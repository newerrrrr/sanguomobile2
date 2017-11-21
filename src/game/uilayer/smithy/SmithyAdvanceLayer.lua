
--铁匠铺:进阶
local EquipmentIcon = require("game.uilayer.common.EquipmentIcon")
local SmithyData = require("game.uilayer.smithy.SmithyData")
local SmithyAdvanceLayer = class("SmithyAdvanceLayer", require("game.uilayer.base.BaseLayer"))

--参数:paraTbl : {generalId, genEquIdx} --- 武将默认高亮的的武将及其指定的装备
--             : equipId      --默认显示空闲装备列表                
function SmithyAdvanceLayer:ctor(paraTbl)
  SmithyAdvanceLayer.super.ctor(self)
  print("SmithyAdvanceLayer:ctor")
  dump(paraTbl, "paraTbl")

  self.curGenIdx = 1 --当前选中的武将索引
  self.curEquListIdx = 1 --当前选中的装备索引

  self.curEquId = nil --当前选中的装备Id
  self.curEquIcon = nil --当前选中的icon对象(供播放动画使用)

  self.btnStatus = false --切换未装备按钮

  self.para = paraTbl 
end 

function SmithyAdvanceLayer:onEnter()
  print("SmithyAdvanceLayer:onEnter")
  local layer = cc.CSLoader:createNode("Blacksmith_Advanced.csb") 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    if nil == self.para or type(self.para) == "table" then 
      local genId = self.para and self.para[1] or nil 
      self.curEquListIdx = self.para and self.para[2] or 1 

      self:showGeneralList(genId) 
      self.para = nil --只执行一次
    else 
      self:showIdleEquipList(true) 
    end 
  end 
  g_guideManager.execute()
end 

function SmithyAdvanceLayer:onExit() 
  print("SmithyAdvanceLayer:onExit") 
  if self.isGenAttrDurty then 
    g_gameCommon.dispatchEvent(g_Consts.CustomEvent.UpdateGenAttr)
  end 
end 

function SmithyAdvanceLayer:initBinding(scaleNode)
  self.nodeEquip1 = scaleNode:getChildByName("Panel_3")
  self.nodeEquip2 = scaleNode:getChildByName("Panel_3_3")
  self.listView = self.nodeEquip1:getChildByName("ListView_1")

  local btnWeapon = self.nodeEquip1:getChildByName("Panel_11")
  local btnArmor = self.nodeEquip1:getChildByName("Panel_12")
  local btnAccessory = self.nodeEquip1:getChildByName("Panel_13")
  local btnZuoqi = self.nodeEquip1:getChildByName("Panel_14")
  self.btnEquipArray = {btnWeapon, btnArmor, btnAccessory, btnZuoqi}
  self.equList = self.nodeEquip2:getChildByName("ListView_2")
  self.nodeArrow = scaleNode:getChildByName("Panel_arrow")

  scaleNode:getChildByName("Text_27"):setString(g_tr("genEquAdvance")) --title


  local strTitle = {g_tr("wu"), g_tr("zhi"), g_tr("zheng"), g_tr("tong"), g_tr("mei")}
  local strTips = {g_tr("wuInfo"), g_tr("zhiInfo"), g_tr("zhengInfo"), g_tr("tongInfo"), g_tr("meiInfo")}

  --非红色装备信息
  self.Panel_4 = scaleNode:getChildByName("Panel_4")
  
  self.Panel_4:getChildByName("Text_27_0"):setString(g_tr("equAdvance"))
  
  self.Panel_4:getChildByName("Panel_tiao_0"):getChildByName("Text_20"):setString(g_tr("starLevel"))
  for i=1, 5 do 
    self.Panel_4:getChildByName("Panel_tiao_"..i):getChildByName("Text_20"):setString(strTitle[i])
    local icon = self.Panel_4:getChildByName("Panel_tiao_"..i):getChildByName("Image_9")
    g_itemTips.tipStr(icon, strTitle[i], strTips[i])
  end 

  --红色装备信息
  self.Panel_6 = scaleNode:getChildByName("Panel_6")
  self.Panel_6:getChildByName("Text_title"):setString(g_tr("equipTuPo"))
  self.Panel_6:getChildByName("Text_6"):setString(g_tr("equipQualityLv"))
  for i=1, 5 do 
    self.Panel_6:getChildByName("Panel_tiao_"..i):getChildByName("Text_20"):setString(strTitle[i])
    local icon = self.Panel_6:getChildByName("Panel_tiao_"..i):getChildByName("Image_9")
    g_itemTips.tipStr(icon, strTitle[i], strTips[i]) 
  end 


  --进阶材料
  self.Panel_5 = scaleNode:getChildByName("Panel_5")
  self.Panel_5:getChildByName("Text_3"):setString(g_tr("advance"))
  self.Panel_5:getChildByName("Panel_mat"):getChildByName("Text_1"):setString(g_tr("material"))
  self.btnAdvance = self.Panel_5:getChildByName("Button_1")
  self.nodeMat = self.Panel_5:getChildByName("Panel_mat")
  self.lbCost = self.Panel_5:getChildByName("Text_19_0")

  for k, v in pairs(self.btnEquipArray) do 
    self:regBtnCallback(v, handler(self, self.onGenEquipmentIcon))
  end 
  self:regBtnCallback(self.btnAdvance, handler(self, self.onstartAdvance))
  self:regBtnCallback(self.nodeArrow, handler(self, self.onChangeView))

  self.nodeArrow:getChildByName("Text_50"):setString(g_tr("idleEquips"))

  g_guideManager.registComponent(9999991, self.btnAdvance)
end 


-- function SmithyAdvanceLayer:updateView()

--   if self.nodeEquip1:isVisible() then --武将列表 
--     self:showGeneralList() 
--   else 
--     self:showIdleEquipList(true) 
--   end 
-- end 


--尽量保持原有列表位置不变，更新状态即可
function SmithyAdvanceLayer:updateView()

  if self.nodeEquip1:isVisible() then 
    if nil == self.listView then return end 

    --更新武将可进阶/突破状态
    --将新数据合并到旧数组self.generals中
    local tmpdata = SmithyData:instance():getGeneralWithEquip() 
    for k, v in pairs(self.generals) do 
      for i, gen in pairs(tmpdata) do 
        if v.general_id == gen.general_id then 
          self.generals[k] = gen 
          table.remove(tmpdata, i)
          break 
        end 
      end 
    end 

    for k, v in pairs(self.listView:getItems()) do 
      local scale_node = v:getChildByName("scale_node")
      if scale_node then 
        local item = self.generals[k] 
        if item then 
          local picAdv = scale_node:getChildByName("Image_4")
          local picTupo = scale_node:getChildByName("Image_5")
          picAdv:setVisible(false)
          picTupo:setVisible(false)
          if item._canTupo then 
            picTupo:setVisible(true) 
          elseif item._canAdvanced then 
            picAdv:setVisible(true)
          end 
        end 
      end 
    end 
    self:showGenEquipIcons() 
  else 

    local dirtyIdx = self.curEquIcon:getIdx()

    local idleEquips = SmithyData:instance():getEquipForAdvanced() 

    local tmpdata = clone(idleEquips)
    for k, icon in pairs(self.iconsTbl) do 
      if k ~= dirtyIdx then 
        for i, v in pairs(tmpdata) do 
          if icon:getEquipId() == v.item_id then 
            icon:setAdvancedImgVisible(v._canAdvanced)
            tmpdata[i].num = tmpdata[i].num - 1 

            if tmpdata[i].num <= 0 then 
              table.remove(tmpdata, i) 
            end 
            break 
          end 
        end 
      end 
    end 

    dump(tmpdata, "====tmpdata")
    local icon_old = self.iconsTbl[dirtyIdx] 
    if nil == icon_old then return end 

    if #tmpdata > 0 then  
      local item_new = tmpdata[1] 
      self.idleEquipsExtend[dirtyIdx] = item_new
      local icon_new = EquipmentIcon:create(item_new.item_id)
      if icon_new then 
        icon_new:setPosition(cc.p(icon_old:getPosition()))
        icon_new:setIdx(dirtyIdx)
        icon_new:setNameVisible(true) 
        icon_new:setTouchCallback(icon_old:getTouchCallback()) 
        icon_new:setAdvancedImgVisible(item_new._canAdvanced)
        icon_old:getParent():addChild(icon_new) 
        self.iconsTbl[dirtyIdx] = icon_new 

        icon_new:getTouchCallback()(dirtyIdx, item_new.item_id)                    
      end 
      icon_old:removeFromParent()
    else 
      --此时装备已经满级满星, 不会再此界面出现，所以移除,高亮旁边一个即可
      icon_old:removeFromParent()
      self.iconsTbl[dirtyIdx] = nil 

      local nearIdx = self.iconsTbl[dirtyIdx+1] and (dirtyIdx+1) or (dirtyIdx-1)
      local nearIcon = self.iconsTbl[nearIdx]
      if nearIcon then 
        nearIcon:getTouchCallback()(dirtyIdx+1, nearIcon:getEquipId()) 
      end 
    end 
  end 
end 

--换装
function SmithyAdvanceLayer:onChangeView()
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  self.btnStatus = not self.btnStatus 

  self.curEquListIdx = 1 --reset 
  print("onChangeView:", self.btnStatus)
  if self.btnStatus then --显示空闲装备列表
    self:showIdleEquipList(true) 
  else 
    self:showGeneralList() 
  end 
end 

--显示未装备列表
function SmithyAdvanceLayer:showIdleEquipList(isVisible)

  print("showIdleEquipList", isVisible)

  if isVisible then 

    self.nodeArrow:getChildByName("Image_1"):setVisible(false)
    self.nodeArrow:getChildByName("Image_2"):setVisible(true)
    
    self.nodeEquip1:setVisible(false)
    self.nodeEquip2:setVisible(true)

    --show equip icons 
    self.equList:removeAllChildren()
    self.equList:setScrollBarEnabled(false)

    self.curEquId = nil
    self.curEquIcon = nil    

    local idleEquips = SmithyData:instance():getEquipForAdvanced() 
    local len = #idleEquips
    if len == 0 then 
      self:showEquipInfo(nil) --reset
      return 
    end 

    --第一次打开界面时需要预处理参数, 只执行一次
    if self.para and type(self.para) == "number" then 
      for k, v in pairs(idleEquips) do 
        if v.item_id == self.para then 
          table.remove(idleEquips, k) --高亮项放在最前面
          table.insert(idleEquips, 1, v)
          break 
        end 
      end 
      self.para = nil 
    end 
    self.curEquId = idleEquips[1].item_id 

    --将叠加的装备展开存储和显示
    self.idleEquipsExtend = {} 
    for k, v in pairs(idleEquips) do 
      for i=1, v.num do 
        table.insert(self.idleEquipsExtend, v) 
      end 
    end 

    local idx_s = 1 
    local idx_e = #self.idleEquipsExtend 
    self.iconsTbl = {} --存放装备icon对象
    local function onTouchEquip(idx, equId)
      --reset
      for k, v in pairs(self.iconsTbl) do 
        if v:getIsSelected() then 
          v:setIsSelected(false)
        end 
      end 
      self.iconsTbl[idx]:setIsSelected(true)

      self.curEquId = equId 
      self.curEquIcon = self.iconsTbl[idx] 
      self:showEquipInfo(self.curEquId)
    end 

    local function loadOneLineItems() 
      if idx_s <= idx_e then 
        local layout = ccui.Layout:create()         
        local gridSize = self.equList:getContentSize().width/3 

        for i = 1, 3 do 
          if idx_s > idx_e then break end 

          local equId = self.idleEquipsExtend[idx_s].item_id
          local icon = EquipmentIcon:create(equId)
          if icon then 
            layout:setContentSize(cc.size(gridSize*3, gridSize)) 
            icon:setPosition(cc.p((i-1)*gridSize+gridSize/2, gridSize/2))
            icon:setIdx(idx_s)
            icon:setNameVisible(true) 
            icon:setTouchCallback(onTouchEquip) 
            icon:setAdvancedImgVisible(self.idleEquipsExtend[idx_s]._canAdvanced)
            layout:addChild(icon) 

            self.iconsTbl[idx_s] = icon                    
          end 
          idx_s = idx_s + 1 
        end 
        self.equList:pushBackCustomItem(layout)

        if idx_s <= 4 then 
          onTouchEquip(1, self.idleEquipsExtend[1].item_id)  
        end 
      else 
        

        if self.frameLoadTimer then 
          self:unschedule(self.frameLoadTimer) 
          self.frameLoadTimer = nil  
        end 
      end 
    end 

    if self.frameLoadTimer then 
      self:unschedule(self.frameLoadTimer) 
      self.frameLoadTimer = nil  
    end 
    self.frameLoadTimer = self:schedule(loadOneLineItems, 0) 

  else 
    self.nodeArrow:getChildByName("Image_1"):setVisible(true)
    self.nodeArrow:getChildByName("Image_2"):setVisible(false)

    self.nodeEquip1:setVisible(true)
    self.nodeEquip2:setVisible(false)
  end 
end 

--显示佩戴装备的武将, 最后一项显示装备背包(存放空闲装备)
function SmithyAdvanceLayer:showGeneralList(focusGenId)

  local function highlightItem(index)
    print("highlightItem:", index)
    local item, scaleNode, img 
    for k, v in pairs(self.listView:getItems()) do 
      scaleNode = v:getChildByName("scale_node")
      if scaleNode then 
        img = scaleNode:getChildByName("Image_3")
        if img then 
          img:setVisible(index == k-1)
        end 
      end 
    end 
  end 

  local function onSelectItem(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then 
      local index = sender:getCurSelectedIndex()
      if self.curGenIdx ~= index+1 then 
        self.curGenIdx = index+1 
        self.curEquListIdx = 1 --默认显示第一个武器icon 
        highlightItem(index) 
        self:showGenEquipIcons() 
      end 
    end 
  end 

  self.nodeEquip1:setVisible(true)
  self.nodeEquip2:setVisible(false)

  self:showIdleEquipList(false)
  self.generals = SmithyData:instance():getGeneralWithEquip() 

  --1.显示武将列表
  local GeneralListItem = cc.CSLoader:createNode("Blacksmith_Advanced01.csb") 
  local scale_node = GeneralListItem:getChildByName("scale_node")
  local nodeIcon = scale_node:getChildByName("Panel_1")
  local lbName = scale_node:getChildByName("Text_2")
  local picAdv = scale_node:getChildByName("Image_4")
  local picTupo = scale_node:getChildByName("Image_5")
  picAdv:setVisible(false)
  picTupo:setVisible(false)
  scale_node:getChildByName("Image_3"):setVisible(false)

  self.listView:removeAllChildren()
  self.listView:addEventListener(onSelectItem)
  self.listView:setItemModel(GeneralListItem)
  self.listView:setScrollBarEnabled(false)
  self.listView:setItemsMargin(10)

  --先显示装备信息,再分帧加载武将列表
  if focusGenId then 
    for k, v in pairs(self.generals) do 
      if v.general_id == focusGenId then 
        self.curGenIdx = k 
        break 
      end 
    end 
  end 
  self:showGenEquipIcons() 

  --分帧加载武将列表
  local idx_s = 1 
  local idx_e = #self.generals 
  local size = nodeIcon:getContentSize()
  local function loadGeneralItem()
    if idx_s <= idx_e then  
      nodeIcon:removeAllChildren() 
      local item = self.generals[idx_s]
      local id = item.general_id*100 + 1 --item.lv
      local icon = self:createHeroHead(id)
      if icon then
        nodeIcon:addChild(icon)
        icon:setPosition(nodeIcon:getContentSize().width/2, nodeIcon:getContentSize().height/2)
        icon:setScale(nodeIcon:getContentSize().width/icon:getContentSize().width)
      end    
      lbName:setString(g_tr(g_data.general[id].general_name))

      picAdv:setVisible(false)
      picTupo:setVisible(false)   
      if item._canTupo then 
        picTupo:setVisible(true) 
      elseif item._canAdvanced then 
        picAdv:setVisible(true)
      end 
      
      GeneralListItem:setTag(item.general_id)
      self.listView:pushBackDefaultItem()
      idx_s = idx_s + 1 

    else 
      --加载完成
      if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
      end 

      if self.curGenIdx > 3 then 
        self.listView:forceDoLayout() 
        self.listView:jumpToPercentVertical(100*self.curGenIdx/idx_e) 
      end 
      highlightItem(self.curGenIdx-1)      
    end 
  end 

  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end 
  self.frameLoadTimer = self:schedule(loadGeneralItem, 0) 
end 


--显示装备icon (武将身上的装备)
function SmithyAdvanceLayer:showGenEquipIcons()
  print("===showGenEquipIcons", self.curEquListIdx)

  self.curEquId = nil
  self.curEquIcon = nil 
  self.isPlayingAnim = false 
  if self.curGenIdx <= #self.generals then --武将身上的装备

    local item = self.generals[self.curGenIdx] 
    local ids = {item.weapon_id, item.armor_id, item.horse_id, item.zuoji_id} 

    --排列装备icon位置(神武将有4个装备)
    local iconNum = 3
    if g_data.general[item.general_id*100+1] and g_data.general[item.general_id*100+1].general_quality >= g_GeneralMode.godQuality then 
      iconNum = 4 
    end 
    local gridHeight = self.listView:getContentSize().height/iconNum 
    local tmp_y = self.listView:getPositionY() + self.listView:getContentSize().height 
    for i = 1, #ids do 
      self.btnEquipArray[i]:setPositionY(tmp_y - (i-0.5)*gridHeight)
      self.btnEquipArray[i]:setVisible(i <= iconNum)
    end 

    for i=1, iconNum do 
      local icon_bg = self.btnEquipArray[i]:getChildByName("Image_1")
      local icon_node = self.btnEquipArray[i]:getChildByName("node_icon")
      icon_bg:setVisible(true)
      icon_node:removeAllChildren() 

      if ids[i] > 0 then 
        local icon = EquipmentIcon:create(ids[i])
        if icon then 
          local size = icon_bg:getContentSize()
          icon:setNameVisible(true)
          icon:setNameInRegion(iconNum > 3)
          icon:setPosition(cc.p(size.width/2, size.height/2))
          icon:setTag(i)
          icon_node:addChild(icon) 
          icon_bg:setVisible(false)

          --播放可进阶装备动画
          if SmithyData:instance():canEquipmentAdvanced(ids[i]) then
            local projName = "Effect_ZhuChengZengYiKuang"
            local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_ZhuChengZengYiKuang/Effect_ZhuChengZengYiKuang.ExportJson", "Effect_ZhuChengZengYiKuang")
            if armature then 
              armature:setPosition(cc.p(size.width/2, size.height/2))
              armature:setTag(100)
              icon_node:addChild(armature)
              animation:play("Animation1")
            end             
          end 

          if i == self.curEquListIdx then 
            self.curEquId = ids[i]
            self.curEquIcon = icon  
            icon:setIsSelected(true)
          else 
            icon:setIsSelected(false)
          end 
        end  
      end 
    end 
  end 

  self:showEquipInfo(self.curEquId)
end 

--点击选中武将指定装备, 若为空, 则打开装备列表供用户选择并佩戴到该武将身上
function SmithyAdvanceLayer:onGenEquipmentIcon(sender) 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  if self.curGenIdx <= #self.generals then 
    local general = self.generals[self.curGenIdx] 

    local icon, node 
    for k, v in pairs(self.btnEquipArray) do 
      node = v:getChildByName("node_icon")
      icon = node:getChildByTag(k)
      if icon then 
        icon:setIsSelected(false) 
      end 
    end 

    local equipId, equType  
    if sender == self.btnEquipArray[1] then 
      equipId = general.weapon_id
      equType = 1 
    elseif sender == self.btnEquipArray[2] then 
      equipId = general.armor_id
      equType = 2 
    elseif sender == self.btnEquipArray[3] then
      equipId = general.horse_id
      equType = 3 
    elseif sender == self.btnEquipArray[4] then 
      equipId = general.zuoji_id
      equType = 4     
    end 
    self.curEquListIdx = equType 

    node = sender:getChildByName("node_icon")
    icon = node:getChildByTag(equType)
    if icon then 
      icon:setIsSelected(true) 
    end     

    print("onGenEquipmentIcon", equType)

    if equipId and equipId > 0 then 
      self.curEquId = equipId
      self.curEquIcon = icon       
      self:showEquipInfo(self.curEquId)
    else 

      print("open equip list for equip, type=", equType)
      --手动选择佩戴到武将身上
      local function singleSelecteResult(resultTbl) 
        print("singleSelecteResult", #resultTbl) 
        if #resultTbl > 0 then 
          local genId = self.generals[self.curGenIdx].general_id 

          --通知服务器给当前武将佩戴装备 
          local function equipResult(result, data)
            print("equipResult:", result)
            if result then 
              self:updateView()
              if self:getDelegate() then 
                self:getDelegate():updatePlayerResource()
              end 
              SmithyData:updateGenBuff(genId)
            end 
          end 
          
          local equId = resultTbl[1].item_id 
          print("=== genid, equiId, equtype", genId, equId, equType)
          g_sgHttp.postData("General/equip", {generalId=genId, itemId = equId, type=equType}, equipResult)        
        end 
      end 

      local allEquips = SmithyData:instance():getIdleEquip() 
      local data = SmithyData:instance():getEquipByType(allEquips, equType)
      if #data > 0 then 
        local layer = require("game.uilayer.smithy.EquipmentListLayer").new(SmithyData.listSelectType.Single, data)
        layer:setUserCallback(singleSelecteResult) 
        g_sceneManager.addNodeForUI(layer) 
      else 
        if equType == 4 then --坐骑
          g_airBox.show(g_tr("equpResTips2")) 
        else 
          g_airBox.show(g_tr("equpResTips")) 
        end 
      end 
    end 
  end 
end 


function SmithyAdvanceLayer:showEquipInfo(equipId)
  if equipId then 
    if SmithyData:isEquipCanTupo(equipId) then 
      self:showToRedEquipInfo(equipId)
    else 
      self:showCommonEquipInfo(equipId)
    end 
  else 
    self:showCommonEquipInfo(equipId)
  end 
end 


--显示装备的详细信息
function SmithyAdvanceLayer:showCommonEquipInfo(equipId)
  print("showCommonEquipInfo: equId=", equipId)

  self.Panel_4:setVisible(true)
  self.Panel_6:setVisible(false)

  local lbSkill = {self.Panel_4:getChildByName("Text_5"), self.Panel_4:getChildByName("Text_6"), self.Panel_4:getChildByName("Text_7")}
  local skillVal = {self.Panel_4:getChildByName("Text_5_1"), self.Panel_4:getChildByName("Text_6_1"), self.Panel_4:getChildByName("Text_7_1")}
  local toValueSkill = {self.Panel_4:getChildByName("Text_5_2"), self.Panel_4:getChildByName("Text_6_2"), self.Panel_4:getChildByName("Text_7_2")}

  local attrTable  = {}
  --reset 
  for i=1, 5 do 
    attrTable[i] = self.Panel_4:getChildByName("Panel_tiao_"..i)
    attrTable[i]:getChildByName("Text_22"):setString("")
    attrTable[i]:getChildByName("Text_23"):setString("")
  end 
  for i=1, 3 do
    lbSkill[i]:setString("")
    skillVal[i]:setString("")
    toValueSkill[i]:setString("")
  end 
  for i=1, 5 do 
    self.nodeMat:getChildByName(string.format("Panel_List0%d", i)):removeAllChildren()
  end
  self.lbCost:setString("")
  self.btnAdvance:setEnabled(false)

  if nil == equipId then return end 

  if equipId and equipId > 0 then 
    local item1 = g_data.equipment[equipId]
    local targetId = item1.target_equip > 0 and item1.target_equip or equipId 
    local item2 = g_data.equipment[targetId] 

    local Panel_tiao_0 = self.Panel_4:getChildByName("Panel_tiao_0")
    local star_gray, star_nor 
    for i = 1, 5 do 
      star_gray = Panel_tiao_0:getChildByName("Image_xing"..i)
      star_nor = Panel_tiao_0:getChildByName("Image_xing"..(i+5))
      star_gray:setVisible(item2.max_star_level >= i) --灰星
      star_nor:setVisible(item2.star_level >= i) --亮星

      --添加星星动画
      star_gray:removeAllChildren()
      if item1.target_equip > 0 and i == item2.star_level then 
        star_nor:setVisible(false) --亮星
        
        local size = star_gray:getContentSize()
        local projName = "Effect_StarKuang"
        local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName)
        star_gray:addChild(armature)
        armature:setPosition(cc.p(size.width/2, size.height/2))
        animation:play("Animation1")        
      end 
    end 
   
    self.btnAdvance:setEnabled(item1.target_unlock > 0 and item1.target_equip > 0)

    print("===id, id2", item1.id, item2.id)
    attrTable[1]:getChildByName("Text_22"):setString(""..item1.force)
    attrTable[1]:getChildByName("Text_23"):setString("+"..(item2.force-item1.force))
    attrTable[2]:getChildByName("Text_22"):setString(""..item1.intelligence)
    attrTable[2]:getChildByName("Text_23"):setString("+"..(item2.intelligence-item1.intelligence))
    attrTable[3]:getChildByName("Text_22"):setString(""..item1.political)
    attrTable[3]:getChildByName("Text_23"):setString("+"..(item2.political-item1.political))
    attrTable[4]:getChildByName("Text_22"):setString(""..item1.governing)
    attrTable[4]:getChildByName("Text_23"):setString("+"..(item2.governing-item1.governing))
    attrTable[5]:getChildByName("Text_22"):setString(""..item1.charm)
    attrTable[5]:getChildByName("Text_23"):setString("+"..(item2.charm-item1.charm))

    --技能
    local emptyIdx
    for i=1, 3 do
      local skill = g_data.equip_skill[item1.equip_skill_id[i]]
      if skill == nil then
        lbSkill[i]:setString("")
        skillVal[i]:setString("")
        toValueSkill[i]:setString("")
        if nil == emptyIdx then 
          emptyIdx = i 
        end 
      else
        local buff = g_data.buff[skill.skill_buff_id[1]]
        lbSkill[i]:setString(g_tr("armyskillstr"))

        local strNum = ""..skill.num
        if buff.buff_type == 1 then --万分比
        strNum = (skill.num/100) .. "%%"
        end 
        skillVal[i]:setString(g_tr(skill.skill_description, {num = strNum})) 

        if equipId == targetId then --满级时    
          toValueSkill[i]:setString("")
        else 
          local nextSkill = g_data.equip_skill[item2.equip_skill_id[i]]
          if buff.buff_type == 1 then
            toValueSkill[i]:setString("->"..(nextSkill.num/100).."%")
          elseif buff.buff_type == 2 then
            toValueSkill[i]:setString("->"..nextSkill.num)
          end
        end
      end
    end
    
    --如果是红色装备,则增加一条额外技能信息
    if item1.quality_id >=6 and nil ~= emptyIdx then 
      lbSkill[emptyIdx]:setString(g_tr("armyskillstr"))
      skillVal[emptyIdx]:setString(SmithyData:instance():getRedEquipNewSkillDesc(equipId))
      if equipId == targetId then --满级时    
        toValueSkill[emptyIdx]:setString("")
      else 
        toValueSkill[emptyIdx]:setString("->"..item2.skill_level) 
      end 
    end 

    --材料 
    self:showMatInfo(equipId) 
  end 

  self.Panel_5:getChildByName("Text_3"):setString(g_tr("advance")) 
end 

--显示装备突破界面
function SmithyAdvanceLayer:showToRedEquipInfo(equipId)
  print("showToRedEquipInfo, equipId=", equipId)

  self.Panel_4:setVisible(false)
  self.Panel_6:setVisible(true) 

  local node_src = self.Panel_6:getChildByName("Image_4") 
  local node_dst = self.Panel_6:getChildByName("Image_6") 
  node_src:removeAllChildren()
  node_dst:removeAllChildren()

  local attrTable = {}
  for i=1, 5 do 
    attrTable[i] = self.Panel_6:getChildByName("Panel_tiao_"..i)
    attrTable[i]:getChildByName("Text_22"):setString("")
    attrTable[i]:getChildByName("Text_23"):setString("")
  end 

  self.Panel_6:getChildByName("Text_7"):setString(g_tr("addNewSkill"))
  local lbSkill = self.Panel_6:getChildByName("Text_8")
  lbSkill:setString("")


  if nil == equipId then return end 

  --显示icon
  local icon_src = require("game.uilayer.common.EquipmentIcon"):create(equipId) 
  if icon_src then 
    local size = node_src:getContentSize()
    icon_src:setNameVisible(false)
    icon_src:setCountEnabled(false)
    icon_src:setPosition(cc.p(size.width/2, size.height/2))
    node_src:addChild(icon_src) 
  end 

  local item1 = g_data.equipment[equipId]
  if nil == item1 then return end 

  if item1.target_equip and item1.target_equip < 0 then return end 

  local item2 = g_data.equipment[item1.target_equip]
  if nil == item2 then return end 

  local icon_dst = require("game.uilayer.common.EquipmentIcon"):create(item1.target_equip) 
  if icon_dst then 
    local size = node_dst:getContentSize()
    icon_dst:setNameVisible(false)
    icon_dst:setCountEnabled(false)
    icon_dst:setPosition(cc.p(size.width/2, size.height/2))
    node_dst:addChild(icon_dst) 
  end 

  --基础属性
  attrTable[1]:getChildByName("Text_22"):setString(""..item1.force)
  if item2.force > item1.force then 
    attrTable[1]:getChildByName("Text_23"):setString("(+"..(item2.force-item1.force)..")")
  end 
  attrTable[2]:getChildByName("Text_22"):setString(""..item1.intelligence)
  if item2.intelligence > item1.intelligence then 
    attrTable[2]:getChildByName("Text_23"):setString("(+"..(item2.intelligence-item1.intelligence)..")")
  end 
  attrTable[3]:getChildByName("Text_22"):setString(""..item1.political)
  if item2.political > item1.political then 
    attrTable[3]:getChildByName("Text_23"):setString("+"..(item2.political-item1.political))
  end 
  attrTable[4]:getChildByName("Text_22"):setString(""..item1.governing)
  if item2.governing > item1.governing then 
    attrTable[4]:getChildByName("Text_23"):setString("+"..(item2.governing-item1.governing)) 
  end 
  attrTable[5]:getChildByName("Text_22"):setString(""..item1.charm)
  if item2.charm > item1.charm then 
    attrTable[5]:getChildByName("Text_23"):setString("+"..(item2.charm-item1.charm))
  end 

  --新增特技 
  local strNewSkill = SmithyData:instance():getRedEquipNewSkillDesc(item1.target_equip) 
  lbSkill:setString(strNewSkill) 

  --材料 
  self:showMatInfo(equipId) 

  --若当前版本未开放或者目标为空则进阶按钮置灰
  self.btnAdvance:setEnabled(item1.target_unlock > 0 and item1.target_equip > 0)

  self.Panel_5:getChildByName("Text_3"):setString(g_tr("officeTuPo"))  
end 


--显示消耗的材料
function SmithyAdvanceLayer:showMatInfo(equipId)
  print("showMatInfo: equipId=", equipId)

  local item1 = g_data.equipment[equipId]

  if nil == item1 then return end 

  self.costSilver = 0 
  self.isMatEnough = true  
  local matCount = 0
  if item1.target_unlock > 0 then 
    for k, v in pairs(item1.consume) do 
      if v[1] == 1 or v[1] == 2 then --材料/装备,表中类型与项目定义的类型有出入,需要转换下
        matCount = matCount + 1 
        if matCount <= 5 then 
          local imgBg = self.nodeMat:getChildByName(string.format("Image_List0%d", matCount))
          local node = self.nodeMat:getChildByName(string.format("Panel_List0%d", matCount))
          imgBg:setVisible(false)
          node:setVisible(true)

          local size = node:getContentSize()
          print("need item_id", v[1], v[2], v[3])

          local ownNum = SmithyData:instance():getOwnMaterialCount(v[1], v[2]) 

          local itype = v[1]==1 and 2 or 4 --类型转换
          local icon
          if itype == 4 then --装备
            icon = require("game.uilayer.common.EquipmentIcon"):create(v[2]) 
          else 
            icon = require("game.uilayer.common.DropItemView").new(itype, v[2], 1) 
          end 
          if icon then 
            icon:setPosition(cc.p(size.width/2, size.height/2))
            icon:setNameVisible(false)
            icon:setCount(string.format("%d/%d", ownNum, v[3]))
            icon:setCountColor((ownNum >= v[3] and g_Consts.ColorType.Green or g_Consts.ColorType.Red))
            node:addChild(icon)
            if ownNum < v[3] then 
              icon:setTag(v[2])
              icon:setTouchEnabled(true)
              self:regBtnCallback(icon, handler(self, self.clickItem))
              self.isMatEnough = false 
            end 
          end 
        end 

      elseif v[1] == 3 then --白银 
        self.costSilver = v[2] 

        local plus1 = 0 
        local plus2 = 0         
        --buff效果
        local allbuffs = g_BuffMode.GetData()
        if allbuffs and allbuffs["silver_reduce"] then
          plus1 = tonumber(allbuffs["silver_reduce"].v)/10000          
        end

        --建筑输出buff
        local allBuilds = g_PlayerBuildMode.GetData()
        for k, v in pairs(allBuilds) do 
          if v.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.smithy then 
            for i, item in pairs(g_data.build[v.build_id].output) do 
              if item[1] == 17 then --白银消耗减少
                -- if g_data.output_type[18].num_type == 1 then --万分比
                plus2 = item[2]/10000  
              end 
            end 
            break 
          end 
        end 

        print("reduce silver buff: plus1, plus2=", plus1, plus2)
        if plus1 > 0 or plus2 > 0 then 
          self.costSilver = math.ceil(self.costSilver * math.max(0, (1 - plus1 - plus2)))
        end 

        self.lbCost:setString(""..self.costSilver)
      end 
    end 
  end 

  for i = matCount + 1, 5 do --多余则隐藏
    self.nodeMat:getChildByName(string.format("Image_List0%d", i)):setVisible(false) 
    self.nodeMat:getChildByName(string.format("Panel_List0%d", i)):setVisible(false) 
  end 
end 

function SmithyAdvanceLayer:clickItem(sender)
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  print("clickItem:", sender:getTag())
  local function closeWin()
    -- self:getDelegate():close()
  end

  local paraTbl 
  if self.nodeEquip1:isVisible() then --武将列表 
    paraTbl = {self.generals[self.curGenIdx].general_id, self.curEquListIdx}
  else 
    paraTbl = sender:getTag() 
  end 
  SmithyData:instance():setBackView(SmithyData.viewType.Advance, paraTbl)

  local iType 
  local configId = sender:getTag() 
  if g_data.item[configId] then 
    iType = g_Consts.DropType.Props
  elseif g_data.equipment[configId] then 
    iType = g_Consts.DropType.Equipment
  end 

  if iType then 
    local view = require("game.uilayer.common.ItemPathView").new(iType, configId, closeWin)
    g_sceneManager.addNodeForUI(view)
  end 
end


function SmithyAdvanceLayer:onstartAdvance() 
  print("onstartAdvance, equId=", self.curEquId) 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self.isPlayingAnim then 
    print("isPlayingAnim...")
    return 
  end 
  
  if nil == self.curEquId then 
    g_airBox.show(g_tr("pls_select_equip1"))
    return 
  end 

  local data = g_PlayerMode.GetData()
  if data.silver < self.costSilver then 
    g_airBox.show(g_tr("no_enough_silver"))
    return 
  end 

  if not self.isMatEnough then 
    g_airBox.show(g_tr("no_enough_material"))
    return 
  end 

  local genId = 0 
  if self.nodeEquip1:isVisible() and self.curGenIdx <= #self.generals then 
    genId = self.generals[self.curGenIdx].general_id 
  end 


  if self.Panel_6:isVisible() then --必须是神武将,其武器才能突破
    if g_data.equipment[self.curEquId].equip_type == 1 then 
      if g_data.general[genId*100+1] and g_data.general[genId*100+1].general_quality < g_GeneralMode.godQuality then 
        g_airBox.show(g_tr("pls_make_gen_to_god"))
        return 
      end 
    end 
  end 


  local function advanceResult(result, data)
    print("equipResult:", result)
    if result then 
      self.isPlayingAnim = true     
      self:playStartAdvancingAnim(self.curEquIcon, function() 
          self:updateView()  
          self.isPlayingAnim = false 
      end )
      
      if self:getDelegate() then 
        self:getDelegate():updatePlayerResource()
      end     
      g_guideManager.execute()   

      SmithyData:updateGenBuff(genId)
      self.isGenAttrDurty = true 
    end 
  end 

  print("=== genid, equId", genId, self.curEquId)
  g_sgHttp.postData("Smithy/levelUp", {generalId=genId, itemId=self.curEquId, materialItemId=0, steps = g_guideManager.getToSaveStepId()}, advanceResult)    
end 

function SmithyAdvanceLayer:createHeroHead(heroId)
  local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)

  local orginal_id = math.floor((heroId-1)/100)
  local general = g_GeneralMode.getOwnedGeneralByOriginalId(orginal_id)
  if general then 
    item:showGeneralServerStarLv(general.star_lv or 0)
  end 
  item:setCountEnabled(false)

  return item
end

function SmithyAdvanceLayer:playStartAdvancingAnim(target, animEndCallback)
  if nil == target then return end 
  
  local size = target:getContentSize()

  local armature , animation
  local function onMovementEventCallFunc2(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()
      if animEndCallback then   
        animEndCallback()
      end 
    end 
  end 

  local function onMovementEventCallFunc1(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()

      --2.播放例子特效
      armature , animation = g_gameTools.LoadCocosAni(
        "anime/TieJiangPu_JinJieBaoFaEffect/TieJiangPu_JinJieBaoFaEffect.ExportJson"
        , "TieJiangPu_JinJieBaoFaEffect"
        , onMovementEventCallFunc2
        --, onFrameEventCallFunc
        )
      armature:setPosition(cc.p(size.width/2, size.height/2))
      target:addChild(armature)
      animation:play("Animation1")
    end
  end 

  --1.播放锤子特效
  armature , animation = g_gameTools.LoadCocosAni(
    "anime/TieJiangPu_JinJieChuiZiEffect/TieJiangPu_JinJieChuiZiEffect.ExportJson"
    , "TieJiangPu_JinJieChuiZiEffect"
    , onMovementEventCallFunc1
    --, onFrameEventCallFunc
    )

  armature:setPosition(cc.p(size.width/2, size.height/2))
  target:addChild(armature)
  animation:play("Animation1")
end 

return  SmithyAdvanceLayer
