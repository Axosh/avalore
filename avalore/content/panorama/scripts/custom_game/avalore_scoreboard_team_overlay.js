"use strict";
// Expects:
// 		score_obj = 
//		{
//			radi_score = int score
//			dire_score = int score
//		}
function RefreshScore(score_obj)
{
	$( "#RadiantPoints" ).html = true;
	$( "#RadiantPoints" ).text = score_obj.radi_score.toString();
	//$( "#RadiantScoreLabel" ).text = score_obj.radi_score.toString();

	$( "#DirePoints" ).html = true;
	$( "#DirePoints" ).text = score_obj.dire_score.toString();
	//$( "#DireScoreLabel" ).text = score_obj.dire_score.toString();

	//$( "#TeamScore" ).html = true;
	//$( "#TeamScore" ).text = score_obj.radi_score.toString();

	//$(DOTA_DEFAULT_UI_TOP_BAR_SCORE)

}


(function()
{
	GameEvents.Subscribe( "refresh_score", RefreshScore );
})();