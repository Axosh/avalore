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
        --MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
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

    self.attack_queue_template = {self.HIT, self.MISS, self.REDUCED}
    self:ShuffleAttackQueue()
end

function modifier_drunk:ShuffleAttackQueue()
    self.attack_queue = shallowcopy( self.attack_queue_template )
    FYShuffle(self.attack_queue)
end

function modifier_drunk:OnAttackStart(keys)
    if not IsServer () then return end
    if keys.attacker == self:GetParent() then
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

function modifier_drunk:GetModifierMiss_Percentage()
    if self.miss_rate >  0 then
        local result = self.miss_rate
        self.miss_rate = 0
        return result
    end
    return 0
end

function modifier_drunk:GetModifierTotalDamageOutgoing_Percentage(keys)
    if self.percent_dmg < 100 then
        self:GetParent():EmitSound("Hero_BrewMaster.CinderBrew.SelfAttack")
        local result = self.percent_dmg
        self.percent_dmg = 100
        return result
    end
    return 100
end