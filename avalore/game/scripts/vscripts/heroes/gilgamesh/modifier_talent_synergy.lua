-- tracking modifier for the talent
modifier_talent_synergy = class({})

LinkLuaModifier( "modifier_synergy", "scripts/vscripts/heroes/gilgamesh/modifier_synergy.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_talent_synergy:IsHidden() 		return true end
function modifier_talent_synergy:IsPurgable() 		return false end
function modifier_talent_synergy:RemoveOnDeath() 	return false end

-- try to handle in events.lua (not ideal, but race conditions)

-- function modifier_talent_synergy:OnCreated()

--     if not IsServer() then return end
--     --self.bonus_attack_speed = self:GetParent():FindTalentValue("talent_synergy", "bonus_as")

--     self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_synergy", {is_enkidu = false})

--     --self:GetParent():GetAdditionalOwnedUnits()
--     local enk_ability = self:GetParent():FindAbilityByName("ability_befriend_enkidu")
--     if enk_ability:GetLevel() > 0 then
--         local enkidu = enk_ability:GetEnkiduRef()
--         -- if they have it leveled, then make sure he's actually summoned
--         if enkidu then
--             enkidu:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_synergy", {is_enkidu = true})
--         end
--     end

-- end