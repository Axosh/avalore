-- tracking modifier for the talent
modifier_talent_bleed_their_purse = class({})

function modifier_talent_bleed_their_purse:IsHidden() 		return true end
function modifier_talent_bleed_their_purse:IsPurgable() 		return false end
function modifier_talent_bleed_their_purse:RemoveOnDeath() 	return false end