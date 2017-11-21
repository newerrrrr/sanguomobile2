local TaskAwardAlertLayer = class("TaskAwardAlertLayer",function()
    return cc.Layer:create()
end)

function TaskAwardAlertLayer:ctor(droupGroups,callBack,buttonEnabled,buttonTxt)
    local uiLayer =  g_gameTools.LoadCocosUI("task_rewards.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    uiLayer:getChildByName("mask"):addClickEventListener(function()
        self:removeFromParent()
    end)
    
    
    local closeBtn = baseNode:getChildByName("content_popup"):getChildByName("btn_off")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent()
              if callBack then
                callBack()
              end
          end
    end)
    
    if buttonEnabled == nil then
        buttonEnabled = true
    end
    closeBtn:setEnabled(buttonEnabled)
    
    closeBtn:getChildByName("Text"):setString(buttonTxt or g_tr("confirm"))
    baseNode:getChildByName("content_popup"):getChildByName("bg_title"):getChildByName("Text"):setString(g_tr("taskAwardTitle"))
    
    local listView = baseNode:getChildByName("content_popup"):getChildByName("ListView_1")
    self._listView = listView
    
    local updateItemView = function(itemView,itemGroup)
        --pic_rewards
        itemView:getChildByName("pic_rewards"):setVisible(false)
        local dropView = require("game.uilayer.common.DropItemView"):create(itemGroup[1],itemGroup[2],itemGroup[3])
        if dropView then
            dropView:enableTip()
            dropView:setCountEnabled(false)
            local size = itemView:getChildByName("bg_rewards"):getContentSize()
            local scale = size.width/dropView:getContentSize().width
            dropView:setScaleX(scale)
            dropView:setScaleY(scale)
            itemView:getChildByName("bg_rewards"):addChild(dropView)
            dropView:setPositionX(size.width/2)
            dropView:setPositionY(size.height/2)
            itemView:getChildByName("text"):setString(dropView:getName())
            itemView:getChildByName("Text_3"):setString("+"..string.formatnumberlogogram(dropView:getCount()))
            
            
        end
    end
    
    --local itemAwards = g_gameTools.getDropGroupByDropIdArray(dropIdArray)
    local itemAwards = droupGroups or {}
    if #itemAwards > 0 then
        local iconItem = cc.CSLoader:createNode("task_rewards_item.csb")
        for key, dropGroup in pairs(itemAwards) do
            local  item = iconItem:clone()
            updateItemView(item,dropGroup)
            self._listView:pushBackCustomItem(item)
        end
    end
end

return TaskAwardAlertLayer