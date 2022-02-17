modifier_embalm_thinker = class({})

function modifier_embalm_thinker:IsPurgable()	return false end
function modifier_embalm_thinker:IsDebuff() return false end

function modifier_embalm_thinker:OnCreated(kv)
    if not IsServer() then return end
    --PrintTable(kv)

    self.corpse_tracker = self:GetCaster():FindModifierByName("modifier_corpse_tracker")
    self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
    self.caster_id = self:GetCaster():GetPlayerID()
    self.resurrected = {}

    local corpses = self.corpse_tracker:GetCorpses()
    print("Corpses At OnCreated Time:")
    print("=========================================================")
    PrintTable(corpses)
    print("=========================================================")

    self:StartIntervalThink(self.tick_interval)
end

function modifier_embalm_thinker:OnIntervalThink()
    if not IsServer() then return end

    local corpses = self.corpse_tracker:GetCorpses()
    -- print("=========================================================")
    -- PrintTable(corpses)
    -- print("=========================================================")
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    PrintTable(self.resurrected)
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    local corpse_spawn_callback = function(unit)
        unit:SetRenderColor(0,255,0) --green
        unit:SetControllableByPlayer(self.caster_id, false ) -- (playerID, bSkipAdjustingPosition)
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