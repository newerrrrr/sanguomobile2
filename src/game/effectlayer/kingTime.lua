local kingTime = {}
setmetatable(kingTime,{__index = _G})
setfenv(1,kingTime)

local m_isShow = false

function show()
	if m_isShow then
		return
	end
	
	local node = cc.Node:create()
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(cc.p(0.0,0.0))
	node:setPosition(g_display.center)
	node:setContentSize(cc.size(1.0,1.0))
	local function nodeEventHandler(eventType)
        if eventType == "enter" then
			m_isShow = true
		elseif eventType == "exit" then
			m_isShow = false
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    node:registerScriptHandler(nodeEventHandler)
	g_sceneManager.addNodeForSceneEffect(node)
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.start == eventType then
		elseif ccs.MovementEventType.complete == eventType then
			local p = armature:getParent()
			if p then
				p:removeFromParent()
			end
		elseif ccs.MovementEventType.loopComplete == eventType then
			local p = armature:getParent()
			if p then
				p:removeFromParent()
			end
		end
	end
	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_DaoJiShi/Effect_DaoJiShi.ExportJson", "Effect_DaoJiShi", onMovementEventCallFunc)
	node:addChild(armature)
	animation:play("Animation1")
	
	cc.Director:getInstance():setNextDeltaTimeZero(true)
end



return kingTime