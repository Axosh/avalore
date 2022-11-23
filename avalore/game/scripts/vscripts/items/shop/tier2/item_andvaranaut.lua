item_andvaranaut = class({})

LinkLuaModifier( "modifier_item_andvaranaut", "items/shop/tier2/item_andvaranaut.lua", LUA_MODIFIER_MOTION_NONE )

function item_andvaranaut:GetIntrinsicModifierName()
    return "modifier_item_andvaranaut"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_andvaranaut = class({})

function modifier_item_andvaranaut:IsHidden() return true end
function modifier_item_andvaranaut:IsDebuff() return false end
function modifier_item_andvaranaut:IsPurgable() return false end
function modifier_item_andvaranaut:RemoveOnDeath() return false end
function modifier_item_andvaranaut:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_andvaranaut:DeclareFunctions()
    return {    MODIFIER_EVENT_ON_DEATH      }
end

function modifier_item_andvaranaut:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_gold_per_kill = self.item_ability:GetSpecialValueFor("bonus_gold_per_kill")
end

function modifier_item_andvaranaut:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_andvaranaut:OnDeath(kv)
    local caster = self:GetCaster()
	local ability = self:GetAbility()
	local attacker = kv.attacker
	local unit = kv.unit
	local reincarnate = kv.reincarnate
    if caster == attacker and not unit:IsBuilding() and not unit:IsIllusion() and not unit:IsTempestDouble() and caster:GetTeamNumber() ~= unit:GetTeamNumber() and unit.GetGoldBounty then
        if reincarnate then
			return nil
		end

        print("Bonus gold!")
        caster:ModifyGold(self.bonus_gold_per_kill, false, DOTA_ModifyGold_Unspecified)
		local player = PlayerResource:GetPlayer(caster:GetPlayerID())
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"
		local particle1 = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_ABSORIGIN, unit, player)
		ParticleManager:SetParticleControl(particle1, 0, unit:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle1, 1, unit:GetAbsOrigin())

        local symbol = 0 -- "+" presymbol
		local color = Vector(255, 200, 33) -- Gold
		local lifetime = 2
		local digits = 2
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
		local particle2 = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_ABSORIGIN, unit, player)
		ParticleManager:SetParticleControl(particle2, 1, Vector(symbol, self.bonus_gold_per_kill, symbol))
		ParticleManager:SetParticleControl(particle2, 2, Vector(lifetime, digits, 0))
		ParticleManager:SetParticleControl(particle2, 3, color)
    end
end