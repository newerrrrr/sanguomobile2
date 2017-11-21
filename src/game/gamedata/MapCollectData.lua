--收藏地图坐标
local MapCollectMode = {}
setmetatable(MapCollectMode,{__index = _G})
setfenv(1, MapCollectMode)

local baseData = nil
local preferMonsterLevel

local bossData = nil

local bossLevel = nil

--更新显示
function NotificationUpdateShow()
	print("MapCollectMode NotificationUpdateShow")
    --require("game.uilayer.mainSurface.mainSurfaceChat").skillUpdate()
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
			SetData(msgData.PlayerCoordinate)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{ name = {"PlayerCoordinate",} }, onRecv)
	return ret
end

function GetData(  )
	if baseData == nil then
		RequestData()
	end
	return baseData
end

--玩家设定的搜怪等级
function SetMonsterSearchLevel(level)
	preferMonsterLevel = level 
end 

function GetMonsterSearchLevel()
	return preferMonsterLevel
end

function SetBossData(data)
	bossData = data
end

function GetBossData()
	return bossData
end

function SetBossLevel(level)
	bossLevel = level
end

function GetBossLevel()
	return bossLevel
end

return MapCollectMode
