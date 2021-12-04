require("references")
require(REQ_ABILITY_AOEDAMAGE)

modifier_ride_a_twister = class({})

function modifier_ride_a_twister:IsDebuff() return false end
function modifier_ride_a_twister:IsHidden() return false end
function modifier_ride_a_twister:IsPurgable() return false end

function modifier_ride_a_twister:DeclareFunctions()
    return  {
                MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
                MODIFIER_PROPERTY_AVOID_DAMAGE
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

    if self.particles == nil then
        self.particles = {}
        self.particles[0] = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_tornado_funnel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        --ParticleManager:SetParticleControl(self.particles[0], 5, Vector(self.radius, 0, 0))
        ParticleManager:SetParticleControl(self.particles[0], 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(self.particles[0], 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)

        --self.particles[1] = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_tornado_funnel_detail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        --ParticleManager:SetParticleControl(self.particles[1], 5, Vector(self.radius, 0, 0))
    end
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
        AOEMagicDamage( self.caster,
                        self.ability,
                        self.caster:GetAbsOrigin(),
                        self.radius,
                        self.damage)
    end
end

function modifier_ride_a_twister:GetOverrideAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_1
end

function modifier_ride_a_twister:GetModifierAvoidDamage(kv)
    if self.hits_since_block == self.block_rate then
        self.hits_since_block = 0
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self.caster, 0, nil)
        return 1
    else
        self.hits_since_block = self.hits_since_block + 1
        return 0
    end
end