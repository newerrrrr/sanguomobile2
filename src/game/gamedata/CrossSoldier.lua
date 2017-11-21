local CrossSoldier = {}
setmetatable(CrossSoldier,{__index = _G})
setfenv(1, CrossSoldier)

local baseData = nil

function NotificationUpdateShow()

end

function SetData(data)
	baseData = data
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			g_guildWarPlayerData.SetData(msgData.CrossPlayer)
			g_crossSoldier.SetData(msgData.CrossPlayerSoldier)
			g_crossGeneral.SetData(msgData.CrossPlayerGeneral)
			g_crossArmy.SetData(msgData.CrossPlayerArmy)
			g_crossArmyUnit.SetData(msgData.CrossPlayerArmyUnit)
			g_crossGuild.SetData(msgData.CrossGuild)
			g_crossPlayerMasterskill.SetData(msgData.CrossPlayerMasterskill)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"CrossPlayer","CrossPlayerSoldier", "CrossPlayerGeneral", "CrossPlayerArmy", "CrossPlayerArmyUnit","CrossGuild","CrossPlayerMasterskill"}},onRecv)
	return ret
end

--获取数据
function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

function GetCurentSoldierNumber()
	local data = GetData()

	if data == nil then
		return 0,tonumber(g_data.warfare_service_config[21].data)
	end

	local result = 0

	for key, value in pairs(data) do
		result = result + value.num
	end

	local armyUnit = g_crossArmyUnit.GetData()

	for key, value in pairs(armyUnit) do
		result = result + value.soldier_num
	end

	return result,tonumber(g_data.warfare_service_config[21].data)
end

function GetAllSoldierNumber()
	
    local data = GetData()
    local result = 0
    for key, value in pairs(data) do
            result = result + value.num
    end
    return result
end


return CrossSoldier