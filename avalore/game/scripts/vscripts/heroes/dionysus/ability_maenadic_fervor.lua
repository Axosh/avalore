ability_maenadic_fervor = class({})
LinkLuaModifier("modifier_maenadic_fervor", "heroes/dionysus/modifier_maenadic_fervor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maenad",          "heroes/dionysus/modifier_maenad.lua",          LUA_MODIFIER_MOTION_NONE)

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

        -- possess the creep unit
		target:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_maenad", -- modifier name
			{ duration = duration_dominate } -- kv
		)

        -- add buff
        target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_maenadic_fervor", -- modifier name
            { duration = duration_dominate } -- kv
        )

		-- dispel target
		target:Purge( false, true, false, false, false )

		-- play effects
		local sound_cast = "Hero_Enchantress.EnchantCreep"
		EmitSoundOn( sound_cast, target )
    end

	
end