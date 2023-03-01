function OnUpdateSelectedUnit() {
    var mainSelected = Players.GetLocalPlayerPortraitUnit()
    var unitName = Entities.GetUnitName(mainSelected)
    $.Msg("Selected Unit => " + unitName)
    $.Msg("Selected Team => " + Entities.GetTeamNumber(mainSelected))
    $.Msg("Player Team => " + Entities.GetTeamNumber(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())))
    // If not a building a user can control
    if (Entities.GetTeamNumber(mainSelected) == Entities.GetTeamNumber(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())) 
            && (unitName.indexOf("mercenary_camp") > -1 
            || unitName.indexOf("building_arcanery") > -1)) {
        $.Msg("VISIBLE")
        $("#TakeControlDisplay").SetHasClass("Hidden", false);
        //$(".ControlBuildingContainer").hittest = false;
    }
    else {
        $.Msg("Should Hide")
        $("#TakeControlDisplay").SetHasClass("Hidden", true);
        
        //$(".ControlBuildingContainer").hittest = true;
    }
}

// function OnAbilityUsed() {
//     $.Msg("OnAbilityUsed")
// }

function AVALOREControlBuilding() {
    $.Msg("AVALOREControlBuilding()")
    var player = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    if( player != -1) {
        var entIndex = Players.GetLocalPlayerPortraitUnit()
        GameEvents.SendCustomGameEventToServer("Avalore_Control_Building", { 'entindex':entIndex, 'playerHeroEntId':player});
    }
}

// wireup string-id to javascript function
(function()
{
	GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
    GameEvents.Subscribe( "dota_player_update_query_unit", OnUpdateSelectedUnit );
    //GameEvents.Subscribe( "dota_player_used_ability", OnAbilityUsed)
    $("#control_building").SetPanelEvent("onactivate", function() { AVALOREControlBuilding(); })
})();