modifier_blind_debuff = class({})

function modifier_blind_debuff:IsHidden() return false end
function modifier_blind_debuff:IsPurgeable() return false end
function modifier_blind_debuff:IsDebuff() return true end

function modifier_blind_debuff:GetTexture()
    return "generic/blind"
end

function modifier_blind_debuff:OnCreated(kv)
    if not IsServer() then return end

    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent  = self:GetParent()

    -- store original for when modifier is removed
    self.original_vision_day = self.parent:GetBaseDayTimeVisionRange()
    self.original_vision_night = self.parent:GetBaseNightTimeVisionRange()

    -- set defaults (prior to kv override)
    self.vision_day = 100
    self.vision_night = 100

    if kv.vision_day then
        self.vision_day = kv.vision_day
    end

    if kv.vision_night then
        self.vision_night = kv.vision_night
    end

    -- TODO: probably need to specify whether to affect both, just day, or just night..
    self.parent:SetDayTimeVisionRange(self.vision_day)
    self.parent:SetNightTimeVisionRange(self.vision_night)
end

function modifier_blind_debuff:OnDestroy()
    if not IsServer() then return end

    self.parent:SetDayTimeVisionRange(self.original_vision_day)
    self.parent:SetNightTimeVisionRange(self.original_vision_night)
end