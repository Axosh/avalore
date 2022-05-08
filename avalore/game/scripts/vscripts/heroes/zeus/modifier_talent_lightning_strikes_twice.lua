modifier_talent_lightning_strikes_twice = modifier_talent_lightning_strikes_twice or class({})

function modifier_talent_lightning_strikes_twice:IsHidden()         return true  end
function modifier_talent_lightning_strikes_twice:IsPurgable()       return false end
function modifier_talent_lightning_strikes_twice:RemoveOnDeath()    return false end