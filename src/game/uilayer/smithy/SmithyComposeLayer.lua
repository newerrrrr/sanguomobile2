
--铁匠铺:合成
local SmithyData = require("game.uilayer.smithy.SmithyData")
local SmithyComposeLayer = class("SmithyComposeLayer",require("game.uilayer.base.BaseLayer"))
local SmithyBatchCompose = require("game.uilayer.smithy.SmithyBatchCompose")

function SmithyComposeLayer:ctor(para)
  SmithyComposeLayer.super.ctor(self)
  print("SmithyComposeLayer:ctor")
  dump(para, "para")
  if type(para) == "table" then 
    self.targetMatId = para.itemId
  else 
    self.targetMatId = para
  end 

   
  self.isPlayingAnim = false 
end 

function SmithyComposeLayer:onEnter()
  print("SmithyComposeLayer:onEnter")
  local layer = cc.CSLoader:createNode("Smithrecast_Synthesis.csb") --g_gameTools.LoadCocosUI("Smithrecast_Synthesis.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 

    self:showConsumedMats()
    self:showTargetMatList()
  end 
end 

function SmithyComposeLayer:onExit() 
  print("SmithyComposeLayer:onExit") 
end 

function SmithyComposeLayer:initBinding(scaleNode)
  local Panel_hecheng01 = scaleNode:getChildByName("Panel_hecheng01")
  self.imgCircleBg = Panel_hecheng01:getChildByName("Image_13")
  local imgMat1 = Panel_hecheng01:getChildByName("Image_kuang01")
  local imgMat2 = Panel_hecheng01:getChildByName("Image_kuang02")
  local imgMat3 = Panel_hecheng01:getChildByName("Image_kuang03")
  local imgMat4 = Panel_hecheng01:getChildByName("Image_kuang04")

  self.btnCompose = Panel_hecheng01:getChildByName("Button_1_0_0") 
  local lbCompose = Panel_hecheng01:getChildByName("Text_3_0_0") 
  self.imgCenter = Panel_hecheng01:getChildByName("Image_23")
  self.imgTargetMat = Panel_hecheng01:getChildByName("Image_kuang01_0")  
  local lbTips = scaleNode:getChildByName("Panel_hecheng02"):getChildByName("Text_5") 
  self.listView = scaleNode:getChildByName("Panel_hecheng02"):getChildByName("ListView_1") 

  lbCompose:setString(g_tr("compose"))
  lbTips:setString(g_tr("compose_tip1"))

  self:regBtnCallback(self.btnCompose, handler(self, self.onCompose))
  self:regBtnCallback(self.imgTargetMat, handler(self, self.onSelecteTarget))

  self.imgMatArray = {imgMat1, imgMat2, imgMat3, imgMat4}

  --播放圆盘背景动画
  local armature, animation = g_gameTools.LoadCocosAni(
    "anime/TieJiangPuHeCheng_DiGuang/TieJiangPuHeCheng_DiGuang.ExportJson"
    , "TieJiangPuHeCheng_DiGuang"
    -- , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )
  armature:setPosition(cc.p(self.imgCircleBg:getContentSize().width/2, self.imgCircleBg:getContentSize().height/2)) 
  self.imgCircleBg:addChild(armature) 
  animation:play("Animation1") 
end 


function SmithyComposeLayer:onSelecteTarget()
  print("onSelecteTarget")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  local function bagSelectCallback(itemId)
    print("bagSelectCallback", itemId)
    if itemId then 
      self.targetMatId = itemId 
      self:showConsumedMats() 
      self:showTargetMatList() 
    end 
  end 

  g_BagMode.NotificationClose() --如果后台背包界面存在,则先关闭
  local bag = require("game.uilayer.bag.BagView").new()
  bag:show(2, bagSelectCallback, 1)
  g_sceneManager.addNodeForUI(bag) 
end 

--圆盘周围显示需要的消耗材料
function SmithyComposeLayer:showConsumedMats()
  self.imgTargetMat:removeAllChildren()
  for k, v in pairs(self.imgMatArray) do 
    v:removeAllChildren()
  end 

  self.hasEnoughMats = false
  print("showConsumedMats: targetId", self.targetMatId)
  if self.targetMatId then 
    --target
    local item = g_data.item_combine[self.targetMatId]
    if nil == item then 
      print("====invalid item id:", self.targetMatId)
      return 
    end 
    local iconTarget = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, self.targetMatId, item.count)
    if iconTarget then 
      local size = self.imgTargetMat:getContentSize()
      iconTarget:setPosition(cc.p(size.width/2, size.height/2))
      self.imgTargetMat:addChild(iconTarget)
    end 

    --消耗的材料
    self.MaxCount = 100 --可合成的最大数量
    local group = g_data.item_combine[self.targetMatId].consume 
    if group then 
      local needMats = group[1] 
      local myCount = g_BagMode.findItemNumberById(needMats[2])
      local icon, size 
      for i=1, math.min(needMats[3], myCount) do 
        if i <= #self.imgMatArray then 
          size = self.imgMatArray[i]:getContentSize()
          icon = require("game.uilayer.common.DropItemView").new(needMats[1], needMats[2], 1)
          if icon then 
            icon:setCountEnabled(false)
            icon:setPosition(cc.p(size.width/2, size.height/2))
            icon:setTag(100)
            self.imgMatArray[i]:addChild(icon) 
          end 
        end 
      end  
      
      self.hasEnoughMats = myCount >= needMats[3]

      --计算可合成的最大数量
      if myCount > 0 and needMats[3] > 0 then 
        local count = math.floor(myCount/needMats[3])
        if count < self.MaxCount then 
          self.MaxCount = count 
        end 
      end 
    end 
  end 

  self:stopAllAnim()

  if self.hasEnoughMats then 
    self:playComposingAnim(self.imgCenter, self.imgMatArray)    
  end 
end 

--供用户选择想要合成的材料
function SmithyComposeLayer:showTargetMatList()
  self.listView:removeAllChildren()

  if nil == self.targetMatId then 
    return 
  end 

  local data, index = SmithyData:instance():getSameSeriesItems(self.targetMatId)

  local function highlightItem(idx)
    local item, scaleNode 
    for k, v in pairs(self.listView:getItems()) do 
      scaleNode = v:getChildByName("scale_node")
      if scaleNode then 
        scaleNode:getChildByName("Image_2"):setVisible(false)
      end 
    end 

    item = self.listView:getItem(idx)
    if nil == item then return end 
    scaleNode = item:getChildByName("scale_node")
    if scaleNode then 
      scaleNode:getChildByName("Image_2"):setVisible(true)
    end 
  end 

  local function onSelectItem(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then 
      local index = sender:getCurSelectedIndex() + 1 
      if data[index].item_level_id == 1 then --1星材料不允许合成
        g_airBox.show(g_tr("cannot_combine_low_mat"))
        index = index + 1 
      end 

      if index <= #data then 
        self.targetMatId = data[index].id 
        highlightItem(index-1)
        self:showConsumedMats()
      end 
    end 
  end 
  
  if #data > 0 then 
    self.listView:setBounceEnabled(true)
    self.listView:setScrollBarEnabled(false)
    self.listView:addEventListener(onSelectItem)

    local listItem = cc.CSLoader:createNode("Smithrecast_Synthesis01.csb") 
    listItem:retain()
    for i=1, #data do 
      local item_new = listItem:clone() --(i==1) and listItem or listItem:clone() 
      local scale_node = item_new:getChildByName("scale_node") 
      local nodeIcon = scale_node:getChildByName("Panel_2") 
      local lbName = scale_node:getChildByName("Text_1") 
      local myCount = g_BagMode.findItemNumberById(data[i].id) 
      scale_node:getChildByName("Text_2"):setString(g_tr("matName"))
      nodeIcon:removeAllChildren()
      local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, data[i].id, myCount)
      if icon then 
        icon:setPosition(cc.p(nodeIcon:getContentSize().width/2, nodeIcon:getContentSize().height/2)) 
        nodeIcon:addChild(icon) 
      end 
      lbName:setString(g_tr(data[i].item_name)) 
      self.listView:pushBackCustomItem(item_new) 
    end 
    listItem:release()
    
    if index and data[index].item_level_id > 1 then 
      highlightItem(index-1) 
    else 
      for k, v in pairs(data) do 
        if v.item_level_id > 1 then 
          highlightItem(k-1)
          if v.id ~= self.targetMatId then 
            self.targetMatId = v.id 
            self:showConsumedMats()
          end 
          break 
        end 
      end       
    end 
  end 
end 

function SmithyComposeLayer:clearAndReset()
  self.isPlayingAnim = false 

  self:showTargetMatList()

  self.imgTargetMat:removeAllChildren()
  for k, v in pairs(self.imgMatArray) do 
    v:removeAllChildren()
  end 
  -- self.targetMatId = nil 
end 

function SmithyComposeLayer:onCompose()
  print("onCompose")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self.isPlayingAnim then 
    print("is playing anim...")
    return 
  end 
  
  if nil == self.targetMatId then 
    g_airBox.show(g_tr("pls_select_equip4"))
    return 
  end 

  if not self.hasEnoughMats then 
    g_airBox.show(g_tr("no_enough_material"))
    return 
  end 



  local function startCompose(count)

    local function composeResult(result, data)
      print("composeResult:", result)
      if result then 
        self.isPlayingAnim = true 
        self:playComposeFinishAnim(self.imgTargetMat, self.imgMatArray, function() 
          self:clearAndReset() 
          self:showConsumedMats()
          end )
        if self:getDelegate() then 
          self:getDelegate():updatePlayerResource()
        end

        SmithyData:instance():setDataIsDurty(true)
      end 
    end 

    print("start combine item, count=", self.targetMatId, count)
    g_sgHttp.postData("Smithy/materialCombine", {itemId= self.targetMatId, num = count or 1}, composeResult)  
  end 

  if self.MaxCount >= 2 then 
    local function selectNumResult(count)
      print("selectNumResult", count)
      if count <= 0 then 
        g_airBox.show(g_tr("wrongNum"))
        return         
      end 
      startCompose(count)
    end 
    local pop = SmithyBatchCompose.new(self.targetMatId, self.MaxCount, selectNumResult)
    self:addChild(pop)
  else 
    startCompose(1) 
  end 
end 

--播放正在合成动画
function SmithyComposeLayer:playComposingAnim(target1, targetTbl)
  self:stopAllAnim()

  local size = target1:getContentSize()

  --1.中心转圈(循环播放)
  local armature, animation = g_gameTools.LoadCocosAni(
    "anime/TieJiangPuHeCheng_Center/TieJiangPuHeCheng_Center.ExportJson"
    , "TieJiangPuHeCheng_Center"
    -- , onMovementEventCallFunc1
    --, onFrameEventCallFunc
    )

  armature:setPosition(cc.p(size.width/2, size.height/2))
  target1:addChild(armature)
  animation:play("Animation1")   

  self.animCircle = armature

  --2.播放连线动画(循环播放)
  self.animLines = {}
  local x2,y2, newPos 
  local x1, y1 = target1:getPosition()
  local degree

  for k, v in pairs(targetTbl) do 
    if v:getChildByTag(100) then 
      local armature, animation = g_gameTools.LoadCocosAni(
        "anime/TieJiangPuHeCheng_TongYongLianXian/TieJiangPuHeCheng_TongYongLianXian.ExportJson"
        , "TieJiangPuHeCheng_TongYongLianXian"
        -- , onMovementEventCallFunc1
        --, onFrameEventCallFunc
        )

      x2, y2 = v:getPosition()

      armature:setPosition(cc.p((x1+x2)/2-target1:getPositionX()+size.width/2, (y1+y2)/2-target1:getPositionY()+size.height/2))
      degree = math.atan((y2-y1)/(x2-x1))*180
      armature:setRotation(degree)
      target1:addChild(armature)
      animation:play("Animation1")  

      table.insert(self.animLines, armature)
    end 
  end 
end 

--播放合成结束动画
function SmithyComposeLayer:playComposeFinishAnim(target1, targetTbl, animEndCallback)

  --2.播放闪光动画
  local function playExplosureAnim()    
    local armature, animation
    local function onMovementEventCallFunc(armature , eventType , name)
      if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
        if animEndCallback then 
          animEndCallback()
        end 
        armature:removeFromParent()
        self:stopAllAnim()
      end 
    end 

    armature, animation = g_gameTools.LoadCocosAni(
      "anime/TieJiangPuHeCheng_BaoFa/TieJiangPuHeCheng_BaoFa.ExportJson"
      , "TieJiangPuHeCheng_BaoFa"
      , onMovementEventCallFunc
      --, onFrameEventCallFunc
      )  
    armature:setPosition(cc.p(target1:getContentSize().width/2, target1:getContentSize().height/2))
    target1:addChild(armature)
    animation:play("Animation1")      
  end 


  --1.播放icon飞到中间的动画
  local icon, act_move, act, seq   
  local duration = 0.4
  local targetSize = target1:getContentSize()
  local x, y = target1:getPosition() 
  for k, v in pairs(targetTbl) do 
    icon = v:getChildByTag(100)
    if icon then 
      act_move = cc.MoveTo:create(duration, cc.p(x-v:getPositionX()+targetSize.width/2, y-v:getPositionY()+targetSize.height/2))
      act = cc.Spawn:create(act_move, cc.RotateBy:create(duration, 100))
      seq = cc.Sequence:create(cc.Spawn:create(act, cc.ScaleTo:create(duration, 0.4, 0.4)), cc.RemoveSelf:create())
      icon:runAction(seq)
    end 
  end 

  self:performWithDelay(playExplosureAnim, duration)
end 

function SmithyComposeLayer:stopAllAnim()
  if self.animCircle then 
    self.animCircle:removeFromParent()
    self.animCircle = nil 
  end 

  if self.animLines then 
    for k, v in pairs(self.animLines) do 
      v:removeFromParent()
    end 
    self.animLines = {}
  end 
  self.isPlayingAnim = false
end 

return  SmithyComposeLayer
