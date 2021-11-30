require("references")
require(REQ_LIB_TIMERS)

ability_shapeshift = class({})

LinkLuaModifier("modifier_shapeshift_eagle", "heroes/zeus/modifier_shapeshift_eagle.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_avalore_hex",     "modifiers/base_spell/modifier_avalore_hex.lua", LUA_MODIFIER_MOTION_NONE)

-- function ability_shapeshift:OnUpgrade()
-- 	if self:GetCaster():HasAbility("ability_shapeshift") then
-- 		self:GetCaster():FindAbilityByName("ability_shapeshift"):SetLevel(self:GetLevel())
-- 	end
-- end

function ability_shapeshift:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- can cast on self if magic immune, but not an enemy if they are
    -- on second thought, let's just not deal with this
    --if caster ~= target and target:IsMagicImmune() then
    if target:IsMagicImmune() then
		return nil
	end

    -- hex if cast on enemy
    if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		if not target:TriggerSpellAbsorb(self) then
            -- "Hex instantly destroys illusions."
			if target:IsIllusion() and not Custom_bIsStrongIllusion(self.parent) then
				target:Kill(target, self:GetCaster())
			else
                local duration_enemy = self:GetSpecialValueFor("duration_enemy")
                if self:GetCaster():HasTalent("talent_shapeshift_enemy_duration") then
                    duration_enemy = duration_enemy + self:GetCaster():FindAbilityByName("talent_shapeshift_enemy_duration"):GetTalentSpecialValueFor("bonus_duration_enemy")
                end
                target:AddNewModifier(self:GetCaster(), self, "modifier_avalore_hex",
                                        {
                                            duration = duration_enemy,
                                            texture = "zeus/modifier_shapeshift_wolf",
                                            model = "models/items/beastmaster/boar/fotw_wolf/fotw_wolf.vmdl"
                                        });
            end
        end
    -- transform if cast on self
    else
        local particle_cast = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
        local transformation_time = self:GetSpecialValueFor("transformation_time")
        local duration = self:GetSpecialValueFor("duration_self")

        caster:EmitSound("Hero_Beastmaster.Call.Hawk")
        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)

        -- Add cast particle effects
        local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_cast_fx, 0 , caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_cast_fx, 1 , caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_cast_fx, 2 , caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_cast_fx, 3 , caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_cast_fx)

        -- disable casting/movement during transform
        --caster:AddNewModifier(caster, ability, "modifier_transform_stun", {duration = transformation_time})

        -- trigger the transformation buff after the Timer expires
        Timers:CreateTimer(transformation_time, function()
            caster:AddNewModifier(caster, self, "modifier_shapeshift_eagle", {duration = duration})
        end)

        -- disable other spells + change ability to cancel transform, preserve levels/upgrades
        local spell_slot1 = self:GetCaster():GetAbilityByIndex(1):GetAbilityName() -- 0-indexed
        caster:SwapAbilities(spell_slot1, "ability_eagle_cancel", false, true)
        local curr_level_slot1 = caster:FindAbilityByName(spell_slot1):GetLevel()
        self:GetCaster():GetAbilityByIndex(1):SetLevel(curr_level_slot1)
        SwapSpells(self, 1, "ability_eagle_cancel")
    end

    
end
