require("references")
require(REQ_CONSTANTS)
if IsServer() then
    require(REQ_LIB_COSMETICS)
end


ability_jack_of_all_trades = ability_jack_of_all_trades or class({})

LinkLuaModifier("modifier_jack_of_all_trades_ranged", "heroes/robin_hood/ability_jack_of_all_trades.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jack_of_all_trades_melee",  "heroes/robin_hood/ability_jack_of_all_trades.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_wearable", "scripts/vscripts/modifiers/modifier_wearable", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wearable_temp_invis", "scripts/vscripts/modifiers/modifier_wearable_temp_invis", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_parry", "heroes/robin_hood/modifier_talent_parry.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_bonus_range", "heroes/robin_hood/modifier_talent_bonus_range.lua", LUA_MODIFIER_MOTION_NONE )

function ability_jack_of_all_trades:ProcsMagicStick()
    return false
end

function ability_jack_of_all_trades:GetAbilityTextureName()
    if self:GetToggleState() then
        return "robin_hood/jack_of_all_trades_melee"
    else
        return "robin_hood/jack_of_all_trades_ranged"
    end
end

-- TODO: make sure this runs immediately when upgraded
function ability_jack_of_all_trades:OnToggle()
    local caster = self:GetCaster()
    -- remove old modifier
    if self.modifier then
        self.modifier:Destroy()
        self.modifier = nil
    end
    -- melee form when toggled on
    if self:GetToggleState() then
        print("melee form")
        -- Melee Mode
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(),
                                                        self,
                                                        "modifier_jack_of_all_trades_melee",
                                                        {})
        local spell_slot1 = self:GetCaster():GetAbilityByIndex(1):GetAbilityName() -- 0 indexed
        local modifier = self:GetCaster():GetAbilityByIndex(1):GetIntrinsicModifierName()
        caster:RemoveModifierByName(modifier) -- remove lingering modifier (Marksmanship)
        local curr_level_slot1 = caster:FindAbilityByName(spell_slot1):GetLevel()
        print("Spell Slot 1 = " .. tostring(spell_slot1) .. " || CurrLevel = " .. tostring(curr_level_slot1))
        caster:SwapAbilities(spell_slot1, "ability_rich_poor", false, true)
        self:GetCaster():GetAbilityByIndex(1):SetLevel(curr_level_slot1)

        SwapSpells(self, 2, "ability_swashbuckle")
    else
        print("ranged form")
        -- Ranged Mode
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(),
                                                        self,
                                                        "modifier_jack_of_all_trades_ranged",
                                                        {})
        local spell_slot1 = self:GetCaster():GetAbilityByIndex(1):GetAbilityName()
        local modifier = self:GetCaster():GetAbilityByIndex(1):GetIntrinsicModifierName()
        caster:RemoveModifierByName(modifier) -- remove lingering modifier
        local curr_level_slot1 = caster:FindAbilityByName(spell_slot1):GetLevel()
        caster:SwapAbilities(spell_slot1, "ability_avalore_marksmanship", false, true)
        self:GetCaster():GetAbilityByIndex(1):SetLevel(curr_level_slot1)

        SwapSpells(self, 2, "ability_shackleshot")
    end
end

-- ===================================================================================================
-- swaps spells, keeping the level the same
-- *******************************************************
-- *******************************************************
-- abilityRef (handle): reference to the ability ("self")
-- slotNum (int):       numerical 0-indexed spell slot to swap out
-- newSpell (str):      internal name of spell to replace it with
-- ===================================================================================================
function SwapSpells(abilityRef, slotNum, newSpell)
    local caster = abilityRef:GetCaster()
    local spell_slot = abilityRef:GetCaster():GetAbilityByIndex(slotNum):GetAbilityName()
    local modifier = abilityRef:GetCaster():GetAbilityByIndex(slotNum):GetIntrinsicModifierName()
    if modifier then
        caster:RemoveModifierByName(modifier) -- remove lingering modifier
    end

    local curr_slot_level = caster:FindAbilityByName(spell_slot):GetLevel()
    caster:SwapAbilities(spell_slot, newSpell, false, true)
    abilityRef:GetCaster():GetAbilityByIndex(slotNum):SetLevel(curr_slot_level)
end

-- function ability_jack_of_all_trades:GetCastRange(vLocation, hTarget)
--     if self:GetToggleState() then
--         return MELEE_ATTACK_RANGE
--     else
--         return 600
--     end
-- end

function ability_jack_of_all_trades:OnUpgrade()
	if self.modifier then
		self.modifier:ForceRefresh()
    else
        -- start in ranged form
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(),
                                                        self,
                                                        "modifier_jack_of_all_trades_ranged",
                                                        {})
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
    --print("[modifier_jack_of_all_trades_ranged] Started OnCreated")
    
    self.bonus_range   = self:GetAbility():GetSpecialValueFor("ranged_bonus_range")
    -- factor in talent if they have it
    self.bonus_range = self.bonus_range + self:GetCaster():FindTalentValue("talent_bonus_range", "bonus_range")
--        print("bonus range => " .. tostring(self.bonus_range))
    self.bonus_ms = 0
    self.range      = 600--self:GetParent():GetBaseAttackRange()
    if IsServer() then
        self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )
    end
end

function modifier_jack_of_all_trades_ranged:OnRefresh()
    self:OnCreated()
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
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
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

function modifier_jack_of_all_trades_melee:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

-- hopefully uses animation for shackleshot which kind of looks like she's swinging a sword
--function modifier_jack_of_all_trades_melee:GetOverrideAnimation() return ACT_DOTA_CAST_ABILITY_1 end

function modifier_jack_of_all_trades_melee:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_jack_of_all_trades_melee:GetModifierAttackRangeBonus()
	return MELEE_ATTACK_RANGE - 600--self:GetParent():GetBaseAttackRange()
end

function modifier_jack_of_all_trades_melee:OnCreated(kv)
    
    self.bonus_ms   = self:GetAbility():GetSpecialValueFor("melee_bonus_move_speed")
    self.range      = MELEE_ATTACK_RANGE
    self.bonus_armor = self:GetCaster():FindTalentValue("talent_parry", "bonus_armor")
    if not IsServer() then return end
    self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
end

function modifier_jack_of_all_trades_melee:OnRefresh()
    self:OnCreated()
end

-- function modifier_jack_of_all_trades_melee:OnIntervalThink()
--     print("OnThink: " .. self:GetParent():GetSequence())
--     if self:GetParent():IsIdle() then
--         -- if self:GetParent():GetSequence() ~= "portrait" then
--         --     self:GetCaster():StopAnimation()
--         --     --self:GetParent():SetSequence("portrait")
--         -- end
--         self:GetCaster():RemoveGesture(ACT_DOTA_IDLE)
--         self:GetCaster():RemoveGesture(ACT_DOTA_IDLE_RARE)
--         self:GetCaster():StartGesture(ACT_DOTA_RELAX_LOOP)
--     end
-- end

function modifier_jack_of_all_trades_melee:OnAttackStart(keys)
    if not IsServer () then return end
    --print("OnAttackStart")
    --PrintTable(keys)
    if keys.attacker == self:GetParent() then
        --print("OnAttackStart - Active Seq: " .. self:GetCaster():GetSequence())
        --self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
        --self:GetCaster():StopAnimation()
        local caster = self:GetCaster()
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK2)
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK_EVENT)
        self:GetCaster():StopAnimation()
        caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, self:GetParent():GetAttacksPerSecond()) -- shackleshot? since it looks like a sword swing
    end
end

function modifier_jack_of_all_trades_melee:OnAttack(keys)
    if not IsServer () then return end
    --print("OnAttack: " .. tostring)
    if keys.attacker == self:GetParent() then
        --print("OnAttack - Active Seq: " .. self:GetCaster():GetSequence())
        local caster = self:GetCaster()
        --DoEntFire( button, "SetAnimation", "ancient_trigger001_down", 0, self, self )
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK2)
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK_EVENT)
        --self:GetCaster():StopAnimation()
        --caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, self:GetParent():GetAttacksPerSecond()) -- shackleshot? since it looks like a sword swing
        --caster:SetSequence("sparrowhawk_shackleshot_anim")
        --caster:SequenceDuration
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
            EmitSoundOn( "Hero_Juggernaut.Attack", self:GetParent() )
            --EmitSoundOn( "sounds/weapons/hero/shared/impacts/heavy_sword_impact4.vsnd", self:GetParent() )
        end
        --self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
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