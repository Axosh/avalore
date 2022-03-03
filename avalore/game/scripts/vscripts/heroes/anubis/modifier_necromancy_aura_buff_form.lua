modifier_necromancy_aura_buff_form = modifier_necromancy_aura_buff_form or class({})


function modifier_necromancy_aura_buff_form:IsHidden() return false end
function modifier_necromancy_aura_buff_form:IsDebuff() return false end
function modifier_necromancy_aura_buff_form:IsPurgable() return false end

function modifier_necromancy_aura_buff_form:OnCreated()
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
end

function modifier_necromancy_aura_buff_form:DeclareFunctions()
	return {    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
				MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
				MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
				MODIFIER_PROPERTY_DISABLE_HEALING,
				MODIFIER_PROPERTY_MODEL_SCALE,
				MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_necromancy_aura_buff_form:CheckState()
	local state = {[MODIFIER_STATE_NO_HEALTH_BAR] = true,
				   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
				   [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return state
end


function modifier_necromancy_aura_buff_form:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_necromancy_aura_buff_form:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_necromancy_aura_buff_form:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_necromancy_aura_buff_form:GetDisableHealing()
	return 1
end

function modifier_necromancy_aura_buff_form:GetModifierModelScale()
	return 1
	--return 105
end



function modifier_necromancy_aura_buff_form:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end
