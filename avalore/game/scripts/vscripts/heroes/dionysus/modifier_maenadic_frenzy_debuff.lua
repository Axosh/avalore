modifier_maenadic_frenzy_debuff = class({})

function modifier_maenadic_frenzy_debuff:IsHidden() return false end
function modifier_maenadic_frenzy_debuff:IsPurgable() return false end
function modifier_maenadic_frenzy_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_maenadic_frenzy_debuff:CheckState()
    return {
        [MODIFIER_STATE_CANNOT_TARGET_ENEMIES] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_ALLIES] = true,
        [MODIFIER_STATE_CANNOT_TARGET_ENEMIES] = true
    }
end

function modifier_maenadic_frenzy_debuff:OnCreated()
    if self:GetCaster():HasTalent("talent_limit_break") then
        self.as_amp = self:GetCaster():FindTalentValue("talent_limit_break", "bonus_attack_speed")
    else
        self.as_amp = 0
    end

    if not IsServer() then return end

    self.parent = self:GetParent()
	self.caster = self:GetCaster()
    self.attack_target = nil

    -- 0 or value
    self.duration_extension_per_death = self:GetCaster():FindTalentValue("talent_ritual_madness", "duration_extension_per_death")
    
    --print("as amp = " .. tostring(self.as_amp))

    local aura_particle = ParticleManager:CreateParticle("particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient_head.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(aura_particle, 5, Vector(0, 0, 0))
	self:AddParticle(aura_particle, false, false, -1, false, false)

    local spotlight_particle = ParticleManager:CreateParticle("particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient_trail_steam.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(spotlight_particle, 5, Vector(0, 0, 0))
	self:AddParticle(spotlight_particle, false, false, -1, false, false)

    local first_target = self:FindClosestAllyToAttack()
    if first_target then
        self.attack_target = first_target;
        (self.parent):FaceTowards(first_target:GetAbsOrigin());
        (self.parent):MoveToTargetToAttack(first_target);
        (self.parent):SetForceAttackTargetAlly(first_target);
    else
        (self.parent):Stop()
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_maenadic_frenzy_debuff:OnIntervalThink()
    if not IsServer() then return end

    -- if target is dead or we don't have one, find a new one
    if (not self.attack_target) or (not (self.attack_target):IsAlive()) then
        local next_target = self:FindClosestAllyToAttack()
        if next_target then
            self.attack_target = next_target;
            (self.parent):FaceTowards(self.attack_target:GetAbsOrigin());
            (self.parent):MoveToTargetToAttack(self.attack_target);
            (self.parent):SetForceAttackTargetAlly(self.attack_target);
        else
            (self.parent):Stop()
        end
    -- else
    --     (self.parent):FaceTowards(self.attack_target:GetAbsOrigin());
    --     (self.parent):SetForceAttackTargetAlly(self.attack_target);
    end
end

function modifier_maenadic_frenzy_debuff:DeclareFunctions()
    return {
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
                MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
                MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
                --MODIFIER_EVENT_ON_DEATH,
                MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
            }
end

-- amp is calculated in the OnCreated and can be modified by a Talent
function modifier_maenadic_frenzy_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.as_amp
end

-- Only Allied units should be able to deal damage during this (similar to Winter Wyvern ult)
function modifier_maenadic_frenzy_debuff:GetAbsoluteNoDamagePhysical(event)
    if event.attacker and event.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
        return 0
    else
        return 1
    end
end
function modifier_maenadic_frenzy_debuff:GetAbsoluteNoDamageMagical(event)
    if event.attacker and event.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
        return 0
    else
        return 1
    end
end
function modifier_maenadic_frenzy_debuff:GetAbsoluteNoDamagePure(event)
    if event.attacker and event.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
        return 0
    else
        return 1
    end
end

-- returns the closest allied target with the same debuff or returns nil
function modifier_maenadic_frenzy_debuff:FindClosestAllyToAttack()
    --local caster = self:GetCaster()
    local radius = self:GetAbility():GetSpecialValueFor("radius")--self:GetAbility():GetSpecialValueFor("frenzy_search_radius")
    --print("Search Radi = " .. tostring(radius))

    local units = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self:GetCaster():GetOrigin(), --self:GetParent():GetAbsOrigin(), --caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		self:GetParent():GetTeamNumber(),	-- int, team filter
        DOTA_UNIT_TARGET_ALL ,
		--DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)

    local target = nil
    --local count = 0
	for _,unit in pairs(units) do
        --count = count + 1
        --print("Checking unit => " .. unit:GetUnitName())
		local filter = unit:FindModifierByName( 'modifier_maenadic_frenzy_debuff' )
		if filter and unit ~= self:GetParent() then
            target = unit
            break
		end
	end
    local target_debug = "nil"
    if target then
        target_debug = target:GetUnitName()
    end
    --print("Looked at " .. tostring(count) .. " nearby units; " .. self:GetParent():GetUnitName() .. " targeting " .. target_debug)

	return target
end

function modifier_maenadic_frenzy_debuff:OnDestroy()
    if not IsServer() then return end

	(self.parent):SetForceAttackTargetAlly(nil)
end

--function modifier_maenadic_frenzy_debuff:OnDeath(kv)
function modifier_maenadic_frenzy_debuff:OnTakeDamageKillCredit(kv)
    if not IsServer() then return end
    -- filter for the unit that has this modifier
    if not kv.target == self:GetParent() then return end
    -- don't do anything if illusion
    --if kv.target:IsIllusion() then return nil end


    -- make sure they're taking lethal damage
    -- print("Unit Health: " .. tostring(self:GetParent():GetHealth()))
    -- print("Taking Damage: " .. tostring(kv.damage))
    if self:GetParent():GetHealth() - kv.damage > 0 then return end
    
    -- make sure they have the debuff
    if not kv.target:FindModifierByName(self:GetName()) then return end

    -- give kill credit to Dionysus
    self:GetParent():Kill(self:GetAbility(), self:GetCaster())

    -- if player has talent, then also extend the duration of the ability
    if self:GetCaster():HasTalent("talent_ritual_madness") then
        local aura_mod = self:GetCaster():FindModifierByName("modifier_maenadic_frenzy_aura")
        -- check for race condition where the debuff lingers longer than the aura is active
        if aura_mod then
            print("Unit died under Maenadic Frenzy - Extending Time")
            print("Original Time Left: " .. tostring(aura_mod:GetRemainingTime()))
            aura_mod:SetDuration(aura_mod:GetRemainingTime() + self.duration_extension_per_death, true)
            print("New Time Left: " .. tostring(aura_mod:GetRemainingTime()))
        end
        
    end

    -- if self:GetCaster():HasTalent("talent_ritual_madness") then
    --     for _,ent in pairs(Entities:FindAllInSphere(self:GetCaster():GetAbsOrigin(), self:GetAbility():GetCastRange())) do
    --         if ent:IsBaseNPC() then
    --             local mod = ent:FindModifierByName(self:GetName())
    --             if mod then
    --                 mod:SetDuration(mod:GetRemainingTime() + self.duration_extension_per_death, true)
    --             end
    --         end
    --     end
    -- end
end