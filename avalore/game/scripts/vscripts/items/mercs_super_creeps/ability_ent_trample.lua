ability_ent_trample = class({})

LinkLuaModifier("modifier_ent_trample_passive", "items/mercs_super_creeps/ability_ent_trample.lua", LUA_MODIFIER_MOTION_NONE)

function ability_ent_trample:GetIntrinsicModifierName()
    return "modifier_ent_trample_passive"
end

-- =============================
-- INTRINSIC MODIFIER
-- =============================

modifier_ent_trample_passive = class({})

function modifier_ent_trample_passive:IsHidden() return true end
function modifier_ent_trample_passive:IsPurgable() return false end
function modifier_ent_trample_passive:IsDebuff() return false end

function modifier_ent_trample_passive:OnCreated()
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

    self.damage_per_sec = self:GetAbility():GetSpecialValueFor( "damage_per_sec")
    self.damage_radius  = self:GetAbility():GetSpecialValueFor( "damage_radius")
    self:StartIntervalThink(1)
end

function modifier_ent_trample_passive:OnIntervalThink()
    if not IsServer() then return end

    -- find enemies in radius
    local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
			self.parent:GetAbsOrigin(),
			nil,
			self.damage_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)

    -- deal damage to them
    local played_effect = false
    for _,enemy in pairs(enemies) do
        if not played_effect then
            local particle_stomp_fx = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_2022_immortal/centaur_2022_immortal_stampede_cast_gold_burst.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(particle_stomp_fx, 0, self:GetCaster():GetAbsOrigin())
            ParticleManager:SetParticleControl(particle_stomp_fx, 1, Vector(self.damage_radius, 1, 1))
            ParticleManager:SetParticleControl(particle_stomp_fx, 2, self:GetCaster():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_stomp_fx)
            played_effect = true
        end

        if not enemy:IsMagicImmune() then
            local damageTable = {   victim = enemy,
                                    attacker = self.parent,
                                    damage = self.damage_per_sec,
                                    damage_type = DAMAGE_TYPE_MAGICAL,
                                    ability = self.ability
                                }

            ApplyDamage(damageTable)
        end
    end
end