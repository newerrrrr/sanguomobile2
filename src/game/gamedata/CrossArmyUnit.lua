local CrossArmyUnit = {}
setmetatable(CrossArmyUnit,{__index = _G})
setfenv(1, CrossArmyUnit)

local baseData = nil
--更新显示
function NotificationUpdateShow()
	require("game.mapguildwar.worldMapLayer_uiLayer").updateArmyTip()
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

return CrossArmyUnit