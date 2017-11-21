local CrossGeneral = {}
setmetatable(CrossGeneral,{__index = _G})
setfenv(1, CrossGeneral)

local baseData = nil
local keyOwnGenerals = {} --以general_original_id为key的服务器武将数据列表

--更新显示
function NotificationUpdateShow()
	
end

function getOwnedGeneralByOriginalId(originalId)
	return keyOwnGenerals[originalId]
end

function getOwnedGenerals()
  return keyOwnGenerals
end

function SetData(data)
	baseData = data
    keyOwnGenerals = {}
	for key, generalInfo in pairs(baseData) do
	    keyOwnGenerals[generalInfo.general_id] = generalInfo --服务器发送的generalInfo.general_id 为general_original_id
    end
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


function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

function getGeneralById(gid)
	local data = GetData()

	for k, v in pairs(data) do 
		if v.general_id == gid then 
			return v
		end 
	end 

	return nil
end

return CrossGeneral