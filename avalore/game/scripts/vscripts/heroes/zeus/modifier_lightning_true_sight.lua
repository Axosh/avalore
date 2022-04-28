modifier_lightning_true_sight = class({})

function modifier_lightning_true_sight:IsAura() return true end
function modifier_lightning_true_sight:IsHidden() return true end
function modifier_lightning_true_sight:IsPurgable() return false end

function modifier_lightning_true_sight:GetAuraRadius()
    return self:GetStackCount()
	--return 1
end

function modifier_lightning_true_sight:GetModifierAura()
    return "modifier_truesight"
end

function modifier_lightning_true_sight:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
	--return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_lightning_true_sight:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_lightning_true_sight:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER
end

function modifier_lightning_true_sight:GetAuraDuration()
    return 0.5
end