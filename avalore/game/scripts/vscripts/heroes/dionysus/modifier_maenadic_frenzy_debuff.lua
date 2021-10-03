modifier_maenadic_frenzy_debuff = class({})

function modifier_maenadic_frenzy_debuff:IsHidden() return false end
function modifier_maenadic_frenzy_debuff:IsPurgable() return false end
function modifier_maenadic_frenzy_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_maenadic_frenzy_debuff:OnCreated()
    if not IsServer() then return end

    self.parent = self:GetParent()
	self.caster = self:GetCaster()
    self.attack_target = nil

    local aura_particle = ParticleManager:CreateParticle("particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient_head.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(aura_particle, 5, Vector(0, 0, 0))
	self:AddParticle(aura_particle, false, false, -1, false, false)

    local spotlight_particle = ParticleManager:CreateParticle("particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient_trail_steam.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(spotlight_particle, 5, Vector(0, 0, 0))
	self:AddParticle(spotlight_particle, false, false, -1, false, false)

    local first_target = self:FindClosestAllyToAttack()
    if first_target then
        self.attack_target = first_target;
        (self.parent):SetForceAttackTargetAlly(first_target)
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
            (self.parent):SetForceAttackTargetAlly(next_target)
        else
            (self.parent):Stop()
        end
    end
end

-- returns the closest allied target with the same debuff or returns nil
function modifier_maenadic_frenzy_debuff:FindClosestAllyToAttack()
    local caster = self:GetCaster()
    local radius = self:GetAbility():GetSpecialValueFor("frenzy_search_radius")

    local units = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)

    local target = nil
	for _,unit in pairs(units) do
		local filter = unit:FindModifierByName( 'modifier_maenadic_frenzy_debuff' )
		if filter then
            target = unit
            break
		end
	end

	return target
end