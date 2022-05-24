ability_quetzalcoatls_blessing = ability_quetzalcoatls_blessing or class({})

LinkLuaModifier( "modifier_quetzalcoatls_blessing", "scripts/vscripts/heroes/quetzalcoatl/modifier_quetzalcoatls_blessing", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_rebirth", "scripts/vscripts/heroes/quetzalcoatl/modifier_talent_rebirth", LUA_MODIFIER_MOTION_NONE )

function ability_quetzalcoatls_blessing:OnAbilityPhaseInterrupted()
end

function ability_quetzalcoatls_blessing:OnAbilityPhaseStart()
	return true -- if success
end

function ability_quetzalcoatls_blessing:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()

    -- apply self-damage first in the event you're casing it on yourself 
    -- (otherwise it basically always does all your HP in damage)
    local self_dmg_percent = (self:GetSpecialValueFor("self_dmg_percent")) / 100
    local hp_loss = caster:GetMaxHealth() * self_dmg_percent
    local damageTable = {
        attacker        = caster,
        victim          = caster,
        damage          = hp_loss,
        damage_type     = DAMAGE_TYPE_MAGICAL,
        damage_flags    = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability         = self
    }

    ApplyDamage( damageTable )
    -- if caster:GetHealth() - hp_loss < 0 then
    --     local damageTable = {
    --         attacker = caster,
    --         damage = hp_loss
    --     }
    -- else
    -- end

    local duration = self:GetSpecialValueFor("buff_duration")

    target:AddNewModifier(
                            caster, -- player source
                            self, -- ability source
                            "modifier_quetzalcoatls_blessing", -- modifier name
                            { duration = duration } -- kv
                        )

    -- local sound_cast = "Hero_Magnataur.Empower.Cast"
    -- local sound_target = "Hero_Magnataur.Empower.Target"
    -- EmitSoundOn( sound_cast, caster )
    -- EmitSoundOn( sound_target, target )
end