--region SoldierData.lua
--Author : luqingqing
--Date   : 2015/11/11
--此文件由[BabeLua]插件自动生成

local SoldierData = {}
setmetatable(SoldierData,{__index = _G})
setfenv(1, SoldierData)

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
			SetData(msgData.PlayerSoldier)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerSoldier",}},onRecv)
	return ret
end

--请求数据
function RequestSycData()
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.PlayerSoldier)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerSoldier",}},onRecv, true)
end

--得到背包所有道具,只可使用不可修改
function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

function GetBasicInfo(sid)
    return g_data.soldier[sid]
end

function GetSoldierNumber(sid)
    for key, value in pairs(GetData()) do
        if value.soldier_id == sid then
            return value.num
        end
    end

    return 0
end

function GetAllSoldierNumber()
    local data = GetData()
    local result = 0
    for key, value in pairs(data) do
            result = result + value.num
    end
    return result
end

return SoldierData

--endregion
