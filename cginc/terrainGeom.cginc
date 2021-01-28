#pragma once
#include "utils.rotate2.cginc"
void addTriangleAtVert(v2f v, float4 center, inout TriangleStream<v2f> tristream,float o, float d) {
	IO v1;
	IO v2;
	IO v3;

	/*
	IO vertTest;
	vertTest.vertex = v.objectPosition;
	vertTest.normal = v.normal;
	vertTest.uv = float2(0, 0);
	vertTest.id = v.vid;
	vertTest.tangent = v.tangent;
	v2f vertTestB = vert(vertTest);
	*/

	v1.normal = float3(0, 1, 0);
	v2.normal = float3(0, 1, 0);
	v3.normal = float3(0, 1, 0);

	v1.tangent = v.tangent;
	v2.tangent = v.tangent;
	v3.tangent = v.tangent;

#if defined(LIGHTMAP_ON)
	v1.lmuv = v.lmuv;
	v2.lmuv = v.lmuv;
	v3.lmuv = v.lmuv;
#endif

	float4 pos = lerp(center, v.objectPosition, d);
	v1.vertex = pos;
	v2.vertex = pos;
	v3.vertex = pos;

	float pathTest = floor(1.0f - tex2Dlod(_FeatureTex, float4(v.uv,0,0)).r + .5f);

	//just so we know what it spawned from and which one it is internally.
	v1.id = v.vid + .1f;
	v2.id = v.vid + .2f;
	v3.id = v.vid + .3f;

	v1.uv = float2(0, 0);
	v2.uv = float2(1, 0);
	v3.uv = float2(.5f, 1);

	v1.vertex.x -= 1.5f;
	v2.vertex.x += 1.5f;
	v3.vertex.y += .5f;
	v3.vertex.z += sin((_Time.y*.5f)+v3.vertex.z)*.2f;

	v1.vertex -= pos;
	v1.vertex.xz = rotate2(v1.vertex.xz, (v.vid + o)*2);
	v1.vertex += pos;

	v2.vertex -= pos;
	v2.vertex.xz = rotate2(v2.vertex.xz, (v.vid + o)*2);
	v2.vertex += pos;

	v1.vertex *= pathTest;
	v2.vertex *= pathTest;
	v3.vertex *= pathTest;

	//just reprocess the fricken vert as if passed in from CPU.
	v2f v1frag = vert(v1);
	v2f v2frag = vert(v2);
	v2f v3frag = vert(v3);

	v1frag.instanceID = v1.id;
	v2frag.instanceID = v2.id;
	v3frag.instanceID = v3.id;

	v1frag.detail = 1.0f;
	v2frag.detail = 1.0f;
	v3frag.detail = 1.0f;

	tristream.Append(v1frag);
	tristream.Append(v2frag);
	tristream.Append(v3frag);

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