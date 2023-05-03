item_nemean_lions_hide = class({})

LinkLuaModifier( "modifier_item_nemean_lions_hide", "items/shop/tier4/item_nemean_lions_hide.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_nemean_lions_hide_buff", "items/shop/tier4/item_nemean_lions_hide.lua", LUA_MODIFIER_MOTION_NONE )

function item_nemean_lions_hide:GetIntrinsicModifierName()
    return "modifier_item_nemean_lions_hide"
end

function item_nemean_lions_hide:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local sound_cast = "DOTA_Item.BlackKingBar.Activate"
    local duration = ability:GetSpecialValueFor("duration")

    -- Play cast sound
    EmitSoundOn(sound_cast, caster)

    -- Apply basic dispel
    caster:Purge(false, true, false, false, false)

    -- grant buff
    caster:AddNewModifier(caster, ability, "modifier_item_nemean_lions_hide_buff", {duration = duration})
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_nemean_lions_hide = modifier_item_nemean_lions_hide or class({})

function modifier_item_nemean_lions_hide:IsHidden() return true end
function modifier_item_nemean_lions_hide:IsDebuff() return false end
function modifier_item_nemean_lions_hide:IsPurgable() return false end
function modifier_item_nemean_lions_hide:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
--function modifier_item_nemean_lions_hide:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_nemean_lions_hide:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_item_nemean_lions_hide:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_strength")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_damage")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.magic_resist = self.item_ability:GetSpecialValueFor("magic_resist")
end

function modifier_item_nemean_lions_hide:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_nemean_lions_hide:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_nemean_lions_hide:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_nemean_lions_hide:GetModifierMagicalResistanceBonus()
    return self.magic_resist
end

-- ==========================================================
-- BUFF
-- ==========================================================

modifier_item_nemean_lions_hide_buff = modifier_item_nemean_lions_hide_buff or class({})

function modifier_item_nemean_lions_hide_buff:IsHidden() return false end
function modifier_item_nemean_lions_hide_buff:IsPurgable() return false end
function modifier_item_nemean_lions_hide_buff:IsDebuff() return false end

function modifier_item_nemean_lions_hide_buff:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_item_nemean_lions_hide_buff:GetTexture()
    return "items/nemean_lion_hide"
end

function modifier_item_nemean_lions_hide_buff:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

    -- Ability properties
    self.ability = self:GetAbility()

    -- Ability specials
    --self.model_scale = self.ability:GetSpecialValueFor("model_scale")
end


function modifier_item_nemean_lions_hide_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_nemean_lions_hide_buff:CheckState()
    local state = {[MODIFIER_STATE_MAGIC_IMMUNE] = true}

    return state
end

-- function modifier_item_nemean_lions_hide_buff:DeclareFunctions()
--     local decFuncs = {MODIFIER_PROPERTY_MODEL_SCALE}
-- end

-- function modifier_item_nemean_lions_hide_buff:GetModifierModelScale()
--     return self.model_scale
-- end