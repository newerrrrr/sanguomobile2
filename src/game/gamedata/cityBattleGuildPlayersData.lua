--g_cityBattleCampPlayersData
local cityBattleGuildPlayersData = {}
setmetatable(cityBattleGuildPlayersData,{__index = _G})
setfenv(1,cityBattleGuildPlayersData)

local baseData = nil

--更新显示
function NotificationUpdateShow()
	require("game.mapcitybattle.worldMapLayer_bigMap").updateFog()
end

function SetData(data)
	baseData = data
end

function GetData()
  if baseData == nil then
      RequestData()
  end
	return baseData
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.guildPosition)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("City_Battle/getGuildPosition",{},onRecv)
	return ret
end

function RequestDataAsync(callback)
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.guildPosition)
			NotificationUpdateShow()
		end
		if callback then
			callback(result, msgData)
		end
	end
	g_sgHttp.postData("City_Battle/getGuildPosition",{},onRecv,true)
end

--function checkHaveXY
--end

return cityBattleGuildPlayersData