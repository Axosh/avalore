ability_flying_dutchman = class({})

LinkLuaModifier("modifier_flying_dutchman", "heroes/davy_jones/ability_flying_dutchman.lua", LUA_MODIFIER_MOTION_NONE)

function ability_flying_dutchman:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetDuration()

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_flying_dutchman", -- modifier name
		{ duration = duration } -- kv
	)
end

-- ==================
-- MODIFIER
-- ==================

modifier_flying_dutchman = class({})

-- Classifications
function modifier_flying_dutchman:IsHidden()
	return false
end

function modifier_flying_dutchman:IsDebuff()
	return false
end

function modifier_flying_dutchman:IsPurgable()
	return false
end