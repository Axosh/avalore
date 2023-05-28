-- NOTE: might go back and revise this later to make it kind of like the
--       HoN version of hatchet, but right now that will just slow dev time
--       while I'm trying to get an MVP out so...

item_paul_bunyans_axe = class({})

LinkLuaModifier( "modifier_item_paul_bunyans_axe", "items/shop/tier3/item_paul_bunyans_axe.lua", LUA_MODIFIER_MOTION_NONE )

function item_paul_bunyans_axe:GetIntrinsicModifierName()
    return "modifier_item_paul_bunyans_axe"
end

function item_paul_bunyans_axe:CastFilterResultTarget(hTarget)
    if not IsServer() then return end

    -- if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
    --     if (hTarget:IsOther() and (string.find(hTarget:GetName(), "npc_dota_ward_base"))) and not hTarget:IsRoshan() then
    --         return UF_SUCCESS
    --     else
    --         return UF_FAIL_CUSTOM
    --     end
    -- end

        -- Otherwise just follow the standard unit filtering and use the standard cast errors
	return UnitFilter( hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber() )
end


-- function item_paul_bunyans_axe:GetCustomCastErrorTarget(hTarget)
-- 	if not IsServer() then return end

-- 	if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
-- 		if hTarget:IsOther() and not (string.find(hTarget:GetName(), "npc_dota_ward_base")) then
-- 			return "Ability Can't Target This Ward-Type Unit"
-- 		end
-- 	end
-- end

function item_paul_bunyans_axe:GetCastRange(location, target)
    --DOTA_UNIT_TARGET_TREE 
    -- if target and (target:IsCreature() or (target:IsOther() and (string.find(hTarget:GetName(), "npc_dota_ward_base")))) then
    --     return self.BaseClass.GetCastRange(self, location, target)
    -- else
        return self:GetSpecialValueFor("fell_tree_cast_range")
    -- end
end

function item_paul_bunyans_axe:GetCooldown(level)
	-- if IsClient() then
	-- 	return self.BaseClass.GetCooldown(self, level)
	-- elseif self:GetCursorTarget() and (self:GetCursorTarget().CutDown or self:GetCursorTarget():IsOther()) then
		return self:GetSpecialValueFor("fell_tree_cooldown")
	-- else
	-- 	return self.BaseClass.GetCooldown(self, level)
	-- end
end

function item_paul_bunyans_axe:OnSpellStart()
    if self:GetCursorTarget().CutDown then
		self:GetCursorTarget():CutDown(self:GetCaster():GetTeamNumber())
    -- else
    --     if not self:GetCursorTarget().IsCreep then
    --         print("THROW paul_bunyans_axe")
    --     end
    else
        -- they ground targeted => find nearby trees
    end
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_paul_bunyans_axe = class({})

function modifier_item_paul_bunyans_axe:IsHidden() return true end
function modifier_item_paul_bunyans_axe:IsDebuff() return false end
function modifier_item_paul_bunyans_axe:IsPurgable() return false end
function modifier_item_paul_bunyans_axe:RemoveOnDeath() return false end
function modifier_item_paul_bunyans_axe:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_paul_bunyans_axe:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_ATTACK_LANDED      }
end

function modifier_item_paul_bunyans_axe:OnCreated(event)
    self.item_ability           = self:GetAbility()
    self.bonus_dmg              = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_str              = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_hp_regen         = self.item_ability:GetSpecialValueFor("bonus_hp_regen")
    -- Cleave (if item owner is melee) ==> this is handled in the check before DoCleave
    --if self:GetParent():GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
    self.cleave_damage_percent  = self.item_ability:GetSpecialValueFor("cleave_damage_percent")
    self.cleave_starting_width  = self.item_ability:GetSpecialValueFor("cleave_starting_width")
    self.cleave_ending_width    = self.item_ability:GetSpecialValueFor("cleave_ending_width")
    self.cleave_distance        = self.item_ability:GetSpecialValueFor("cleave_distance")
    --end
end

function modifier_item_paul_bunyans_axe:GetModifierPreAttack_BonusDamage(keys)
	return self.bonus_dmg
end

function modifier_item_paul_bunyans_axe:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_paul_bunyans_axe:GetModifierConstantHealthRegen()
    return self.bonus_hp_regen
end

function modifier_item_paul_bunyans_axe:OnAttackLanded(keys)
    if (self:GetAbility():GetName() == "item_paul_bunyans_axe"
        and keys.attacker == self:GetParent()
        and not self:GetParent():IsRangedAttacker()
        and self:GetParent():IsAlive()
        and not self:GetParent():IsIllusion()
        and not keys.target:IsBuilding()
        and not keys.target:IsOther()
        and self:GetParent():GetTeamNumber() ~= keys.target:GetTeamNumber()
    ) then
        DoCleaveAttack( self:GetParent(),
                        keys.target,
                        self.item_ability,
                        keys.damage * self.cleave_damage_percent * 0.01,
                        self.cleave_starting_width,
                        self.cleave_ending_width,
                        self.cleave_distance,
                        "particles/items_fx/battlefury_cleave.vpcf")
    end
end