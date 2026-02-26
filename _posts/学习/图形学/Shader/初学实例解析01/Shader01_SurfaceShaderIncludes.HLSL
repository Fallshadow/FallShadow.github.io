#ifndef SURFACE_SHADER_INCLUDES
#define SURFACE_SHADER_INCLUDES

#define ENABLE_VIEW_MODE_VISUALIZE

#include "../../ShaderLibrary/Common.hlsl"
#if defined(PARTICLE) && PARTICLE == 1
#include "Common/ParticleSceneData.hlsl"
#else
#include "Common/SceneData.hlsl"
#endif
#include "../../ShaderLibrary/GlobalModelVariables.hlsl"
#include "../../Material/Lit/LitUEVariables.hlsl"

#if !defined(CE_INSTANCING) || (defined(VERTEX_TYPE) && VERTEX_TYPE == VertexType_Vegetation)
    #include "ShaderLibrary/Vertex.hlsl"
#else
    StructuredBuffer<ObjectSceneData> ce_PerObject : register(space2);
    #include "ShaderLibrary/Vertex_Instancing.hlsl"
#endif


#include "../../Material/Material.hlsl"
#include "../../Lighting/Lighting.hlsl"

#ifdef OPEN_VT
#include "../../Features/VirtualTexture/VirtualTextureCommon.hlsl"
#endif

#include "../../Material/Lit/LitCommonStruct.hlsl"

#endif