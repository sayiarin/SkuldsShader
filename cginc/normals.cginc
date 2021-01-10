#pragma once
//Normals
float _NormalScale;

float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) *
		(binormalSign * unity_WorldTransformParams.w);
}

void applyNormalMap(inout PIO o) {
	float3 binormal;
#if defined(TERRAIN)
	float4 color = tex2D(_NormalTex, o.normalUV + o.uvOffset);

	float4 nextCol = tex2D(_Normal1, o.uv + o.uvOffset);
	float test = saturate((o.worldPosition.y - _Height1) *_FadeRange);
	color = lerp(color, nextCol, test);

	nextCol = tex2D(_Normal2, o.uv + o.uvOffset);
	test = saturate((o.worldPosition.y - _Height2) * _FadeRange);
	color = lerp(color, nextCol, test);

	nextCol = tex2D(_Normal3, o.uv + o.uvOffset);
	test = saturate((o.worldPosition.y - _Height3) * _FadeRange);
	color = lerp(color, nextCol, test);

	float3 tangentSpaceNormal = UnpackScaleNormal(color, _NormalScale);
#else
	float3 tangentSpaceNormal = UnpackScaleNormal(tex2D(_NormalTex, o.normalUV + o.uvOffset), _NormalScale);
#endif
	binormal = CreateBinormal(o.worldNormal, o.worldTangent.xyz, o.worldTangent.w);

	o.worldNormal = normalize(
		tangentSpaceNormal.x * o.worldTangent +
		tangentSpaceNormal.y * binormal +
		tangentSpaceNormal.z * o.worldNormal
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
