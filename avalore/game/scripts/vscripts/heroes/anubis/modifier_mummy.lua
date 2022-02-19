modifier_mummy = class({})

function modifier_mummy:IsHidden() return false end
function modifier_mummy:IsDebuff() return false end
function modifier_mummy:IsPurgable() return false end

function modifier_mummy:GetTexture() 
    return "anubis/embalm"
end

function modifier_mummy:OnCreated(kv)
    if not IsServer() then return end

    local parent = self:GetParent()
    local caster = self:GetCaster()

    parent:SetTeam(caster:GetTeamNumber())
    parent:SetOwner(caster)
    parent:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
end

function modifier_mummy:OnDestroy(kv)
    if not IsServer() then return end

    self:GetParent():ForceKill(false)
end

function modifier_mummy:CheckState()
    return {
        [MODIFIER_STATE_DOMINATED] = true,
    }
end

function modifier_mummy:GetEffectName()
    return "particles/units/heroes/hero_undying/undying_zombie_spawn.vpcf"
end

function modifier_mummy:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end