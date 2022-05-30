-- tracking modifier for the talent
modifier_talent_grappling_hold = class({})

function modifier_talent_grappling_hold:IsHidden() 		return true end
function modifier_talent_grappling_hold:IsPurgable() 	return false end
function modifier_talent_grappling_hold:RemoveOnDeath() 	return false end