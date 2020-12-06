#pragma once
float4 frag(PIO process, uint isFrontFace : SV_IsFrontFace) : SV_Target
{
	applyHeight(process);
	ApplyFeatureMap(process);
	//get the uv coordinates and set the base color.
	float4 color = tex2D(_MainTex, process.uv + process.uvOffset) * _Color;
	float finalAlpha = color.a;
	color = HSV(color, _Hue, _Saturation, _Value);

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
		//Should not be added to FowardAdd.	
		//color = applyReflectionProbe(color, process, _Smoothness, _Reflectiveness);
		//Do this:
		color = lerp(color, 0, _Reflectiveness);

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