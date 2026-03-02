#ifndef COMMON_HLSL
#define COMMON_HLSL

#define FLATTEN [flatten]
#define UNROLL  [unroll]
#define UNROLL_N(N) [unroll(N)]
#define BRANCH  [branch]

#define M_PI                3.14159265358979
#define M_2PI               6.28318530717958
#define M_InvPI             0.31830988618379
#define M_E                 2.71828182845904
#define M_InvE              0.36787944117144
#define M_Log2_E			1.44269504088896340736
#define M_GoldenRadito      1.61803398874989

#define M_EarthGravity      9.80665
#define M_SpeedOfLight      2.99792458e8

#define M_RefractIndex_Water        1.333
#define M_RefractIndex_Cornea       1.380
#define M_RefractIndex_Oil          1.470
#define M_RefractIndex_Glass        1.500
#define M_RefractIndex_Jade         1.641
#define M_RefractIndex_Gem          1.760
#define M_RefractIndex_Crystal      2.000
#define M_RefractIndex_Diamond      2.417

#define M_FloatEps  5.960464478e-8  // 2^-24, machine epsilon: 1 + EPS = 1 (half of the ULP for 1.0f)
#define M_FloatMin  1.175494351e-38 // Minimum normalized positive floating-point number
#define M_FloatMax  3.402823466e+38 // Maximum representable floating-point number
#define M_FloatEps  5.960464478e-8  // 2^-24, machine epsilon: 1 + EPS = 1 (half of the ULP for 1.0f)

#define M_RoughnessFloatMin  0.045
#define M_Roughness2FloatMin 0.002025

// for mobile, min roughness such that (M_RoughnessHalfMin^4) > 0 in fp16 (i.e. 2^(-14/4), rounded up)
#define M_RoughnessHalfMin  0.089
#define M_Roughness2HalfMin 0.007921

#define M_RoughnessMin M_RoughnessFloatMin   // material gui roughness min  
#define M_Roughness2Min M_Roughness2FloatMin // material gui roughness^2 min 

#define VertexType_Standard 0
#define VertexType_Vegetation 1
#define VertexType_Terrain 2

#define Square(x) (x * x)
#define Degree2Radian(d) (d*(M_PI/180))
#define Radian2Degree(r) (r*(180/M_PI))

//https://shaderbits.com/blog/optimized-snell-s-law-refraction/
//Remark:   eta = refract_index - 1 
//          Only wrok for refract_index >= 1
#define FastRefract(i, n, eta)  (normalize(-n*eta + i)) 

//Todo : shader compiler ...
#define half float
#define half2 float2
#define half3 float3
#define half4 float4

#define OUT_ARG
#define INOUT_ARG

#define MAX_RP_NUM  10

// ----------------------------------------------------------------------------
// Subpass Input
// ----------------------------------------------------------------------------

#if CROSS_NGI_SUPPORT_SUBPASS_INPUT

#define CROSS_DECLARE_SUBPASS_INPUT(type, name, index, space) \
[[vk::input_attachment_index(index)]] \
SubpassInput<type> name : register(space);

#define CROSS_SUBPASS_LOAD(name, sampler, pos) name.SubpassLoad()

#else

#define CROSS_DECLARE_SUBPASS_INPUT(type, name, index, space) \
Texture2D<type> name : register(space);

#define CROSS_SUBPASS_LOAD(name, sampler, pos) name.Sample(sampler, pos)

#endif
//
// Trigonometric functions
//

// max absolute error 9.0x10^-3
// Eberly's polynomial degree 1 - respect bounds
// 4 VGPR, 12 FR (8 FR, 1 QR), 1 scalar
// input [-1, 1] and output [0, PI]
float acosFast(float inX) 
{
    float x = abs(inX);
    float res = -0.156583f * x + (0.5 * M_PI);
    res *= sqrt(1.0f - x);
    return (inX >= 0) ? res : M_PI - res;
}

// Same cost as acosFast + 1 FR
// Same error
// input [-1, 1] and output [-PI/2, PI/2]
float asinFast( float x )
{
    return (0.5 * M_PI) - acosFast(x);
}

// ----------------------------------------------------------------------------
// Depth encoding/decoding
// ----------------------------------------------------------------------------

float LinearEyeDepth(float depth, float4x4 projMatrix)
{
    return (projMatrix[2][3] / (depth - projMatrix[2][2]));
}

float LinearEyeDepth(float3 positionWS, float4x4 viewMatrix)
{
    float viewSpaceZ = mul(viewMatrix, float4(positionWS, 1.0)).z;
    return abs(viewSpaceZ);
}

float Linear01Depth(float depth, float4x4 projMatrix)
{
    float zNear = -projMatrix[2][3] / projMatrix[2][2];
    float zFar = projMatrix[2][3] / (1.0 - projMatrix[2][2]);

    return (LinearEyeDepth(depth, projMatrix) - zNear) / (zFar - zNear);
}


// ----------------------------------------------------------------------------
// Grid Culling
// ----------------------------------------------------------------------------

uint ComputeLightGridCellIndex(uint2 PixelPos, float SceneDepth, float3 LightGridZParamsBOS, uint3 CulledGridSizeXYZ, uint LightGridPixelSizeShift)//sceneDepth ViewSpace
{
    uint ZSlice = (uint)(max(0, log2(SceneDepth * LightGridZParamsBOS.x + LightGridZParamsBOS.y) * LightGridZParamsBOS.z));
    ZSlice = min(ZSlice, (uint)(CulledGridSizeXYZ.z - 1));
    uint3 GridCoord = uint3(PixelPos >> LightGridPixelSizeShift, ZSlice);
    return (GridCoord.z * CulledGridSizeXYZ.y + GridCoord.y) * CulledGridSizeXYZ.x + GridCoord.x;
}

float ConvertFromDeviceZ(float DeviceZ, matrix projMat)
{
    return (projMat[2][3] / (DeviceZ - projMat[2][2]));
}

float ConvertToDeviceZ(float SceneDepth, matrix projMat)
{
    return projMat[2][3] / SceneDepth + projMat[2][2];
}


// ----------------------------------------------------------------------------
// Space transformations
// ----------------------------------------------------------------------------

float4 ComputeClipSpacePosition(float2 positionNDC, float deviceDepth)
{
    float4 positionCS = float4(positionNDC * 2.0 - 1.0, deviceDepth, 1.0);
    return positionCS;
}

float3 ComputeWorldSpacePosition(float2 positionNDC, float deviceDepth, float4x4 invViewProjMatrix)
{
    float4 positionCS = ComputeClipSpacePosition(positionNDC, deviceDepth);
    float4 hpositionWS = mul(invViewProjMatrix, positionCS);
    return hpositionWS.xyz / hpositionWS.w;
}

float3 ComputeWorldSpacePosition(float4 positionCS, float4x4 invViewProjMatrix)
{
    float4 hpositionWS = mul(invViewProjMatrix, positionCS);
    return hpositionWS.xyz / hpositionWS.w;
}

// ----------------------------------------------------------------------------
// PositionInputs
// ----------------------------------------------------------------------------

struct PositionInputs
{
    float3 positionWS;  // World space position (could be camera-relative)
    float2 positionNDC; // Normalized screen coordinates within the viewport    : [0, 1) (with the half-pixel offset)
    uint2  positionSS;  // Screen space pixel coordinates                       : [0, NumPixels)
    uint2  tileCoord;   // Screen tile coordinates                              : [0, NumTiles)
    float  deviceDepth; // Depth from the depth buffer                          : [0, 1] (typically reversed)
    float  linearDepth; // View space Z coordinate                              : [Near, Far]
    float2 uv;
};


PositionInputs GetPositionInput(float3 positionWS, float2 screenUV)
{
    PositionInputs posInput = (PositionInputs)0;
    posInput.positionWS = positionWS;
    posInput.positionNDC = float2(screenUV.x, 1.0f - screenUV.y); 
    posInput.uv = screenUV;
    return posInput;
}

PositionInputs GetPositionInput(float2 uv, float deviceDepth,
    float4x4 invViewProjMatrix, float4x4 viewMatrix)
{
    PositionInputs posInput = (PositionInputs)0;
    posInput.positionNDC = float2(uv.x, 1.0 - uv.y);
    posInput.uv = uv;
    posInput.positionWS = ComputeWorldSpacePosition(posInput.positionNDC, deviceDepth, invViewProjMatrix);
    posInput.deviceDepth = deviceDepth;
    posInput.linearDepth = LinearEyeDepth(posInput.positionWS, viewMatrix);

    return posInput;
}

// Called by compute shader
PositionInputs GetPositionInput(float2 positionSS, float2 invScreenSize)
{
    PositionInputs posInput = (PositionInputs)0;

    posInput.positionNDC = positionSS;
    posInput.positionNDC.xy += float2(0.5, 0.5);
    posInput.positionNDC *= invScreenSize;
    posInput.positionNDC.y = 1.0 - posInput.positionNDC.y;
    posInput.positionSS = uint2(positionSS);

    return posInput;
}

// Called by compute shader
PositionInputs GetPositionInput(float2 positionSS, float2 invScreenSize, float deviceDepth,
    float4x4 invViewProjMatrix, float4x4 viewMatrix)
{
    PositionInputs posInput = GetPositionInput(positionSS, invScreenSize);
    posInput.positionWS = ComputeWorldSpacePosition(posInput.positionNDC, deviceDepth, invViewProjMatrix);
    posInput.deviceDepth = deviceDepth;
    posInput.linearDepth = LinearEyeDepth(posInput.positionWS, viewMatrix);

    return posInput;
}

// ----------------------------------------------------------------------------
// Large World Coordinates System Position
// ----------------------------------------------------------------------------

#ifndef LENGTH_PER_TILE
#define LENGTH_PER_TILE 65536.0

float3 GetLargeCoordinateReltvPosition(float3 posOffsetInModelTile, float3 modelTileInLargeWorld, float3 orgTileInLargeWorld)
{
    return posOffsetInModelTile + (modelTileInLargeWorld - orgTileInLargeWorld) * LENGTH_PER_TILE;
}

float3 GetLargeCoordinatePositionOffset(float3 modelTileInLargeWorld, float3 orgTileInLargeWorld)
{
    return (modelTileInLargeWorld - orgTileInLargeWorld) * LENGTH_PER_TILE;
}

float3 GetLargeCoordinateModelPosition(float3 posOffsetInOrgTile, float3 modelTileInLargeWorld, float3 orgTileInLargeWorld)
{
    return posOffsetInOrgTile + (orgTileInLargeWorld - modelTileInLargeWorld) * LENGTH_PER_TILE;
}

float3 GetLargeCoordinateAbsolutePosition(float3 RelativePosition, float3 TileIndex)
{
    return RelativePosition + TileIndex * LENGTH_PER_TILE;
}

float2 GetLargeCoordinateAbsolutePosition(float2 RelativePosition, float2 TileIndex)
{
    return RelativePosition + TileIndex * LENGTH_PER_TILE;
}
#endif

float DefaultUnitToKm(float inDefaultUnit)
{
    return inDefaultUnit * 0.00001f;
}

float DefaultUnitToDm(float inDefaultUnit)
{
    return inDefaultUnit * 0.1;
}

float DefaultUnitToM(float inDefaultUnit)
{
    return inDefaultUnit * 0.01;
}

float2 DefaultUnitToKm(float2 inDefaultUnit)
{
    return inDefaultUnit * 0.00001f;
}

float2 DefaultUnitToDm(float2 inDefaultUnit)
{
    return inDefaultUnit * 0.1;
}

float2 DefaultUnitToM(float2 inDefaultUnit)
{
    return inDefaultUnit * 0.01;
}

float3 DefaultUnitToKm(float3 inDefaultUnit)
{
    return inDefaultUnit * 0.00001f;
}

float3 DefaultUnitToDm(float3 inDefaultUnit)
{
    return inDefaultUnit * 0.1;
}

float3 DefaultUnitToM(float3 inDefaultUnit)
{
    return inDefaultUnit * 0.01;
}

matrix CombineTranslationMatrix(matrix localToWorld, matrix worldToClip, float3 objectTilePosition, float3 cameraTilePosition)
{
    matrix result = localToWorld;
    float3 offset = (objectTilePosition - cameraTilePosition) * LENGTH_PER_TILE;
    result[0].w += offset.x;
    result[1].w += offset.y;
    result[2].w += offset.z;
    return mul(worldToClip, result);
}

// ----------------------------------------------------------------------------
// Common math functions
// ----------------------------------------------------------------------------

float CopySign(float x, float s)
{
    return (s >= 0) ? abs(x) : -abs(x);
}

float FastSign(float s)
{
    return CopySign(1.0, s);
}

float4x4 inverse(float4x4 m) {
    float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0], n14 = m[3][0];
    float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1], n24 = m[3][1];
    float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2], n34 = m[3][2];
    float n41 = m[0][3], n42 = m[1][3], n43 = m[2][3], n44 = m[3][3];

    float t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
    float t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
    float t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
    float t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;

    float det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;
    float idet = 1.0f / det;

    float4x4 ret;

    ret[0][0] = t11 * idet;
    ret[0][1] = (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * idet;
    ret[0][2] = (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * idet;
    ret[0][3] = (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * idet;

    ret[1][0] = t12 * idet;
    ret[1][1] = (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * idet;
    ret[1][2] = (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * idet;
    ret[1][3] = (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * idet;

    ret[2][0] = t13 * idet;
    ret[2][1] = (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * idet;
    ret[2][2] = (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * idet;
    ret[2][3] = (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * idet;

    ret[3][0] = t14 * idet;
    ret[3][1] = (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * idet;
    ret[3][2] = (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * idet;
    ret[3][3] = (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * idet;

    return ret;
}

float3 BoxProjectedCubemapDirection(float3 worldRefl, float3 worldPos, float3 cubemapCenter, float3 boxMin, float3 boxMax)
{
    float3 nrdir = normalize(worldRefl);

#if 1
    float3 rbmax = (boxMax.xyz - worldPos) / nrdir;
    float3 rbmin = (boxMin.xyz - worldPos) / nrdir;

    float3 rbminmax = select((nrdir > 0.0f), rbmax, rbmin);

#else // Optimized version
    float3 rbmax = (boxMax.xyz - worldPos);
    float3 rbmin = (boxMin.xyz - worldPos);

    float3 select = step(float3(0, 0, 0), nrdir);
    float3 rbminmax = lerp(rbmax, rbmin, select);
    rbminmax /= nrdir;
#endif

    float fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);

    worldPos -= cubemapCenter.xyz;
    worldRefl = worldPos + nrdir * fa;

    return worldRefl;
}

float3x3 GetRotMatrixFromEuler(float3 EulerAngles)
{
    float3x3 res = float3x3(
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0
        );
    float c1 = cos(EulerAngles.y / 180.0 * M_PI);
    float s1 = sin(EulerAngles.y / 180.0 * M_PI);
    float c2 = cos(EulerAngles.x / 180.0 * M_PI);
    float s2 = sin(EulerAngles.x / 180.0 * M_PI);
    float c3 = cos(EulerAngles.z / 180.0 * M_PI);
    float s3 = sin(EulerAngles.z / 180.0 * M_PI);
    res[0][0] = c1 * c3 + s1 * s2 * s3;
    res[0][1] = c2 * s3;
    res[0][2] = c1 * s2 * s3 - s1 * c3;
    res[1][0] = c3 * s1 * s2 - c1 * s3;
    res[1][1] = c2 * c3;
    res[1][2] = s1 * s3 + c1 * c3 * s2;
    res[2][0] = c2 * s1;
    res[2][1] = -s2;
    res[2][2] = c1 * c2;
    return res;
}

// float3x3 GetRotMatrixFromEuler(float3 EulerAngles)
// {
//     float3x3 res;

//     float c1 = cos(EulerAngles.y / 180.0 * M_PI);
//     float s1 = sin(EulerAngles.y / 180.0 * M_PI);
//     float c2 = cos(EulerAngles.x / 180.0 * M_PI);
//     float s2 = sin(EulerAngles.x / 180.0 * M_PI);
//     float c3 = cos(EulerAngles.z / 180.0 * M_PI);
//     float s3 = sin(EulerAngles.z / 180.0 * M_PI);

//     res[0][0] = c1 * c3 - s1 * c2 * s3;
//     res[0][1] = -s1 * s2;
//     res[0][2] = c1 * s3 + s1 * c2 * c3;

//     res[1][0] = s1 * c3 + c1 * c2 * s3;
//     res[1][1] = c1 * s2;
//     res[1][2] = s1 * s3 - c1 * c2 * c3;

//     res[2][0] = -s2 * c3;
//     res[2][1] = c2;
//     res[2][2] = s2 * s3;

//     return res;
// }

// Rotation order:      Heading(yaw) Pitch Back(roll)
// Vector multi order:  vector in Right side
// Left hand system:    x right, y top, z forward
// matrix:              _m00、_m01、_m02、_m03
//                      _m10、_m11、_m12、_m13
//                      _m20、_m21、_m22、_m23
//                      _m30、_m31、_m32、_m33
// Attention!!!
// 1. Euler angle in radian
// 2. Matrix generated by translate & rotation: first TRANS then ROT: T * Rh * Rp * Rb * V_space = V_world
//                                                                    return val: V_space = RETURN * V_world                                                                             
matrix GetTransMatrixInverseFromEulerAndPos(float3 EulerAngles, float3 Position)
{
    matrix res = matrix(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
        );
    
    // get inverse(Rh * Rp * Rb) = Rb_inv * Rp_inv * Rh_inv
    float cH = cos(EulerAngles.y); // yaw
    float sH = sin(EulerAngles.y); 
    float cP = cos(EulerAngles.x); // pitch
    float sP = sin(EulerAngles.x); 
    float cB = cos(EulerAngles.z); // roll
    float sB = sin(EulerAngles.z); 

    res._m00 = cH * cB + sH * sP * sB;
    res._m10 = -sB * cH + cB * sP * sH;
    res._m20 = cP * sH;
    
    res._m01 = sB * cP;
    res._m11 = cB * cP;
    res._m21 = -sP;

    res._m02 = -cB * sH + sB * sP * cH;
    res._m12 = sB * sH + cB * sP * cH;
    res._m22 = cP * cH;
    
    // Vertex_space = inverse(Rh * Rp * Rb) * inverse(Trans) * Vertex_world
    Position = Position * -1.0;
    res._m03 = Position.x * res._m00 + Position.y * res._m01 + Position.z * res._m02;
    res._m13 = Position.x * res._m10 + Position.y * res._m11 + Position.z * res._m12;
    res._m23 = Position.x * res._m20 + Position.y * res._m21 + Position.z * res._m22;
    
    return res;
}

float3x3 GetRotMatrixFromAxisTheta(float3 axis, float theta)
{
    float3x3 res = float3x3(
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0
        );
    float cos_theta = cos(theta);
    float sin_theta = sin(theta);
    float a = axis.x;
    float b = axis.y;
    float c = axis.z;
    float a2 = axis.x * axis.x;
    float b2 = axis.y * axis.y;
    float c2 = axis.z * axis.z;
    float ab = axis.x * axis.y;
    float ac = axis.x * axis.z;
    float bc = axis.y * axis.z;
    res[0][0] = (b2 + c2) * cos_theta + a2;
    res[0][1] = ab * (1 - cos_theta) + c * sin_theta;
    res[0][2] = ac * (1 - cos_theta) - b * sin_theta;
    res[1][0] = ab * (1 - cos_theta) - c * sin_theta;
    res[1][1] = b2 + (1 - b2) * cos_theta;
    res[1][2] = bc * (1 - cos_theta) + a * sin_theta;
    res[2][0] = ac * (1 - cos_theta) + b * sin_theta;
    res[2][1] = bc * (1 - cos_theta) - a * sin_theta;
    res[2][2] = c2 + (1 - c2) * cos_theta;

    return res;
}

float Pow1(float x)
{
    return x;
}

float Pow2(float x)
{
	return x * x;
}

float2 Pow2(float2 x)
{
	return x * x;
}

float3 Pow2(float3 x)
{
	return x * x;
}

float4 Pow2(float4 x)
{
	return x * x;
}

float Pow3(float x)
{
	return x * x * x;
}

float2 Pow3(float2 x)
{
	return x * x * x;
}

float3 Pow3(float3 x)
{
	return x * x * x;
}

float4 Pow3(float4 x)
{
	return x * x * x;
}

float Pow4(float x)
{
	float xx = x * x;
	return xx * xx;
}

float2 Pow4(float2 x)
{
	float2 xx = x * x;
	return xx * xx;
}

float3 Pow4(float3 x)
{
	float3 xx = x * x;
	return xx * xx;
}

float4 Pow4(float4 x)
{
	float4 xx = x * x;
	return xx * xx;
}

float Pow5(float x)
{
	float xx = x * x;
	return xx * xx * x;
}

float2 Pow5(float2 x)
{
	float2 xx = x * x;
	return xx * xx * x;
}

float3 Pow5(float3 x)
{
	float3 xx = x * x;
	return xx * xx * x;
}

float4 Pow5(float4 x)
{
	float4 xx = x * x;
	return xx * xx * x;
}

float Pow6(float x)
{
	float xx = x * x;
	return xx * xx * xx;
}

float2 Pow6(float2 x)
{
	float2 xx = x * x;
	return xx * xx * xx;
}

float3 Pow6(float3 x)
{
	float3 xx = x * x;
	return xx * xx * xx;
}

float4 Pow6(float4 x)
{
	float4 xx = x * x;
	return xx * xx * xx;
}

float Pow10(float x)
{
    float xx = x * x;
    float xxxx = xx * xx;
    return xxxx * xxxx * xx;
}

float Luminance( float3 LinearColor )
{
	return dot( LinearColor, float3( 0.3, 0.59, 0.11 ) );
}

float FastExp(float x)
{
    return exp2(1.442695f * x);
}

float3 FastExp(float3 x)
{
    return exp2(1.442695f * x);
}

float4 FastExp(float4 x)
{
    return exp2(1.442695f * x);
}

float Convert_minus1to1_To_0to1(float x)
{
    return x * 0.5f + 0.5f;
}

float2 Convert_minus1to1_To_0to1(float2 x)
{
    return x * 0.5f + 0.5f;
}

float3 Convert_minus1to1_To_0to1(float3 x)
{
    return x * 0.5f + 0.5f;
}

float4 Convert_minus1to1_To_0to1(float4 x)
{
    return x * 0.5f + 0.5f;
}

float Convert_0to1_To_minus1to1(float x)
{
    return x * 2.0f - 1.0f;
}

float2 Convert_0to1_To_minus1to1(float2 x)
{
    return x * 2.0f - 1.0f;
}

float3 Convert_0to1_To_minus1to1(float3 x)
{
    return x * 2.0f - 1.0f;
}

float4 Convert_0to1_To_minus1to1(float4 x)
{
    return x * 2.0f - 1.0f;
}

float2 mins(float2 a, float2 b){
	return float2(min(a.x, b.x), min(a.y, b.y));
}

float2 maxs(float2 a, float2 b){
	return float2(max(a.x, b.x), max(a.y, b.y));
}

float3 mins(float3 a, float3 b){
	return float3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z));
}

float3 maxs(float3 a, float3 b){
	return float3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z));
}

float4 mins(float4 a, float4 b){
	return float4(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z), min(a.w, b.w));
}

float4 maxs(float4 a, float4 b){
	return float4(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z), max(a.w, b.w));
}

float3 GetPerpendicularVector(float3 u) 
{
    float3 a = abs(u);
    uint xm = ((a.x - a.y) < 0 && (a.x - a.z) < 0) ? 1 : 0;
    uint ym = (a.y - a.z) < 0 ? (1 ^ xm) : 0;
    uint zm = 1 ^ (xm | ym);
    return cross(u, float3(xm, ym, zm));
}

// high frequency dither pattern appearing almost random without banding steps
//note: from "NEXT GENERATION POST PROCESSING IN CALL OF DUTY: ADVANCED WARFARE"
//      http://advances.realtimerendering.com/s2014/index.html
// Epic extended by FrameId
// ~7 ALU operations (2 frac, 3 mad, 2 *)
// @return 0..1
float InterleavedGradientNoise(float2 uv, float FrameId)
{
    // magic values are found by experimentation
    uv += FrameId * (float2(47, 17) * 0.695f);

    const float3 magic = float3(0.06711056f, 0.00583715f, 52.9829189f);
    return frac(magic.z * frac(dot(uv, magic.xy)));
}

float3 DesaturateColor(float3 inColor, float fraction)
{
    float3 gray = dot(inColor, float3(0.3, 0.59, 0.11));
    return lerp(inColor, gray, fraction);
}

float3 GetLODVisualize(int LODIndex)
{
    float3 LODS[8] = {
        float3(1.0, 1.0, 1.0),
        float3(1.0, 0.0, 0.0), 
        float3(0.0, 1.0, 0.0), 
        float3(0.0, 0.0, 1.0), 
        float3(1.0, 1.0, 0.0),
        float3(1.0, 0.0, 1.0),
        float3(0.0, 1.0, 1.0),
        float3(0.5, 0.5, 0.5)
         };

         return LODS[LODIndex % 8];
}


// Shader Constant
#ifdef CROSS_NGI_D3D12 
#define SHADER_CONST(Type, Name, Value) Type Name
#else
#define SHADER_CONST(Type, Name, Value) [[vk::constant_id(__COUNTER__)]] const Type Name = Value;
#endif


#define DECLARE_UNIFORM(Type, Name) Type Name;

#endif
