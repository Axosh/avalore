require("references")
require(REQ_AI_SHARED)
require(REQ_LIB_TIMERS)
--require("scripts/vscripts/items/demmi_hero_mercs/modifier_demi_hero_attr_bonus")

LinkLuaModifier( "modifier_demi_hero_attr_bonus", "scripts/vscripts/items/demi_hero_mercs/modifier_demi_hero_attr_bonus.lua", LUA_MODIFIER_MOTION_NONE )

function Spawn(entityKeyValues)
    -- client needs access to this info
    if thisEntity then
        thisEntity:AddNewModifier(thisEntity, nil, "modifier_demi_hero_attr_bonus", {manaPerLevel = 200, msPerLevel = 25})
    end

    if (not IsServer()) or (thisEntity == nil) then return end

    hIceShards      = thisEntity:FindAbilityByName("tusk_ice_shards")
    hSnowball       = thisEntity:FindAbilityByName("tusk_snowball")
    hNova           = thisEntity:FindAbilityByName("crystal_maiden_crystal_nova")
    hFreezingField  = thisEntity:FindAbilityByName("crystal_maiden_freezing_field")
    hSnowballRelease = thisEntity:FindAbilityByName("tusk_launch_snowball")

    if thisEntity:GetLevel() < 5 then
        --hFreezingField:setiSetHidden(true)
        hFreezingField:SetLevel(0)
    end

    if thisEntity:GetLevel() < 4 then
        hNova:SetLevel(0)
    end

    if thisEntity:GetLevel() < 3 then
        hSnowball:SetLevel(0)
        hSnowballRelease:SetLevel(0)
    end

    if thisEntity:GetLevel() < 2 then
        hIceShards:SetLevel(0)
    end

    -- thisEntity:SetMaxHealth(thisEntity:GetMaxHealth() +(thisEntity:GetLevel() * 500))
    -- thisEntity:SetMaxMana(thisEntity:GetMaxMana() +(thisEntity:GetLevel() * 200))
    -- thisEntity:SetDama
    thisEntity:SetHPGain( 500 )
    --thisEntity:SetManaGain(200) --doesn't work
    --thisEntity:SetMaxMana(thisEntity:GetMaxMana() + (thisEntity:GetLevel() * 200))
    thisEntity:SetDamageGain(50)
    thisEntity:SetArmorGain(2)
    thisEntity:SetAttackTimeGain(0.1)
    --thisEntity:SetMoveSpeedGain(25) -- doesn't work
    --thisEntity:SetBaseMoveSpeed(thisEntity:GetBaseMoveSpeed() + (thisEntity:GetLevel() * 25))

    --thisEntity:SetMana(thisEntity:GetMaxMana())
    thisEntity:GiveMana(9999)
    
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
    if self:GetLevel() > 1 then
        -- ==============
        -- ICE SHARDS
        -- ==============
        local hVisiblePlayers = GetVisibleEnemyHeroesInRange( thisEntity, nAggroRange )
        -- only try to do stuff if we see enemy heroes
        if #hVisiblePlayers > 0 then
            local hRandomPlayer = hVisiblePlayers[ RandomInt( 1, #hVisiblePlayers ) ]

            -- try to forecast 2 sec in the future so that shards don't always miss
            -- assumes they will not make any attempt to dodge
            local dirFacing = hRandomPlayer:GetForwardVector()
            local ms = hRandomPlayer:GetMoveSpeedModifier(hRandomPlayer:GetBaseMoveSpeed(), false)
            local guesstimateFuturePos = dirFacing * (ms * 2)

            if hIceShards:IsCooldownReady() and hIceShards:IsFullyCastable() then
                print("Casting Shards on " .. hRandomPlayer:GetUnitName())
                ExecuteOrderFromTable({
                    UnitIndex = thisEntity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    Position = hRandomPlayer:GetOrigin() + guesstimateFuturePos,
                    AbilityIndex = hIceShards:entindex(),
                    Queue = false,
                })
                hIceShards:RefundManaCost()
                return 1
            end
        end

        if self:GetLevel() > 2 then
            -- ==============
            -- SNOWBALL
            -- ==============
            local hVisiblePlayers = GetVisibleEnemyHeroesInRange( thisEntity, hSnowball:GetCastRange() )
            if #hVisiblePlayers > 0 then
                local hRandomPlayer = hVisiblePlayers[ RandomInt( 1, #hVisiblePlayers ) ]
    
                -- TODO: make better (just need some working prototype for now)
                if hSnowball:IsCooldownReady() and hSnowball:IsFullyCastable() then
                    print("Casting Snowball on " .. hRandomPlayer:GetUnitName())
                    ExecuteOrderFromTable({
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                        --Position = hTarget:GetOrigin(),
                        AbilityIndex = hSnowball:entindex(),
                        TargetIndex = hRandomPlayer:GetEntityIndex(),
                        Queue = false,
                    })
                    -- Launch Snowball after 1s
                    Timers:CreateTimer(1.0, function()
                        ExecuteOrderFromTable({
                            UnitIndex = thisEntity:entindex(),
                            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                            AbilityIndex = hSnowballRelease:entindex(),
                            Queue = false,
                        })
                    end)
                    hSnowball:RefundManaCost()
                    return 1
                end
            end

            if self:GetLevel() > 3 then
                -- ==============
                -- NOVA
                -- ==============
                --TODO: make this check if they're clustered before casting
                --local hVisibleEnemies = GetVisibleEnemiesNearby( thisEntity, nAggroRange )
                local hVisibleEnemies = GetVisibleEnemyHeroesInRange( thisEntity, hNova:GetCastRange() )
                print("Visible Enemies = " .. tostring(#hVisibleEnemies))
                --if #hVisibleEnemies > 3 then
                if #hVisibleEnemies > 1 then
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

                if self:GetLevel() > 4 then
                    -- ==============
                    -- FREEZING FIELD
                    -- ==============
                    local hVisibleEnemies = GetVisibleEnemiesNearby( thisEntity, hFreezingField:GetCastRange() )
                    if #hVisibleEnemies >= 1 then
                        local hRandomEnemy = hVisibleEnemies[ RandomInt( 1, #hVisibleEnemies ) ]
                        local vTargetLocation = hRandomEnemy:GetAbsOrigin()
                        if vTargetLocation ~= nil then
                            Order =
                            {
                                UnitIndex = self.me:entindex(),
                                OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                                AbilityIndex = hFreezingField:entindex(),
                                Queue = false,
                            }
                            hFreezingField:RefundManaCost()
                            return hFreezingField:GetChannelTime()
                            --Order.flOrderInterval = self.hFreezingField:GetChannelTime()
                        end
                    end
                end
            end
        end
    end
    return RandomFloat( 0.5, 1.5 )
end