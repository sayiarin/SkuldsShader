PIO createProcess(inout v2f fragin, uint isFrontFace)
{
	UNITY_SETUP_INSTANCE_ID(fragin);
	PIO process;
	process.worldPosition = mul(unity_ObjectToWorld, fragin.objectPosition).xyz;
	process.worldNormal = normalize(UnityObjectToWorldNormal(fragin.normal));
	process.uvOffset = float2(0, 0);

	process.detailUV = TRANSFORM_TEX(fragin.uv, _DetailTex);
	process.normalUV = TRANSFORM_TEX(fragin.uv, _NormalTex);
	process.featureUV = TRANSFORM_TEX(fragin.uv, _FeatureTex);
	process.glowUV = TRANSFORM_TEX(fragin.uv, _GlowTex);
	process.worldTangent = float4(UnityObjectToWorldDir(fragin.tangent.xyz), fragin.tangent.w);
	process.binormal = CreateBinormal(process.worldNormal, process.worldTangent.xyz, process.worldTangent.w);

#if defined(TERRAIN)
	process.featureUV = fragin.uv;
	float2 ouv = TRANSFORM_TEX(fragin.uv, _MainTex);
	fragin.uv = lerp(ouv, fragin.uv, fragin.detail);
	
#else
	fragin.uv = TRANSFORM_TEX(fragin.uv, _MainTex); //must be done last.
#endif

	if (!isFrontFace) {
		fragin.normal = -fragin.normal;
		process.worldNormal = -process.worldNormal;
	}

	//get the camera position to calculate view direction and then get the direction from the camera to the pixel.
	//This needs to be done both in vertex and frag shaders.
	process.viewDirection = normalize(process.worldPosition - _WorldSpaceCameraPos.xyz);
	UNITY_LIGHT_ATTENUATION(attenuation, fragin, process.worldPosition);
	process.attenuation = attenuation;

	if (_NormalScale > 0) {
		applyNormalMap(process, fragin);
	}
	applyHeight(process, fragin);
#if !defined(TERRAIN)
	ApplyFeatureMap(process, fragin);
#endif

	return process;
}