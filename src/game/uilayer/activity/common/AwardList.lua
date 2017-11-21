local AwardList = class("AwardList",function()
    return cc.Layer:create()
end)

function AwardList:ctor(dropGroups)
    local uiLayer =  g_gameTools.LoadCocosUI("turntable_resources_main.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    local closeBtn = uiLayer:getChildByName("mask")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent()
          end
    end)
    
    baseNode:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
    
    
    local titleStr = g_tr("commonAwardTitle")
    baseNode:getChildByName("Text_c2"):setString(titleStr)
     
    local listView = baseNode:getChildByName("ListView_1")
    local rankAwardtemModel = cc.CSLoader:createNode("activity_integral_list1.csb")
    for key, var in pairs(dropGroups) do
        local type = var[1]
        local id = var[2]
        local count = var[3]
        local itemData = require("game.uilayer.common.DropItemView"):create(type,id,count)
        itemData:setCountEnabled(false)
        local item = rankAwardtemModel:clone()
        --item:getChildByName("Image_4"):loadTexture(itemData:getIconPath())
        item:getChildByName("Image_4"):addChild(itemData)
        local size = item:getChildByName("Image_4"):getContentSize()
        itemData:setPosition(cc.p(size.width*0.5,size.height*0.5))
        local scale = size.width/itemData:getContentSize().width
        itemData:setScale(scale)

        item:getChildByName("Text_2"):setString(itemData:getName())
        item:getChildByName("Text_5_0"):setString(string.formatnumberthousands(count))
        listView:pushBackCustomItem(item)
    end
end

return AwardList