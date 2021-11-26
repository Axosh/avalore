modifier_talent_static_field = class({})

function modifier_talent_static_field:RemoveOnDeath() return false end
function modifier_talent_static_field:IsPurgable() return false end
function modifier_talent_static_field:IsHidden() return true end

function modifier_talent_static_field:OnCreated()
    print("modifier_talent_static_field")
end

function modifier_talent_static_field:DeclareFunctions()
    return  {
                MODIFIER_EVENT_ON_ABILITY_EXECUTED
            }
end

--function modifier_talent_static_field:OnAbilityFullyCast(kv)
function modifier_talent_static_field:OnAbilityExecuted(kv)
    if not IsServer() then return end
    --print("modifier_talent_static_field:OnAbilityExecuted(kv)")

    --if not self:GetCaster():HasTalent("talent_static_field") then return end
--    print("modifier_talent_static_field:OnAbilityExecuted(kv) -- Has Talent")

    local caster = self:GetCaster()
    if not caster:PassivesDisabled() and kv.unit == caster and caster:HasTalent("talent_static_field") and not kv.ability:IsItem() then
        --local ability 			 = self:GetAbility()
        local radius 			 = self:GetAbility():GetSpecialValueFor("radius")
        local damage_health_pct  = self:GetAbility():GetSpecialValueFor("damage_health_pct")
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

        --local caster_position = caster:GetAbsOrigin()

        -- local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        -- ParticleManager:SetParticleControl(pfx, 1, kv.target:GetAbsOrigin() * 100)
        --ParticleManager:SetParticleControl(pfx, 0, Vector(caster_position.x, caster_position.y, caster_position.z))		
        --ParticleManager:SetParticleControl(pfx, 1, Vector(caster_position.x, caster_position.y, caster_position.z) * 100)	
        
        local damage_table 			= {}
        damage_table.attacker 		= self:GetCaster()
        damage_table.ability 		= kv.ability
        damage_table.damage_type 	= kv.ability:GetAbilityDamageType()
        damage_table.damage_flag	= DOTA_DAMAGE_FLAG_HPLOSS

        print("Nearby Units for Static Field:")
        for _,unit in pairs(nearby_enemy_units) do
            if unit:IsAlive() and unit ~= caster and not unit:IsBoss() then
                print(unit:GetName())
                local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
                ParticleManager:SetParticleControl(pfx, 1, unit:GetAbsOrigin() * 100)

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