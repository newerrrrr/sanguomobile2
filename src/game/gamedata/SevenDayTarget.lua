--region SevenDayTarget.lua
--Author : luqingqing
--Date   : 2016/5/13
--此文件由[BabeLua]插件自动生成

local SevenDayTarget = {}
setmetatable(SevenDayTarget,{__index = _G})
setfenv(1,SevenDayTarget)

local baseData = nil

local result = false

local baseView = nil

function SetView(value)
	baseView = value
end

function NotificationUpdateShow()
	result = false
    if baseData ~= nil then
        for i=1, #baseData do
            if baseData[i].current_value == baseData[i].target_value and baseData[i].award_status == 0 then
                result = true
                break
            end
        end
    end
    require("game.uilayer.mainSurface.mainSurfacePlayer").showSevenTargetEffect(result)

    if baseView ~= nil then
    	baseView:show()
    end
end

function SetData(data)
    baseData = data
end

function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerTarget)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerTarget",}},onRecv, false)
	return ret
end

function RequestSycData(callback)
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerTarget)
			NotificationUpdateShow()

			if callback ~= nil then
				callback()
			end
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerTarget",}},onRecv, true)
	return ret
end

function GetData()
	if baseData == nil then
		RequestData()
	end
	return baseData
end

function getResult()
	return result
end

return SevenDayTarget
--endregion
