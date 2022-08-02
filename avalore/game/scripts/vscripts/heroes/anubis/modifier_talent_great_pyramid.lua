-- tracking modifier for the talent
modifier_talent_great_pyramid = class({})

function modifier_talent_great_pyramid:IsHidden() 		return true end
function modifier_talent_great_pyramid:IsPurgable() 		return false end
function modifier_talent_great_pyramid:RemoveOnDeath() 	return false end