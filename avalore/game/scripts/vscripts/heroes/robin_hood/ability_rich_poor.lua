ability_rich_poor = ability_rich_poor or class({})

LinkLuaModifier( "modifier_rich_poor", "heroes/robin_hood/ability_rich_poor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rogueish_escape", "heroes/robin_hood/ability_rich_poor", LUA_MODIFIER_MOTION_NONE )

function ability_rich_poor:GetAbilityTextureName()
    if self:GetToggleState() then
        return "steal_from_rich"
    else
        return "give_to_poor"
    end
end

function ability_rich_poor:GetIntrinsicModifierName()
	return "modifier_rich_poor"
end

function ability_rich_poor:ProcsMagicStick()
	return false
end

function ability_rich_poor:OnUpgrade()
	self:GetOwner():FindModifierByName(self:GetIntrinsicModifierName()):ForceRefresh()
end

function ability_rich_poor:OnToggle()
    
end

-- ========================================
-- INTRINSIC MODIFIER
-- ========================================

modifier_rich_poor = modifier_rich_poor or class({})

function modifier_rich_poor:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}

	return funcs
end

function modifier_rich_poor:IsHidden()
    return true
end

function modifier_rich_poor:IsPurgable()
    return false
end

function modifier_rich_poor:OnCreated(kv)
    self.gold_steal = self:GetAbility():GetSpecialValueFor("gold_steal")
    self.escape_time = self:GetAbility():GetSpecialValueFor("escape_time")
    self.cd = self:GetAbility():GetSpecialValueFor("virtual_cooldown")
end

function modifier_rich_poor:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_rich_poor:GetModifierProcAttack_Feedback( kv )
    if IsServer() then
        -- don't proc on buildings or wards
        if kv.target:IsBuilding() or kv.target:IsOther() then
            return
        end

        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then
            return
        end

        if self:GetAbility():IsCooldownReady() then
            -- TODO: change who gets gold based on toggle state
            self:GetParent():ModifyGold(self.gold_steal, true, 0)
            print("Stealing Gold! " .. tostring(self.gold_steal))
            -- TODO: reduce target's gold by same amount (or as much as possible regarding negatives)


            -- STEAL EFFECT
            --self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
            local particle_cast = "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_midas_coinshower.vpcf"
            local caster = kv.target
            local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
            ParticleManager:SetParticleControlEnt(
                effect_cast,
                0,
                caster,
                PATTACH_POINT_FOLLOW,
                "attach_hitloc",
                caster:GetOrigin(), -- unknown
                true -- unknown, true
            )
            ParticleManager:SetParticleControl( effect_cast, 1, caster:GetOrigin() )
            ParticleManager:SetParticleControlForward( effect_cast, 1, -caster:GetForwardVector() )
            ParticleManager:ReleaseParticleIndex( effect_cast )
            --EmitSoundOn("sounds/items/item_handofmidas.vsnd", self:GetParent() )
            EmitSoundOn("Hero_BountyHunter.Jinada", self:GetParent())

            -- GIVE GOLD EFFECT
            --particle_cast = "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_midas_coins.vpcf"
            particle_cast = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinada.vpcf"
            caster = self:GetParent()
            effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
            ParticleManager:SetParticleControlEnt(
                effect_cast,
                0,
                caster,
                PATTACH_POINT_FOLLOW,
                "attach_hitloc",
                caster:GetOrigin(), -- unknown
                true -- unknown, true
            )
            ParticleManager:SetParticleControl( effect_cast, 1, caster:GetOrigin() )
            ParticleManager:SetParticleControlForward( effect_cast, 1, -caster:GetForwardVector() )
            ParticleManager:ReleaseParticleIndex( effect_cast )

            -- escape modifier
            self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_rogueish_escape", {duration = self.escape_time})
            -- local player_num = self:GetParent():GetPlayerOwnerID()
            -- for key,value in pairs(CAvaloreGameMode.player_cosmetics[player_num]) do
            --     value:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_rogueish_escape", {duration = self.escape_time})
            -- end

            self:GetAbility():StartCooldown(self.cd)
        end
    end
end

-- ========================================
--  MODIFIER
-- ========================================

modifier_rogueish_escape = modifier_rogueish_escape or class({})

function modifier_rogueish_escape:IsHidden() return false end
function modifier_rogueish_escape:IsPurgable() return false end
function modifier_rogueish_escape:IsDebuff() return false end

function modifier_rogueish_escape:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_EVENT_ON_ATTACK}
end

function modifier_rogueish_escape:GetModifierInvisibilityLevel()
    return 1
end

function modifier_rogueish_escape:CheckState()
    return  {   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                        [MODIFIER_STATE_INVISIBLE] = true
            }
end

function modifier_rogueish_escape:GetPriority()
    return MODIFIER_PRIORITY_NORMAL
end

function modifier_rogueish_escape:GetTexture()
    return "rogueish_escape"
end

function modifier_rogueish_escape:OnCreated()
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

	local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_rogueish_escape:OnAttack(kv)
    if IsServer() then
        local attacker = kv.attacker
        if self.parent == attacker then
            self:Destroy()
        end
    end
end