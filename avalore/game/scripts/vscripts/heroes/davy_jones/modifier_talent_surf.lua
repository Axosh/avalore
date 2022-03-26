-- tracking modifier for the talent
modifier_talent_surf = class({})

function modifier_talent_surf:IsHidden() 		return true end
function modifier_talent_surf:IsPurgable() 		return false end
function modifier_talent_surf:RemoveOnDeath() 	return false end