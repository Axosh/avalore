modifier_avalore_sent_ward = class({})


function modifier_avalore_sent_ward:IsHidden() return true end
function modifier_avalore_sent_ward:IsPurgable() return false end

function modifier_avalore_sent_ward:OnCreated(kv)
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.particle = ParticleManager:CreateParticle("particles/econ/wards/fall20_cauldron_ward/fall20_cauldron_ward_sentry_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.particle, 1, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 1, self.caster:GetAbsOrigin())
end

function modifier_avalore_sent_ward:DeclareFunctions()
    return { MODIFIER_PROPERTY_MODEL_CHANGE }
end

-- function modifier_avalore_sent_ward:GetEffect()
--     return "particles/econ/wards/portal/ward_portal_core/ward_portal_eye_sentry.vpcf"
--     --return "particles/econ/wards/fall20_cauldron_ward/fall20_cauldron_ward_sentry_ambient.vpcf"
--     --return "particles/econ/wards/the_watcher_below/watcher_below/watcher_below_sentry_ambient.vpcf"
-- end

-- function modifier_avalore_sent_ward:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
--     --return PATTACH_OVERHEAD_FOLLOW 
-- end

-- Note: I think this only works because the model gets precached in npc_units_custom.txt
function modifier_avalore_sent_ward:GetModifierModelChange()
    return "models/items/wards/phoenix_ward/phoenix_ward.vmdl"
end

function modifier_avalore_sent_ward:OnDestroy(kv)
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)
end