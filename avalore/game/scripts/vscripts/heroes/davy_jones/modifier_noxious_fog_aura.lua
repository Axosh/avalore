modifier_noxious_fog_aura = class({})

LinkLuaModifier( "modifier_noxious_fog_debuff", "modifiers/modifier_noxious_fog_debuff.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_noxious_fog_aura:IsPurgable() return false end
function modifier_noxious_fog_aura:IsAura() return true end
function modifier_noxious_fog_aura:IsHidden() return true end

function modifier_noxious_fog_aura:OnCreated(kv)
	self.radius = kv.radius
end

function modifier_noxious_fog_aura:OnRefresh()
	if IsServer() then return end
    self:OnCreated()
end

function modifier_noxious_fog_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_noxious_fog_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
end

function modifier_noxious_fog_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_noxious_fog_aura:GetModifierAura()
	return "modifier_noxious_fog_debuff"
end

function modifier_noxious_fog_aura:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf"
end

function modifier_noxious_fog_aura:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_noxious_fog_aura:GetAuraEntityReject(target)
	return false
end

function modifier_noxious_fog_aura:GetAuraRadius()
	return self.radius
end
