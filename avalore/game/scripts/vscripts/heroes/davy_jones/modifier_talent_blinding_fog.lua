-- tracking modifier for the talent
modifier_talent_blinding_fog = class({})

function modifier_talent_blinding_fog:IsHidden() 		return true end
function modifier_talent_blinding_fog:IsPurgable() 		return false end
function modifier_talent_blinding_fog:RemoveOnDeath() 	return false end