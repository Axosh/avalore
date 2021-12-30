modifier_72_bian_bird = class({})

function modifier_72_bian_bird:IsAura() return true end
function modifier_72_bian_bird:IsHidden() return false end
function modifier_72_bian_bird:IsPurgable() return false end

function modifier_72_bian_bird:GetTexture()
    return "sun_wukong/bird_form"
end

function modifier_72_bian_bird:OnCreated()
    if not IsServer() then return end
    self:GetParent():GetAbilityByName("ability_ruyi_jingu_bang"):SetHidden(true)
end


function modifier_72_bian_bird:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MODEL_CHANGE,
                MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
            }
end

function modifier_72_bian_bird:CheckState()
	return {    [MODIFIER_STATE_FLYING] = true,
                --[MODIFIER_STATE_FORCED_FLYING_VISION] = true,
                [MODIFIER_STATE_DISARMED] = true,
                [MODIFIER_STATE_MUTED] = true
            }
end

function modifier_72_bian_bird:GetModifierModelChange()
	return "models/heroes/beastmaster/beastmaster_bird.vmdl"
end

function modifier_72_bian_bird:GetActivityTranslationModifiers()
	return "hunter_night"
end

function modifier_72_bian_bird:OnDestroy()
    if not IsServer() then return end
    self:GetParent():GetAbilityByName("ability_ruyi_jingu_bang"):SetHidden(false)
end