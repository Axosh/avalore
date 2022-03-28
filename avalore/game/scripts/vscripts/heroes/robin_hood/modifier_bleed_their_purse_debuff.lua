modifier_bleed_their_purse_debuff = class({})

function modifier_bleed_their_purse_debuff:IsHidden() return false end
function modifier_bleed_their_purse_debuff:IsDebuff() return true end
function modifier_bleed_their_purse_debuff:IsPurgeable() return true end
function modifier_bleed_their_purse_debuff:RemoveOnDeath() return true end

function modifier_bleed_their_purse_debuff:GetTexture()
    return "robin_hood/steal_from_rich"
end

function modifier_bleed_their_purse_debuff:OnCreated()
    self.gold_reduction = self:GetCaster():FindTalentValue("talent_bleed_their_purse", "reduction")
end

function modifier_bleed_their_purse_debuff:GoldReduction()
    return self.gold_reduction
end