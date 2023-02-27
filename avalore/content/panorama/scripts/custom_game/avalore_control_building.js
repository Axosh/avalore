function OnUpdateSelectedUnit() {
    var mainSelected = Players.GetLocalPlayerPortraitUnit()
    var unitName = Entities.GetUnitName(mainSelected)
    $.Msg("Selected Unit => " + unitName)
    if (unitName.indexOf("mercenary_camp") <= -1 && unitName.indexOf("building_arcanery") <= -1) {
        $("#TakeControlDisplay").SetHasClass("Hidden", true);
        //$(".ControlBuildingContainer").hittest = false;
    }
    else {
        $("#TakeControlDisplay").SetHasClass("Hidden", false);
        //$(".ControlBuildingContainer").hittest = true;
    }
}

// wireup string-id to javascript function
(function()
{
	GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
})();