item_ambrosia = class({})

LinkLuaModifier( "modifier_ambrosia_buff", "items/shop/consumables/item_ambrosia.lua", LUA_MODIFIER_MOTION_NONE )

function item_ambrosia:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
end

function item_ambrosia:OnSpellStart()
    local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local cast_sound = "DOTA_Item.HealingSalve.Activate"

    -- Ability specials
	local duration = ability:GetSpecialValueFor("duration")

	-- Emit sound
	EmitSoundOn(cast_sound, target)

    -- Give the target the modifier
	target:AddNewModifier(caster, ability, "modifier_ambrosia_buff", {duration = duration})

	-- Reduce a charge, or destroy the item if no charges are left
	ability:SpendCharge()
end

-- ====================================
-- REGEN BUFF
-- ====================================

modifier_ambrosia_buff = modifier_ambrosia_buff or class({})

function modifier_ambrosia_buff:IsHidden() return false end
function modifier_ambrosia_buff:IsDebuff() return false end
function modifier_ambrosia_buff:IsPurgable() return true end

function modifier_ambrosia_buff:GetTexture()
	return "items/ambrosia_orig"
end

function modifier_ambrosia_buff:GetEffectName()
	return "particles/items5_fx/elixer.vpcf"
end


function modifier_ambrosia_buff:OnCreated()
    self.caster = self:GetCaster()
	self.parent = self:GetParent()

    self.hp_regen = self:GetAbility():GetSpecialValueFor("hp_regen")
    self.mana_regen = self:GetAbility():GetSpecialValueFor("mp_regen")
end

function modifier_ambrosia_buff:DeclareFunctions()
	return {    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_ambrosia_buff:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_ambrosia_buff:GetModifierConstantManaRegen()
	return self.mana_regen
end

function modifier_ambrosia_buff:OnTakeDamage(kv)
    if not IsServer() then return end

    local attacker      = kv.attacker
	local target        = kv.unit
	local damage        = kv.original_damage
	local damage_flags  = kv.damage_flags

    -- Do nothing if the target isn't the parent
    if target ~= self.parent then
        return nil
    end

    -- Do nothing if damage is 0
	if damage <= 0 then
		return nil
	end

    -- Nothing if self-inflicted
    if attacker == self.parent then
        return nil
    end

    -- Do nothing if the source of the damage is flagged as HP removal
	if damage_flags == DOTA_DAMAGE_FLAG_HPLOSS then
		return nil
	end

    -- if we got this far, destroy the buff because we took damage from something
    self:Destroy()
end