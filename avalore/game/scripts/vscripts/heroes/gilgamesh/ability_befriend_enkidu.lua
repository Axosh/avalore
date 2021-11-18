ability_befriend_enkidu = ability_befriend_enkidu or class({})

LinkLuaModifier( "modifier_gilgameshs_sorrow", "scripts/vscripts/heroes/gilgamesh/modifier_gilgameshs_sorrow.lua", LUA_MODIFIER_MOTION_NONE )

function ability_befriend_enkidu:OnSpellStart()
    if not IsServer() then return end

    print("ability_befriend_enkidu:OnSpellStart()")
    -- Spawn Unit
    self.enkidu = self:SummonEnkidu()

    print("ability_befriend_enkidu:OnSpellStart()")

    -- start tracking whether enkidu is alive
    if not self.sorrow_debuff then
        self.sorrow_debuff = self:GetCaster():AddNewModifier(nil, nil, "modifier_gilgameshs_sorrow", {enkidu_ref = self.enkidu})
    else
        -- update enkidu ref
        (self.sorrow_debuff):UpdateEnkiduRef(self.enkidu)
    end
end

function ability_befriend_enkidu:OnUpgrade()
    if not IsServer() then return end

    print("ability_befriend_enkidu:OnUpgrade()")

    if self.enkidu and self.enkidu:IsAlive() then
        -- remove the old model without drawing
        local curr_location_vector = Vector(self.enkidu:GetAbsOrigin().x, self.enkidu:GetAbsOrigin().y, self.enkidu:GetAbsOrigin().z)
        print("Before: (" .. tostring(curr_location_vector.x) .. ", " .. tostring(curr_location_vector.y) .. ", " .. tostring(curr_location_vector.z) .. ")")
        UTIL_RemoveImmediate(self.enkidu)
        print("After: (" .. tostring(curr_location_vector.x) .. ", " .. tostring(curr_location_vector.y) .. ", " .. tostring(curr_location_vector.z) .. ")")
        self.enkidu = self:SummonEnkidu(curr_location_vector)

        -- refresh to keep track of enkidu unit
        if not self.sorrow_debuff then
            self.sorrow_debuff = self:GetCaster():AddNewModifier(nil, nil, "modifier_gilgameshs_sorrow", {enkidu_ref = self.enkidu})
        else
            -- update enkidu ref
            (self.sorrow_debuff):UpdateEnkiduRef(self.enkidu)
        end
    end
end

-- TODO: decide if we want to keep modifiers/hp/mana consistent
function ability_befriend_enkidu:SummonEnkidu(vector_location)
    if not IsServer() then return end

    local spawn_location_vector = self:GetCaster():GetAbsOrigin()
    if vector_location ~= nil then
        print("using vector_location")
        spawn_location_vector  = vector_location
    end

    local enkidu_level = self:GetLevel()

    local unit = CreateUnitByName( "npc_avalore_enkidu" .. tostring(enkidu_level),
                                    spawn_location_vector,
                                    true,
                                    self:GetCaster(),
                                    self:GetCaster(),
                                    self:GetCaster():GetTeam())

    -- Spawn Effects
    --particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf
    local particle = "particles/neutral_fx/roshan_spawn.vpcf"
    local spawn_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, unit)
    ParticleManager:SetParticleControl(spawn_fx, 0, spawn_location_vector)

    -- attribute kills to hero
    unit:AddNewModifier(self:GetCaster(), self, "modifier_kill", nil)

    -- give control
    unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)

    return unit
end