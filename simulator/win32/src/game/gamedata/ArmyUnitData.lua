--region ArmyUnitData.lua
--Author : luqingqing
--Date   : 2015/11/18
--此文件由[BabeLua]插件自动生成

local ArmyUnitMode = {}
setmetatable(ArmyUnitMode,{__index = _G})
setfenv(1, ArmyUnitMode)

m_SoldierOriginType = {
    infantry = 1,--步兵
    cavalry=2,--骑兵
    archer=3,--弓兵
    vehicles=4,--车兵
}

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
			SetData(msgData.PlayerArmyUnit)
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerArmyUnit",}},onRecv)
	return ret
end

function RequestSycData()
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.PlayerArmyUnit)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerArmyUnit",}},onRecv, true)
end

--获取军团单位信息
function GetData()
    if baseData == nil then
        RequestData()
    end

	return baseData
end

function GetCurentData()
    return GetData()
end

--获取所有部队数量
function GetAllSodier()
    if baseData == nil then
        RequestData()
    end

    local armyData = g_ArmyMode.GetData()
    local soldierData = g_SoldierMode.GetData()

    local result ={}
	
	for k , v in pairs(m_SoldierOriginType) do
		result[v] = 0
	end

    for key, value in pairs(baseData) do
        if value.soldier_id ~= 0 then
            if armyData[value.army_id..""].status == 0 then
                local sData = g_data.soldier[value.soldier_id]
		        result[sData.soldier_type] = result[sData.soldier_type] + value.soldier_num
            end
        end
    end

    for key, value in pairs(soldierData) do
        local sData = g_data.soldier[value.soldier_id]
        result[sData.soldier_type] = result[sData.soldier_type] + value.num
    end

    return result
end

function GetArmyAllSoldier()
    local result = {}
    local data = GetData()
    local army = g_ArmyMode.GetData()

    for key, value in pairs(army) do
        result[value.position] = 0
    end

    for i=1, #data do
        if data[i].soldier_id ~= 0 then
            result[army[data[i].army_id..""].position] = result[army[data[i].army_id..""].position] + data[i].soldier_num
        end
    end

    return result
end

function ShowPop()
    local data = GetData()
    for key, value in pairs(data) do
        local maxArmy = g_ArmyMode.GetMaxArmyNum(value.general_id)
        if value.soldier_id == 0 and g_SoldierMode.GetAllSoldierNumber() > 0 then
            return true
        elseif value.soldier_id > 0 and maxArmy > value.soldier_num and g_SoldierMode.GetSoldierNumber(value.soldier_id) > 0 then
            return true
        end
    end
    return false
end

return ArmyUnitMode

--endregion
