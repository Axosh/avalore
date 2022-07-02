-- tracking modifier for the talent
modifier_talent_multiple_immortality = class({})

function modifier_talent_multiple_immortality:IsHidden() 		return true  end
function modifier_talent_multiple_immortality:IsPurgable() 		return false end
function modifier_talent_multiple_immortality:RemoveOnDeath() 	return false end