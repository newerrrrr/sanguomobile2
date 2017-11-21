local CollectResourceLayer = class("CollectResourceLayer",function()
    return cc.Layer:create()
end)

local maxQuene = 5
function CollectResourceLayer:ctor()
	local uiLayer =  g_gameTools.LoadCocosUI("collect_resource.csb",5)
    self:addChild(uiLayer)
    g_resourcesInterface.installResources(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent(true)
          end
    end)
    
    self._timeLabel = self._baseNode:getChildByName("time")
    
    --for test
    self._allItemList = 
    {
      10100,
      10200,
      10300,
      10400,
      10500,
      10600,
    }
    
    self._itemQuene = {}
    
    local picBuilding = self._baseNode:getChildByName("pic_building")
    self._dragging = nil
    self._currentPos = nil
    local touchHandler = function(sender,eventType)
          if eventType == ccui.TouchEventType.began then
              self._dragging = sender:getChildByName("Image"):clone()
              self._dragging:setTouchEnabled(false)
              self:addChild(self._dragging)
              self._dragging:setVisible(false)
              self._currentPos = cc.p(0,0)
          elseif eventType == ccui.TouchEventType.moved then
              if self._dragging then
                  self._dragging:setVisible(true)
                  self._dragging:setPosition(sender:getTouchMovePosition())
                  self._currentPos = sender:getTouchMovePosition()
              end
          elseif eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.ended then
              if self._dragging then
                  self._dragging:removeFromParent()
                  self._dragging = nil
                  
                  if eventType == ccui.TouchEventType.canceled then
                        local rect = picBuilding:getBoundingBox()
                        --print(rect.x,rect.y,rect.width,rect.height)
                        if cc.rectContainsPoint(rect,self._currentPos) then
                            print("draged in")
                            if #self._itemQuene >= maxQuene then
                               table.remove(self._itemQuene,1)
                            end
                            
                            --TODO:push back quene
                            table.insert(self._itemQuene,sender.idx)
                            self:updateQuene()
                        end
                  end
              end
          end
    end
    
    for i = 1, 8 do
        local dragBtn = self._baseNode:getChildByName("btn_"..i)
        dragBtn:setVisible(false)
        
        if self._allItemList[i] ~= nil then
            dragBtn:setVisible(true)
            dragBtn.idx = self._allItemList[i]
      	    dragBtn:addTouchEventListener(touchHandler)
      	end
    end
    
    local removeHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           --TODO:remove item in the quene
           table.remove(self._itemQuene,sender.idx)
           self:updateQuene()
        end
    end
    
    for i = 1, maxQuene do
      	local queneBtn = self._baseNode:getChildByName("ico_"..(i+1))
      	queneBtn.idx = i 
        queneBtn:addTouchEventListener(removeHandler)
    end
    
    self:updateQuene()
end

function CollectResourceLayer:updateQuene()
    for i = 1, maxQuene do
        local queneBtn = self._baseNode:getChildByName("ico_"..(i+1))
        local icon = self._baseNode:getChildByName("pic_resource_"..(i+1))
        if self._itemQuene[i] then
            queneBtn:setVisible(true)
            icon:setVisible(true)
            icon:loadTexture(g_resManager.getResPath(g_data.item[self._itemQuene[i]].res_icon))
        else
            queneBtn:setVisible(false)
            icon:setVisible(false)
        end
    end
end

return CollectResourceLayer