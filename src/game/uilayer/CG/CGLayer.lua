local CGLayer = {}
setmetatable(CGLayer,{__index = _G})
setfenv(1,CGLayer)


--CG动画

local m_Root = nil
local m_IsExecutedEnd = false

local function clearGlobal()
	m_Root = nil
	m_IsExecutedEnd = false
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
	
	local talk_widget = g_gameTools.LoadCocosUI("dialogue_panel.csb", 8)
	rootLayer:addChild(talk_widget, 2)
	
	local talk_scale_node = talk_widget:getChildByName("scale_node")
	
	local talk_left_Image = talk_scale_node:getChildByName("Panel_renwu1")
	talk_left_Image:loadTexture(g_data.sprite[1030115].path)
	
	local talk_right_Image = talk_scale_node:getChildByName("Panel_renwu2")
	talk_right_Image:loadTexture(g_data.sprite[1030143].path)
	
	local talk_panel_text = talk_scale_node:getChildByName("Panel_1")
	
	local talk_text_label = talk_panel_text:getChildByName("Text_1")
	talk_text_label:setText("")
	
	talk_widget:setVisible(false)
	
	local origin_text_position = cc.p(talk_panel_text:getPositionX(), talk_panel_text:getPositionY())
	talk_panel_text:setPosition(cc.p(origin_text_position.x,origin_text_position.y - 200))
	
	talk_left_Image:setScale(0.75)
	talk_left_Image:setColor(cc.c3b(162,162,162))
	talk_right_Image:setScale(0.75)
	talk_right_Image:setColor(cc.c3b(162,162,162))
	
	do
		local function onMovementEventCallFunc(armature , eventType , name)
			if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
				g_autoCallback.addCocosList( onCGEnd , 0.2 )
			end
		end
		
		local function onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
			if frameEventName == "talk_1" then
				talk_widget:setVisible(true)
				local function onTalk_1()
					talk_left_Image:runAction(cc.ScaleTo:create(0.25, 1.0))
					talk_left_Image:runAction(cc.TintTo:create(0.25, 255, 255, 255))
					talk_text_label:setText(g_tr("CG_Talk_1"))
				end
				talk_panel_text:runAction(cc.Sequence:create(cc.MoveTo:create(0.25, origin_text_position), cc.DelayTime:create(0.2), cc.CallFunc:create(onTalk_1)))
			elseif frameEventName == "talk_2" then
				talk_left_Image:runAction(cc.ScaleTo:create(0.25, 0.75))
				talk_left_Image:runAction(cc.TintTo:create(0.25, 162, 162, 162))
				
				talk_right_Image:runAction(cc.ScaleTo:create(0.25, 1.0))
				talk_right_Image:runAction(cc.TintTo:create(0.25, 255, 255, 255))
				
				talk_text_label:setText(g_tr("CG_Talk_2"))
			elseif frameEventName == "talk_3" then
				local function onTalkEnd()
					talk_widget:setVisible(false)
				end
				talk_panel_text:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(origin_text_position.x,origin_text_position.y - 150)), cc.CallFunc:create(onTalkEnd)))
			end
		end
		
		local armature , animation = g_gameTools.LoadCocosAni(
			"anime/anim_cg/anim_cg.ExportJson"
			, "anim_cg"
			, onMovementEventCallFunc
			, onFrameEventCallFunc
			)
		armature:setPosition(g_display.center)
		rootLayer:addChild(armature, 1)
		animation:play("dz", -1, 0)
	end
	

	local skip_widget = g_gameTools.LoadCocosUI("skip.csb", 3)
	rootLayer:addChild(skip_widget, 3)
	local function onButtonSkip(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			onCGEnd()
		end
	end
	skip_widget:getChildByName("scale_node"):getChildByName("Button_1"):addTouchEventListener(onButtonSkip)
	
	cc.Director:getInstance():setNextDeltaTimeZero(true)
	
	return rootLayer
end


function onCGEnd()
	if m_IsExecutedEnd == false then
		m_IsExecutedEnd = true
		g_sceneManager.setScene(g_sceneManager.sceneMode.clear)
	end
end



return CGLayer