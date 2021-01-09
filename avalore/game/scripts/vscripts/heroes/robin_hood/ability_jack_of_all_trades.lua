require("references")
require(REQ_CONSTANTS)
if IsServer() then
    require(REQ_LIB_COSMETICS)
end

ability_jack_of_all_trades = ability_jack_of_all_trades or class({})

LinkLuaModifier("modifier_jack_of_all_trades_ranged", "heroes/robin_hood/ability_jack_of_all_trades.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jack_of_all_trades_melee",  "heroes/robin_hood/ability_jack_of_all_trades.lua", LUA_MODIFIER_MOTION_NONE)

function ability_jack_of_all_trades:ProcsMagicStick()
    return false
end

function ability_jack_of_all_trades:GetAbilityTextureName()
    if self:GetToggleState() then
        return "jack_of_all_trades_melee"
    else
        return "jack_of_all_trades_ranged"
    end
end

-- TODO: make sure this runs immediately when upgraded
function ability_jack_of_all_trades:OnToggle()
    -- remove old modifier
    if self.modifier then
        self.modifier:Destroy()
        self.modifier = nil
    end
    -- melee form when toggled on
    if self:GetToggleState() then
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(),
                                                        self,
                                                        "modifier_jack_of_all_trades_melee",
                                                        {})
    else
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(),
                                                        self,
                                                        "modifier_jack_of_all_trades_ranged",
                                                        {})
    end
end

function ability_jack_of_all_trades:OnUpgrade()
	if self.modifier then
		self.modifier:ForceRefresh()
	end
end

function ability_jack_of_all_trades:PlayEffects()
	-- Get Resources
	local sound_cast = "Hero_TrollWarlord.BerserkersRage.Toggle"

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

-- =======================================
-- modifier_jack_of_all_trades_ranged
-- =======================================
modifier_jack_of_all_trades_ranged = modifier_jack_of_all_trades_ranged or class({})

function modifier_jack_of_all_trades_ranged:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}

	return funcs
end

function modifier_jack_of_all_trades_ranged:IsHidden()
	return false
end

function modifier_jack_of_all_trades_ranged:IsDebuff()
	return false
end

function modifier_jack_of_all_trades_ranged:IsPurgable()
	return false
end

function modifier_jack_of_all_trades_ranged:RemoveOnDeath()
	return false
end

function modifier_jack_of_all_trades_ranged:GetModifierAttackRangeBonus()
	return self.bonus_range
end

function modifier_jack_of_all_trades_ranged:OnCreated(kv)
    if IsServer() then
        self.bonus_range   = self:GetAbility():GetSpecialValueFor("ranged_bonus_range")
        self.bonus_ms = 0
        self.range      = 600--self:GetParent():GetBaseAttackRange()
        --print("[modifier_jack_of_all_trades_ranged] parent = " .. self:GetParent():GetName())
        --print("[modifier_jack_of_all_trades_ranged] Current Attack Cap = " .. self:GetParent():GetAttackCapability())
        --print("[modifier_jack_of_all_trades_ranged] printing DOTA_UNIT_CAP_RANGED_ATTACK ==> " .. tostring(DOTA_UNIT_CAP_RANGED_ATTACK))
        self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )

        --CosmeticLib:RemoveFromSlot(self:GetParent(), DOTA_LOADOUT_TYPE_WEAPON)
        self:GetParent().weapon_model:RemoveSelf()
        self:GetParent().weapon_model = nil
        -- Longbow of the Roving Pathfinder (DOTA_LOADOUT_TYPE_WEAPON)
        local SomeModel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_bow/the_swift_pathfinder_swift_pathfinders_bow.vmdl"})
        SomeModel:FollowEntity(self:GetParent(), true)
        self:GetParent().weapon_model = SomeModel
    end
end


-- =======================================
-- modifier_jack_of_all_trades_melee
-- =======================================

modifier_jack_of_all_trades_melee = modifier_jack_of_all_trades_melee or class({})

function modifier_jack_of_all_trades_melee:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function modifier_jack_of_all_trades_melee:IsHidden()
	return false
end

function modifier_jack_of_all_trades_melee:IsDebuff()
	return false
end

function modifier_jack_of_all_trades_melee:IsPurgable()
	return false
end

function modifier_jack_of_all_trades_melee:RemoveOnDeath()
	return false
end

function modifier_jack_of_all_trades_melee:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_jack_of_all_trades_melee:GetModifierAttackRangeBonus()
	return MELEE_ATTACK_RANGE - 600--self:GetParent():GetBaseAttackRange()
end

function modifier_jack_of_all_trades_melee:OnCreated(kv)
    if IsServer() then
        self.bonus_ms   = self:GetAbility():GetSpecialValueFor("melee_bonus_move_speed")
        self.range      = MELEE_ATTACK_RANGE
        self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )

        --CosmeticLib:RemoveFromSlot(self:GetParent(), DOTA_LOADOUT_TYPE_WEAPON)
        self:GetParent().weapon_model:RemoveSelf()
        self:GetParent().weapon_model = nil
        -- No-Guard the Courageous Edge (DOTA_LOADOUT_TYPE_WEAPON) -- Juggernaut Weapon
        --local SomeModel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/brave_sword.vmdl"})

        local SomeModel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/ti9_cache_kunkka_kunkkquistador_weapon/ti9_cache_kunkka_kunkkquistador_weapon.vmdl"})
        SomeModel:SetLocalScale(0.75)

        -- print ("========[BEFORE]=========")
        -- print("Forward Vector = " .. DebugVector(SomeModel:GetForwardVector()))
        -- print("Local Origin = " .. DebugVector(SomeModel:GetLocalOrigin()))
        -- print ("=========================")
        -- SomeModel:SetForwardVector(self:GetParent():GetForwardVector() * Vector(-1,-1,1))
        -- SomeModel:SetLocalOrigin(Vector(100,100,100))
        -- print ("========[AFTER]=========")
        -- print("Forward Vector = " .. DebugVector(SomeModel:GetForwardVector()))
        -- print("Local Origin = " .. DebugVector(SomeModel:GetLocalOrigin()))
        -- print ("=========================")
        SomeModel:FollowEntity(self:GetParent(), true)
        -- print ("========[FOLLOW]=========")
        -- print("Forward Vector = " .. DebugVector(SomeModel:GetForwardVector()))
        -- print("Local Origin = " .. DebugVector(SomeModel:GetLocalOrigin()))
        -- print ("=========================")
        self:GetParent().weapon_model = SomeModel
    end
end

function modifier_jack_of_all_trades_melee:OnAttackLanded(kv)
    if IsServer () then
        if kv.attacker == self:GetParent() then
            local particle_cast = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter_slash.vpcf"
            local caster = kv.target --self:GetParent()
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
            --EmitSoundOn( "Hero_Juggernaut.Attack", self:GetParent() )
            EmitSoundOn( "sounds/weapons/hero/shared/impacts/heavy_sword_impact4.vsnd", self:GetParent() )
        end
    end
end

-- function modifier_jack_of_all_trades_melee:GetAttackSound(kv)
--     if kv.attacker == self:GetParent() then
--         return "Hero_Juggernaut.Attack"
--     end
-- end


function DebugVector( vector )
    local result = "(" .. tostring(vector.X) .. ", " .. tostring(vector.Y) .. ", " .. tostring(vector.Z) .. ")"
    return result
end