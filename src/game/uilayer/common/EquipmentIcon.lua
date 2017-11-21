
--装备icon信息
local EquipmentIcon = class("EquipmentIcon", function() return ccui.Widget:create() end )


function EquipmentIcon:ctor()
  self.touchCallback = nil 
end 

function EquipmentIcon:initBinding(widget, equipId, count)
  self.curWidget = widget 
  self.curEquId = equipId 

  if widget then 
    self:setContentSize(widget:getContentSize())
    self:addChild(widget) 

    self.imgIcon = widget:getChildByName("Panel_1")
    self.imgHighlight = widget:getChildByName("Image_1_1")

    self.lbWear = widget:getChildByName("Text_wear")
    self.lbName = widget:getChildByName("Text")
    self.imgAdvance = widget:getChildByName("Image_10")
    self.imgTupo = widget:getChildByName("Image_11")
    self.imgAdvance:setVisible(false) --默认不显示可进阶
    self.imgTupo:setVisible(false)

    self.lbWear:setString(g_tr("isWearing"))

    self.lbCount = widget:getChildByName("Text_num") 
    self.lbCount:enableOutline(cc.c4b(0, 0, 0,255),1)
    self.lbCount:setString("")
    --图标 
    local icon 
    if g_data.equipment[equipId] then 
      local path = g_resManager.getResPath(g_data.equipment[equipId].equip_icon) 
      icon = ccui.ImageView:create(path) 

      --星级(除了万能装备都显示星级)
      self:setStarVisible(g_data.equipment[equipId].equip_type > 0)
    end 
    if icon then 
      local size = self.imgIcon:getContentSize()
      --底框
      local id = 1011001 + g_data.equipment[equipId].quality_id - 1 
      local frameBg = ccui.ImageView:create(g_data.sprite[id].path) 
      if frameBg then 
        frameBg:setPosition(cc.p(size.width/2, size.height/2))
        self.imgIcon:addChild(frameBg)
      end 

      icon:setPosition(cc.p(size.width/2, size.height/2))
      self.imgIcon:addChild(icon)

      --上框
      local id2 = 1011201 + g_data.equipment[equipId].quality_id - 1 
      local frameFg = ccui.ImageView:create(g_data.sprite[id2].path) 
      if frameFg then 
        frameFg:setPosition(cc.p(size.width/2, size.height/2))
        self.imgIcon:addChild(frameFg)
      end 

      if count then 
        self.lbCount:setString(""..count) 
      end 
    end 



    --默认取消交互
    self.imgIcon:setTouchEnabled(false) 
    self:setIsSelected(false)
    self:setIsWearing(false)
    if self.imgIcon:getChildByTag(100) then --默认去掉数字字串
      self.imgIcon:removeChildByTag(100)
    end 
  end 
end 

function EquipmentIcon:create(equipId, count)
  self.widget = cc.CSLoader:createNode("equipIcon.csb") 
  local item = EquipmentIcon.new()
  item:initBinding(self.widget, equipId, count)
  
  return item 
end 

function EquipmentIcon:clone(equipId)
  assert(nil ~= equipId, "invalid equip id !!")
  local widget = self.widget:clone()
  local item = EquipmentIcon.new()
  item:initBinding(widget, equipId)

  return item 
end 

function EquipmentIcon:getIconSize()
  return self.imgIcon:getContentSize()
end 

function EquipmentIcon:setNameVisible(isVisible)
  self.lbName:setVisible(isVisible)
end 

--将文字放在图片内部靠下
function EquipmentIcon:setNameInRegion(isInRegion)
  local y = self.imgIcon:getPositionY()
  if isInRegion then 
    self.lbName:setPositionY(y + self.lbName:getContentSize().height/2 + 2)
  else 
    self.lbName:setPositionY(y - self.lbName:getContentSize().height/2 - 5)
  end 
end 

function EquipmentIcon:setStarVisible(isVisible)
  if nil == self.curWidget then return end 

  local imgStar = {}
  for i = 1, 10 do 
    imgStar[i] = self.curWidget:getChildByName(string.format("start_%d", i))
    imgStar[i]:setVisible(false)
  end 

  if isVisible then 
    local baseInfo = g_data.equipment[self.curEquId]
    if baseInfo then 
      for i =1, 5 do  
        if i <= baseInfo.max_star_level then 
          if i <= baseInfo.star_level then 
            imgStar[i]:setVisible(false)
            imgStar[i+5]:setVisible(true)
          else 
            imgStar[i]:setVisible(true)
            imgStar[i+5]:setVisible(false)          
          end 
        else 
          imgStar[i]:setVisible(false)
          imgStar[i+5]:setVisible(false)
        end 
      end 
      self.lbName:setString(g_tr(baseInfo.equip_name))
    end 
  end 
end 

function EquipmentIcon:setAdvancedImgVisible(isVisible)
  self.imgAdvance:setVisible(isVisible)
  if isVisible then  
    local SmithyData = require("game.uilayer.smithy.SmithyData")
    if SmithyData:isEquipCanTupo(self:getEquipId()) then 
      self.imgAdvance:setVisible(false)
      self.imgTupo:setVisible(true)
    else 
      self.imgAdvance:setVisible(true)
      self.imgTupo:setVisible(false)
    end 
  else 
    self.imgAdvance:setVisible(false)
    self.imgTupo:setVisible(false)
  end 
end 

function EquipmentIcon:setIdx(idx)
  self._idx = idx 
end 

function EquipmentIcon:getIdx()
  return self._idx 
end 

function EquipmentIcon:setTouchCallback(callback)
  self.touchCallback = callback 
  
  if callback then 
    self.imgIcon:setTouchEnabled(true)

    local btnObj 
    local function onClick(sender,eventType) 
      if eventType == ccui.TouchEventType.began then 
        btnObj = sender 
      elseif eventType == ccui.TouchEventType.ended then 
        if btnObj == sender then
          if self.touchCallback then 
            self.touchCallback(self:getIdx(), self.curEquId)
          end 
        end 
      end 
    end 
    self.imgIcon:addTouchEventListener(onClick) 
  end   
end 

function EquipmentIcon:getTouchCallback()
  return self.touchCallback 
end 

function EquipmentIcon:getSize()
  local size = self.widget:getContentSize()
  if self.lbName:isVisible() then 
    size.height = size.height + self.lbName:getContentSize().height 
  end 

  return size
end 

function EquipmentIcon:setIsSelected(isSelected)
  self._isSelected = isSelected
  self.imgHighlight:setVisible(isSelected)
end 

function EquipmentIcon:getIsSelected()
  return self._isSelected
end 

function EquipmentIcon:setCount(count, isCountVisible, isRateCount) 
  local function formatCount(count)
    local str = ""
    if count >= 1000000 then 
      str = string.format("%.1fM", count/1000000)
    elseif count >= 1000 then 
      str = string.format("%.1fK", count/1000)
    else 
      str = string.format("%d", count)
    end 
    return str
  end 

  if nil == self.imgIcon then return end 
  if isCountVisible == false then return end 

  count = count or 1 
  if type(count) == "number" then 
    local str = ""
    local color = cc.c3b(255, 255, 255)
    if isRateCount then 
      local item = g_EquipmentlMode.getSameEquips(self.curEquId)
      local ownCount = item and item.num or 0    
      color = (ownCount >= count) and cc.c3b(0, 200, 0) or cc.c3b(250, 0, 0)
      str = formatCount(ownCount) .. "/" .. formatCount(count) 
    elseif count > 1 then 
      str = formatCount(count) 
    end 
    self.lbCount:setString(str)
  else 
    self.lbCount:setString(""..count)
  end 
  

  -- local text = ccui.Text:create(str, "Arial", 24)
  -- text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
  -- text:setAnchorPoint(cc.p(1.0, 0.0))
  -- text:setPosition(cc.p(self.imgIcon:getContentSize().width-10, 5))
  -- text:setTextColor(color)
  -- text:setTag(100)
  -- self.imgIcon:addChild(text)  
end 


function EquipmentIcon:setCountEnabled(CountEnabled) 
  self.lbCount:setVisible(CountEnabled) 
end 


function EquipmentIcon:setCountColor(color)
  self.lbCount:setTextColor(color)
end

function EquipmentIcon:enableTip()
  g_itemTips.tip(self.imgIcon, g_Consts.DropType.Equipment, self.curEquId)
end

--当前穿戴
function EquipmentIcon:setIsWearing(isVisible)
  self.lbWear:setVisible(isVisible)
end 

function EquipmentIcon:IsWearing()
  return self.lbWear:isVisible()
end 

function EquipmentIcon:getEquipId()
  return self.curEquId
end 

return EquipmentIcon 
