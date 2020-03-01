require("constants")
require("spawners")

-----------------------------------------------------------------------------------------------------------
--	Item Definition
-----------------------------------------------------------------------------------------------------------
item_objective_flag = item_objective_flag or class({})
item_avalore_flag_morale_radi = item_avalore_flag_morale_radi or class({})

LinkLuaModifier( "modifier_item_flag_carry", "items/item_objective_flag.lua", LUA_MODIFIER_MOTION_NONE )

function item_objective_flag:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end

function item_avalore_flag_morale_radi:GetIntrinsicModifierName()
    return "modifier_item_flag_carry" end


-----------------------------------------------------------------------------------------------------------
--	Intrinsic modifier definition
-----------------------------------------------------------------------------------------------------------

if modifier_item_flag_carry == nil then modifier_item_flag_carry = class({}) end

function modifier_item_flag_carry:OnCreated(keys)
    if IsServer() then
        local ent_flag = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "maps/journey_assets/props/teams/banner_journey_dire_small.vmdl"})

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
    if hPlayerHero:HasItemInInventory("item_avalore_flag_morale_radi") then
        return "item_avalore_flag_morale_radi"
    end
    return nil
end