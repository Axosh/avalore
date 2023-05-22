item_avalore_lifesteal = class({})

LinkLuaModifier( "modifier_item_avalore_lifesteal", "items/shop/components/item_avalore_lifesteal.lua", LUA_MODIFIER_MOTION_NONE )

function item_avalore_lifesteal:GetIntrinsicModifierName()
    return "modifier_item_avalore_lifesteal"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_avalore_lifesteal = modifier_item_avalore_lifesteal or class({})

function modifier_item_avalore_lifesteal:IsHidden() return true end
function modifier_item_avalore_lifesteal:IsDebuff() return false end
function modifier_item_avalore_lifesteal:IsPurgable() return false end
function modifier_item_avalore_lifesteal:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_avalore_lifesteal:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_avalore_lifesteal:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_item_avalore_lifesteal:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.lifesteal_pct = self.item_ability:GetSpecialValueFor("lifesteal_pct")
    --self:SetStackCount( 1 )
end

function modifier_item_avalore_lifesteal:GetModifierProcAttack_Feedback(params)
    if not IsServer() then return end

    -- make sure we're targeting an enemy that we can lifesteal off of
    if (params.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber()
        and (not params.target:IsBuilding())
        and (not params.target:IsOther())
    ) then
        self.attack_record = params.record
    end
end

function modifier_item_avalore_lifesteal:OnTakeDamage(params)
    if not IsServer() then return end

    if self.attack_record and params.record == self.attack_record then
        self.attack_record = nil
        local heal = params.damage * self.lifesteal_pct/100
        self:GetParent():Heal( heal, self:GetAbility() )
        self:PlayEffects( self:GetParent() )
    end
end

function modifier_item_avalore_lifesteal:PlayEffects( target )
    local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end