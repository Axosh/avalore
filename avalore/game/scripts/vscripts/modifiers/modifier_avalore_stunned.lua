modifier_avalore_stunned = class({})

function modifier_avalore_stunned:GetTexture()
	return "generic/stunned"
end

--------------------------------------------------------------------------------
-- Classifications
function modifier_avalore_stunned:IsDebuff()
	return true
end

function modifier_avalore_stunned:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_avalore_stunned:OnCreated( kv )
	if not IsServer() then return end

	self.particle = "particles/generic_gameplay/generic_stunned.vpcf"
	if kv.bash==1 then
		self.particle = "particles/generic_gameplay/generic_bashed.vpcf"
	end


	-- calculate status resistance
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_avalore_stunned:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_avalore_stunned:OnRemoved()
end

function modifier_avalore_stunned:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_avalore_stunned:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_avalore_stunned:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_avalore_stunned:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_avalore_stunned:GetEffectName()
	return self.particle
end

function modifier_avalore_stunned:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end