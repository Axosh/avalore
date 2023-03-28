item_lesser_agility = class({})

LinkLuaModifier( "modifier_item_basic_stats", "items/shop/components/item_basic_stats.lua", LUA_MODIFIER_MOTION_NONE )

function item_basic_stats:GetIntrinsicModifierName()
    return "modifier_item_basic_stats"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_basic_stats = modifier_item_basic_stats or class({})

function modifier_item_basic_stats:IsHidden() return true end
function modifier_item_basic_stats:IsDebuff() return false end
function modifier_item_basic_stats:IsPurgable() return false end
function modifier_item_basic_stats:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_basic_stats:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_basic_stats:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_item_basic_stats:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self:SetStackCount( 1 )
end

function modifier_item_basic_stats:GetModifierBonusStats_Agility()
    return self.bonus_agi * self:GetStackCount()
end