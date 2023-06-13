item_sacis_cap = class({})

LinkLuaModifier( "modifier_item_sacis_cap", "items/shop/tier3/item_sacis_cap.lua", LUA_MODIFIER_MOTION_NONE )

function item_sacis_cap:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
end

function item_sacis_cap:GetIntrinsicModifierName()
	return "modifier_item_sacis_cap"
end


-- only will need this if we're doing something like how overshooting blink punishes the user
-- function item_sacis_cap:GetCastRange(location, target)

-- end

function item_sacis_cap:OnAbilityPhaseStart()
    if self:GetCursorTarget() and self:GetCursorTarget() == self:GetCaster() then
    -- double tap
        for _, ent in pairs(Entities:FindAllByClassname("ent_dota_fountain")) do
            if ent:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
                self:GetCaster():SetCursorTargetingNothing(true)
                if self:GetCaster().GetPlayerID then
                    self:GetCaster():CastAbilityOnPosition(ent:GetAbsOrigin(), self, self:GetCaster():GetPlayerID())
                elseif self:GetCaster():GetOwner().GetPlayerID then
                    self:GetCaster():CastAbilityOnPosition(ent:GetAbsOrigin(), self, self:GetCaster():GetOwner():GetPlayerID())
                end

                break
            end
        end
    end

    return true
end

function item_sacis_cap:OnSpellStart()
	if self:GetCursorTarget() or self:GetCursorTarget() == self:GetCaster() then self:EndCooldown() return end

    local caster = self:GetCaster()
	local origin_point = caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()

    local distance = (target_point - origin_point):Length2D()
	local max_blink_range = self:GetSpecialValueFor("max_blink_range")

    -- if overshot, scale it down
    if distance > max_blink_range then
        target_point = origin_point + (target_point - origin_point):Normalized() * max_blink_range
    end

    -- NOTE: this has customizations in hero_extension for effects and sounds
    caster:Blink(target_point, false, true)
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_sacis_cap = modifier_item_sacis_cap or class({})

function modifier_item_sacis_cap:IsHidden() return true end
function modifier_item_sacis_cap:IsDebuff() return false end
function modifier_item_sacis_cap:IsPurgable() return false end
function modifier_item_sacis_cap:RemoveOnDeath() return false end

function modifier_item_sacis_cap:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_item_sacis_cap:OnTakeDamage( keys )
	local ability = self:GetAbility()
	local blink_damage_cooldown = ability:GetSpecialValueFor("blink_damage_cooldown")

	local parent = self:GetParent()					-- Modifier carrier
	local unit = keys.unit							-- Who took damage

	if parent == unit and keys.attacker:GetTeam() ~= parent:GetTeam() then
		-- Custom function from funcs.lua
		if keys.attacker:IsHeroDamage(keys.damage) then
			if ability:GetCooldownTimeRemaining() < blink_damage_cooldown then
				ability:StartCooldown(blink_damage_cooldown)
			end
		end
	end
end