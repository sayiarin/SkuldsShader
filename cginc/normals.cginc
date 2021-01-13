#pragma once
//Normals
float _NormalScale;

//called from adjust process.
float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) *
		(binormalSign * unity_WorldTransformParams.w);
}

void applyNormalMap(inout PIO process, inout v2f fragin) {
	float3 binormal;
#if defined(TERRAIN)
	float4 color = tex2D(_NormalTex, process.normalUV + process.uvOffset);

	float4 nextCol = tex2D(_Normal1, fragin.uv + process.uvOffset);
	float test = saturate((process.worldPosition.y - _Height1) *_FadeRange);
	color = lerp(color, nextCol, test);

	nextCol = tex2D(_Normal2, fragin.uv + process.uvOffset);
	test = saturate((process.worldPosition.y - _Height2) * _FadeRange);
	color = lerp(color, nextCol, test);

	nextCol = tex2D(_Normal3, fragin.uv + process.uvOffset);
	test = saturate((process.worldPosition.y - _Height3) * _FadeRange);
	color = lerp(color, nextCol, test);

	float3 tangentSpaceNormal = UnpackScaleNormal(color, _NormalScale);
#else
	float3 tangentSpaceNormal = UnpackScaleNormal(tex2D(_NormalTex, process.normalUV + process.uvOffset), _NormalScale);
#endif

	process.worldNormal = normalize(
		tangentSpaceNormal.x * process.worldTangent +
		tangentSpaceNormal.y * process.binormal +
		tangentSpaceNormal.z * process.worldNormal
	);
}

float3 BoxProjection(
	float3 direction, float3 position,
	float4 cubemapPosition, float3 boxMin, float3 boxMax
) {

	if (cubemapPosition.w > 0) {
		float3 factors =
			((direction > 0 ? boxMax : boxMin) - position) / direction;
		float scalar = min(min(factors.x, factors.y), factors.z);
		direction = direction * scalar + (position - cubemapPosition);
	}

	return direction;
}
