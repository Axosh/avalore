AVALORE_INVISIBLE_MODIFIERS = {
	"modifier_wearable_temp_invis",
    "modifier_deadly_fog_invis",
    "modifier_rogueish_escape",
	"modifier_faction_forest_fade",
	"modifier_water_fade",
	"modifier_forest_fade", -- generic version, unassociated with the faction
	-- built-in dota mods
	"modifier_persistent_invisibility",
	"modifier_invisible",
	"modifier_invisible_truesight_immune",
	"modifier_rune_invis",
	"modifier_rune_super_invis",
	"modifier_item_essence_of_shadow"
}

AVALORE_STATUS_MODIFIERS = {
	"modifier_avalore_ghost"
}

--LinkLuaModifier( "modifier_rogueish_escape", "heroes/robin_hood/ability_rich_poor", LUA_MODIFIER_MOTION_NONE )

-- Based on code from: dota imba
modifier_wearable = modifier_wearable or class({})

function modifier_wearable:CheckState() 
    return { 
        [MODIFIER_STATE_STUNNED] = (not self.pet),
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true
    } 
end

function modifier_wearable:IsPurgable() return false end
function modifier_wearable:IsStunDebuff() return false end
function modifier_wearable:IsPurgeException() return false end
function modifier_wearable:IsHidden() return true end

function modifier_wearable:OnCreated(kv)
	if not IsServer() then return end

	if kv.is_pet then
		self.pet = kv.is_pet
	else
		self.pet = false
	end

	print("Created a modifier_wearable for " .. self:GetParent():GetModelName())

	-- spawn in as invis so that it doesn't accidentally draw when its not supposed to
	-- (mostly applicable for Robin Hood because they can swap cosmetics as a skill)
	-- local cosmetic = self:GetParent()
	-- cosmetic:AddNewModifier(cosmetic, nil, "modifier_wearable_temp_invis", {isCosmetic = true})

	-- modifiers that when applied mean we shouldn't draw the cosmetic
	PrintTable(kv)
	if kv.no_draw_mod then
		self.no_draw_mod = kv.no_draw_mod
	else
		self.no_draw_mod = "modifier_dummy_no_draw" -- bogus value
	end

	if kv.destroy_on_death then
		self.destroy_on_death = true
	end

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

	if hero and hero:IsAlive() == false and self.destroy_on_death then
		self:GetParent():RemoveSelf()
		return
	end

	if hero == nil then
		if self.destroy_on_death then
			self:GetParent():RemoveSelf()
		end
		return
	end

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
				local mod = hero:FindModifierByName(v)
				print("Adding Modifier " .. tostring(v) .. " to " .. cosmetic:GetName() .. " for " .. hero:GetName())
				-- need to make sure we include the ability so that it can pull SpecialValues
				cosmetic:AddNewModifier(cosmetic, mod:GetAbility(), v, {isCosmetic = true})
				break
			end
		end
		-- monitor stacks since a lot of those are used for tracking countdowns to invis
		if hero:HasModifier(v) and cosmetic:HasModifier(v) then
			if hero:FindModifierByName(v):GetStackCount() ~= cosmetic:FindModifierByName(v) then
				cosmetic:FindModifierByName(v):SetStackCount(hero:FindModifierByName(v):GetStackCount())
			end
		end
	end

	for _, v in pairs(AVALORE_STATUS_MODIFIERS) do
		if not hero:HasModifier(v) then
			if cosmetic:HasModifier(v) then
				cosmetic:RemoveModifierByName(v)
			end
		else
			if not cosmetic:HasModifier(v) then
				local mod = hero:FindModifierByName(v)
				print("Adding Modifier " .. tostring(v) .. " to " .. cosmetic:GetName() .. " for " .. hero:GetName())
				-- need to make sure we include the ability so that it can pull SpecialValues
				cosmetic:AddNewModifier(cosmetic, mod:GetAbility(), v, {isCosmetic = true})
				break
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

	-- check for no-draw modifiers special to this hero/cosmetic
	-- local special_no_draw = false
	-- for key,value in pairs(self.no_draw_mods) do
	-- 	print("Checking for Modifier => " .. value)
	-- 	if hero:hasModifier(value) then
	-- 		--cosmetic:AddNoDraw()
	-- 		print("Found Special NoDraw Case ==> " .. value)
	-- 		special_no_draw = true
	-- 	end
	-- end

	-- if hero:HasModifier("modifier_no_hammer") then
	-- 	print("Hero has no_hammer")
	-- 	print(self.no_draw_mod)
	-- end

	if (hero:IsOutOfGame() or hero:IsHexed()
		or hero:HasModifier("modifier_shapeshift_eagle")
		or hero:HasModifier("modifier_72_bian_boar")
		or hero:HasModifier("modifier_72_bian_bird")
		or hero:HasModifier("modifier_72_bian_tree")
		or hero:HasModifier(self.no_draw_mod)) then
		--or special_no_draw) then
			--print("Adding NoDraw to " .. cosmetic:GetModelName())
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
		elseif hero:GetName() == "npc_dota_hero_dawnbreaker" then
			if hero:HasModifier("modifier_thunder_gods_strength_buff") then
				if cosmetic:GetModelName() == "models/items/dawnbreaker/first_light_head/first_light_head.vmdl" then
					cosmetic:AddNoDraw()
				elseif cosmetic:GetModelName() == "models/heroes/dawnbreaker/dawnbreaker_head.vmdl" then
					cosmetic:RemoveNoDraw()
				end
			else
				if cosmetic:GetModelName() == "models/items/dawnbreaker/first_light_head/first_light_head.vmdl" then
					cosmetic:RemoveNoDraw()
				elseif cosmetic:GetModelName() == "models/heroes/dawnbreaker/dawnbreaker_head.vmdl" then
					cosmetic:AddNoDraw()
				end
			end
		end
	end

end
