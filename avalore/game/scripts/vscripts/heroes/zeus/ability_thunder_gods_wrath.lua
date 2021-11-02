ability_thunder_gods_wrath = class({})

function ability_thunder_gods_wrath:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Zuus.GodsWrath.PreCast")

	local attack_lock = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1"))

	self.thundergod_spell_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) --, self:GetCaster())
	ParticleManager:SetParticleControl(self.thundergod_spell_cast, 0, Vector(attack_lock.x, attack_lock.y, attack_lock.z))
	ParticleManager:SetParticleControl(self.thundergod_spell_cast, 1, Vector(attack_lock.x, attack_lock.y, attack_lock.z))
	ParticleManager:SetParticleControl(self.thundergod_spell_cast, 2, Vector(attack_lock.x, attack_lock.y, attack_lock.z))

	return true
end

function ability_thunder_gods_wrath:OnAbilityPhaseInterrupted()
	if self.thundergod_spell_cast then
		ParticleManager:DestroyParticle(self.thundergod_spell_cast, true)
		ParticleManager:ReleaseParticleIndex(self.thundergod_spell_cast)
	end
end

function ability_thunder_gods_wrath:OnSpellStart(kv)
    if not IsServer() then return end
    local caster = self:GetCaster()
	local ability = self
	local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	
    EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Hero_Zuus.GodsWrath", self:GetCaster())

    local damage_table 			= {}
    damage_table.attacker 		= self:GetCaster()
    damage_table.ability 		= ability
    damage_table.damage_type 	= ability:GetAbilityDamageType()

    for _,hero in pairs(HeroList:GetAllHeroes()) do 
        if hero:IsAlive() and hero:GetTeam() ~= caster:GetTeam() and (not hero:IsIllusion()) and not hero:IsClone() then
            local target_point = hero:GetAbsOrigin()

            local thundergod_strike_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, self:GetCaster())
            ParticleManager:SetParticleControl(thundergod_strike_particle, 0, Vector(target_point.x, target_point.y, target_point.z + hero:GetBoundingMaxs().z))
            ParticleManager:SetParticleControl(thundergod_strike_particle, 1, Vector(target_point.x, target_point.y, 2000))
            ParticleManager:SetParticleControl(thundergod_strike_particle, 2, Vector(target_point.x, target_point.y, target_point.z + hero:GetBoundingMaxs().z))

            if (not hero:IsMagicImmune()) and (not hero:IsInvisible() or caster:CanEntityBeSeenByMyTeam(hero)) then
                damage_table.damage	 = self:GetAbilityDamage()
                damage_table.victim  = hero
                ApplyDamage(damage_table)

                Timers:CreateTimer(FrameTime(), function()
                    if not hero:IsAlive() then
                        local thundergod_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zues_kill_empty.vpcf", PATTACH_WORLDORIGIN, nil, self:GetCaster())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 0, hero:GetAbsOrigin())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 1, hero:GetAbsOrigin())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 2, hero:GetAbsOrigin())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 3, hero:GetAbsOrigin())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 6, hero:GetAbsOrigin())
                    end
                end)
            end

            hero:EmitSound("Hero_Zuus.GodsWrath.Target")

            hero:AddNewModifier(caster, ability, "modifier_zuus_thundergodswrath_vision_thinker", {duration = sight_duration, radius = sight_radius}) -- using a built-in modifier
        end
    end
end