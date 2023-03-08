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

function OnUpdateSelectedUnit() {
    $.Msg("OnUpdateSelectedUnit");
    OverrideWardDispenser();
}

function OverrideWardDispenser() {
    var Parent = $.GetContextPanel().GetParent().GetParent();
    var inv = Parent.FindChildTraverse("inventory_list_container");
    // loop through inventory_list, inventory_list2, inventory_backpack_list
    for (let list of inv.Children()) {
        $.Msg("Curr List => " + list.id)
        //loop through inventory_slot_0, inventory_slot_1, etc.
        for (let slot of list.Children()) {
            $.Msg("Curr Slot => " + slot.id)
            var itemImage = slot.FindChildTraverse("ItemImage");
            //itemImage.SetImage('file://{images}/ui/hulk.png')
            $.Msg("Curr Image => " + itemImage.itemname)
            if (itemImage.GetAttributeString("src", "") != "") {
                //$.Msg(itemImage.src)
                if (itemImage.itemname == 'item_ward_dispenser') {
                    //itemImage.attr('src', 'file://{images}/items/test.png');
                    itemImage.SetImage('file://{images}/items/avalore_ward_dispenser.png');
                }
                else if (itemImage.itemname == 'item_ward_dispenser_sentry') {
                    //itemImage.attr('src', 'file://{images}/items/test.png');
                    itemImage.SetImage('file://{images}/items/avalore_ward_dispenser_sentry.png');
                }
            }
        }
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

    // shop changed seems to be when someone enters the shop radius
    //GameEvents.Subscribe("dota_player_shop_changed", OnShopChanged)
    // GameEvents.Subscribe("dota_item_combined", OnItemCombined);
    // GameEvents.Subscribe("dota_hero_inventory_item_change", OnHeroInventoryItemChange);
    // GameEvents.Subscribe("dota_item_picked_up", OnItemPickedUp);
    GameEvents.Subscribe("dota_inventory_item_changed", OnInventoryItemChange);

    GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
    GameEvents.Subscribe( "dota_player_update_query_unit", OnUpdateSelectedUnit );
})();

// function OnBeginCast() {
//     $.Msg("Began Cast!!")
// }

// function OnUpdateQueryUnit() {
//     $.Msg("OnUpdateQueryUnit")
// }