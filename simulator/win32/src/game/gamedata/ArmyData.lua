--region ArmyData.lua
--Author : luqingqing
--Date   : 2015/11/11
--此文件由[BabeLua]插件自动生成

local ArmyDataMode = {}
setmetatable(ArmyDataMode,{__index = _G})
setfenv(1, ArmyDataMode)

local baseData = nil

local curArmy = 1

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
			SetData(msgData.PlayerArmy)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerArmy",}},onRecv)
	return ret
end

function RequestSycData()
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.PlayerArmy)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerArmy",}},onRecv, true)
end

--获取军团信息
function GetData()
    if baseData == nil then
        RequestData()
    end

	return baseData
end

--返回XX军团
function GetArmyPosition(armyId)
    local data = GetData()

    if data[armyId..""] ~= nil then
        return data[armyId..""].position
    else
        return 0
    end
end

function GetMaxArmyNum(gid)
    local buildData = g_PlayerBuildMode.FindBuild_high_OriginID(g_PlayerBuildMode.m_BuildOriginType.spectacular)
    local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName("troop_max_plus",buildData.position)

    local gData = g_GeneralMode.GetBasicInfo(gid, 1)
    local bData = g_data.build[g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.spectacular).build_id].output[1][2]

    local orginalValue = (gData.max_soldier + buffValue + bData)

    local resultVaule = g_BuffMode.calculateFinalValueByBuffKeyName(orginalValue,"troop_max_plus_percent",buildData.position)

    return resultVaule
end

function ShowPop()
    local buff = g_BuffMode.GetData()

    local playerData = g_PlayerMode.GetData()

    local maxArmyNum = tonumber(g_data.starting[19].data) + buff["deputy_per_corp"].v

    local allTab = playerData.army_num + buff["corps_in_control"].v

    local armyData = g_ArmyMode.GetData()

    local armyUnitData = g_ArmyUnitMode.GetData()

    local general = g_GeneralMode.GetData()

    local happ = false

    for key, value in pairs(general) do
        if value.army_id == 0 then
            happ = true
            break
        end
    end

    if happ == false then
        return false
    end

    --vip导致的军团增加
    local max = 0
    for key, value in pairs(armyData) do
        if value.position > max then
            max = value.position
        end
    end

    if max > allTab then
        allTab = max
    end

    local tag = false

    for i=1, allTab do
        for key, value in pairs(armyData) do
            if value.position == i then
                local num = 0
                for j=1, #armyUnitData do
                    if armyUnitData[j].army_id == value.id then
                        num = num + 1
                    end
                end
                if num ~= maxArmyNum then
                    tag = true
                    curArmy = i
                    break
                end
            end
        end

        if tag == true then
            break
        end
    end

    return tag
end

function getCurArmy()
    return curArmy
end

return ArmyDataMode

--endregion
