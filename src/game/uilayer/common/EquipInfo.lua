
--武将装备详情/换装/强化/卸下
local EquipmentIcon = require("game.uilayer.common.EquipmentIcon")
local EquipInfo = class("EquipInfo",require("game.uilayer.base.BaseLayer"))
local SmithyData = require("game.uilayer.smithy.SmithyData")

--参数： 
--generalId: 武将id (必传)
--equipType: 装备类型(必传) 1:武器, 2:铠甲 3:饰品 4:坐骑
--equipId: 武将身上携带装备id, 如果不传则显示选择界面,否则显示详情box 
function EquipInfo:ctor(generalId, equipType, equipId)
  EquipInfo.super.ctor(self)
  print("EquipInfo:ctor(): generalId, equipType, equipId", generalId, equipType, equipId)
  assert(generalId and generalId > 0, "invalid para: generalId")
  assert(equipType and equipType > 0, "invalid para: equipType")
  self.generalId = generalId 
  self.equipType = equipType 
  if equipId and equipId > 0 then 
    self.generalEquId = equipId 
    self.touchEquId = equipId 
  end 

  --由武将ID获取该武将所有信息
  local allGenData = g_GeneralMode.GetData()
  for k, v in pairs(allGenData) do 
    if v.general_id == generalId then 
      self.genData = v 
      break 
    end 
  end 
  self.isDataDirty = false  
end 

function EquipInfo:onEnter() 
  print("EquipInfo:onEnter") 

  local layer = g_gameTools.LoadCocosUI("equip_info_enhance.csb",5) 
  if layer then 
    self:addChild(layer) 
    local viewSize = cc.Director:getInstance():getWinSize()
    layer:getChildByName("mask"):setContentSize(viewSize)
    self:initBinding(layer:getChildByName("scale_node")) 
  end 

  if self.generalEquId then --显示详情box 
    self:showInfoBox() 
  else 
    self:showSelectList(self.touchEquId) --显示选择界面 
  end 
end 

function EquipInfo:onExit()
  print("EquipInfo:onExit, isDataDirty", self.isDataDirty)
  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end 
  if self.isDataDirty and self.updateFuncWhenExit then 
    self.updateFuncWhenExit()
  end 
end 

function EquipInfo:initBinding(scaleNode)
  --详情box
  self.panelBox = scaleNode:getChildByName("info_box")
  local boxClose = self.panelBox:getChildByName("Button_xhao")
  local boxTitle = self.panelBox:getChildByName("Image_51"):getChildByName("Text_37")
  self.boxInfoNode = self.panelBox:getChildByName("Panel_info")

  --选择强化列表
  self.panelList = scaleNode:getChildByName("info_list") 
  local listClose = self.panelList:getChildByName("Button_xhao") 
  self.listInfoNode = self.panelList:getChildByName("equip_info2") 
  self.listView = self.panelList:getChildByName("Panel_2"):getChildByName("ListView_1")  
  local lbTitle = self.panelList:getChildByName("Text_xinban")

  boxTitle:setString(g_tr("equipment"))
  lbTitle:setString(g_tr("generalEquipment"))
  self:regBtnCallback(boxClose, handler(self, self.close))
  self:regBtnCallback(listClose, handler(self, self.close))


  self.dataLen = 0 
  self.mainIdx = 0 
  self.subIdx = 0
  self.firstLoadMax = 20 --初次最多显示20行,后续滑动列表时手动添加


  --滑动列表逐渐添加
  local function onScrollViewEvent(sender, eventType) 
    if eventType == ccui.ScrollviewEventType.scrolling then
      if self.frameLoadTimer then return end --如果仍在分帧加载中,则返回

      local pos = sender:getInnerContainerPosition() 
      print("pos.y===", pos.y)

      if pos.y > -5 then 
        self:frameLoadList(5) 
      end 
    end 
  end 
  self.listView:addScrollViewEventListener(onScrollViewEvent) 
end 

--显示详情box 
function EquipInfo:showInfoBox()
  self.panelBox:setVisible(true)
  self.panelList:setVisible(false)
  self.boxInfoNode:removeAllChildren()
  local info = self:getInfoNode(true)
  if info then 
    self:updataAttrInfo(self.touchEquId)
    self.boxInfoNode:addChild(info)
  end 
end 

--显示选择界面
function EquipInfo:showSelectList(highlightId)
  print("showSelectList, highlightId", highlightId)

  self.panelBox:setVisible(false)
  self.panelList:setVisible(true)  

  self.listInfoNode:removeAllChildren()
  local info = self:getInfoNode(false)
  if info then 
    self.listInfoNode:addChild(info)
  end 

  --显示装备列表
  self.listView:removeAllChildren()
  self.listView:setScrollBarEnabled(false) 
  self.equipData = self:getEquipData(self.equipType)

  self.mainIdx = 1 
  self.subIdx = 1 
  self.count = 0 
  self.iconBackup = {}  
  self.dataLen = #self.equipData 

  if self.dataLen <= 0 then return end 

  if nil == highlightId then 
    highlightId = self.equipData[1].item_id 
  end 
  self:frameLoadList(self.firstLoadMax, highlightId)
end 

function EquipInfo:frameLoadList(loadLineCount, highlightId)
  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end 

  if self.mainIdx > self.dataLen then return end 

  local lineCount = 0 

  local function onTouchIcon(idx, equId)
    print("onTouchIcon:", idx)
    
    for k, v in pairs(self.iconBackup) do 
      if v:getIsSelected() then 
        v:setIsSelected(false)
      end 
    end 

    self.iconBackup[idx]:setIsSelected(true)
    self.touchEquId = self.iconBackup[idx]:getEquipId() 

    self:updataAttrInfo(self.touchEquId)    
  end

  local function loadOneLineItems()
    if self.mainIdx <= self.dataLen and lineCount < loadLineCount  then 

      local gridSize = 114 
      local layout = ccui.Layout:create() 
      layout:setContentSize(cc.size(gridSize*5, gridSize))
      for i = 1, 5 do 
        if self.mainIdx > self.dataLen then break end 
        if self.subIdx > self.equipData[self.mainIdx].num then 
          self.subIdx = 1
          self.mainIdx = self.mainIdx + 1 

          if self.mainIdx > self.dataLen then break end 
        end 

        local equId = self.equipData[self.mainIdx].item_id
        local icon = EquipmentIcon:create(equId)
        if icon then 
          self.count = self.count + 1 
          icon:setScale(gridSize/icon:getContentSize().width) 
          icon:setPosition(cc.p((i-1)*gridSize+gridSize/2, gridSize/2))
          icon:setIdx(self.count)
          icon:setNameVisible(false) 
          icon:setIsWearing(equId == self.generalEquId and self.subIdx == 1)
          icon:setTouchCallback(onTouchIcon)          
          layout:addChild(icon) 
          self.iconBackup[self.count] = icon 

          --highlight
          if highlightId and highlightId == equId and self.subIdx == 1 then 
            onTouchIcon(self.count)
          end 
          
          self.subIdx = self.subIdx + 1
        end 
      end 
      self.listView:pushBackCustomItem(layout)
      lineCount = lineCount + 1 
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
end 

--返回详情界面
function EquipInfo:getInfoNode(isInfoBox)
  local node = cc.CSLoader:createNode("equip_info.csb") 
  local Panel_1 = node:getChildByName("Panel_1")
  self.infoIconBg = Panel_1:getChildByName("Image_9") 
  self.infoIcon = Panel_1:getChildByName("Panel_equip") 
  local lbWu = Panel_1:getChildByName("Panel_01"):getChildByName("Text_3") 
  local lbZhi = Panel_1:getChildByName("Panel_02"):getChildByName("Text_3") 
  local lbZheng = Panel_1:getChildByName("Panel_03"):getChildByName("Text_3") 
  local lbTong = Panel_1:getChildByName("Panel_04"):getChildByName("Text_3") 
  local lbMei = Panel_1:getChildByName("Panel_05"):getChildByName("Text_3") 

  self.infoAttr = {}
  for i=1, 5 do 
    self.infoAttr[i] = Panel_1:getChildByName(string.format("Panel_0%d", i)):getChildByName("Text_2") 
    self.infoAttr[i]:setString("")
  end 
  self.lbPrefer = Panel_1:getChildByName("skill_prefer") 

  self.infoSkill = Panel_1:getChildByName("skill_desc") 
  self.infoSkillNode = Panel_1:getChildByName("skill_other") 
  self.btnChange = Panel_1:getChildByName("Button_1") 
  self.btnEnhance = Panel_1:getChildByName("Button_2") 
  self.btnUnload = Panel_1:getChildByName("Button_3") 
  local lbChange = self.btnChange:getChildByName("Text_26") 
  local lbEnhance = self.btnEnhance:getChildByName("Text_27") 
  local lbUnload = self.btnUnload:getChildByName("Text_28") 

  lbWu:setString(g_tr("wu"))
  lbZhi:setString(g_tr("zhi"))
  lbZheng:setString(g_tr("zheng"))
  lbTong:setString(g_tr("tong"))
  lbMei:setString(g_tr("mei"))
  self.infoSkill:setString("")
  self.lbPrefer:setString("")

  lbEnhance:setString(g_tr("equipEnhance"))
  lbUnload:setString(g_tr("equipUnload"))
  self:regBtnCallback(self.btnEnhance, handler(self, self.onEnhance))
  self:regBtnCallback(self.btnUnload, handler(self, self.onUnload))

  if isInfoBox then 
    self:regBtnCallback(self.btnChange, handler(self, self.onChange))
    lbChange:setString(g_tr("equipChange"))
  else 
    self:regBtnCallback(self.btnChange, handler(self, self.onSelect))
    lbChange:setString(g_tr("equipLoad"))
  end 

  if self.equipType == 1 then --武器不允许换装和卸下
    self.btnChange:setEnabled(false)
    self.btnUnload:setEnabled(false)
    self.btnChange:setVisible(false)
    self.btnUnload:setVisible(false)
  end 

  --如果铁匠铺未建造,则不允许进阶
  local buildInfo = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.smithy)
  if nil == buildInfo or nil == buildInfo[1] then 
    self.btnEnhance:setEnabled(false)
  end 

  return node 
end 

--更新装备信息
function EquipInfo:updataAttrInfo(equipId)
  print("updataAttrInfo, gen_equid, equipId=", self.generalEquId, equipId)

  self.infoIcon:removeAllChildren()
  self.infoSkillNode:removeAllChildren()
  local baseInfo
  if equipId then 
    baseInfo = g_data.equipment[equipId]
  end 

  --进阶按钮状态
  if nil == baseInfo or baseInfo.target_unlock == 0 or baseInfo.target_equip <= 0 then 
    self.btnEnhance:setEnabled(false)
  else 
    self.btnEnhance:setEnabled(true)
  end 

  if baseInfo and baseInfo.quality_id == 5 and baseInfo.star_level == 5 then 
    self.btnEnhance:getChildByName("Text_27"):setString(g_tr("officeTuPo"))
  else 
    self.btnEnhance:getChildByName("Text_27"):setString(g_tr("equipEnhance"))
  end 



  if baseInfo then 
    --基础属性
    self.infoAttr[1]:setString(string.format("%d", baseInfo.force))
    self.infoAttr[2]:setString(string.format("%d", baseInfo.intelligence))
    self.infoAttr[3]:setString(string.format("%d", baseInfo.political))
    self.infoAttr[4]:setString(string.format("%d", baseInfo.governing))
    self.infoAttr[5]:setString(string.format("%d", baseInfo.charm))

    --图标 
    local icon = EquipmentIcon:create(equipId)
    if icon then 
      icon:setPosition(cc.p(icon:getContentSize().width/2, icon:getContentSize().height/2))
      self.infoIcon:addChild(icon) 
    end 
    self.infoIconBg:setVisible(nil == icon)

    --技能描述
    local newLabel
    local count = 0 
    self.infoSkill:setString("") 
    self.infoSkillNode:setPosition(cc.p(self.infoSkill:getPosition()))
    self.lbPrefer:setString("") 
    local len = #baseInfo.equip_skill_id 
    for i=len, 1, -1 do 
      if i > 1 then 
        newLabel = self.infoSkill:clone()
        newLabel:setPosition(cc.p(0, -(i-1)*36))
        self.infoSkillNode:addChild(newLabel)
      else 
        newLabel = self.infoSkill 
      end 

      local skill = g_data.equip_skill[baseInfo.equip_skill_id[i]]
      if skill then 
        local buff = g_data.buff[skill.skill_buff_id[1]]
        if buff then 
          local strNum = ""..skill.num
          if buff.buff_type == 1 then --万分比
            strNum = (skill.num/100) .. "%%"
          end 
          newLabel:setString(g_tr(skill.skill_description, {num = strNum}))
        end 
        
        if i == len then 
          if baseInfo.equip_type == 2 and self.genData then --防具时显示武器对应的描述            
            print("weapon_id", self.genData.weapon_id)
            local weaponItem = g_data.equipment[self.genData.weapon_id]
            if weaponItem then 
              local weaponSkill = g_data.equip_skill[weaponItem.equip_skill_id[1]]
              if weaponSkill and weaponSkill.equip_arm_description > 0 then 
                self.lbPrefer:setString(g_tr("equipPerfer") .. g_tr(weaponSkill.equip_arm_description)) 
                local y = self.infoSkillNode:getPositionY() - i*36
                if self.lbPrefer:getPositionY() > y then 
                  self.lbPrefer:setPositionY(y-36) 
                end 
              end 
            end 
          elseif baseInfo.equip_type == 3 then --饰品显示固定描述
            self.lbPrefer:setString(g_tr("equipPerfer_2"))
          end 
        end 
      end 
    end 

    --红色装备新增一条技能
    if baseInfo.quality_id >= 6 then 
      local str = SmithyData:instance():getRedEquipNewSkillDesc(baseInfo.id) 
      local label = self.infoSkill:clone()
      label:setPosition(cc.p(0, -len*36))
      label:setString(str)
      self.infoSkillNode:addChild(label) 
    end     


    if self.panelList:isVisible() then 
      self.btnChange:setEnabled(self.equipType > 1 and equipId ~= self.generalEquId)
    end 
    self.btnUnload:setEnabled(self.equipType > 1 and (equipId == self.generalEquId))
  else 
    for i=1, 5 do 
      self.infoAttr[i]:setString("")
    end 
    self.infoSkill:setString("")
  end 
end 



--换装
function EquipInfo:onChange()
  print("onChange")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  self:showSelectList()
end 

--给武将佩戴装备
function EquipInfo:onSelect()
  print("onSelect")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if nil == self.touchEquId or 0 == self.touchEquId then 
    g_airBox.show(g_tr("equipNotSelected"))    
    return 
  end 

  local function equipResult(result, data) 
    print("equipResult:", result) 
    if result then  
      self.generalEquId = self.touchEquId 
      self.btnChange:setEnabled(false)
      self.btnUnload:setEnabled(true) 

      SmithyData:updateGenBuff(self.generalId)
      self.isDataDirty = true  
      self:close()  
    end 
  end 

  local equType = g_data.equipment[self.touchEquId].equip_type 
  g_sgHttp.postData("General/equip", {generalId=self.generalId, itemId=self.touchEquId, type=equType}, equipResult)  
end 

--强化装备
function EquipInfo:onEnhance() 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  print("onEnhance:touchEquId, genEquId", self.touchEquId, self.generalEquId) 

  local paraTbl = self.touchEquId 

  local item = g_data.equipment[self.touchEquId]
  if nil == item or item.target_unlock == 0 or item.target_equip <= 0 then 
    return  
  end 

  if self.touchEquId == self.generalEquId then 
    paraTbl = {self.generalId, self.equipType}
  end 

  --铁匠铺：进阶
  g_sceneManager.addNodeForUI(require("game.uilayer.smithy.SmithyBaseLayer").new(SmithyData.viewType.Advance, paraTbl)) 

  self:close()
end 


--卸下装备
function EquipInfo:onUnload()
  print("onUnload")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if nil == self.generalId or 0 == self.generalId then 
    print("no general equip id")  
    return 
  end 

  local function unloadResult(result, data) 
    print("unloadResult:", result) 
    if result then  
      self.generalEquId = nil 
      self.btnChange:setEnabled(true)
      self.btnUnload:setEnabled(false)  
      -- self.btnEnhance:setEnabled(false)  

      if self.panelBox:isVisible() then --详情box界面
        self:updataAttrInfo()
      end 
      SmithyData:updateGenBuff(self.generalId)
      self.isDataDirty = true 
      self:close() 
    end 
  end 

  g_sgHttp.postData("General/equip", {generalId=self.generalId, itemId=0, type=self.equipType}, unloadResult)  
end 

--设置回调供退出当前界面时更新外部界面
function EquipInfo:setUpdateFuncWhenExit(callback)
  self.updateFuncWhenExit = callback 
end 


--根据装备类型返回相同类型的装备, 并排序, 当前佩戴装备排在前面 
function EquipInfo:getEquipData(equipType)
  local tbl = {}

  --空闲装备
  local allEquips = g_EquipmentlMode.getIdleEquipsByType(equipType)
  --

  SmithyData:sortEquipByQualityAndId(allEquips)


  local genEqu 
  for k, v in pairs(allEquips) do 
    if v.item_id == self.generalEquId then --如果武将佩戴有装备，则排在前面 
      --table.insert(tbl, 1, v)
      genEqu = v 
    else 
      table.insert(tbl, v)
    end 
  end 

  if self.generalEquId then  
    if nil == genEqu then 
      genEqu = {item_id = self.generalEquId, num = 1}
    end 
    table.insert(tbl, 1, genEqu)
  end 

  return tbl 
end 



return EquipInfo 
