item_helskor = class({})

LinkLuaModifier( "modifier_avalore_ghost", "scripts/vscripts/modifiers/base_spell/modifier_avalore_ghost.lua", LUA_MODIFIER_MOTION_NONE )

function item_helskor:GetIntrinsicModifierName()
    return "modifier_item_helskor"
end

function item_helskor:OnSpellStart()
    local caster = self:GetCaster()
	local ability = self
	local sound_cast = "DOTA_Item.PhaseBoots.Activate"
    local phase_duration = ability:GetSpecialValueFor("phase_duration")
    
    EmitSoundOn(sound_cast, caster)
    caster:AddNewModifier(caster, ability, "modifier_avalore_ghost", {duration = phase_duration})
end