item_leather_boots = class({})

LinkLuaModifier( "modifier_item_leather_boots", "items/shop/base_materials/item_leather_boots.lua", LUA_MODIFIER_MOTION_NONE )

function item_leather_boots:GetIntrinsicModifierName()
    return "modifier_item_leather_boots"
end

-- function item_leather_boots:CanBeUsedOutOfInventory()
--     if self:IsInBackpack() then
--         return true
--     end
--     return false
-- end

-- function item_leather_boots:OnEquip()
--     print("Leather Boots Equipped")
-- end

-- function item_leather_boots:OnUnequip()
--     print("Leather Boots Unequipped")
-- end
-- function item_leather_boots:IsInBackpack()
--     return false
-- end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_leather_boots = class({})

function modifier_item_leather_boots:IsHidden() return true end
function modifier_item_leather_boots:IsDebuff() return false end
function modifier_item_leather_boots:IsPurgable() return false end
function modifier_item_leather_boots:RemoveOnDeath() return false end
function modifier_item_leather_boots:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_leather_boots:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_leather_boots:OnCreated(event)
    self.item_ability = self:GetAbility()
    print(self:GetAbility():GetName())
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_leather_boots:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_item_leather_boots:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end