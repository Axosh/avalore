-- tracking modifier for the talent
modifier_talent_give_in = class({})

function modifier_talent_give_in:IsHidden() 		return true end
function modifier_talent_give_in:IsPurgable() 	return false end
function modifier_talent_give_in:RemoveOnDeath() 	return false end