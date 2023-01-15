

-- function CAvaloreGameMode:PingPlayers(team_id)
--     for playerId = 0,19 do
--         local player = PlayerResource:GetPlayer(playerId)
--         if player ~= nil then
--             if player:GetAssignedHero() then
--                 if player:GetTeam() == gem_broadcast_team then
--                     MinimapEvent(gem_broadcast_team, player:GetAssignedHero(), gem_trigger:GetOrigin().x,  gem_trigger:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 3)
--                 end
--             end
--         end
--     end
-- end
