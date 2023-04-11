item_bonemace = class({})

LinkLuaModifier( "modifier_item_bonemace_ready", "items/shop/base_materials/item_bonemace.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_avalore_bash",         "modifiers/base_spell/modifier_avalore_bash.lua", LUA_MODIFIER_MOTION_NONE)

function item_bonemace:GetIntrinsicModifierName()
    return "modifier_item_bonemace_ready"
end

-- function item_bonemace:GetCooldown(level)
--     return self:GetSpecialValueFor("cooldown")
-- end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_bonemace_ready = modifier_item_bonemace_ready or class({})

function modifier_item_bonemace_ready:IsHidden() return true end
function modifier_item_bonemace_ready:IsDebuff() return false end
function modifier_item_bonemace_ready:IsPurgable() return false end
function modifier_item_bonemace_ready:RemoveOnDeath() return false end
-- function modifier_item_bonemace_ready:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

function modifier_item_bonemace_ready:DeclareFunctions()
    return {    MODIFIER_EVENT_ON_ATTACK,
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL      }
end

function modifier_item_bonemace_ready:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.mini_bash = self.item_ability:GetSpecialValueFor("mini_bash")
    self.bash_dmg = self.item_ability:GetSpecialValueFor("bash_dmg")

    -- if IsServer() then
    --     self:SetStackCount( 1 )
    -- end
end

function modifier_item_bonemace_ready:OnAttack(keys)
    if (self:GetAbility() and
        keys.attacker == self:GetParent() and
        self:GetAbility():IsCooldownReady() and
        not keys.attacker:IsIllusion() and
        not keys.target:IsBuilding() and
        not keys.target:IsOther())
    then
        print("BASH READY")
        self.bash_ready = true
    end
end

function modifier_item_bonemace_ready:OnAttackLanded(keys)
    if self:GetAbility() and keys.attacker == self:GetParent() and self.bash_ready then
        print("PROC BASH")
        -- reset bash proc
		self.bash_ready = false

        -- Make the ability go into cooldown
		self:GetAbility():UseResources(false, false, true)

        -- apply bash
        keys.target:EmitSound("DOTA_Item.SkullBasher")
        local bash_dur = (self.mini_bash * (1 - keys.target:GetStatusResistance()))
        keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_avalore_bash", {duration = bash_dur})
    end
end


function modifier_item_bonemace_ready:GetModifierProcAttack_BonusDamage_Physical()
	if self:GetAbility() and self.bash_proc then
		return self.bash_dmg
	end
end