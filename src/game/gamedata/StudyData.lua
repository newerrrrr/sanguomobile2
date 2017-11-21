--region StudyData.lua
--Author : luqingqing
--Date   : 2015/11/11
--此文件由[BabeLua]插件自动生成

local StudyDataMode = {}
setmetatable(StudyDataMode,{__index = _G})
setfenv(1, StudyDataMode)

local baseData = nil

--更新显示
function NotificationUpdateShow()
	
end


function SetData(data)
	baseData = data.PlayerStudy
end


--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerStudy",}},onRecv)
	return ret
end

--得到书院所有信息,只可使用不可修改
function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

return StudyDataMode

--endregion
