modifier_tomb_aura_buff = class({})

function modifier_tomb_aura_buff:IsHidden() return false end
function modifier_tomb_aura_buff:IsPurgable() return false end
function modifier_tomb_aura_buff:IsDebuff() return false end

function modifier_tomb_aura_buff:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf"
end

function modifier_tomb_aura_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_tomb_aura_buff:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- Ability specials
	self.bonus_move_speed_pct = self.ability:GetSpecialValueFor("bonus_move_speed_pct")
	self.bonus_attack_speed = self.ability:GetSpecialValueFor("bonus_attack_speed")

	self.talent_ms = self.ability:GetSpecialValueFor("talent_bonus_move_speed")
	self.talent_as = self.ability:GetSpecialValueFor("talent_bonus_attack_speed")

    -- -- particle
    -- local aura_particle = ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_eztzhok_ovr_arc_lv.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	-- ParticleManager:SetParticleControl(aura_particle, 3, Vector(0, 0, 0))
	-- self:AddParticle(aura_particle, false, false, -1, false, false)
end

function modifier_tomb_aura_buff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					  MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}

	return decFuncs
end

function modifier_tomb_aura_buff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetCaster():HasModifier("modifier_talent_epitaph_spells") then
		return self.bonus_move_speed_pct + self.talent_ms
	end
	
	return self.bonus_move_speed_pct
end

function modifier_tomb_aura_buff:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster():HasModifier("modifier_talent_epitaph_spells") then
		return self.bonus_attack_speed + self.talent_as
	end

	return self.bonus_attack_speed
end