function OnUpdateSelectedUnit() {
    var mainSelected = Players.GetLocalPlayerPortraitUnit()
    var unitName = Entities.GetUnitName(mainSelected)
    $.Msg("Selected Unit => " + unitName)
    // If not a building a user can control
    if (unitName.indexOf("mercenary_camp") <= -1 && unitName.indexOf("building_arcanery") <= -1) {
        $.Msg("Should Hide")
        $("#TakeControlDisplay").SetHasClass("Hidden", true);
        //$(".ControlBuildingContainer").hittest = false;
    }
    else {
        $.Msg("VISIBLE")
        $("#TakeControlDisplay").SetHasClass("Hidden", false);
        //$(".ControlBuildingContainer").hittest = true;
    }
}

function OnAbilityUsed() {
    $.Msg("OnAbilityUsed")
}

// wireup string-id to javascript function
(function()
{
	GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
    GameEvents.Subscribe( "dota_player_update_query_unit", OnUpdateSelectedUnit );
    GameEvents.Subscribe( "dota_player_used_ability", OnAbilityUsed)
})();