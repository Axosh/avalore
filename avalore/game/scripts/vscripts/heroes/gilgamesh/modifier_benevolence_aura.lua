modifier_benevolence_aura = class({})

LinkLuaModifier("modifier_benevolence_aura_buff",    "scripts/vscripts/heroes/gilgamesh/modifier_benevolence_aura_buff.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_benevolence_aura:IsPurgable() return false end
function modifier_benevolence_aura:IsAura()     return true  end
function modifier_benevolence_aura:IsDebuff()   return false end

function modifier_benevolence_aura:GetTexture()
    return "gilgamesh/benevolence"
end

function modifier_benevolence_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_benevolence_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_benevolence_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_benevolence_aura:GetAuraEntityReject(hEntity)
    if IsServer() then
		if self:GetParent() == hEntity then
			return true
		end
	end

	return false
end

function modifier_benevolence_aura:GetModifierAura()
    return "modifier_benevolence_aura_buff"
end

-- function modifier_benevolence_aura:DeclareFunctions()
--     return {
--         MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
--     }
-- end

function modifier_benevolence_aura:OnCreated()
    self.radius               = self:GetCaster():FindTalentValue("talent_benevolence", "aura_radius")
    --self.damage_buff_aura_pct = self:GetCaster():FindTalentValue("talent_benevolence", "damage_buff_aura_pct")
end

-- function modifier_benevolence_aura:GetModifierBaseAttack_BonusDamage()
--     return self.damage_buff_aura_pct
-- end

function modifier_benevolence_aura:GetAuraRadius()
    return self.radius
end