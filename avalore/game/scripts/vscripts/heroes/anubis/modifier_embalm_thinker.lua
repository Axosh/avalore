modifier_embalm_thinker = class({})

function modifier_embalm_thinker:IsPurgable()	return false end
function modifier_embalm_thinker:IsDebuff() return false end

function modifier_embalm_thinker:OnCreated(kv)
    if not IsServer() then return end
    --PrintTable(kv)

    self.corpse_tracker = self:GetCaster():FindModifierByName("modifier_corpse_tracker")
    self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
    self.resurrected = {}

    self:StartIntervalThink(self.tick_interval)
end

function modifier_embalm_thinker:OnIntervalThink()
    if not IsServer() then return end

    local corpses = self.corpse_tracker:GetCorpses()

    local corpse_spawn_callback = function(unit)
        unit:SetRenderColor(0,255,0) --green
        unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), false ) -- (playerID, bSkipAdjustingPosition)
    end

    for unit,unitinfo in pairs(corpses) do
        -- check that we haven't already resurrected this one
        if not self.resurrected[unit] then
            -- check that its in range
            if DistanceBetweenVectors(unitinfo["location"], self:GetCaster():GetAbsOrigin()) <= self:GetAbility():GetSpecialValueFor("radius") then
                table.insert(self.resurrected, unit)
                CreateUnitByNameAsync(  unitinfo["unitname"], 
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