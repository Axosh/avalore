--round1_quest = class({})

ai = require( "round1/ai/ai_quest_wisp" )

LinkLuaModifier( "modifier_quest_wisp", "scripts/vscripts/modifiers/modifier_quest_wisp.lua", LUA_MODIFIER_MOTION_NONE )

function Spawn( entityKeyValues )
    ai.Init( thisEntity )

    thisEntity:AddNewModifier(thisEntity, nil, "modifier_quest_wisp", {})

    --local nGoldReward = 0
    --if RandomFloat( 0, 1 ) > 0.75 then
    --    nGoldReward = thisEntity:GetGoldBounty()
    --end
    --thisEntity:SetMinimumGoldBounty( nGoldReward )
    --thisEntity:SetMaximumGoldBounty( nGoldReward )
end