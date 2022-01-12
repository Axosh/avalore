require("references")
require(REQ_AI_SHARED)

function Spawn(entityKeyValues)
    if (not IsServer()) or (thisEntity == nil) then return end

    hIceShards      = thisEntity:FindAbilityByName("tusk_ice_shards")
    hSnowball       = thisEntity:FindAbilityByName("tusk_snowball")
    hNova           = thisEntity:FindAbilityByName("crystal_maiden_crystal_nova")
    hFreezingField  = thisEntity:FindAbilityByName("crystal_maiden_freezing_field")

    if thisEntity:GetLevel() < 5 then
        --hFreezingField:setiSetHidden(true)
        hFreezingField:SetLevel(0)
    end

    if thisEntity:GetLevel() < 4 then
        hNova:SetLevel(0)
    end
    
    thisEntity:SetContextThink("YetiAIThink", YetiAIThink, 1)
end

function YetiAIThink(self)
    if not self:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end

    -- no spells at level 1, thus no special logic
    --if self:GetLevel() > 1 then
    if self:GetLevel() > 0 then -- for testing
        local hVisiblePlayers = GetVisibleEnemyHeroesInRange( thisEntity, nAggroRange )
        -- only try to do stuff if we see enemy heroes
        if #hVisiblePlayers > 0 then
            local hRandomPlayer = hVisiblePlayers[ RandomInt( 1, #hVisiblePlayers ) ]

            -- TODO: make better (just need some working prototype for now)
            if hIceShards:IsCooldownReady() and hIceShards:IsFullyCastable() then
                print("Casting Shards on " .. hRandomPlayer:GetUnitName())
                ExecuteOrderFromTable({
                    UnitIndex = thisEntity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    Position = hRandomPlayer:GetOrigin(),
                    AbilityIndex = hIceShards:entindex(),
                    Queue = false,
                })
                return 1
            end

            
        end

        local hVisibleEnemies = GetVisibleEnemiesNearby( thisEntity, nAggroRange )
        print("Visible Enemies = " .. tostring(#hVisibleEnemies))
        if #hVisibleEnemies > 3 then
            local hRandomEnemy = hVisibleEnemies[ RandomInt( 1, #hVisibleEnemies ) ]
            print("Casting Nova on " .. hRandomEnemy:GetUnitName())
            ExecuteOrderFromTable({
                UnitIndex = thisEntity:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                Position = hRandomEnemy:GetOrigin(),
                AbilityIndex = hNova:entindex(),
                Queue = false,
            })
            hNova:RefundManaCost()
            return 1
        end
    end
    return RandomFloat( 0.5, 1.5 )
end