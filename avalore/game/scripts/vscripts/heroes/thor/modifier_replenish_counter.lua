modifier_replenish_counter = modifier_replenish_counter or  class({})

function modifier_replenish_counter:IsHidden() return true end
function modifier_replenish_counter:IsDebuff() return false end
function modifier_replenish_counter:IsPurgable() return false end
function modifier_replenish_counter:RemoveOnDeath() return false end

-- -- make stackable
-- function modifier_replenish_counter:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end