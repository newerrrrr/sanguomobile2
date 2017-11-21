
--神龛武将升星成功弹框

local GodGeneralStarUpPop = class("GodGeneralStarUpPop",require("game.uilayer.base.BaseLayer"))

local viewUI 
function GodGeneralStarUpPop:ctor(genDataOld, genDataNew)
  GodGeneralStarUpPop.super.ctor(self) 
  self.genDataOld = genDataOld 
  self.genDataNew = genDataNew
end 

function GodGeneralStarUpPop:onEnter()
  print("GodGeneralStarUpPop:onEnter") 

  viewUI = self 
  local layer = g_gameTools.LoadCocosUI("GodGenerals_starup_pop.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:showGenInfo(layer:getChildByName("scale_node"))

    local mask = layer:getChildByName("scale_node"):getChildByName("Image_beijing")
    self:regBtnCallback(mask, handler(self, self.onClose))      
  end 
end 

function GodGeneralStarUpPop:onExit()
  print("GodGeneralStarUpPop:onExit") 
  viewUI = nil 
end 

function GodGeneralStarUpPop:onClose()

  if nil == viewUI then return end 

  print("self.animPlaying", self.animPlaying)
  if true == self.animPlaying then return end 
  print("self.animPlaying222")
  self:close()
end 

function GodGeneralStarUpPop:showGenInfo(scaleNode)
  self.scaleNode = scaleNode 

  if nil == self.genDataOld then return end 
  if nil == self.genDataNew then return end 

  local general = g_data.general[self.genDataOld.general_id*100+1]
  if nil == general then return end 

  --显示武将
  local Panel_anim = scaleNode:getChildByName("Panel_anim") 
  local Panel_gen = scaleNode:getChildByName("Panel_gen") 
  local baseInfo = g_data.general[100*self.genDataNew.general_id+1] 
  if baseInfo then 
    local icon = g_resManager.getRes(baseInfo.general_big_icon)
    if icon then 
      icon:setPosition(cc.p(0, 0))
      Panel_gen:addChild(icon)

      --添加动画
      local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()
      GodGeneralMode:addGenBgAnim(Panel_anim)
    end 
  end 


    --["attr1"] = "武",
    --["attr2"] = "智",
    --["attr3"] = "统",
    --["attr4"] = "魅",
    --["attr5"] = "政",

  --初始化旧属性
  --星级
  local nodeStar = scaleNode:getChildByName("prop_row_1")
  nodeStar:getChildByName("Text_24"):setString(g_tr("godGenStarupSuccess", {name=g_tr(general.general_name)}))
  local starGray, starNormal 
  local starNum = math.floor(self.genDataOld.star_lv/5) + 1 
  for i=1, 4 do 
    starGray = nodeStar:getChildByName("Image_x"..i)
    starNormal = nodeStar:getChildByName(string.format("Image_x%d_0", i))
    starGray:setVisible(i>starNum)
    starNormal:setVisible(i<=starNum)
  end 

  local nodeProp = scaleNode:getChildByName("prop_row_2")
  --基础属性
  local attr_old = g_GeneralMode.getGeneralPropertyByServerData(self.genDataOld)
  for i=1, 5 do 
    nodeProp:getChildByName("prop_"..i):getChildByName("Text_1"):setString(g_tr("attr"..i))
    nodeProp:getChildByName("prop_"..i):getChildByName("Text_2"):setString(""..attr_old[i])
    nodeProp:getChildByName("prop_"..i):getChildByName("Text_2_0"):setString("")
  end 

  --天赋提升
  local lbTalent = scaleNode:getChildByName("Text_tf")
  local lbTalentVal = scaleNode:getChildByName("Text_tf1")
  lbTalent:setString(g_tr("godGenTalentUp"))
  lbTalentVal:setString("")
  lbTalentVal:setPositionX(lbTalent:getPositionX()+lbTalent:getContentSize().width+10)

  --技能槽位
  scaleNode:getChildByName("Text_cz"):setString("")

  --显示新属性
  local function showNewAttr()
    print("showNewAttr") 
    self.animPlaying = false 

    if nil == viewUI then return end 

    --基础属性
    local addValStr
    local attr_new = g_GeneralMode.getGeneralPropertyByServerData(self.genDataNew) 
    for i=1, 5 do 
      addValStr = ""
      if attr_new[i] > attr_old[i] then 
        addValStr = " (+"..(attr_new[i]-attr_old[i])..")" 
      end 
      nodeProp:getChildByName("prop_"..i):getChildByName("Text_2_0"):setString(""..attr_new[i]..addValStr)
    end 

    --天赋提升
    local talentStr = ""
    local baseInfo = g_data.general[100*self.genDataNew.general_id+1]
    if baseInfo then 
      g_custom_loadFunc("GenTalentVal", "(star)", " return "..baseInfo.general_talent_value_client)
      local val = externFunctionGenTalentVal(self.genDataNew.star_lv) 
      talentStr = g_tr(baseInfo.general_talent_description, {num = val})    
    end 
    scaleNode:getChildByName("Text_tf1"):setString(talentStr)
    g_gameTools.createRichText(scaleNode:getChildByName("Text_tf1"), talentStr) 

    --槽位
    local lbSlot = scaleNode:getChildByName("Text_cz")
    lbSlot:setString(g_tr("godGenSkillSlotNum"))
    g_gameTools.createRichText(lbSlot, g_tr("godGenSkillSlotNum")) 
  end 

  --星星动画
  self.animPlaying = true 

  local starNum2 = math.floor(self.genDataNew.star_lv/5) + 1 
  local iconStar = nodeStar:getChildByName(string.format("Image_x%d_0", starNum2))
  local x, y = iconStar:getPosition() 
  -- iconStar:setPosition(cc.p(x+40, y-60)) 
  -- iconStar:setVisible(true) 
  -- local act = cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(x, y)), cc.CallFunc:create(showNewAttr))
  -- iconStar:runAction(act) 

  local armature, animation
  local function onMovementEventCallFunc(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent() 
      self.animPlaying = false 
      iconStar:setVisible(true) 
      showNewAttr()
    end
  end 
  armature, animation = g_gameTools.LoadCocosAni(
    "anime/Effect_StarZengJia/Effect_StarZengJia.ExportJson"
    , "Effect_StarZengJia"
    , onMovementEventCallFunc
    )

  armature:setPosition(cc.p(x, y))
  nodeStar:addChild(armature)
  animation:play("Animation1")


  scaleNode:getChildByName("Text_gb"):setString(g_tr("clickhereclose"))
end 





return GodGeneralStarUpPop 
