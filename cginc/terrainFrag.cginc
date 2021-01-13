#pragma once
float4 frag(v2f fragin, uint isFrontFace : SV_IsFrontFace) : SV_Target
{
	PIO process = createProcess(fragin, isFrontFace);
	//get the uv coordinates and set the base color.
	float4 color = tex2D(_MainTex, fragin.uv + process.uvOffset) * _Color;


	float4 nextCol = tex2D(_Tex1, fragin.uv + process.uvOffset);
	float test = saturate((process.worldPosition.y - _Height1) *_FadeRange);
	color = lerp(color, nextCol, test);

	nextCol = tex2D(_Tex2, fragin.uv + process.uvOffset);
	test = saturate((process.worldPosition.y - _Height2) * _FadeRange);
	color = lerp(color, nextCol, test);

	nextCol = tex2D(_Tex3, fragin.uv + process.uvOffset);
	test = saturate((process.worldPosition.y - _Height3) * _FadeRange);
	color = lerp(color, nextCol, test);

	float finalAlpha = color.a;
	color = HSV(color, _Hue, _Saturation, _Value);
	color = Contrast(color, _Contrast);
	//apply contrast

	if (_DetailLayer == 1) {
		//is it terrain or grass?
		float4 grassColor = tex2D(_DetailTex, fragin.uv + process.uvOffset) * _DetailColor;
		grassColor = HSV(grassColor, _DetailHue, _DetailSaturation, _DetailValue);
		test = saturate((process.worldPosition.y - _GrassHeight) *_FadeRange);
		grassColor.a = lerp(0, grassColor.a, test);
		color = lerp(color, grassColor, fragin.detail);
	}

	if (_RenderType == 2) {
		clip(color.a - _TCut);
	}

	float4 baseColor = color; //for any alternative calculations.
	

	#ifdef UNITY_PASS_FORWARDBASE

		color = applyFresnel(process, fragin, color);
		color = applySpecular(process, fragin, color);
		color = applyLight(process, fragin, color);
		color = applyReflectionProbe(process, fragin, color, _Smoothness, _Reflectiveness);
		
		color = saturate(color);
		color = applyGlow(process, fragin, color);
	#else

		color = applySpecular(process, fragin, color);
		color = applyLight(process, fragin, color);

		color = saturate(color);
		color = applyGlowForward(process, fragin, color);
	#endif

	
	if (_RenderType == 0) {
		color.a = 1;
	}
	else {
		color.a = finalAlpha;
	}

	return color;
}