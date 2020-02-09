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
//	  msg = "helloworld",
//	  time = 5,
//	  elaboration = "note"
//  }
//  CustomGameEventManager:Send_ServerToAllClients( "broadcast_message", broadcast_obj )
function OnBroadcastLocalizedMessage(broadcast_obj)
{
	$.GetContextPanel().SetHasClass( "broadcast", true ); // css class: .broadcast #AlertMessage

	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Delivery" ).text = $.Localize( broadcast_obj.msg );

	if(broadcast_obj.elaboration){
		$( "#AlertMessage_Elaboration" ).html = true;
		$( "#AlertMessage_Elaboration" ).text = $.Localize( broadcast_obj.elaboration );
	}

	//$.Schedule( broadcast_obj.time, ClearAlert );
	//$.Schedule( broadcast_obj.time, ClearAlert );
	$.Schedule( 3, ClearAlert );
}

function ClearAlert()
{
	$.GetContextPanel().SetHasClass( "broadcast", false );
	$.GetContextPanel().SetHasClass( "test", false );
	$( "#AlertMessage" ).text = "";
	$( "#AlertMessage_Delivery" ).text = "";
	$( "#AlertMessage_Elaboration" ).text = "";
}

(function () {
	GameEvents.Subscribe( "test", OnTest );
	GameEvents.Subscribe( "broadcast_message", OnBroadcastLocalizedMessage );
})();