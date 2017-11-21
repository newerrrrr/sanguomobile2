local playerGuildMode = {}
setmetatable(playerGuildMode,{__index = _G})
setfenv(1,playerGuildMode)

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
			SetData(msgData.PlayerGuild)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerGuild",}},onRecv)
	return ret
end

function GetData()
	if baseData == nil then
		RequestData()
	end
	return baseData
end

return playerGuildMode