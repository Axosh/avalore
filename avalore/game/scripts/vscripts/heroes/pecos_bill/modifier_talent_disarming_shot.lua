-- tracking modifier for talent
modifier_talent_disarming_shot = class({})

function modifier_talent_disarming_shot:IsHidden() 		return true  end
function modifier_talent_disarming_shot:IsPurgable()     return false end
function modifier_talent_disarming_shot:RemoveOnDeath()  return false end