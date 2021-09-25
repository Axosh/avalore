require("references")
require(REQ_UTIL)

modifier_drunk = class({})

function modifier_drunk:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_debuff.vpcf"
end

function modifier_drunk:GetStatusEffectName()
	return "particles/status_fx/status_effect_brewmaster_cinder_brew.vpcf"
end

function modifier_drunk:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_drunk:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MISS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_drunk:OnCreated()
    if not IsServer() then return end
    self.HIT = 0 -- normal attack
    self.MISS = 1 -- miss
    self.REDUCED = 2 -- 50% damage
    
    self.miss_chance = 0 -- changes based on whether next attack is a miss
    self.percent_dmg = 100
    self.reduction = self:GetAbility():GetSpecialValueFor("reduction")
    self.movement_slow		= self:GetAbility():GetSpecialValueFor("movement_slow") * (-1)
    self.is_slow_interval = true
    self.countdown = 3

    self.attack_queue_template = {self.HIT, self.MISS, self.REDUCED}
    self:ShuffleAttackQueue()

    self:StartIntervalThink(1) -- 1 sec intervals
end

function modifier_drunk:OnIntervalThink(kv)
    if not IsServer() then return end

    self.countdown = self.countdown - 1
    if self.countdown == 0 then
        self.countdown = 3
        self.is_slow_interval = not self.is_slow_interval
    end
end

function modifier_drunk:GetModifierMoveSpeedBonus_Percentage(kv)
    if kv.unit == self:GetParent() then
        if self.is_slow_interval then
            return self.movement_slow
        end
    end
end

function modifier_drunk:ShuffleAttackQueue()
    self.attack_queue = shallowcopy( self.attack_queue_template )
    FYShuffle(self.attack_queue)
end

function modifier_drunk:OnAttackStart(kv)
    if not IsServer () then return end
    if kv.attacker == self:GetParent() then
        local next = next --https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
        local next_attack = table.remove(self.attack_queue)

        if next_attack == self.MISS then
            self.miss_chance = 1
        elseif next_attack == self.REDUCED then
            self.percent_dmg = 100 - self.reduction
        end

        if not next(self.attack_queue) then
            self:ShuffleAttackQueue()
        end
    end
end

function modifier_drunk:GetModifierMiss_Percentage(kv)
    if kv.attacker == self:GetParent() then
        if self.miss_rate >  0 then
            local result = self.miss_rate
            self.miss_rate = 0
            return result
        end
        return 0
    end
end

function modifier_drunk:GetModifierTotalDamageOutgoing_Percentage(kv)
    if kv.attacker == self:GetParent() then
        if self.percent_dmg < 100 then
            self:GetParent():EmitSound("Hero_BrewMaster.CinderBrew.SelfAttack")
            local result = self.percent_dmg
            self.percent_dmg = 100
            return result
        end
        return 100
    end
end