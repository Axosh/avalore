-- tracking modifier for the talent
modifier_talent_rebirth = class({})

function modifier_talent_rebirth:IsHidden() 		return true end
function modifier_talent_rebirth:IsPurgable() 		return false end
function modifier_talent_rebirth:RemoveOnDeath() 	return false end