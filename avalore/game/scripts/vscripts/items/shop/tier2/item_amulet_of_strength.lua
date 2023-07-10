item_amulet_of_strength = class({})

LinkLuaModifier( "modifier_item_amulet_of_strength", "items/shop/tier2/item_amulet_of_strength.lua", LUA_MODIFIER_MOTION_NONE )

function item_amulet_of_strength:GetIntrinsicModifierName()
    return "modifier_item_amulet_of_strength"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_amulet_of_strength = modifier_item_amulet_of_strength or class({})

function modifier_item_amulet_of_strength:IsHidden() return true end
function modifier_item_amulet_of_strength:IsDebuff() return false end
function modifier_item_amulet_of_strength:IsPurgable() return false end
function modifier_item_amulet_of_strength:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_amulet_of_strength:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_amulet_of_strength:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE   }
end

function modifier_item_amulet_of_strength:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_hp_regen_pct = self.item_ability:GetSpecialValueFor("bonus_hp_regen_pct")
end

function modifier_item_amulet_of_strength:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_amulet_of_strength:GetModifierHealthRegenPercentage()
    return self.bonus_hp_regen_pct
end
