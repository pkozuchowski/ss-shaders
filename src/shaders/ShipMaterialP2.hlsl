#define EFFECT_MAX_LIGHT_COUNT 8

sampler2D ColoredTextureSampler : register(s0);
sampler2D NormalMapSampler : register(s1);
sampler2D EnvMapSampler : register(s2);

float3 LightPositions[EFFECT_MAX_LIGHT_COUNT];
float LightAtts[EFFECT_MAX_LIGHT_COUNT];
float3 LightColors[EFFECT_MAX_LIGHT_COUNT];
float3 SpecularColors[EFFECT_MAX_LIGHT_COUNT];
float3 AmbientColor;
float4 DiffuseTint;
float SpecularExponent, LCount, DoSphereMapping;
bool UseNormalMap;

static const float3 lDir = float3(0,0,1);


float4 pixelMain
(
   float2 TexCoords        : TEXCOORD0,
   float3 View             : TEXCOORD1,
   float3 Normal           : TEXCOORD2,
   float3 Tangent          : TEXCOORD3,
   float3 Binormal         : TEXCOORD4,
   float3 WPos             : TEXCOORD5,
   float4 Misc		 		: TEXCOORD6,
   float4 Misc2	 			: TEXCOORD7
) 
   : COLOR0
{
	if (UseNormalMap) {
		float4 sample = tex2D(NormalMapSampler, TexCoords);
		float3 peturbation = sample.xyz - float3(0.5, 0.5, 0.5);

		Normal = float3(
			peturbation.x * Tangent - 
			peturbation.y * Binormal + 
			peturbation.z * Normal);
	}
	/* Interpolated vertex normals might not be normalized. */
	Normal = normalize(Normal);
		
	float4 albedoColor = tex2D(ColoredTextureSampler, TexCoords) * DiffuseTint;

	if(DoSphereMapping > 0.5)	{
		float2 refCoords = reflect(View, Normal).xy * 0.5;
		albedoColor = lerp(albedoColor, tex2D(EnvMapSampler, refCoords), 0.5);
	}	


	float diffuse = clamp(dot(Normal, lDir), 0.25, 1);
	float3 finalLightColor = diffuse + (AmbientColor / 4);

	float4 finalColor = saturate(albedoColor * float4(finalLightColor.xyz, 1.0));
	finalColor.a = saturate(DiffuseTint.a);

	return finalColor;
}