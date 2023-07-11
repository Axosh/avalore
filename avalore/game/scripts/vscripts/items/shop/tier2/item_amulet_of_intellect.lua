item_amulet_of_intellect = class({})

LinkLuaModifier( "modifier_item_amulet_of_intellect", "items/shop/tier2/item_amulet_of_intellect.lua", LUA_MODIFIER_MOTION_NONE )

function item_amulet_of_intellect:GetIntrinsicModifierName()
    return "modifier_item_amulet_of_intellect"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_amulet_of_intellect = modifier_item_amulet_of_intellect or class({})

function modifier_item_amulet_of_intellect:IsHidden() return true end
function modifier_item_amulet_of_intellect:IsDebuff() return false end
function modifier_item_amulet_of_intellect:IsPurgable() return false end
function modifier_item_amulet_of_intellect:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_amulet_of_intellect:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_amulet_of_intellect:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT           }
end

function modifier_item_amulet_of_intellect:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.cooldown_reduction = self.item_ability:GetSpecialValueFor("cooldown_reduction")
    self.passive_mana_regen = self.item_ability:GetSpecialValueFor("passive_mana_regen")
end

function modifier_item_amulet_of_intellect:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_amulet_of_intellect:GetModifierCooldownReduction_Constant()
    return self.cooldown_reduction
end


function modifier_item_amulet_of_intellect:GetModifierConstantManaRegen()
    return self.passive_mana_regen
end