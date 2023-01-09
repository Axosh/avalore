item_health_potion = class({})

LinkLuaModifier( "modifier_health_potion_buff", "items/shop/consumables/item_health_potion.lua", LUA_MODIFIER_MOTION_NONE )

function item_health_potion:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
end

function item_health_potion:OnSpellStart()
    local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local cast_sound = "DOTA_Item.HealingSalve.Activate"

    -- Ability specials
	local duration = ability:GetSpecialValueFor("duration")

	-- Emit sound
	EmitSoundOn(cast_sound, target)

    -- Give the target the modifier
	target:AddNewModifier(caster, ability, "modifier_health_potion_buff", {duration = duration})

	-- Reduce a charge, or destroy the item if no charges are left
	ability:SpendCharge()
end

-- ====================================
-- REGEN BUFF
-- ====================================

modifier_health_potion_buff = modifier_health_potion_buff or class({})

function modifier_health_potion_buff:IsHidden() return false end
function modifier_health_potion_buff:IsDebuff() return false end
function modifier_health_potion_buff:IsPurgable() return true end

function modifier_health_potion_buff:GetTexture()
	return "items/health_potion_orig"
end

function modifier_health_potion_buff:GetEffectName()
	return "particles/items_fx/healing_flask.vpcf"
end


function modifier_health_potion_buff:OnCreated()
    self.caster = self:GetCaster()
	self.parent = self:GetParent()

    self.hp_regen = self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_health_potion_buff:DeclareFunctions()
	return {    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
                MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_health_potion_buff:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_health_potion_buff:OnTakeDamage(kv)
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