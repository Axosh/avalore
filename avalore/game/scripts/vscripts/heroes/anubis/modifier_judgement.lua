modifier_judgement = class({})

function modifier_judgement:IsHidden() return false end
function modifier_judgement:IsPurgable() return false end
function modifier_judgement:RemoveOnDeath() return true end

function modifier_judgement:OnCreated(kv)
    self.max_dmg = self:GetAbility():GetSpecialValueFor("max_damage")
    self.max_heal = self:GetAbility():GetSpecialValueFor("max_healing")

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_heartpiercer_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(self.particle, false, false, -1, true, true)

    if not IsServer() then return end
    self.damage_taken_counter = 1 -- default to healing if neither happens
    self.damage_given_counter = 0
end

function modifier_judgement:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_judgement:GetModifierIncomingDamage_Percentage(kv)
    if kv.attacker and self:GetRemainingTime() >= 0 then
        self.damage_taken_counter = self.damage_taken_counter + kv.damage
        --print("Damage Taken => " .. tostring(self.damage_taken_counter))
    end
end

function modifier_judgement:GetModifierTotalDamageOutgoing_Percentage(kv)
    if not IsServer() then return end

    if kv.attacker == self:GetParent() and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
        --self.damage_given_count = self.damage_given_count + 
        --print("OUTGOING DAMAGE ====================")
        --PrintTable(kv)
        self.damage_given_counter = self.damage_given_counter + kv.original_damage
    end
end

function modifier_judgement:OnDestroy()
    if not IsServer() then return end

    if self:GetCaster():HasTalent("talent_tilted_scales") then
        if self:GetParent():GetTeam() == self:GetCaster():GetTeam() then
            -- if ally, force heal
            self.damage_taken_counter = 999
            self.damage_given_counter = 0
        else
            -- if enemy, force damage
            self.damage_taken_counter = 0
            self.damage_given_counter = 999
        end
    end

    if self.damage_taken_counter > self.damage_given_counter then
        -- if this is imba, then maybe consider doing (taken/given) * max_heal
        self:GetParent():EmitSound("Hero_Oracle.FalsePromise.Healed")
        self.end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(self.end_particle)
        self:GetParent():Heal(self.max_heal, self:GetCaster())
    else
        -- if this is imba, then maybe consider doing (given/taken) * max_dmg
        self:GetParent():EmitSound("Hero_Oracle.FalsePromise.Damaged")
        self.end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(self.end_particle)
        local damageTable = {
            attacker        = self:GetCaster(),
            victim          = self:GetParent(),
            damage          = self.max_dmg,
            damage_type     = DAMAGE_TYPE_PURE,
            damage_flags    = DOTA_DAMAGE_FLAG_NONE,
            ability         = self:GetAbility()
        }
        ApplyDamage( damageTable )
        print("dealt damage")
    end
end