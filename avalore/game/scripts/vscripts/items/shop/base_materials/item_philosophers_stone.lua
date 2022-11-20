item_philosophers_stone = class({})

LinkLuaModifier( "modifier_item_philosophers_stone", "items/shop/base_materials/item_philosophers_stone.lua", LUA_MODIFIER_MOTION_NONE )

function item_philosophers_stone:GetIntrinsicModifierName()
    return "modifier_item_philosophers_stone"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_philosophers_stone = modifier_item_philosophers_stone or class({})

function modifier_item_philosophers_stone:IsHidden()      return true  end
function modifier_item_philosophers_stone:IsDebuff()      return false end
function modifier_item_philosophers_stone:IsPurgable()    return false end
function modifier_item_philosophers_stone:RemoveOnDeath() return false end

function modifier_item_philosophers_stone:DeclareFunctions()
    return { MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_item_philosophers_stone:OnCreated(kv)
    self.item_ability       = self:GetAbility()
    self.gold_per_min       = self.item_ability:GetSpecialValueFor("gold_per_min")
    self.gold_per_tick      = self.gold_per_min / 60

    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_item_philosophers_stone:OnTooltip()
    return self.gold_per_min
end

function modifier_item_philosophers_stone:OnIntervalThink()
    if not IsServer() then return end

    self:GetParent():ModifyGold(self.gold_per_tick, false, DOTA_ModifyGold_AbilityGold)
end