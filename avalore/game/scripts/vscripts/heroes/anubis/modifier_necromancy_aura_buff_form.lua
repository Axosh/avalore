modifier_necromancy_aura_buff_form = modifier_necromancy_aura_buff_form or class({})


function modifier_necromancy_aura_buff_form:IsHidden() return false end
function modifier_necromancy_aura_buff_form:IsDebuff() return false end
function modifier_necromancy_aura_buff_form:IsPurgable() return false end

function modifier_necromancy_aura_buff_form:OnCreated(kv)
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.outgoing_damage_pct = kv.outgoing_damage_pct
	if IsServer() then
		self:StartIntervalThink(0.1)
	end

	self:SetStackCount(math.floor(self:GetDuration() + 0.5))
end

function modifier_necromancy_aura_buff_form:DeclareFunctions()
	return {    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
				MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
				MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
				MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
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

function modifier_necromancy_aura_buff_form:OnIntervalThink()
	if not IsServer() then
		return
	end
	self:SetStackCount(math.floor(self:GetRemainingTime() + 0.5))
end

function modifier_necromancy_aura_buff_form:GetModifierTotalDamageOutgoing_Percentage(kv)
	if kv.attacker == self:GetParent() then
		return self.outgoing_damage_pct
	end
end

function modifier_necromancy_aura_buff_form:OnDestroy()
	if IsServer() then
		print("modifier_necromancy_aura_buff_form:OnDestroy()")
		-- Force kill the unit
		TrueKill(self.original_killer, self.parent, self.ability_killer)

		if self.parent:IsAlive() then
			self.parent:Kill(self.ability_killer, self.original_killer)
		end

		if self.parent:IsAlive() then
			print("modifier_necromancy_aura_buff_form:OnDestroy() >> Deal Lethal Damage")
			local damageTable = {
				victim = self.parent,
				attacker = self.original_killer,
				damage = 100000000,
				damage_type = DAMAGE_TYPE_PURE,
				ability = self.ability_killer,
				damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_REFLECTION,
			}
			ApplyDamage(damageTable)
		end

		--self.damage_pool = nil
		self.max_hp = nil
		self.threhold_hp = nil
	end
	self.caster = nil
	self.ability = nil
	self.parent = nil
end


function modifier_necromancy_aura_buff_form:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end
