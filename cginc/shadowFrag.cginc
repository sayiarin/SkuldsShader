#pragma once
fixed4 frag( v2f fragin, uint isFrontFace : SV_IsFrontFace ) : SV_Target
{
	SHADOW_CASTER_FRAGMENT(fragin)
}