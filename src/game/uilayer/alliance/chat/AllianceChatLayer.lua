local AllianceChatLayer = class("AllianceChatLayer",function()
    return cc.Layer:create()
end)

function AllianceChatLayer:ctor()
    local uiLayer = g_gameTools.LoadCocosUI("alliance_chat.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    --关闭本页
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent(true)
        end
    end)
    
    local btnSend = baseNode:getChildByName("btn_send")
    btnSend:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:sendMessageHandler()
        end
    end)
    self._btnSend = btnSend
    
    
end

function AllianceChatLayer:sendMessageHandler()
    local str = self._baseNode:getChildByName("TextField_1"):getString()
    str = string.trim(str)
    if str == "" then
        g_airBox.show("不能发送空消息")
        return
    end
    
    local chatMessageItem = cc.CSLoader:createNode("alliance_chat_item_2.csb")
    chatMessageItem:getChildByName("item"):getChildByName("Text_1")
    :setString(g_tr("我:")..str)
    
    local currentTime = g_clock.getCurServerTime(true)
    chatMessageItem:getChildByName("item"):getChildByName("Text_2")
    :setString(string.format("%02d:%02d:%02d",currentTime.hour,currentTime.min,currentTime.sec))
    --dump(currentTime)
    
    local listView = self._baseNode:getChildByName("ListView_1")
    listView:pushBackCustomItem(chatMessageItem)
    listView:setTouchEnabled(false)
    self._btnSend:setTouchEnabled(false)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.15),cc.CallFunc:create(function()
        listView:setTouchEnabled(true)
        self._btnSend:setTouchEnabled(true)
        listView:jumpToBottom()
    end))
    self:runAction(seq)
    self._baseNode:getChildByName("TextField_1"):setString("")
    
    --TODO:send to server
end

return AllianceChatLayer