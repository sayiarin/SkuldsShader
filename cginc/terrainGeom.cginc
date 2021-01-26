#pragma once
#include "utils.rotate2.cginc"
void reformatVert(inout v2f vert) {
	vert.pos = UnityObjectToClipPos(vert.objectPosition);
	vert.normal = float4(0, 1, 0, 1);
#if defined(LIGHTMAP_ON)
	vert.lmuv=float2(0,0);
#endif
#if !defined(UNITY_PASS_SHADOWCASTER)
	#if !defined(SHADOWS_DEPTH)
		//TRANSFER_SHADOW(vert)
	#endif
#endif
}

void addTriangleAtVert(v2f vert, float4 center, inout TriangleStream<v2f> tristream,float o, float d) {
	v2f v1 = vert;
	v2f v2 = vert;
	v2f v3 = vert;

	float4 pos = lerp(center, vert.objectPosition, d);
	v1.objectPosition = pos;
	v2.objectPosition = pos;
	v3.objectPosition = pos;

	float pathTest = floor(1.0f - tex2Dlod(_FeatureTex, float4(vert.uv,0,0)).r + .5f);
	v1.detail = 1.0f;
	v2.detail = 1.0f;
	v3.detail = 1.0f;

	//just so we know what it spawned from and which one it is internally.
	v1.vid += .1f;
	v2.vid += .2f;
	v3.vid += .3f;

	v1.uv = float2(0, 0);
	v2.uv = float2(1, 0);
	v3.uv = float2(.5f, 1);

	v1.objectPosition.x -= 1.5f;
	v2.objectPosition.x += 1.5f;
	v3.objectPosition.y += .5f;
	v3.objectPosition.z += sin((_Time.y*.5f)+v3.objectPosition.z)*.2f;

	v1.objectPosition -= pos;
	v1.objectPosition.xz = rotate2(v1.objectPosition.xz, (vert.vid + o)*2);
	v1.objectPosition += pos;

	v2.objectPosition -= pos;
	v2.objectPosition.xz = rotate2(v2.objectPosition.xz, (vert.vid + o)*2);
	v2.objectPosition += pos;

	v1.objectPosition *= pathTest;
	v2.objectPosition *= pathTest;
	v3.objectPosition *= pathTest;

	reformatVert(v1);
	reformatVert(v2);
	reformatVert(v3);

	tristream.Append(v1);
	tristream.Append(v2);
	tristream.Append(v3);

	tristream.RestartStrip();
}

[maxvertexcount(33)]
void geom(triangle v2f input[3], inout TriangleStream<v2f> tristream) {
	for (int i = 0; i < 3; i++) {
		v2f vert = input[i];
		vert.detail = 0.0f;
		tristream.Append(vert);
	}
	float worldPosition = mul(unity_ObjectToWorld, input[0].objectPosition);
	float distance = length(worldPosition - _WorldSpaceCameraPos);
	if (_DetailLayer == 1 ) {
		tristream.RestartStrip();

		float4 center = input[0].objectPosition + input[1].objectPosition + input[2].objectPosition;
		center /= 3.0f;
		addTriangleAtVert(input[0], center, tristream, 0, 0);
		addTriangleAtVert(input[1], center, tristream, .4f, .1f);
		addTriangleAtVert(input[2], center, tristream, .8f, .3f);

		addTriangleAtVert(input[0], center, tristream, 1.0f, .5f);
		addTriangleAtVert(input[1], center, tristream, .6f, .7f);
		addTriangleAtVert(input[2], center, tristream, .8f, .2f);

		addTriangleAtVert(input[0], center, tristream, .3f, .8f);
		addTriangleAtVert(input[1], center, tristream, .2f, .7f);
		addTriangleAtVert(input[2], center, tristream, .1f, .9f);

		addTriangleAtVert(input[0], center, tristream, .9f, 1.0f);
	}
}