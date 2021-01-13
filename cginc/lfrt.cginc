#pragma once
sampler2D _ETex;
float4 _ETex_ST;
float4 _EPosition;
float _ERange;
float _EBrightness;
float4 _ESamples;

float4 applyLFRTColor(PIO process, v2f fragin, float4 color, float4 baseColor ) {
	float xstep = 1.0f / _ESamples.x;
	float ystep = 1.0f / _ESamples.y;
	float xstart = xstep / 2;
	float ystart = ystep / 2;

	float3 ecol = float3(0, 0, 0);
	for (float x = xstart; x < 1.0f; x += xstep) {
		float3 pcol = float3(0, 0, 0);
		for (float y = ystart; y < 1.0f; y += ystep) {
			pcol += tex2D(_ETex, float2(x, y)).rgb;
		}
		ecol += pcol / _ESamples.y;
	}
	ecol /= _ESamples.x;
	ecol *= baseColor;

	float4 edir = float4(_EPosition.xyz - process.worldPosition, 1);
	float b = dot(process.worldNormal, edir);
	b /= 2.0f;
	b += .5f;
	b = ApplyProceduralToonRamp(b);

	float l = length(process.worldPosition - _EPosition) / 100.0f;
	float r = _ERange / 100.0f;
	float a = saturate((r - l) / r);
	a *= a;
	a *= _EBrightness;

	ecol *= b;
	ecol *= a;//attenuation
	ecol = max(0, ecol);

	color.rgb += ecol;

	return color;
}