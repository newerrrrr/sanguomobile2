local screenFire = {}
setmetatable(screenFire,{__index = _G})
setfenv(1,screenFire)


local m_Root = nil

local function clearGlobal()
	m_Root = nil
end

local c_tag_action = 55412149

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
			if rootLayer == m_Root then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	
	rootLayer:setCascadeOpacityEnabled(true)
	
	
	local display_top = cc.Sprite:create("homeImage/screenFire.png")
	display_top:setAnchorPoint(cc.p(0.5, 1.0))
	local size = display_top:getContentSize()
	display_top:setFlippedY(true)
	display_top:setPosition(g_display.top_center)
	if g_display.visibleSize.width > size.width then
		display_top:setScaleX(g_display.visibleSize.width / size.width)
	end
	rootLayer:addChild(display_top)
	
	
	local display_bottom = cc.Sprite:create("homeImage/screenFire.png")
	display_bottom:setAnchorPoint(cc.p(0.5, 0.0))
	display_bottom:setPosition(g_display.bottom_center)
	if g_display.visibleSize.width > size.width then
		display_bottom:setScaleX(g_display.visibleSize.width / size.width)
	end
	rootLayer:addChild(display_bottom)
	
	
	local display_left = cc.Sprite:create("homeImage/screenFire.png")
	display_left:setAnchorPoint(cc.p(0.5, 0.0))
	display_left:setPosition(g_display.left_center)
	display_left:setRotation(90.0)
	rootLayer:addChild(display_left)
	
	
	local display_right = cc.Sprite:create("homeImage/screenFire.png")
	display_right:setAnchorPoint(cc.p(0.5, 0.0))
	display_right:setPosition(g_display.right_center)
	display_right:setRotation(-90.0)
	rootLayer:addChild(display_right)
	
	hide()

	return rootLayer
end


function show()
	if m_Root == nil then
		return
	end
	m_Root:setVisible(true)
	if m_Root:getActionByTag(c_tag_action) == nil then
		local action = cc.RepeatForever:create( cc.Sequence:create( cc.FadeTo:create(1.0, 0) , cc.FadeTo:create(1.0, 255) ) )
		action:setTag(c_tag_action)
		m_Root:runAction(action)
	end
end


function hide()
	if m_Root == nil then
		return
	end
	m_Root:setVisible(false)
	m_Root:stopActionByTag(c_tag_action)
end


return screenFire