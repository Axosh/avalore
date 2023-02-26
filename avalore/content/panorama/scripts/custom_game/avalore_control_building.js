

// wireup string-id to javascript function
(function()
{
	GameEvents.Subscribe( "update_team_gold", UpdateGold );
    GameEvents.Subscribe( "add_to_hire_queue", AddToQueue );
    GameEvents.Subscribe( "clear_hire_queue", ClearQueue );
})();