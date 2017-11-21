
--道具选择框
local SmithyBatchCompose = class("SmithyBatchCompose",require("game.uilayer.base.BaseLayer"))



function SmithyBatchCompose:ctor(itemId, maxCount, callback)
  SmithyBatchCompose.super.ctor(self)

  print("SmithyBatchCompose:", itemId, maxCount)
  self.itemId = itemId 
  self.maxCount = maxCount 
  self.callback = callback 
end 

function SmithyBatchCompose:onEnter()
  local root = cc.CSLoader:createNode("Smithrecast_BatchCompose.csb")
  if root then 
    self:init(root)
    self:addChild(root)
  end 
end 

function SmithyBatchCompose:onExit()

end 

function SmithyBatchCompose:init(rootNode)
  local mask = rootNode:getChildByName("mask")
  local scaleNode = rootNode:getChildByName("scale_node")
  local btn = scaleNode:getChildByName("Button_1")
  local pic = scaleNode:getChildByName("Image_k")
  local textField = scaleNode:getChildByName("TextField_1") 
  local btnDec = scaleNode:getChildByName("Image_an1") 
  local btnInc = scaleNode:getChildByName("Image_an2") 

  self.slider = scaleNode:getChildByName("Slider_1") 
  scaleNode:getChildByName("Text_title"):setString(g_tr("batchCompose"))
  scaleNode:getChildByName("Text_1"):setString(g_tr("compose"))
  scaleNode:getChildByName("Text_num"):setString(g_tr("composeNum"))
  scaleNode:getChildByName("Text_Button"):setString(g_tr("compose"))
  scaleNode:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))

  self:regBtnCallback(mask, handler(self, self.close)) 
  self:regBtnCallback(btn, handler(self, self.onBatchCompose)) 
  self:regBtnCallback(btnDec, handler(self, self.onDecrease)) 
  self:regBtnCallback(btnInc, handler(self, self.onIncrease)) 

  local item = g_data.item_combine[self.itemId]
  if item then 
    local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, self.itemId, 1)
    if icon then 
      local size = pic:getContentSize()
      icon:setCountEnabled(false)
      icon:setPosition(cc.p(size.width/2, size.height/2))
      pic:addChild(icon)
    end 
    scaleNode:getChildByName("Text_name"):setString(g_tr(g_data.item[self.itemId].item_name))
  end 

  --输入框
  local function textFieldEvent(eventType)
      if eventType == "customEnd" then
          local editnum = tonumber( self.lbInputNum:getString() ) or 1
          if editnum >= self.maxCount then
            editnum = self.maxCount
          end
          if editnum < 1 then
            editnum = 1
          end
          self:updateByCount(editnum)
      end
  end
  self.lbInputNum = g_gameTools.convertTextFieldToEditBox(textField)
  self.lbInputNum:setPlaceHolder("")
  -- self.lbInputNum:setMaxLength(4)
  self.lbInputNum:registerScriptEditBoxHandler(textFieldEvent)  

  --滑动条
  local function sliderEvent(sender, eventType)
    if eventType == ccui.SliderEventType.percentChanged then
      local count = math.floor(self.maxCount*sender:getPercent()/100)
      count = math.max(1, count) 
      print("sliderEvent, count",count)
      self:updateByCount(count)
    end
  end 
  self.slider:addEventListener(sliderEvent)

  self:updateByCount(1)
end 


function SmithyBatchCompose:updateByCount(count)
  if self.lbInputNum then 
    self.lbInputNum:setString(""..count)
  end 

  if self.slider then 
    local percent = 100*count/self.maxCount
    self.slider:setPercent(percent)
  end 
end 

function SmithyBatchCompose:onDecrease()
  local count = tonumber(self.lbInputNum:getString()) or 1
  count = count - 1 
  if count < 1 then 
    count = 1 
  end 
  self:updateByCount(count)
end 

function SmithyBatchCompose:onIncrease()
  local count = tonumber(self.lbInputNum:getString()) or 1
  count = count + 1 
  if count > self.maxCount then 
    count = self.maxCount
  end 
  self:updateByCount(count)
end 

function SmithyBatchCompose:onBatchCompose() 
  print("onBatchCompose") 
  local count = tonumber(self.lbInputNum:getString()) 
  if self.callback then 
    self.callback(count)
  end 
  self:close()
end 




return SmithyBatchCompose 
