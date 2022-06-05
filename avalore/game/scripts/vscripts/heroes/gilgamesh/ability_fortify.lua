ability_fortify = class({})

LinkLuaModifier("modifier_fortify_walls", "scripts/vscripts/heroes/gilgamesh/modifier_fortify_walls.lua", LUA_MODIFIER_MOTION_NONE )

function ability_fortify:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

function ability_fortify:CastFilterResultTarget(target)
    -- check for merc camp (technically a "creature")
    if target:GetUnitName() == "mercenary_camp" then
        return UF_SUCCESS
    end
    -- check for buildings
    return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())
end

function ability_fortify:OnSpellStart()
    if not IsServer() then return end

    self.target = self:GetCursorTarget()
    self.total_heal = self:GetSpecialValueFor("total_healing")
    self.curr_heal = 0
    self.channel_time = 0

    local particle_cast = "particles/items5_fx/repair_kit.vpcf"
    -- use bigger particle for bigger structures
    if self.target:GetUnitName() == "mercenary_camp" or self.target:GetUnitName() == OBJECTIVE_DIRE_BASE or self.target:GetUnitName() == OBJECTIVE_RADI_BASE or string.find(self.target:GetUnitName(), "rax") then
        particle_cast = "particles/items5_fx/repair_kit_ancient.vpcf"
    end
    self.repair_particle = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.target)
	ParticleManager:SetParticleControlEnt(self.repair_particle, 1, self.target, PATTACH_POINT_FOLLOW, "attach_origin", self.target:GetAbsOrigin(), true)
	--self.target:AddParticle(self.repair_particle, false, false, -1, false, false)
end

function ability_fortify:OnChannelThink(interval)
    -- print(tostring(interval)) -- seems to print out "0.033332824707031", so must be how long since last time
    if not IsServer() then return end

    local time_fraction = interval/self:GetChannelTime()
    local heal_amount = self.total_heal * time_fraction
    -- make sure we're not overhealing
    if self.curr_heal < self.total_heal then
        -- check if this one puts us over
        if (self.curr_heal + heal_amount) > self.total_heal then
            heal_amount = self.total_heal - self.curr_heal
        end

        self.target:Heal(heal_amount, self)
        SendOverheadEventMessage(self.target, OVERHEAD_ALERT_HEAL, self.target, heal_amount, self.target)
        self.curr_heal = self.curr_heal + heal_amount
        --print(tostring(self.curr_heal))
    end
    self.channel_time = self.channel_time + interval
end

function ability_fortify:OnChannelFinish(bIntrreupted)
    -- remove repair particle
    --ParticleManager:ReleaseParticleIndex(self.repair_particle)
    ParticleManager:DestroyParticle(self.repair_particle, true)
    
    if not IsServer() then return end
    -- only grant buff if channel finished successfully
    if not bIntrreupted then
        -- check for any lingering healing that wasn't finished
        local extra_heal =self.total_heal - self.curr_heal
        if extra_heal > 0 then
            self.target:Heal(extra_heal, self)
            SendOverheadEventMessage(self.target, OVERHEAD_ALERT_HEAL, self.target, extra_heal, self.target)
        end
        self.curr_heal = self.curr_heal + extra_heal
        --print(tostring(self.curr_heal))

        -- add the buff
        self.target:AddNewModifier(self:GetCaster(), self, "modifier_fortify_walls", {duration = self:GetSpecialValueFor("buff_duration")})
    end
end