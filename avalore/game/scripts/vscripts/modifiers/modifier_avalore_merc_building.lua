modifier_avalore_merc_building = class({})

function modifier_avalore_merc_building:IsHidden() return true end
function modifier_avalore_merc_building:IsPurgeable() return false end
function modifier_avalore_merc_building:IsDebuff() return false end

function modifier_avalore_merc_building:DeclareFunctions()
    return {    MODIFIER_PROPERTY_DISABLE_TURNING,
                MODIFIER_PROPERTY_IGNORE_CAST_ANGLE }
end

-- don't let the building rotate around to auto-attack
function modifier_avalore_merc_building:GetModifierDisableTurning()
	return 1
end

-- allow auto-attack to happen from any angle (so it doesn't have to be facing opponent)
function modifier_avalore_merc_building:GetModifierIgnoreCastAngle()
    return 1
end