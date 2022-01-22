modifier_consume_goat = class({})

function modifier_consume_goat:OnCreated()
    if not IsServer() then return end

    local ability = self:GetAbility()
    self.interval = ability:GetSpecialValueFor("heal_interval")
    self.heal_per_interval = ability:GetSpecialValueFor("heal_per_interval")

    self:StartIntervalThink( self.interval )
end

function modifier_consume_goat:OnIntervalThink()
    self:GetParent():Heal(self.heal_per_interval, self:GetCaster())
    SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_HEAL, self:GetParent(), self.heal_per_interval, self:GetParent())
end