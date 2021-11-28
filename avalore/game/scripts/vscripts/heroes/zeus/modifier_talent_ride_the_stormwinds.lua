modifier_talent_ride_the_stormwinds = modifier_talent_ride_the_stormwinds or class({})

function modifier_talent_ride_the_stormwinds:IsHidden()         return true  end
function modifier_talent_ride_the_stormwinds:IsPurgable()       return false end
function modifier_talent_ride_the_stormwinds:RemoveOnDeath()    return false end