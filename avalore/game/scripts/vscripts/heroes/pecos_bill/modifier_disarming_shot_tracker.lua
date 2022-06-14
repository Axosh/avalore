modifier_disarming_shot_tracker = class({})

function modifier_disarming_shot_tracker:IsHidden() return false end
function modifier_disarming_shot_tracker:IsDebuff() return true end
function modifier_disarming_shot_tracker:IsStunDebuff() return false end
function modifier_disarming_shot_tracker:IsPurgable() return false end

function modifier_disarming_shot_tracker:GetTexture()
    return "pecos_bill/disarming_shot"
end

function modifier_disarming_shot_tracker:OnCreated()
    self:SetStackCount(1)
    print("modifier_disarming_shot_tracker:OnCreated()")
end

function modifier_disarming_shot_tracker:OnRefresh()
    self:IncrementStackCount()
    print("modifier_disarming_shot_tracker:OnRefresh()")
end