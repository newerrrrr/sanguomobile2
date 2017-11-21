local BaseLayer = class("BaseLayer", function() 
    return cc.Layer:create()
end)

function BaseLayer:ctor()
    if self.instance == true then
      return
    end
    self:setNodeEventEnabled(true)
end 

function BaseLayer:setNodeEventEnabled(enabled, handler)
    if enabled then
        if not handler then
            handler = function(event)
                if event == "enter" then
                    self.instance = true
                    self:onEnter()
                elseif event == "exit" then
                    self.instance = false
                    self:onExit()
                elseif event == "enterTransitionFinish" then
                    self:onEnterTransitionFinish()
                elseif event == "exitTransitionStart" then
                    self:onExitTransitionStart()
                elseif event == "cleanup" then
                    self:onCleanup()
                end
            end
        end
        self:registerScriptHandler(handler)
    else
        self:unregisterScriptHandler()
    end
end

function BaseLayer:onEnter()

end 

function BaseLayer:onExit()

end 

function BaseLayer:onEnterTransitionFinish()

end

function BaseLayer:onExitTransitionStart()

end

function BaseLayer:onCleanup()

end

function BaseLayer:loadUI(url)
  local layout = g_gameTools.LoadCocosUI(url, 5)
  self:addChild(layout)

  return layout
end

function BaseLayer:regBtnCallback(btn, callback)
  if nil == btn then 
    print("=== nil button")
    return 
  end 

  local btnObj
  local function onClick(sender,eventType) 
    if eventType == ccui.TouchEventType.began then 
      btnObj = sender 
    elseif eventType == ccui.TouchEventType.moved then 
    elseif eventType == ccui.TouchEventType.ended then 
      if btnObj == sender then
        callback(sender) 
      end 
    end 
  end 
  btn:addTouchEventListener(onClick)   
end 

function BaseLayer:close(bSoundEffect)
  self:removeFromParent()
  if bSoundEffect then 
    g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
  end 
end

function BaseLayer:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function BaseLayer:unschedule(action)
  self:stopAction(action)
end

function BaseLayer:setDelegate(delegate)
  self._delegate = delegate
end 

function BaseLayer:getDelegate()
  return self._delegate
end 

function BaseLayer:performWithDelay(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  self:runAction(sequence)
  return sequence
end

return BaseLayer