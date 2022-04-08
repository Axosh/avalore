-- tracking modifier for the talent
modifier_talent_unbridled_power = class({})

function modifier_talent_unbridled_power:IsHidden() 		return true end
function modifier_talent_unbridled_power:IsPurgable() 		return false end
function modifier_talent_unbridled_power:RemoveOnDeath() 	return false end