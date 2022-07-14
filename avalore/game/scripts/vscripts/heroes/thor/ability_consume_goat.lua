ability_consume_goat = class({})

LinkLuaModifier("modifier_consume_goat", "heroes/thor/modifier_consume_goat.lua", LUA_MODIFIER_MOTION_NONE)

function ability_consume_goat:CastFilterResult()
    local goat_count = self:GetCaster():FindModifierByName("modifier_toothgnashers_counter")

    if goat_count and goat_count:GetStackCount() > 0 then
        return UF_SUCCESS
    else
        return UF_FAIL_CUSTOM
    end
end

function ability_consume_goat:GetCustomCastError()
    return "DOTA_HUD_Error_no_goats"
end


function ability_consume_goat:OnSpellStart()
    local caster = self:GetCaster()

    if not IsServer() then return end
    local goat_count = caster:FindModifierByName("modifier_toothgnashers_counter")

    if goat_count and goat_count:GetStackCount() > 0 then
        self.modifier = caster:AddNewModifier(caster, self, "modifier_consume_goat", {duration = self:GetChannelTime()})
        goat_count:DecrementStackCount()

        if self:GetCaster():HasTalent("talent_shared_sustenance") then
            self.radius = self:GetCaster():FindTalentValue("talent_shared_sustenance", "heal_radius")
            self.mainParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
            ParticleManager:SetParticleControlEnt(self.mainParticle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetCaster():GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(self.mainParticle, 1, Vector( self.radius, self.radius, self.radius ) )
            ParticleManager:SetParticleControlEnt(self.mainParticle, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetCaster():GetAbsOrigin(), true)
        end
    else
        self:EndCooldown()
    end
end

function ability_consume_goat:OnChannelFinish(bInstrrupted)
    if self.modifier then
        self.modifier:Destroy()
        self.modifier = nil
    end

    if self.mainParticle then
        ParticleManager:DestroyParticle(self.mainParticle, false)
        ParticleManager:ReleaseParticleIndex(self.mainParticle)
    end
end