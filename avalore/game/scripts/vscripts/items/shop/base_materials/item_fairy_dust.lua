item_fairy_dust = class({})

LinkLuaModifier( "modifier_fairy_dust_buff", "items/shop/base_materials/item_fairy_dust.lua", LUA_MODIFIER_MOTION_NONE )

function item_fairy_dust:GetBehavior() 
    return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function item_fairy_dust:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fairy_dust_buff", {duration = self:GetSpecialValueFor("flying_time")})

    -- update charges
    local new_charges = self:GetCurrentCharges() - 1
    if new_charges <= 0 then
        --self:Destroy() -- destroy doesn't trigger the inventory manager updat
        --self:GetPurchaser():RemoveItem(self)
        --self:SetCurrentCharges(new_charges)
        InventoryManager[self:GetCaster():GetPlayerOwnerID()]:Remove(self, true)
    else
        self:SetCurrentCharges(new_charges)
    end
end


modifier_fairy_dust_buff = modifier_fairy_dust_buff or class({})

function modifier_fairy_dust_buff:IsHidden()    return false end
function modifier_fairy_dust_buff:IsPurgeable() return true end
function modifier_fairy_dust_buff:IsDebuff()    return false end

function modifier_fairy_dust_buff:GetTexture()
    return "items/fairy_dust_orig"
end

function modifier_fairy_dust_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS }
end

function modifier_fairy_dust_buff:CheckState()
    return { [MODIFIER_STATE_FLYING] = true }
end

function modifier_fairy_dust_buff:GetActivityTranslationModifiers()
	return "hunter_night"
end

function modifier_fairy_dust_buff:OnCreated(kv)
    print("modifier_fairy_dust_buff > Created")
    -- sparkle fx
    local particle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_gold_sparkles.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    --local particle = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_2022_immortal/centaur_2022_immortal_stampede_gold_overhead_sparkles.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	--ParticleManager:SetParticleControl(particle, 1, Vector(200, 200, 200))
    ParticleManager:ReleaseParticleIndex(particle)
    -- wings fx
    self.particle_wings = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"
    self.particle_wings_fx = ParticleManager:CreateParticle(self.particle_wings, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

    ParticleManager:SetParticleControl(self.particle_wings_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(self.particle_wings_fx, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.particle_wings_fx, false, false, -1, false, false)
end