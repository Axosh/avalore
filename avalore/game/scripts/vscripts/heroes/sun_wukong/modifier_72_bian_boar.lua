modifier_72_bian_boar = class({})

function modifier_72_bian_boar:IsAura() return true end
function modifier_72_bian_boar:IsHidden() return false end
function modifier_72_bian_boar:IsPurgable() return false end

function modifier_72_bian_boar:GetTexture()
    return "sun_wukong/boar_form"
end

function modifier_72_bian_boar:OnCreated()
    if not IsServer() then return end

    --if self:GetParent():IsRealHero() then
        self.gore_ability = self:GetParent():AddAbility("ability_boar_gore")
        self.gore_ability:SetLevel(self:GetParent():GetAbilityByName("ability_72_bian"):GetLevel())
        self.jingu_ability = self:GetParent():FindAbilityByName("ability_ruyi_jingu_bang")
        self:GetParent():SwapAbilities( self.gore_ability:GetAbilityName(),
                                        self.jingu_ability:GetAbilityName(),
                                        true, --enable gore
                                        false) --disable jingu
    --end
    --self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_boar_gore", {})
end


function modifier_72_bian_boar:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MODEL_CHANGE,
                MODIFIER_PROPERTY_HEALTH_BONUS
            }
end

function modifier_72_bian_boar:GetModifierModelChange()
	return "models/items/beastmaster/boar/ti9_cache_beastmaster_king_of_beasts_boar/ti9_cache_beastmaster_king_of_beasts_boar.vmdl"
end

function modifier_72_bian_boar:GetModifierExtraHealthBonus()
    return 400 --temp for testing
end

function modifier_72_bian_boar:OnDestroy()
    if not IsServer() then return end

    self:GetCaster():RemoveModifierByName("modifier_boar_gore")

    if self:GetParent():IsRealHero() then
        self:GetParent():SwapAbilities( self.gore_ability:GetAbilityName(),
                                        self.jingu_ability:GetAbilityName(),
                                        false, --disable gore
                                        true) --enable jingu
        self:GetParent():RemoveAbility("ability_boar_gore")
    end
end