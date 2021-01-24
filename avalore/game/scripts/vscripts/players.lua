-- Functions relating to the collection of all players
-- =====================================================

-- finds the player with the lowest networth on a particular team
-- and returns their playerId
function LowestNetworthPlayer(team_id)
    local lowest_gold = -1
    local lowest_gold_playerId = -1
    for playerID = 0, DOTA_MAX_PLAYERS do
        -- check for actual players
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                -- check team
                if(PlayerResource:GetTeam(playerID) == team_id) then
                    local player_networth = PlayerResource:GetNetWorth(playerID)
                    -- check if not set, or is lower networth than lowest found
                    if (lowest_gold == -1) or (lowest_gold > player_networth) then
                        lowest_gold = player_networth
                        lowest_gold_playerId = playerID
                    end
                end
            end
        end
    end
    return lowest_gold_playerId
end