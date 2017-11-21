--g_guildWarPlayerData
local guildWarPlayerData = {}
setmetatable(guildWarPlayerData,{__index = _G})
setfenv(1,guildWarPlayerData)

local baseData = nil
function NotificationUpdateShow()
	require("game.mapguildwar.worldMapLayer_uiLayer").updatePlayerInfo() 
end

function SetData(data)
	baseData = data
end

--得到基本信息,只可使用不可修改
function GetData()
	if baseData == nil then
		RequestAllCrossData()
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
		if g_guildWarBattleInfoData.IsAttacker() then
			pos = cc.p(38,34)
		else
			pos = cc.p(55,23)
		end
	end
	return pos
end

--请求数据
function RequestAllCrossData()
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

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.CrossPlayer)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"CrossPlayer",}},onRecv)
	return ret
end

--请求数据
function RequestDataAsync()
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.CrossPlayer)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"CrossPlayer",}},onRecv,true)
end

function getGuildId()
	local playerData = GetData()
	return playerData.guild_id
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

return guildWarPlayerData