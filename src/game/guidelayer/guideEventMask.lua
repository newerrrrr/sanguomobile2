local guideEventMask = {}
setmetatable(guideEventMask,{__index = _G})
setfenv(1,guideEventMask)

--引导的事件基础辅助

local c_mad_failed_Count = 7

local c_move_inch = 7.0 / 160.0

local function _convertDistanceFromPointToInch( dis )
	local glview = cc.Director:getInstance():getOpenGLView()
    local dpi = cc.Device:getDPI()
	local d = cc.p( dis.x * glview:getScaleX() / dpi , dis.y * glview:getScaleY() / dpi )
    return math.floor( math.sqrt( d.x * d.x + d.y * d.y ) )
end



--创建
function guideEventMask_create()
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	ret:setPosition(g_display.center)
	ret:setContentSize(g_display.size)
	
	local attribute = {
		passRect = nil,			--默认为全屏不渗透
		clickCallback = nil,	--默认没有触发函数
		madCallback = nil,		--默认没有发狂函数
		failedCallback = nil,	--默认没有失败函数
	}
	
	--设置通过条件为矩形范围内通过
	ret.lua_setPassRect = function ( self , rect )
		attribute.passRect = cc.rect(rect.x, rect.y, rect.width, rect.height)
	end
	
	--设置通过条件为全屏通过
	ret.lua_setPassAlways = function ( self )
		attribute.passRect = cc.rect(0.0, 0.0, g_display.size.width, g_display.size.height)
	end
	
	--设置通过条件为全屏不通过
	ret.lua_setPassNever = function ( self )
		attribute.passRect = nil
	end
	
	--设置当条件通过之后触发的回调函数,绑定回调函数之后事件将不会继续向下分发
	ret.lua_setClickCallback = function ( self , func )
		attribute.clickCallback = func
	end
	
	--设置发狂回调函数,此函数将在连续点击了c_mad_failed_Count次无效位置后触发
	ret.lua_setMadCallback = function ( self , func )
		attribute.madCallback = func
	end
	
	--设置点击失败后的触发函数
	ret.lua_setFailedCallback = function ( self , func )
		attribute.failedCallback = func
	end
	
	local failCount = 0
	local lastTouchData = nil --{ id , position }
	local function onTouchBegan(touch, event)
		if lastTouchData == nil then
			if attribute.clickCallback then
				lastTouchData = { id = touch:getId() , position = touch:getLocation() }
				return true
			end
			if attribute.passRect == nil then
				lastTouchData = { id = touch:getId() , position = touch:getLocation() }
				return true
			end
			if ( not cc.rectContainsPoint( attribute.passRect , touch:getLocation() ) ) then
				lastTouchData = { id = touch:getId() , position = touch:getLocation() }
				return true
			else
				failCount = 0
				return false
			end
		else
			return true
		end
	end
	local function onTouchMoved(touch, event)
		if lastTouchData and lastTouchData.id == touch:getId() then
			if _convertDistanceFromPointToInch(cc.pSub(touch:getLocation(), lastTouchData.position)) > c_move_inch then
				lastTouchData = nil
			end
		end
	end
	local function onTouchEnded(touch, event)
		if lastTouchData and lastTouchData.id == touch:getId() then
			local isSucceed = false
			local origin_position = lastTouchData.position
			lastTouchData = nil
			local new_position = touch:getLocation()
			if _convertDistanceFromPointToInch(cc.pSub(new_position, origin_position)) <= c_move_inch then
				if attribute.clickCallback then
					if attribute.passRect then
						if cc.rectContainsPoint(attribute.passRect , new_position) then
							isSucceed = true
							attribute.clickCallback()
						end
					end
				end
			end
			if isSucceed == false then
				failCount = failCount + 1
				if attribute.failedCallback then
					attribute.failedCallback()
				end
				if failCount >= c_mad_failed_Count then
					failCount = 0
					if attribute.madCallback then
						attribute.madCallback()
					end
				end
			else
				failCount = 0
			end
		end
	end
	local function onTouchCancelled(touch, event)
		if lastTouchData and lastTouchData.id == touch:getId() then
			lastTouchData = nil
		end
	end
	local touchListener = cc.EventListenerTouchOneByOne:create()
	touchListener:setSwallowTouches(true)
	touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
	touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
	touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
	touchListener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED )
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, ret)
	return ret
end




return guideEventMask