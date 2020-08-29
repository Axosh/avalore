modifier_invuln_tower_based = class({})

function modifier_invuln_tower_based:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, 
    		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, 
    		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
    		DOTA_ABILITY_BEHAVIOR_HIDDEN}
end

function modifier_invuln_tower_based:GetAbsoluteNoDamageMagical( params )
	if IsServer() then
        local attacker = params.attacker
        local target = params.target
        if (self:CanDoDamage(attacker, target)) then
            return 0 
        else
            return 1
        end
    end
	return 1
end

function modifier_invuln_tower_based:GetAbsoluteNoDamagePhysical( params )
    if IsServer() then
        local attacker = params.attacker
        local target = params.target
        if (self:CanDoDamage(attacker, target)) then
            return 0 
        else
            return 1
        end
    end
	return 1
end

function modifier_invuln_tower_based:GetAbsoluteNoDamagePure( params )
	if IsServer() then
        local attacker = params.attacker
        local target = params.target
        if (self:CanDoDamage(attacker, target)) then
            return 0 
        else
            return 1
        end
    end
	return 1
end

function modifier_invuln_tower_based:OnAttackLanded(params)
	if IsServer() then
        local attacker = params.attacker
        local target = params.target
        if (self:CanDoDamage(attacker, target)) then
            return 0 
        else
            if target == self:GetParent() then 
                print("trying to do particle")
                self.particle_no_dmg = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect_energy.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
                ParticleManager:SetParticleControl(self.particle_no_dmg, 0, self:GetParent():GetAbsOrigin())
                --ParticleManager:SetParticleControl(self.particle_no_dmg, 1, Vector( 200, 200, 200 ))
                ParticleManager:ReleaseParticleIndex( self.particle_no_dmg )
            end
            return 1
        end
    end
	return 1
end

function modifier_invuln_tower_based:IsHidden()
	return true
end


-- HELPER FUNCTIONS
function modifier_invuln_tower_based:CanDoDamage(attacker, target)
    if target ~= nil then 
        --print("Target = " .. target:GetUnitName())
        if target ~= self:GetParent() then 
            --print("Target wasn't the boss")
            return false
        end
    else
        print("Target null")
        return false
    end
    if attacker ~= nil then
        print("Attacker = " .. attacker:GetUnitName())
        if (attacker:GetTeam() == DOTA_TEAM_GOODGUYS) and self:RadiCanAttack() then
            print("Radi can do damage")
            return true
        elseif (attacker:GetTeam() == DOTA_TEAM_BADGUYS) and self:DireCanAttack() then
            print("Dire can do damage")
            return true
        else
            print("Can't do damage")
            return false
        end
    end
    print("Can't do damage")
    return false
end

function modifier_invuln_tower_based:RadiCanAttack()
    return (Score.round4.radi.towerA == nil 
                and
                Score.round4.radi.towerB == nil)
end

function modifier_invuln_tower_based:DireCanAttack()
    return (Score.round4.dire.towerA == nil 
            and
            Score.round4.dire.towerB == nil)
end