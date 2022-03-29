-- used to track how many times a unit has been hit by swashbuckle
-- then on a certain number of stacks, applies a debuff

modifier_swashbuckle_tracker_debuff = class({})

function modifier_swashbuckle_tracker_debuff:IsHidden() return true end
function modifier_swashbuckle_tracker_debuff:IsDebuff() return true end
function modifier_swashbuckle_tracker_debuff:IsPurgeable() return false end

function modifier_swashbuckle_tracker_debuff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_swashbuckle_tracker_debuff:OnRefresh()
    if not IsServer() then return end
    self:IncrementStackCount()
end

-- function modifier_swashbuckle_tracker_debuff:OnStackCountChanged(iStackCount)
--     if not IsServer() then return end

--     if iStackCount == 4 then
--         self:GetParent():AddNewModifier()
--     end
-- end