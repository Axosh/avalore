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

    var ability_images = Parent.FindChildTraverse("AbilityImage");
	//Init();
})();