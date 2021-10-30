modifier_shapeshift_eagle = class({})

function modifier_shapeshift_eagle:IsAura() return true end
function modifier_shapeshift_eagle:IsHidden() return false end
function modifier_shapeshift_eagle:IsPurgable() return false end

function modifier_shapeshift_eagle:GetTexture()
    return "zeus/modifier_shapeshift_eagle"
end

function modifier_shapeshift_eagle:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MODEL_CHANGE,
                MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
                MODIFIER_PROPERTY_BONUS_DAY_VISION,
                MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
                MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS        }
end

function modifier_shapeshift_eagle:CheckState()
	return {    [MODIFIER_STATE_FLYING] = true  }
end

function modifier_shapeshift_eagle:GetModifierModelChange()
	return "models/items/beastmaster/hawk/fotw_eagle/fotw_eagle.vmdl"
end

function modifier_shapeshift_eagle:OnCreated()
    self.movespeed = self:GetAbility():GetSpecialValueFor("speed_self")
    self.vision = self:GetAbility():GetSpecialValueFor("vision")
end

function modifier_shapeshift_eagle:GetModifierMoveSpeed_AbsoluteMin()
    return self.movespeed
end

function modifier_shapeshift_eagle:GetBonusDayVision()
    return self.vision
end

function modifier_shapeshift_eagle:GetBonusNightVision()
    return self.vision
end

function modifier_shapeshift_eagle:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Beastmaster.Call.Hawk")
    local particle_revert = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"
    local particle_revert_fx = ParticleManager:CreateParticle(particle_revert, PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_revert_fx, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_revert_fx, 3, self:GetCaster():GetAbsOrigin())
end

function modifier_shapeshift_eagle:GetActivityTranslationModifiers()
	return "hunter_night"
end