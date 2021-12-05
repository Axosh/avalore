require("references")
require(REQ_ABILITY_AOEDAMAGE)

modifier_ride_a_twister = class({})

function modifier_ride_a_twister:IsDebuff() return false end
function modifier_ride_a_twister:IsHidden() return false end
function modifier_ride_a_twister:IsPurgable() return false end

function modifier_ride_a_twister:DeclareFunctions()
    return  {
                MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
                MODIFIER_PROPERTY_AVOID_DAMAGE,
                MODIFIER_PROPERTY_OVERRIDE_ANIMATION
            }
end

function modifier_ride_a_twister:CheckState()
    return  {
                [MODIFIER_STATE_FLYING] = true
            }
end

function modifier_ride_a_twister:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    self.damage = self.ability:GetSpecialValueFor("damage_per_tick")
    self.damage_interval = self.ability:GetSpecialValueFor("damage_tick_interval")
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.block_rate = self.ability:GetSpecialValueFor("block_rate")

    self.hits_since_block = 0

    if not IsServer() then return end

    --local dummy = CreateModifierThinker(self:GetCaster(), self,	nil, {}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(),	false)
    local offset_vector = Vector(0, 0, 0)

    if self.particles == nil then
        self.particles = {}
        --particles/econ/items/invoker/invoker_ti6/invoker_tornado_ti6_base_leaves.vpcf
        --self.particles[0] = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_tornado_funnel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        --ParticleManager:SetParticleControl(self.particles[0], 5, Vector(self.radius, 0, 0))
        self.particles[0] = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal_cyclone_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        --ParticleManager:SetParticleControl(self.particles[0], 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particles[0], 5, Vector(self.radius, 0, 0))
		ParticleManager:SetParticleControlEnt(self.particles[0], 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin() - offset_vector, true)

        --self.particles[1] = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_tornado_funnel_detail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self.particles[1] = ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/cyclone_fm06_leaves.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.particles[1], 5, Vector(self.radius, 0, 0))
        --ParticleManager:SetParticleControl(self.particles[1], 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(self.particles[1], 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin() - offset_vector, true)

        self.particles[2] = ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/cyclone_fm06_dust.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.particles[2], 5, Vector(self.radius, 0, 0))
		ParticleManager:SetParticleControlEnt(self.particles[2], 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin() - offset_vector, true)

        self.particles[3] = ParticleManager:CreateParticle("particles/items_fx/cyclone_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        --ParticleManager:SetParticleControl(self.particles[3], 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particles[3], 5, Vector(self.radius, 0, 0))
		ParticleManager:SetParticleControlEnt(self.particles[3], 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin() - offset_vector, true)

        --self.particles[4] = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_cyclone.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self.particles[4] = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        --ParticleManager:SetParticleControl(self.particles[4], 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particles[4], 5, Vector(self.radius, 0, 0))
		ParticleManager:SetParticleControlEnt(self.particles[4], 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin() - offset_vector, true)
    end

    self:StartIntervalThink( self.damage_interval )
end

function modifier_ride_a_twister:OnDestroy(kv)
    if self.particles ~= nil then
        for k,particle in pairs(self.particles) do
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end
        self.particles = nil
    end
end

function modifier_ride_a_twister:OnIntervalThink()
    if IsServer() then
        PrintVector(self.caster:GetAbsOrigin(), "  Curr")

        AOEMagicDamage( self.caster,
                        self.ability,
                        self.caster:GetAbsOrigin(),
                        self.radius,
                        self.damage)

        -- clear trees
        GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin(), self.radius, true)
    end
end

function modifier_ride_a_twister:GetOverrideAnimation()
    --return ACT_DOTA_ATTACK_EVENT
    return ACT_DOTA_OVERRIDE_ABILITY_1
end

function modifier_ride_a_twister:GetModifierAvoidDamage(kv)
    if self.hits_since_block == self.block_rate then
        self.hits_since_block = 0
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self.caster, 0, nil)
        print("BLOCK")
        return 1
    else
        print("HIT")
        self.hits_since_block = self.hits_since_block + 1
        return 0
    end
end