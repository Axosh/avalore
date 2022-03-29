modifier_avalore_disarmed = class({})

function modifier_avalore_disarmed:IsHidden() return false end
function modifier_avalore_disarmed:IsDebuff() return true end
function modifier_avalore_disarmed:IsPurgeable() return true end

function modifier_avalore_disarmed:GetTexture()
    return "generic/disarm"
end

function modifier_avalore_disarmed:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_avalore_disarmed:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end