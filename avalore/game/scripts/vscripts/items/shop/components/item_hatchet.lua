-- NOTE: might go back and revise this later to make it kind of like the
--       HoN version of hatchet, but right now that will just slow dev time
--       while I'm trying to get an MVP out so...

item_hatchet = class({})

LinkLuaModifier( "modifier_item_hatchet", "items/shop/components/item_hatchet.lua", LUA_MODIFIER_MOTION_NONE )

function item_hatchet:GetIntrinsicModifierName()
    return "modifier_item_hatchet"
end

function item_hatchet:CastFilterResultTarget(hTarget)
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


-- function item_hatchet:GetCustomCastErrorTarget(hTarget)
-- 	if not IsServer() then return end

-- 	if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
-- 		if hTarget:IsOther() and not (string.find(hTarget:GetName(), "npc_dota_ward_base")) then
-- 			return "Ability Can't Target This Ward-Type Unit"
-- 		end
-- 	end
-- end

function item_hatchet:GetCastRange(location, target)
    --DOTA_UNIT_TARGET_TREE 
    -- if target and (target:IsCreature() or (target:IsOther() and (string.find(hTarget:GetName(), "npc_dota_ward_base")))) then
    --     return self.BaseClass.GetCastRange(self, location, target)
    -- else
        return self:GetSpecialValueFor("fell_tree_cast_range")
    -- end
end

function item_hatchet:GetCooldown(level)
	-- if IsClient() then
	-- 	return self.BaseClass.GetCooldown(self, level)
	-- elseif self:GetCursorTarget() and (self:GetCursorTarget().CutDown or self:GetCursorTarget():IsOther()) then
		return self:GetSpecialValueFor("fell_tree_cooldown")
	-- else
	-- 	return self.BaseClass.GetCooldown(self, level)
	-- end
end

function item_hatchet:OnSpellStart()
    if self:GetCursorTarget().CutDown then
		self:GetCursorTarget():CutDown(self:GetCaster():GetTeamNumber())
    -- else
    --     if not self:GetCursorTarget().IsCreep then
    --         print("THROW HATCHET")
    --     end
    end
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_hatchet = class({})

function modifier_item_hatchet:IsHidden() return true end
function modifier_item_hatchet:IsDebuff() return false end
function modifier_item_hatchet:IsPurgable() return false end
function modifier_item_hatchet:RemoveOnDeath() return false end
function modifier_item_hatchet:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_hatchet:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE      }
end

function modifier_item_hatchet:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.damage_bonus = self.item_ability:GetSpecialValueFor("damage_bonus")

end

function modifier_item_hatchet:GetModifierPreAttack_BonusDamage(keys)
	if not IsServer() then return end

	if (keys.target 
        and not keys.target:IsHero()
        and not keys.target:IsOther()
        and not keys.target:IsBuilding()
        and not string.find(keys.target:GetUnitName(), "npc_dota_lone_druid_bear")
        and keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber()
    ) then
		return self.damage_bonus
	end
end