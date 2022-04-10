-- tracking modifier for the talent
modifier_talent_possessed = class({})

function modifier_talent_possessed:IsHidden() 		return true end
function modifier_talent_possessed:IsPurgable() 	return false end
function modifier_talent_possessed:RemoveOnDeath() 	return false end