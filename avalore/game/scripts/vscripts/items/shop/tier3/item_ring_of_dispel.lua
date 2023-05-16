item_ring_of_dispel = class({})

LinkLuaModifier( "modifier_item_ring_of_dispel", "items/shop/tier3/item_ring_of_dispel.lua", LUA_MODIFIER_MOTION_NONE )

function item_ring_of_dispel:GetIntrinsicModifierName()
    return "modifier_item_ring_of_dispel"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_ring_of_dispel = modifier_item_ring_of_dispel or class({})

function modifier_item_ring_of_dispel:IsHidden() return true end
function modifier_item_ring_of_dispel:IsDebuff() return false end
function modifier_item_ring_of_dispel:IsPurgable() return false end
function modifier_item_ring_of_dispel:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_ring_of_dispel:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_ring_of_dispel:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
                MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, 
                MODIFIER_PROPERTY_ABSORB_SPELL }
end

function modifier_item_ring_of_dispel:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self.magic_resist = self.item_ability:GetSpecialValueFor("magic_resist")
    self.bonus_hp_regen = self.item_ability:GetSpecialValueFor("bonus_hp_regen")
end

function modifier_item_ring_of_dispel:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_ring_of_dispel:GetModifierMagicalResistanceBonus()
    return self.magic_resist
end

function modifier_item_ring_of_dispel:GetModifierConstantHealthRegen()
    return self.bonus_hp_regen
end

function modifier_item_ring_of_dispel:GetAbsorbSpell(params)
    if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        print("same team - skipping")
		return nil
	end

    -- check if we can absorb
    if not self.item_ability:IsCooldownReady() then return 0 end

    self:GetCaster():EmitSound("Item.LinkensSphere.Activate")
    -- start item cooldown
    self.item_ability:UseResources(false, false, false, true)

    return 1
end