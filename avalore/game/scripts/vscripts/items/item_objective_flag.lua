require("references")
require(REQ_CONSTANTS)
require(REQ_SPAWNERS)
require(REQ_SCORE)
require(REQ_UTIL)

-----------------------------------------------------------------------------------------------------------
--	Item Definitions
-----------------------------------------------------------------------------------------------------------
item_objective_flag = item_objective_flag or class({})
item_avalore_flag_a = item_avalore_flag_a or class({})
item_avalore_flag_b = item_avalore_flag_b or class({})
item_avalore_flag_c = item_avalore_flag_c or class({})
item_avalore_flag_d = item_avalore_flag_d or class({})
item_avalore_flag_e = item_avalore_flag_e or class({})

LinkLuaModifier( MODIFIER_FLAG_CARRY_NAME, MODIFIER_ITEM_FLAG_CARRY, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( MODIFIER_FLAG_MORALE_NAME, MODIFIER_FLAG_MORALE, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( MODIFIER_FLAG_AGILITY_NAME, MODIFIER_FLAG_AGILITY, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( MODIFIER_FLAG_ARCANE_NAME, MODIFIER_FLAG_ARCANE, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( MODIFIER_FLAG_REGROWTH_NAME, MODIFIER_FLAG_REGROWTH, LUA_MODIFIER_MOTION_NONE )

function item_objective_flag:GetIntrinsicModifierName()
     return MODIFIER_FLAG_CARRY_NAME end

function item_avalore_flag_a:GetIntrinsicModifierName()
    return MODIFIER_FLAG_CARRY_NAME end

function item_avalore_flag_a:CanUnitPickUp(unit)
    return unit:IsHero()
end

-- Drop currently held flag on death
function item_avalore_flag_a:OnOwnerDied()
    print("Flag Owner Died")
    local flag = HasFlagInInventory(self:GetOwner())
    if flag ~= nil then
        local hItem = self:GetOwner():FindItemInInventory(flag)
        self:GetOwner():DropItemAtPositionImmediate(hItem, self:GetOwner():GetOrigin())
    end
end

function item_avalore_flag_b:GetIntrinsicModifierName()
    return MODIFIER_FLAG_CARRY_NAME end

function item_avalore_flag_b:CanUnitPickUp(unit)
    return unit:IsHero()
end

-- Drop currently held flag on death
function item_avalore_flag_b:OnOwnerDied()
    print("Flag Owner Died")
    local flag = HasFlagInInventory(self:GetOwner())
    if flag ~= nil then
        local hItem = self:GetOwner():FindItemInInventory(flag)
        self:GetOwner():DropItemAtPositionImmediate(hItem, self:GetOwner():GetOrigin())
    end
end

function item_avalore_flag_c:GetIntrinsicModifierName()
    return MODIFIER_FLAG_CARRY_NAME end

function item_avalore_flag_c:CanUnitPickUp(unit)
    return unit:IsHero()
end

-- Drop currently held flag on death
function item_avalore_flag_c:OnOwnerDied()
    print("Flag Owner Died")
    local flag = HasFlagInInventory(self:GetOwner())
    if flag ~= nil then
        local hItem = self:GetOwner():FindItemInInventory(flag)
        self:GetOwner():DropItemAtPositionImmediate(hItem, self:GetOwner():GetOrigin())
    end
end

function item_avalore_flag_d:GetIntrinsicModifierName()
    return MODIFIER_FLAG_CARRY_NAME end

function item_avalore_flag_d:CanUnitPickUp(unit)
    return unit:IsHero()
end

-- Drop currently held flag on death
function item_avalore_flag_d:OnOwnerDied()
    print("Flag Owner Died")
    local flag = HasFlagInInventory(self:GetOwner())
    if flag ~= nil then
        local hItem = self:GetOwner():FindItemInInventory(flag)
        self:GetOwner():DropItemAtPositionImmediate(hItem, self:GetOwner():GetOrigin())
    end
end

function item_avalore_flag_e:GetIntrinsicModifierName()
    return MODIFIER_FLAG_CARRY_NAME end

function item_avalore_flag_e:CanUnitPickUp(unit)
    return unit:IsHero()
end

-- Drop currently held flag on death
function item_avalore_flag_e:OnOwnerDied()
    print("Flag Owner Died")
    local flag = HasFlagInInventory(self:GetOwner())
    if flag ~= nil then
        local hItem = self:GetOwner():FindItemInInventory(flag)
        self:GetOwner():DropItemAtPositionImmediate(hItem, self:GetOwner():GetOrigin())
    end
end

-----------------------------------------------------------------------------------------------------------
--	Intrinsic modifier definition
-----------------------------------------------------------------------------------------------------------

if modifier_item_flag_carry == nil then modifier_item_flag_carry = class({}) end

function modifier_item_flag_carry:IsHidden() return false end
function modifier_item_flag_carry:IsDebuff() return true end
function modifier_item_flag_carry:IsPurgable() return false end

function modifier_item_flag_carry:OnCreated(keys)
    if IsServer() then
        print("modifier_item_flag_carry:OnCreated()")
        local ent_flag = nil

        --local sFlag = HasFlagInInventory(self:GetParent())
        local sFlag = self:GetAbility():GetName() -- this will be one of the item_avalore_flag_abcde items

        local flag_carry_mods = self:GetParent():FindAllModifiersByName(MODIFIER_FLAG_CARRY_NAME)
        --check to see if they already have a flag (i.e. 2 instances of this modifier since it's already been applied here)
        print("table count = " .. TableCount(flag_carry_mods))
        if TableCount(flag_carry_mods) > 1 then
            print("already had modifier")
            --PrintTable(flag_carry_mods)
            for _,mod in pairs(flag_carry_mods) do
                print("destroying old carry mod")
                mod:Destroy()
            end
        end
        
        local particleFx = ""
        if sFlag == OBJECTIVE_FLAG_ITEM_A then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_A})
            particleFx = "particles/units/heroes/hero_legion_commander/legion_commander_press_base.vpcf"
            RenderFlagMorale(ent_flag)
        elseif sFlag == OBJECTIVE_FLAG_ITEM_B then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_B})
            particleFx = "particles/units/heroes/hero_legion_commander/legion_commander_press_base.vpcf"
            RenderFlagMorale(ent_flag)
        elseif sFlag == OBJECTIVE_FLAG_ITEM_C then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_C})
            particleFx = "particles/econ/items/invoker/invoker_ti7/invoker_ti7_alacrity_buff_arc_pnt.vpcf"
            RenderFlagAgility(ent_flag)
        elseif sFlag == OBJECTIVE_FLAG_ITEM_D then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_D})
            particleFx = "particles/items5_fx/elixer_mana.vpcf"
            RenderFlagArcane(ent_flag)
        elseif sFlag == OBJECTIVE_FLAG_ITEM_E then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_E})
            particleFx = "particles/econ/events/spring_2021/fountain_regen_spring_2021_bokeh.vpcf"
            --particleFx = "particles/econ/events/fall_major_2016/cyclone_fm06_leaves.vpcf"
            RenderFlagRegrowth(ent_flag)
        end
        --SetFlagForward(ent_flag)

        local flag_letter = string.sub(sFlag, -1) -- get the last letter

        ent_flag:FollowEntity(self:GetParent(), false)
        self.entFollow = ent_flag
        --ent_flag:SetForwardVector(Vector(1, 0, 0))
        --ent_flag:SetForwardVector(Vector(-1, 0, 0))

        -- print("Owner = > " .. self:GetParent():GetName())
        local hero_forward = self:GetParent():GetForwardVector()
        --local flag_forward = RotatePosition(hero_forward, QAngle(0, 90, 0), )
        local flag_forward = RotatePosition(Vector(0,0,0), QAngle(0, 90, 0), hero_forward)
        ent_flag:SetForwardVector(flag_forward)
        -- local xRot = math.sin(90)
        -- local yRot = math.cos(90)
        -- ent_flag:SetForwardVector(Vector(hero_forward.x + xRot, hero_forward.y + yRot, hero_forward.z))
        -- PrintVector(self:GetParent():GetForwardVector(), "Hero Forward Vect")
        -- PrintVector(ent_flag:GetForwardVector(), "Flag Forward Vect")
        -- print("Angle Between = " .. tostring(AngleBetween2DVectors(ent_flag:GetForwardVector(), hero_forward)))
        
        if self.particle == nil then
            self.particle = ParticleManager:CreateParticle(OBJECTIVE_FLAG_PARTICLE_CAPTURE, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(self.particle, 0, Vector(0, 0, 0))
        end

        if self.flag_particle == nil then
            self.flag_particle = ParticleManager:CreateParticle(particleFx, PATTACH_ABSORIGIN_FOLLOW, ent_flag)
            ParticleManager:SetParticleControl(self.flag_particle, 0, Vector(0, 0, 0))
        end

        local mod_name = GetFlagModifierNameFromIdentifier(flag_letter)

        --remove modifiers from previous team
        if Score.flags[flag_letter].inBase and Score.flags[flag_letter].currTeamPossession ~= DOTA_TEAM_NOTEAM then
            for playerID = 0, DOTA_MAX_PLAYERS do
                if PlayerResource:IsValidPlayerID(playerID) then
                    if not PlayerResource:IsBroadcaster(playerID) then
                        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                        if hero:GetTeam() == Score.flags[flag_letter].currTeamPossession then
                            print("Removing Modifier " .. mod_name .. " from " .. hero:GetName())
                            local morale_buff = hero:FindModifierByName(MODIFIER_FLAG_MORALE_NAME)
                            if (mod_name == MODIFIER_FLAG_MORALE_NAME and morale_buff and morale_buff:GetStackCount() > 1) then
                                print("Decrementing stack")
                                morale_buff:DecrementStackCount()
                            else
                                hero:RemoveModifierByName(mod_name)
                            end
                        end
                    end -- end IsBroadcaster
                end -- end IsValidPlayerID
            end -- end for-loop
        end

        -- flag has been picked up, so update status
        Score.flags[flag_letter].inBase = false
    end -- end IsServer()
end -- end: function modifier_item_flag_carry:OnCreated(keys)

-- function modifier_item_flag_carry:OnRefresh(keys)
--     print("modifier_item_flag_carry:OnRefresh()")
--     PrintTable(keys)
--     local flag_carry_mods = self:GetParent():FindAllModifiersByName(MODIFIER_FLAG_CARRY_NAME)
--     --check to see if they already have a flag (i.e. 2 instances of this modifier since it's already been applied here)
--     print("table count = " .. TableCount(flag_carry_mods))
--     if TableCount(flag_carry_mods) > 1 then
--         PrintTable(flag_carry_mods)
--     end
-- end

function modifier_item_flag_carry:OnDestroy(keys)
    print("OnDestroy for " ..  MODIFIER_FLAG_CARRY_NAME )
    if self.particle ~= nil then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
		self.particle = nil
    end

    if self.flag_particle ~= nil then
		ParticleManager:DestroyParticle(self.flag_particle, false)
		ParticleManager:ReleaseParticleIndex(self.flag_particle)
		self.flag_particle = nil
    end

    if self.entFollow ~= nil then
        self.entFollow:RemoveSelf()
        self.entFollow = nil
    end
end

function modifier_item_flag_carry:GetTexture()
    return "naga_siren_ensnare"
end

-- Triggers

--trigger names
-- trigger_radi_flag_botl
-- trigger_radi_flag_topl
--trigger_radi_flag_top


-- NOTE: probably need to do some detection here to see if the hero is trying 
--       to steal or capture the flag
function FlagTrigger_OnStartTouch(trigger)
    local triggerName = thisEntity:GetName()
	if trigger.activator ~= nil and trigger.caller ~= nil then
		local activator_entindex = trigger.activator:GetEntityIndex()
		local caller_entindex = trigger.caller:GetEntityIndex()
        local NPC = EntIndexToHScript( activator_entindex )
        local TriggerEntity = EntIndexToHScript( caller_entindex )

        print("NPC Team = " .. NPC:GetTeam())
        --print("Trigger Team = " .. TriggerEntity:GetTeam())
        local triggerSide = nil
        if string.find(TriggerEntity:GetName(), "radi") then
            triggerSide = DOTA_TEAM_GOODGUYS
        elseif string.find(TriggerEntity:GetName(), "dire") then
            triggerSide = DOTA_TEAM_BADGUYS
        end
        
        -- don't do anything unless this is a Player Owned Hero and on one of their team's capture points
        if NPC ~= nil and NPC:IsHero() and NPC:IsOwnedByAnyPlayer() and NPC:GetTeam() == triggerSide then
            local flag = HasFlagInInventory(NPC)
            if flag ~= nil then
                local hItem = NPC:FindItemInInventory(flag)
                local nearestFlagSpawner = nil
                local location = nil
                if string.find(TriggerEntity:GetName(), "radi") then
                    location = SanitizeLocation(TriggerEntity:GetName():gsub("%trigger_radi_flag_", ""))
                    nearestFlagSpawner = Spawners.RadiFlagBases[location]
                elseif string.find(TriggerEntity:GetName(), "dire") then
                    location = SanitizeLocation(TriggerEntity:GetName():gsub("%trigger_dire_flag_", ""))
                    nearestFlagSpawner = Spawners.DireFlagBases[location]
                end
                --print("At spawner " .. nearestFlagSpawner:GetName())

                local flag_letter = string.sub(hItem:GetName(), -1) -- get the last letter

                -- make sure we can put the flag here
                print("Score.flags")
                print("===========")
                for key, value in pairs(Score.flags) do
                    print(tostring(key) .. " || " .. tostring(value))
                    print(Score.flags[key].location)
                    if(Score.flags[key].currTeamPossession == NPC:GetTeam() and Score.flags[key].inBase and Score.flags[key].location == location) then
                        return
                    end
                end

                --capture the player stats if they actually captured it
                --print("Owner = " .. NPC:GetPlayerOwnerID())
                if(Score.flags[flag_letter].currTeamPossession ~= NPC:GetTeam()) then
                    Score.playerStats[NPC:GetPlayerOwnerID()].flag_captures = Score.playerStats[NPC:GetPlayerOwnerID()].flag_captures + 1
                    -- show a message to all
                    objectiveMsg = "objective_flag" -- see addon_english.txt (panorama/localization)
                    local broadcast_obj =
                    {
                        msg = objectiveMsg,
                        time = 10,
                        elaboration = ""
                    }
                    CustomGameEventManager:Send_ServerToAllClients( MESSAGE_EVENT_BROADCAST, broadcast_obj )
                end

                NPC:DropItemAtPositionImmediate(hItem, nearestFlagSpawner:GetOrigin())

                local mod_name = GetFlagModifierNameFromIdentifier(flag_letter)

                Score.flags[flag_letter].currTeamPossession = NPC:GetTeam()
                Score.flags[flag_letter].inBase = true
                Score.flags[flag_letter].location = location

                hItem:SetTeam(NPC:GetTeam())

                for playerID = 0, DOTA_MAX_PLAYERS do
                    if PlayerResource:IsValidPlayerID(playerID) then
                        if not PlayerResource:IsBroadcaster(playerID) then
                            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                            if hero:GetTeam() == NPC:GetTeam() then
                                if (mod_name == MODIFIER_FLAG_MORALE_NAME and hero:FindModifierByName(MODIFIER_FLAG_MORALE_NAME)) then
                                    print("Found instance of morale aura - Incrementing stack count")
                                    hero:FindModifierByName(MODIFIER_FLAG_MORALE_NAME):IncrementStackCount()
                                else
                                    print("Adding modifier " .. mod_name .. " for hero " .. hero:GetName())
                                    hero:AddNewModifier(hero, nil, mod_name, {})
                                end
                            end
                        end
                    end
                end

                -- remove the carry modifier/debuff
                NPC:RemoveModifierByName(MODIFIER_FLAG_CARRY_NAME)

                -- set score
                Score:RecalculateScores()
            end
        end
	else
		printf("ERROR: OnStartTouch: trigger \"%s\" has a nil activator or caller", triggerName)
    end
end

function SanitizeLocation(sTriggerLoc)
    if sTriggerLoc == "top" then
        return "Top"
    elseif sTriggerLoc == "mid" then
        return "Mid"
    elseif sTriggerLoc == "bot" then
        return "Bot"
    elseif sTriggerLoc == "topl" then
        return "TopL"
    elseif sTriggerLoc == "botl" then
        return "BotL"
    end
end

function HasFlagInInventory(hPlayerHero)
    if hPlayerHero:HasItemInInventory(OBJECTIVE_FLAG_ITEM_A) then
        return OBJECTIVE_FLAG_ITEM_A
    elseif hPlayerHero:HasItemInInventory(OBJECTIVE_FLAG_ITEM_B) then
        return OBJECTIVE_FLAG_ITEM_B
    elseif hPlayerHero:HasItemInInventory(OBJECTIVE_FLAG_ITEM_C) then
        return OBJECTIVE_FLAG_ITEM_C
    elseif hPlayerHero:HasItemInInventory(OBJECTIVE_FLAG_ITEM_D) then
        return OBJECTIVE_FLAG_ITEM_D
    elseif hPlayerHero:HasItemInInventory(OBJECTIVE_FLAG_ITEM_E) then
        return OBJECTIVE_FLAG_ITEM_E
    end

    return nil
end

function GetFlagModifierNameFromIdentifier(flag_letter)
    if (flag_letter == IDENTIFIER_FLAG_A or flag_letter == IDENTIFIER_FLAG_B) then 
        mod_name = MODIFIER_FLAG_MORALE_NAME
    elseif (flag_letter == IDENTIFIER_FLAG_C) then
        mod_name = MODIFIER_FLAG_AGILITY_NAME
    elseif (flag_letter == IDENTIFIER_FLAG_D) then
        mod_name = MODIFIER_FLAG_ARCANE_NAME
    elseif (flag_letter == IDENTIFIER_FLAG_E) then
        mod_name = MODIFIER_FLAG_REGROWTH_NAME
    end

    print("GetFlagModifierNameFromIdentifier returned: " .. mod_name)
    return mod_name
end