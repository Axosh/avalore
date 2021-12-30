modifier_boar_gore = modifier_boar_gore or class({})

-- Modifier properties
function modifier_boar_gore:IsDebuff() return false end
function modifier_boar_gore:IsHidden() return true end
function modifier_boar_gore:IsPurgable() return false end

function modifier_boar_gore:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return decFuncs
end

function modifier_boar_gore:OnAttackLanded(params)
	if IsServer() then
		-- Ability properties
		local target 	=	 params.target
		local parent	=	self:GetParent()
		local ability	=	self:GetAbility()
		-- Ability paramaters
		local duration	=	ability:GetSpecialValueFor("duration")
		-- When the boar attacks a target, apply poison on the target.
		if (parent == params.attacker) then
			if (target:IsCreep() or target:IsHero()) and not target:IsBuilding() then
				target:AddNewModifier(parent, ability, "modifier_boar_gore_debuff", {duration = duration * (1 - target:GetStatusResistance())})
			end
		end
	end
end