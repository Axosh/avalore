EXPORTS = {}

EXPORTS.Init = function( self )
	self.aiState = {
		--hAggroTarget = nil,
		--flShoutRange = 300,
		--nWalkingMoveSpeed = 140,
		--nAggroMoveSpeed = 280,
		--flAcquisitionRange = 600,
		vTargetWaypoint = nil,
	}
	self:SetContextThink( "init_think", function() 
		self.aiThink = aiThink
		--self.CheckIfHasAggro = CheckIfHasAggro
		--self.ShoutInRadius = ShoutInRadius
		self.RoamBetweenWaypoints = RoamBetweenWaypoints
        --self:SetAcquisitionRange( self.aiState.flAcquisitionRange )
        --self.bIsRoaring = false

	    -- Generate nearby waypoints for this unit
	    local tWaypoints = {}
	    local nWaypointsPerRoamNode = 3--10
	    local nMinWaypointSearchDistance = 2000--0
	    local nMaxWaypointSearchDistance = 8000--2048

	    while #tWaypoints < nWaypointsPerRoamNode do
	    	local vWaypoint = self:GetAbsOrigin() + RandomVector( RandomFloat( nMinWaypointSearchDistance, nMaxWaypointSearchDistance ) )
	    	if GridNav:CanFindPath( self:GetAbsOrigin(), vWaypoint ) then
	    		table.insert( tWaypoints, vWaypoint )
	    	end
	    end
	    self.aiState.tWaypoints = tWaypoints
	    self:SetContextThink( "ai_base_creature.aiThink", Dynamic_Wrap( self, "aiThink" ), 0 )
	end, 0 )
end

function aiThink( self )
    if not self:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end
	--if self:CheckIfHasAggro() then
	--	return RandomFloat( 0.5, 1.5 )
	--end
	return self:RoamBetweenWaypoints()
end

--------------------------------------------------------------------------------
-- RoamBetweenWaypoints
--------------------------------------------------------------------------------
function RoamBetweenWaypoints( self )
	local gameTime = GameRules:GetGameTime()
	local aiState = self.aiState
	if aiState.vWaypoint ~= nil then
		local flRoamTimeLeft = aiState.flNextWaypointTime - gameTime
		if flRoamTimeLeft <= 0 then
			aiState.vWaypoint = nil
		end
	end
    if aiState.vWaypoint == nil then
        aiState.vWaypoint = aiState.tWaypoints[ RandomInt( 1, #aiState.tWaypoints ) ]
        aiState.flNextWaypointTime = gameTime + RandomFloat( 2, 4 )
    	self:MoveToPositionAggressive( aiState.vWaypoint )
    end
   	return RandomFloat( 0.5, 1.0 )
end

return EXPORTS