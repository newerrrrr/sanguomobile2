local CityBattleArmy = {}
setmetatable(CityBattleArmy,{__index = _G})
setfenv(1, CityBattleArmy)

local baseData = nil

--更新显示
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
			g_cityBattleGuild.SetData(msgData.CityBattleCamp)
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

function GetArmyPosition(armyId)
    local data = GetData()

    if data[armyId..""] ~= nil then
        return data[armyId..""].position
    else
        return 0
    end
end

function GetMaxArmyNum(gid)
     
    local gData = g_GeneralMode.GetBasicInfo(gid, 1)
    local crossPlayer = g_cityBattlePlayerData.GetData()
    local max_soldier = 0
    local max_plus = 0
    local plus_percent = 0
    
    if crossPlayer.buff.troop_max_plus ~= nil then
		max_plus = crossPlayer.buff.troop_max_plus
	end

    if crossPlayer.buff.troop_max_plus_percent ~= nil then
		plus_percent = crossPlayer.buff.troop_max_plus_percent
	end

    max_soldier = ( gData.max_soldier + max_plus ) * ( plus_percent + 10000 ) / 10000

    return max_soldier
end

return CityBattleArmy