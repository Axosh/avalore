ability_embalm = ability_embalm or class({})

LinkLuaModifier("modifier_corpse_tracker",    "scripts/vscripts/heroes/anubis/modifier_corpse_tracker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_embalm_thinker",    "scripts/vscripts/heroes/anubis/modifier_embalm_thinker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mummy",    		  "scripts/vscripts/heroes/anubis/modifier_mummy.lua", LUA_MODIFIER_MOTION_NONE)

-- -- called when the ability entity is created
-- function ability_embalm:Init?()
--     self.mod_corpse_count = self:GetOwner():AddNewModifier(self:GetOwner(), self, "modifier_corpse_tracker", {})
-- end

function ability_embalm:OnSpellStart()
    local caster = self:GetCaster()
	local ability = self
    local duration = self:GetSpecialValueFor("duration")

	if not IsServer() then return end

    self.thinker = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_embalm_thinker", -- modifier name
		{ duration = duration },
		  --corpse_tracker = self.tracker }, -- kv
		caster:GetAbsOrigin(),
		caster:GetTeamNumber(),
		false
	)
	--self.thinker = self.thinker:FindModifierByName("modifier_embalm_thinker")
	caster:StopAnimation()
	caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_1, 5)
end

function ability_embalm:OnChannelFinish( bInterrupted )
	if self.thinker and not self.thinker:IsNull() then
		self.thinker:Destroy()
	end
end

function ability_embalm:OnUpgrade()
	if not IsServer() then return end
	-- check to see if this is the first time we're learning the spell and
	-- set up the thinker if so
	if not self.tracker then
		self.tracker = self:GetOwner():AddNewModifier(self:GetOwner(), self, "modifier_corpse_tracker", {})
	end
end