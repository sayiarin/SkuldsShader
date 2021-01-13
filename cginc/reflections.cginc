#pragma once
float3 cubemapReflection(PIO process, v2f fragin, float3 color, float smooth, float ref)
{
	float3 reflectDir = reflect(process.viewDirection, process.worldNormal);
	Unity_GlossyEnvironmentData envData;
	envData.roughness = 1 - smooth;
	envData.reflUVW = normalize(reflectDir);

	float3 result = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
	float spec0interpolationStrength = unity_SpecCube0_BoxMin.w;

	UNITY_BRANCH
		if (spec0interpolationStrength < 0.999)
		{
			envData.reflUVW = BoxProjection(reflectDir, process.worldPosition,
				unity_SpecCube1_ProbePosition,
				unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
			result = lerp(Unity_GlossyEnvironment(
				UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0),
				unity_SpecCube1_HDR, envData
			), result, spec0interpolationStrength);
		}

	//apply the amount the reflective surface is allowed to affect:

	switch (_ReflectType) {
		default:
			case 0:
				result = lerp(color, result, ref);
				break;
			case 1:
				result = result * color * ref;
				break;
			case 2:
				result = color + ( result * ref );
				break;
	}
	return result;
}

float4 applyReflectionProbe(inout PIO process, inout v2f fragin, float4 col, float smooth, float ref) {
	if (ref > 0.0f) {
		col.rgb = cubemapReflection(process, fragin, col.rgb, smooth, ref);
	}
	return col;
}
