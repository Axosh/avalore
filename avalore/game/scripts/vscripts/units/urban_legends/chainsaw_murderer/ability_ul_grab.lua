ability_ul_grab = ability_ul_grab or class({})

LinkLuaModifier("modifier_ul_grab_debuff",    "scripts/vscripts/units/urban_legends/chainsaw_murderer/ability_ul_grab.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ul_grab_self",    "scripts/vscripts/units/urban_legends/chainsaw_murderer/ability_ul_grab.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_avalore_stunned", "modifiers/modifier_avalore_stunned", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_avalore_not_auto_attackable", "scripts/vscripts/modifiers/modifier_avalore_not_auto_attackable.lua", LUA_MODIFIER_MOTION_NONE )


function ability_ul_grab:OnSpellStart()
	local target = self:GetCursorTarget()

	print("[ability_ul_grab] Target = " .. target:GetName() .. " with entindex " .. tostring(target:entindex()))
	
	if target:TriggerSpellAbsorb(self) then return end

    local target_mod = target:AddNewModifier(self:GetCaster(), self, "modifier_ul_grab_debuff", {})
	
	self:GetCaster():EmitSound("Hero_Batrider.FlamingLasso.Cast")

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ul_grab_self", { target_ent_index = target:entindex() })
end

-- ===============================================
-- MODIFIER - GRAB DEBUFF
-- ===============================================

modifier_ul_grab_debuff = modifier_ul_grab_debuff or class({})

function modifier_ul_grab_debuff:IsDebuff() return true end

function modifier_ul_grab_debuff:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_flaming_lasso_generic_smoke.vpcf"
end

function modifier_ul_grab_debuff:OnCreated(params)
	if not IsServer() then return end

	self.drag_distance			= self:GetAbility():GetSpecialValueFor("drag_distance")
	self.break_distance			= self:GetAbility():GetSpecialValueFor("break_distance")
	self.interval			= FrameTime()
	self.vector				= self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
	self.current_position	= self:GetCaster():GetAbsOrigin()
	self.dmg_to_drop	= self:GetAbility():GetSpecialValueFor("dmg_to_drop")

	-- so we don't get a cluster of lane creeps following
	self.non_auto_attack_mod = self:GetParent():AddNewModifier(self, nil, "modifier_avalore_not_auto_attackable", {})

	self.radi_tree = Entities:FindByName(nil, UL_TREE_RADI)
	self.dire_tree = Entities:FindByName(nil, UL_TREE_DIRE)

	self:GetParent():EmitSound("Hero_Batrider.FlamingLasso.Loop")
	
	self.lasso_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flaming_lasso.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.lasso_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.lasso_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.lasso_particle, false, false, -1, false, false)

	self:StartIntervalThink(self.interval)
end

function modifier_ul_grab_debuff:OnIntervalThink()
	self.vector				= self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
	self.current_position	= self:GetCaster():GetAbsOrigin()

	-- if we're super far away (problem, some sort of teleport) then break the chain
	if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > self.break_distance then
		self:Destroy()
	end
	
	-- keep behind
	if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > self.drag_distance then
		self:GetParent():SetAbsOrigin(GetGroundPosition(self:GetCaster():GetAbsOrigin() + self.vector:Normalized() * self.drag_distance, nil))
	end
end

function modifier_ul_grab_debuff:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():StopSound("Hero_Batrider.FlamingLasso.Loop")
	self:GetParent():EmitSound("Hero_Batrider.FlamingLasso.End")

	self.non_auto_attack_mod:Destroy()
	-- local non_auto_attack_mod =	self:FindModifierByName("modifier_avalore_not_auto_attackable")
	-- if non_auto_attack_mod then
	-- 	non_auto_attack_mod:Destroy()
	-- end

	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
end

function modifier_ul_grab_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED]							= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true
	}
end

function modifier_ul_grab_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_ul_grab_debuff:OnTooltip()
	return self.dmg_to_drop
end

function modifier_ul_grab_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

-- ===============================================
-- MODIFIER - GRAB SELF
-- ===============================================

modifier_ul_grab_self = modifier_ul_grab_self or class({})

function modifier_ul_grab_self:IsHidden() return false end

function modifier_ul_grab_self:IsPurgable()	return false end
	
function modifier_ul_grab_self:OnCreated(kv)
	self.dmg_to_drop	= self:GetAbility():GetSpecialValueFor("dmg_to_drop")
	self.dmg_to_drop_remaining = self.dmg_to_drop

	if IsServer() then
		print("Target Ent Index => " .. tostring(kv.target_ent_index))
		self.target = EntIndexToHScript(kv.target_ent_index)
		self.tree_radi = Entities:FindByName(nil, "trigger_radi_tree")
		self.tree_dire = Entities:FindByName(nil, "trigger_dire_tree")
	end

	self.interval			= FrameTime()

	self:StartIntervalThink(self.interval)
end

function modifier_ul_grab_self:DeclareFunctions()
	return { 	MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
				MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
				MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_ul_grab_self:GetOverrideAnimation()
	return ACT_DOTA_LASSO_LOOP
end

function modifier_ul_grab_self:OnTooltip()
	return self.dmg_to_drop_remaining
end

-- not actually doing any manipulation of this, just need to count how much damage until we drop
function modifier_ul_grab_self:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end

	self.dmg_to_drop_remaining = self.dmg_to_drop_remaining - kv.damage

	if self.dmg_to_drop_remaining <= 0 then
		self.target:FindModifierByName("modifier_ul_grab_debuff"):Destroy()
		self:Destroy()
	end

	return 0
end


function modifier_ul_grab_self:OnIntervalThink()
	if not IsServer() then return end

	-- if the child mod is somehow gone, then get rid of this one
	if not self.target:FindModifierByName("modifier_ul_grab_debuff") then
		print("[modifier_ul_grab_self] Grab Target Broke Free")
		self:GetParent():AddNewModifier(
				self:GetParent(), -- player source
				self, -- ability source
				"modifier_avalore_stunned", -- modifier name
				{ duration = 5.0 } -- kv
			)
		self:Destroy()
	end

	-- idk if this actually is working
	if self.tree_radi:IsTouching(self:GetParent()) or self.tree_dire:IsTouching(self:GetParent()) then
		print("[modifier_ul_grab_self] Made it to Sacrifice Tree")
		self.target:Kill(self:GetAbility(), self:GetParent())
	end
end

function modifier_ul_grab_self:Complete()
	if not IsServer() then return end
	self.target:Kill(self:GetAbility(), self:GetParent())
end

function modifier_ul_grab_self:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():StopSound("Hero_Batrider.FlamingLasso.Loop")
	self:GetParent():EmitSound("Hero_Batrider.FlamingLasso.End")
end