ability_coyote_howl = class({})

function ability_coyote_howl:IsHiddenWhenStolen()       return false end
function ability_coyote_howl:IsRefreshable()            return true end
function ability_coyote_howl:IsStealable()              return true end
function ability_coyote_howl:IsNetherWardStealable()    return true end

function imba_vengefulspirit_wave_of_terror:OnSpellStart()
	if not IsServer() then return end

    --ensure vector has a length > 0
    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end

    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()

    -- Parameters
    local damage = self:GetSpecialValueFor("damage")
    local speed = self:GetSpecialValueFor("wave_speed")
    local wave_width = self:GetSpecialValueFor("wave_width")
    local duration = self:GetSpecialValueFor("duration")
    local primary_distance = self:GetCastRange(caster_loc,caster) + GetCastRangeIncrease(caster)

    --TODO: vision talent
    
end
