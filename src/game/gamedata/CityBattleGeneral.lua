local CityBattleGeneral = {}
setmetatable(CityBattleGeneral,{__index = _G})
setfenv(1, CityBattleGeneral)

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

return CityBattleGeneral