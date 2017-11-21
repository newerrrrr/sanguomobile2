--region SignData.lua
--Author : luqingqing
--Date   : 2016/5/16
--此文件由[BabeLua]插件自动生成

local SignData = {}
setmetatable(SignData,{__index = _G})
setfenv(1, SignData)

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
			SetData(msgData.PlayerSignAward)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerSignAward",}},onRecv, false)
	return ret
end

--请求数据
function RequestSycData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerSignAward)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerSignAward",}},onRecv, true)
	return ret
end

function GetData()
    if baseData == nil then
        RequestData()
    end

	return baseData
end

return SignData

--endregion
