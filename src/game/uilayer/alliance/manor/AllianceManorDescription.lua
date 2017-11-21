local AllianceManorDescription = class("AllianceManorDescription",function()
    return cc.Layer:create()
end)

function AllianceManorDescription:ctor(serverData)
    local uiLayer =  g_gameTools.LoadCocosUI("Towe_main.csb",5)
    self:addChild(uiLayer)
		
    --关闭本页
    local btnClose = uiLayer:getChildByName("mask")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    local listView = uiLayer:getChildByName("scale_node"):getChildByName("ListView_1")
    
    local mapElementInfo = g_data.map_element[serverData.map_element_id]
    --assert(mapElementInfo)
    --uiLayer:getChildByName("scale_node"):getChildByName("Text_1"):setString(g_tr(mapElementInfo.description))
    uiLayer:getChildByName("scale_node"):getChildByName("Text_c2"):setString(g_tr(mapElementInfo.name))
    
    local tmpUIText = uiLayer:getChildByName("scale_node"):getChildByName("Text_1")
    tmpUIText:setVisible(false)
    
    local contentLabel = cc.Label:createWithTTF("",tmpUIText:getFontName(),tmpUIText:getFontSize(),
      cc.size(listView:getContentSize().width -5,0))
    contentLabel:setAnchorPoint(cc.p(0,0))
    contentLabel:setString(g_tr(mapElementInfo.description))
    local container = ccui.Widget:create()
    container:addChild(contentLabel)
    container:setContentSize(contentLabel:getContentSize())
    listView:pushBackCustomItem(container)
    
    
    local btnView = uiLayer:getChildByName("scale_node"):getChildByName("Button_1")
    btnView:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent()
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            require("game.uilayer.alliance.manor.AllianceInfoLayer").show(serverData.guild_id)
        end
    end)
    
end

return AllianceManorDescription