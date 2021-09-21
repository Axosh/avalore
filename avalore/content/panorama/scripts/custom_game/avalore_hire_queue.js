// ========================================================
// team_gold - table containing one value:
//    team_gold.gold | int | new team shared gold value
// ========================================================
function UpdateGold(team_gold){
    // var queue_panel = $('#HireQueue');
    // queue_panel.
    var label = $('#SharedGold');
    label.text = team_gold.gold.toString();
}

function GetLocationString(location) {
    var loc_str = "";
    if (location.includes("Top"))
        loc_str = "Top";
    else
        loc_str = "Bot";
    
    return loc_str;
}

//function GetQueueId(location) {
function GetQueuePanel(location) {
    if (GetLocationString(location) == "Top")
        return $("#HireQueue_Top");
    else
        return $("#HireQueue_Bot");
    //return ("#HireQueue_" + GetLocationString(location));
}

// ========================================================
//  queue_obj {
//      img | string | icon to map to display
//      loc | string | which queue to display on
// }
// location comes from Constants:
// Constants.KEY_RADIANT_TOP       = "Radiant_Top"
// Constants.KEY_RADIANT_BOT       = "Radiant_Bot"
// Constants.KEY_DIRE_TOP          = "Dire_Top"
// Constants.KEY_DIRE_BOT          = "Dire_Bot"
// ========================================================
// function AddToQueue(queue_obj) {
//     //var id = GetQueueId(queue_obj.loc);
//     //$.Msg("AddToQueue " + id); //debug print
//     var queue_panel = GetQueuePanel(queue_obj.loc); //$(`${id}`);
//     // use the built-in panorama function
//     queue_panel.BCreateChildren(`<Label id='MercQueueItem' class='.${queue_obj.img}' />`);
// }
function AddToQueue(queue_obj) {
        if (GetLocationString(queue_obj.loc) == "Top")
            $("#HireQueue_Top").BCreateChildren(`<Label id='MercQueueItem' class='.${queue_obj.img}' />`);
        else
            $("#HireQueue_Bot").BCreateChildren(`<Label id='MercQueueItem' class='.${queue_obj.img}' />`);
    }

// ========================================================
//  queue_obj {
//      loc | string | which queue to display on
// }
// ========================================================
function ClearQueue(queue_obj) {
    //var id = GetQueueId(queue_obj.loc);
    //var queue_panel = $(`${id}`);
    var queue_panel = GetQueuePanel(queue_obj.loc);
    queue_panel.RemoveAndDeleteChildren();
    // add back in the anchor
    queue_panel.BCreateChildren(`<Label id='${GetLocationString(queue_obj.loc)}QueueIcon' />`);
}

// wireup string-id to javascript function
(function()
{
	GameEvents.Subscribe( "update_team_gold", UpdateGold );
    GameEvents.Subscribe( "add_to_hire_queue", AddToQueue );
    GameEvents.Subscribe( "clear_hire_queue", ClearQueue );
})();