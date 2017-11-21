local homeScreenEffect = {}
setmetatable(homeScreenEffect,{__index = _G})
setfenv(1,homeScreenEffect)

local m_WeatherType = {	--这个字符串别改,有其他模块在使用
	[1] = "sunshine",
	[2] = "sunshine",
	[3] = "rain",
}

local m_Current_WeatherType = math.random(1,(#m_WeatherType))
local m_Last_Random_time = os.time()

local m_Root = nil
local m_Sunshine_Armature = nil
local m_Rain_Armature = nil

local function clearGlobal()
	m_Root = nil
	m_Sunshine_Armature = nil
	m_Rain_Armature = nil
end

function create()
	
	clearGlobal()
	
	local rootLayer = cc.Node:create()
	m_Root = rootLayer
	rootLayer:ignoreAnchorPointForPosition(false)
	rootLayer:setAnchorPoint(cc.p(0.5,0.5))
	rootLayer:setPosition(g_display.center)
	rootLayer:setContentSize(g_display.size)
	
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_weather, 6.0 , false)
			update_weather(0.01667)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	
	do --阳光
		local sunshine_Armature , sunshine_Animation = nil
		local function onPlay()
			sunshine_Armature:setVisible(m_WeatherType[m_Current_WeatherType] == "sunshine" and true or false)
			sunshine_Animation:play("Action0", -1, 0)
		end
		local function onMovementEventCallFunc(armature , eventType , name)
			if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
				sunshine_Armature:setVisible(false)
				sunshine_Armature:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(25,50)), cc.CallFunc:create(onPlay)))
			end
		end
		sunshine_Armature , sunshine_Animation = g_gameTools.LoadCocosAni("anime/Effect_ZhuChengSunShanGuang/Effect_ZhuChengSunShanGuang.ExportJson", "Effect_ZhuChengSunShanGuang", onMovementEventCallFunc)
		m_Sunshine_Armature = sunshine_Armature
		sunshine_Armature:setPosition(cc.p(g_display.right,g_display.top))
		rootLayer:addChild(sunshine_Armature)
		sunshine_Armature:setVisible(false)
		sunshine_Armature:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(10,15)), cc.CallFunc:create(onPlay)))
	end
	
	
	do --雨水
		local rain_Armature , rain_Animation = g_gameTools.LoadCocosAni("anime/Effect_ZhuChengRain/Effect_ZhuChengRain.ExportJson", "Effect_ZhuChengRain")
		m_Rain_Armature = rain_Armature
		rain_Armature:setPosition(cc.p(g_display.center.x,g_display.top))
		rootLayer:addChild(rain_Armature)
		rain_Animation:play("Animation1")
		rain_Armature:setVisible(m_WeatherType[m_Current_WeatherType] == "rain" and true or false)
	end
	
	
	rootLayer:setVisible(g_saveCache.power_save == 0 and true or false)
	
	return rootLayer
end


function updateForScrollViewTrans(viewSize, contentSize, offsetPosition)
	if m_Root == nil then
		return
	end
	local left_angle_x = 30
	local right_angle_x = -25
	local activity_size = cc.size(contentSize.width - viewSize.width, contentSize.height - viewSize.height)
	m_Sunshine_Armature:setRotation(left_angle_x + (right_angle_x - left_angle_x) * (offsetPosition.x * -1 / activity_size.width))
end


function update_weather(dt)
	local current_time = os.time()
	if m_Last_Random_time < current_time - 60.0 then
		m_Last_Random_time = current_time
		m_Current_WeatherType = math.random(1,(#m_WeatherType))
		m_Rain_Armature:setVisible(m_WeatherType[m_Current_WeatherType] == "rain" and true or false)
	end
end


function getCurrentWeather()
	return m_WeatherType[m_Current_WeatherType]
end


--省电开启
function onPowerSaveOpen()
	if m_Root == nil then
		return
	end
	m_Root:setVisible(false)
end


--省电关闭
function onPowerSaveClose()
	if m_Root == nil then
		return
	end
	m_Root:setVisible(true)
end


return homeScreenEffect