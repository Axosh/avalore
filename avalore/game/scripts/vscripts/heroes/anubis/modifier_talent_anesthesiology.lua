-- tracking modifier for the talent
modifier_talent_anesthesiology = class({})

function modifier_talent_anesthesiology:IsHidden() 		return true end
function modifier_talent_anesthesiology:IsPurgable() 		return false end
function modifier_talent_anesthesiology:RemoveOnDeath() 	return false end