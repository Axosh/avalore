ability_maenadic_fervor = class({})
LinkLuaModifier("modifier_maenadic_fervor", "heroes/dionysus/modifier_maenadic_fervor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maenad",          "heroes/dionysus/modifier_maenad.lua",          LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_talent_unbridled_power", "heroes/dionysus/modifier_talent_unbridled_power.lua", LUA_MODIFIER_MOTION_NONE )

function ability_maenadic_fervor:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")

    if target:IsRealHero() then
        -- dispel target
		target:Purge( true, false, false, false, false )

        -- add modifier
        target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_maenadic_fervor", -- modifier name
            { duration = duration } -- kv
        )

        -- Effects
        local sound_cast = "hero_bloodseeker.bloodRage"
        EmitSoundOn( sound_cast, caster )
    else
        local duration_dominate = self:GetSpecialValueFor("duration_maenad")

        if self:IsAICreep(target) then
            target = self:ControlAICreep(target)
        end

        local maenad_kv = {}
        -- if they don't have the talent, then there's a time limit
        if not self:GetCaster():HasTalent("talent_possessed") then
            maenad_kv = { duration = duration_dominate }
        end

        -- possess the creep unit
		target:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_maenad", -- modifier name
            maenad_kv -- kv
		)

        -- add buff
        target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_maenadic_fervor", -- modifier name
            maenad_kv -- kv
        )

		-- dispel target
		target:Purge( false, true, false, false, false )

		-- play effects
		local sound_cast = "Hero_Enchantress.EnchantCreep"
		EmitSoundOn( sound_cast, target )
    end

	
end

-- ======================================================================
-- Helper Functions to deal with creeps that have AI
-- (i.e. lane/merc creeps)
-- ======================================================================
function ability_maenadic_fervor:IsAICreep(target)
    return (    string.find(target:GetUnitName(), "npc_avalore_creep")
            or  string.find(target:GetUnitName(), "npc_avalore_siege")
            or  string.find(target:GetUnitName(), "npc_avalore_merc"))
end

function ability_maenadic_fervor:ControlAICreep(target)
    local lane_creep_name = target:GetUnitName()
			
    local new_lane_creep = CreateUnitByName(target:GetUnitName(), target:GetAbsOrigin(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    -- Copy the relevant stats over to the creep
    new_lane_creep:SetBaseMaxHealth(target:GetMaxHealth())
    new_lane_creep:SetHealth(target:GetHealth())
    new_lane_creep:SetBaseDamageMin(target:GetBaseDamageMin())
    new_lane_creep:SetBaseDamageMax(target:GetBaseDamageMax())
    new_lane_creep:SetMinimumGoldBounty(target:GetGoldBounty())
    new_lane_creep:SetMaximumGoldBounty(target:GetGoldBounty())			
    target:AddNoDraw()
    target:ForceKill(false)
    return new_lane_creep
end