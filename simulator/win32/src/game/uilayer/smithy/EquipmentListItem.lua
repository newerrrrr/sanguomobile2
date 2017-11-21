
local SmithyData = require("game.uilayer.smithy.SmithyData")
local EquipmentListItem = class("EquipmentListItem", function() return ccui.Widget:create() end)

local listSelectType
function EquipmentListItem:ctor()
  -- EquipmentListItem.super.ctor(self)
end 

function EquipmentListItem:create(selectType)
  listSelectType = selectType 
  self._uiWidget = cc.CSLoader:createNode("equipment_list_item.csb")
  local item = EquipmentListItem.new()
  item:initBinding(self._uiWidget)
  return item 
end 

function EquipmentListItem:clone()
  local widget_new = self._uiWidget:clone()
  local item = EquipmentListItem.new()
  item:initBinding(widget_new)
  return item 
end 

function EquipmentListItem:onEnter()
end 

function EquipmentListItem:onExit()
end 

function EquipmentListItem:initBinding(uiWidget)
  -- self._uiWidget = uiWidget 

  if uiWidget then 
    local size = uiWidget:getContentSize()
    self:setContentSize(size)
    uiWidget:setPosition(cc.p(size.width/2, size.height/2))
    self:addChild(uiWidget) 

    local scaleNode = uiWidget:getChildByName("scale_node")
    self.imgIcon = scaleNode:getChildByName("Panel_1")
    self.lbName = scaleNode:getChildByName("Text_1") 
    self.imgStar1 = scaleNode:getChildByName("Image_xing01") 
    self.imgStar2 = scaleNode:getChildByName("Image_xing02") 
    self.imgStar3 = scaleNode:getChildByName("Image_xing03") 
    self.imgStar4 = scaleNode:getChildByName("Image_xing04") 
    self.imgStar5 = scaleNode:getChildByName("Image_xing05") 
    self.btnSelect = scaleNode:getChildByName("Image_1") 
    self.imgSelect = scaleNode:getChildByName("Image_13") 

    local function onTouchSelected() 
      local state = not self:getIsSelected()
      if state and self:getDelegate() and not self:getDelegate():canSelected() then 
        g_airBox.show(g_tr("selCountExceed"))
        return 
      end 
      
      if state and listSelectType == SmithyData.listSelectType.Single then 
        if self:getDelegate() then 
          self:getDelegate():unselectAllItems()
        end 
      end 
      self:setSelected(state) 
      if self:getDelegate() then 
        self:getDelegate():updateSelectedNum()
      end 
    end 

    self.btnSelect:setSwallowTouches(false)
    self.btnSelect:addClickEventListener(onTouchSelected)
    -- local function onTouchItem(sender, eventType)
    --   if eventType == ccui.TouchEventType.began then
    --     self.isMoving = false 
    --   elseif eventType == ccui.TouchEventType.moved then 
    --     self.isMoving = true 
    --   elseif eventType == ccui.TouchEventType.ended then
    --     if self.isMoving then return end 

    --     onTouchSelected() 
    --   elseif eventType == ccui.TouchEventType.canceled then
    --   end
    -- end
    -- self.btnSelect:addTouchEventListener(onTouchItem)
  end 
end 

function EquipmentListItem:setSelectedUI(isSelected)
  if self.btnSelect:isVisible() then 
    self.imgSelect:setVisible(isSelected) 
  end 
end 

function EquipmentListItem:setSelected(isSelected)
  self._isSelected = isSelected 

  self:setSelectedUI(isSelected)
  
  if self.equip then 
    self.equip._isSelected = isSelected 

    local flag = isSelected and 1 or -1 
    self.equip._selNum = self.equip._selNum + flag
    if self.equip._selNum > self.equip.num then 
      self.equip._selNum = self.equip.num 
    end 
    if self.equip._selNum < 0 then 
      self.equip._selNum = 0
    end 
  end 
end 

function EquipmentListItem:getIsSelected()
  return self._isSelected 
end 

function EquipmentListItem:setData(equipMode)
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

    self.lbName:setString(g_tr(g_data.equipment[equipMode.item_id].equip_name))
    local starTbl = {self.imgStar1, self.imgStar2, self.imgStar3, self.imgStar4, self.imgStar5}
    local starLevel = g_data.equipment[equipMode.item_id].star_level 
    for i=1, 5 do 
      starTbl[i]:setVisible(i <= starLevel)
    end 
  end 
end 

function EquipmentListItem:getData()
  return self.equip 
end 

function EquipmentListItem:setDelegate(delegate)
  self._delegate = delegate
end 

function EquipmentListItem:getDelegate()
  return self._delegate
end 

return  EquipmentListItem 
