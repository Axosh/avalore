modifier_talent_static_field = class({})

function modifier_talent_static_field:RemoveOnDeath() return false end
function modifier_talent_static_field:IsPurgable() return false end
function modifier_talent_static_field:IsHidden() return true end

function modifier_talent_static_field:OnAbilityExecuted(kv)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if kv.unit == caster and not kv.ability:IsItem() then
        --local ability 			 = self:GetAbility()
        local radius 			 = ability:GetSpecialValueFor("radius")
        local damage_health_pct  = ability:GetSpecialValueFor("damage_health_pct")
        --local duration			 = ability:GetSpecialValueFor("duration")
        --local radius                = 900
        --local damage_health_pct     = 8
        local nearby_enemy_units = FindUnitsInRadius(
            caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        local caster_position = caster:GetAbsOrigin()

        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster)
        ParticleManager:SetParticleControl(pfx, 0, Vector(caster_position.x, caster_position.y, caster_position.z))		
        ParticleManager:SetParticleControl(pfx, 1, Vector(caster_position.x, caster_position.y, caster_position.z) * 100)	
        
        local damage_table 			= {}
        damage_table.attacker 		= self:GetCaster()
        damage_table.ability 		= ability
        damage_table.damage_type 	= ability:GetAbilityDamageType() 

        for _,unit in pairs(nearby_enemy_units) do
            if unit:IsAlive() and unit ~= caster and not unit:IsRoshan() then
                local current_health = unit:GetHealth()
                damage_table.damage	 = (current_health / 100) * damage_health_pct
                damage_table.victim  = unit
                ApplyDamage(damage_table)
            end
        end
    end
end

-- function modifier_talent_static_field:Apply(target)
--     if not IsServer() then return end

--     if self:GetCaster():PassivesDisabled() or not target:IsAlive() or target == self:GetCaster() or target:IsRoshan() then return end

--     local caster			= self:GetCaster()
--     local damage_health_pct = 8

-- end