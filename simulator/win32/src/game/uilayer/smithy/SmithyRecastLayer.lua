
--铁匠铺:重铸
local EquipmentIcon = require("game.uilayer.common.EquipmentIcon")
local SmithyData = require("game.uilayer.smithy.SmithyData")
local SmithyRecastLayer = class("SmithyRecastLayer",require("game.uilayer.base.BaseLayer"))

function SmithyRecastLayer:ctor()
  SmithyRecastLayer.super.ctor(self)
  print("SmithyRecastLayer:ctor")
end 

function SmithyRecastLayer:onEnter()
  print("SmithyRecastLayer:onEnter")
  local layer = cc.CSLoader:createNode("Smithrecast_Recast.csb") --g_gameTools.LoadCocosUI("Smithrecast_Recast.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
  end 
end 

function SmithyRecastLayer:onExit() 
  print("SmithyRecastLayer:onExit") 
end 

function SmithyRecastLayer:initBinding(scaleNode)
  local Panel_1 = scaleNode:getChildByName("Panel_1")
  local Panel_2 = scaleNode:getChildByName("Panel_2")
  local lbTips1 = Panel_1:getChildByName("Text_2")
  self.recastBg = Panel_1:getChildByName("Image_13") 
  self.btnAdd = Panel_1:getChildByName("Panel_chongzhu"):getChildByName("Image_23")
  self.imgAdd = Panel_1:getChildByName("Panel_chongzhu"):getChildByName("Image_kuang01_0")
  self.btnRecast = Panel_2:getChildByName("Panel_anniu03"):getChildByName("Button_1")
  local lbRecast = Panel_2:getChildByName("Panel_anniu03"):getChildByName("Text_3") 
  self.lbCost = Panel_2:getChildByName("Panel_anniu03"):getChildByName("Text_14") 
  local lbTips2 = Panel_2:getChildByName("Text_5") 
  self.listView = Panel_2:getChildByName("ListView_1") 

  lbTips1:setString(g_tr("recast_tips1"))
  lbTips2:setString(g_tr("recast_tips2"))
  lbRecast:setString(g_tr("recast"))
  self.lbCost:setString("")

  self:regBtnCallback(self.btnAdd, handler(self, self.onSelectEquip))
  self:regBtnCallback(self.btnRecast, handler(self, self.onRecast))

  --播放圆盘背景动画
  local armature, animation = g_gameTools.LoadCocosAni(
    "anime/TieJiangPuChongZhu_MoRenXunHuanDi/TieJiangPuChongZhu_MoRenXunHuanDi.ExportJson"
    , "TieJiangPuChongZhu_MoRenXunHuanDi"
    -- , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )
  armature:setPosition(cc.p(self.recastBg:getContentSize().width/2, self.recastBg:getContentSize().height/2)) 
  self.recastBg:addChild(armature) 
  animation:play("Animation1") 
end 

function SmithyRecastLayer:onSelectEquip()
  print("onSelectEquip")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local function singleSelecteResult(resultTbl) 
    print("singleSelecteResult", #resultTbl) 
    self.recastItem = nil 
    self.imgAdd:removeAllChildren()
    self.lbCost:setString("")
    self.listView:removeAllChildren()

    if #resultTbl > 0 then 
      self.recastItem = resultTbl[1]
      print("singleSelecteResult, equId=", self.recastItem.item_id)
      
      local icon = EquipmentIcon:create(self.recastItem.item_id)
      if icon then 
        local size = self.imgAdd:getContentSize() 
        icon:setNameVisible(false)
        icon:setPosition(cc.p(size.width/2, size.height/2)) 
        self.imgAdd:addChild(icon) 
      end 

      local cost = g_data.equipment[self.recastItem.item_id].recast_cost
      self.lbCost:setString(""..cost)
      self:showMaterialsList(self.recastItem.item_id) 
    end 
  end 

  local data = SmithyData:instance():getEquipForRecast() 
  if self.recastItem then 
    SmithyData:instance():setPreSelectedState(data, {self.recastItem})
  end 
  
  local layer = require("game.uilayer.smithy.EquipmentListLayer").new(SmithyData.listSelectType.Single, data) 
  layer:setUserCallback(singleSelecteResult) 
  g_sceneManager.addNodeForUI(layer) 
end 

function SmithyRecastLayer:onRecast()
  print("onRecast")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  if nil == self.recastItem then 
    g_airBox.show(g_tr("pls_select_equip2"))
    return 
  end 

  --消耗元宝
  local cost = g_data.equipment[self.recastItem.item_id].recast_cost 
  local playerData = g_PlayerMode.GetData() 
  local ownNum = playerData.rmb_gem +  playerData.gift_gem 
  print("own, cost money:", ownNum, cost)
  if cost > ownNum then 
    g_airBox.show(g_tr("no_enough_money"))
    return 
  end 

  local function recastResult(result, data)
    print("recastResult:", result)
    local function animEnd1()
      self.imgAdd:removeAllChildren()
    end 

    local function animEnd2()
      self.listView:removeAllChildren()
      self.lbCost:setString("")
    end 

    if result then 
      self.recastItem = nil 
      -- self.imgAdd:removeAllChildren()
      -- self.listView:removeAllChildren()
      self:playRecastAnim(self.recastBg, self.imgAdd, animEnd1, animEnd2)
      if self:getDelegate() then 
        self:getDelegate():updatePlayerResource()
      end       
    end 
  end 
  
  print("=== onRecast, equId=", self.recastItem.item_id)
  g_sgHttp.postData("Smithy/rebuild", {itemId= self.recastItem.item_id}, recastResult) 
end 

function SmithyRecastLayer:showMaterialsList(equipId)

  self.listView:removeAllChildren()
  self.gainedMat = SmithyData:instance():getEquipRecastMat(equipId)
  local dataLen = #self.gainedMat 

  if dataLen > 0 then 
    self.listView:setBounceEnabled(true)
    self.listView:setScrollBarEnabled(false)


    local idx, child, viewItem
    local col = 3 
    local itemCount = math.ceil(dataLen/col)
    local gridSize = self.listView:getContentSize().width/col 
    local iconSize = 94 
    for i=1, itemCount do 
      viewItem = ccui.Layout:create() 
      viewItem:setContentSize(cc.size(gridSize*col, gridSize)) 
      for k=1, col do 
        idx = (i-1) * col + k 
        if idx <= dataLen then 
          if self.gainedMat[idx][1] == g_Consts.DropType.Equipment then 
            child = require("game.uilayer.common.EquipmentIcon"):create(self.gainedMat[idx][2], self.gainedMat[idx][3]) 
          else 
            child = require("game.uilayer.common.DropItemView").new(self.gainedMat[idx][1], self.gainedMat[idx][2], self.gainedMat[idx][3])
          end 
          if child then 
            child:setNameVisible(false) 
            child:setPosition(cc.p(k*gridSize-gridSize/2, gridSize/2)) 
            child:setScale(iconSize/child:getContentSize().width) 
            viewItem:addChild(child) 
          end 
        end 
      end 
      self.listView:pushBackCustomItem(viewItem) 
    end 
  end 
end 

function SmithyRecastLayer:playRecastAnim(target1, target2, animEndCallback1, animEndCallback2)
  if nil == target1 or nil == target2 then return end 

  local armature , animation

  local function onMovementEventCallFunc2(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()
      if animEndCallback2 then 
        animEndCallback2()
      end 
    end 
  end 

  local function onMovementEventCallFunc1(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()
      if animEndCallback1 then 
        animEndCallback1()
      end 

      --2.播放销毁动画
      armature , animation = g_gameTools.LoadCocosAni(
        "anime/TieJiangPuChongZhu_RanJin/TieJiangPuChongZhu_RanJin.ExportJson"
        , "TieJiangPuChongZhu_RanJin"
        , onMovementEventCallFunc2
        --, onFrameEventCallFunc
        )
      armature:setPosition(cc.p(target2:getContentSize().width/2, target2:getContentSize().height/2))
      target2:addChild(armature)
      animation:play("Animation1")
    end
  end 

  --1.播放吸入动画
  armature, animation = g_gameTools.LoadCocosAni(
    "anime/TieJiangPuChongZhu_XiRu/TieJiangPuChongZhu_XiRu.ExportJson"
    , "TieJiangPuChongZhu_XiRu"
    , onMovementEventCallFunc1
    --, onFrameEventCallFunc
    )

  armature:setPosition(cc.p(target1:getContentSize().width/2, target1:getContentSize().height/2))
  target1:addChild(armature)
  animation:play("Animation1")  
end 

return  SmithyRecastLayer 
