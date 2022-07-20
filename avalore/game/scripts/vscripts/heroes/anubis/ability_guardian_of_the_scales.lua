ability_guardian_of_the_scales = ability_guardian_of_the_scales or class({})

LinkLuaModifier( "modifier_judgement", "scripts/vscripts/heroes/anubis/modifier_judgement", LUA_MODIFIER_MOTION_NONE )

function ability_guardian_of_the_scales:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()

    local duration = self:GetSpecialValueFor("duration")

    self:GetCaster():EmitSound("Hero_Oracle.FalsePromise.Cast") --idk if this will be the final sound or not

    -- Purge(removePositiveBuffs, removeDebuffs, frameOnly, removeStuns, removeExceptions)
    target:Purge(false, true, false, true, true)

    target:AddNewModifier(
                            caster, -- player source
                            self, -- ability source
                            "modifier_judgement", -- modifier name
                            { duration = duration } -- kv
                        )
end