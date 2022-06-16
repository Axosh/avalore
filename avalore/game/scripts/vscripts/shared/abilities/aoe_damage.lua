function AOEMagicDamage(caster, ability, location_vector, radius, damage)
    AOEDamage(caster, ability, location_vector, radius, damage, DAMAGE_TYPE_MAGICAL, nil)
end

function AOEMagicDamageExtra(caster, ability, location_vector, radius, damage, extra_targets)
    AOEDamage(caster, ability, location_vector, radius, damage, DAMAGE_TYPE_MAGICAL, extra_targets)
end

function AOEDamage(caster, ability, location_vector, radius, damage, damage_type, extra_targets)
    local targets = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    if extra_targets then
        targets = targets + extra_targets
    end
    -- find enemies to damage
    local enemies = FindUnitsInRadius(  caster:GetTeamNumber(),
                                        location_vector,--caster:GetAbsOrigin(),
                                        nil,
                                        radius,
                                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                                        targets,
                                        DOTA_UNIT_TARGET_FLAG_NONE,
                                        FIND_ANY_ORDER,
                                        false)

    -- loop through enemies to damage
    for _,enemy in pairs(enemies) do
        -- Deal damage
        local damageTable = {   victim      = enemy,
                                attacker    = caster,
                                damage      = damage,
                                damage_type = damage_type,
                                ability     = ability
                            }

        ApplyDamage(damageTable)
    end
end