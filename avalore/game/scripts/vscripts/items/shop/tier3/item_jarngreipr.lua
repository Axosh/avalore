item_jarngreipr = class({})

LinkLuaModifier( "modifier_item_jarngreipr", "items/shop/tier3/item_jarngreipr.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_jarngreipr_active", "items/shop/tier3/item_jarngreipr.lua", LUA_MODIFIER_MOTION_NONE )

function item_jarngreipr:GetIntrinsicModifierName()
    return "modifier_item_jarngreipr"
end

function item_jarngreipr:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()

    local duration = self:GetSpecialValueFor("active_duration")

    target:AddNewModifier(
                            caster, -- player source
                            self, -- ability source
                            "modifier_item_jarngreipr_active", -- modifier name
                            { duration = duration } -- kv
                        )
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_jarngreipr = modifier_item_jarngreipr or class({})

function modifier_item_jarngreipr:IsHidden() return true end
function modifier_item_jarngreipr:IsDebuff() return false end
function modifier_item_jarngreipr:IsPurgable() return false end
function modifier_item_jarngreipr:RemoveOnDeath() return false end
function modifier_item_jarngreipr:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_jarngreipr:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_STATS_STRENGTH_BONUS      }
end

function modifier_item_jarngreipr:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
end

function modifier_item_jarngreipr:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_jarngreipr:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_jarngreipr:GetModifierBonusStats_Strength()
    return self.bonus_str
end

-- ====================================
-- ACTIVE MOD
-- ====================================
modifier_item_jarngreipr_active = modifier_item_jarngreipr_active or class({})

function modifier_item_jarngreipr_active:IsHidden() return false end
function modifier_item_jarngreipr_active:IsDebuff() return false end
function modifier_item_jarngreipr_active:IsPurgable() return true end

function modifier_item_jarngreipr_active:DeclareFunctions()
    --return {    MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE      }
    return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT }
end

function modifier_item_jarngreipr_active:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.shield = self.item_ability:GetSpecialValueFor("active_shield_capacity")
    self.particle = ParticleManager:CreateParticle("particles/items2_fx/pavise_friend.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_item_jarngreipr_active:GetTexture()
    return "items/Jarngreipr_orig"
end

-- function modifier_item_jarngreipr_active:GetModifierIncomingPhysicalDamage_Percentage()
--     if not IsServer() then return end


-- end

function modifier_item_jarngreipr_active:GetModifierIncomingPhysicalDamageConstant(params)
    if not IsServer() then return end

    -- show that damage is getting aborbed
    self:PlayEffects()

    -- block based on damage
	if params.damage>self.shield then
		self:Destroy()
		return -self.shield
	else
		self.shield = self.shield-params.damage
		return -params.damage
	end
end

function modifier_item_jarngreipr_active:PlayEffects()
    local particle = "particles/units/heroes/hero_bristleback/bristleback_back_dmg.vpcf"
    local sound_cast = "Hero_Bristleback.Bristleback"

    local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN, self:GetParent() )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        1,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        self:GetParent():GetOrigin(), -- unknown
        true -- unknown, true
    )
    EmitSoundOn( sound_cast, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end
