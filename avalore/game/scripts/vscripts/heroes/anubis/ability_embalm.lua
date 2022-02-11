ability_embalm = ability_embalm or class({})

-- called when the ability entity is created
function ability_embalm:Init?()
    self.mod_corpse_count = self:GetOwner():AddNewModifier(self:GetOwner(), self, "modifier_corpse_tracker", {})
end

function ability_embalm:OnSpellStart()
    local caster = self:GetCaster()
	local ability = self
    local duration = self:GetSpecialValueFor("duration")

    self.thinker = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_embalm_thinker", -- modifier name
		{ duration = duration }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)
	self.thinker = self.thinker:FindModifierByName("modifier_embalm_thinker")
end

function ability_embalm:OnChannelFinish( bInterrupted )
	if self.thinker and not self.thinker:IsNull() then
		self.thinker:Destroy()
	end
end

