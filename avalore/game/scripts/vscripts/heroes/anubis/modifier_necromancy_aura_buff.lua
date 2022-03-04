modifier_necromancy_aura_buff = class({})

function modifier_necromancy_aura_buff:IsHidden() return false end
function modifier_necromancy_aura_buff:IsPurgable() return false end
function modifier_necromancy_aura_buff:IsDebuff() return false end

function modifier_necromancy_aura_buff:OnCreated()
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.necromancy_form = "modifier_necromancy_aura_buff_form"

    self.duration = self.ability:GetSpecialValueFor("duration")
	self.outgoing_damage_pct = self.ability:GetSpecialValueFor("outgoing_damage_pct")
end

function modifier_necromancy_aura_buff:DeclareFunctions()
	local decFuncs = {  MODIFIER_PROPERTY_MIN_HEALTH,
                        MODIFIER_EVENT_ON_TAKEDAMAGE }

	return decFuncs
end

function modifier_necromancy_aura_buff:GetMinHealth()
	return 1
end

function modifier_necromancy_aura_buff:OnTakeDamage(keys)
	if not IsServer() then return end

    local attacker = keys.attacker
    local target = keys.unit
    local damage = keys.damage

    -- Only apply if the unit taking damage is the parent
    if self.parent == target then

        -- Check if the damage is fatal
        if damage >= self.parent:GetHealth() then

            -- Check for Sun Wukong's Ult
            if self.parent:HasModifier("modifier_wukong_immortality") then
                -- if it's off cooldown, then kill normally to trigger that first
                if not self.parent:FindModifierByName("modifier_wukong_immortality"):CanDie() then
                    self:Destroy()
                    self.parent:Kill(self.ability, attacker)
                    return nil
                end
            end

            -- Check for Aegis: kill the unit normally
            if self.parent:HasModifier("modifier_item_aegis") then
                self:Destroy()
                self.parent:Kill(self.ability, attacker)
                return nil
            end

            -- Check if this unit has Reincarnation and it is ready: if so, kill the unit normally
            -- if self.parent:HasAbility("ability_immortality") then
            --     local reincarnation_ability = self.parent:FindAbilityByName("ability_immortality")
            --     if reincarnation_ability then
            --         if self.parent:GetMana() >= reincarnation_ability:GetManaCost(-1) and reincarnation_ability:IsCooldownReady() then
            --             self:Destroy()
            --             self.parent:Kill(self.ability, attacker)
            --             return nil
            --         end
            --     end
            -- end

            -- Assign the killer to the modifier, which would actually kill the hero later
            local necromancy_form_modifier_handler = self.parent:AddNewModifier(self.caster, self.ability, self.necromancy_form, {duration = self.duration, outgoing_damage_pct = self.outgoing_damage_pct})
            if necromancy_form_modifier_handler then
                necromancy_form_modifier_handler.original_killer = attacker
                necromancy_form_modifier_handler.ability_killer = keys.inflictor
                -- if keys.inflictor then
                --     if keys.inflictor:GetName() == "imba_necrolyte_reapers_scythe" then
                --         keys.inflictor.ghost_death = true
                --     end
                -- end
            end
        end
	end
end
