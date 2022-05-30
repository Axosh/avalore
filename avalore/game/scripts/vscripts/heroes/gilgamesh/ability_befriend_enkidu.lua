ability_befriend_enkidu = ability_befriend_enkidu or class({})

LinkLuaModifier( "modifier_gilgameshs_sorrow", "scripts/vscripts/heroes/gilgamesh/modifier_gilgameshs_sorrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_synergy", "scripts/vscripts/heroes/gilgamesh/modifier_synergy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_synergy", "scripts/vscripts/heroes/gilgamesh/modifier_talent_synergy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_tag_team", "scripts/vscripts/heroes/gilgamesh/modifier_talent_tag_team.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_endurance", "scripts/vscripts/heroes/gilgamesh/modifier_talent_endurance.lua", LUA_MODIFIER_MOTION_NONE )

function ability_befriend_enkidu:OnSpellStart()
    if not IsServer() then return end

    print("ability_befriend_enkidu:OnSpellStart()")
    
    -- if they are re-summoning, then nuke the current Enkidu so they don't get 2
    if self.enkidu and self.enkidu:IsAlive() then
        UTIL_RemoveImmediate(self.enkidu)
    end
    -- Spawn Unit
    self.enkidu = self:SummonEnkidu()

    -- start tracking whether enkidu is alive
    if not self.sorrow_debuff then
        self.sorrow_debuff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gilgameshs_sorrow", {enkidu_ref = self.enkidu});
        (self.sorrow_debuff):UpdateEnkiduRef(self.enkidu);
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
        --print("Before: (" .. tostring(curr_location_vector.x) .. ", " .. tostring(curr_location_vector.y) .. ", " .. tostring(curr_location_vector.z) .. ")")
        UTIL_RemoveImmediate(self.enkidu)
        --print("After: (" .. tostring(curr_location_vector.x) .. ", " .. tostring(curr_location_vector.y) .. ", " .. tostring(curr_location_vector.z) .. ")")
        self.enkidu = self:SummonEnkidu(curr_location_vector)

        -- refresh to keep track of enkidu unit
        if not self.sorrow_debuff then
            self.sorrow_debuff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gilgameshs_sorrow", {enkidu_ref = self.enkidu});
            (self.sorrow_debuff):UpdateEnkiduRef(self.enkidu);
        else
            -- update enkidu ref
            (self.sorrow_debuff):UpdateEnkiduRef(self.enkidu)
        end
    end
end

function ability_befriend_enkidu:GetEnkiduRef()
    if not IsServer() then return end

    return self.enkidu
end

-- TODO: decide if we want to keep modifiers/hp/mana consistent
function ability_befriend_enkidu:SummonEnkidu(vector_location)
    if not IsServer() then return end

    local spawn_location_vector = self:GetCaster():GetAbsOrigin()
    if vector_location ~= nil then
        --print("using vector_location")
        spawn_location_vector  = vector_location
    end

    local enkidu_level = self:GetLevel()

    local unit = CreateUnitByName( "npc_avalore_enkidu" .. tostring(enkidu_level),
                                    spawn_location_vector,
                                    true,
                                    self:GetCaster(),
                                    self:GetCaster(),
                                    self:GetCaster():GetTeam())

    -- sync the Grapple Ability
    if enkidu_level > 2 and self:GetCaster():GetAbilityByIndex(1):GetLevel() > 0 then
        unit:GetAbilityByIndex(1):SetLevel(self:GetCaster():GetAbilityByIndex(1):GetLevel())
    end

    -- Spawn Effects
    --particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf
    local particle = "particles/neutral_fx/roshan_spawn.vpcf"
    local spawn_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, unit)
    ParticleManager:SetParticleControl(spawn_fx, 0, spawn_location_vector)

    -- attribute kills to hero
    unit:AddNewModifier(self:GetCaster(), self, "modifier_kill", nil)

    if self:GetCaster():HasTalent("talent_synergy") then
        unit:AddNewModifier(self:GetCaster(), self, "modifier_synergy", {is_enkidu = true})
    end

    if self:GetCaster():HasTalent("talent_endurance") then
        --print("Giving Enkidu Endurance Talent")
        unit:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("ability_gilgamesh_grapple"), "modifier_talent_endurance", {})
    end

    if self:GetCaster():HasTalent("talent_grappling_hold") then
        --print("Giving Enkidu Endurance Talent")
        unit:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("ability_gilgamesh_grapple"), "modifier_talent_grappling_hold", {})
    end

    -- give control
    unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)

    --print("Enk Ref => " .. tostring(unit))
    return unit
end