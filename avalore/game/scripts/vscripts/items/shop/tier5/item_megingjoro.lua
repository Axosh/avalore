item_megingjoro = class({})

LinkLuaModifier( "modifier_item_megingjoro", "items/shop/tier5/item_megingjoro.lua", LUA_MODIFIER_MOTION_NONE )

function item_megingjoro:GetIntrinsicModifierName()
    return "modifier_item_megingjoro"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_megingjoro = modifier_item_megingjoro or class({})

function modifier_item_megingjoro:IsHidden() return true end
function modifier_item_megingjoro:IsDebuff() return false end
function modifier_item_megingjoro:IsPurgable() return false end
function modifier_item_megingjoro:RemoveOnDeath() return false end

function modifier_item_megingjoro:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
                --MODIFIER_PROPERTY_STATS_STRENGTH_BONUS_PERCENTAGE }
end

function modifier_item_megingjoro:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_str_mult = self.item_ability:GetSpecialValueFor("bonus_str_mult")
end

function modifier_item_megingjoro:GetModifierBonusStats_Strength()
    return self.bonus_str + (self:GetParent():GetBaseStrength() * (self.bonus_str_mult - 1))
end

function modifier_item_megingjoro:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

-- function modifier_item_megingjoro:GetModifierBonusStats_Strength_Percentage()
--     return self.bonus_str_mult
-- end