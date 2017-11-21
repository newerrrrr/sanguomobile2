
--装备列表选择(支持单选/多选)

local SmithyData = require("game.uilayer.smithy.SmithyData")
local EquipmentListLayer = class("EquipmentListLayer",require("game.uilayer.base.BaseLayer"))

function EquipmentListLayer:ctor(selectType, equipArray)
  EquipmentListLayer.super.ctor(self)

  self.selectType = selectType or SmithyData.listSelectType.Mulitiple 

  self.genEqu = {} --武将装备原始数据
  self.uniEqu = {} --万能装备原始数据
  self.curTabType = nil 
  self.preSelectedArray = {} --初始勾选的项 
  self:initEquipData(equipArray)
  self:setSelectedCountMax(1)
  self.listItems = {}
end 


function EquipmentListLayer:onEnter()
  print("EquipmentListLayer:onEnter")
  local layer = g_gameTools.LoadCocosUI("equipment_list.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 

    self.halfItem = require("game.uilayer.smithy.EquipmentListItem"):create(self.selectType)
    self.halfItem:retain() 
    if #self.genEqu > 0 or #self.uniEqu == 0 then 
      self:showEquipList(self.genEqu, 1) 
    else 
      self:showEquipList(self.uniEqu, 2) 
    end 
  end 
end 


function EquipmentListLayer:onExit() 
  print("EquipmentListLayer:onExit") 
  self.halfItem:release()

  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end   
end 

function EquipmentListLayer:initBinding(scaleNode)
  self.rootNode = scaleNode 

  local selectInfo = scaleNode:getChildByName("Panel_selectInfo")
  scaleNode:getChildByName("Text_1"):setString(g_tr("equipList"))
  scaleNode:getChildByName("Text_8"):setString(g_tr("confirm"))
  
  local lbPreNum = selectInfo:getChildByName("Text_9")
  self.selectedNum = selectInfo:getChildByName("Text_4")
  self.listView = scaleNode:getChildByName("ListView_1")
  
  local btnConfirm = scaleNode:getChildByName("Button_4") 
  local btnClose = scaleNode:getChildByName("Button_6") 
  local btnGenEqup = scaleNode:getChildByName("Button_wj") 
  local btnUniversalEqup = scaleNode:getChildByName("Button_wn") 

  lbPreNum:setString(g_tr("equipSelectedNum"))
  self.selectedNum:setString("") 
  self.selectedNum:setPositionX(lbPreNum:getPositionX()+lbPreNum:getContentSize().width + 5)
  btnGenEqup:getChildByName("Text_1"):setString(g_tr("generalEquipment")) 
  btnUniversalEqup:getChildByName("Text_1"):setString(g_tr("equipmentItemName")) 
  self:regBtnCallback(btnConfirm, handler(self, self.onConfirm)) 
  self:regBtnCallback(btnClose, handler(self, self.onClose)) 
  self:regBtnCallback(btnGenEqup, handler(self, self.onGenEquipList)) 
  self:regBtnCallback(btnUniversalEqup, handler(self, self.onUniversalEquipList)) 

  --有万能装备时才显示两个按钮 
  btnGenEqup:setVisible(#self.uniEqu > 0) 
  btnUniversalEqup:setVisible(#self.uniEqu > 0) 

  self.dataLen = 0 
  self.mainIdx = 0 
  self.subIdx = 0
  self.firstLoadMax = 20 --初次最多显示20行,后续滑动列表时手动添加

  --滑动列表逐渐添加
  local function onScrollViewEvent(sender, eventType) 
    if eventType == ccui.ScrollviewEventType.scrolling then
      if self.frameLoadTimer then return end --如果仍在分帧加载中,则返回

      if self.curTabType == 2 then return end --万能装备不需要

      local pos = sender:getInnerContainerPosition() 
      if pos.y > -5 then 
        self:frameLoadList(5) 
      end 
    end 
  end 
  self.listView:addScrollViewEventListener(onScrollViewEvent) 
end 

function EquipmentListLayer:initEquipData(equipArray)
  --装备分类
  local item
  for k, v in pairs(equipArray) do 
    if v._isSelected then --先备份原始勾选的项
      table.insert(self.preSelectedArray, v)
    end 

    item = g_data.equipment[v.item_id]
    if item then  
      if item.equip_type == 0 then --万能装备
        table.insert(self.uniEqu, v)
      else 
        table.insert(self.genEqu, v)
      end 
    end 
  end 

  if #self.uniEqu > 0 then 
    table.sort(self.uniEqu, function(a, b) return a.item_id < b.item_id end)
  end 

  SmithyData:sortEquipByQualityAndId(self.genEqu)

end 

function EquipmentListLayer:onClose() 
  --手动关闭时恢复之前勾选项的状态
  if self.preSelectedArray and #self.preSelectedArray > 0 then 
    for k, v in pairs(self.preSelectedArray) do 
      v._isSelected = true 
    end 
  end 
  self:close()
end 

function EquipmentListLayer:onConfirm() 
  print("onConfirm")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  if self._userCallback then 
    local result = self:getSelectedArray()   
    self._userCallback(result)
  end 

  self:removeFromParent()
end 

--武将装备列表
function EquipmentListLayer:onGenEquipList() 
  print("onGenEquipList")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  SmithyData:resetSelectedNum(self.uniEqu)
  self:showEquipList(self.genEqu, 1) 
end 

--万能装备列表
function EquipmentListLayer:onUniversalEquipList() 
  print("onUniversalEquipList")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  SmithyData:resetSelectedNum(self.genEqu)
  self:showEquipList(self.uniEqu, 2) 
end 

--equipArray 叠加的装备
function EquipmentListLayer:showEquipList(equipArray, curTabType)
  if self.curTabType == curTabType then return end 

  self.curTabType = curTabType
  self.curData = equipArray 

  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end 
  self.funcLoadOneLine = nil 

  --高亮tab菜单
  local btnGenEqup = self.rootNode:getChildByName("Button_wj") 
  local btnUniEqup = self.rootNode:getChildByName("Button_wn") 
  if btnGenEqup:isVisible() then 
    btnGenEqup:setBright(curTabType ~= 1)
  end 
  if btnUniEqup:isVisible() then 
    btnUniEqup:setBright(curTabType ~= 2)
  end 

  --加载列表项
  self.listView:removeAllChildren()
  self.listView:setScrollBarEnabled(false)

  self.listItems = {}
  if curTabType == 2 then --万能装备
    local item = require("game.uilayer.smithy.EquipmentListItemEx"):create(self.selectType)
    local item_new 
    for k, v in pairs(self.curData) do 
      item_new = item:clone()
      item_new:setDelegate(self)
      item_new:setData(v) 
      item_new:setSelected(v._isSelected)
      self.listView:pushBackCustomItem(item_new)  
      table.insert(self.listItems, item_new) 
    end 

  else 
    self.dataLen = #self.curData 
    self.mainIdx = 1 
    self.subIdx = 1    
    
    self:frameLoadList(self.firstLoadMax)
  end 
end 

function EquipmentListLayer:frameLoadList(loadLineCount) 
  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end  

  if self.mainIdx > self.dataLen then return end 

  local lineCount = 0 

  local function insertOneLine()
    if self.mainIdx > self.dataLen then return false end 

    print("insertOneLine")

    local halfSize = self.halfItem:getContentSize() 
    local itemSize = cc.size(self.listView:getContentSize().width, halfSize.height)

    local layout = ccui.Widget:create() 
    layout:setContentSize(cc.size(itemSize.width, itemSize.height)) 
    for k =1, 2 do 
      if self.subIdx > self.curData[self.mainIdx].num then 
        self.subIdx = 1
        self.mainIdx = self.mainIdx + 1 

        if self.mainIdx > self.dataLen then break end 
      end 

      local item_new = self.halfItem:clone()
      item_new:setDelegate(self)
      item_new:setData(self.curData[self.mainIdx]) 
      item_new:setSelectedUI(self.subIdx <= self.curData[self.mainIdx]._selNum)
      item_new:setPosition(cc.p((k-1)*(itemSize.width-halfSize.width), 0)) 
      layout:addChild(item_new) 
      table.insert(self.listItems, item_new) 

      self.subIdx = self.subIdx + 1            
    end 
    self.listView:pushBackCustomItem(layout)  

    return true 
  end 

  local function loadOneLineItems() 
    if self.mainIdx <= self.dataLen and lineCount < loadLineCount then 
      if insertOneLine() then 
        lineCount = lineCount + 1  
      end 
    else 
      --load finish
      if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
      end 
      self:updateSelectedNum()
    end 
  end 

  self.frameLoadTimer = self:schedule(loadOneLineItems, 0) 
end 

--将选择的数据返回给用户
function EquipmentListLayer:setUserCallback(callback)
  self._userCallback = callback 
end 

function EquipmentListLayer:setSelectedCountMax(countMax)
  self._countMax = countMax 
end 

function EquipmentListLayer:getSelectedArray()
  local tbl = {}

  for k, v in pairs(self.genEqu) do 
    if v._selNum > 0 then 
      table.insert(tbl, v)
    end 
  end 
  for k, v in pairs(self.uniEqu) do 
    if v._selNum > 0 then 
      table.insert(tbl, v)
    end 
  end 

  return tbl  
end 

function EquipmentListLayer:getSelectedCount()
  local count = 0 

  for k, v in pairs(self.genEqu) do 
    if v._selNum > 0 then 
      count = count + v._selNum
    end 
  end 
  for k, v in pairs(self.uniEqu) do 
    if v._selNum > 0 then 
      count = count + v._selNum
    end 
  end 

  return count 
end 

function EquipmentListLayer:unselectAllItems()
  if self.listView then 
    for k, v in pairs(self.listItems) do 
      v:setSelected(false)
    end 
  end 
end 

--item项选择前预处理
function EquipmentListLayer:canSelected() 
  if self.selectType == SmithyData.listSelectType.Mulitiple then   
    return self:getSelectedCount() < self._countMax 
  end 

  return true 
end 

function EquipmentListLayer:updateSelectedNum()
  --更新选择数目
  local selCount = self:getSelectedCount() 
  self.selectedNum:setString(string.format("%d/%d", selCount, self._countMax))
end 


return  EquipmentListLayer 
