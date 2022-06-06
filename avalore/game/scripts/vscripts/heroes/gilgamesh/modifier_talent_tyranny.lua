-- tracking modifier for the talent
modifier_talent_tyranny = class({})

function modifier_talent_tyranny:IsHidden()
    if self:GetStackCount() > 0 then
        return false
    end
    return true
end
function modifier_talent_tyranny:IsPurgable() 	    return false end
function modifier_talent_tyranny:RemoveOnDeath() 	return false end

function modifier_talent_tyranny:GetTexture()
    return "gilgamesh/tyranny"
end

function modifier_talent_tyranny:DeclareFunctions()
	return  {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_talent_tyranny:OnCreated()
    self.bonus_dmg_per_kill = self:GetCaster():FindTalentValue("talent_tyranny", "bonus_dmg_per_kill")

    if IsServer() and self:GetStackCount() == nil then
        self:SetStackCount(0)
   end
end

function modifier_talent_tyranny:OnRefresh()
	print("modifier_talent_tyranny:OnRefresh()")
	self:OnCreated()
end

function modifier_talent_tyranny:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * self.bonus_dmg_per_kill
end

-- NOTE: This fires any time any unit dies
function modifier_talent_tyranny:OnDeath( params )
    if not IsServer() then return end

    -- was this a real enemy hero that died?
    if params.unit:IsRealHero() and params.unit:GetTeam() ~= self:GetParent():GetTeam() then
        -- is this gilgamesh/enkidu that killed them?
        if params.attacker:GetMainControllingPlayer() and params.attacker:GetMainControllingPlayer() == self:GetParent():GetMainControllingPlayer() then
            -- only works while Gilgamesh is ulting
            if self:GetParent():HasModifier("modifier_tyrant_king_aura") then
                self:SetStackCount(self:GetStackCount() + 1)
            end
        end
    end
end