-- tracking modifier for the talent
modifier_talent_beacon = class({})

function modifier_talent_beacon:IsHidden() 		return true end
function modifier_talent_beacon:IsPurgable() 	return false end
function modifier_talent_beacon:RemoveOnDeath() 	return false end