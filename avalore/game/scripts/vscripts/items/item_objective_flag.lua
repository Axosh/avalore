require("constants")
require("spawners")
require("score")
require("references")

-----------------------------------------------------------------------------------------------------------
--	Item Definitions
-----------------------------------------------------------------------------------------------------------
item_objective_flag = item_objective_flag or class({})
item_avalore_flag_a = item_avalore_flag_a or class({})
item_avalore_flag_b = item_avalore_flag_b or class({})
item_avalore_flag_c = item_avalore_flag_c or class({})
item_avalore_flag_d = item_avalore_flag_d or class({})
item_avalore_flag_e = item_avalore_flag_e or class({})

LinkLuaModifier( "modifier_item_flag_carry", MODIFIER_ITEM_FLAG_CARRY, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flag_morale", MODIFIER_FLAG_MORALE, LUA_MODIFIER_MOTION_NONE )

function item_objective_flag:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end

function item_avalore_flag_a:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end

function item_avalore_flag_b:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end

function item_avalore_flag_c:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end

function item_avalore_flag_d:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end

function item_avalore_flag_e:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end


-----------------------------------------------------------------------------------------------------------
--	Intrinsic modifier definition
-----------------------------------------------------------------------------------------------------------

if modifier_item_flag_carry == nil then modifier_item_flag_carry = class({}) end

function modifier_item_flag_carry:OnCreated(keys)
    if IsServer() then
        local ent_flag = nil

        --local sFlag = HasFlagInInventory(self:GetParent())
        local sFlag = self:GetAbility():GetName() -- this will be one of the item_avalore_flag_abcde items
        
        if sFlag == OBJECTIVE_FLAG_ITEM_A then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_A})
        elseif sFlag == OBJECTIVE_FLAG_ITEM_B then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_B})
        elseif sFlag == OBJECTIVE_FLAG_ITEM_C then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_C})
        elseif sFlag == OBJECTIVE_FLAG_ITEM_D then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_D})
        elseif sFlag == OBJECTIVE_FLAG_ITEM_E then
            ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = OBJECTIVE_FLAG_MODEL_E})
        end

        -- flag has been picked up, so update status
        local flag_letter = string.sub(sFlag, -1) -- get the last letter
        Score.flags[flag_letter].inBase = false

        ent_flag:FollowEntity(self:GetParent(), false)
        self.entFollow = ent_flag
        
        if self.particle == nil then
            self.particle = ParticleManager:CreateParticle("particles/customgames/capturepoints/cp_wood.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(self.particle, 0, Vector(0, 0, 0))
        end

        -- if self.flag_model == nil then
        --     self.flag_model = ParticleManager:CreateParticle("maps/journey_assets/props/teams/banner_journey_dire_small.vmdl", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        --     --ParticleManager:SetParticleControl(self.flag_model, 0, Vector(0, 0, 0))
        --     --ParticleID particle, int controlPoint, CDOTA_BaseNPC unit, ParticleAttachment_t particleAttach, cstring attachment, vector offset, bool lockOrientation 
        --     --ParticleManager:SetParticleControlEnt(self.flag_model, 0, self:GetParent(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_hitloc", Vector(0, -10, 0), false)
        --     --ParticleManager:SetParticleControlEnt(self.flag_model, 0, self:GetParent(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
        --     ParticleManager:SetParticleControl(self.flag_model, 0, Vector(0, 0, 0))
        -- end
    end
end

function modifier_item_flag_carry:OnDestroy(keys)
    if self.particle ~= nil then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
		self.particle = nil
    end
    -- if self.flag_model ~= nil then
	-- 	ParticleManager:DestroyParticle(self.flag_model, false)
	-- 	ParticleManager:ReleaseParticleIndex(self.flag_model)
	-- 	self.flag_model = nil
    -- end
    if self.entFollow ~= nil then
        self.entFollow:RemoveSelf()
        self.entFollow = nil
    end
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
                if string.find(TriggerEntity:GetName(), "radi") then
                    nearestFlagSpawner = Spawners.RadiFlagBases[SanitizeLocation(TriggerEntity:GetName():gsub("%trigger_radi_flag_", ""))]
                    --nearestFlagSpawner = Entities:FindByNameNearest("npc_avalore_radi_flag_base", TriggerEntity:GetOrigin(), 500)
                elseif string.find(TriggerEntity:GetName(), "dire") then
                    nearestFlagSpawner = Spawners.RadiFlagBases[SanitizeLocation(TriggerEntity:GetName():gsub("%trigger_dire_flag_", ""))]
                end
                NPC:DropItemAtPositionImmediate(hItem, nearestFlagSpawner:GetOrigin())

                local flag_letter = string.sub(hItem:GetName(), -1) -- get the last letter
                --capture the player stats if they actually captured it
                print("Owner = " .. NPC:GetPlayerOwnerID())
                if(Score.flags[flag_letter].currTeamPossession ~= NPC:GetTeam()) then
                    Score.playerStats[NPC:GetPlayerOwnerID()].flag_captures = Score.playerStats[NPC:GetPlayerOwnerID()].flag_captures + 1
                end
                Score.flags[flag_letter].currTeamPossession = NPC:GetTeam()
                Score.flags[flag_letter].inBase = true

                hItem:SetTeam(NPC:GetTeam())
                --hItem:AddNewModifier(hItem, nil, "modifier_flag_morale", {})
                --NPC:AddNewModifier(hItem, nil, "modifier_flag_morale", {})
                NPC:AddNewModifier(hItem, "flag_morale_aura", nil, {})
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