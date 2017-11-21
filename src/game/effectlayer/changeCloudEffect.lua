local changeCloudEffect = {}
setmetatable(changeCloudEffect,{__index = _G})
setfenv(1,changeCloudEffect)

--变换地图的过场特效

local c_name_close = "ZhenChaGuoChangDongHuaKai"

local c_name_open = "ZhenChaGuoChangDongHuaGuan"


m_EnevtEnum = {
	close_start = 1,
	close_complete = 2,
	open_start = 3,
	open_complete = 4,
}


function create(callback)
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setContentSize(cc.size(0.0,0.0))
	ret:setAnchorPoint(cc.p(0.0,0.0))
	ret:setPosition(g_display.center)
	
	do--阻止触摸
		local function onTouchBegan(touch, event)
			return true
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(true)
		touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, ret)
	end
	
	
	local armature , animation = nil , nil
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
			if name == c_name_close then
				
				if callback then
					callback(m_EnevtEnum.close_complete)
				end
				
				ret:runAction(cc.Sequence:create(
					cc.DelayTime:create(0.5)
					, cc.CallFunc:create(function() animation:play(c_name_open) end)
					))
				
			elseif name == c_name_open then
			
				if callback then
					callback(m_EnevtEnum.open_complete)
				end

				ret:removeFromParent()
			end
		elseif ccs.MovementEventType.start == eventType then
			if name == c_name_close then
				if callback then
					callback(m_EnevtEnum.close_start)
				end
			elseif name == c_name_open then
				if callback then
					callback(m_EnevtEnum.open_start)
				end
			end
		end
	end
	
	--local function onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
	--end
	
	armature , animation = g_gameTools.LoadCocosAni(
		"anime/ZhenChaGuoChangDongHuaHeJi/ZhenChaGuoChangDongHuaHeJi.ExportJson"
		, "ZhenChaGuoChangDongHuaHeJi"
		, onMovementEventCallFunc
		--, onFrameEventCallFunc
		)
	ret:addChild(armature)
	
	animation:play(c_name_close)
	
	cc.Director:getInstance():setNextDeltaTimeZero(true)

	return ret
	
end



return changeCloudEffect