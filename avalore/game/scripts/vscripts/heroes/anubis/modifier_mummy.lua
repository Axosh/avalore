modifier_mummy = class({})

LinkLuaModifier( "modifier_anesthesiology_slow", "scripts/vscripts/heroes/anubis/modifier_anesthesiology_slow", LUA_MODIFIER_MOTION_NONE )

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

function modifier_mummy:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_mummy:OnAttackLanded(kv)
    if not IsServer() then return end
    local player_hero = kv.attacker:GetMainControllingPlayer()
    if kv.attacker:HasTalent("talent_anesthesiology") then
        kv.target:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("ability_embalm"), "modifier_anesthesiology_slow", {duration = self:GetCaster():FindTalentValue("talent_anesthesiology", "duration") * (1 - kv.target:GetStatusResistance())})
    end
end