local msgLevelTouchEvent = {}
setmetatable(msgLevelTouchEvent,{__index = _G})
setfenv(1,msgLevelTouchEvent)

local m_EventCallbacks = {}

function create()
	local ret = cc.Node:create()
	
	local function _touchBegan(touch, event)
		m_EventCallbacks.onTouchBegan(touch, event)
		return true
	end
	local function _touchMoved(touch, event)
		m_EventCallbacks.onTouchMoved(touch, event)
	end
	local function _touchEnded(touch, event)
		m_EventCallbacks.onTouchEnded(touch, event)
	end
	local function _touchCancelled(touch, event)
		m_EventCallbacks.onTouchCancelled(touch, event)
	end
	local touchListener = cc.EventListenerTouchOneByOne:create()
	touchListener:setSwallowTouches(false)
	touchListener:registerScriptHandler(_touchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	touchListener:registerScriptHandler(_touchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	touchListener:registerScriptHandler(_touchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	touchListener:registerScriptHandler(_touchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, ret)
	
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if targetPlatform == cc.PLATFORM_OS_ANDROID then
		local layer = return_key()
		ret:addChild(layer)
	end
	
	return ret
end

--返回键监听
function return_key()
    local layer = cc.Layer:create()
    print("返回键监听")
    --回调方法
    local function onrelease(code, event)
        if code == cc.KeyCode.KEY_BACK then
        	local download_channel = g_Account.getDownloadChannel()
					if download_channel == g_sdkManager.SdkDownLoadChannel.anysdk then
							local pluginChannel = require("anysdk.PluginChannel"):getInstance()
							if pluginChannel then
							 pluginChannel:exit()
							end
					end
        end
    end
    --监听手机返回键
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layer)
    return layer
end


--事件比UI层高，在msg层属于最低


function m_EventCallbacks.onTouchBegan(touch, event)
	require("game.uilayer.mainSurface.mainSurfaceChat").onUpdateTaskGuideHand()
end


function m_EventCallbacks.onTouchMoved(touch, event)
	
end


function m_EventCallbacks.onTouchEnded(touch, event)
	
end


function m_EventCallbacks.onTouchCancelled(touch, event)
	
end




return msgLevelTouchEvent