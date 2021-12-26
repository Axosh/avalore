AVALORE_INVISIBLE_MODIFIERS = {
	"modifier_wearable_temp_invis",
    "modifier_deadly_fog_invis",
    "modifier_rogueish_escape",
	"modifier_faction_forest_fade",
	"modifier_water_fade"
}

--LinkLuaModifier( "modifier_rogueish_escape", "heroes/robin_hood/ability_rich_poor", LUA_MODIFIER_MOTION_NONE )

-- Based on code from: dota imba
modifier_wearable = modifier_wearable or class({})

function modifier_wearable:CheckState() 
    return { 
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    } 
end

function modifier_wearable:IsPurgable() return false end
function modifier_wearable:IsStunDebuff() return false end
function modifier_wearable:IsPurgeException() return false end
function modifier_wearable:IsHidden() return true end

function modifier_wearable:OnCreated()
	--print("Created a modifier_wearable")
	if not IsServer() then return end

	-- spawn in as invis so that it doesn't accidentally draw when its not supposed to
	-- (mostly applicable for Robin Hood because they can swap cosmetics as a skill)
	-- local cosmetic = self:GetParent()
	-- cosmetic:AddNewModifier(cosmetic, nil, "modifier_wearable_temp_invis", {isCosmetic = true})

	self:StartIntervalThink(FrameTime())
	self.render_color = nil
	--self.illusion = self:GetParent():GetOwnerEntity():IsIllusion()
end

function modifier_wearable:OnIntervalThink()
	local cosmetic = self:GetParent()
	local hero = cosmetic:GetOwnerEntity()

	if hero then
		self.illusion = hero:IsIllusion()
	end

	-- if hero:IsIllusion() then
	-- 	cosmetic:SetRenderColor(0,0,220)
	-- end

	if hero == nil then return end

	-- if self.illusion and not hero:IsAlive() then
	-- 	cosmetic:AddNoDraw() -- if it was an illusion (poofs) don't draw the cosmetic until its garbage collected
	-- end

	--print("Cosmetic " .. cosmetic:GetName() .. " is thinking")

-- 	if self.render_color == nil then
-- 		if hero:HasModifier("modifier_juggernaut_arcana") then
-- --			print("Jugg arcana 1, Color wearables!")
-- 			self.render_color = true
-- 			cosmetic:SetRenderColor(80, 80, 100)
-- 		elseif hero:HasModifier("modifier_juggernaut_arcana") and hero:FindModifierByName("modifier_juggernaut_arcana"):GetStackCount() == 1 then
-- 			print("Jugg arcana 2, Color wearables!")
-- 			self.render_color = true
-- 			cosmetic:SetRenderColor(255, 220, 220)
-- 		elseif hero:GetUnitName() == "npc_dota_hero_vardor" then
-- --			print("Vardor, Color wearables!")
-- 			self.render_color = true
-- 			cosmetic:SetRenderColor(255, 0, 0)
-- 		end
-- 	end

	for _, v in pairs(AVALORE_INVISIBLE_MODIFIERS) do
		if not hero:HasModifier(v) then
			if cosmetic:HasModifier(v) then
				cosmetic:RemoveModifierByName(v)
			end
		else
			if not cosmetic:HasModifier(v) then
				print("Adding Modifier " .. tostring(v) .. " to " .. cosmetic:GetName() .. " for " .. hero:GetName())
				cosmetic:AddNewModifier(cosmetic, nil, v, {isCosmetic = true})
				break -- remove this break if you want to add multiple modifiers at the same time
			end
		end
		-- monitor stacks since a lot of those are used for tracking countdowns to invis
		if hero:HasModifier(v) and cosmetic:HasModifier(v) then
			if hero:FindModifierByName(v):GetStackCount() ~= cosmetic:FindModifierByName(v) then
				cosmetic:FindModifierByName(v):SetStackCount(hero:FindModifierByName(v):GetStackCount())
			end
		end
	end

	-- for _, v in pairs(IMBA_NODRAW_MODIFIERS) do
	-- 	if hero:HasModifier(v) then
	-- 		if not cosmetic.model then
	-- 			print("ADD NODRAW TO COSMETICS")
	-- 			cosmetic.model = cosmetic:GetModelName()
	-- 		end

	-- 		if cosmetic.model and cosmetic:GetModelName() ~= "models/development/invisiblebox.vmdl" then
	-- 			cosmetic:SetOriginalModel("models/development/invisiblebox.vmdl")
	-- 			cosmetic:SetModel("models/development/invisiblebox.vmdl")
	-- 			break
	-- 		end
	-- 	else
	-- 		if cosmetic.model and cosmetic:GetModelName() ~= cosmetic.model then
	-- 			print("REMOVE NODRAW TO COSMETICS")
	-- 			cosmetic:SetOriginalModel(cosmetic.model)
	-- 			cosmetic:SetModel(cosmetic.model)
	-- 			break
	-- 		end
	-- 	end
	-- end

	if hero:IsOutOfGame() or hero:IsHexed() or hero:HasModifier("modifier_shapeshift_eagle") then
		cosmetic:AddNoDraw()
	else
		cosmetic:RemoveNoDraw()
		-- For Robin-Hood since they can swap weapons
		if hero:GetName() == "npc_dota_hero_windrunner" then --or hero:GetName() == "npc_dota_hero_robin_hood" then
			if cosmetic:GetModelName() == "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_bow/the_swift_pathfinder_swift_pathfinders_bow.vmdl" then
				if hero:HasModifier("modifier_jack_of_all_trades_melee")  then
					cosmetic:AddNoDraw()
				end
			-- if we get here they either are in ranged form, or don't have the ability learned yet
			elseif cosmetic:GetModelName() == "models/items/kunkka/ti9_cache_kunkka_kunkkquistador_weapon/ti9_cache_kunkka_kunkkquistador_weapon.vmdl" then
				if not hero:HasModifier("modifier_jack_of_all_trades_melee") then
					cosmetic:AddNoDraw()
				end
			end
		elseif hero:GetName() == "npc_dota_hero_monkey_king" then
			if hero:HasModifier("modifier_72_bian_fish") then
				if (cosmetic:GetModelName() == "models/items/siren/naga_ti8_immortal_tail/naga_ti8_immortal_tail.vmdl"
					or cosmetic:GetModelName() == "models/items/siren/luminous_warrior_head/luminous_warrior_head.vmdl" 
					or cosmetic:GetModelName() == "models/heroes/monkey_king/monkey_king_base_weapon.vmdl") then
						cosmetic:RemoveNoDraw()
				else
					cosmetic:AddNoDraw()
				end
			else
				if (cosmetic:GetModelName() == "models/items/siren/naga_ti8_immortal_tail/naga_ti8_immortal_tail.vmdl"
					or cosmetic:GetModelName() == "models/items/siren/luminous_warrior_head/luminous_warrior_head.vmdl") then
						cosmetic:AddNoDraw()
						--print("MK Cosmetic ==> " .. cosmetic:GetModelName())
				else
					cosmetic:RemoveNoDraw()
				end
			end
		end
	end

end
