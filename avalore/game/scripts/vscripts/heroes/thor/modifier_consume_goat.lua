modifier_consume_goat = class({})

function modifier_consume_goat:OnCreated()
    if not IsServer() then return end

    local ability = self:GetAbility()
    self.interval = ability:GetSpecialValueFor("heal_interval")
    self.heal_per_interval = ability:GetSpecialValueFor("heal_per_interval")

    self:StartIntervalThink( self.interval )
end

function modifier_consume_goat:OnIntervalThink()
    if self:GetCaster():HasTalent("talent_shared_sustenance") then
        -- find allies in radius
        local allies = FindUnitsInRadius(   self:GetCaster():GetTeamNumber(),
                                            self:GetCaster():GetAbsOrigin(),
                                            nil,
                                            self:GetCaster():FindTalentValue("talent_shared_sustenance", "heal_radius"),
                                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                            DOTA_UNIT_TARGET_FLAG_NONE,
                                            FIND_ANY_ORDER,
                                            false)

        -- do the heal
        for _, ally in pairs(allies) do
            ally:Heal(self.heal_per_interval, self:GetCaster())
            SendOverheadEventMessage(ally, OVERHEAD_ALERT_HEAL, ally, self.heal_per_interval, self:GetParent())
        end
    else
        self:GetParent():Heal(self.heal_per_interval, self:GetCaster())
        SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_HEAL, self:GetParent(), self.heal_per_interval, self:GetParent())
    end
end