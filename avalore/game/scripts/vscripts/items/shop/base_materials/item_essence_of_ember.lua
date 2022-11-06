item_essence_of_ember = class({})

LinkLuaModifier( "modifier_item_essence_of_ember", "items/shop/base_materials/item_essence_of_ember.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ember_burn", "items/shop/base_materials/item_essence_of_ember.lua", LUA_MODIFIER_MOTION_NONE )

function item_essence_of_ember:GetIntrinsicModifierName()
    return "modifier_item_essence_of_ember"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_essence_of_ember = modifier_item_essence_of_ember or class({})

function modifier_item_essence_of_ember:IsHidden()      return true  end
function modifier_item_essence_of_ember:IsDebuff()      return false end
function modifier_item_essence_of_ember:IsPurgable()    return false end
function modifier_item_essence_of_ember:RemoveOnDeath() return false end

function modifier_item_essence_of_ember:DeclareFunctions()
    return {    MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_item_essence_of_ember:OnCreated(kv)
    self.item_ability       = self:GetAbility()
    self.burn_per_sec       = self.item_ability:GetSpecialValueFor("burn_per_sec")
    self.duration           = self.item_ability:GetSpecialValueFor("burn_duration")
end

function modifier_item_essence_of_ember:OnAttackLanded(kv)
    if not IsServer() then return end

    local caster = self:GetCaster();
    if kv.attacker == caster then
        local dur_resist = self.duration * (1 - kv.target:GetStatusResistance())
        kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_ember_burn", {duration = dur_resist})
    end
end

-- ====================================
-- DEBUFF MOD 
-- ====================================

modifier_ember_burn = modifier_ember_burn or class({})

function modifier_ember_burn:IsHidden() return false end
function modifier_ember_burn:IsDebuff() return true end
function modifier_ember_burn:IsPurgable() return true end
function modifier_ember_burn:RemoveOnDeath() return true end

function modifier_ember_burn:GetTexture()
    return "generic/burning"
end

function modifier_ember_burn:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_ember_burn:DeclareFunctions()
    return {    MODIFIER_PROPERTY_TOOLTIP } --,
                --MODIFIER_PROPERTY_TOOLTIP2 }
end

function modifier_ember_burn:OnCreated(kv)
    self.burn_per_sec       = self:GetAbility():GetSpecialValueFor("burn_per_sec")

    if not IsServer() then return end
    self:IncrementStackCount()

    -- Precache damage table
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
        ability = self:GetAbility()
	}

    self:StartIntervalThink(1)
end

function modifier_ember_burn:OnRefresh()
	if not IsServer() then return end

	self:IncrementStackCount()
end

function modifier_ember_burn:OnIntervalThink()
    if not IsServer() then return end

	self.damage_type = DAMAGE_TYPE_MAGICAL

	self.damageTable.damage 		= self:GetStackCount() * self.burn_per_sec
	self.damageTable.damage_type	= self.damage_type

	ApplyDamage( self.damageTable )
end

function modifier_ember_burn:OnTooltip()
    return (self:GetStackCount() * self.burn_per_sec)
end