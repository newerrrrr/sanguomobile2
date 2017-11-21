local CityBattleArmyUnit = {}
setmetatable(CityBattleArmyUnit,{__index = _G})
setfenv(1, CityBattleArmyUnit)

local baseData = nil
--更新显示
function NotificationUpdateShow()
	require("game.mapcitybattle.worldMapLayer_uiLayer").updateArmyTip()
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


function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

function ArmyWithSoldier()
    local data = GetData()
    local tag = false
    for key, value in pairs(data) do
        local maxArmy = g_ArmyMode.GetMaxArmyNum(value.general_id)
        if value.soldier_id == 0 or maxArmy > value.soldier_num then
            tag = true
            break
        end
    end

    return tag
end

function GeneralWithSoldier()
    local data = GetData()

    local tag = true
    for key, value in pairs(data) do
        if value.soldier_id ~= 0 then
            tag = false
            break
        end
    end

    return tag
end

return CityBattleArmyUnit