-- tracking modifier for talent
modifier_talent_class_5_twister = class({})

function modifier_talent_class_5_twister:IsHidden() 		return true  end
function modifier_talent_class_5_twister:IsPurgable()     return false end
function modifier_talent_class_5_twister:RemoveOnDeath()  return false end