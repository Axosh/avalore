function UpdateGold(team_gold){
    // var queue_panel = $('#HireQueue');
    // queue_panel.
    var label = $('#SharedGold');
    label.text = team_gold.gold.toString();
}

// wireup string-id to javascript function
(function()
{
	GameEvents.Subscribe( "update_team_gold", UpdateGold );
})();