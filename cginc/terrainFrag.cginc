#pragma once
float4 frag(PIO process, uint isFrontFace : SV_IsFrontFace) : SV_Target
{
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

	float4 baseColor = color; //for any alternative calculations.

	if (_NormalScale > 0) {
		applyNormalMap(process);
	}
	
	if (_RenderType == 2) {
		clip(color.a - _TCut);
	}

	process = adjustProcess(process, isFrontFace);

	#ifdef UNITY_PASS_FORWARDBASE
		color = applyDetailLayer(process, color, 1-_DetailUnlit);

		color = applyFresnel(process, color);
		color = applySpecular(process, color);
		color = applyLight(process, color);
		color = applyReflectionProbe(color, process, _Smoothness, _Reflectiveness);

		color = applyDetailLayer(process, color, _DetailUnlit);
		
		#if defined(LFRT)
			baseColor = applyDetailLayer(process, baseColor, 1 - _DetailUnlit);
			baseColor = applySpecular(process, baseColor);
			baseColor = applyReflectionProbe(baseColor, process, _Smoothness, _Reflectiveness);
			//just gets added like a foward add light.
			color = applyLFRTColor(process, color, baseColor);
		#endif
		color = saturate(color);
		color = applyGlow(process, color);
	#else
		color = applyDetailLayer(process, color, 1 - _DetailUnlit);

		color = applySpecular(process, color);
		color = applyLight(process, color);

		//I'm still not quiet sure what would be the correct way to handle reflections with Forward add. For now, ommitting.
		//color = applyReflectionProbe(color, process, _Smoothness, _Reflectiveness);
		//color = lerp(color, 0, _Reflectiveness);

		color = applyDetailLayerForward(process, color, _DetailUnlit);
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