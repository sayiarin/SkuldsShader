#pragma once
float4 frag(PIO process, uint isFrontFace : SV_IsFrontFace) : SV_Target
{
	UNITY_SETUP_INSTANCE_ID(process);
	applyHeight(process);
	ApplyFeatureMap(process);
	//get the uv coordinates and set the base color.
	float4 color = tex2D(_MainTex, process.uv + process.uvOffset) * _Color;

	float4 nextCol = tex2D(_Tex1, process.uv + process.uvOffset);
	float test = saturate((process.worldPosition.y - _Height1) *_FadeRange);
	color = lerp(color, nextCol, test);

	nextCol = tex2D(_Tex2, process.uv + process.uvOffset);
	test = saturate((process.worldPosition.y - _Height2) * _FadeRange);
	color = lerp(color, nextCol, test);

	nextCol = tex2D(_Tex3, process.uv + process.uvOffset);
	test = saturate((process.worldPosition.y - _Height3) * _FadeRange);
	color = lerp(color, nextCol, test);

	float finalAlpha = color.a;
	color = HSV(color, _Hue, _Saturation, _Value);
	color = Contrast(color, _Contrast);
	//apply contrast

	if (_DetailLayer == 1) {
		//is it terrain or grass?
		float4 grassColor = tex2D(_DetailTex, process.detailUV + process.uvOffset) * _DetailColor;
		grassColor = HSV(grassColor, _DetailHue, _DetailSaturation, _DetailValue);
		test = saturate((process.worldPosition.y - _GrassHeight) *_FadeRange);
		grassColor.a = lerp(0, grassColor.a, test);
		color = lerp(color, grassColor, process.detail);
	}


	float4 baseColor = color; //for any alternative calculations.

	if (_NormalScale > 0) {
		applyNormalMap(process);
	}
	
	if (_RenderType == 2) {
		clip(color.a - _TCut);
	}

	process = adjustProcess(process, isFrontFace);

	#ifdef UNITY_PASS_FORWARDBASE

		color = applyFresnel(process, color);
		color = applySpecular(process, color);
		color = applyLight(process, color);
		color = applyReflectionProbe(color, process, _Smoothness, _Reflectiveness);
		
		color = saturate(color);
		color = applyGlow(process, color);
	#else

		color = applySpecular(process, color);
		color = applyLight(process, color);

		color = saturate(color);
		color = applyGlowForward(process, color);
	#endif

	
	if (_RenderType == 0) {
		color.a = 1;
	}
	else {
		color.a = finalAlpha;
	}

	return color;
}