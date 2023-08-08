item_guandao = class({})

LinkLuaModifier( "modifier_item_guandao", "items/shop/tier1/item_guandao.lua", LUA_MODIFIER_MOTION_NONE )

function item_guandao:GetIntrinsicModifierName()
    return "modifier_item_guandao"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_guandao = modifier_item_guandao or class({})

function modifier_item_guandao:IsHidden() return true end
function modifier_item_guandao:IsDebuff() return false end
function modifier_item_guandao:IsPurgable() return false end
function modifier_item_guandao:RemoveOnDeath() return false end

function modifier_item_guandao:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
                MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end

function modifier_item_guandao:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.damage_block = self.item_ability:GetSpecialValueFor("damage_block")
    self.bonus_range = self.item_ability:GetSpecialValueFor("bonus_range")
end

function modifier_item_guandao:GetModifierPhysical_ConstantBlock()
	return self.damage_block
end

function modifier_item_guandao:GetModifierAttackRangeBonus()
    if not self:GetParent():IsRangedAttacker() then
        return self.bonus_range
    end
end