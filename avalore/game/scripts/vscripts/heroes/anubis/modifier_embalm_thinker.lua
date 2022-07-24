modifier_embalm_thinker = class({})

LinkLuaModifier("modifier_talent_embalming_mastery",    		  "scripts/vscripts/heroes/anubis/modifier_talent_embalming_mastery.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_embalm_thinker:IsPurgable()	return false end
function modifier_embalm_thinker:IsDebuff() return false end

function modifier_embalm_thinker:OnCreated(kv)
    if not IsServer() then return end
    --PrintTable(kv)

    self.corpse_tracker = self:GetCaster():FindModifierByName("modifier_corpse_tracker")
    self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
    self.mummy_duration = self:GetAbility():GetSpecialValueFor("mummy_duration")
    self.caster_id = self:GetCaster():GetPlayerID()
    self.resurrected = {}

    local corpses = self.corpse_tracker:GetCorpses()
    -- print("Corpses At OnCreated Time:")
    -- print("=========================================================")
    -- PrintTable(corpses)
    -- print("=========================================================")

    self:StartIntervalThink(self.tick_interval)
end

function modifier_embalm_thinker:OnIntervalThink()
    if not IsServer() then return end

    local corpses = self.corpse_tracker:GetCorpses()
    -- print("=========================================================")
    -- PrintTable(corpses)
    -- print("=========================================================")
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- PrintTable(self.resurrected)
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    local particle_spawn = "particles/units/heroes/hero_undying/undying_zombie_spawn.vpcf"
    local corpse_spawn_callback = function(unit)
        unit:SetRenderColor(0,255,0) --green
        unit:SetControllableByPlayer(self.caster_id, false ) -- (playerID, bSkipAdjustingPosition)
        unit:AddNewModifier(self:GetCaster(), nil, "modifier_mummy", {duration = self.mummy_duration + self:GetCaster():FindTalentValue("talent_embalming_mastery", "bonus_duration")})

        local particle_cast_fx = ParticleManager:CreateParticle(particle_spawn, PATTACH_ABSORIGIN, unit)
        ParticleManager:SetParticleControl(particle_cast_fx, 0 , unit:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_cast_fx)
    end

    for id,unitinfo in pairs(corpses) do
        -- check that we haven't already resurrected this one
        if not self.resurrected[id] then
            -- check that its in range
            if DistanceBetweenVectors(unitinfo["location"], self:GetCaster():GetAbsOrigin()) <= self:GetAbility():GetSpecialValueFor("radius") then
                print("[Embalm Thinker] Pushing ID: " .. tostring(id))
                --table.insert(self.resurrected, id) -- don't push this way, it generates its own indicies
                self.resurrected[id] = unitinfo
                local unit_name = unitinfo["unitname"]
                if string.find(unit_name, "npc_avalore_creep_melee") then
                    unit_name = "anubis_mummy_melee"
                elseif string.find(unit_name, "npc_avalore_creep_ranged") then
                    unit_name = "anubis_mummy_ranged"
                end

                CreateUnitByNameAsync(  unit_name, 
                                        unitinfo["location"], 
                                        true, 
                                        self:GetCaster(), 
                                        self:GetCaster(), 
                                        self:GetCaster():GetTeamNumber(),
                                        corpse_spawn_callback)
            end
        end
    end
end