local loading = {}
setmetatable(loading,{__index = _G})
setfenv(1,loading)



local m_Root = nil
local m_LoadingBar = nil
local m_RequestList = {}
local m_TotalCount = 0

local function clearGlobal()
	m_Root = nil
	m_LoadingBar = nil
	m_RequestList = {}
	m_TotalCount = 0
end



function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	
	
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
			rootLayer:unscheduleUpdate()
		elseif eventType == "enterTransitionFinish" then
			rootLayer:scheduleUpdateWithPriorityLua(update, 0)
			local function onClearLoginAnimation()
				ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("anime/Effect_RenWuLoading/Effect_RenWuLoading.ExportJson")
			end
			g_autoCallback.addCocosList(onClearLoginAnimation, 0.1)
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	
	local widget = g_gameTools.LoadCocosUI("schedule_update.csb",5)
	rootLayer:addChild(widget)
	
	local scale_node = widget:getChildByName("scale_node")
	
	local descData = g_data.loading_desc[math.random(1,#(g_data.loading_desc))]
	
	scale_node:getChildByName("Text_1"):setString(descData and g_tr(descData.tips) or "")
	
	m_LoadingBar = scale_node:getChildByName("LoadingBar_1")
	
	m_LoadingBar:setPercent(0)
	
	local funcs = require("game.uilayer.loading.loadingFunc")
	for k,v in pairs(funcs) do
		if(type(v) == "function")then
			m_RequestList[(#m_RequestList) + 1] = v
		else
			cToolsForLua:MessageBox("found not is \"function\" member in loading code file","lua error")
		end
	end
	
	m_TotalCount = math.max(1, table.total(m_RequestList))
	
	return rootLayer
end


function update(dt)
	if(m_Root==nil)then
		return
	end
	
	local status = 0
	for k , v in pairs(m_RequestList) do
		status = 1
		if(v() == true)then
			m_RequestList[k] = nil
		else
			socket.select(nil, nil, 2.0)
			if(v() == true)then
				m_RequestList[k] = nil
			else
				status = 2
			end
		end
		break
	end
	
	if(status == 0)then
		m_LoadingBar:setPercent(100)
		m_Root:unscheduleUpdate()
		local function inGameScene()
			g_gameStateManager.setFirstInGameFlag(true)
			g_sceneManager.setScene(g_sceneManager.sceneMode.game)
			local function onClearImage()
				cc.Director:getInstance():getTextureCache():removeUnusedTextures()
			end
			g_autoCallback.addCocosList(onClearImage, 1.0 )
		end
		g_autoCallback.addCocosList( inGameScene , 0.5 )
	elseif(status == 2)then
		m_Root:unscheduleUpdate()
		g_sceneManager.setScene(g_sceneManager.sceneMode.login)
		g_airBox.show(g_tr("loadingGameFail"))
	else
		m_LoadingBar:setPercent(math.clampf( (m_TotalCount - table.total(m_RequestList)) / m_TotalCount * 100 , 0, 100))
	end 
	
end



return loading