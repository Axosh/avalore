modifier_synergy = class({})

LinkLuaModifier( "modifier_talent_synergy", "scripts/vscripts/heroes/gilgamesh/modifier_talent_synergy.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_synergy:IsHidden()    return false end
function modifier_synergy:IsPurgable()    return false end
function modifier_synergy:RemoveOnDeath()    return false end

function modifier_synergy:GetTexture()
    return "gilgamesh/synergy"
end

function modifier_synergy:OnCreated(kv)
    
    self.bonus_attack_speed = self:GetCaster():FindTalentValue("talent_synergy", "bonus_as")
    self.bonus_move_speed = 0

    if not IsServer() then return end

    --if kv.is_enkidu then
        self:StartIntervalThink(FrameTime())
    --end
end

-- synchronize move speeds
function modifier_synergy:OnIntervalThink()
    --if not IsServer() then return end

    -- re-read this due to race condition
    if self.bonus_attack_speed == 0 then
        self.bonus_attack_speed = self:GetCaster():FindTalentValue("talent_synergy", "bonus_as")
    end

    -- only update for Enkidu
    if self:GetParent() ~= self:GetCaster() then
        local enkidu_speed = self:GetParent():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), false)
        local gilgamesh_speed = self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), false)
        self.bonus_move_speed = gilgamesh_speed - enkidu_speed
    end

    --print("Gilga = " .. tostring(gilgamesh_speed) .. " || Enk = " .. tostring(enkidu_speed))

    --self:GetParent():SetBaseMoveSpeed(self:GetCaster():GetBaseMoveSpeed())
end

function modifier_synergy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end

function modifier_synergy:GetModifierAttackSpeedBonus_Constant(kv)
    return self.bonus_attack_speed
end

function modifier_synergy:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end