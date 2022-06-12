-- tracking modifier for talent
modifier_talent_drive = class({})

function modifier_talent_drive:IsHidden() 		return true  end
function modifier_talent_drive:IsPurgable()     return false end
function modifier_talent_drive:RemoveOnDeath()  return false end