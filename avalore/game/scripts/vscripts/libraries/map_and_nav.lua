function BuildingLaneLocation(building_unit_name)
	local result = ""
	
	-- check top/bot first since there are more of those (tier4s)
	if string.find(building_unit_name, "top") then
		result = "top"
	elseif string.find(building_unit_name, "bot") then
		result = "bot"
	elseif string.find(building_unit_name, "mid") then
		result = "mid"
	end

	return result
end