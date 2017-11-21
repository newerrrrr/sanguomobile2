local WallData = {}
setmetatable(WallData,{__index = _G})
setfenv(1, WallData)

function showPop()
	local playerData = g_PlayerMode.GetData()

	if playerData.wall_durability < playerData.wall_durability_max then
		local dt = playerData.last_repair_time - g_clock.getCurServerTime() + g_data.starting[27].data
		if dt < 0 then
			return true
		else
			return false
		end
	else
		return false
	end

	return false
end

return WallData