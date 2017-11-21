local AllianceCommentInputLayer = class("AllianceCommentInputLayer",function()
    return cc.Layer:create()
end)

function AllianceCommentInputLayer:ctor(serverData)
    local uiLayer = g_gameTools.LoadCocosUI("MessageBoard_alliance_write.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    --关闭本页
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent()
        end
    end)
    
    local sendBtn = baseNode:getChildByName("Button_2")
    sendBtn:getChildByName("Text_38"):setString(g_tr("allianceCommentSend"))
    sendBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local titleStr = self._titleEditBox:getText()
            local contentStr = self._contentEditBox:getText()
            titleStr = string.trim(titleStr)
            contentStr = string.trim(contentStr)
            if titleStr == "" then
                return g_airBox.show(g_tr("allianceCommentTitleStrEmpty"))
            end
            
            local titleMaxLength = 15
            if string.utf8len(titleStr) > titleMaxLength then
                return g_airBox.show(g_tr("allianceCommentTitleStrTooLong"))
            end
            
            if contentStr == "" then
                return g_airBox.show(g_tr("allianceCommentContentStrEmpty"))
            end
            
            local contentMaxLength = 800
            if string.utf8len(contentStr) > contentMaxLength then
                return g_airBox.show(g_tr("allianceCommentContentStrTooLong"))
            end
            
            if self._lastTitleStr == titleStr and self._lastContentStr == contentStr then 
                self:removeFromParent()
                return
            end
            
            local orderId = g_allianceCommentData.getAnIdleOrderId()
            if serverData then
                orderId = serverData.order_id
            end
            
            assert(orderId)
            
            if g_allianceCommentData.changeComment(orderId,titleStr,contentStr,serverData.update_time) then
                local contentView = self:getContentView()
                if contentView then
                    local data = g_allianceCommentData.getCommentDataByOrderId(orderId)
                    contentView:setData(data)
                    contentView:updateView()
                end
                self:removeFromParent()
            end
        end
    end)
    
    baseNode:getChildByName("text_sjr"):setString(g_tr("allianceCommentPreTitel"))
    baseNode:getChildByName("text_nr"):setString(g_tr("allianceCommentPreContent"))
    baseNode:getChildByName("text"):setString(g_tr("allianceCommentInputTitle"))
    
    
    local titleStr = ""
    local contentStr = ""
    
    if serverData then
        titleStr = tostring(serverData.title)
        contentStr = tostring(serverData.content)
    end
    --print("titleStr:",titleStr,"contentStr:",contentStr)
    
    self._lastTitleStr = titleStr
    self._lastContentStr = contentStr
    
    self._titleEditBox = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("TextField_2_0"))
    self._contentEditBox = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("TextField_2"))
    self._titleEditBox:setString(titleStr)
    self._contentEditBox:setString(contentStr)
    self._contentEditBox:setMaxLength(850)
    
end

------
--  Getter & Setter for
--      AllianceCommentInputLayer._ContentView
-----
function AllianceCommentInputLayer:setContentView(ContentView)
    self._ContentView = ContentView
end

function AllianceCommentInputLayer:getContentView()
    return self._ContentView
end

return AllianceCommentInputLayer