item_mantle_of_invisiibility = class({})

LinkLuaModifier( "modifier_item_mantle_of_invisiibility", "items/shop/tier3/item_mantle_of_invisiibility.lua", LUA_MODIFIER_MOTION_NONE )

function item_mantle_of_invisiibility:GetIntrinsicModifierName()
    return "modifier_item_mantle_of_invisiibility"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_mantle_of_invisiibility = class({})

function modifier_item_mantle_of_invisiibility:IsHidden() return true end
function modifier_item_mantle_of_invisiibility:IsDebuff() return false end
function modifier_item_mantle_of_invisiibility:IsPurgable() return false end
function modifier_item_mantle_of_invisiibility:RemoveOnDeath() return false end
function modifier_item_mantle_of_invisiibility:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mantle_of_invisiibility:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT      }
end

function modifier_item_mantle_of_invisiibility:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_mantle_of_invisiibility:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_mantle_of_invisiibility:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_mantle_of_invisiibility:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_mantle_of_invisiibility:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_mantle_of_invisiibility:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_mantle_of_invisiibility:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end
