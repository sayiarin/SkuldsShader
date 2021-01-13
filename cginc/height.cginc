#pragma once
float GetParallaxHeight(float2 uv) {
	return tex2D(_FeatureTex, uv).a * _Height;
}

void applyHeight(inout PIO process, inout v2f fragin) {
	float2 uvOffset = 0;
	float2 uvDelta = -process.viewDirection * .001;

	float stepHeight = 1;
	float surfaceHeight = 1 - GetParallaxHeight(process.featureUV);

	for ( int i = 1; i < 10 && stepHeight > surfaceHeight; i++ ) {
		uvOffset -= uvDelta;
		stepHeight -= .001;
		surfaceHeight = 1- GetParallaxHeight(process.featureUV + uvOffset);
	}
	process.uvOffset = uvOffset;
}