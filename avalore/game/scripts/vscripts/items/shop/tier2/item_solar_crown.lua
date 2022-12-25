item_solar_crown = class({})

LinkLuaModifier( "modifier_item_solar_crown", "items/shop/tier2/item_solar_crown.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_golden_fleece_aura", "items/shop/base_materials/item_golden_fleece.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ember_burn", "items/shop/base_materials/item_essence_of_ember.lua", LUA_MODIFIER_MOTION_NONE )

function item_solar_crown:GetIntrinsicModifierName()
    return "modifier_item_solar_crown"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_solar_crown = class({})

function modifier_item_solar_crown:IsHidden() return true end
function modifier_item_solar_crown:IsDebuff() return false end
function modifier_item_solar_crown:IsPurgable() return false end
function modifier_item_solar_crown:RemoveOnDeath() return false end
function modifier_item_solar_crown:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_solar_crown:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_BONUS_DAY_VISION,
                MODIFIER_EVENT_ON_ATTACK_LANDED      }
end

function modifier_item_solar_crown:IsAura()
	return true
end

function modifier_item_solar_crown:GetAuraRadius()
	if self.item_ability then
		return self.item_ability:GetSpecialValueFor("aura_radius")
	end
end

function modifier_item_solar_crown:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_solar_crown:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_solar_crown:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_solar_crown:OnCreated(event)
    self.item_ability       = self:GetAbility()
    self.bonus_armor        = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_day_vision   = self.item_ability:GetSpecialValueFor("bonus_day_vision")
    self.duration           = self.item_ability:GetSpecialValueFor("burn_duration")
end

function modifier_item_solar_crown:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_solar_crown:GetBonusDayVision()
    return self.bonus_day_vision
end

function modifier_item_solar_crown:GetModifierAura()
	return "modifier_item_golden_fleece_aura"
end

function modifier_item_solar_crown:OnAttackLanded(kv)
    if not IsServer() then return end

    local caster = self:GetCaster();
    if kv.attacker == caster then
        local dur_resist = self.duration * (1 - kv.target:GetStatusResistance())
        kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_ember_burn", {duration = dur_resist})
    end
end