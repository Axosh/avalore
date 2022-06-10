modifier_avalore_track_location = class({})

-- gives vision of target's location (like Bloodseeker's Thirst)

function modifier_avalore_track_location:IsPurgeable()      return false end
function modifier_avalore_track_location:RemoveOnDeath()    return true  end
function modifier_avalore_track_location:IsDebuff()         return true  end

function modifier_avalore_track_location:GetTexture()
    return "generic/track"
end

function modifier_avalore_track_location:GetEffectName()
    --return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield_bullseye.vpcf"
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_vision.vpcf"
end

function modifier_avalore_track_location:GetStatusEffectName()
    --return "particles/econ/items/spectre/spectre_transversant_soul/spectre_ti7_crimson_spectral_dagger_path_owner.vpcf"
    --return "particles/econ/items/dazzle/dazzle_ti6/dazzle_ti6_shallow_grave_ground_steam.vpcf"
    --return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield_bullseye.vpcf"
	return "particles/status_fx/status_effect_thirst_vision.vpcf"
    --return "particles/status_fx/status_effect_sylph_wisp_fear.vpcf"
end

function modifier_avalore_track_location:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

-- function modifier_avalore_track_location:OnCreated(kv)
-- end

function modifier_avalore_track_location:CheckState()
    return  {
                [MODIFIER_STATE_INVISIBLE] = false
            }
end

function modifier_avalore_track_location:DeclareFunctions()
	return  {
                MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
            }
end

function modifier_avalore_track_location:GetModifierProvidesFOWVision()
	return 1
end