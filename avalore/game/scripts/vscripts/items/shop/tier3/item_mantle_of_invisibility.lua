item_mantle_of_invisiibility = class({})

LinkLuaModifier( "modifier_item_mantle_of_invisiibility", "items/shop/tier3/item_mantle_of_invisiibility.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mantle_of_invisiibility_invis", "items/shop/tier3/item_mantle_of_invisiibility.lua", LUA_MODIFIER_MOTION_NONE )

function item_mantle_of_invisiibility:GetIntrinsicModifierName()
    return "modifier_item_mantle_of_invisiibility"
end

function item_mantle_of_invisiibility:OnSpellStart()
    local caster    =   self:GetCaster()
	local particle_invis_start = "particles/generic_hero_status/status_invisibility_start.vpcf"

    local duration  =   self:GetSpecialValueFor("invis_duration")
	local fade_time =   self:GetSpecialValueFor("invis_fade_time")

    EmitSoundOn("DOTA_Item.InvisibilitySword.Activate", self:GetCaster())

    Timers:CreateTimer(fade_time, function()
		local particle_invis_start_fx = ParticleManager:CreateParticle(particle_invis_start, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_invis_start_fx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_invis_start_fx)

		caster:AddNewModifier(caster, self, "modifier_item_mantle_of_invisiibility_invis", {duration = duration})
	end)

end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_mantle_of_invisiibility = class({})

function modifier_item_mantle_of_invisiibility:IsHidden() return true end
function modifier_item_mantle_of_invisiibility:IsDebuff() return false end
function modifier_item_mantle_of_invisiibility:IsPurgable() return false end
function modifier_item_mantle_of_invisiibility:RemoveOnDeath() return false end
function modifier_item_mantle_of_invisiibility:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mantle_of_invisiibility:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT      }
end

function modifier_item_mantle_of_invisiibility:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_mantle_of_invisiibility:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_mantle_of_invisiibility:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_mantle_of_invisiibility:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_mantle_of_invisiibility:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_mantle_of_invisiibility:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_mantle_of_invisiibility:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

-- ====================================
-- ACTIVE MOD
-- ====================================

modifier_item_mantle_of_invisiibility_invis = class({})

function modifier_item_mantle_of_invisiibility_invis:IsDebuff() return false end
function modifier_item_mantle_of_invisiibility_invis:IsHidden() return false end
function modifier_item_mantle_of_invisiibility_invis:IsPurgable() return false end

function modifier_item_mantle_of_invisiibility_invis:OnCreated(params)
    if not self:GetAbility() then self:Destroy() return end
    self.invis_ms_pct = self.item_ability:GetSpecialValueFor("invis_ms_pct")
    
end

function modifier_item_mantle_of_invisiibility_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]			= true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_item_mantle_of_invisiibility_invis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function modifier_item_mantle_of_invisiibility_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_item_mantle_of_invisiibility_invis:GetModifierMoveSpeedBonus_Percentage()
    return self.invis_ms_pct
end

function modifier_item_mantle_of_invisiibility_invis:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_item_mantle_of_invisiibility_invis:OnAbilityExecuted( keys )
	if IsServer() then
		local parent =	self:GetParent()
		-- Remove the invis on cast
		if keys.unit == parent then
			self:Destroy()
		end
	end
end