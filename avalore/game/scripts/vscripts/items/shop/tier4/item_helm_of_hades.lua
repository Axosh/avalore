item_helm_of_hades = class({})

LinkLuaModifier( "modifier_item_helm_of_hades", "items/shop/tier4/item_helm_of_hades.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_helm_of_hades_invis", "items/shop/tier4/item_helm_of_hades.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_helm_of_hades_visual", "items/shop/tier4/item_helm_of_hades.lua", LUA_MODIFIER_MOTION_NONE )

function item_helm_of_hades:GetIntrinsicModifierName()
    return "modifier_item_helm_of_hades"
end

function item_helm_of_hades:OnSpellStart()
    --EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Hero_Slark.DarkPact.PreCast", self:GetCaster())
    EmitSoundOn("DOTA_Item.InvisibilitySword.Activate", self:GetCaster())

    local duration  =   self:GetSpecialValueFor("invis_duration")
	local fade_time =   self:GetSpecialValueFor("invis_fade_time")

    local start_particle	= ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster(), self:GetCaster():GetTeamNumber())
    ParticleManager:SetParticleControlEnt(start_particle, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(start_particle, 61, Vector(0, 0, 0))
    --delay_modifier:AddParticle(start_particle, false, false, -1, false, false)
    ParticleManager:ReleaseParticleIndex(start_particle)
        
    Timers:CreateTimer(fade_time, function()
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_helm_of_hades_invis", {duration = duration})
    end)

end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_helm_of_hades = class({})

function modifier_item_helm_of_hades:IsHidden() return true end
function modifier_item_helm_of_hades:IsDebuff() return false end
function modifier_item_helm_of_hades:IsPurgable() return false end
function modifier_item_helm_of_hades:RemoveOnDeath() return false end
function modifier_item_helm_of_hades:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_helm_of_hades:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS      }
end

function modifier_item_helm_of_hades:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
end

function modifier_item_helm_of_hades:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_helm_of_hades:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_item_helm_of_hades:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

-- ====================================
-- ACTIVE MOD
-- ====================================

modifier_item_helm_of_hades_invis = class({})

function modifier_item_helm_of_hades_invis:IsDebuff() return false end
function modifier_item_helm_of_hades_invis:IsHidden() return false end
function modifier_item_helm_of_hades_invis:IsPurgable() return false end

function modifier_item_helm_of_hades_invis:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function modifier_item_helm_of_hades_invis:OnCreated(params)
    if not IsServer() then return end

    -- since cosmetics replicate the mod, don't spam out the particles
    if not self:GetParent():FindModifierByName( "modifier_wearable" ) then
        self.shadow_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.shadow_particle, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_eyeR", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.shadow_particle, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_eyeL", self:GetCaster():GetAbsOrigin(), true)
        self:AddParticle(self.shadow_particle, false, false, -1, false, false)

        ParticleManager:SetParticleControlEnt(self.shadow_particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        local visual_unit = CreateUnitByName("npc_dota_slark_visual", self:GetParent():GetAbsOrigin(), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber())
        visual_unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_helm_of_hades_visual", {})
        visual_unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = self:GetDuration()})

        local shadow_particle_name = "particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf"
        self.shadow_dummy_particle = ParticleManager:CreateParticle(shadow_particle_name, PATTACH_ABSORIGIN_FOLLOW, visual_unit)
        ParticleManager:SetParticleControlEnt(self.shadow_dummy_particle, 1, visual_unit, PATTACH_POINT_FOLLOW, nil, visual_unit:GetAbsOrigin(), true)
        self:AddParticle(self.shadow_dummy_particle, false, false, -1, false, false)
    end
end

function modifier_item_helm_of_hades_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]			= true
	}
end

function modifier_item_helm_of_hades_invis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end

function modifier_item_helm_of_hades_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_item_helm_of_hades_invis:GetActivityTranslationModifiers()
	return "shadow_dance"
end


-- ====================================
-- VISUAL MOD
-- ====================================

modifier_item_helm_of_hades_visual = class({})

function modifier_item_helm_of_hades_visual:IsPurgable()	return false end

function modifier_item_helm_of_hades_visual:OnCreated()
	if not IsServer() then return end
	
	self:StartIntervalThink(FrameTime())
end

function modifier_item_helm_of_hades_visual:OnIntervalThink()
	self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin())
end

function modifier_item_helm_of_hades_visual:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]				= false,
		[MODIFIER_STATE_NO_HEALTH_BAR]			= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
		[MODIFIER_STATE_INVULNERABLE]			= true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY]	= true,
		[MODIFIER_STATE_UNSELECTABLE]			= true,
		[MODIFIER_STATE_UNTARGETABLE]			= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP]			= true
	}
end