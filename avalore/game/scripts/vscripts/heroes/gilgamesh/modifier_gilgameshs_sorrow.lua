modifier_gilgameshs_sorrow = class({})

-- hide if we don't have an active count-down timer
function modifier_gilgameshs_sorrow:IsHidden()
    return self:GetStackCount() == 6
end
function modifier_gilgameshs_sorrow:IsPurgable()	return false end
function modifier_gilgameshs_sorrow:RemoveOnDeath() return false end
function modifier_gilgameshs_sorrow:IsDebuff()      return true end
function modifier_gilgameshs_sorrow:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_gilgameshs_sorrow:GetTexture()
    return "gilgamesh/gilgameshs_sorrow"
end

function modifier_gilgameshs_sorrow:OnCreated(kv)
    if not IsServer() then return end

    print("Added: modifier_gilgameshs_sorrow")

    self.enkidu_ref = kv.enkidu_ref
    -- if self.enkidu_ref ~= nil then
    --     print(tostring(self.enkidu_ref))
    --     print(tostring(self.enkidu_ref:IsAlive()))
    -- end
    self.debuffed = false
    self:SetStackCount(6)
    self:StartIntervalThink(1)
end

function modifier_gilgameshs_sorrow:UpdateEnkiduRef(enk_ref)
    print("modifier_gilgameshs_sorrow:UpdateEnkiduRef(enk_ref)")
    self.enkidu_ref = enk_ref
    -- if self.enkidu_ref ~= nil then
    --     print(tostring(self.enkidu_ref))
    --     print(tostring(self.enkidu_ref:IsAlive()))
    -- end
    self.debuffed = false
    self:SetStackCount(6)
end

function modifier_gilgameshs_sorrow:OnIntervalThink()
    if not IsServer() then return end

    -- if self.enkidu_ref ~= nil then
    --     print(tostring(self.enkidu_ref))
    --     print(tostring(self.enkidu_ref:IsAlive()))
    -- end

    -- check if enkidu is dead
    if not (self.enkidu_ref and self.enkidu_ref:IsAlive()) then
        -- check grace period
        if self:GetStackCount() > 0 then
            self:SetStackCount((self:GetStackCount() - 1))
        -- apply debuff
        elseif not self.debuffed then
            self.debuffed = true
            -- apply damage

            ApplyDamage({
				victim = self:GetParent(),
				attacker = self:GetParent(),
				damage = 300,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
				ability = nil
			})
        end
    else
        self:SetStackCount(6)
    end
end

function modifier_gilgameshs_sorrow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_gilgameshs_sorrow:GetModifierMoveSpeedBonus_Percentage()
    if self:GetStackCount() == 0 then
        return -25
    end
end

function modifier_gilgameshs_sorrow:GetModifierAttackSpeedBonus_Constant()
    if self:GetStackCount() == 0 then
        return -25
    end
end