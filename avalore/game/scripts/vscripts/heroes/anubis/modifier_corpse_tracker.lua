modifier_corpse_tracker = class({})

function modifier_corpse_tracker:IsHidden() return true end
function modifier_corpse_tracker:IsPurgable() return false end
function modifier_corpse_tracker:RemoveOnDeath() return false end

function modifier_corpse_tracker:OnCreated(kv)
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.freshness = self:GetAbility():GetSpecialValueFor("corpse_freshness") -- make sure to update this when level up
    
    if not IsServer() then return end

    -- track: unit/entid, gametime of death, unit class?
    self.corpses = {}

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
                                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC,              -- target type filter
                                    DOTA_UNIT_TARGET_FLAG_DEAD,         -- unit target flags
                                    FIND_ANY_ORDER,                     -- find order
                                    false)                              -- can grow cache

    for _,unit in pairs(units) do
        if not self.corpses[unit] then
            self.corpses[unit] = {GameRules:GetGameTime(), unit:GetUnitName()}
        end
    end

    -- prune corpses that are too old
    local temp = {}
    for unit,unitinfo in pairs(self.corpses) do
        for gametime,unitname in pairs(unitinfo) do
            if (GameRules:GetGameTime() - gametime) < self.freshness then
                temp[unit] = {gametime, unitname}
            end
        end
    end

    self.corpses = temp
end