item_adventurers_cloak = class({})

LinkLuaModifier( "modifier_item_adventurers_cloak", "items/shop/base_materials/item_adventurers_cloak.lua", LUA_MODIFIER_MOTION_NONE )

function item_adventurers_cloak:GetIntrinsicModifierName()
    return "modifier_item_adventurers_cloak"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_adventurers_cloak = class({})

function modifier_item_adventurers_cloak:IsHidden() return true end
function modifier_item_adventurers_cloak:IsDebuff() return false end
function modifier_item_adventurers_cloak:IsPurgable() return false end
function modifier_item_adventurers_cloak:RemoveOnDeath() return false end
function modifier_item_adventurers_cloak:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_adventurers_cloak:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_adventurers_cloak:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_adventurers_cloak:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_adventurers_cloak:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_adventurers_cloak:GetModifierBonusStats_Intellect()
    return self.bonus_int
end


function modifier_item_adventurers_cloak:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end