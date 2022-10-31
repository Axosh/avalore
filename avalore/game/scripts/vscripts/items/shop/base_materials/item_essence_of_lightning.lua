item_essence_of_lightning = class({})

LinkLuaModifier( "modifier_item_essence_of_lightning", "items/shop/base_materials/item_essence_of_lightning.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_static_shock", "items/shop/base_materials/item_essence_of_lightning.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_avalore_stunned", "modifiers/modifier_avalore_stunned", LUA_MODIFIER_MOTION_NONE )

function item_essence_of_lightning:GetIntrinsicModifierName()
    return "modifier_item_essence_of_lightning"
end


-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_essence_of_lightning = modifier_item_essence_of_lightning or class({})

function modifier_item_essence_of_lightning:IsHidden()      return true  end
function modifier_item_essence_of_lightning:IsDebuff()      return false end
function modifier_item_essence_of_lightning:IsPurgable()    return false end
function modifier_item_essence_of_lightning:RemoveOnDeath() return false end

function modifier_item_essence_of_lightning:DeclareFunctions()
    return {    MODIFIER_EVENT_ON_UNIT_MOVED,
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_EVENT_ON_DEATH }
end

function modifier_item_essence_of_lightning:OnCreated(event)
    self.item_ability       = self:GetAbility()
    self.dist_to_charge     = self.item_ability:GetSpecialValueFor("dist_to_charge")
    self.mini_stun_dur      = self.item_ability:GetSpecialValueFor("mini_stun")
    self.shock_dmg          = self.item_ability:GetSpecialValueFor("shock_dmg")

    if not IsServer() then return end
    self.curr_charge        = 0
    self.curr_pos           = self:GetCaster():GetAbsOrigin()
end

-- EVENT
-- =======================================
-- new_pos: Vector
-- order_type: dotaunitorder_t
-- unit: CDOTA_BaseNPC
-- =======================================
function modifier_item_essence_of_lightning:OnUnitMoved(kv)
    if not IsServer() then return end

    if (kv.unit == self:GetCaster()) and (self.curr_charge < self.dist_to_charge) then
        self.curr_charge = self.curr_charge + CalculateDistance(self.curr_pos, kv.new_pos)
        self.curr_pos = kv.new_pos
        if self.curr_charge > self.dist_to_charge then
            self:GetCaster():AddNewModifier(
                                self:GetCaster(), -- player source
                                self.item_ability, -- ability source
                                "modifier_static_shock", -- modifier name
                                { } -- kv
                            )
        end
    end
end

function modifier_item_essence_of_lightning:OnAttackLanded(kv)
    if not IsServer() then return end

    local caster = self:GetCaster();
    if kv.attacker == caster and caster:HasModifier("modifier_static_shock") then

        local particle_cast = "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf"
	    local sound_cast = "Hero_razor.lightning"
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetParent() )
	    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() + Vector(0,0,500) )
        ParticleManager:SetParticleControlEnt(
            effect_cast,
            1,
            kv.target,
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        EmitSoundOn( sound_cast, kv.target )

        local damage = {
			victim = kv.target,
			attacker = self:GetCaster(),
			damage = self.shock_dmg,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.item_ability
		}
		ApplyDamage( damage )

        kv.target:AddNewModifier(
					self:GetCaster(), -- player source
					self, -- ability source
					"modifier_avalore_stunned", -- modifier name
					{ duration = self.mini_stun_dur } -- kv
				)

        self.curr_charge = 0
        self:GetParent():RemoveModifierByName("modifier_static_shock")
    end
end

function modifier_item_essence_of_lightning:OnDeath(kv)
    if kv.unit == self:GetParent() then
        -- if self:GetParent():HasModifier("modifier_static_shock") then
        --     self:GetParent():Remo
        -- end
        self.curr_charge = 0
    end
end


-- ====================================
-- BUFF MODIFIER 
-- ====================================

modifier_static_shock = modifier_static_shock or class({})

function modifier_static_shock:IsHidden()      return false end
function modifier_static_shock:IsDebuff()      return false end
function modifier_static_shock:IsPurgable()    return true end
function modifier_static_shock:RemoveOnDeath() return true end

function modifier_static_shock:GetTexture()
    return "items/essence_of_lightning_orig"
end