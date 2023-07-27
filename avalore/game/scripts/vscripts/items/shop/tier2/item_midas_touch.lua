item_midas_touch = class({})

LinkLuaModifier( "modifier_item_midas_touch", "items/shop/tier2/item_midas_touch.lua", LUA_MODIFIER_MOTION_NONE )

function item_midas_touch:GetIntrinsicModifierName()
    return "modifier_item_midas_touch"
end

function item_midas_touch:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	local sound_cast = "DOTA_Item.Hand_Of_Midas"
    
    local bonus_gold = ability:GetSpecialValueFor("bonus_gold")
	local xp_multiplier = ability:GetSpecialValueFor("xp_multiplier")
    local bonus_xp = target:GetDeathXP()
    bonus_xp = bonus_xp * xp_multiplier

    target:EmitSound(sound_cast)
	SendOverheadEventMessage(PlayerResource:GetPlayer(caster:GetPlayerOwnerID()), OVERHEAD_ALERT_GOLD, target, bonus_gold, nil)

    local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

    -- Grant gold and XP only to the caster
	target:SetDeathXP(0)
	target:SetMinimumGoldBounty(0)
	target:SetMaximumGoldBounty(0)
	target:Kill(ability, caster)
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_midas_touch = modifier_item_midas_touch or class({})

function modifier_item_midas_touch:IsHidden() return true end
function modifier_item_midas_touch:IsDebuff() return false end
function modifier_item_midas_touch:IsPurgable() return false end
function modifier_item_midas_touch:RemoveOnDeath() return false end

function modifier_item_midas_touch:DeclareFunctions()
    return {   MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
                --MODIFIER_PROPERTY_TOOLTIP      }
end

function modifier_item_midas_touch:OnCreated( kv )
    self.item_ability       = self:GetAbility()
    -- self.gold_per_min       = self.item_ability:GetSpecialValueFor("gold_per_min")
    -- self.gold_per_tick      = self.gold_per_min / 30
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")

    -- if not IsServer() then return end
    -- self:StartIntervalThink(2)
end

-- function modifier_item_midas_touch:OnTooltip()
--     return self.gold_per_min
-- end

-- function modifier_item_midas_touch:OnIntervalThink()
--     if not IsServer() then return end

--     -- careful with this because gold_per_tick needs to be type "INT" or it takes the floor
--     self:GetParent():ModifyGold(self.gold_per_tick, false, DOTA_ModifyGold_AbilityGold)
-- end

function modifier_item_midas_touch:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end