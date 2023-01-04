item_solar_crown = class({})

LinkLuaModifier( "modifier_item_solar_crown", "items/shop/tier2/item_solar_crown.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_golden_fleece_aura", "items/shop/base_materials/item_golden_fleece.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ember_burn", "items/shop/base_materials/item_essence_of_ember.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_solar_flare", "items/shop/tier2/item_solar_crown.lua", LUA_MODIFIER_MOTION_NONE )

function item_solar_crown:GetIntrinsicModifierName()
    return "modifier_item_solar_crown"
end

function item_solar_crown:GetBehavior() 
    return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
end

function item_solar_crown:OnSpellStart()
    self.radius = self:GetSpecialValueFor("blind_aoe")
    self.duration = self:GetSpecialValueFor("blind_duration")
    --local miss_rate = self:GetSpecialValueFor("miss_rate") --this is used in the solar flare mod
    self.caster		= self:GetCaster()

    if not IsServer() then return end
    local position = self.caster:GetAbsOrigin()
    self.caster:EmitSound("Hero_KeeperOfTheLight.BlindingLight")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf", PATTACH_POINT_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(particle, 0, position)
	ParticleManager:SetParticleControl(particle, 1, position)
	ParticleManager:SetParticleControl(particle, 2, Vector(self.radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(particle)

    local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(self.caster, self, "modifier_solar_flare", {duration = self.duration * (1 - enemy:GetStatusResistance())})
    end
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

-- ====================================
-- ACTIVE: SOLAR FLARE
-- ====================================

modifier_solar_flare = class({})
function modifier_solar_flare:IsHidden() return false end
function modifier_solar_flare:IsDebuff() return true end
function modifier_solar_flare:IsPurgable() return true end

function modifier_solar_flare:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

function modifier_solar_flare:GetTexture()
    return "items/solar_flare"
end

function modifier_solar_flare:OnCreated()
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()

	-- AbilitySpecials
	self.miss_rate				= self.ability:GetSpecialValueFor("miss_rate")
end

function modifier_solar_flare:OnAttackStart(kv)
    if not IsServer () then return end
    if kv.attacker == self:GetParent() then
        SendOverheadEventMessage(
                    nil,
                    OVERHEAD_ALERT_MISS,
                    kv.attacker,
                    0,
                    nil
                )
    end
end


function modifier_solar_flare:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_START
    }
end

function modifier_solar_flare:GetModifierMiss_Percentage()
    return self.miss_rate
end