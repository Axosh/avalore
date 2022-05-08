modifier_talent_rainstorm = modifier_talent_rainstorm or class({})

function modifier_talent_rainstorm:IsHidden()         return true  end
function modifier_talent_rainstorm:IsPurgable()       return false end
function modifier_talent_rainstorm:RemoveOnDeath()    return false end