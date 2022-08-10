-- tracking modifier for the talent
modifier_talent_tilted_scales = class({})

function modifier_talent_tilted_scales:IsHidden() 		return true end
function modifier_talent_tilted_scales:IsPurgable() 		return false end
function modifier_talent_tilted_scales:RemoveOnDeath() 	return false end