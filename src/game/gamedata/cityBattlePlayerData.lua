--g_cityBattlePlayerData
local cityBattlePlayerData = {}
setmetatable(cityBattlePlayerData,{__index = _G})
setfenv(1,cityBattlePlayerData)

local baseData = nil
function NotificationUpdateShow()
	require("game.mapcitybattle.worldMapLayer_uiLayer").updatePlayerInfo() 
end

function SetData(data)
	baseData = data
end

--得到基本信息,只可使用不可修改
function GetData()
	if baseData == nil then
		RequestAllCityBattleData()
	end
	return baseData
end

--获取玩家出生点
function GetPosition()
	local data = GetData()
	local pos = cc.p(0,0)
	if hasSelectedOnMap() then --如果玩家已经选择过复活点
		pos = cc.p(data.x,data.y)
	else
		if g_cityBattleInfoData.IsAttacker() then
			pos = cc.p(38,34)
		else
			pos = cc.p(55,23)
		end
	end
	return pos
end

--请求数据
function RequestAllCityBattleData()
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

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.CityBattlePlayer)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"CityBattlePlayer",}},onRecv)
	return ret
end

--请求数据
function RequestDataAsync( fun,isShow )
    local _IsShow = isShow or false
	local function onRecv(result, msgData)
        if _IsShow then
            g_busyTip.hide_1()
        end
		if(result==true)then
			SetData(msgData.CityBattlePlayer)
			NotificationUpdateShow()
            if fun then
                fun()
            end
		end
	end
    if _IsShow then
        g_busyTip.show_1()
    end
	g_sgHttp.postData("data/index",{name = {"CityBattlePlayer",}},onRecv,true)
end

function getGuildId()
	local playerData = GetData()
	return playerData.guild_id
end

function getCampId()
	local playerData = GetData()
	return playerData.camp_id
end

--本轮是否已经强制选择过复活点
function hasSelectedOnMap()
	local isBol = false
	local playerData = GetData()
	if playerData.change_location_time and type(playerData.change_location_time) == "number" and playerData.change_location_time > 0 then
		isBol = true
	else
		isBol = false
	end
	return isBol
end

return cityBattlePlayerData