local HealthGameAdviceLayer = class("HealthGameAdviceLayer",function()
	return cc.Layer:create()
end)

function HealthGameAdviceLayer:ctor()
    local listener = cc.EventListenerTouchOneByOne:create()
    local onTouchBegan = function(touch,event)
        return true
    end
    
    local onTouchEnded = function(touch,event)
       
    end
    
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
    
    self:setCascadeOpacityEnabled(true)
    local img = ccui.ImageView:create("cocos/cocostudio_res/login/health_game_advice.png")
    if img then
    	self:addChild(img)
    end
end

return HealthGameAdviceLayer