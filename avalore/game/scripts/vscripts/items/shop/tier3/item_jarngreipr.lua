item_jarngreipr = class({})

LinkLuaModifier( "modifier_item_jarngreipr", "items/shop/base_materials/item_jarngreipr.lua", LUA_MODIFIER_MOTION_NONE )

function item_jarngreipr:GetIntrinsicModifierName()
    return "modifier_item_jarngreipr"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_jarngreipr = modifier_item_jarngreipr or class({})

function modifier_item_jarngreipr:IsHidden() return true end
function modifier_item_jarngreipr:IsDebuff() return false end
function modifier_item_jarngreipr:IsPurgable() return false end
function modifier_item_jarngreipr:RemoveOnDeath() return false end
function modifier_item_jarngreipr:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_jarngreipr:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_STATS_STRENGTH_BONUS      }
end

function modifier_item_jarngreipr:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
end

function modifier_item_jarngreipr:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_jarngreipr:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_jarngreipr:GetModifierBonusStats_Strength()
    return self.bonus_str
end