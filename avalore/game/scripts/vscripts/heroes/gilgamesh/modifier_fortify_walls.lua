modifier_fortify_walls = class({})

function modifier_fortify_walls:IsHidden() return false end
function modifier_fortify_walls:IsDebuff() return false end
function modifier_fortify_walls:IsPurgable() return true end

function modifier_fortify_walls:OnCreated(kv)
    self.armor_buff = self:GetAbility():GetSpecialValueFor( "armor_buff" )
    self.armor_particle = ParticleManager:CreateParticle("particles/items2_fx/medallion_of_courage_friend_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    --ParticleManager:SetParticleControl(self.armor_particle, 0, self:GetParent():GetAbsOrigin() + Vector(0, 0, 0))
	--ParticleManager:SetParticleControl(self.armor_particle, 1, Vector(self.shield_size, 0, 0))
    ParticleManager:SetParticleControlEnt(self.armor_particle, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.armor_particle, false, false, -1, false, false)
end

function modifier_fortify_walls:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_fortify_walls:GetModifierPhysicalArmorBonus()
    return self.armor_buff
end