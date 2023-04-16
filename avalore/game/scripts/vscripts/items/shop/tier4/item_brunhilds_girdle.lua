item_brunhilds_girdle = class({})

LinkLuaModifier( "modifier_item_brunhilds_girdle", "items/shop/tier4/item_brunhilds_girdle.lua", LUA_MODIFIER_MOTION_NONE )

function item_brunhilds_girdle:GetIntrinsicModifierName()
    return "modifier_item_brunhilds_girdle"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_brunhilds_girdle = modifier_item_brunhilds_girdle or class({})

function modifier_item_brunhilds_girdle:IsHidden() return true end
function modifier_item_brunhilds_girdle:IsDebuff() return false end
function modifier_item_brunhilds_girdle:IsPurgable() return false end
function modifier_item_brunhilds_girdle:RemoveOnDeath() return false end

function modifier_item_brunhilds_girdle:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_item_brunhilds_girdle:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
end

function modifier_item_brunhilds_girdle:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_brunhilds_girdle:GetModifierBonusStats_Agility()
    return self.bonus_agi
end