-- tracking modifier for the talent
modifier_talent_cannons = class({})

function modifier_talent_cannons:IsHidden() 		return true end
function modifier_talent_cannons:IsPurgable() 		return false end
function modifier_talent_cannons:RemoveOnDeath() 	return false end