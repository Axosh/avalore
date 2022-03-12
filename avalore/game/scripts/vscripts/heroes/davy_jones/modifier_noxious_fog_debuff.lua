modifier_noxious_fog_debuff = class({})

function modifier_noxious_fog_debuff:IsDebuff() return true end
function modifier_noxious_fog_debuff:IsPurgable() return false end
function modifier_noxious_fog_debuff:IsHidden() return true end

function modifier_noxious_fog_debuff:OnCreated(kv)
    if not IsServer() then return end

    self.parent	= self:GetParent()
	
    self.radius = kv.radius
    self.damage_percent = self:GetAbility():GetTalentSpecialValueFor("damage_percent")
    self.tick_rate	= 1.0

    self:StartIntervalThink(self.tick_rate)
end

function modifier_noxious_fog_debuff:OnIntervalThink()
    local damage = self.parent:GetMaxHealth() * (self.damage_percent * self.tick_rate) / 100
    ApplyDamage(    {attacker = self:GetCaster(),
                    victim = self.parent,
                    ability = self:GetAbility(),
                    damage = damage,
                    damage_type = DAMAGE_TYPE_PURE,
                    damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
                    });

end