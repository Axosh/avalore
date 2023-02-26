// idk if this will work, but trying to override the default funciton of the stash
function DOTAHUDStashGrabAll() {
    $.Msg( "Hello from DOTAHUDStashGrabAll, World!" );
    var unit = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    if( unit != -1) {
        GameEvents.SendCustomGameEventToServer("Avalore_Take_Stash", { 'entindex':unit});
    }
}

function AVALOREHUDStashGrabAll() {
    $.Msg( "Hello from AVALOREHUDStashGrabAll, World!" );
    var unit = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    if( unit != -1) {
        GameEvents.SendCustomGameEventToServer("Avalore_Take_Stash", { 'entindex':unit});
    }
}

(function() {
	$.Msg( "Hello from avalore_overrides, World! asdf" );

    // $("#grab_all_button").SetPanelEvent("onactivate", function() { 
    //     AVALOREHUDStashGrabAll();
    //  });

    var Parent = $.GetContextPanel().GetParent().GetParent()
    Parent.FindChildTraverse("grab_all_button").SetPanelEvent("onactivate", function() { 
            AVALOREHUDStashGrabAll();
         });

    // let abilities = Parent.FindChildTraverse("abilities");
    // for (let ability of abilities.Children()) {
    //     //if (ability.FindChildTraverse("AbilityImage").src.includes("mercenary")) {
    //         $.Msg( "Found " +  ability.FindChildTraverse("AbilityImage").src);
    //     //}
    //     ReplaceDOTAAbilitySpecialValues
    // }

    // GameEvents.Subscribe("dota_player_begin_cast", OnBeginCast)
    // GameEvents.Subscribe( "dota_player_update_query_unit", OnUpdateQueryUnit );
})();

// function OnBeginCast() {
//     $.Msg("Began Cast!!")
// }

// function OnUpdateQueryUnit() {
//     $.Msg("OnUpdateQueryUnit")
// }