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
    RepaintInventory();
    // make backpack items not gray
    // $.Msg("Has class? " + GetDotaHud().FindChildTraverse("inventory_slot_6").BHasClass("inactive_item"))
    // GetDotaHud().FindChildTraverse("inventory_slot_6").RemoveClass("inactive_item")
    // GetDotaHud().FindChildTraverse("inventory_slot_6").AddClass("AvaloreBackpack")
    // var img = GetDotaHud().FindChildTraverse("inventory_slot_6").FindChildTraverse("ItemImage")
    // $.Msg("Inv 6 Icon => '" + img.itemname + "'")
    // //if (img.GetAttributeString("src", "").includes("empty.png"))
    // if (img.itemname == '')
    // {
    //     $.Msg("inv 6 empty")
    //     img.SetImage("file://{images}/ui/slot_misc.png")
    // }
    // GetDotaHud().FindChildTraverse("inventory_slot_7").RemoveClass("inactive_item")
    // GetDotaHud().FindChildTraverse("inventory_slot_7").AddClass("AvaloreBackpack")
    // GetDotaHud().FindChildTraverse("inventory_slot_8").RemoveClass("inactive_item")
    // GetDotaHud().FindChildTraverse("inventory_slot_8").AddClass("AvaloreBackpack")
}

function RepaintInventory()
{
    $.Msg("RepaintInventory()")
    OverrideWardDispenser();

    var hud = GetDotaHud();
    var slots =         ['inventory_slot_0',                 'inventory_slot_1',                  'inventory_slot_2',                 'inventory_slot_3',                  'inventory_slot_4',                 'inventory_slot_5',                    'inventory_slot_6',                 'inventory_slot_7',                 'inventory_slot_8']
    var slot_images =   ['file://{images}/ui/slot_head.png', 'file://{images}/ui/slot_chest.png', 'file://{images}/ui/slot_back.png', 'file://{images}/ui/slot_hands.png', 'file://{images}/ui/slot_feet.png', 'file://{images}/ui/slot_trinket.png', 'file://{images}/ui/slot_misc.png', 'file://{images}/ui/slot_misc.png', 'file://{images}/ui/slot_misc.png']

    for (let i = 0; i < slots.length; i++) {
        var abilityPanel = hud.FindChildTraverse(slots[i]);
        if (i > 5) {
            abilityPanel.RemoveClass("inactive_item");
            abilityPanel.RemoveClass("BackpackSlot");
        }

        var img = abilityPanel.FindChildTraverse("ItemImage")
        if (img.itemname == '') {
            img.SetImage(slot_images[i]);
        }
    }
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
    RepaintInventory()
    //GameUI.SelectUnit(Players.GetSelectedEntities(Players.GetLocalPlayer())[0], false)
    //OverrideWardDispenser();
    //OverrideHeroPortrait();
}

function OnUpdateSelectedUnit() {
    $.Msg("OnUpdateSelectedUnit");
    RepaintInventory()
    //OverrideWardDispenser();
    //OverrideHeroPortrait();
}

function GameUIActivated() {
    $.Msg("GameUIActivated");
}

function InventoryChangedQueryUnit() {
    $.Msg("InventoryChangedQueryUnit");
    RepaintInventory()
}

function OnInventoryUpdated() {
    $.Msg("OnInventoryUpdated");
}

function ItemDragEnd() {
    $.Msg("ItemDragEnd");
    RepaintInventory()
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

function GameRulesStateChange() {
    $.Msg("State Change")
    // var desc = GetDotaHud().FindChildTraverse("HeroSimpleDescription");
    // for (let list of desc.Children()) {
    //     $.Msg("Found One");
    // }
}

function BindPanelOpen() {
    $.Msg("Bind Panel Open");
}

function UpdateHeroSelection() {
    $.Msg("UpdateHeroSelection");
}

function UpdateAssignedHero() {
    $.Msg("UpdateAssignedHero");
}

function HeroSelectionDirty() {
    //$.Msg("HeroSelectionDirty");
    var desc = GetDotaHud().FindChildTraverse("HeroSimpleDescription");
    //$.Msg("Desc => " + desc)
    // Loop through: HeroTipHeader, HeroTipContainer, SimlarHeroes
    for (let heroTip of desc.Children()) {
        //$.Msg("HeroTip => " + heroTip)
        // Loop through: FirstParagraph, SecondParagraph
        if (heroTip.BHasClass("HeroTipContainer")){
            for (let panel of heroTip.Children()) {
                //$.Msg("panel => " + panel)
                if (panel.BHasClass("FirstParagraph")) {
                    // Loop through: HeroImage, HeroDescriptionText
                    for (let child of panel.Children()) {
                        //$.Msg("child => " + child)
                        if (child.BHasClass("HeroDescriptionText")) {
                            //$.Msg("Adding Description Font Change");
                            child.AddClass("AvaloreHeroDescriptionText");
                            child.RemoveClass("HeroDescriptionText")
                        }
                    }
                }
            }
        }
        else if (heroTip.BHasClass("SimilarHeroes")) {
            //$.Msg("Has SimilarHeroes Class -- Removing")
            heroTip.visible = false;
            // Deleting this throws errors, so maybe just hide it?
            // heroTip.RemoveAndDeleteChildren();
            // heroTip.DeleteAsync(0.0);
        }
    }
}

function HeroSelectorPreviewSet() {
    $.Msg("HeroSelectorPreviewSet");
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

    GameEvents.Subscribe( "game_rules_state_change", GameRulesStateChange );
    GameEvents.Subscribe( "bindpanel_open", BindPanelOpen );
    GameEvents.Subscribe( "dota_player_update_hero_selection", UpdateHeroSelection );
    GameEvents.Subscribe( "dota_player_update_assigned_hero", UpdateAssignedHero );
    GameEvents.Subscribe( "dota_player_hero_selection_dirty", HeroSelectionDirty );
    GameEvents.Subscribe( "hero_selector_preview_set", HeroSelectorPreviewSet );
    GameEvents.Subscribe( "dota_item_drag_end", ItemDragEnd );
    
    

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