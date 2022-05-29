-- tracking modifier for the talent
modifier_talent_endurance = class({})

function modifier_talent_endurance:IsHidden() 		return true end
function modifier_talent_endurance:IsPurgable() 	return false end
function modifier_talent_endurance:RemoveOnDeath() 	return false end