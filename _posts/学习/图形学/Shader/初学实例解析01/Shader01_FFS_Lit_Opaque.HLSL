#pragma vertex VSMain
#pragma pixel PSMain

#pragma keyword QTANGENT
#pragma keyword TEXTURE_ARRAY_ENABLE
//#pragma keyword CE_INSTANCING
// #pragma keyword CLUSTER_RENDERING
#pragma keyword FOLIAGE_RENDERING
//#pragma keyword CPU_SKIN   
#pragma keyword USED_WITH_SKELETAL_MESH

#define ENABLE_DEFERRED_VIRSUALIZE
#define CE_USE_DOUBLE_TRANSFORM 1

#ifdef FOLIAGE_RENDERING
    #define CE_INSTANCING
    #define VERTEX_TYPE VertexType_Vegetation
#endif

#define FULL_CUSTOM 1
#define ADDITIONAL_MTL_PARAM \
float _Roughness; \
float _Metallic; \
float4 _SubsurfaceColor; \
float4 _EmissiveColor; \
float _Opacity; \
float _OpacityMask; \
float2 _ScaleUV; \
float2 _OffsetUV; \
float _AlphaClip; \
float _Specular; \
float _BlinkingPower;\
float _BlinkingRate;\
float NIGHT;\
bool ANISOTROPIC_SAMPLE;\
//float _VertOffsetIntensity; \

#ifndef USED_WITH_SKELETAL_MESH
    float2 _Reactivemask;
#endif

Texture2D<float4> _MROTex : register(space1);
Texture2D<float4> _EmissiveMap : register(space1);

#include "/Material/Lit/SurfaceShaderIncludes.hlsl"

SHADER_CONST(bool, ALPHA_CLIP, false);
SHADER_CONST(bool, USE_NIGHT_LIGHT, false);
SHADER_CONST(bool, USE_BLINKING_LIGHT, false);
SHADER_CONST(bool, USE_EMISSIVE_MAP, false);

#ifdef CE_INSTANCING 
SurfaceData GetSurfaceData(ObjectSceneData objectData, SurfaceInput input)
#else
SurfaceData GetSurfaceData(SurfaceInput input)
#endif
{
	SurfaceData surfaceData = (SurfaceData)0;

    float2 uv = input.uv;
    float4 channels = float4(1,1,1,1);
    if(ANISOTROPIC_SAMPLE)
    {
        channels = _NormalMap.SampleBias(ce_Sampler_Anisotropic, uv, _TextureSampleBias);
    }
    else
    {
        channels = _NormalMap.SampleBias(ce_Sampler_Repeat, uv, _TextureSampleBias);
    }
	
    float4 color = _BaseMap.SampleBias(ce_Sampler_Repeat, uv, _TextureSampleBias);
    float3 normalTS = UnpackNormalmapRGorAG(channels, 1.0);
    //R:Metallic G:Roughness B:AO A:EmissiveMask
    float4 MRO_Tex = _MROTex.Sample(ce_Sampler_Repeat, uv);

	surfaceData.baseColor = color * _BaseColor.rgb;
	surfaceData.opacity = color.a * _Opacity;
    surfaceData.opacityMask = color.a * _OpacityMask;
    surfaceData.opacityMaskClip = _AlphaClip;
    surfaceData.normalTS = normalTS;
    surfaceData.metallic = _Metallic * MRO_Tex.r;
	surfaceData.roughness = _Roughness * MRO_Tex.g;
    surfaceData.specular = _Specular;

    float3 emissiveColor = _EmissiveColor * surfaceData.baseColor * MRO_Tex.a;
    if(USE_EMISSIVE_MAP){
        emissiveColor = _EmissiveMap.SampleBias(texture_sampler,uv,_TextureSampleBias)*_EmissiveColor;
    }
	surfaceData.emissiveColor = emissiveColor; 
    if(USE_NIGHT_LIGHT) 
    {
        if(USE_BLINKING_LIGHT)surfaceData.emissiveColor *= pow(sin(ce_Time.x * _BlinkingRate ), _BlinkingPower);
        surfaceData.emissiveColor *= NIGHT;

    }
    surfaceData.ambientOcclusion = MRO_Tex.b * _AO_Intensity;
    surfaceData.subsurfaceColor =  _SubsurfaceColor * _BaseColor.rgb;
	surfaceData.materialType = MATERIAL_TYPE;


        // Fsr reactive mask
    #ifdef USED_WITH_SKELETAL_MESH   
        float3 normalInView = mul(ce_View, float4(input.normalWS.xyz, 0.0));
        normalInView = normalize(normalInView);

        float reactiveFactor = min(0.0, dot(normalInView, float3(0, 0, 1))); // -1.0 -- 0.0
        reactiveFactor = step(_Reactivemask.x, 1.0 - abs(reactiveFactor)) * (1.0 - abs(reactiveFactor)) * _Reactivemask.y;
        surfaceData.temporalReactive = reactiveFactor;
    #else
        // temporalReactive.x 范围：0-1，值越大，历史影响的越少，拖尾越少，但随之抗锯齿效果越差，temporalReactive.y 是定位半透明像素,效果不明显
        surfaceData.temporalReactive = _Reactivemask;
    #endif
    surfaceData.debugColor = 10;

    //surfaceData.debugColor = channels.xyz;
	return surfaceData;
}


#include "/Material/Lit/Lit.hlsl"
#include "/RenderPass/ShaderPassGBuffer.hlsl"