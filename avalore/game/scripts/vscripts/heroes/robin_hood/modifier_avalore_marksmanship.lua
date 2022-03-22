modifier_avalore_marksmanship = class({})

LinkLuaModifier( "modifier_chink_in_the_armor_debuff", "heroes/robin_hood/modifier_chink_in_the_armor_debuff.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------


function modifier_avalore_marksmanship:IsHidden( kv )
	return false
end

function modifier_avalore_marksmanship:IsDebuff( kv )
	return false
end

function modifier_avalore_marksmanship:IsPurgable( kv )
	return false
end

function modifier_avalore_marksmanship:RemoveOnDeath( kv )
	return false
end

--------------------------------------------------------------------------------
-- Life cycle
--------------------------------------------------------------------------------

function modifier_avalore_marksmanship:OnCreated( kv )
	print("Got Marksmanship Buff")
	if IsServer() then
		-- get reference
		self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_stack")
		self.bonus_reset_time = self:GetAbility():GetSpecialValueFor("bonus_reset_time")
        self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	end
end

function modifier_avalore_marksmanship:OnRefresh( kv )
	if IsServer() then
		-- get reference
		self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_stack")
		self.bonus_reset_time = self:GetAbility():GetSpecialValueFor("bonus_reset_time")
		self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	end
end

--------------------------------------------------------------------------------
-- Declare functions
--------------------------------------------------------------------------------

function modifier_avalore_marksmanship:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

--------------------------------------------------------------------------------
-- Declared functions' logic
--------------------------------------------------------------------------------

function modifier_avalore_marksmanship:GetModifierProcAttack_BonusDamage_Physical( params )
	if IsServer() then
		-- get target
		local target = params.target if target==nil then target = params.unit end
		if target:GetTeamNumber()==self:GetParent():GetTeamNumber() then
			return 0
		end

		-- get modifier stack
		local stack = 0
		local modifier = target:FindModifierByNameAndCaster("modifier_marksmanship_debuff", self:GetAbility():GetCaster())

		print("Making Marksmanship Stack on... " .. tostring(target:GetName()))

		-- add stack if not
		if modifier==nil then
			-- if does not have break
			if not self:GetParent():PassivesDisabled() then
				-- determine duration if roshan/not
				local _duration = self.bonus_reset_time

				-- add modifier
				target:AddNewModifier(
					self:GetAbility():GetCaster(),
					self:GetAbility(),
					"modifier_marksmanship_debuff",
					{ duration = _duration }
				)

				-- get stack number
				stack = 1
			end
		else
			-- increase stack unless already maxed
			if modifier:GetStackCount() < self.max_stacks then
				modifier:IncrementStackCount()
			end
			
			if modifier:GetStackCount() == self.max_stacks and self:GetCaster():HasTalent("talent_chink_in_the_armor") then
				target:AddNewModifier(	self:GetAbility():GetCaster(),
										self:GetCaster():FindAbilityByName("talent_chink_in_the_armor"),
										"modifier_chink_in_the_armor_debuff",
										{})
			end
			modifier:ForceRefresh()

			-- get stack number
			stack = modifier:GetStackCount()
		end

		-- return damage bonus
		return stack * self.damage_per_stack
	end
end