modifier_talent_fear = class({})

function modifier_talent_fear:IsHidden() 		return true end
function modifier_talent_fear:IsPurgable() 		return false end
function modifier_talent_fear:RemoveOnDeath() 	return false end