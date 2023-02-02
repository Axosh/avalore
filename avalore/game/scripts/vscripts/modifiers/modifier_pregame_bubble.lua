require ("constants")

modifier_pregame_bubble = class({})

function modifier_pregame_bubble:IsHidden() return true end
function modifier_pregame_bubble:IsDebugg() return true end
function modifier_pregame_bubble:IsPurgeable() return false end

function modifier_pregame_bubble:OnCreated(kv)
    if not IsServer() then return end

    local base_name = "radiant_base"
    if self:GetParent():GetTeam() == DOTA_TEAM_BADGUYS then
        base_name = "dire_base"
    end

    --self.radius = 1000
    self.radius = 900
    self.parent = self:GetParent()
    self.aura_origin = Entities:FindByName(nil, base_name):GetAbsOrigin()

    self.width = 100
    self.max_speed = 550
    self.min_speed = 0.1
    self.max_min = self.max_speed-self.min_speed
    self.inside = (self.parent:GetOrigin()-self.aura_origin):Length2D() < self.radius

    self.prev_loc = self:GetParent():GetAbsOrigin()

    self:StartIntervalThink(FrameTime())
end

function modifier_pregame_bubble:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

function modifier_pregame_bubble:OnIntervalThink()
    if not IsServer() then return end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME and GameRules:GetDOTATime(false, true) > Constants.TIME_FLAG_SPAWN then
        self:Destroy()
    elseif GameRules:State_Get() > DOTA_GAMERULES_STATE_PRE_GAME then
        self:Destroy()
    end

    -- make sure they didn't escape the bubble
    local parent_vector = self.parent:GetOrigin()-self.aura_origin
	local actual_distance = parent_vector:Length2D()
    --print("Dist => " .. tostring(actual_distance))
    if actual_distance > self.radius then
        self:GetParent():SetAbsOrigin(self.prev_loc)
    else
        self.prev_loc = self:GetParent():GetAbsOrigin()
    end
end


-- This is lifted from modifier_disruptor_kinetic_field_lua.lua in dota-2-lua-abilities on GitHub
function modifier_pregame_bubble:GetModifierMoveSpeed_Limit(kv)
    if not IsServer() then return end

    local parent_vector = self.parent:GetOrigin()-self.aura_origin
	local parent_direction = parent_vector:Normalized()

    -- check inside/outside
	local actual_distance = parent_vector:Length2D()
	local wall_distance = actual_distance-self.radius
	local over_walls = false
	if self.inside ~= (wall_distance<0) then
		-- moved to other side, check buffer
		if math.abs( wall_distance )>self.width then
			-- flip
			self.inside = not self.inside
		else
			over_walls = true
		end
	end	

	-- no limit if outside width
	wall_distance = math.abs(wall_distance)
	if wall_distance>self.width then return 0 end

	-- calculate facing angle
	local parent_angle = 0
	if self.inside then
		parent_angle = VectorToAngles(parent_direction).y
	else
		parent_angle = VectorToAngles(-parent_direction).y
	end
	local unit_angle = self:GetParent():GetAnglesAsVector().y
	local wall_angle = math.abs( AngleDiff( parent_angle, unit_angle ) )

	-- calculate movespeed limit
	local limit = 0
	if wall_angle<=90 then
		-- facing and touching wall
		if over_walls then
			limit = self.min_speed
			self:RemoveMotions()
		else
			-- interpolate
			limit = (wall_distance/self.width)*self.max_min + self.min_speed
		end
	else
		-- no limit if facing away
		limit = 0
	end

	return limit
end