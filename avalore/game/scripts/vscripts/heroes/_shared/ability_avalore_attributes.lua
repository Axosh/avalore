ability_avalore_attributes = ability_avalore_attributes or class({})

function ability_avalore_attributes:GetIntrinsicModifierName()
    return "modifier_avalore_attributes"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_avalore_attributes = class({})

function modifier_avalore_attributes:IsHidden() return true end
function modifier_avalore_attributes:IsDebuff() return false end
function modifier_avalore_attributes:IsPurgable() return false end
function modifier_avalore_attributes:RemoveOnDeath() return false end
function modifier_avalore_attributes:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_avalore_attributes:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end