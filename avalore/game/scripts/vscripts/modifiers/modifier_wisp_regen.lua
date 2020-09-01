require("references")
--require(REQ_SCORE)
require("score")

modifier_wisp_regen = class({})

function modifier_wisp_regen:IsHidden() return false end
function modifier_wisp_regen:IsDebuff() return false end
function modifier_wisp_regen:IsPurgable() return false end
function modifier_wisp_regen:RemoveOnDeath() return false end

function modifier_wisp_regen:OnCreated()
    --if IsServer() then
    print("[modifier_wisp_regen] modifier_wisp_regen:OnCreated()")
    --print("[modifier_wisp_regen] " .. self:GetParent():GetName())
    --self.team = self:GetParent():GetOwner():GetTeam()
    --print("[modifier_wisp_regen] TeamID = " .. self.team)
    local mana_regen_mult = 0.25
    if self.mana_regen == nil then
        self.mana_regen = mana_regen_mult
    else
        self.mana_regen = self.mana_regen + mana_regen_mult
    end
    
    -- if (self.team == DOTA_TEAM_GOODGUYS) then
    --     self.mana_regen = (mana_regen_mult * Score.round1.radi_wisp_count)
    -- elseif (self.team == DOTA_TEAM_BADGUYS) then 
    --     self.mana_regen = (mana_regen_mult * Score.round1.dire_wisp_count)
    -- end
    print("[modifier_wisp_regen] init mana_regen = " .. tostring(self.mana_regen))
    --end
end

function modifier_wisp_regen:OnRefresh()
    self:OnCreated()
end

function modifier_wisp_regen:GetTexture()
    return "wisp_spirits"
end

function modifier_wisp_regen:DeclareFunctions()
    local functs = {
        --DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        --DOTA_ABILITY_BEHAVIOR_PASSIVE,
        --DOTA_ABILITY_BEHAVIOR_AURA,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
    return functs
end

function modifier_wisp_regen:GetModifierConstantManaRegen(params)
    --if IsServer() and self.mana_regen ~= nil then
    --print("[modifier_wisp_regen] mana_regen = " .. tostring(self.mana_regen))
    return self.mana_regen
    --end
    --if Score.round1 then

    --print("modifier_wisp_regen:GetModifierConstantManaRegen()")
    -- if(self.team == DOTA_TEAM_GOODGUYS) then
    --     --print("[modifier_wisp_regen] Score.round1.radi_wisp_count = " .. tostring(Score.round1.radi_wisp_count))
    --     return (0.25 * Score.round1.radi_wisp_count)
    -- end

    -- --print("[modifier_wisp_regen] Score.round1.dire_wisp_count = " .. tostring(Score.round1.dire_wisp_count))
    -- return (0.25 * Score.round1.dire_wisp_count)

    --end
end