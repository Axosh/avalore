modifier_replenish_counter = class({})

function modifier_replenish_counter:IsHidden() return false end
function modifier_replenish_counter:IsDebuff() return false end
function modifier_replenish_counter:IsPurgable() return false end
function modifier_replenish_counter:RemoveOnDeath() return false end

function modifier_replenish_counter:OnCreated()
    print("hello world")
end

function modifier_replenish_counter:GetTexture()
    return "thor/replenish_goat"
end

-- -- make stackable
-- function modifier_replenish_counter:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end