local msgBox = {}
setmetatable(msgBox,{__index = _G})
setfenv(1,msgBox)


local function _create(text, title, ctp, callback, utp, changeTab)
	local widget = g_gameTools.LoadCocosUI("system_message_popup.csb",5)
	
	local scale_node = widget:getChildByName("scale_node")
	
	local content_popup = scale_node:getChildByName("content_popup")
	
	local uiText = content_popup:getChildByName("Text_1")
	
	uiText:setString(text and text or "")
	
	local color = nil
	if(ctp == nil)then
		color = cc.c4b(255,255,255,255)
	elseif(ctp == 1)then
		color = cc.c4b(0,255,0,255)
	elseif(ctp == 2)then
		color = cc.c4b(255,255,0,255)
	elseif(ctp == 3)then
		color = cc.c4b(255,0,0,255)
	else
		color = cc.c4b(255,255,255,255)
	end
	uiText:setTextColor(color)
	
	local uiTitle = content_popup:getChildByName("bg_title"):getChildByName("Text_2")
	
	uiTitle:setString(title and title or g_tr("msgBox_system"))
	
	local open_animation_completed = false
	
	local function onButtonOK(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
			    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
				widget:removeFromParent()
				if(callback and type(callback)=="function")then
					callback(0)
				end
			end
		end
	end
	
	local function onButtonCancle(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
			    g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
				widget:removeFromParent()
				if(callback and type(callback)=="function")then
					callback(1)
				end
			end
		end
	end
	
	local bt1 = content_popup:getChildByName("btn_1")
	bt1:getChildByName("Text_1"):setString(g_tr("msgBox_ok"))
	local bt2 = content_popup:getChildByName("btn_confirm")
	bt2:getChildByName("Text_1"):setString(g_tr("msgBox_ok"))
	local bt3 = content_popup:getChildByName("btn_cancle")
	bt3:getChildByName("Text_1"):setString(g_tr("msgBox_cancle"))

	if(utp == nil or utp == 0)then -- 0
		bt1:setVisible(true)
		bt2:setVisible(false)
		bt3:setVisible(false)
		bt1:addTouchEventListener(onButtonOK)
	elseif(utp == 1)then -- 1
		bt1:setVisible(false)
		bt2:setVisible(true)
		bt3:setVisible(true)
		bt2:addTouchEventListener(onButtonOK)
		bt3:addTouchEventListener(onButtonCancle)
	else--default --0
		bt1:setVisible(true)
		bt2:setVisible(false)
		bt3:setVisible(false)
		bt1:addTouchEventListener(onButtonOK)
	end
	
	if changeTab and type(changeTab)=="table" then
		local function change(t,v)
			if type(t) == "string" then
				if t == "0" then
					content_popup:getChildByName("btn_1"):getChildByName("Text_1"):setString(v)
					content_popup:getChildByName("btn_confirm"):getChildByName("Text_1"):setString(v)
				elseif t == "1" then
					content_popup:getChildByName("btn_cancle"):getChildByName("Text_1"):setString(v)
				end
			end
		end
		for k,v in pairs(changeTab) do
			change(k,v)
		end
	end
	
	local origin_scale = scale_node:getScale()
	scale_node:setScale(origin_scale * 0.5)
	scale_node:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.35, origin_scale)), cc.CallFunc:create(function() open_animation_completed = true end)))
	
	local function widgetEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    widget:registerScriptHandler(widgetEventHandler)
	
	return widget
end


--显示一个提示框或二次确认框
--参数： text 显示文本
--参数： title 标题文本 ，不传为默认标题
--参数： ctp 显示类型 ， 不传为默认类型(白色), 1为成功类型(绿色) ,2为警告(黄色) ,3为错误(红色)
--参数:  callback 回调监听 ， 可以不传 , 回调形参是一个event (0是点击了确定,1是点击了取消) --事件类型必须判断是否是自己想要的,今后可能扩展234567....
--参数： utp 按钮类型 ， 不传或者传0都为默认只出现一个确认按钮,传1为确认和取消两个按钮
--参数:  changeTab 修改数据 , {["0"] = "确定按钮文字" , ["1"] = "取消按钮文字"}
function show(text, title, ctp, callback, utp, changeTab)
	g_sceneManager.addNodeForMsgBox(_create(text, title, ctp, callback, utp, changeTab))
end


--网络状况不好的专用弹出窗口,网络错误的弹窗只需要存在一个,并且是在最高层,超过新手引导
local m_HaveShowNetError = false
function showNetError(performCode, responseCode)
	if m_HaveShowNetError == true then
		return
	end
	local node = cc.Node:create()
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(cc.p(0.0,0.0))
	node:setPosition(cc.p(0.0,0.0))
	node:setContentSize(cc.size(0.0,0.0))
	local function nodeEventHandler(eventType)
        if eventType == "enter" then
			m_HaveShowNetError = true
		elseif eventType == "exit" then
			m_HaveShowNetError = false
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    node:registerScriptHandler(nodeEventHandler)
	local function callbackFunc(event)
		if event == 0 then
			node:removeFromParent()
		end
	end
	--node:addChild(_create(g_tr("msgBox_netError").."\ncurl_easy_perform = "..tostring(performCode).."\nCURLINFO_RESPONSE_CODE = "..tostring(responseCode), nil, nil, callbackFunc))
	node:addChild(_create(g_tr("msgBox_netError"), nil, nil, callbackFunc))
	g_sceneManager.addNodeForTopMsgBox(node)
end


--网络请求数据错误的专用弹出窗口,只需要存在一个,并且是在最高层,超过新手引导
local m_HaveShowNetDataError = false
function showNetDataError()
	if m_HaveShowNetDataError == true then
		return
	end
	local node = cc.Node:create()
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(cc.p(0.0,0.0))
	node:setPosition(cc.p(0.0,0.0))
	node:setContentSize(cc.size(0.0,0.0))
	local function nodeEventHandler(eventType)
        if eventType == "enter" then
			m_HaveShowNetDataError = true
		elseif eventType == "exit" then
			m_HaveShowNetDataError = false
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    node:registerScriptHandler(nodeEventHandler)
	local function callbackFunc(event)
		if event == 0 then
			node:removeFromParent()
		end
	end
	node:addChild(_create(g_tr("msgBox_netDataError"), nil, nil, callbackFunc))
	g_sceneManager.addNodeForTopMsgBox(node)
end


--被挤下线专用弹出窗口,只需要存在一个,并且是在最高层,超过新手引导
local m_HaveShowOffLine = false
function showOffLine()
	if m_HaveShowOffLine == true then
		return
	end
	local node = cc.Node:create()
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(cc.p(0.0,0.0))
	node:setPosition(cc.p(0.0,0.0))
	node:setContentSize(cc.size(0.0,0.0))
	local function nodeEventHandler(eventType)
        if eventType == "enter" then
			m_HaveShowOffLine = true
		elseif eventType == "exit" then
			m_HaveShowOffLine = false
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    node:registerScriptHandler(nodeEventHandler)
	local function callbackFunc(event)
		if event == 0 then
			node:removeFromParent()
			g_gameManager.reStartGame()
		end
	end
	node:addChild(_create(g_tr("msgBox_offLine"), nil, nil, callbackFunc))
	g_sceneManager.addNodeForTopMsgBox(node)
	httpNet:getInstance():DiscardAllPost()
end
function isShowOffLine()
	return m_HaveShowOffLine
end


--强制下线更新弹出窗口,只需要存在一个,并且是在最高层,超过新手引导
local m_HaveShowVersionOffLine = false
function showVersionOffLine()
	if m_HaveShowVersionOffLine == true then
		return
	end
	local node = cc.Node:create()
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(cc.p(0.0,0.0))
	node:setPosition(cc.p(0.0,0.0))
	node:setContentSize(cc.size(0.0,0.0))
	local function nodeEventHandler(eventType)
        if eventType == "enter" then
			m_HaveShowVersionOffLine = true
		elseif eventType == "exit" then
			m_HaveShowVersionOffLine = false
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    node:registerScriptHandler(nodeEventHandler)
	local function callbackFunc(event)
		if event == 0 then
			node:removeFromParent()
			g_gameManager.reStartGame()
		end
	end
	node:addChild(_create(g_tr("msgBox_versionOffLine"), nil, nil, callbackFunc))
	g_sceneManager.addNodeForTopMsgBox(node)
	httpNet:getInstance():DiscardAllPost()
end
function isShowVersionOffLine()
	return m_HaveShowVersionOffLine
end


--被封号以后强制下线弹出窗口,只需要存在一个,并且是在最高层,超过新手引导
local m_HaveShowDisableUser = false
function showDisableUser()
	if m_HaveShowDisableUser == true then
		return
	end
	local node = cc.Node:create()
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(cc.p(0.0,0.0))
	node:setPosition(cc.p(0.0,0.0))
	node:setContentSize(cc.size(0.0,0.0))
	local function nodeEventHandler(eventType)
        if eventType == "enter" then
			m_HaveShowDisableUser = true
		elseif eventType == "exit" then
			m_HaveShowDisableUser = false
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    node:registerScriptHandler(nodeEventHandler)
	local function callbackFunc(event)
		if event == 0 then
			node:removeFromParent()
			g_gameManager.reStartGame()
		end
	end
	node:addChild(_create(g_tr("msgBox_disableUser"), nil, nil, callbackFunc))
	g_sceneManager.addNodeForTopMsgBox(node)
	httpNet:getInstance():DiscardAllPost()
end
function isShowDisableUser()
	return m_HaveShowDisableUser
end

--显示一个元宝消耗提示框
--参数： count 使用元宝数量 , 必须传
--参数： text 显示文本
--参数： title 标题文本 ，不传为默认标题
--参数:  buttonText 确定按钮文字 ， 不传为默认确定
--参数:  callback 回调 ， 确定， 形参为需要使用的元宝数量
function showConsume(count, text, title, buttonText, callback)

	local widget = g_gameTools.LoadCocosUI("system_message_popup1.csb",5)

	local scale_node = widget:getChildByName("scale_node")
	
	local content_popup = scale_node:getChildByName("content_popup")
	
	content_popup:getChildByName("bg_title"):getChildByName("Text_2"):setString(title and title or g_tr("msgBox_tip"))

	content_popup:getChildByName("Text_1"):setString(text and text or "")

	scale_node:getChildByName("Text_4_0"):setString(tostring(count))
	
	local cnt , iconPath = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)

	scale_node:getChildByName("Image_3_0"):loadTexture(iconPath) --图标

	scale_node:getChildByName("Text_4_0"):setTextColor( (count > cnt and cc.c3b(255, 0, 0) or cc.c3b(255, 252, 0)) )
	
	content_popup:getChildByName("btn_1"):getChildByName("Text_1"):setString( buttonText and buttonText or g_tr("msgBox_ok") )
	
	local open_animation_completed = false
	
	local function onButtonOK(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
			    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
				widget:removeFromParent()
				if count > cnt then
					--g_airBox.show(g_tr("msgBox_notHaveMoney"), 2) --以后这里打开界面
					g_gameTools.tipGotoPayLayer()
				else
					if callback and type(callback)=="function" then
						callback(count)
					end
				end
			end
		end
	end
	content_popup:getChildByName("btn_1"):addTouchEventListener(onButtonOK)

	local function onButtonClose(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
			    g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
				widget:removeFromParent()
			end
		end
	end
	content_popup:getChildByName("Button_4"):addTouchEventListener(onButtonClose)
	
	local origin_scale = scale_node:getScale()
	scale_node:setScale(origin_scale * 0.5)
	scale_node:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.35, origin_scale)), cc.CallFunc:create(function() open_animation_completed = true end)))
	
	local function widgetEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    widget:registerScriptHandler(widgetEventHandler)
	
	g_sceneManager.addNodeForMsgBox(widget)
end


--显示一个元宝秒时间提示框
--参数： finishTime 完成时间
--参数： text 显示文本
--参数： title 标题文本 ，不传为默认标题
--参数:  buttonText 确定按钮文字 ， 不传为默认确定
--参数:  callback 回调 ， 确定， 形参为需要使用的元宝数量
function showSpeedUp(finishTime, text, title, buttonText, callback)
	local widget = g_gameTools.LoadCocosUI("building_complete.csb",5)
    local scale_node = widget:getChildByName("scale_node")
	local content_popup =  scale_node:getChildByName("content_popup")
	
	content_popup:getChildByName("Text_1"):setString(text and text or "")
	
	scale_node:getChildByName("Text_12"):setString(title and title or g_tr("msgBox_tip"))
	
	content_popup:getChildByName("btn_1"):getChildByName("Text"):setString(buttonText and buttonText or g_tr("msgBox_upSpeed"))
	
	local cnt , iconPath = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
	
	content_popup:getChildByName("btn_1"):getChildByName("Image_1"):loadTexture(iconPath)
	
	local countLabel =  content_popup:getChildByName("btn_1"):getChildByName("Text_0")
    local timeLabel = content_popup:getChildByName("Text_2")
	
    countLabel:setString("0")
    timeLabel:setString("00:00:00")
    
    local currentTime = g_clock.getCurServerTime()
    local count = 0
	
    if finishTime - currentTime > 0 then
        local updateTimeStr = function()
            currentTime = g_clock.getCurServerTime()
            local secondsLeft = finishTime - currentTime
            count = g_gameTools.getGemCostBySeconds(secondsLeft)
            countLabel:setString(string.formatnumberthousands(count))
			countLabel:setTextColor( (count > cnt and cc.c3b(255, 0, 0) or cc.c3b(255, 252, 0)) )
            if secondsLeft < 0 then
                secondsLeft = 0
				widget:removeFromParent()
			else
				timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft))
            end
        end
        timeLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))))
        updateTimeStr()
    end
	
	local open_animation_completed = false
	
	local function onButtonClose(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
			    g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
				widget:removeFromParent()
			end
		end
    end
    content_popup:getChildByName("Button_xhao"):addTouchEventListener(onButtonClose)
	
	
	local function onButtonOK(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
			    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
				widget:removeFromParent()
				if count > cnt then
					--g_airBox.show(g_tr("msgBox_notHaveMoney"), 2) --以后这里打开界面
					g_gameTools.tipGotoPayLayer()
				else
					if callback and type(callback)=="function" then
						callback(count)
					end
				end
			end
		end
	end
	content_popup:getChildByName("btn_1"):getChildByName("Button_1"):addTouchEventListener(onButtonOK)
   
	local origin_scale = scale_node:getScale()
	scale_node:setScale(origin_scale * 0.5)
	scale_node:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.35, origin_scale)), cc.CallFunc:create(function() open_animation_completed = true end)))
	
	local function widgetEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    widget:registerScriptHandler(widgetEventHandler)
	
	g_sceneManager.addNodeForMsgBox(widget)
end





return msgBox