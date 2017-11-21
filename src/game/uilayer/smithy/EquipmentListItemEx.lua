
--万能装备列表项
local SmithyData = require("game.uilayer.smithy.SmithyData")
local EquipmentListItemEx = class("EquipmentListItemEx", function() return ccui.Widget:create() end)

local listSelectType
function EquipmentListItemEx:ctor()
  -- EquipmentListItemEx.super.ctor(self)
end 

function EquipmentListItemEx:create(selectType)
  listSelectType = selectType 
  self._uiWidget = cc.CSLoader:createNode("equipment_list_item1.csb")
  local item = EquipmentListItemEx.new()
  item:initBinding(self._uiWidget)
  return item 
end 

function EquipmentListItemEx:clone()
  local widget_new = self._uiWidget:clone()
  local item = EquipmentListItemEx.new()
  item:initBinding(widget_new)
  return item 
end 

function EquipmentListItemEx:onEnter()
end 

function EquipmentListItemEx:onExit()
end 

function EquipmentListItemEx:initBinding(uiWidget)
  -- self._uiWidget = uiWidget 

  if uiWidget then 
    local size = uiWidget:getContentSize()
    self:setContentSize(size)
    -- uiWidget:setPosition(cc.p(size.width/2, size.height/2))
    self:addChild(uiWidget) 

    local scaleNode = uiWidget:getChildByName("scale_node")
    self.imgIcon = scaleNode:getChildByName("Image_1_0") 
    self.slider = scaleNode:getChildByName("Slider_1") 
    local textfield = scaleNode:getChildByName("TextField_1") 
    self.input = g_gameTools.convertTextFieldToEditBox(textfield)
    self.imgSelect = scaleNode:getChildByName("Image_13")
    self.lbTotal = scaleNode:getChildByName("Text_sz") 


    local function sliderEvent(sender, eventType)
      if eventType == ccui.SliderEventType.percentChanged then
        if nil == self.equip then return end 

        local count = math.ceil(self.equip.num * sender:getPercent()/100)
        count = math.min(count, self.equip.num)
        self:updateNum(count)
      end 
    end 
    self.slider:addEventListener(sliderEvent)


    local function textFieldEvent(eventType)
      if eventType == "customEnd" then
        if nil == self.equip then return end 

        local editnum = tonumber( self.input:getString()) or 0 
        editnum = math.min(editnum, self.equip.num)
        editnum = math.max(0, editnum)
        self:updateNum(editnum)
      end 
    end 
    self.input:setPlaceHolder("")
    self.input:registerScriptEditBoxHandler(textFieldEvent) 
  end 
end 

function EquipmentListItemEx:updateNum(count)
  if nil == self.equip then return end 
  count = math.min(99, count)

  self.equip._selNum = count 
  self.slider:setPercent(100*count/self.equip.num) 
  self.input:setString(""..count) 
  self:setSelected(count > 0) 
  self:getDelegate():updateSelectedNum() 
end 

function EquipmentListItemEx:setSelected(isSelected)
  self._isSelected = isSelected 
  self.imgSelect:setVisible(isSelected) 

  if self.equip then 
    self.equip._isSelected = isSelected 
  end   
end 

function EquipmentListItemEx:getIsSelected()
  return self._isSelected 
end 

function EquipmentListItemEx:setData(equipMode)
  self.equip = equipMode 

  if self.equip then 
    self.imgIcon:removeAllChildren()
    local size = self.imgIcon:getContentSize()
    local icon = require("game.uilayer.common.EquipmentIcon"):create(equipMode.item_id)
    if icon then 
      icon:setPosition(cc.p(size.width/2, size.height/2))
      icon:setScale(size.width/icon:getIconSize().width)
      icon:setNameVisible(false)
      self.imgIcon:addChild(icon)
    end 

    self.lbTotal:setString("/"..equipMode.num) 

    self:updateNum(equipMode._selNum)
  end 
end 

function EquipmentListItemEx:getData()
  return self.equip 
end 

function EquipmentListItemEx:setDelegate(delegate)
  self._delegate = delegate
end 

function EquipmentListItemEx:getDelegate()
  return self._delegate
end 

return  EquipmentListItemEx 
