modifier_talent_rainstorm = modifier_talent_ride_the_stormwinds or class({})

function modifier_talent_rainstorm:IsHidden()         return true  end
function modifier_talent_rainstorm:IsPurgable()       return false end
function modifier_talent_rainstorm:RemoveOnDeath()    return false end