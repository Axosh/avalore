--[[
    These get called directly from the Trigger surrounding the 
    outposts - check both the properties and the outputs

    radiant_outpost // radiant_outpost_trigger
]]

function Outpost_OnStartTouch( trigger )
    print("Got in Outpost_OnStartTouch")
    local hHero = trigger.activator
    local sCheckpointTriggerName = thisEntity:GetName() -- should be like "radiant_outpost_trigger"
    sCheckpointTriggerName = string.sub(sCheckpointTriggerName, 0, string.len(sCheckpointTriggerName) - 8) -- remove "_trigger"
    print(sCheckpointTriggerName)
	local hBuilding = Entities:FindByName( nil, sCheckpointTriggerName )

	-- If it's already activated by this team - we're good
	if hBuilding:GetTeamNumber() == hHero:GetTeamNumber() then
        return
    else
        hBuilding:SetTeam( hHero:GetTeamNumber() )
        EmitGlobalSound( "DOTA_Item.Refresher.Activate" )
    end
    
	--GameRules.rpg_example:RecordActivatedCheckpoint( hHero:GetPlayerID(), sCheckpointTriggerName )

	-- if sCheckpointTriggerName ~= "checkpoint00" then
	-- 	BroadcastMessage( "Activated " .. sCheckpointTriggerName, 3 )
	-- 	EmitGlobalSound( "DOTA_Item.Refresher.Activate" ) -- Checkpoint.Activate
	-- end
end