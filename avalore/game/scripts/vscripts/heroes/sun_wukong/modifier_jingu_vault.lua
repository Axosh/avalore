require("references")
require(REQ_LIB_TIMERS)

modifier_jingu_vault = class({})

function modifier_jingu_vault:IsHidden() return true end
function modifier_jingu_vault:IsPurgable() return false end
function modifier_jingu_vault:IsDebuff() return false end
function modifier_jingu_vault:IgnoreTenacity() return true end
function modifier_jingu_vault:IsMotionController() return true end
function modifier_jingu_vault:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_jingu_vault:OnCreated(kv)
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()

    self.vault_speed = self.ability:GetSpecialValueFor("vault_speed")
    
    if not IsServer() then return end
    -- Variables
    self.time_elapsed = 0
    self.leap_z = 0
    self.target_point = Vector(kv.target_point_x, kv.target_point_y, kv.target_point_z)

    PrintVector(self.target_point, "Target Point")
    --self.caster:SetForwardVector(self.target_point)
    self.caster:FaceTowards(self.target_point)

    -- Wait one frame to get the target point from the ability's OnSpellStart, then calculate distance
    --Timers:CreateTimer(FrameTime(), function()
    Timers:CreateTimer(0.4, function()
        self.distance = (self.caster:GetAbsOrigin() - self.target_point):Length2D()
        self.vault_time = self.distance / self.vault_speed

        self.direction = (self.target_point - self.caster:GetAbsOrigin()):Normalized()

        self.frametime = FrameTime()
        self.caster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
        self.caster:StartGesture(ACT_DOTA_MK_SPRING_SOAR)
        self:StartIntervalThink(self.frametime)
    end)
end

function modifier_jingu_vault:OnIntervalThink()
	-- Check motion controllers
	-- if not self:CheckMotionControllers() then
	-- 	self:Destroy()
	-- 	return nil
	-- end

	-- Vertical Motion
	self:VerticalMotion(self.caster, self.frametime)

	-- Horizontal Motion
	self:HorizontalMotion(self.caster, self.frametime)

	self.ability:StartCooldown(0)
end

function modifier_jingu_vault:VerticalMotion(me, dt)
    if not IsServer() then return end

    -- Check if we're still jumping
    if self.time_elapsed < self.vault_time then

        -- Check if we should be going up or down
        if self.time_elapsed <= self.vault_time / 2 then
            -- Going up
            self.leap_z = self.leap_z + 30


            self.caster:SetAbsOrigin(GetGroundPosition(self.caster:GetAbsOrigin(), self.caster) + Vector(0,0,self.leap_z))
        else
            -- Going down
            self.leap_z = self.leap_z - 30
            if self.leap_z > 0 then
                self.caster:SetAbsOrigin(GetGroundPosition(self.caster:GetAbsOrigin(), self.caster) + Vector(0,0,self.leap_z))
            end
        end
    end
end

function modifier_jingu_vault:HorizontalMotion(me, dt)
    if not IsServer() then return end

    -- Check if we're still jumping
    self.time_elapsed = self.time_elapsed + dt
    if self.time_elapsed < self.vault_time then

        -- Go forward
        local new_location = self.caster:GetAbsOrigin() + self.direction * self.vault_speed * dt
        self.caster:SetAbsOrigin(new_location)
    else
        self.caster:RemoveGesture(ACT_DOTA_MK_SPRING_SOAR)
        --self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1 )
        self.caster:StartGesture(ACT_DOTA_MK_SPRING_END)
        self:Destroy()
    end
end

function modifier_jingu_vault:OnRemoved()
    if not IsServer() then return end
    self.caster:RemoveGesture(ACT_DOTA_MK_SPRING_SOAR)
    self.caster:RemoveGesture(ACT_DOTA_MK_STRIKE )
    self.caster:RemoveGesture(ACT_DOTA_MK_SPRING_END)
    self.caster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
    FindClearSpaceForUnit(self.caster, self.caster:GetAbsOrigin(), false)

	-- if IsServer() then
	-- 	self.caster:SetUnitOnClearGround()
	-- end
end