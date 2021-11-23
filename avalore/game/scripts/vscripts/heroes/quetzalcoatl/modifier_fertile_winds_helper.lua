modifier_fertile_winds_helper = modifier_fertile_winds_helper or class({})

function modifier_fertile_winds_helper:IsDebuff()			return false end
function modifier_fertile_winds_helper:IsHidden() 			return true  end
function modifier_fertile_winds_helper:IsPurgable() 		return false end
function modifier_fertile_winds_helper:IsPurgeException() 	return false end
function modifier_fertile_winds_helper:IsStunDebuff() 		return false end
function modifier_fertile_winds_helper:RemoveOnDeath() 		return true  end

function modifier_fertile_winds_helper:DeclareFunctions()
	return  { MODIFIER_PROPERTY_IGNORE_CAST_ANGLE }
end

function modifier_fertile_winds_helper:GetModifierIgnoreCastAngle() return 360 end

function modifier_fertile_winds_helper:GetTexture()
	return "queztalcoatl/fertile_winds"
end

function modifier_fertile_winds_helper:OnCreated()
    if not IsServer() then return end

    local caster = self:GetCaster()
	EmitSoundOn("Hero_Phoenix.IcarusDive.Cast", caster)
end

function modifier_fertile_winds_helper:OnDestroy()
	if not IsServer() then return end

    local caster    = self:GetCaster()
	local point     = caster:GetAbsOrigin()
	--local ability   = self:GetAbility()

    -- local sub_ability_name	= "ability_fertile_winds"
	-- local main_ability_name	= "ability_fertile_winds_cancel"
	-- caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
	local ability_slot = 0 -- 0-indexed
    local spell_in_slot = self:GetCaster():GetAbilityByIndex(ability_slot):GetAbilityName() 
    self:GetCaster():SwapAbilities(spell_in_slot, "ability_fertile_winds", false, true)
    local curr_level_slot1 = self:GetCaster():FindAbilityByName(spell_in_slot):GetLevel()
    self:GetCaster():GetAbilityByIndex(ability_slot):SetLevel(curr_level_slot1)
    SwapSpells(self, ability_slot, "ability_fertile_winds")

    -- Anti-stuck
    --FindClearSpaceForUnit(caster, point, true)
	--GridNav:DestroyTreesAroundPoint(point, 150, true) -- find clear space doesn't seem to work all that well
end