LinkLuaModifier("modifier_ul_grab_debuff",    "scripts/vscripts/units/urban_legends/chainsaw_murderer/ability_ul_grab.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ul_grab_self",    "scripts/vscripts/units/urban_legends/chainsaw_murderer/ability_ul_grab.lua", LUA_MODIFIER_MOTION_NONE)


function ability_ul_grab:OnSpellStart()
	local target = self:GetCursorTarget()
	
	if target:TriggerSpellAbsorb(self) then return end

    target:AddNewModifier(self:GetCaster(), self, "modifier_ul_grab_debuff", {})
	
	self:GetCaster():EmitSound("Hero_Batrider.FlamingLasso.Cast")

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ul_grab_self", {})
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
	self.interval			= FrameTime()
	self.vector				= self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
	self.current_position	= self:GetCaster():GetAbsOrigin()

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
	
	if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > self.drag_distance then
		self:GetParent():SetAbsOrigin(GetGroundPosition(self:GetCaster():GetAbsOrigin() + self.vector:Normalized() * self.drag_distance, nil))
	end
end

function modifier_ul_grab_debuff:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():StopSound("Hero_Batrider.FlamingLasso.Loop")
	self:GetParent():EmitSound("Hero_Batrider.FlamingLasso.End")

	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)	
end

function modifier_ul_grab_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED]							= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true
	}
end

function modifier_ul_grab_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
end

function modifier_ul_grab_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

-- ===============================================
-- MODIFIER - GRAB SELF
-- ===============================================

modifier_ul_grab_self = modifier_ul_grab_self or class({})

function modifier_ul_grab_self:IsPurgable()	return false end
	
function modifier_ul_grab_self:OnCreated()
	self.dmg_to_drop	= self:GetAbility():GetSpecialValueFor("dmg_to_drop")
end

function modifier_ul_grab_self:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_ul_grab_self:GetOverrideAnimation()
	return ACT_DOTA_LASSO_LOOP
end

-- not actually doing any manipulation of this, just need to count how much damage until we drop
function modifier_ul_grab_self:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end

	return 0
end