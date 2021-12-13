modifier_gunslinger = class({})

function modifier_gunslinger:IsHidden() return false end
function modifier_gunslinger:IsDebuff() return false end
function modifier_gunslinger:IsStunDebuff() return false end
function modifier_gunslinger:IsPurgable() return true end

function modifier_gunslinger:OnCreated(kv)
    self.attacks = self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )

	--self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )

	if not IsServer() then return end
	self:SetStackCount( self.attacks )

	self.records = {}

	-- play Effects & Sound
	--self:PlayEffects()
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_gunslinger:OnRefresh( kv )
	-- references
	self.attacks = self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )

	--self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )

	if not IsServer() then return end
	self:SetStackCount( self.attacks )

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_gunslinger:OnRemoved()
end

function modifier_gunslinger:OnDestroy()
	if not IsServer() then return end

	-- stop sound
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	StopSoundOn( sound_cast, self:GetParent() )
end

function modifier_gunslinger:DeclareFunctions()
	local funcs = {
		 MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function modifier_gunslinger:OnAttack(kv)
	if kv.attacker~=self:GetParent() then return end
	if self:GetStackCount()<=1 then
		self:Destroy()
	end

	if self:GetStackCount()>0 then
		self:DecrementStackCount()
	end
end

-- function modifier_gunslinger:GetModifierProjectileName()
-- 	if self:GetStackCount()<=0 then return end
-- 	return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf"
-- end

function modifier_gunslinger:GetModifierOverrideAttackDamage()
	if self:GetStackCount()<=0 then return end
	return self.damage
end

function modifier_gunslinger:GetModifierAttackRangeBonus()
	if self:GetStackCount()<=0 then return end
	return self.range_bonus
end

function modifier_gunslinger:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount()<=0 then return end
	return self.as_bonus
end

function modifier_gunslinger:GetModifierBaseAttackTimeConstant()
	if self:GetStackCount()<=0 then return end
	return self.bat
end