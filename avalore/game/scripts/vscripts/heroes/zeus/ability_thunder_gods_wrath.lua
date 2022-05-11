ability_thunder_gods_wrath = class({})

LinkLuaModifier("modifier_talent_static_field",       "heroes/zeus/modifier_talent_static_field.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_lightning_rod",       "heroes/zeus/modifier_talent_lightning_rod.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lightning_true_sight", "heroes/zeus/modifier_lightning_true_sight.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lightning_bolt",       "heroes/zeus/modifier_lightning_bolt.lua",       LUA_MODIFIER_MOTION_NONE)

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
	local sight_radius = ability:GetLevelSpecialValueFor("true_sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	
    EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Hero_Zuus.GodsWrath", self:GetCaster())

    local damage_table 			= {}
    damage_table.attacker 		= self:GetCaster()
    damage_table.ability 		= ability
    damage_table.damage_type 	= ability:GetAbilityDamageType()

    for _,hero in pairs(HeroList:GetAllHeroes()) do 
        if hero:IsAlive() and hero:GetTeam() ~= caster:GetTeam() and (not hero:IsIllusion()) and not hero:IsClone() then
            local target_point = hero:GetAbsOrigin()
            print("Zapping " .. hero:GetName())
            print("Radi = " .. tostring(sight_radius))
            print("Dur = " .. tostring(sight_duration))

            -- local dummy_unit = CreateUnitByName("npc_dummy_unit", Vector(target_point.x, target_point.y, 0), false, nil, nil, caster:GetTeam())
            -- local true_sight = dummy_unit:AddNewModifier(caster, ability, "modifier_lightning_true_sight", {duration = sight_duration})
            -- true_sight:SetStackCount(sight_radius)
            -- dummy_unit:SetDayTimeVisionRange(sight_radius)
            -- dummy_unit:SetNightTimeVisionRange(sight_radius)
            -- dummy_unit:AddNewModifier(caster, ability, "modifier_lightning_bolt", {})
            -- print("Target Point: (" .. tostring(target_point.x) .. ", " .. tostring(target_point.y) .. ")")
            -- AddFOWViewer(DOTA_TEAM_GOODGUYS, target_point, sight_radius, sight_duration, false)
	        -- AddFOWViewer(DOTA_TEAM_BADGUYS, target_point, sight_radius, sight_duration, false)

            --local thundergod_strike_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            --local thundergod_strike_particle = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            local thundergod_strike_particle = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            ParticleManager:SetParticleControl(thundergod_strike_particle, 0, Vector(target_point.x, target_point.y, target_point.z + hero:GetBoundingMaxs().z))
            ParticleManager:SetParticleControl(thundergod_strike_particle, 1, Vector(target_point.x, target_point.y, 2000))
            ParticleManager:SetParticleControl(thundergod_strike_particle, 2, Vector(target_point.x, target_point.y, target_point.z + hero:GetBoundingMaxs().z))
            ParticleManager:ReleaseParticleIndex(thundergod_strike_particle)

            --local particle = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_strike.vpcf", PATTACH_WORLDORIGIN, target)
            local particle = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_bolt_parent.vpcf", PATTACH_WORLDORIGIN, target)
            -- ParticleManager:SetParticleControl(particle, 0, Vector(target_point.x, target_point.y, target_point.z))
            -- ParticleManager:SetParticleControl(particle, 1, Vector(target_point.x, target_point.y, z_pos))
            -- ParticleManager:SetParticleControl(particle, 2, Vector(target_point.x, target_point.y, target_point.z))
            ParticleManager:SetParticleControl(particle, 0, target_point)
	        ParticleManager:ReleaseParticleIndex(particle)

            if (not hero:IsMagicImmune()) and (not hero:IsInvisible() or caster:CanEntityBeSeenByMyTeam(hero)) then
                local bonus_dmg = 0
                if self:GetCaster():HasTalent("talent_lightning_rod") then
                    local lightning_rod_radius = self:GetCaster():FindTalentValue("talent_lightning_rod", "search_radius")
                    local bonus_dmg_per_hero = self:GetCaster():FindTalentValue("talent_lightning_rod", "bonus_dmg_per_hero")
                    -- iterate through targets again, find out if any are within the radius
                    --for _,hero_b in pairs(HeroList:GetAllHeroes()) do 
                    for _,hero_b in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hero:GetAbsOrigin(), nil, lightning_rod_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do 
                        if hero ~= hero_b and hero_b:IsAlive() and hero_b:GetTeam() ~= caster:GetTeam() and (not hero_b:IsIllusion()) and not hero_b:IsClone() then
                            bonus_dmg = bonus_dmg + bonus_dmg_per_hero
                            print("bonus damage += " .. tostring(bonus_dmg))
                        end
                    end

                end

                damage_table.damage	 = self:GetAbilityDamage() + bonus_dmg
                damage_table.victim  = hero
                ApplyDamage(damage_table)

                Timers:CreateTimer(FrameTime(), function()
                    if not hero:IsAlive() then
                        print("He dead")
                        --local thundergod_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zues_kill_empty.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
                        local thundergod_kill_particle = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_kill_remnant.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 0, hero:GetAbsOrigin())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 1, hero:GetAbsOrigin())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 2, hero:GetAbsOrigin())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 3, hero:GetAbsOrigin())
                        ParticleManager:SetParticleControl(thundergod_kill_particle, 6, hero:GetAbsOrigin())
                    end
                end)
            end

            hero:EmitSound("Hero_Zuus.GodsWrath.Target")

            --hero:AddNewModifier(caster, ability, "modifier_zuus_thundergodswrath_vision_thinker", {duration = sight_duration, radius = sight_radius}) -- using a built-in modifier
            AddFOWViewer(self:GetCaster():GetTeam(), target_point, sight_radius, sight_duration, false)
            local dummy_unit = CreateUnitByName("npc_dummy_unit", Vector(target_point.x, target_point.y, 0), false, nil, nil, caster:GetTeam())
            local true_sight = dummy_unit:AddNewModifier(caster, ability, "modifier_lightning_true_sight", {duration = sight_duration})
            true_sight:SetStackCount(sight_radius)
            -- dummy_unit:SetDayTimeVisionRange(sight_radius)
            -- dummy_unit:SetNightTimeVisionRange(sight_radius)
            dummy_unit:AddNewModifier(caster, ability, "modifier_lightning_bolt", {})
            dummy_unit:AddNewModifier(self:GetCaster(), nil, "modifier_kill", {duration = sight_duration + 1}) --built-in modifier: remove dummy after duration
        end
    end
end