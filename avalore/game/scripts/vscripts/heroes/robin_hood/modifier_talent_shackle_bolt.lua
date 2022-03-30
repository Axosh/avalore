-- tracking modifier for the talent
modifier_talent_shackle_bolt = class({})

function modifier_talent_shackle_bolt:IsHidden() 		return true end
function modifier_talent_shackle_bolt:IsPurgable() 		return false end
function modifier_talent_shackle_bolt:RemoveOnDeath() 	return false end