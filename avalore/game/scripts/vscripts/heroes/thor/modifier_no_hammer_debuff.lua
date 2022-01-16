modifier_no_hammer_debuff = class({})

function modifier_no_hammer_debuff:IsHidden() return false end
function modifier_no_hammer_debuff:IsDebuff() return true end
function modifier_no_hammer_debuff:IsPurgable() return false end
function modifier_no_hammer_debuff:RemoveOnDeath() return true end

function modifier_no_hammer_debuff:GetTexture()
    return "thor/no_hammer"
end

function modifier_no_hammer_debuff:OnCreated()
    if not IsServer() then return end
    self:GetCaster():AddActivityModifier("no_hammer")
    self:StartIntervalThink(FrameTime())
end

function modifier_no_hammer_debuff:OnIntervalThink()
    if not self:GetCaster():HasModifier("modifier_no_hammer") then
        self:GetCaster():ClearActivityModifiers()
        self:Destroy()
    end
end


function modifier_no_hammer_debuff:DeclareFunction()
    return  {
                MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
                --MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
                --MODIFIER_EVENT_ON_ATTACK_START
            }
end

function modifier_no_hammer_debuff:GetModifierAttackSpeedBonus_Constant()
    return -25
end

-- use the fist-attack animation
-- function modifier_no_hammer_debuff:GetActivityTranslationModifiers()
--     return "no_hammer"
-- end

-- function modifier_no_hammer_debuff:OnAttackStart(kv)
--     if not IsServer () then return end

--     if kv.attacker == self:GetParent() then
--         local caster = self:GetCaster()
--         self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
--         self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK2)
--         self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK_EVENT)
--         self:GetCaster():StopAnimation()
--         -- try to use fist animation
--         caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_SPECIAL, self:GetParent():GetAttacksPerSecond())
--     end
-- end