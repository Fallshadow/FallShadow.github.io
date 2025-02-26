using UnityEngine;
using Base;
using Gameplay.UI;
using System.Collections.Generic;
#if !UNITY_EDITOR && UNITY_WEBGL
using WeChatWASM;
#endif 
using Sofunny.Asset.Runtime;
using UnityEngine.U2D;
using UnityEngine.Networking;
using System.IO;
using System;


namespace Gameplay {
    public class App : MonoBehaviour {

        #region AppSetting
        [SerializeField]
        RemoteConfig remoteConfig;

        [SerializeField]
        public LocalConfig localConfig;

        UnityWebRequest gameSettingWebRequest;
        UnityWebRequest gameMaintenanceWebRequest;
        UnityWebRequest ipAddressWebRequest;
        bool ipAddressWebRequestCompleted;

        bool isInitFinish;

        [NonSerialized]
        public GameSetting gameSetting;
        [NonSerialized]
        public GameMaintenance gameMaintenance;
        #endregion

        // 资源加载器
        AssetDB db;

        public PersistenceDataManager data;
        // ui 管理器
        public UIManager ui;
        public AudioManager audioManager;
        // stage 切换系统
        public StageSystem stageSystem;

        public NetworkSystem networkSystem;

        // 资源加载系统
        public AssetSystem assetSystem;

        public TimerSystem timerSystem;

        public WXSDKComp wxSDKComp;
        // 引力SDK,做充值，广告打点
        public GravitySDKComp gravitySDKComp;
        // FunnySDK打点，做业务数据打点
        public FunnyDBSDKComp funnyDBSDKComp;
        // 支付SDK
        public PaySDKComp paySDKComp;

        // 流程管理
        public FlowManager flowManager;

        // 暂时没有很好的地方初始化，先放这里
        public ChatFilter chatFilter;

        bool wxSDKCompleted;
        bool appSettingInitCompleted;

        public CacheManager cacheManager;
        private string ipAddress = string.Empty;
        private Action gameMaintenanceHandle;
        private bool isInitGameMaintenanceFinish;
        private bool isGameMaintenanceInit;

        public AssetDB.LoadMode LoadMode {
#if UNITY_EDITOR
            get => PlayerPrefs.GetInt("simulate_load_editor") == 1 ? AssetDB.LoadMode.Editor : AssetDB.LoadMode.Runtime;
#else
            get => AssetDB.LoadMode.Runtime;
#endif
        }

        // Gravity引力打点Token, 从引力后台获取, 固定值
        public const string GravityToken = "qzQOoxdkBbb6FhwlyZDszructeG0s87x";
# if Formal_Evn
        // funnyDB 相关数据(正式)
        public const string FunnyDBKeyId = "FDI_ArSUikhHTd46sBq21WZM";
        public const string FunnyDBkeySecret = "FDS_07P6e6J0kb4eVpR8C99JTrVf5My6";
# else
        // funnyDB 相关数据（测试）
        public const string FunnyDBKeyId = "FDI_XFG1Duhe7sGi8Wsq6UHw";
        public const string FunnyDBkeySecret = "FDS_hm8QEeT9ghUePgi6v2szFHpRYgYI";
#endif

        public const string FunnyDBEndPoint = "https://ingest.zh-cn.xmfunny.com";

        // FunnyDB账户，之后看一下要不要走统一配置
        public const string FunnyPayAccountId = "4141537657";

        // 首帧做的事情尽可能少
        void Awake() {
            Application.runInBackground = true;
            // 屏幕不休眠
            Screen.sleepTimeout = SleepTimeout.NeverSleep;
            DontDestroyOnLoad(this);
            this.SplashInit();
            this.WXSDKInit();
            // 获取本机 IP 地址
            this.GetIPAddress();
        }

        // 获取本机 IP 地址
        private void GetIPAddress() {
            string url = "https://myip.xindong.com/wulala";
#if UNITY_EDITOR
            this.ipAddressWebRequest = UnityWebRequest.Get(url);
            this.ipAddressWebRequest.SendWebRequest();
#else
            this.ipAddressWebRequest = UnityWebRequest.Get(url);
            this.ipAddressWebRequest.SendWebRequest();
#endif
        }

        void SplashInit() {
            var panel = this.transform.Find("SplashPanel");
            if (panel == null) {
                return;
            }
            this.transform.Find("SplashPanel").gameObject.SetActive(true);
        }

        // 微信 SDK 初始化
        void WXSDKInit() {
#if !UNITY_EDITOR && UNITY_WEBGL   //真机且是WebGL
            WX.InitSDK((int code) => {
                this.wxSDKCompleted = true;
                this.wxSDKComp = new WXSDKCompImplement();
                this.wxSDKComp.Init();
                GameObject.Find("App/EventSystem").gameObject.AddComponent<WXTouchInputOverride>();
                this.OnApplicationBasicInitComplete();
            });
#else
            this.wxSDKCompleted = true;
            this.wxSDKComp = new WXSDKComp();
            this.wxSDKComp.Init();
            this.OnApplicationBasicInitComplete();
#endif
        }

        void GameSettingInit(bool isWhiteList) {
            string gameSettingUrl = string.Empty;
#if UNITY_EDITOR
            if (isWhiteList) {
                gameSettingUrl = $"file://{Application.dataPath}/Settings/game_setting_whitelist.json";
            } else {
                gameSettingUrl = $"file://{Application.dataPath}/Settings/game_setting.json";
            }
#else
            // 设置远程资源路径
            if (isWhiteList) {
                gameSettingUrl = $"{remoteConfig.remoteUrl}/game_setting_whitelist.json";
            } else {
                gameSettingUrl = $"{remoteConfig.remoteUrl}/game_setting.json";
            }
#endif
            Debug.Log(gameSettingUrl);
            this.gameSettingWebRequest = UnityWebRequest.Get(gameSettingUrl);
            this.gameSettingWebRequest.SendWebRequest();
        }

        // 基础初始化完成检测
        void OnApplicationBasicInitComplete() {
            if (!this.wxSDKCompleted)
                return;
            if (!this.appSettingInitCompleted)
                return;

            // 引力打点工具初始化
            this.GravitySDKInit();

            // 业务数据打点工具初始化
            this.FunnyDBSDKInit();

            // 支付SDK初始化
            this.PaySDKInit();

            this.AssetsInit();

            this.cacheManager = new CacheManager();
            this.cacheManager.Init();

            this.timerSystem = new TimerSystem();
            this.timerSystem.Initialize();

            this.data = new PersistenceDataManager();
            this.data.Init();

            this.InitSound();

            // 初始化 UI
            this.ui = new UIManager();
            IUIScreenInfoGetter screenInfoGetter = null;
#if !UNITY_EDITOR && UNITY_WEBGL
            screenInfoGetter = new UIWXScreenInfoGetter(this.wxSDKComp);
#else
            screenInfoGetter = new UIUnityScreenInfoGetter();
#endif
            this.ui.Initialize(this.assetSystem, db, this.timerSystem, this.audioManager, this.funnyDBSDKComp, new UIConstSignGetter(), screenInfoGetter);
            this.ui.CreateRoot("UIRoot");
            this.ui.CreateUILayer();

            this.flowManager = new FlowManager();
            this.flowManager.Startup();

            var networkData = this.data.GetPersistence<NetworkData>();
            networkData.deviceId = this.funnyDBSDKComp.GetDeviceId();
            this.networkSystem = new NetworkSystem();
            this.networkSystem.Init(this.gameSetting, networkData);

            this.stageSystem = new StageSystem();
            this.stageSystem.Initialize(this);
            this.stageSystem.Load(null);
            this.stageSystem.SwitchStage(new LaunchStage(this));

            this.InitChatFilter();
            Command.Init();
            RegisterCommand();

            this.InitInGameDebugConsole();
            Debug.Log("OnApplicationBasicInitComplete");
        }

        // 引力SD看初始化（充值，广告这些的打点）
        void GravitySDKInit() {
            if (this.gameSetting.isWXSDKTokenLogin && this.gameSetting.isOpenGravitySDK) {
                this.gravitySDKComp = new GravitySDKCompImplement();
            } else {
                this.gravitySDKComp = new GravitySDKComp();
            }
        }

        // 业务打点
        void FunnyDBSDKInit() {
            if (this.gameSetting.isOpenFunnyDBSDK) {
                this.funnyDBSDKComp = new FunnyDBSDKCompImplement();
            } else {
                this.funnyDBSDKComp = new FunnyDBSDKComp();
            }
            this.funnyDBSDKComp.InitSDK();
        }

        // 支付SDK初始化
        void PaySDKInit() {
            string platform = wxSDKComp.GetPlatform();
            if (this.gameSetting.isWXSDKTokenLogin) {
                if ((platform == "ios" && this.gameSetting.isIOSOpenPaySDK) ||
                (platform == "android" && this.gameSetting.isAndroidOpenPaySDK) ||
                ((platform == "mac" || platform == "windows") && this.gameSetting.isPCOpenPaySDK)) {
                    this.paySDKComp = new PaySDKCompImplement();
                } else {
                    this.paySDKComp = new PaySDKComp();
                }
            } else {
                this.paySDKComp = new PaySDKComp();
            }

            this.paySDKComp.InitSDK();
        }

        // 资源相关初始化
        void AssetsInit() {
            // 初始化 DB
            this.InitDB();
            this.assetSystem = new AssetSystem();
            this.assetSystem.Initialize(db);
        }

        void RegisterCommand() {
            Command.RegisterCommand("enter_secret_area_panel", "进入秘境界面", (List<string> list) => {
                var testStage = new TestSecretAreaPanelStage(this);
                ui.GetUI(UIConst.StartupUI)?.Close();
                stageSystem.SwitchStage(testStage);
            });

            Command.RegisterCommand("enter_secret_area_battle", "进入秘境场景", (List<string> list) => {
                var testStage = new TestSecretAreaStage(this);
                ui.GetUI(UIConst.StartupUI)?.Close();
                stageSystem.SwitchStage(testStage);
            });

            Command.RegisterCommand("enter_test_teamstage", "进入组队界面测试", (list) => {
                var testTeamStage = new TestTeamStage(this);
                ui.GetUI(UIConst.StartupUI)?.Close();
                stageSystem.SwitchStage(testTeamStage);
            });
            Command.RegisterCommand("enter_test_adventure_panel_stage", "进入冒险主界面测试", (list) => {
                var testStage = new TestAdventurePanelStage(this);
                ui.GetUI(UIConst.StartupUI)?.Close();
                stageSystem.SwitchStage(testStage);
            });

            Command.RegisterCommand("enter_test_actor_panel_stage", "进入角色主界面测试", (list) => {
                var testStage = new TestActorEquipStage(this);
                ui.GetUI(UIConst.StartupUI)?.Close();
                stageSystem.SwitchStage(testStage);
            });

            Command.RegisterCommand("enter_test_monster_chest_panel_stage", "测试怪物宝箱", (list) => {
                var testStage = new TestMonsterChestPanelStage(this);
                ui.GetUI(UIConst.StartupUI)?.Close();
                stageSystem.SwitchStage(testStage);
            });
        }

        void InitDB() {
            db = new AssetDB();
            db.Initialize(LoadMode);
            db.RegisterAsset(".txt", typeof(TextAsset), false);
            db.RegisterAsset(".json", typeof(TextAsset), false);
            db.RegisterAsset(".csv", typeof(TextAsset), false);
            db.RegisterAsset(".toml", typeof(TextAsset), false);
            db.RegisterAsset(".xml", typeof(TextAsset), false);
            db.RegisterAsset(".level", typeof(TextAsset), false);
            db.RegisterAsset(".bin", typeof(TextAsset), true);
            db.RegisterAsset(".dll", typeof(TextAsset), true);
            db.RegisterAsset(".mjs", typeof(TextAsset), false);
            db.RegisterAsset(".js", typeof(TextAsset), false);
            db.RegisterAsset(".ttf", typeof(Font), false);
            db.RegisterAsset(".prefab", typeof(GameObject), false);
            db.RegisterAsset(".mat", typeof(Material), false);
            db.RegisterAsset(".shader", typeof(Shader), false);
            db.RegisterAsset(".anim", typeof(AnimationClip), false);
            db.RegisterAsset(".controller", typeof(RuntimeAnimatorController), false);
            db.RegisterAsset(".sprite", typeof(Sprite), false);
            db.RegisterAsset(".spriteatlas", typeof(SpriteAtlas), false);
            db.RegisterAsset(".spriteatlasv2", typeof(SpriteAtlas), false);
            db.RegisterAsset(".asset", typeof(ScriptableObject), false);
            db.RegisterAsset(".png", typeof(Texture), false);
            db.RegisterAsset(".jpg", typeof(Texture), false);
            db.RegisterAsset(".tga", typeof(Texture), false);
            db.RegisterAsset(".playable", typeof(UnityEngine.Playables.PlayableAsset), false);
            db.RegisterAsset(".unity", typeof(UnityEngine.SceneManagement.Scene), false);
            db.RegisterAsset(".wav", typeof(UnityEngine.AudioClip), true);
            db.RegisterAsset(".mp3", typeof(UnityEngine.AudioClip), true);


#if !UNITY_EDITOR
            // 设置远程资源路径
            Debug.Log("远程地址：" + $"{remoteConfig.remoteUrl}/StreamingAssets");
            db.SetSpecialDirectory($"{remoteConfig.remoteUrl}/StreamingAssets");
            db.SetFilesUrl($"{remoteConfig.remoteUrl}/Version/{this.gameSetting.resNum}.txt");
            db.Mount($"{remoteConfig.remoteUrl}/StreamingAssets");
#else
            string sandboxMountPath = Path.GetFullPath($"{Application.dataPath}/../sandbox");
            db.SetFilesUrl($"{sandboxMountPath}/files.txt");
            // Mount 指定文件夹
            db.Mount(sandboxMountPath);
#endif
            db.GlobFiles();
        }

        void GameSettingTick() {
            if (!this.isInitFinish && gameSettingWebRequest != null) {
                if (gameSettingWebRequest.isDone) {
                    this.isInitFinish = true;
                    if (gameSettingWebRequest.result != UnityWebRequest.Result.Success) {
                        this.ui.Instantiate<CommonInfoTip>((ui) => {
                            ui.Init($"请求AppSetting Error: {gameSettingWebRequest.error}");
                            ui.Show();
                            ui.Close(1);
                        }, UILayer.Tip);
                        this.gameSetting = new GameSetting() { serverHost = "http://dev-passport.lite-ulala.funnyrpg.com/" };
                    } else {
                        string responseText = gameSettingWebRequest.downloadHandler.text;
                        Debug.Log($"GameSetting: {responseText}");
                        this.gameSetting = JsonUtility.FromJson<GameSetting>(responseText);
                    }
                    if (CheckIsWhiteList()) {
                        isInitFinish = false;
                        GameSettingInit(true);
                    } else {
                        this.appSettingInitCompleted = true;
                        ReqGameMaintenanceInfo(true);
                    }
                }
            }
        }

        // 请求游戏维护信息
        public void ReqGameMaintenanceInfo(Action callBack) {
            this.gameMaintenanceHandle = callBack;
            ReqGameMaintenanceInfo(false);
        }

        void ReqGameMaintenanceInfo(bool init) {
            this.isGameMaintenanceInit = init;
            this.isInitGameMaintenanceFinish = false;
            string gameUrl = string.Empty;
#if UNITY_EDITOR
            gameUrl = $"file://{Application.dataPath}/Settings/game_maintenance.json";
#else
            gameUrl = gameSetting.gameMaintenanceUrl;
#endif
            Debug.Log($"请求游戏维护 URL: {gameUrl}");
            if (string.IsNullOrEmpty(gameUrl)) {
                gameMaintenance = new GameMaintenance();
                this.OnApplicationBasicInitComplete();
                return;
            }
            this.gameMaintenanceWebRequest = UnityWebRequest.Get(gameUrl);
            this.gameMaintenanceWebRequest.SendWebRequest();
        }

        void GameGameMaintenanceTick() {
            if (!isInitGameMaintenanceFinish && gameMaintenanceWebRequest != null) {
                if (gameMaintenanceWebRequest.isDone) {
                    isInitGameMaintenanceFinish = true;
                    try {
                        if (gameMaintenanceWebRequest.result != UnityWebRequest.Result.Success) {
                            this.ui.Instantiate<CommonInfoTip>((ui) => {
                                ui.Init($"请求游戏维护信息 Error: {gameMaintenanceWebRequest.error}");
                                ui.Show();
                                ui.Close(1);
                            }, UILayer.Tip);
                            this.gameMaintenance = new GameMaintenance();
                        } else {
                            string responseText = gameMaintenanceWebRequest.downloadHandler.text;
                            Debug.Log($"gameMaintenance: {responseText}");
                            this.gameMaintenance = JsonUtility.FromJson<GameMaintenance>(responseText);
                        }
                        gameMaintenanceHandle?.Invoke();
                        if (isGameMaintenanceInit) {
                            this.OnApplicationBasicInitComplete();
                        }
                    } catch (System.Exception e) {
                        UnityEngine.Debug.LogError($"请求游戏维护信息 Error: {e}");
                    }
                }
            }
        }

        // 检查是否是白名单
        bool CheckIsWhiteList() {
            if (!gameSetting.openWhiteList) {
                return false;
            }

            if (this.ipAddress == string.Empty) {
                return false;
            }

            if (gameSetting.whiteList == null) {
                return false;
            }

            for (int i = 0; i < gameSetting.whiteList.Length; i++) {
                if (this.ipAddress == gameSetting.whiteList[i]) {
                    return true;
                }
            }
            return false;
        }

        // IP 地址 Tick
        void IPAddresTick() {
            if (this.ipAddressWebRequest != null) {
                if (this.ipAddressWebRequest.isDone) {
                    if (this.ipAddressWebRequest.result != UnityWebRequest.Result.Success) {
                        this.ui.Instantiate<CommonInfoTip>((ui) => {
                            ui.Init($"请求IP地址 Error: {this.ipAddressWebRequest.error}");
                            ui.Show();
                            ui.Close(1);
                        }, UILayer.Tip);
                    } else {
                        AreaConfig areaConig = new AreaConfig();
                        areaConig.ToData(this.ipAddressWebRequest.downloadHandler.text);
                        ipAddress = areaConig.Ip;
                        Debug.Log($"本机IP地址：{ipAddress}");
                    }
                    this.GameSettingInit(false);
                    ipAddressWebRequestCompleted = true;
                    ipAddressWebRequest = null;
                }
            }
        }

        void InitChatFilter() {
            this.chatFilter = new ChatFilter();
            string url = $"asset://Scripts/GenCode/Configs/{Configs.SensitivewordsManager.CsvFile}";
            this.assetSystem.RequestLoadAsset(url, (string txt) => {
                if (txt != null) {
                    Configs.SensitivewordsManager.Load(txt);
                    Configs.SensitivewordsManager.ForEach((sensitivewords) => {
                        this.chatFilter.AddWord(sensitivewords.Words);
                        return false;
                    });
                    // TODO 清理表数据
                } else {
                    UnityEngine.Debug.LogError($"加载 csv {url} 配置失败");
                }
            });
        }

        void InitInGameDebugConsole() {
            if (this.gameSetting.openDebugConsole) {
                string url = $"asset://Engine/UnityIngameDebugConsole/UnityIngameDebugConsole/Plugins/IngameDebugConsole/Prefab/IngameDebugConsole.prefab";
                this.assetSystem.RequestLoadAsset(url, (UnityEngine.Object asset) => {
                    GameObject consoleAsset = asset as GameObject;
                    var go = GameObject.Instantiate<GameObject>(consoleAsset);
                    GameObject.DontDestroyOnLoad(go);
                });
            }
        }

        // 初始化音效
        void InitSound() {
            this.audioManager = new AudioManager();
            this.audioManager.Init(this.transform, this.timerSystem);
        }

        void Update() {
            this.IPAddresTick();
            this.GameSettingTick();
            this.GameGameMaintenanceTick();
            this.cacheManager?.Tick();
            this.flowManager?.Tick();
            this.db?.Tick();
            this.data?.Tick();
            this.ui?.Tick();
            this.audioManager?.Tick();
            this.networkSystem?.Tick();
            this.assetSystem?.Tick();
            this.timerSystem?.Tick();
            this.stageSystem?.Tick();
            this.wxSDKComp?.Tick();
            Command.Tick();
        }

        void OnDestroy() {
            this.flowManager?.Exit();
            this.cacheManager?.Save();
            this.networkSystem?.Destroy();
            this.data?.Destroy();
            this.ui?.Dispose();
            this.db?.Dispose();
            ipAddressWebRequest?.Dispose();
            gameSettingWebRequest?.Dispose();
            gameMaintenanceWebRequest?.Dispose();
            Command.Destroy();
        }

        void OnApplicationQuit() {
            this.cacheManager?.Save();
        }
    }
}
