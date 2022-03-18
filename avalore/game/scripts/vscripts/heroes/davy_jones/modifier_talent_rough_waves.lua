-- tracking modifier for the talent
modifier_talent_rough_waves = class({})

function modifier_talent_rough_waves:IsHidden() 		return true end
function modifier_talent_rough_waves:IsPurgable() 		return false end
function modifier_talent_rough_waves:RemoveOnDeath() 	return false end