local playerInfoDataMode = {}
setmetatable(playerInfoDataMode,{__index = _G})
setfenv(1,playerInfoDataMode)


local baseData = nil


--显示更新可以放这里
function NotificationUpdateShow()
	g_PlayerPubMode.checkHaveStarReward()
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
			SetData(msgData.PlayerInfo)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerInfo",}},onRecv)
	return ret
end




--public


--得到数据信息,只可使用不可修改
function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

function IsOpen()
    local data = GetData()
    if data.target_end_time - g_clock.getCurServerTime() > 0 then
        return true
    else
        return false
    end
end




return playerInfoDataMode