-- tracking modifier for the talent
modifier_talent_potent_drinks = class({})

function modifier_talent_potent_drinks:IsHidden() 		return true end
function modifier_talent_potent_drinks:IsPurgable() 		return false end
function modifier_talent_potent_drinks:RemoveOnDeath() 	return false end