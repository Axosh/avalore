-- tracking modifier for the talent
modifier_talent_osiris_will = class({})

function modifier_talent_osiris_will:IsHidden() 		return true end
function modifier_talent_osiris_will:IsPurgable() 		return false end
function modifier_talent_osiris_will:RemoveOnDeath() 	return false end