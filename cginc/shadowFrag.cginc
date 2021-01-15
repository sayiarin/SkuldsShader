#pragma once
fixed4 frag(v2f fragin, uint isFrontFace : SV_IsFrontFace) : SV_Target
{
	PIO process = createProcess(fragin, isFrontFace);
	float4 color = tex2D(_MainTex, fragin.uv + process.uvOffset) * _Color;
	if (_RenderType == 2) {
		clip(color.a - _TCut);
	}
	SHADOW_CASTER_FRAGMENT(fragin)
}

#if defined(TERRAIN)
fixed4 terrainFrag(v2f fragin, uint isFrontFace : SV_IsFrontFace) : SV_Target
{
	PIO process = createProcess(fragin, isFrontFace);
	float4 baseColor = tex2D(_DetailTex, fragin.uv + process.uvOffset) * _Color;
	float4 detailColor = tex2D(_MainTex, fragin.uv + process.uvOffset) * _Color;
	float4 color = lerp(baseColor, detailColor, fragin.detail);
	if (_RenderType == 2) {
		clip( color.a - _TCut );
	}
	SHADOW_CASTER_FRAGMENT(fragin)
}
#endif