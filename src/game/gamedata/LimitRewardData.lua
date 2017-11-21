--region LimitRewardData.lua  --限时领奖数据
--Author : liuyi
--Date   : 2016/4/6

local LimitRewardData = {}
setmetatable(LimitRewardData,{__index = _G})
setfenv(1,LimitRewardData)

local baseData = nil

function NotificationUpdateShow()
    require("game.uilayer.mainSurface.mainSurfacePlayer").updateShowWithData_LimitGift()
    require("game.uilayer.mainSurface.mainSurfacePlayer").viewChangeShow()
end

function SetData(data)
    baseData = data
end

function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerOnlineAward)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerOnlineAward",}},onRecv)
	return ret
end

function GetData()
	if baseData == nil then
		RequestData()
	end
	return baseData
end

--PlayerOnlineAward


return LimitRewardData