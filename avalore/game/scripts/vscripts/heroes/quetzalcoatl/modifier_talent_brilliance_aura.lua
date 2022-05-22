-- tracking modifier for the talent
modifier_talent_brilliance_aura = class({})

function modifier_talent_brilliance_aura:IsHidden() 		return true end
function modifier_talent_brilliance_aura:IsPurgable() 		return false end
function modifier_talent_brilliance_aura:RemoveOnDeath() 	return false end