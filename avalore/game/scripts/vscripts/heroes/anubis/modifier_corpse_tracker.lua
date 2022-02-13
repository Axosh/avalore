modifier_corpse_tracker = class({})

function modifier_corpse_tracker:IsHidden() return true end
function modifier_corpse_tracker:IsPurgable() return false end
function modifier_corpse_tracker:RemoveOnDeath() return false end

function modifier_corpse_tracker:OnCreated(kv)
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.freshness = self:GetAbility():GetSpecialValueFor("corpse_freshness") -- make sure to update this when level up
    
    if not IsServer() then return end
    print("Corpse Tracker Initialized!")

    -- track: unit/entid, gametime of death, unit class?
    self.corpses = {}
    self.corpse_id = 0

    self:StartIntervalThink(FrameTime())
end

function modifier_corpse_tracker:OnIntervalThink()
    -- find nearby dead units and see if they need to be added to the collection
    -- have to do this because dota only remembers units for 4 seconds after death
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),   -- your team
                                    self:GetParent():GetAbsOrigin(),    -- your location
                                    nil,                                -- cacheUnit
                                    self.radius,                        -- radius
                                    DOTA_UNIT_TARGET_TEAM_BOTH,     -- target team filter
                                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,              -- target type filter
                                    DOTA_UNIT_TARGET_FLAG_DEAD,         -- unit target flags
                                    FIND_ANY_ORDER,                     -- find order
                                    false)                              -- can grow cache

    for _,unit in pairs(units) do
        -- double checking IsAlive because that seems to derp out
        if not unit:IsAlive() and not unit["corpse_indexed"] then
            --self.corpses[unit:GetEntityIndex()] = {}
            unit["corpse_indexed"] = true
            unit["corpse_id"] = self.corpse_id -- may need to find a way to lock this while being used/incremented
            print("[CorpseTracker] Added New Corpse(" .. tostring(self.corpse_id) .. "): " .. unit:GetUnitName()) -- .. " with index: " .. tostring(unit:GetEntityIndex()))
            self.corpse_id = self.corpse_id + 1

            self.corpses[unit["corpse_id"]] = {}
            self.corpses[unit["corpse_id"]]["gametime"] = GameRules:GetGameTime()--{"gametime" =GameRules:GetGameTime(), unit:GetUnitName()}
            self.corpses[unit["corpse_id"]]["unitname"] = unit:GetUnitName()
            self.corpses[unit["corpse_id"]]["location"] = unit:GetAbsOrigin()
            --self.corpses[unit]["corpse_id"] = unit["corpse_id"]
            --PrintTable(unit)
        end
    end

    -- prune corpses that are too old
    local temp = {}
    for id,unitinfo in pairs(self.corpses) do
        if (GameRules:GetGameTime() - unitinfo["gametime"]) < self.freshness then
            temp[id] = {}
            temp[id]["gametime"] = unitinfo["gametime"]
            temp[id]["unitname"] = unitinfo["unitname"]
            temp[id]["location"] = unitinfo["location"]
            --temp[unit]["corpse_id"] = unitinfo["corpse_id"]
        end
    end

    self.corpses = temp
end

-- return a clone, not sure if there will be concurrency issues with the way the thinker works
-- TODO: might need to add some sort of lock to the table while processing
function modifier_corpse_tracker:GetCorpses()
    local result = {}

    for unit,unitinfo in pairs(self.corpses) do
        result[unit] = {}
        result[unit]["gametime"] = unitinfo["gametime"]
        result[unit]["unitname"] = unitinfo["unitname"]
        result[unit]["location"] = unitinfo["location"]
        result[unit]["corpse_id"] = unitinfo["corpse_id"]
    end
    
    return result
end