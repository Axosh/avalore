-- tracking modifier for talent
modifier_talent_rope_em_in = class({})

function modifier_talent_rope_em_in:IsHidden() 		 return true  end
function modifier_talent_rope_em_in:IsPurgable()     return false end
function modifier_talent_rope_em_in:RemoveOnDeath()  return false end