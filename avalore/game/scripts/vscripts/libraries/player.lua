-- Checks if a given unit is a Boss unit
function CDOTA_BaseNPC:IsBoss()
	if self:GetName() == "npc_avalore_quest_wisp" or self:GetName() == "npc_dota_roshan" or self:GetUnitLabel() == "npc_avalore_round4_boss" or self:GetName() == "npc_avalore_gem_boss" then
		return true
	else
		return false
	end
end
