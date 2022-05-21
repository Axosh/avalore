-- tracking modifier for the talent
modifier_talent_life_giver = class({})

function modifier_talent_life_giver:IsHidden() 		return true end
function modifier_talent_life_giver:IsPurgable() 		return false end
function modifier_talent_life_giver:RemoveOnDeath() 	return false end