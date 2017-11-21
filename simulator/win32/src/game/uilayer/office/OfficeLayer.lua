

local OfficeLayer = class("OfficeLayer",require("game.uilayer.base.BaseLayer"))
local SmithyData = require("game.uilayer.smithy.SmithyData")

--generalId：进入界面默认高亮的武将完整id 
function OfficeLayer:ctor(generalId)
  OfficeLayer.super.ctor(self)
  print("OfficeLayer:ctor")
  self.entryGenId = generalId 
  self.curTabIndex = 1 
end 

function OfficeLayer:onEnter()
  print("OfficeLayer:onEnter")
  local layer = g_gameTools.LoadCocosUI("guangfu1.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showGeneralList()
  end 
  g_gameCommon.addEventHandler(g_Consts.CustomEvent.UpdateGenAttr, OfficeLayer.updateEquipUI, self)
end 

function OfficeLayer:onExit()
  print("OfficeLayer:onExit")
  self:stopAllActions()
  g_gameCommon.removeAllEventHandlers(self)
end 

function OfficeLayer:initBinding(scaleNode)
  self.scaleNode = scaleNode 

  local btnClose = scaleNode:getChildByName("Button_close")
  local lbTitle = scaleNode:getChildByName("Text_title")
  local nodeList = scaleNode:getChildByName("Panel_gen_list")
  local lbpreCount = nodeList:getChildByName("Image_20"):getChildByName("Text_wujiangshu") 
  self.lbCount = nodeList:getChildByName("Image_20"):getChildByName("Text_wujiangshu_0")
  self.listview = nodeList:getChildByName("ListView_1")

  lbTitle:setString(g_tr("officialTitle"))
  lbpreCount:setString(g_tr("generalsCount"))
  self.lbCount:setString("")

  --装备
  local nodeEqu = scaleNode:getChildByName("Panel_2"):getChildByName("Panel_6")
  local btnWeaponAdd = nodeEqu:getChildByName("Panel_1") 
  local btnArmorAdd = nodeEqu:getChildByName("Panel_2") 
  local btnAccessoryAdd = nodeEqu:getChildByName("Panel_3") 
  local btnRiderAdd = nodeEqu:getChildByName("Panel_4") 
  self.equipInfo = {btnWeaponAdd, btnArmorAdd, btnAccessoryAdd, btnRiderAdd}


  self:regBtnCallback(btnClose, handler(self, self.close))
  self:regBtnCallback(btnWeaponAdd, handler(self, self.onAddWeapon)) 
  self:regBtnCallback(btnArmorAdd, handler(self, self.onAddArmor))
  self:regBtnCallback(btnAccessoryAdd, handler(self, self.onAddAccessory))
  self:regBtnCallback(btnRiderAdd, handler(self, self.onAddRider)) 

  --属性tab页
  local nodeAttr = scaleNode:getChildByName("Panel_tab_attr")
  local btnAttrBase = nodeAttr:getChildByName("Button_aa1")
  local btnAttrGod = nodeAttr:getChildByName("Button_aa2")
  btnAttrBase:getChildByName("Text_5"):setString(g_tr("officialBaseAttr"))
  btnAttrGod:getChildByName("Text_5"):setString(g_tr("officialGodAttr"))
  self:regBtnCallback(btnAttrBase, handler(self, self.onAttrBase)) 
  self:regBtnCallback(btnAttrGod, handler(self, self.onAttrGod)) 

  local tab2 = nodeAttr:getChildByName("tab_2")
  for i = 1, 3 do 
    local suo = tab2:getChildByName("Panel_god_skill1"):getChildByName(string.format("Image_%d_0", i)) 
    local wenhao = tab2:getChildByName("Panel_god_skill1"):getChildByName(string.format("Image_%d_1", i)) 
    suo:addClickEventListener(function() 
      g_airBox.show(g_tr("officialUnlockTips", {lv = i+1}))          
      end) 

    wenhao:addClickEventListener(function() 
      g_airBox.show(g_tr("getSkillTips")) 
      end)     
  end 

  --4.前去培养
  local btnGoto = nodeAttr:getChildByName("tab_2"):getChildByName("Button_qw")
  btnGoto:getChildByName("Text_name_0"):setString(g_tr("gotoEnhance"))
  self:regBtnCallback(btnGoto, handler(self, self.onGodGenEnhance)) 
end 


function OfficeLayer:updateEquipUI()
  print("===updateUI")
  self.generalData = g_GeneralMode.GetData()
  self:updateGeneralInfo(self.touchIndex)
end 

function OfficeLayer:onAddWeapon()
  print("onAddWeapon")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local general = self.generalData[self.touchIndex]
  if general then 
    local layer = require("game.uilayer.common.EquipInfo").new(general.general_id, 1, general.weapon_id)
    layer:setUpdateFuncWhenExit(handler(self, self.updateEquipUI))
    g_sceneManager.addNodeForUI(layer)
  end 
end 

function OfficeLayer:onAddArmor()
  print("onAddArmor")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local general = self.generalData[self.touchIndex]
  if general then 
    if general.armor_id == 0 then --武将未佩戴而且没有同类型空闲装备时则提示用户
      local armor = g_EquipmentlMode.getIdleEquipsByType(2)
      if #armor == 0 then 
        g_airBox.show(g_tr("equpResTips"))
        return 
      end  
    end 

    local layer = require("game.uilayer.common.EquipInfo").new(general.general_id, 2, general.armor_id)
    layer:setUpdateFuncWhenExit(handler(self, self.updateEquipUI))
    g_sceneManager.addNodeForUI(layer)
  end   
end 

function OfficeLayer:onAddAccessory()
  print("onAddAccessory")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local general = self.generalData[self.touchIndex]
  if general then 
    if general.horse_id == 0 then 
      local acce = g_EquipmentlMode.getIdleEquipsByType(3)
      if #acce == 0 then 
        g_airBox.show(g_tr("equpResTips"))
        return 
      end 
    end 

    local layer = require("game.uilayer.common.EquipInfo").new(general.general_id, 3, general.horse_id)
    layer:setUpdateFuncWhenExit(handler(self, self.updateEquipUI))
    g_sceneManager.addNodeForUI(layer)
  end    
end 

function OfficeLayer:onAddRider()
  print("onAddRider")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local general = self.generalData[self.touchIndex]
  if general then 
    if general.zuoji_id == 0 then 
      local acce = g_EquipmentlMode.getIdleEquipsByType(4)
      if #acce == 0 then 
        g_airBox.show(g_tr("equpResTips2"))
        return 
      end 
    end 

    local layer = require("game.uilayer.common.EquipInfo").new(general.general_id, 4, general.zuoji_id)
    layer:setUpdateFuncWhenExit(handler(self, self.updateEquipUI))
    g_sceneManager.addNodeForUI(layer)
  end    
end 

function OfficeLayer:onGodGenEnhance()
  print("onGodGenEnhance")
  local general = self.generalData[self.touchIndex]
  local baseInfo = g_data.general[100*general.general_id+1]
  if baseInfo and baseInfo.general_quality == g_GeneralMode.godQuality then --神武将
    local layer = require("game.uilayer.godGeneral.GodGeneralEnhance"):create(general.general_id, handler(self, self.updateEquipUI))
    g_sceneManager.addNodeForUI(layer) 
    -- self:close() 
  end 
end 

function OfficeLayer:onAttrBase()
  print("onAttrBase") 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  self.curTabIndex = 1 

  local nodeAttr = self.scaleNode:getChildByName("Panel_tab_attr") 
  local btnAttrBase = nodeAttr:getChildByName("Button_aa1")
  local btnAttrGod = nodeAttr:getChildByName("Button_aa2")
  btnAttrBase:setHighlighted(true)
  btnAttrGod:setHighlighted(false)  

  local general = self.generalData[self.touchIndex]
  self:updateCommonAttr(general)  
end 

function OfficeLayer:onAttrGod()
  print("onAttrGod") 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  self.curTabIndex = 2 

  local nodeAttr = self.scaleNode:getChildByName("Panel_tab_attr") 
  local btnAttrBase = nodeAttr:getChildByName("Button_aa1")
  local btnAttrGod = nodeAttr:getChildByName("Button_aa2")  
  btnAttrBase:setHighlighted(false)
  btnAttrGod:setHighlighted(true)

  local general = self.generalData[self.touchIndex]
  self:updateGodAttr(general)  
end 

function OfficeLayer:showGeneralList()
  local function highlightItem(index)
    local item, scaleNode, img 
    for k, v in pairs(self.listview:getItems()) do 
      scaleNode = v:getChildByName("scale_node")
      if scaleNode then 
        img = scaleNode:getChildByName("Image_2")
        if img then 
          img:setVisible(index == k-1)
        end 
      end 
    end 
  end 

  local function onSelectItem(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then 
      local index = sender:getCurSelectedIndex()+1
      print("=== select list index:", index)
      if self.touchIndex ~= index then 
        self.touchIndex = index 
        highlightItem(index-1)
        self:updateGeneralInfo(index)
      end 
    end 
  end 

  local function onBtnClick(sender,eventType) 
    if eventType == ccui.TouchEventType.ended then 
      local general = self.generalData[sender:getTag()]
      dump(general, "onBtnClick")
      self:playLevelupAnim(general)
    end 
  end 

  --load items 
  local GeneralListItem = cc.CSLoader:createNode("guanfu_wujiang.csb") 
  local scaleNode = GeneralListItem:getChildByName("scale_node")
  local imgHead = scaleNode:getChildByName("icon")  
  local lbName = scaleNode:getChildByName("Image_31"):getChildByName("Text_mingzi")
  local lblZhu = scaleNode:getChildByName("Image_3"):getChildByName("Text_29")
  scaleNode:getChildByName("Image_2"):setVisible(false)

  lblZhu:setString(g_tr("grarrisTitle"))
  self.imgZhu = scaleNode:getChildByName("Image_3")
  self.Text_1 = scaleNode:getChildByName("Text_1")

  self.listview:setScrollBarPositionFromCorner(cc.p(7, 2))
  self.listview:addEventListener(onSelectItem)
  self.listview:setItemModel(GeneralListItem)

  self.generalData = g_GeneralMode.GetData() --武将数据
  self.armyData = g_ArmyMode.GetData() --军团信息

  local player = g_PlayerMode.GetData()
  local maxNum = require("game.gamedata.PlayerPub").getMaxGeneralToRecruit()
  self.lbCount:setString(string.format("%d/%d", #self.generalData, maxNum))

  self.touchIndex = 1 
  if self.entryGenId then 
    for k, v in pairs(self.generalData) do 
      if 100*v.general_id + 1 == self.entryGenId then 
        self.touchIndex = k 
        break 
      end 
    end 
    self.entryGenId = nil 
  end 
  self:updateGeneralInfo(self.touchIndex)


  --分帧加载武将列表
  local idx_s = 1 
  local idx_e = #self.generalData 
  local function loadGeneralItem()
    if idx_s <= idx_e then  
      local v = self.generalData[idx_s]
      local id = v.general_id*100 + 1
      local baseInfo = g_data.general[id]
      lbName:setString(g_tr(baseInfo.general_name))
      imgHead:removeAllChildren()
      local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, id, 1)
      icon:setCountEnabled(false)
      if baseInfo.general_quality == g_GeneralMode.godQuality then 
        icon:showGeneralStarLv(math.floor(v.star_lv/5)+1)
      end 
      icon:setPosition(imgHead:getContentSize().width/2, imgHead:getContentSize().height/2)
      imgHead:addChild(icon)
      icon:setScale(imgHead:getContentSize().width/icon:getContentSize().width)
      self.imgZhu:setVisible(v.build_id ~= 0)
      if v.army_id ~= 0 and self.armyData[v.army_id..""] then
        self.Text_1:setString(g_tr("corp")..g_tr("num"..self.armyData[v.army_id..""].position))
      else
        self.Text_1:setString("")
      end 
      self.listview:pushBackDefaultItem()
      
      if idx_s == self.touchIndex then 
        highlightItem(self.touchIndex-1)      
      end 
      idx_s = idx_s + 1 
    else 
      --加载完成
      if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
      end 

      if self.touchIndex > 3 then 
        self.listview:forceDoLayout() 
        self.listview:jumpToPercentVertical(100*self.touchIndex/idx_e) 
      end       
    end 
  end 

  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end 
  self.frameLoadTimer = self:schedule(loadGeneralItem, 0) 
end 


--普通属性
function OfficeLayer:updateCommonAttr(general)
  local Panel_attr = self.scaleNode:getChildByName("Panel_tab_attr")
  local attr_common = Panel_attr:getChildByName("tab_1") 
  local attr_god = Panel_attr:getChildByName("tab_2") 
  attr_common:setVisible(true)
  attr_god:setVisible(false)

  attr_common:getChildByName("Text_s1"):setString(g_tr("baseInfo"))

  local baseInfo = general and g_data.general[100*general.general_id+1] or nil 

  --1.军团
  attr_common:getChildByName("Text_juntuan1"):setString(g_tr("myCorp"))
  local lbJuntuan = attr_common:getChildByName("Text_juntuan2") 
  if general then 
    -- dump(general, "general")
    -- dump(self.armyData, "self.armyData")

    local str = ""
    if general.army_id == 0 then 
      str = g_tr("standby") 
    else 
      if self.armyData[general.army_id..""] then 
        str = g_tr("corp")..g_tr("num"..self.armyData[general.army_id..""].position)
      end 
    end 
    lbJuntuan:setString(str) 
  else 
    lbJuntuan:setString("")
  end 

  --2.驻守
  attr_common:getChildByName("Text_zhushou1"):setString(g_tr("grarrisTitle"))
  local lbZhushou = attr_common:getChildByName("Text_zhushou2")  
  if general then 
    lbZhushou:setString(g_tr("none"))
    if general.build_id > 0 then 
      local buildInfos = g_PlayerBuildMode.GetData() 
      if buildInfos then 
        for k, v in pairs(buildInfos) do 
          if v.id == general.build_id then  
            if g_data.build[v.build_id] then 
              lbZhushou:setString(g_tr(g_data.build[v.build_id].build_name))
            end 
          end 
        end 
      end 
    end 
  else 
    lbZhushou:setString("")
  end 

  --3.武将属性
    --["attr1"] = "武",
    --["attr2"] = "智",
    --["attr3"] = "统",
    --["attr4"] = "魅",
    --["attr5"] = "政",
  local strTips = {g_tr("wuInfo"), g_tr("zhiInfo"), g_tr("tongInfo"), g_tr("meiInfo"), g_tr("zhengInfo")}
  local baseproperty = g_GeneralMode.getGeneralPropertyByGeneralId(general.general_id) 
  local allProperty = g_GeneralMode.getAllGeneralPropertyByGeneralId(general.general_id) 
  local tmp, lbBase, lbExtra 
  for i = 1, 5 do 
    tmp = attr_common:getChildByName(string.format("Panel_0%d", i))
    tmp:getChildByName("Text_01"):setString(g_tr("attr"..i))
    g_itemTips.tipStr(tmp:getChildByName("Image_1"), g_tr("attr"..i), strTips[i])

    lbBase = tmp:getChildByName("Text_1") 
    lbExtra = tmp:getChildByName("Text_2") 
    lbBase:setString(""..baseproperty[i]) 
    lbExtra:setString("+"..allProperty[i]-baseproperty[i]) 
    lbExtra:setPositionX(lbBase:getPositionX()+lbBase:getContentSize().width+2) 
  end 

  --4.装备特技
  local panel_skill = attr_common:getChildByName("Panel_skill")
  panel_skill:getChildByName("text_skill"):setString(g_tr("equipScience"))

  local skillCount = 0 
  local qualityColor = {cc.c3b(255, 255, 255), cc.c3b(72, 255, 98),cc.c3b(22, 155, 209),cc.c3b(167, 85, 230),cc.c3b(255, 126, 0),cc.c3b(255, 126, 0), cc.c3b(255, 126, 0)}

  local listView = panel_skill:getChildByName("ListView_2")
  listView:removeAllChildren()
  if nil == baseInfo then return end 

  local function addNewSkillListItem(iconIndex, subCount, str, strColor)
    local pic = panel_skill:getChildByName("Image_"..iconIndex)
    local node = ccui.Widget:create() 
    node:setContentSize(cc.size(listView:getContentSize().width, pic:getContentSize().height+6)) 
    if subCount == 0 then --显示装备类型icon 
      local picNew = pic:clone()
      picNew:setVisible(true)
      picNew:setPosition(cc.p(pic:getContentSize().width/2+6, node:getContentSize().height/2))
      node:addChild(picNew)
    end 

    local lbSkill = panel_skill:getChildByName("Text_skill_1"):clone()
    lbSkill:setVisible(true) 
    lbSkill:setPosition(cc.p(pic:getContentSize().width+16, node:getContentSize().height/2))
    lbSkill:setString(str)
    lbSkill:setTextColor(strColor)
    node:addChild(lbSkill) 
    listView:pushBackCustomItem(node) 
  end 

  local equId = {general.weapon_id, general.armor_id, general.horse_id, general.zuoji_id}
  local iconNum = baseInfo.general_quality >= g_GeneralMode.godQuality and 4 or 3 


  for i = 1, iconNum do 
    local subCounts = 0 

    --设置技能文字
    if equId[i] > 0 then 
      local item = g_data.equipment[equId[i]]
      if item then 
        for k, id in pairs(item.equip_skill_id) do 
          local skill = g_data.equip_skill[id]
          if skill then 
            local buff = g_data.buff[skill.skill_buff_id[1]]
            if buff then 
              local strNum = ""..skill.num
              if buff.buff_type == 1 then --万分比
                strNum = (skill.num/100) .. "%%"
              end 
              
              addNewSkillListItem(i, subCounts, g_tr(skill.skill_description, {num = strNum}), qualityColor[item.quality_id])
              subCounts = subCounts + 1            
            end 
          end 
        end

        --红色装备新增一条技能
        if item.quality_id >= 6 then 
          local str = SmithyData:instance():getRedEquipNewSkillDesc(item.id) 
          addNewSkillListItem(i, subCounts, str, qualityColor[item.quality_id])
          subCounts = subCounts + 1 
        end 
      end 

    else 
      addNewSkillListItem(i, subCounts, g_tr("none"), cc.c3b(255, 255, 255))
    end 
  end 

  --将模板隐藏
  panel_skill:getChildByName("Text_skill_1"):setVisible(false)
  for i=1, 4 do 
    panel_skill:getChildByName("Image_"..i):setVisible(false)
  end 


  --5.天赋
  attr_common:getChildByName("Panel_tf"):getChildByName("text_skill"):setString(g_tr("talent"))
  local talentStr = ""
  local talentTips = ""
  if baseInfo then 
    g_custom_loadFunc("GenTalentVal", "(star)", " return "..baseInfo.general_talent_value_client)
    local val = externFunctionGenTalentVal(general.star_lv) 
    talentStr = g_tr(baseInfo.general_talent_description, {num = val})
    if baseInfo.general_quality == g_GeneralMode.godQuality then --神武将
      talentTips = g_tr("officialSkillupTips")
    end     
  end 
  attr_common:getChildByName("Panel_tf"):getChildByName("text_skill_tips"):setString(talentTips)

  if nil == self.tallentRichText then 
    local label = attr_common:getChildByName("Panel_tf"):getChildByName("Text_skill_1") 
    self.tallentRichText = g_gameTools.createRichText(label, talentStr) 
  else 
    self.tallentRichText:setRichText(talentStr)
  end 
end 




--神武将属性
function OfficeLayer:updateGodAttr(general)
  local Panel_attr = self.scaleNode:getChildByName("Panel_tab_attr")
  local attr_common = Panel_attr:getChildByName("tab_1") 
  local attr_god = Panel_attr:getChildByName("tab_2") 
  attr_common:setVisible(false)
  attr_god:setVisible(true)

  local nodeBase = attr_god:getChildByName("shuxin_jc")
  nodeBase:getChildByName("Text_s1"):setString(g_tr("baseInfo"))
  nodeBase:getChildByName("Text_dj1"):setString(g_tr("level"))

  --1.基本信息
  local function showGenStar(num)
    for i=1, 4 do 
      nodeBase:getChildByName("Image_xx"..(2*i-1)):setVisible( i>num )
      nodeBase:getChildByName("Image_xx"..(2*i)):setVisible( i<= num)
    end 
  end 

  local baseInfo = general and g_data.general[100*general.general_id+1] or nil 
  if nil == baseInfo then 
    nodeBase:getChildByName("Text_dj2"):setString("")
    nodeBase:getChildByName("Text_dj3"):setString("")
    nodeBase:getChildByName("LoadingBar_1"):setPercent(0)
    showGenStar(0)
  else 
    nodeBase:getChildByName("Text_dj2"):setString(""..general.lv)
    local cfg1 = g_data.general_exp[general.lv]
    local cfg2 = g_data.general_exp[general.lv+1]
    local percent = 100 
    if cfg2 then 
      percent = 100* (general.exp - cfg1.general_exp)/(cfg2.general_exp - cfg1.general_exp)
    end 
    nodeBase:getChildByName("LoadingBar_1"):setPercent(percent)
    nodeBase:getChildByName("Text_dj3"):setString(string.format("%d%%", percent))

    showGenStar(math.floor(general.star_lv/5) + 1)
  end 

  --2.神技能
  local genSkillLv = g_GeneralMode.getGenSkillLv(general) 
  local godSkill = attr_god:getChildByName("Panel_god_skill")
  godSkill:getChildByName("text_skill"):setString(g_tr("god_skill"))
  if baseInfo and baseInfo.skill_icon and baseInfo.skill_icon > 0 then 
    local pig_bg = godSkill:getChildByName("Image_1_0") 
    local skillBorderRes = require("game.uilayer.godGeneral.GodGeneralMode"):instance():getSkillBorderRes(genSkillLv)
    pig_bg:loadTexture( skillBorderRes )

    local pic = godSkill:getChildByName("Image_1")
    pic:loadTexture(g_resManager.getResPath(baseInfo.skill_icon))
    godSkill:getChildByName("Text_lv"):setString("Lv"..genSkillLv)

    local skill = g_data.duel_skill[baseInfo.general_duel_skill] 
    local str = skill and g_tr(skill.skill_name) or "" 
    godSkill:getChildByName("Text_nr1"):setString(str) 

    g_itemTips.tipGodGeneralData(pic, baseInfo) 
  end 

  --3.城战技能
  local nodeBattSkill = attr_god:getChildByName("Panel_god_skill1")
  nodeBattSkill:getChildByName("text_skill"):setString(g_tr("officialBattleSkill"))
  if general then 
    local tbl_id = {general.cross_skill_id_1, general.cross_skill_id_2, general.cross_skill_id_3}
    -- local tbl_lv = {general.cross_skill_lv_1, general.cross_skill_lv_2, general.cross_skill_lv_3}
    local starLevel = math.floor(general.star_lv/5) + 1 
    local pic, lbLevel, lbName, suo, wenhao
    for i = 1, 3 do 
      pic = nodeBattSkill:getChildByName("Image_"..i) 
      lbLevel = nodeBattSkill:getChildByName("Text_lv"..i) 
      lbName = nodeBattSkill:getChildByName("Text_nr"..i) 
      suo = nodeBattSkill:getChildByName(string.format("Image_%d_0", i)) 
      wenhao = nodeBattSkill:getChildByName(string.format("Image_%d_1", i)) 
      if starLevel >= i+1 then --已解锁
        if tbl_id[i] and tbl_id[i] > 0 and g_data.battle_skill[tbl_id[i]] then 
          pic:loadTexture(g_resManager.getResPath(g_data.battle_skill[tbl_id[i]].skill_res)) 
          lbLevel:setString("Lv"..g_GeneralMode.getGenBattleSkillLv(general, i))
          lbName:setString(g_tr(g_data.battle_skill[tbl_id[i]].skill_name))
          suo:setVisible(false) 
          wenhao:setVisible(false) 

          g_itemTips.tipGeneralBattleSkill(pic,general, i)
        else 
          suo:setVisible(false) 
          wenhao:setVisible(true) 
          lbLevel:setString("") 
          lbName:setString(g_tr("hasNoSkill")) 
        end 
      else 
        suo:setVisible(true) 
        wenhao:setVisible(false) 
        lbLevel:setString("") 
        lbName:setString(g_tr("officialUnlock", {lv = i+1}))  
      end 
    end 
  end 
end 

--更新武将信息
function OfficeLayer:updateGeneralInfo(idx)
  idx = idx or self.touchIndex 
  print("updateGeneralInfo, idx", idx) 

  if nil == idx then return end 

  local general = self.generalData[idx]
  local baseInfo = general and g_data.general[100*general.general_id+1] or nil 

  --1.武将/神武将名字,头像
  local function dispGenNameInfo(baseInfo) 
    local nodeName = self.scaleNode:getChildByName("Panel_2"):getChildByName("Panel_name")
    nodeName:setVisible(nil ~= baseInfo)

    if nodeName:isVisible() then 
      nodeName:getChildByName("Text_name"):setString(g_tr(baseInfo.general_name))
      nodeName:getChildByName("Image_name1"):setVisible(baseInfo.general_quality == g_GeneralMode.godQuality)
      nodeName:getChildByName("Image_name2"):setVisible(baseInfo.general_quality < g_GeneralMode.godQuality)
    end 
  end 

  local Panel_2 = self.scaleNode:getChildByName("Panel_2")
  local imgGenBg = Panel_2:getChildByName("Image_gen_bg")
  local imgGen = Panel_2:getChildByName("Image_gen")
  local imgGenFg = Panel_2:getChildByName("Image_gen_fg")
  if baseInfo then 
    imgGenBg:loadTexture(g_resManager.getResPath(1005000 + baseInfo.general_quality))--背景
    imgGenFg:loadTexture(g_resManager.getResPath(1005100 + baseInfo.general_quality))--边框
    imgGen:loadTexture(g_resManager.getResPath(baseInfo.general_big_icon))
  end 
  dispGenNameInfo(baseInfo)

  --2.装备icon位置(神武将有4个装备)
  if baseInfo then 
    local nodeEqu = Panel_2:getChildByName("Panel_6")
    local equId = {general.weapon_id, general.armor_id, general.horse_id, general.zuoji_id}

    local iconNum = baseInfo.general_quality >= g_GeneralMode.godQuality and 4 or 3 
    nodeEqu:getChildByName("Panel_4"):setVisible(iconNum == 4)

    local EquipmentIcon = require("game.uilayer.common.EquipmentIcon")
    local node, icon, size, canAdv 
    for i=1, iconNum do 
      self.equipInfo[i]:getChildByName("Image_0"):setVisible(equId[i] == 0)
      node = self.equipInfo[i]:getChildByName("Image_1")
      size = node:getContentSize()
      node:removeAllChildren()

      if equId[i] > 0 then 
        print("equId[i]", equId[i])
        item = g_data.equipment[equId[i]]
        if item then 
          icon = EquipmentIcon:create(equId[i])
          if icon then 
            icon:setScale(size.width/icon:getIconSize().width)
            icon:setPosition(cc.p(size.width/2, size.height/2))
            icon:setNameVisible(true) 
            -- icon:setNameInRegion(false)
            node:addChild(icon)
            canAdv = SmithyData:instance():canEquipmentAdvanced(equId[i])
            icon:setAdvancedImgVisible(canAdv)
          end 
        else 
          g_airBox.show(string.format("无效装备id %d", equId[i]))
        end 
      else 
        --可装备时动画提示
        local tbl = g_EquipmentlMode.getIdleEquipsByType(i)
        if #tbl > 0 then 
          local projName = "Effect_ZhuChengZengYiKuang"
          local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_ZhuChengZengYiKuang/Effect_ZhuChengZengYiKuang.ExportJson", "Effect_ZhuChengZengYiKuang")
          if armature then 
            armature:setPosition(cc.p(size.width/2, size.height/2))
            node:addChild(armature)
            animation:play("Animation1")
          end 
        end 
      end 
    end 
  end 

  --3.显示属性
  local nodeAttr = self.scaleNode:getChildByName("Panel_tab_attr") 
  local btnAttrBase = nodeAttr:getChildByName("Button_aa1")
  local btnAttrGod = nodeAttr:getChildByName("Button_aa2")
  local tab2 = nodeAttr:getChildByName("tab_2")
  if baseInfo and baseInfo.general_quality == g_GeneralMode.godQuality then --神武将显示两个tab页,其他只显示一个
    btnAttrGod:setVisible(true)
    tab2:setVisible(true)
  else 
    btnAttrGod:setVisible(false)
    tab2:setVisible(false) 
    self.curTabIndex = 1 
  end 

  btnAttrBase:setHighlighted(self.curTabIndex == 1)
  btnAttrGod:setHighlighted(self.curTabIndex == 2) 
  if self.curTabIndex == 1 then  
    self:updateCommonAttr(general)
  else 
    self:updateGodAttr(general) 
  end 
end 


function OfficeLayer:playLevelupAnim()
  local percent_s = 1
  local percent_e = 150
  local schedulerEntry = nil 
  local function updatePercent()
    percent_s = percent_s + 1 
    --self.loadingBar:setPercent(math.min(percent_s, percent_e))
    if percent_s >= percent_e then 
      self:unschedule(schedulerEntry)
      
      self:updateGeneralInfo(self.touchIndex)
    end 
  end 
  
  schedulerEntry = self:schedule(updatePercent, 0)
end 




return OfficeLayer 
