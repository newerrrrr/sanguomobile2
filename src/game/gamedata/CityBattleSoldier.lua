local CityBattleSoldier = {}
setmetatable(CityBattleSoldier,{__index = _G})
setfenv(1, CityBattleSoldier)

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
			g_cityBattlePlayerData.SetData(msgData.CityBattlePlayer)
			g_cityBattleSoldier.SetData(msgData.CityBattlePlayerSoldier)
			g_cityBattleGeneral.SetData(msgData.CityBattlePlayerGeneral)
			g_cityBattleArmy.SetData(msgData.CityBattlePlayerArmy)
			g_cityBattleArmyUnit.SetData(msgData.CityBattlePlayerArmyUnit)
			g_cityBattleCamp.SetData(msgData.CityBattleCamp)
			g_cityBattlePlayerMasterskill.SetData(msgData.CityBattlePlayerMasterskill)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"CityBattlePlayer","CityBattlePlayerSoldier", "CityBattlePlayerGeneral", "CityBattlePlayerArmy", "CityBattlePlayerArmyUnit","CityBattleCamp","CityBattlePlayerMasterskill"}},onRecv)
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
		return 0,tonumber(g_data.country_basic_setting[47].data)
	end

	local result = 0

	for key, value in pairs(data) do
		result = result + value.num
	end

	local armyUnit = g_cityBattleArmyUnit.GetData()

	for key, value in pairs(armyUnit) do
		result = result + value.soldier_num
	end

	return result,tonumber(g_data.country_basic_setting[47].data)
end

function GetAllSoldierNumber()
	
    local data = GetData()
    local result = 0
    for key, value in pairs(data) do
            result = result + value.num
    end
    return result
end


return CityBattleSoldier