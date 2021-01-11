#pragma once
#include "utils.rotate2.cginc"
void reformatVert(inout PIO vert) {
	vert.pos = UnityObjectToClipPos(vert.objectPosition);
	vert.worldPosition = mul(unity_ObjectToWorld, vert.objectPosition).xyz;
	vert.attenuation = 0;
	vert.normal = float4(0, 1, 0, 1);
	vert.worldNormal = normalize(UnityObjectToWorldNormal(vert.normal));
#if defined(LIGHTMAP_ON)
	vert.lmuv=float2(0,0);
#endif
}

void addTriangleAtVert(PIO vert, float4 center, inout TriangleStream<PIO> tristream,float o, float d) {
	PIO v1 = vert;
	PIO v2 = vert;
	PIO v3 = vert;

	float4 pos = lerp(center, vert.objectPosition, d);
	v1.objectPosition = pos;
	v2.objectPosition = pos;
	v3.objectPosition = pos;

	v1.detail = 1.0f;
	v2.detail = 1.0f;
	v3.detail = 1.0f;

	//just so we know what it spawned from and which one it is internally.
	v1.vid += .1f;
	v2.vid += .2f;
	v3.vid += .3f;

	v1.detailUV = float2(0, 0);
	v2.detailUV = float2(1, 0);
	v3.detailUV = float2(.5f, 1);

	v1.objectPosition.x -= 1.5f;
	v2.objectPosition.x += 1.5f;
	v3.objectPosition.y += .5f;

	v1.objectPosition -= pos;
	v1.objectPosition.xz = rotate2(v1.objectPosition.xz, (vert.vid + o)*2);
	v1.objectPosition += pos;

	v2.objectPosition -= pos;
	v2.objectPosition.xz = rotate2(v2.objectPosition.xz, (vert.vid + o)*2);
	v2.objectPosition += pos;

	reformatVert(v1);
	reformatVert(v2);
	reformatVert(v3);

	tristream.Append(v1);
	tristream.Append(v2);
	tristream.Append(v3);

	tristream.RestartStrip();
}

[maxvertexcount(18)]
void geom(triangle PIO input[3], inout TriangleStream<PIO> tristream) {
	for (int i = 0; i < 3; i++) {
		PIO vert = input[i];
		vert.detail = 0.0f;
		tristream.Append(vert);
	}
	if (_DetailLayer == 1) {
		tristream.RestartStrip();

		float4 center = input[0].objectPosition + input[1].objectPosition + input[2].objectPosition;
		center /= 3.0f;
		addTriangleAtVert(input[0], center, tristream, 0, 0);
		addTriangleAtVert(input[1], center, tristream, .4f, .1f);
		addTriangleAtVert(input[2], center, tristream, .8f, .3f);

		addTriangleAtVert(input[0], center, tristream, 1.0f, .5f);
		addTriangleAtVert(input[1], center, tristream, .6f, .7f);
	}
}