modifier_talent_chain_lightning = class({})

function modifier_talent_chain_lightning:IsHidden()		return true end
function modifier_talent_chain_lightning:IsPurgable()		return false end
function modifier_talent_chain_lightning:RemoveOnDeath()	return false end
function modifier_talent_chain_lightning:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_chain_lightning:OnCreated(kv)
	if not IsServer() or not self:GetAbility() then return end
    self.triggering_ability = self:GetAbility()
    self.talent_ability = self:GetAbility():GetOwner():FindAbilityByName("talent_chain_lightning")

    -- sync level so 
    self.talent_ability:SetLevel(self.triggering_ability:GetLevel())
    
    if not self.talent_ability then return end


	self.arc_damage			= self.talent_ability:GetSpecialValueFor("jump_damage")
	self.radius				= self.talent_ability:GetSpecialValueFor("radius")
	self.jump_count			= self.talent_ability:GetSpecialValueFor("jump_count")
	self.jump_delay			= self.talent_ability:GetSpecialValueFor("jump_delay")
	
	self.starting_unit_entindex	= kv.starting_unit_entindex
	
	self.units_affected			= {}
	
	if self.starting_unit_entindex and EntIndexToHScript(self.starting_unit_entindex) then
		-- Using a previous unit and current unit variable to track n-1 and n-2 unit hit in current Arc Lightning jump, with previous unit being used for the Master of Lightning talent (can only chain if the next target is not current or previous target)
		self.current_unit						= EntIndexToHScript(self.starting_unit_entindex)
		self.units_affected[self.current_unit]	= 1
		
		-- if self:GetCaster():HasModifier("modifier_talent_static_field") then
		-- 	self:GetCaster():FindModifierByName("modifier_talent_static_field"):Apply(self.current_unit)
		-- end
		
		ApplyDamage({
			victim 			= self.current_unit,
			damage 			= self.arc_damage,
			damage_type		= DAMAGE_TYPE_MAGICAL,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self.talent_ability
		})
	else
		self:Destroy()
		return
	end
	
	self.unit_counter			= 0
	
	self:StartIntervalThink(self.jump_delay)
end

function modifier_talent_chain_lightning:OnIntervalThink()
	self.zapped = false
	
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.current_unit:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
		if not self.units_affected[enemy] and enemy ~= self.current_unit and enemy ~= self.previous_unit then
			enemy:EmitSound("Hero_Zuus.ArcLightning.Target")
			
			self.lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.current_unit)
			ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_unit:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(self.lightning_particle, 62, Vector(2, 0, 2))
			ParticleManager:ReleaseParticleIndex(self.lightning_particle)
		
			self.unit_counter						= self.unit_counter + 1
			self.previous_unit						= self.current_unit
			self.current_unit						= enemy
			
			if self.units_affected[self.current_unit] then
				self.units_affected[self.current_unit]	= self.units_affected[self.current_unit] + 1
			else
				self.units_affected[self.current_unit]	= 1
			end
			
			self.zapped								= true
			
			-- if self:GetCaster():HasModifier("modifier_talent_static_field") then
            -- 	self:GetCaster():FindModifierByName("modifier_talent_static_field"):Apply(self.current_unit)
            -- end
			
			ApplyDamage({
				victim 			= enemy,
				damage 			= self.arc_damage,
				damage_type		= DAMAGE_TYPE_MAGICAL,
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self.talent_ability
			})
			
			break
		end
	end
	
	if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
		
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.current_unit:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
			if not self.units_affected[enemy] and enemy ~= self.current_unit and enemy ~= self.previous_unit then
				enemy:EmitSound("Hero_Zuus.ArcLightning.Target")
				
				self.lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.current_unit)
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_unit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(self.lightning_particle, 62, Vector(2, 0, 2))
				ParticleManager:ReleaseParticleIndex(self.lightning_particle)
				
				self.unit_counter						= self.unit_counter + 1
				self.previous_unit						= self.current_unit
				self.current_unit						= enemy
				
				if self.units_affected[self.current_unit] then
					self.units_affected[self.current_unit]	= self.units_affected[self.current_unit] + 1
				else
					self.units_affected[self.current_unit]	= 1
				end
				
				self.zapped								= true
				
				-- if self:GetCaster():HasModifier("modifier_talent_static_field") then
            -- 	self:GetCaster():FindModifierByName("modifier_talent_static_field"):Apply(self.current_unit)
            -- end
				
				ApplyDamage({
					victim 			= enemy,
					damage 			= self.arc_damage,
					damage_type		= DAMAGE_TYPE_MAGICAL,
					damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
					attacker 		= self:GetCaster(),
					ability 		= self.talent_ability
				})
				
				break
			end
		end
		
		-- Check again...
		if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
			self:StartIntervalThink(-1)
			self:Destroy()
		end
	end
end