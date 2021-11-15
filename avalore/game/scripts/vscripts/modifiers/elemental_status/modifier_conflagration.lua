modifier_conflagration = class({})

function modifier_conflagration:IsHidden() return false end
function modifier_conflagration:IsDebuff() return true end

function modifier_conflagration:GetTexture()
    return "elemental_status/conflagration"
end

function modifier_conflagration:OnCreated(kv)
    if not IsServer() then return end

    self:IncrementStackCount()

    -- Precache damage table
	self.damageTable = {
		victim      = self:GetParent(),
		attacker    = self:GetCaster(),
        damage_type = DAMAGE_TYPE_MAGICAL,
		ability     = nil --self:GetAbility()
	}

    self:StartIntervalThink(1)
end

function modifier_conflagration:OnRefresh(kv)
    if not IsServer() then return end

    self:IncrementStackCount()
end

function modifier_conflagration:OnIntervalThink()
   if not IsServer() then return end
   
   self.damageTable.damage = (self:GetStackCount() * 3)
   ApplyDamage(damageTable)
end