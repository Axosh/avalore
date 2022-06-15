-- tracking modifier for talent
modifier_talent_explosive_shells = class({})

function modifier_talent_explosive_shells:IsHidden() 		return true  end
function modifier_talent_explosive_shells:IsPurgable()     return false end
function modifier_talent_explosive_shells:RemoveOnDeath()  return false end