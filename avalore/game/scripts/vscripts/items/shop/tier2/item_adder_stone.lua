item_adder_stone = class({})

LinkLuaModifier( "modifier_item_adder_stone", "items/shop/tier2/item_adder_stone.lua", LUA_MODIFIER_MOTION_NONE )

function item_adder_stone:GetIntrinsicModifierName()
    return "modifier_item_adder_stone"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_adder_stone = modifier_item_adder_stone or class({})

function modifier_item_adder_stone:IsHidden() return true end
function modifier_item_adder_stone:IsDebuff() return false end
function modifier_item_adder_stone:IsPurgable() return false end
function modifier_item_adder_stone:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_adder_stone:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_adder_stone:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
                MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, 
                MODIFIER_PROPERTY_ABSORB_SPELL }
end

function modifier_item_adder_stone:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self.magic_resist = self.item_ability:GetSpecialValueFor("magic_resist")
    self.bonus_hp_regen = self.item_ability:GetSpecialValueFor("bonus_hp_regen")
    self.particle = "particles/prototype_fx/item_linkens_buff.vpcf"
end

function modifier_item_adder_stone:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_adder_stone:GetModifierMagicalResistanceBonus()
    return self.magic_resist
end

function modifier_item_adder_stone:GetModifierConstantHealthRegen()
    return self.bonus_hp_regen
end

function modifier_item_adder_stone:GetAbsorbSpell(params)
    if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        print("same team - skipping")
		return nil
	end

    -- check if we can absorb
    if not self.item_ability:IsCooldownReady() then return 0 end

    -- Effects
    self:GetCaster():EmitSound("Item.LinkensSphere.Activate")

    self.pfx = ParticleManager:CreateParticle(self.particle, PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

    -- start item cooldown
    self.item_ability:UseResources(false, false, false, true)

    return 1
end