ability_calmecac_patronage = ability_calmecac_patronage or class({})

LinkLuaModifier( "modifier_calmecac_patronage_aura", "scripts/vscripts/heroes/quetzalcoatl/modifier_calmecac_patronage_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_calmecac_patronage_aura_effect", "scripts/vscripts/heroes/quetzalcoatl/modifier_calmecac_patronage_aura_effect", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function ability_calmecac_patronage:GetIntrinsicModifierName()
	return "modifier_calmecac_patronage_aura"
end