item_ring_of_gyges = class({})

LinkLuaModifier( "modifier_item_ring_of_gyges", "items/shop/tier4/item_ring_of_gyges.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_ring_of_gyges_invis", "items/shop/tier4/item_ring_of_gyges.lua", LUA_MODIFIER_MOTION_NONE )

function item_ring_of_gyges:GetIntrinsicModifierName()
    return "modifier_item_ring_of_gyges"
end

function item_ring_of_gyges:OnSpellStart()
    local caster    =   self:GetCaster()
	local particle_invis_start = "particles/generic_hero_status/status_invisibility_start.vpcf"

    local duration  =   self:GetSpecialValueFor("invis_duration")
	local fade_time =   self:GetSpecialValueFor("invis_fade_time")

    EmitSoundOn("DOTA_Item.InvisibilitySword.Activate", self:GetCaster())

    Timers:CreateTimer(fade_time, function()
		local particle_invis_start_fx = ParticleManager:CreateParticle(particle_invis_start, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_invis_start_fx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_invis_start_fx)

		caster:AddNewModifier(caster, self, "modifier_item_ring_of_gyges_invis", {duration = duration})
	end)

end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_ring_of_gyges = class({})

function modifier_item_ring_of_gyges:IsHidden() return true end
function modifier_item_ring_of_gyges:IsDebuff() return false end
function modifier_item_ring_of_gyges:IsPurgable() return false end
function modifier_item_ring_of_gyges:RemoveOnDeath() return false end
function modifier_item_ring_of_gyges:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_ring_of_gyges:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS      }
end

function modifier_item_ring_of_gyges:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
end

function modifier_item_ring_of_gyges:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_ring_of_gyges:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_ring_of_gyges:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

-- ====================================
-- ACTIVE MOD
-- ====================================

modifier_item_ring_of_gyges_invis = class({})

function modifier_item_ring_of_gyges_invis:IsDebuff() return false end
function modifier_item_ring_of_gyges_invis:IsHidden() return false end
function modifier_item_ring_of_gyges_invis:IsPurgable() return false end

function modifier_item_ring_of_gyges_invis:OnCreated(params)
    if not self:GetAbility() then self:Destroy() return end
    if not IsServer() then return end
end

function modifier_item_ring_of_gyges_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]			= true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE]	= true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_item_ring_of_gyges_invis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end

function modifier_item_ring_of_gyges_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_item_ring_of_gyges_invis:GetTexture()
    return "items/ring_of_gyges_orig"
end