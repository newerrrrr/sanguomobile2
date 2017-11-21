local mainSurfacePosition = {}
setmetatable(mainSurfacePosition,{__index = _G})
setfenv(1,mainSurfacePosition)



--野外下面中间的坐标UI

local m_Root = nil
local m_Widget = nil
local m_LastShow_bigTileIndex = nil

local function clearGlobal()
	m_Root = nil
	m_Widget = nil
	m_LastShow_bigTileIndex = nil
end


function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	m_Widget = g_gameTools.LoadCocosUI("worldmap_show_position.csb",8)
	rootLayer:addChild(m_Widget)
	
	m_Widget:getChildByName("scale_node"):getChildByName("Text_1"):setString("")
	
	
	local function onButton(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if m_LastShow_bigTileIndex then
				onButtonClick(cc.p(m_LastShow_bigTileIndex.x,m_LastShow_bigTileIndex.y))
			end
		end
	end
	m_Widget:getChildByName("scale_node"):getChildByName("Image_1"):addTouchEventListener(onButton)
	m_Widget:getChildByName("scale_node"):getChildByName("Image_2"):setTouchEnabled(true)
	m_Widget:getChildByName("scale_node"):getChildByName("Image_2"):addTouchEventListener(onButton)
	
	viewChangeShow()
	
	return rootLayer
end


function viewChangeShow()
	if m_Root then
		local changeMapScene = require("game.maplayer.changeMapScene")
		local mapStatus = changeMapScene.getCurrentMapStatus()
		if mapStatus == changeMapScene.m_MapEnum.home then
			m_Root:setVisible(false)
		elseif mapStatus == changeMapScene.m_MapEnum.world then
			m_Root:setVisible(true)
	  elseif mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then
      m_Root:setVisible(false)
		end
	end
end


function updateShow_bigTileIndex(bigTileIndex)
	if m_Root == nil then
		return
	end
	if m_LastShow_bigTileIndex == nil or m_LastShow_bigTileIndex.x ~= bigTileIndex.x or m_LastShow_bigTileIndex.y ~= bigTileIndex.y then
		m_Widget:getChildByName("scale_node"):getChildByName("Text_1"):setString(string.format("%d , %d",bigTileIndex.x,bigTileIndex.y))
		m_LastShow_bigTileIndex = cc.p(bigTileIndex.x, bigTileIndex.y)
	end
end


function onButtonClick(currentBigTileIndex)
	
	--g_airBox.show("刘毅来这里打开界面", 2)
	local jumpMapLayer = require("game.uilayer.map.jumpMapLayer")
    g_sceneManager.addNodeForUI( jumpMapLayer:create() )
end




return mainSurfacePosition