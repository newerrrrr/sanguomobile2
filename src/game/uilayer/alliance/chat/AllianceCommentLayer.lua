local AllianceCommentLayer = class("AllianceCommentLayer",function()
    return cc.Layer:create()
end)
  
function AllianceCommentLayer:ctor()
    local uiLayer = g_gameTools.LoadCocosUI("MessageBoard_panel.csb",5)
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
    
    self:registerScriptHandler(function(eventType)
        if eventType == "enter" then
            g_allianceCommentData.SetView(self)
        elseif eventType == "exit" then
            g_allianceCommentData.SetView(nil)

        end 
    end )

    self._baseNode:getChildByName("Text_1"):setString(g_tr("allianceTitle"))
    self._baseNode:getChildByName("Text_c2"):setString(g_tr("allianceCommentTitle"))
    
    self._dragging = nil
    self._currentPos = nil
    self._srcItem = nil
    
    local canMove = false
    local pressAction = nil
    
    local touchHandler = function(sender,eventType)
          if eventType == ccui.TouchEventType.began then
              self._dragging = sender:clone()
              self._dragging:setTouchEnabled(false)
              self:addChild(self._dragging)
              self._dragging:setVisible(false)
              self._currentPos = cc.p(0,0)
              self._srcItem = sender
              
              if g_AllianceMode.isAllianceLeader() then
                  pressAction = self._dragging:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                      canMove = true
                      pressAction = nil
                  end)))
              end
              
          elseif eventType == ccui.TouchEventType.moved then
          
              if canMove and self._dragging then
                  self._dragging:setVisible(true)
                  self._srcItem:setVisible(false)
                  local movePos = sender:getTouchMovePosition()
                  self._dragging:setPosition(cc.p(movePos.x - sender:getContentSize().width*0.5,movePos.y - sender:getContentSize().height*0.5 ))
                  self._currentPos = movePos
              end
          elseif eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.ended then
                
              if self._dragging then
                  
                  if pressAction then
                     self._dragging:stopAction(pressAction)
                     pressAction = nil
                  end
                  
                  if canMove then
                      local posDraggingItem = function(pos)
                            if self._srcItem then
                                self._srcItem:setPosition(self._srcItem.orginPos)
                            end
                                    
                           self._dragging:runAction(cc.Sequence:create(cc.MoveTo:create(0.25,pos),cc.RemoveSelf:create(),cc.CallFunc:create(function()
                                if self._srcItem then
                                    self._srcItem:setVisible(true)
                                end
                           end)))
                           self._dragging = nil
                      end
    
                      local removed = false
                      if eventType == ccui.TouchEventType.canceled then
                            for i = 1, 8 do
                            	local targetItem = self._baseNode:getChildByName("Panel_"..i)
                            	local rect = targetItem:getBoundingBox()
                                --print(rect.x,rect.y,rect.width,rect.height)
                                if cc.rectContainsPoint(rect,self._currentPos) then
                                    print("draged in")
                                    print("dst :",i)
                                    
                                    --if g_allianceCommentData.isVaildData(targetItem.serverData) and g_allianceCommentData.isVaildData(self._srcItem.serverData) then --两个都要数据的才能交换
                                    
                                        local startPosition = cc.p(self._srcItem:getPosition())
                                       
                                        local pos = cc.p(targetItem:getPosition())
                                        posDraggingItem(pos)
                                        
                                        targetItem:runAction(cc.Sequence:create(cc.MoveTo:create(0.25,startPosition),cc.CallFunc:create(function()
                                            targetItem:setPosition(targetItem.orginPos)
                                            g_allianceCommentData.swapComment(targetItem.serverData.order_id,self._srcItem.serverData.order_id,targetItem.serverData.update_time,self._srcItem.serverData.update_time)
                                        end)))
                        
                                        removed = true
                                    --end
                                    
                                    break
                                end
                            end
                      end
                      
                      if not removed then
                            local pos = cc.p(self._srcItem:getPosition())
                            posDraggingItem(pos)
                      end
                  end
              end
              
              if not canMove then
                 print("click")
                 
                 if g_allianceCommentData.isVaildData(sender.serverData) then
                    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.chat.AllianceCommentContentLayer"):create(sender.serverData))
                 elseif g_AllianceMode.isAllianceLeader() then
                    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.chat.AllianceCommentInputLayer"):create(sender.serverData))
                 end
                 
              end
              
              canMove = false
          end
    end
    
    for i = 1, 8 do
        local dragBtn = self._baseNode:getChildByName("Panel_"..i)
        dragBtn:setTouchEnabled(true)
        dragBtn:addTouchEventListener(touchHandler)
        dragBtn:getChildByName("Panel_1"):getChildByName("Text_2"):setString(g_tr("allianceCommentWriteTip"))
        dragBtn.orginPos = cc.p(dragBtn:getPosition())
    end
    
    self:updateView()
end

local function updateItem(item,data)
    item.serverData = data
    if g_allianceCommentData.isVaildData(data) then
        item:getChildByName("Panel_1"):setVisible(false)
        item:getChildByName("Panel_br"):setVisible(true)
        
        local isNew = (g_clock.getCurServerTime() - data.update_time) < 360 * 24
        item:getChildByName("Panel_br"):getChildByName("Image_xin"):setVisible(isNew)
        item:getChildByName("Panel_br"):getChildByName("Text_1_0"):setString(tostring(data.nick))
        item:getChildByName("Panel_br"):getChildByName("Text_1"):setString(tostring(data.title))
        
        local contentStr = tostring(data.content)
        local contentpreviewStr = ""
        --拆分每个字符
        do
           local i = 0
           for c in string.gmatch(contentStr, ".[\128-\191]*") do       
             --   m_table[i] = c                                         
              i=i+1
              contentpreviewStr = contentpreviewStr..c
              if i >=45 then
                 contentpreviewStr = contentpreviewStr.."..."
                 break
              end
           end
        end
        item:getChildByName("Panel_br"):getChildByName("Text_3"):setString(contentpreviewStr)
    else
        if g_AllianceMode.isAllianceLeader() then
            item:setVisible(true)
            item:getChildByName("Panel_br"):setVisible(false)
            item:getChildByName("Panel_1"):setVisible(true)
        else
            item:setVisible(false)
        end
        
    end
end

function AllianceCommentLayer:updateView()
    local serverData = g_allianceCommentData.GetData()
    --[{"id":1,"guild_id":88,"order_id":1,"content":"dddd","update_time":1467097369},{"id":4,"guild_id":88,"order_id":1,"content":"bbbbb","update_time":1467097163},{"id":2,"guild_id":88,"order_id":5,"content":"5555","update_time":1467097392},{"id":3,"guild_id":88,"order_id":6,"content":"hello word 1","update_time":1467096984}]
    table.sort(serverData,function(a,b)
        return a.order_id < b.order_id
    end)
    
    local vaildDatas = {}
    for key, var in ipairs(serverData) do
    	if g_allianceCommentData.isVaildData(var) then
    	   table.insert(vaildDatas,var)
    	end
    end
    
    for i = 1, 8 do
        local dragBtn = self._baseNode:getChildByName("Panel_"..i)
        local data = vaildDatas[i]
        if g_AllianceMode.isAllianceLeader() then
            data = g_allianceCommentData.getCommentDataByOrderId(i)
        end
        updateItem(dragBtn,data)
    end
end

return AllianceCommentLayer