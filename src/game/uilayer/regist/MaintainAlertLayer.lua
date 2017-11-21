local MaintainAlertLayer = class("MaintainAlertLayer",function()
    return cc.Layer:create()
end)

function MaintainAlertLayer:ctor(str)
    local uiLayer =  g_gameTools.LoadCocosUI("login_Maintain_popup.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    local closeBtn = self._baseNode:getChildByName("content_popup"):getChildByName("btn_1")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    self._baseNode:getChildByName("content_popup"):getChildByName("bg_title"):getChildByName("Text_2")
    :setString(g_tr("serverMaintainTitle"))
    
    self._baseNode:getChildByName("content_popup"):getChildByName("btn_1"):getChildByName("Text_1")
    :setString(g_tr("confirm"))
    
    self._baseNode:getChildByName("content_popup"):getChildByName("Text_1")
    :setString(str)
    
end

return MaintainAlertLayer