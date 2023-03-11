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

// function OnShopChanged() {
//     $.Msg("Shop Changed!!");
// }

// function OnItemCombined() {
//     $.Msg("OnItemCombined");
// }

// function OnHeroInventoryItemChange() {
//     $.Msg("OnHeroInventoryItemChange");
// }

// function OnItemPickedUp() {
//     $.Msg("OnItemPickedUp");
// }

function GetDotaHud() {
    var p = $.GetContextPanel();
    try {
        while (true) {
            if (p.id === "Hud")
                return p;
            else
                p = p.GetParent();
        }
    } catch (e) {}
}

function OnInventoryItemChange() {
    $.Msg("OnInventoryItemChange");
    OverrideWardDispenser();
}

// function OverrideWardDispenser() {
//     //var Parent = $.GetContextPanel().GetParent().GetParent()
//     //var x = $("DOTAItemImage[src$='file://{images}/items/ward_dispenser.png']");
//     //var x = $("#ItemImage[src$='file://{images}/items/ward_dispenser.png']");
//     var x = $("#ItemImage");
//     if (x){
//         $.Msg(x.attr('src'));
//         x.attr('src', 'file://{images}/items/test.png');
//     }
// }

function OnUpdateQueryUnit(){
    $.Msg("OnUpdateQueryUnit");
    //GameUI.SelectUnit(Players.GetSelectedEntities(Players.GetLocalPlayer())[0], false)
    //OverrideWardDispenser();
    //OverrideHeroPortrait();
}

function OnUpdateSelectedUnit() {
    $.Msg("OnUpdateSelectedUnit");
    //OverrideWardDispenser();
    //OverrideHeroPortrait();
}

function GameUIActivated() {
    $.Msg("GameUIActivated");
}

function InventoryChangedQueryUnit() {
    $.Msg("InventoryChangedQueryUnit");
}

function OnInventoryUpdated() {
    $.Msg("OnInventoryUpdated");
}

function OverrideWardDispenser() {
    //var Parent = $.GetContextPanel().GetParent().GetParent();
    //var inv = Parent.FindChildTraverse("inventory_list_container");
    var inv = GetDotaHud().FindChildTraverse("inventory_list_container");
    //var inv = $("#inventory_list_container")
    // loop through inventory_list, inventory_list2, inventory_backpack_list
    for (let list of inv.Children()) {
        //$.Msg("Curr List => " + list.id)
        //loop through inventory_slot_0, inventory_slot_1, etc.
        for (let slot of list.Children()) {
            //$.Msg("Curr Slot => " + slot.id)
            var itemImage = slot.FindChildTraverse("ItemImage");
            //$.Msg("Curr Image => " + itemImage.itemname)
            $.Msg("EntId => " + itemImage.contextEntityIndex);
            if (itemImage.itemname == 'item_ward_dispenser') {
                $.Msg("Swapping item_ward_dispenser");
                //itemImage.SetImage('file://{images}/items/test.png');
                itemImage.SetImage('file://{images}/items/avalore_ward_dispenser.png');
            }
            else if (itemImage.itemname == 'item_ward_dispenser_sentry') {
                $.Msg("Swapping item_ward_dispenser_sentry");
                //itemImage.SetImage('file://{images}/items/test.png');
                itemImage.SetImage('file://{images}/items/avalore_ward_dispenser_sentry.png');
            }
        }
    }
}

function OverrideHeroPortrait() {
    var hero = Players.GetLocalPlayerPortraitUnit()
    var heroName = Entities.GetUnitName(hero)
    $.Msg("Portrait Unit => " + heroName);
    //var portraitContainer = GetDotaHud().FindChildTraverse("PortraitContainer");
    // var portraitGroup = GetDotaHud().FindChildTraverse("PortraitGroup");
    // // Kunkka
    // //if (hero == 283) {
    // //if (portraitGroup.BHasClass("npc_dota_hero_kunkka")) {
    // if (heroName == "npc_dota_hero_kunkka") {
    //     $.Msg("Is Kunkka")
    //     portraitGroup.AddClass("DavyJones")
    //     portraitGroup.RemoveClass("npc_dota_hero_kunkka")
    //     // var heroImg = $.CreatePanel('DOTAHeroImage', portraitGroup, '');
    //     // heroImg.SetImage('file://{images}/portrait/davy_jones.png');
    //     // heroImg.AddClass("DavyJones");
    // }
}

function printObject(o) {
    var out = '';
    for (var p in o) {
      out += p + ': ' + o[p] + '\n';
    }
    $.Msg(out);
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

    // shop changed seems to be when someone enters the shop radius
    //GameEvents.Subscribe("dota_player_shop_changed", OnShopChanged)
    // GameEvents.Subscribe("dota_item_combined", OnItemCombined);
    // GameEvents.Subscribe("dota_hero_inventory_item_change", OnHeroInventoryItemChange);
    // GameEvents.Subscribe("dota_item_picked_up", OnItemPickedUp);
    GameEvents.Subscribe("dota_inventory_item_changed", OnInventoryItemChange);

    GameEvents.Subscribe("inventory_updated", OnInventoryUpdated);

    GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
    GameEvents.Subscribe( "dota_player_update_query_unit", OnUpdateQueryUnit );

    GameEvents.Subscribe( "item_purchased", OverrideWardDispenser );
    GameEvents.Subscribe( "gameui_activated", GameUIActivated );
    GameEvents.Subscribe( "dota_inventory_changed_query_unit", InventoryChangedQueryUnit );

    GameUI.CustomUIConfig().team_colors = {}
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#33FFCC;"; // { 51, 255, 204 }    -- cyanish
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "#9013FE;"; // { 144, 19, 254 }    -- Purple
    
    printObject(GameUI.CustomUIConfig());
})();

// function OnBeginCast() {
//     $.Msg("Began Cast!!")
// }

// function OnUpdateQueryUnit() {
//     $.Msg("OnUpdateQueryUnit")
// }