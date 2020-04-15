require("references")
--require(REQ_SCORE)
require("score")

modifier_wisp_regen = class({})

function modifier_wisp_regen:IsHidden() return false end
function modifier_wisp_regen:IsDebuff() return false end
function modifier_wisp_regen:IsPurgable() return false end

function modifier_wisp_regen:OnCreated()
    if IsServer() then
        print("modifier_wisp_regen:OnCreated()")
        print(self:GetParent():GetName())
        self.team = self:GetParent():GetOwner():GetTeam()
        print("TeamID = " .. self.team)
    end
end

function modifier_wisp_regen:GetTexture()
    return "wisp_spirits"
end

function modifier_wisp_regen:DeclareFunctions()
    local functs = {
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_ABILITY_BEHAVIOR_PASSIVE,
        DOTA_ABILITY_BEHAVIOR_AURA,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
    return functs
end

function modifier_wisp_regen:GetModifierConstantManaRegen()
    if Score.round1 then
        --print("modifier_wisp_regen:GetModifierConstantManaRegen()")
        if(self.team == DOTA_TEAM_GOODGUYS) then
            --print("Score.round1.radi_wisp_count = " .. tostring(Score.round1.radi_wisp_count))
            return (0.25 * Score.round1.radi_wisp_count)
        end

        return (0.25 * Score.round1.dire_wisp_count)
    end
end