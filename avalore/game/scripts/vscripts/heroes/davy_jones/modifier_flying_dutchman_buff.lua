-- tracking modifier for the talent
modifier_flying_dutchman_buff = class({})

function modifier_flying_dutchman_buff:IsHidden() 		return true end
function modifier_flying_dutchman_buff:IsPurgable() 		return false end
function modifier_flying_dutchman_buff:RemoveOnDeath() 	return false end