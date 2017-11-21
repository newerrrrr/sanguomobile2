local airBox = {}
setmetatable(airBox,{__index = _G})
setfenv(1,airBox)


local m_CurrentShowList = {}

local function pushList(widget)
	local h = 66.0 --资源修改,对应这里也要修改
	for k , v in pairs(m_CurrentShowList) do
		v:runAction(cc.MoveBy:create(0.13,cc.p(0.0,h)))
	end
	m_CurrentShowList[ (#m_CurrentShowList) + 1 ] = widget
end

local function popList(widget)
	for k , v in pairs(m_CurrentShowList) do
		if v == widget then
			table.remove(m_CurrentShowList,k)
			break
		end
	end
end




--显示一个气泡提示框
--参数： text 显示文本
--参数： ctp 显示类型 ， 不传为默认类型(白色), 1为成功类型(绿色) ,2为警告(黄色) ,3为错误(红色)

function show(text,ctp)
	local widget = g_gameTools.LoadCocosUI("system_tips_alert.csb",5)
	local uiText = widget:getChildByName("scale_node"):getChildByName("Panel_6"):getChildByName("Text_7")
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
	widget:setScaleY(0.1)
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			pushList(widget)
		elseif eventType == "exit" then
			popList(widget)
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    widget:registerScriptHandler(rootLayerEventHandler)
	widget:runAction( cc.Sequence:create( cc.ScaleTo:create(0.13,1.0) , cc.DelayTime:create(2.5) , cc.ScaleTo:create(0.13,1.0,0.1,1.0) , cc.RemoveSelf:create() ) )
	g_sceneManager.addNodeForTopMsgBox(widget)
end




return airBox