local busyTip = {}
setmetatable(busyTip,{__index = _G})
setfenv(1,busyTip)

local m_Tip_1 = nil

function show_1()
	if m_Tip_1 then
		m_Tip_1:removeFromParent(false)
	else
		m_Tip_1 = cc.LayerColor:create(cc.c4b(0,0,0,128))
		m_Tip_1:retain()
		cc.SpriteFrameCache:getInstance():addSpriteFrames("worldmap/worldmap_image.plist","worldmap/worldmap_image.png")
		local loadingImage = cc.Sprite:createWithSpriteFrameName("worldmap_image_loading.png")
		loadingImage:setPosition(g_display.center)
		loadingImage:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, 180)))
		m_Tip_1:addChild(loadingImage)
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local function onTouchBegan_MenuNode(touch, event)
			return true
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(true)
		touchListener:registerScriptHandler(onTouchBegan_MenuNode,cc.Handler.EVENT_TOUCH_BEGAN )
		eventDispatcher:addEventListenerWithSceneGraphPriority(touchListener,m_Tip_1)
		eventDispatcher:setDiscardAllTouchEndEventToCancelled(m_Tip_1)
	end
	g_sceneManager.addNodeForMsgBox(m_Tip_1)
end


function hide_1()
	if m_Tip_1 then
		m_Tip_1:removeFromParent()
		m_Tip_1:release()
		m_Tip_1 = nil
	end
end





return busyTip