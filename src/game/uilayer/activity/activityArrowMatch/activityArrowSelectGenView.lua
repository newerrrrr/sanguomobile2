
--选择武将

local activityArrowSelectGenView = class("activityArrowSelectGenView",require("game.uilayer.base.BaseLayer"))
local viewObj 

--preSelectedGen: 只包含武将id
function activityArrowSelectGenView:ctor(preSelectedGen, callback)
  activityArrowSelectGenView.super.ctor(self)
  viewObj = self 
  self.callback = callback 
  self.preSelBak = preSelectedGen 
  self.curSelGens = {} --存放选中的武将数据
  self.iconBak = {} --保存显示的所有icon

  local layer = g_gameTools.LoadCocosUI("activity4_mian10_list1.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    self:initData(preSelectedGen)
  end 
end 

function activityArrowSelectGenView:onEnter()
  print("activityArrowSelectGenView:onEnter") 
  self:showPreSelGen()
  self:showGenList()
end 

function activityArrowSelectGenView:onExit() 
  print("activityArrowSelectGenView:onExit") 
  viewObj = nil 

  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end    
end 

function activityArrowSelectGenView:initData(preSelectedGen)

  --武将排序
  local data = g_GeneralMode.GetData() 
  if data then 
    self.allGens = clone(data)

    --1.排序
    --按品质排序
    table.sort(self.allGens, function(a, b) 
        return g_data.general[a.general_id*100+1].general_quality > g_data.general[b.general_id*100+1].general_quality
      end)

    --按星级
    local function sortByStarLv(a, b)
      return a.star_lv < b.star_lv 
    end 
    local SmithyData = require("game.uilayer.smithy.SmithyData")

    local idx_s = 1
    local idx_e = #self.allGens
    local preType = g_data.general[self.allGens[idx_s].general_id*100+1].general_quality
    for i = idx_s+1, idx_e do
      local curType = g_data.general[self.allGens[i].general_id*100+1].general_quality
      if i < idx_e then
        if curType ~= preType then
          SmithyData:sort(self.allGens, idx_s, i-1, sortByStarLv)
          idx_s = i
          preType = curType
        end 
      else 
        if curType ~= preType then
          SmithyData:sort(self.allGens, idx_s, i-1, sortByStarLv)
        else
          SmithyData:sort(self.allGens, idx_s, i, sortByStarLv)
        end
      end
    end

    --2.查找已选
    if preSelectedGen and type(preSelectedGen) == "table" then 
      for key, id in pairs(preSelectedGen) do 
        for k, v in pairs(self.allGens) do 
          if v.general_id == id then 
            table.insert(self.curSelGens, v)
          end 
        end 
      end 
    end 
  end 
end 

function activityArrowSelectGenView:initBinging(layer)
  self.root = layer:getChildByName("scale_node") 

  local btnClose = self.root:getChildByName("close_btn") 
  self:regBtnCallback(btnClose, handler(self, self.close))
  self.root:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("selectGeneralTitle"))

  self.listView = self.root:getChildByName("ListView_1") 
  self.root:getChildByName("Text_wj1"):setString(g_tr("arrow_selected_gen"))

  local btnConfirm = self.root:getChildByName("Button_1")
  btnConfirm:getChildByName("Text_1"):setString(g_tr("confirm"))
  self:regBtnCallback(btnConfirm, handler(self, self.onConfirm))


  --滑动列表逐渐添加
  local function onScrollViewEvent(sender, eventType) 
    if eventType == ccui.ScrollviewEventType.scrolling then 

      if self.frameLoadTimer then return end --如果仍在分帧加载中,则返回

      local pos = sender:getInnerContainerPosition() 
      if pos.y > -5 then 
        self:frameLoadList(5) 
      end 
    end 
  end 
  self.listView:addScrollViewEventListener(onScrollViewEvent) 
end 

function activityArrowSelectGenView:isSelected(genId) 
  if nil == self.curSelGens then return false end 

  for k, v in pairs(self.curSelGens) do 
    if v == genId then 
      return true 
    end 
  end 

  return false 
end 

function activityArrowSelectGenView:showPreSelGen()
  if nil == self.root then return end 

  if #self.curSelGens < 1 then return end 

  for i = 1, 3 do 
    if self.curSelGens[i] then 
      local icon = self:getGenIcon(self.curSelGens[i], false)
      if icon then 
        local node = self.root:getChildByName("Panel_"..i)
        icon:setAnchorPoint(cc.p(0, 1))
        icon:setPosition(cc.p(0, node:getContentSize().height))
        node:addChild(icon)
      end 
    end 
  end 
end 

function activityArrowSelectGenView:showGenList()
  if nil == self.allGens then return end 

  --加载列表项
  self.listView:removeAllChildren()
  self.listView:setScrollBarEnabled(false)

  self.dataLen = #self.allGens  --武将总数
  self.mainIdx = 1  --当前行数
  self.firstLoadMax = 5 --初次最多显示20行,后续滑动列表时手动添加
  self:frameLoadList(self.firstLoadMax)
end 


function activityArrowSelectGenView:frameLoadList(loadLineCount) 
  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end  

  if self.mainIdx > self.dataLen then return end 


  local function insertOneLine()
    if self.mainIdx > self.dataLen then return false end 

    print("insertOneLine")
    local numPerLine = 5
    local layout = ccui.Layout:create()  
    local itemLineSize = cc.size(self.listView:getContentSize().width, 170) 
    local gridSize = cc.size(itemLineSize.width/numPerLine, itemLineSize.height)
    layout:setContentSize(itemLineSize) 

    for k = 1, numPerLine do 

      if self.mainIdx > self.dataLen then break end 

      local genId = self.allGens[self.mainIdx].general_id 
      local icon = self:getGenIcon(self.allGens[self.mainIdx], true)
      if icon then 
        icon:setAnchorPoint(cc.p(0, 1))
        icon:setPosition(cc.p((k-1)*gridSize.width, gridSize.height))
        layout:addChild(icon) 
        self.iconBak[genId] = icon 
      end 
      self.mainIdx = self.mainIdx + 1 
    end 
    self.listView:pushBackCustomItem(layout)

    return true 
  end 

  local lineCount = 0 
  local function loadLineItems() 
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
    end 
  end 
  self.frameLoadTimer = self:schedule(loadLineItems, 0) 
end 

function activityArrowSelectGenView:onTouchIcon(genId)
  print("onTouchIcon", genId) 
  local node = self.iconBak[genId] 
  if nil == node then return end 

  local idx 
  for k, v in pairs(self.curSelGens) do 
    if v.general_id == genId then 
      idx = k 
      break 
    end 
  end
  
  if idx then 
    table.remove(self.curSelGens, idx)
    node:getChildByName("Image_sel"):setVisible(false)
  else 
    if #self.curSelGens >= 3 then 
      g_airBox.show(g_tr("arrow_sel_count_max"))
    else 
      for k, v in pairs(self.allGens) do 
        if v.general_id == genId then 
          table.insert(self.curSelGens, v)
          node:getChildByName("Image_sel"):setVisible(true)        
          break 
        end 
      end 
    end 
  end 
end 

function activityArrowSelectGenView:onConfirm()

  if #self.curSelGens ~= 3 then 
    g_airBox.show(g_tr("arrow_sel_tips"))
    return 
  end 

  if self:isPositionChanged() then 

    local function onRecv(result, data)
      g_busyTip.hide_1()
      if result then 
        dump(data, "====data")
        if self.callback then 
          self.callback(self.curSelGens)
        end 
      end 
      self:close() 
    end 

    local para = {general_1 = self.curSelGens[1].general_id, general_2 = self.curSelGens[2].general_id, 
                  general_3 = self.curSelGens[3].general_id, steps = g_guideManager.getToSaveStepId() }
    g_sgHttp.postData("Arrow/saveArrowGeneral", para, onRecv, true) 
    g_busyTip.show_1() 
  else 
    self:close() 
  end 
end 

function activityArrowSelectGenView:isPositionChanged()
  local isChanged = false 
  for k, id in pairs(self.preSelBak) do 
    local found = false 
    for i, v in pairs(self.curSelGens) do 
      if id == v.general_id then 
        found = true 
        break 
      end 
    end 

    if not found then 
      isChanged = true 
      break 
    end 
  end 

  return isChanged 
end 

function activityArrowSelectGenView:getGenIcon(srvGen, isEnableSel)
  local node = cc.CSLoader:createNode("activity4_mian10_list2.csb") 
  local bg = node:getChildByName("Image")  
  local size = bg:getContentSize()
  local configId = srvGen.general_id*100+1
  local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, configId, 1)
  if icon then 
    icon:setNameVisible(true) 
    icon:setCountEnabled(false)
    icon:setPosition(cc.p(size.width/2, size.height/2))
    if g_data.general[configId].general_quality == g_GeneralMode.godQuality then --神武将 
      icon:showGeneralServerStarLv(srvGen.star_lv)
    end 
    bg:addChild(icon)
  end 
  node:getChildByName("Image_sel"):setVisible(false)
  node:getChildByName("Image_fg"):setVisible(false)
  node:setTag(srvGen.general_id)
  if isEnableSel then 
    node:setTouchEnabled(true)
    node:addClickEventListener(function(sender) self:onTouchIcon(sender:getTag()) end) 

    for k, v in pairs(self.curSelGens) do 
      if srvGen.general_id == v.general_id then 
        node:getChildByName("Image_sel"):setVisible(true) 
        break 
      end 
    end 
  end

  --显示旗子,星级
  local item = g_data.general[configId]
  if item then 
    local resId = {1081003, 1081002, 1081001, 1081007} --吴、蜀、魏、群雄 
    if resId[item.general_country] then 
      node:getChildByName("Image_qizi"):loadTexture(g_resManager.getResPath(resId[item.general_country]))
    else 
      node:getChildByName("Image_qizi"):setVisible(false)
    end 
  end 

  return node 
end 

return activityArrowSelectGenView 

