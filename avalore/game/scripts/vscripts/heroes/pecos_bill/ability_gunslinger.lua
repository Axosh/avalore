ability_gunslinger = class({})

LinkLuaModifier("modifier_gunslinger", "heroes/pecos_bill/modifier_gunslinger.lua",        LUA_MODIFIER_MOTION_NONE )

function ability_gunslinger:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetDuration()

	-- addd buff
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_gunslinger", -- modifier name
		{ duration = duration } -- kv
	)
end