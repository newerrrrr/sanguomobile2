

local GodGeneralEnhance = class("GodGeneralEnhance",require("game.uilayer.base.BaseLayer"))
local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()
local GodGeneralLevelUp = require("game.uilayer.godGeneral.GodGeneralLevelUp")
local GodGeneralStarUp = require("game.uilayer.godGeneral.GodGeneralStarUp")
local GodGeneralToGod = require("game.uilayer.godGeneral.GodGeneralToGod") 
local viewUI
local buttonEffectName = "__sdsbuttonEffectName"


function GodGeneralEnhance:ctor(generalId, callback)
  GodGeneralEnhance.super.ctor(self)
  print("GodGeneralEnhance: generalId = ", generalId)
  self.focusGenId = generalId 
  self.callback = callback 
  self.curListIndex = 0 --下标从0开始
  self.curTabIndex = 1 
  self.curBattleSkillIndex = 1 --城战技能栏位索引
  self.selSkillIndex = nil 
  
  self.GodGenData = GodGeneralMode:getGodGenListData() 
end 

function GodGeneralEnhance:onEnter()
  print("GodGeneralEnhance:onEnter")
  if viewUI then 
    print("GodGeneralEnhance: close exist viewUI !!!")
    viewUI:removeFromParent()
  end 
  viewUI = self 

  local layer = g_gameTools.LoadCocosUI("GodGenerals_new1.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showGodGenList(self.focusGenId)
  end 
end 

function GodGeneralEnhance:onExit()
  print("GodGeneralEnhance:onExit")
  viewUI = nil 
  self:stopAllActions()

  GodGeneralToGod.deInitUI()
  GodGeneralLevelUp.deInitUI()
  GodGeneralStarUp.deInitUI() 

  if self.callback then 
    self.callback() 
  end 
end 

function GodGeneralEnhance:initBinding(scaleNode)
  self.scaleNode = scaleNode 

  local btnClose = scaleNode:getChildByName("Button_close")
  local lbTitle = scaleNode:getChildByName("Text_title")
  self.listView = scaleNode:getChildByName("Panel_gen_list"):getChildByName("ListView_2") 
  self:regBtnCallback(btnClose, handler(self, self.close))

  scaleNode:getChildByName("Text_title"):setString(g_tr("godGeneralTitle"))

  local nodeTab = scaleNode:getChildByName("Panel_enhance")
  local btnTab1 = nodeTab:getChildByName("Button_aa1")
  local btnTab2 = nodeTab:getChildByName("Button_aa2")
  local btnTab3 = nodeTab:getChildByName("Button_aa3")
  local btnTab4 = nodeTab:getChildByName("Button_aa4")
  btnTab1:getChildByName("Text_5"):setString(g_tr("godGenTabLevelStar"))
  btnTab2:getChildByName("Text_5"):setString(g_tr("godGenTabGodSkill"))
  btnTab3:getChildByName("Text_5"):setString(g_tr("godGenTabBattleSkill"))
  btnTab4:getChildByName("Text_5"):setString(g_tr("godGenTabBattleRestartSkill"))
  self:regBtnCallback(btnTab1, handler(self, self.showTabLevelStar)) 
  self:regBtnCallback(btnTab2, handler(self, self.showTabGodSkill)) 
  self:regBtnCallback(btnTab3, handler(self, self.showTabBattleSkill)) 
  self:regBtnCallback(btnTab4, handler(self, self.showTabBattleRestartSkill))
  
   --新手引导
  g_guideManager.registComponent(9999980,btnTab4)
  -- g_guideManager.execute() 

  local function levelupSuccess()
    print("levelupSuccess, update god data")
    if nil == viewUI then return end 

    self.GodGenData = GodGeneralMode:getGodGenListData() 
    self:updateGenListRedPoint()
    self:updateTabRedPoint()
  end 

  local function toGodSuccess(commonCdata, godCdata) 
    if nil == viewUI then return end 
    print("toGodSuccess")

    local node = self.scaleNode:getChildByName("Panel_anim")

    GodGeneralMode:addToGodSuccessAnim(self.scaleNode, commonCdata, godCdata) 

    self.GodGenData = GodGeneralMode:getGodGenListData() 
    self:showGodGenList(godCdata.general_original_id)
    self:updateTabRedPoint()
  end 

  local function starupSuccess()
    if nil == viewUI then return end 
    print("starupSuccess") 
    self.GodGenData = GodGeneralMode:getGodGenListData() 
    self:updateCurGenStar() 
    self:updateGenListRedPoint()
    self:updateTabRedPoint() 
    GodGeneralLevelUp.updateWhenStarUp(self.GodGenData[self.curListIndex+1])
  end 
  GodGeneralToGod.setDelegate(self)
  GodGeneralToGod.initUI(scaleNode:getChildByName("Panel_huashen"), toGodSuccess)   
  GodGeneralLevelUp.initUI(nodeTab:getChildByName("tab_1"), levelupSuccess) 
  GodGeneralStarUp.setDelegate(self)
  GodGeneralStarUp.initUI(nodeTab:getChildByName("tab_1"), starupSuccess) 
end 

--focusGenId:general_original_id
function GodGeneralEnhance:showGodGenList(focusGenId)
  print("showGodGenList:", focusGenId)
  self.listView:removeAllItems()

  local function highlightItem(index, bJump)
    local scaleNode, img 
    for k, v in pairs(self.listView:getItems()) do 
      scaleNode = v:getChildByName("scale_node")
      if scaleNode then 
        img = scaleNode:getChildByName("Image_2")
        if img then 
          img:setVisible(index == k-1)
        end 
      end 
    end 

    self:updateGenInfo(self.GodGenData[index+1]) 
    self:registerGenAttrTips(self.GodGenData[index+1]) 

    if bJump then 
      self.listView:forceDoLayout() 
      self.listView:jumpToPercentVertical(100*(index)/math.max(1, #self.GodGenData)) 
    end 
  end 

  local function onSelectItem(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then 
      local index = sender:getCurSelectedIndex()
      print("=== select list index:", index)
      if self.curListIndex ~= index then 
        self.curListIndex = index 
        self.curBattleSkillIndex = 1 
        self.selSkillIndex = nil
        highlightItem(index) 
      end 
    end 
  end 

  self.listView:addEventListener(onSelectItem)

  local hasNewGuide = g_guideManager.execute()

  --加载武将列表
  local item = cc.CSLoader:createNode("GodGenerals_new1_list1.csb") 
  for k, data in ipairs(self.GodGenData) do      
    local item_new = item:clone() 
    local imgHead = item_new:getChildByName("scale_node"):getChildByName("Image_1")
    local lbName = item_new:getChildByName("scale_node"):getChildByName("Text_mingzi") 
    local imgRed = item_new:getChildByName("scale_node"):getChildByName("Image_3")
    local starBigLevel = data.ndata and (math.floor(data.ndata.star_lv/5)+1) or 1

    local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, data.cdata.id, 1)
    if icon then 
      icon:setCountEnabled(false)
      icon:setPosition(imgHead:getContentSize().width/2, imgHead:getContentSize().height/2)
      if data.ndata == nil then --没有拥有这个武将
        icon:getIconRender():getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
      end 
      icon:showGeneralStarLv(starBigLevel)
      icon:setTag(k)
      imgHead:addChild(icon)
    end 

    lbName:setString(g_tr(data.cdata.general_name))
    imgRed:setVisible(GodGeneralMode:isShowRP(data))

    self.listView:pushBackCustomItem(item_new)

    if hasNewGuide then --新手引导时指向黄盖
      if data.cdata.general_original_id == 10050 then 
        self.curListIndex = k - 1 
      end 
    else
      if focusGenId and focusGenId == data.cdata.general_original_id then 
        self.curListIndex = k - 1 
      end 
    end 
  end 

  --高亮项
  highlightItem(self.curListIndex, self.curListIndex>3)
end 

function GodGeneralEnhance:updateGenInfo(data)
  dump(data, "updateGenInfo")

  if nil == data or nil == data.cdata then return end 

  local nodeGen = self.scaleNode:getChildByName("Panel_gen")
  local lbName = nodeGen:getChildByName("Panel_name"):getChildByName("Text_name")
  local imgGen = nodeGen:getChildByName("Image_gen")

  imgGen:loadTexture( g_resManager.getResPath(data.cdata.general_big_icon))
  lbName:setString(g_tr(data.cdata.general_name))

  local nodeGod = self.scaleNode:getChildByName("Panel_huashen") 
  local nodeTab = self.scaleNode:getChildByName("Panel_enhance") 

  --普通武将按钮显示属性tips
  nodeGen:getChildByName("Image_tanhao"):setVisible(nil == data.ndata)

  if nil == data.ndata then --未化神
    nodeGod:setVisible(true) 
    nodeTab:setVisible(false) 
    GodGeneralToGod.showToGodInfo(data) 

  else 
    nodeGod:setVisible(false) 
    nodeTab:setVisible(true) 
    self:showTabLevelStar() 
    self:updateTabRedPoint()
  end 
end 

function GodGeneralEnhance:highlightTabMenu(index)
  self.curTabIndex = index
  local nodeTab = self.scaleNode:getChildByName("Panel_enhance")
  nodeTab:getChildByName("Button_aa1"):setHighlighted(index==1)
  nodeTab:getChildByName("Button_aa2"):setHighlighted(index==2)
  nodeTab:getChildByName("Button_aa3"):setHighlighted(index==3)
  nodeTab:getChildByName("Button_aa4"):setHighlighted(index==4)
  nodeTab:getChildByName("tab_1"):setVisible(index==1)
  nodeTab:getChildByName("tab_2"):setVisible(index==2)
  nodeTab:getChildByName("tab_3"):setVisible(index==3) 
  nodeTab:getChildByName("tab_4"):setVisible(index==4) 
end 

--武将列表红点
function GodGeneralEnhance:updateGenListRedPoint()
  if nil == viewUI then return end 

  for k, v in pairs(self.listView:getItems()) do 
    local imgRed = v:getChildByName("scale_node"):getChildByName("Image_3")
    imgRed:setVisible(GodGeneralMode:isShowRP(self.GodGenData[k]))
  end 
end 

--更新当前武将星级显示
function GodGeneralEnhance:updateCurGenStar()
  if nil == viewUI then return end
  
  local item = self.listView:getItem(self.curListIndex) 
  if item then 
    local imgHead = item:getChildByName("scale_node"):getChildByName("Image_1")
    local icon = imgHead:getChildByTag(self.curListIndex+1) 
    if icon then 
      local data = self.GodGenData[self.curListIndex+1] 
      local starBigLevel = math.floor(data.ndata.star_lv/5)+1
      icon:showGeneralStarLv(starBigLevel)
    end 
  end 
end 

--tab页红点:可升级/升星/升技能
function GodGeneralEnhance:updateTabRedPoint()
  if nil == viewUI then return end 

  local godGenData = self.GodGenData[self.curListIndex+1] 

  local nodeTab = self.scaleNode:getChildByName("Panel_enhance")
  local canLvUp = GodGeneralMode:canLevelup(godGenData.ndata) or GodGeneralMode:canStarup(godGenData.ndata) 
  local canSkillUp1 = GodGeneralMode:isGodSkillNeedTip(godGenData)
  local canSkillUp2 = GodGeneralMode:isBattleSkillNeedTip(godGenData)
  local canXiLian = GodGeneralMode:canXiLian(godGenData.ndata)

  nodeTab:getChildByName("Button_aa1"):getChildByName("Image_4"):setVisible(canLvUp)
  nodeTab:getChildByName("Button_aa2"):getChildByName("Image_4"):setVisible(canSkillUp1)
  nodeTab:getChildByName("Button_aa3"):getChildByName("Image_4"):setVisible(canSkillUp2)
  nodeTab:getChildByName("Button_aa4"):getChildByName("Image_4"):setVisible(canXiLian)
end 


--tab:升级/升星
function GodGeneralEnhance:showTabLevelStar()
  self:highlightTabMenu(1)

  local godGenData = self.GodGenData[self.curListIndex+1] 
  GodGeneralLevelUp.updateInfo(godGenData)
  GodGeneralStarUp.updateInfo(godGenData)
end 

--普通武将属性tips
function GodGeneralEnhance:registerGenAttrTips(godGenData)
  local btnAttr = self.scaleNode:getChildByName("Panel_gen"):getChildByName("Image_tanhao")
  if btnAttr:isVisible() then 
    g_itemTips.tip(btnAttr, g_Consts.DropType.General, godGenData.cdata.id) 
  end 
end 





--以下为技能部分, 找王永超
----------------------------------------- kkk kkk --------------------------------------------------


function GodGeneralEnhance:updateView()
  --更新数据
  self.GodGenData = GodGeneralMode:getGodGenListData() 
  
  --更新武将显示
  --TODO
  
  --更新当前标签显示
  if self.curTabIndex == 1 then
    self:showTabLevelStar()
  elseif self.curTabIndex == 2 then
    self:showTabGodSkill()
  elseif self.curTabIndex == 3 then
    self:showTabBattleSkill()
  end
  
  self:updateTabRedPoint() 
  self:updateGenListRedPoint()
end

--城战技能升级网络请求
function GodGeneralEnhance:doBattleSkillLevelUp(idx)
  local function callback(result,msgData)
    g_busyTip.hide_1()
    if result == true then
      --g_airBox.show(g_tr("godGeneralQHOK"))
      local projName = "Effect_ShenWuJianUiText"
      local animPath = "anime/"..projName.."/"..projName..".ExportJson"
      local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
         if 0 == eventType then --start
         elseif 1 == eventType then --end
           armature:removeFromParent()
         end
      end)
      self.scaleNode:getChildByName("Panel_enhance"):addChild(armature)
      animation:play("Effect_ShengJiChengGongText")
      
      if msgData.addNum > 0 then
          g_airBox.show(g_tr("battle_skill_update_extra",{num = msgData.addNum}))
      end
      
      self:updateView()
    end
  end
  g_busyTip.show_1()
  local currentGeneral = self.GodGenData[self.curListIndex + 1]
  g_sgHttp.postData("Pub/upBattleSkill", { generalId = currentGeneral.cdata.general_original_id,id = idx }, callback)
end

--神技能升级网络请求
function GodGeneralEnhance:doGodSkillLevelUp()
  local function callback(result,msgData)
    g_busyTip.hide_1()
    if result == true then
      --g_airBox.show(g_tr("godGeneralQHOK"))
      
      local projName = "Effect_ShenWuJianUiText"
      local animPath = "anime/"..projName.."/"..projName..".ExportJson"
      local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
         if 0 == eventType then --start
         elseif 1 == eventType then --end
           armature:removeFromParent()
         end
      end)
      self.scaleNode:getChildByName("Panel_enhance"):addChild(armature)
      animation:play("Effect_QiangHuaChengGongText")
      
      self:updateView()
    end
  end
  g_busyTip.show_1()
  local currentGeneral = self.GodGenData[self.curListIndex + 1]
  g_sgHttp.postData("Pub/upGodSkill", { generalId = currentGeneral.cdata.general_original_id }, callback)
end

--tab:神技能
function GodGeneralEnhance:showTabGodSkill()
  self:highlightTabMenu(2)

  local currentGeneral = self.GodGenData[self.curListIndex + 1]
  
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_qhxg"):getChildByName("text_skill"):setString(g_tr("generalBattleSkillDescTitle"))
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("shuxin_sjn"):getChildByName("Text_s1"):setString(g_tr("godGeneralAdd2"))
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_qhxg"):getChildByName("Text_nr1"):setString(g_tr("godGeneralCZBuffStr"))
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_qhxg"):getChildByName("Text_nr3"):setString(g_tr("godGeneralWDBuffStr"))
  
  local showData = GodGeneralMode:getLevelFormula(currentGeneral)
  
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("shuxin_sjn"):getChildByName("Text_nc1"):setString(showData.title)
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("shuxin_sjn"):getChildByName("Text_lv"):setString("Lv."..showData.level)
  
  if currentGeneral.cdata.skill_icon ~= 0 then
    self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("shuxin_sjn"):getChildByName("Image_1"):loadTexture( g_resManager.getResPath(currentGeneral.cdata.skill_icon) )
  end
  
  if self._combatSkillDescRich == nil then
    self._combatSkillDescRich = g_gameTools.createRichText(self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_qhxg"):getChildByName("Text_nr4"))
  end
  
  if self._duleSkillDescRich == nil then
    self._duleSkillDescRich = g_gameTools.createRichText(self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_qhxg"):getChildByName("Text_nr2"))
  end
  
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_t1"):removeAllChildren()
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_t2"):removeAllChildren()
  
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Text_23"):setString("") --generalSkillLevelMax
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):setVisible(false)
  if currentGeneral.ndata then
    local skillLv = 1
    skillLv = tonumber(currentGeneral.ndata.skill_lv)
    
    local skillLvWithEquip = g_GeneralMode.getGenSkillLv(currentGeneral.ndata)
    
    local boaderPath = GodGeneralMode:getSkillBorderRes(skillLv)
    self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("shuxin_sjn"):getChildByName("Image_1_0"):loadTexture(boaderPath)
    
    local iType = g_Consts.DropType.Props
    local iId = 51011
    local iNum = 0
    local count,needCount,isMaxLv = GodGeneralMode:getNeedSkillUpItemCount(skillLv)

    if isMaxLv then
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Text_23"):setString(g_tr("generalSkillLevelMax")) --generalSkillLevelMax
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):setVisible(false)
      
      do
        local projName = "Effect_ManJiPeiTaoGlow"
        local animPath = "anime/"..projName.."/"..projName..".ExportJson"
        local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
           if 0 == eventType then --start
           elseif 1 == eventType then --end
               
           end
        end)
        self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_t1"):addChild(armature)
        animation:play("Animation1")
      end
      
      do
        local projName = "Effect_ManJiPeiTaoGlowStar"
        local animPath = "anime/"..projName.."/"..projName..".ExportJson"
        local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
           if 0 == eventType then --start
           elseif 1 == eventType then --end
               
           end
        end)
        self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_t2"):addChild(armature)
        animation:play("Animation1")
      end
      
    else
      --显示技能升级面板
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):setVisible(true)
      
      --道具显示
      local showBorder = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):getChildByName("Panel_s1"):getChildByName("Image_1")
      showBorder:removeAllChildren()
      local itemIcon = require("game.uilayer.common.DropItemView").new(iType,iId,iNum)
      itemIcon:setPosition( cc.p( showBorder:getContentSize().width/2, showBorder:getContentSize().height/2 ) )
      local scale = showBorder:getContentSize().width/itemIcon:getContentSize().width
      itemIcon:setCountEnabled(false)
      itemIcon:setNameVisible(true)
      itemIcon:setScale(scale)
      --itemIcon:enableTip(true)
      showBorder:addChild(itemIcon)
      --showBorder.item = itemIcon
      itemIcon:setTouchEnabled(true)
      itemIcon:addClickEventListener( function ( sender )
        --获得途径
        local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, iId)
        view:keepShowByCloseCallback(function()
          --回来后更新当前页面
          self:updateView()
        end)
        g_sceneManager.addNodeForUI(view)
      end )
      
      --道具数量显示
      local labelCnt = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):getChildByName("Panel_s1"):getChildByName("Text_6")
      local color = g_Consts.ColorType.Red
      if count >= needCount then
        color = g_Consts.ColorType.Green
      end
      labelCnt:setTextColor(color)
      labelCnt:setString(count.."/"..needCount)
      
      local labelGeneralLvNeed = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):getChildByName("Text_8")
      local color = g_Consts.ColorType.Normal
      if currentGeneral.ndata.lv <= skillLv then
         color = g_Consts.ColorType.Red
      end
      labelGeneralLvNeed:setTextColor(color)

      local nextSkillLv = skillLv + 1
      labelGeneralLvNeed:setString( g_tr("godLvNeedToUpSkillLvStr",{lv = nextSkillLv }) )
      
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):getChildByName("Text_lv1"):setString("Lv."..skillLvWithEquip)
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):getChildByName("Text_lv2"):setString("Lv."..(skillLvWithEquip + 1))

      local btnLvUp = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_2"):getChildByName("Panel_www"):getChildByName("Button_starup_0")
      btnLvUp:getChildByName("Text_1"):setString(g_tr("generalGodSkillLvBtn"))
      btnLvUp.skillLv = skillLv
      
      do --可升级按钮特效
        if btnLvUp:getChildByName(buttonEffectName) then
          btnLvUp:removeChildByName(buttonEffectName)
        end
        
        if count >= needCount and skillLv < currentGeneral.ndata.lv then
          local projName = "Effect_TiShengNewAnNiu"
          local animPath = "anime/"..projName.."/"..projName..".ExportJson"
          local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
             if 0 == eventType then --start
             elseif 1 == eventType then --end
                 
             end
          end)
          btnLvUp:addChild(armature)
          armature:setName(buttonEffectName)
          armature:setPosition(cc.p(btnLvUp:getContentSize().width/2,btnLvUp:getContentSize().height/2))
          animation:play("Animation1")
        end
      end

      if not self._godSkillLvUpBtnRegisted then
        btnLvUp:addClickEventListener(function()
          local skillLv = btnLvUp.skillLv
          local currentGeneral = self.GodGenData[self.curListIndex + 1] --取最新数据
          local count,needCount,isMaxLv = GodGeneralMode:getNeedSkillUpItemCount(skillLv)
          if count < needCount then
            g_airBox.show(g_tr("godGeneralUseItemError"))
          elseif currentGeneral.ndata.lv <= skillLv then
            g_airBox.show(g_tr("generalSkillLvLimit"))
          else
            self:doGodSkillLevelUp()
          end
        end)
        self._godSkillLvUpBtnRegisted = true
      end
    end
  end
  
  self._combatSkillDescRich:setRichText(showData.rddsc1)
  self._duleSkillDescRich:setRichText(showData.rdsc1)

end 


--显示指定栏位的城战技能
function GodGeneralEnhance:_showBattleSkillByPosIdx(posIdx)
  
  local currentGeneral = self.GodGenData[self.curListIndex + 1] --取最新数据
  
  local clientStar = 1
  if currentGeneral.ndata then
    clientStar = math.floor(tonumber(currentGeneral.ndata.star_lv)/5) + 1
  end
  
  for i=1, 3 do
    self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("shuxin_jczjn"):getChildByName("Panel_god_skill1"):getChildByName("Image_xuanz"..i):setVisible(false)
  end
  
  if clientStar > 1 then
    self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("shuxin_jczjn"):getChildByName("Panel_god_skill1"):getChildByName("Image_xuanz"..posIdx):setVisible(true)
  end
  
  self.curBattleSkillIndex = posIdx
  
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):setVisible(false)
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):getChildByName("Text_nr1_0"):setString(g_tr("godGenBatleEffectStr"))
 
  if self._battleSkillDescRich == nil then
    self._battleSkillDescRich = g_gameTools.createRichText(self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):getChildByName("Text_nr2_0"))
  end
  
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Text_23"):setString("") --generalSkillLevelMax
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):setVisible(false)
  
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_t1"):removeAllChildren()
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_t2"):removeAllChildren()
  
  if currentGeneral.ndata then
    local battleSkillId = tonumber(currentGeneral.ndata["cross_skill_id_"..self.curBattleSkillIndex])
    if battleSkillId > 0 then --该栏位有技能
      local skillLv = 1
      skillLv = tonumber(currentGeneral.ndata["cross_skill_lv_"..self.curBattleSkillIndex])
      
      local skillLvWithEquip = g_GeneralMode.getGenBattleSkillLv(currentGeneral.ndata, self.curBattleSkillIndex) 

      local count,needCount,isMaxLv,itemDropInfo = GodGeneralMode:getNeedBattleSkillUpItemCount(skillLv)
      
      local showData = GodGeneralMode:getBattleSkillFormula(currentGeneral,self.curBattleSkillIndex)
      if showData then
        self._battleSkillDescRich:setRichText(showData.skill_desc)
      end
      
      --显示技能升级面板
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):setVisible(true)
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):setVisible(true)
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Button_xz"):setVisible(true)
    
      --道具显示
      local showBorder = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):getChildByName("Panel_s1"):getChildByName("Image_1")
      showBorder:removeAllChildren()
      
      local itemType = itemDropInfo[1]
      local itemId = itemDropInfo[2]
      local itemCnt = itemDropInfo[3]
      local itemIcon = require("game.uilayer.common.DropItemView").new(itemType,itemId,itemCnt)
      itemIcon:setPosition( cc.p( showBorder:getContentSize().width/2, showBorder:getContentSize().height/2 ) )
      local scale = showBorder:getContentSize().width/itemIcon:getContentSize().width
      itemIcon:setCountEnabled(false)
      itemIcon:setNameVisible(true)
      itemIcon:setScale(scale)
      --itemIcon:enableTip(true)
      showBorder:addChild(itemIcon)
      --showBorder.item = itemIcon
      itemIcon:setTouchEnabled(true)
      itemIcon:addClickEventListener( function ( sender )
        --获得途径
        local view = require("game.uilayer.common.ItemPathView").new(itemType,itemId)
        view:keepShowByCloseCallback(function()
          --回来后更新当前页面
          self:updateView()
        end)
        g_sceneManager.addNodeForUI(view)
      end )
      
      --道具数量显示
      local labelCnt = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):getChildByName("Panel_s1"):getChildByName("Text_6")
      local color = g_Consts.ColorType.Red
      if count >= needCount then
        color = g_Consts.ColorType.Green
      end
      labelCnt:setTextColor(color)
      labelCnt:setString(count.."/"..needCount)
      
      local labelGeneralLvNeed = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):getChildByName("Text_8")
      labelGeneralLvNeed:setString("")
      
      --城战技能需求不再有武将等级限制
--      local color = g_Consts.ColorType.Normal
--      if currentGeneral.ndata.lv <= skillLv then
--        color = g_Consts.ColorType.Red
--      end
--      labelGeneralLvNeed:setTextColor(color)
--      
      local nextSkillLv = skillLv + 1
--      labelGeneralLvNeed:setString( g_tr("godLvNeedToUpSkillLvStr",{lv = nextSkillLv }) )
      
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):getChildByName("Text_dj1"):setString("Lv."..skillLvWithEquip)
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):getChildByName("Text_dj2"):setString("Lv."..(skillLvWithEquip + 1))
      
      local btnLvUp = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):getChildByName("Button_starup_0")
      btnLvUp:getChildByName("Text_1"):setString(g_tr("generalSkillLvBtn"))
      btnLvUp.skillLv = skillLv
      
      do --可升级按钮特效
        if btnLvUp:getChildByName(buttonEffectName) then
          btnLvUp:removeChildByName(buttonEffectName)
        end
        
        if count >= needCount and skillLv < currentGeneral.ndata.lv then
          local projName = "Effect_TiShengNewAnNiu"
          local animPath = "anime/"..projName.."/"..projName..".ExportJson"
          local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
             if 0 == eventType then --start
             elseif 1 == eventType then --end
                 
             end
          end)
          btnLvUp:addChild(armature)
          armature:setName(buttonEffectName)
          armature:setPosition(cc.p(btnLvUp:getContentSize().width/2,btnLvUp:getContentSize().height/2))
          animation:play("Animation1")
        end
        
        if isMaxLv then
          self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Text_23"):setString(g_tr("generalSkillLevelMax")) --generalSkillLevelMax
          self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):setVisible(false)
          self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):getChildByName("Text_dj1"):setString("")
          self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):getChildByName("Text_dj2"):setString("")
          
          do
            local projName = "Effect_ManJiPeiTaoGlow"
            local animPath = "anime/"..projName.."/"..projName..".ExportJson"
            local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
               if 0 == eventType then --start
               elseif 1 == eventType then --end
                   
               end
            end)
            self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_t1"):addChild(armature)
            animation:play("Animation1")
          end
          
          do
            local projName = "Effect_ManJiPeiTaoGlowStar"
            local animPath = "anime/"..projName.."/"..projName..".ExportJson"
            local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
               if 0 == eventType then --start
               elseif 1 == eventType then --end
                   
               end
            end)
            self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_t2"):addChild(armature)
            animation:play("Animation1")
          end
        end
        
        if not self._battleSkillLvUpBtnRegisted then
          btnLvUp:addClickEventListener(function()
            local skillLv = btnLvUp.skillLv
            local currentGeneral = self.GodGenData[self.curListIndex + 1] --取最新数据
            local count,needCount,isMaxLv,itemDropInfo = GodGeneralMode:getNeedBattleSkillUpItemCount(skillLv)
            if count < needCount then
              g_airBox.show(g_tr("godGeneralUseItemError"))
              --城战技能升级不再有武将等级限制
--            elseif currentGeneral.ndata.lv <= skillLv then
--              g_airBox.show(g_tr("generalSkillLvLimit"))
            else
              self:doBattleSkillLevelUp(self.curBattleSkillIndex)
            end
          end)
          self._battleSkillLvUpBtnRegisted = true
        end
      end
    else --该栏位无技能
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Text_23"):setString("") --generalSkillLevelMax
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):setVisible(false)
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):setVisible(false)
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Button_xz"):setVisible(false)
      
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):setVisible(true)
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Text_3"):setString(g_tr("generalBattleSkillAddTip"))
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Button_hs"):getChildByName("Text_77"):setString(g_tr("generalBattleSkillGoto"))
      local gotoBtn = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Button_hs")
      gotoBtn:setVisible(true)
      gotoBtn:addClickEventListener(function()
        self:showTabBattleRestartSkill()  
      end)


      --gotoBtn:setEnabled(false)
      
      if clientStar <= 1 then
        self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):setVisible(true)
        self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Text_3"):setString(g_tr("generalBattleSkillUnlockFirstPos"))
        self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Button_hs"):getChildByName("Text_77"):setString(g_tr("generalBattleSkillGoto"))
        local gotoBtn = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Button_hs")
        gotoBtn:setVisible(false)
      end
      
    end
  else --未解锁
    self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Text_23"):setString("") --generalSkillLevelMax
    self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):setVisible(false)
    self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_www"):setVisible(false)
    self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Button_xz"):setVisible(false)
    
    if clientStar <= 1 then
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):setVisible(true)
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Text_3"):setString(g_tr("generalBattleSkillUnlockFirstPos"))
      self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Button_hs"):getChildByName("Text_77"):setString(g_tr("generalBattleSkillGoto"))
      local gotoBtn = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_bf"):getChildByName("Button_hs")
      gotoBtn:setVisible(false)
    end
  end
end

--tab:城战技能

function GodGeneralEnhance:showTabBattleSkill()

  local currentGeneral = self.GodGenData[self.curListIndex + 1]

  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("Panel_qhxg"):getChildByName("text_skill"):setString(g_tr("generalBattleSkillDescTitle"))
  self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("shuxin_jczjn"):getChildByName("Text_czjn"):setString(g_tr("generalBattleSkill"))
  
  local clientStar = 1
  if currentGeneral.ndata then
    clientStar = math.floor(tonumber(currentGeneral.ndata.star_lv)/5) + 1
  end
  
  for i=1, 3 do
    local lockIcon = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("shuxin_jczjn"):getChildByName("Panel_god_skill1"):getChildByName("Image_"..i.."_0")

    local labelSkillName = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("shuxin_jczjn"):getChildByName("Panel_god_skill1"):getChildByName("Text_nr"..i)
    labelSkillName:setString(g_tr("generalBattleSkillOpen",{star = (i + 1)}))
    
    local labelSkillLevel = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("shuxin_jczjn"):getChildByName("Panel_god_skill1"):getChildByName("Text_lv"..i)
    labelSkillLevel:setString("")
    
    local skillIconCon = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_3"):getChildByName("shuxin_jczjn"):getChildByName("Panel_god_skill1"):getChildByName("Image_"..i.."_1")
    skillIconCon:removeAllChildren()
    
    local btnSkill = skillIconCon
    
    local needStar = (i + 1)
    if clientStar >= needStar then --栏位已解锁
      
      labelSkillName:setString("")
      labelSkillLevel:setString("")
      
      lockIcon:setVisible(false)
      if currentGeneral.ndata then
        local battleSkillId = tonumber(currentGeneral.ndata["cross_skill_id_"..i])
        if battleSkillId > 0 then --该栏位有城战技能
            --local battleSkillLv = currentGeneral.ndata["cross_skill_lv_"..i]
            
            local skillLvWithEquip = g_GeneralMode.getGenBattleSkillLv(currentGeneral.ndata, i) 
          local battleSkillLv = skillLvWithEquip
          local battleSkillConfig = g_data.battle_skill[battleSkillId]
          labelSkillName:setString(g_tr(battleSkillConfig.skill_name))
          labelSkillLevel:setString("Lv."..battleSkillLv)
          local skillIcon = g_resManager.getRes(battleSkillConfig.skill_res)
          if skillIcon then
            skillIcon:setScale(1.08)
            skillIcon:setTouchEnabled(false)
            local size = skillIconCon:getContentSize()
            skillIconCon:addChild(skillIcon)
            skillIcon:setPosition(cc.p(size.width/2,size.height/2))
          end
        end
        
        if not btnSkill.registedClick then
          btnSkill:setTouchEnabled(true)
          --栏位切换
          btnSkill:addClickEventListener(function()
            self:_showBattleSkillByPosIdx(i)
          end)
          btnSkill.registedClick = true
        end
      end
    else --未解锁
      lockIcon:setVisible(true)
    end
    
    self:_showBattleSkillByPosIdx(self.curBattleSkillIndex)
    
  end
  
  self:highlightTabMenu(3)
end 


--tab:技能洗练
function GodGeneralEnhance:showTabBattleRestartSkill()
    
    local openLv = tonumber(g_data.starting[111].data)
    local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
    if mainCityLevel < openLv then
        g_airBox.show(g_tr("godGenXiLianNoOpen",{lv = openLv}))
        return
    end
    
    g_guideManager.execute()
    
    local currentGeneral = self.GodGenData[self.curListIndex + 1] --取最新数据
    local tab4 = self.scaleNode:getChildByName("Panel_enhance"):getChildByName("tab_4")
    local skillPanel = tab4:getChildByName("shuxin_jczjn")
    local _skillPanel = skillPanel:getChildByName("Panel_god_skill1")
    local highs = {}

    local skillDescTx = tab4:getChildByName("Panel_qhxg"):getChildByName("Text_nr2_0")
    if skillDescTx.rich then
        skillDescTx.rich:removeFromParent()
        skillDescTx.rich = nil
    end

    if skillDescTx.rich == nil then
        skillDescTx.rich = g_gameTools.createRichText(skillDescTx)
    end

    --skillDescTx:setString(g_tr("godGenXiLianDes"))
    local mode = tab4:getChildByName("Panel_qhxg"):getChildByName("Text_nrjs")
    --mode:setString(g_tr("godGenXiLianBackDes",{num = 10,name = "孙悟空"}))
    if mode.rich then
        mode.rich:removeFromParent()
        mode.rich = nil
    end

    if mode.rich == nil then
        mode.rich = g_gameTools.createRichText(mode)
    end
    
    local showSkillBtn = tab4:getChildByName("Panel_qhxg"):getChildByName("Button_xlyl")
    showSkillBtn:getChildByName("Text_26"):setString(g_tr("godGenXiLianDesTitle"))
    showSkillBtn.currentGeneral = currentGeneral
    if showSkillBtn.isTouch == nil then
        showSkillBtn:addClickEventListener(function()
            local showView = require("game.uilayer.godGeneral.GodGeneralBattleSkillShow"):create(showSkillBtn.currentGeneral)
            g_sceneManager.addNodeForUI(showView)
        end)
        showSkillBtn.isTouch = true
    end

    local clientStar = 1
    if currentGeneral.ndata then
        clientStar = math.floor(tonumber(currentGeneral.ndata.star_lv)/5) + 1
    end
    

    tab4.getBackItemNum = nil
    tab4.getBackItemNum = function (index)
        if currentGeneral.ndata then

            local showData = GodGeneralMode:getBattleSkillFormula(currentGeneral,index)
            if showData then
                skillDescTx.rich:setRichText(showData.skill_desc)
            end
            
            local battleSkillId = tonumber(currentGeneral.ndata["cross_skill_id_"..index])
            if battleSkillId > 0 then
                mode.rich:setVisible(true)
                local battleSkillConfig = g_data.battle_skill[battleSkillId]
                local lvUpConfig = g_data.battle_skill_levelup
                local battleSkillLv = currentGeneral.ndata["cross_skill_lv_"..index]
                local defultLv = battleSkillConfig.battle_skill_defalut_level
                local upLevel = battleSkillLv - defultLv
                local backNum = 0
                if upLevel > 0 then
                    for i = 2,battleSkillLv do
                        backNum = backNum + ( lvUpConfig[i].consume[1][3] or 0 )
                    end
                else
                    mode.rich:setVisible(false)
                end
                mode:setString( g_tr("godGenXiLianBackDes",{num = backNum}) )
                mode.rich:setRichText(mode:getString())
            else
                --mode:setString( g_tr("godGenXiLianDes") )
                --mode.rich:setRichText(mode:getString())
                skillDescTx.rich:setRichText(g_tr("godGenXiLianDes"))
                mode.rich:setVisible(false)
            end
        end
    end
    
    
    local isOpen = {}
    for i = 1, 3 do
        local lockIcon = _skillPanel:getChildByName("Image_"..i.."_0")
        local labelSkillName = _skillPanel:getChildByName("Text_nr"..i)
        labelSkillName:setString(g_tr("generalBattleSkillOpen",{star = (i + 1)}))
        local skillIconCon = _skillPanel:getChildByName("Image_"..i.."_1")
        skillIconCon:setTouchEnabled(true)

        local high = _skillPanel:getChildByName("Image_xuanz"..i)
        --high:setVisible( self.selSkillIndex == i )
        table.insert(highs,high)
        local labelSkillLevel = _skillPanel:getChildByName("Text_lv"..i)
        labelSkillLevel:setString("")

        skillIconCon:removeAllChildren()

        local needStar = (i + 1)
        if clientStar >= needStar then --栏位已解锁
            isOpen[i] = true
            labelSkillName:setString("")
            labelSkillLevel:setString("")
            lockIcon:setVisible(false)
            if currentGeneral.ndata then
                local battleSkillId = tonumber(currentGeneral.ndata["cross_skill_id_"..i])
                if battleSkillId > 0 then --该栏位有城战技能
                    --local battleSkillLv = currentGeneral.ndata["cross_skill_lv_"..i]
                    
                    local skillLvWithEquip = g_GeneralMode.getGenBattleSkillLv(currentGeneral.ndata, i) 
                    local battleSkillLv = skillLvWithEquip
                    local battleSkillConfig = g_data.battle_skill[battleSkillId]
                    labelSkillName:setString(g_tr(battleSkillConfig.skill_name))
                    labelSkillLevel:setString("Lv."..battleSkillLv)
                    local skillIcon = g_resManager.getRes(battleSkillConfig.skill_res)
                    if skillIcon then
                        skillIcon:setScale(1.08)
                        local size = skillIconCon:getContentSize()
                        skillIconCon:addChild(skillIcon)
                        skillIcon:setPosition(cc.p(size.width/2,size.height/2))
                    end
                else
                    print("未解锁",i,self.selSkillIndex)
                    if self.selSkillIndex == nil then
                        self.selSkillIndex = i
                    end
                end
            end
        else --未解锁
            isOpen[i] = false
            high:setVisible(false)
            lockIcon:setVisible(true)
        end
        
        if skillIconCon.isTouch == nil then
            --栏位切换
            skillIconCon:addClickEventListener(function()
                self.selSkillIndex = i
                tab4.getBackItemNum(self.selSkillIndex)
                for _, _high in ipairs(highs) do
                    _high:setVisible(false)
                end
                high:setVisible(true)
            end)
            skillIconCon.isTouch = true
        end
    end
    
    if self.selSkillIndex == nil then
        self.selSkillIndex = 1
    end
        
    for index, var in ipairs(highs) do
        if index == self.selSkillIndex and  isOpen[index] then
            var:setVisible(true)
        else
            var:setVisible(false)
        end
    end

    tab4.getBackItemNum(self.selSkillIndex)

    local iType = g_Consts.DropType.Props
    local iId = 12100
    local iNum = g_PlayerMode.getXuanTie()
    local needNum = g_data.cost[10026].cost_num

    local showBorder = tab4:getChildByName("Panel_www"):getChildByName("Panel_s1"):getChildByName("Image_1")
    local showNumTx = tab4:getChildByName("Panel_www"):getChildByName("Panel_s1"):getChildByName("Text_6")
    showNumTx:setString( iNum .. "/" .. needNum )
    if iNum < needNum then
        showNumTx:setTextColor(cc.c3b(230,30,30))
    else
        showNumTx:setTextColor(cc.c3b(30,230,30))
    end

    showBorder:removeAllChildren()
    local itemIcon = require("game.uilayer.common.DropItemView").new(iType,iId,iNum)
    itemIcon:setCountEnabled(false)
    itemIcon:setNameVisible(true)
    itemIcon:setPosition( cc.p( showBorder:getContentSize().width/2, showBorder:getContentSize().height/2 ) )
    showBorder:addChild(itemIcon)
    itemIcon:setTouchEnabled(true)
    itemIcon:addClickEventListener( function ( sender )
        --获得途径
        local view = require("game.uilayer.common.ItemPathView").new(iType,iId)
        view:keepShowByCloseCallback(function()
          --回来后更新当前页面
          --self:updateView()
            if iNum ~= g_PlayerMode.getXuanTie() then
                self:showTabBattleRestartSkill()
            end
        end)
        g_sceneManager.addNodeForUI(view)
     end )

    --Text_6
    
    local sendBtn = tab4:getChildByName("Panel_www"):getChildByName("Button_starup_0")
    sendBtn:getChildByName("Text_1"):setString(g_tr("godGenXiLian"))
    sendBtn:setEnabled(false)

    for key, var in ipairs(isOpen) do
        if var then
            sendBtn:setEnabled(true)
            break
        end
    end
    
    sendBtn.currentGeneral = currentGeneral
    if not sendBtn.addTouch then
        sendBtn.addTouch = true
        sendBtn:addClickEventListener(function()
        
            local timeTb = string.split(g_playerInfoData.GetData().skill_wash_date,"-")
            local time = os.time({ day = tonumber(timeTb[3]), month = tonumber(timeTb[2]), year = tonumber(timeTb[1]), hour = 0, minute = 0, second = 0}) or 0
            --if g_clock.isSameDay(time,g_clock.getCurServerTime()) then --不免费

            if g_PlayerMode.getXuanTie() < g_data.cost[10026].cost_num and g_clock.isSameDay(time,g_clock.getCurServerTime()) then
                g_airBox.show(g_tr("godGenItemNoEnought"))
                return
            end
        
            local isSkill = false

            local battleSkillId = tonumber(sendBtn.currentGeneral.ndata["cross_skill_id_"..self.selSkillIndex])
            if battleSkillId > 0 then --该栏位有城战技能
                isSkill = true
            end

            local function send()
                local function callback(result,msgData)
                    if result == true then
                        --dump(msgData)
                        g_airBox.show(g_tr("godGenXiLianSc"))
                        self.GodGenData = GodGeneralMode:getGodGenListData()
                        self:showTabBattleRestartSkill()
                        self:updateTabRedPoint() 
                        self:updateGenListRedPoint()
                        
                        if msgData.addNum > 0 then
                            g_airBox.show(g_tr("battle_skill_wash_extra",{num = msgData.addNum}))
                        end
                    end
                end
                g_sgHttp.postData("Pub/washBattleSkill", { generalId = sendBtn.currentGeneral.cdata.general_original_id,id = self.selSkillIndex }, callback)
            end
            --技能槽拥有技能 提心
            if isSkill then
                g_msgBox.show( g_tr("godGenTrue"),nil,nil,
                function ( eventtype )
                    --确定
                    if eventtype == 0 then 
                        send()
                    end
                end , 1)
            else
                send()
            end
        end)
    end
    
    local timeStr = tab4:getChildByName("Panel_www"):getChildByName("Text_time")
    timeStr:setVisible(false)

    if timeStr.timer then
        timeStr:stopAction(timeStr.timer)
        timeStr.timer = nil
    end

    local freeTime = g_playerInfoData.GetData().skill_wash_date
    if freeTime then
        local timeTb = string.split(g_playerInfoData.GetData().skill_wash_date,"-")
        local time = os.time({ day = tonumber(timeTb[3]), month = tonumber(timeTb[2]), year = tonumber(timeTb[1]), hour = 0, minute = 0, second = 0}) or 0
        if g_clock.isSameDay(time,g_clock.getCurServerTime()) then --不免费
            if timeStr.timer == nil then
                local overtime = ( time + 86400 ) --第二天凌晨
                timeStr:setString( g_gameTools.convertSecondToString(overtime - g_clock.getCurServerTime()) .. g_tr("nextFreeTime") )
                local delay = cc.DelayTime:create(1)
                local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function (args)
                    timeStr:setString( g_gameTools.convertSecondToString(overtime - g_clock.getCurServerTime()) .. g_tr("nextFreeTime") )
                end))
                local action = cc.RepeatForever:create(sequence)
                timeStr:runAction(action)
                timeStr.timer = action
            end
            timeStr:setVisible(true)
        else
            showNumTx:setTextColor( cc.c3b(30,230,30) )
            showNumTx:setString(g_tr("air_free"))
        end
    end

    self:highlightTabMenu(4)
end



return GodGeneralEnhance 
