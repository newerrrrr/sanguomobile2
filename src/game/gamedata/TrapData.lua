
--陷阱数据
local TrapData = {}
setmetatable(TrapData,{__index = _G})
setfenv(1, TrapData)

local baseData = nil
local trapCount = nil
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
			SetData(msgData.PlayerTrap)
			NotificationUpdateShow()
		end
	end 

	g_sgHttp.postData("data/index",{name = {"PlayerTrap"}}, onRecv)

	return ret
end

function RequestSycData(callback)
    local function onRecv(result, msgData)
		
        if result == true then
		    SetData(msgData.PlayerTrap)
        end

        if callback then
            callback(result,msgData)
        end

	end 
	g_sgHttp.postData("data/index",{name = {"PlayerTrap"}}, onRecv,true)
end

function GetData()
	if(baseData == nil)then
		RequestData()
	end

	return baseData
end

--获取陷阱制造上限
--isRef 强制获取服务器数据
function GetTrapCount()
    local config = g_data.build[g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.rampart).build_id]
    local trapCount = config.output[2][2]
    --城墙信息
    local CQbuildInfo = g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.rampart)
    local position = CQbuildInfo and CQbuildInfo.position or nil
    trapCount = g_BuffMode.calculateFinalValueByBuffKeyName(trapCount,"pitfall_amount_plus",position)
    return trapCount
end


return TrapData

