modifier_avalore_flying = class({})

function modifier_avalore_flying:IsHidden() return true end
function modifier_avalore_flying:IsPurgeable() return false end
function modifier_avalore_flying:IsDebuff() return false end

function modifier_avalore_flying:DeclareFunctions()
    return { MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS }
end

function modifier_avalore_flying:CheckState()
    return { [MODIFIER_STATE_FLYING] = true }
end

function modifier_avalore_flying:GetActivityTranslationModifiers()
	return "hunter_night"
end