function OnTest(msg)
{
	$.GetContextPanel().SetHasClass( "test", true );
	//$.GetContextPanel().SetHasClass( "item_has_spawned", false );
	//GameUI.PingMinimapAtLocation( msg.spawn_location );
	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Delivery" ).text = $.Localize( "#Test" );

	$.Schedule( 3, ClearAlert );
}

// 
// Expects 2 things in broadcast_obj:
// broadcast_obj.msg ==> message to show (strings are in avalore/panorama/localization)
// broadcast_obj.time ==> how long to show before clearing
//
// Example Invocation:
// local broadcast_obj =
// {
//	  msg = "helloworld"
//	  time = 5
//  }
//  CustomGameEventManager:Send_ServerToAllClients( "broadcast_message", broadcast_obj )
function OnBroadcastLocalizedMessage(broadcast_obj)
{
	$.GetContextPanel().SetHasClass( "test", true ); // css class: .broadcast #AlertMessage

	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Delivery" ).text = $.Localize( broadcast_obj.msg );

	//$.Schedule( broadcast_obj.time, ClearAlert );
	$.Schedule( broadcast_obj.time, ClearAlert );
}

function ClearAlert()
{
	$.GetContextPanel().SetHasClass( "broadcast", false );
	$.GetContextPanel().SetHasClass( "test", false );
	$( "#AlertMessage" ).text = "";
}

(function () {
	GameEvents.Subscribe( "test", OnTest );
	GameEvents.Subscribe( "broadcast_message", OnBroadcastLocalizedMessage );
})();