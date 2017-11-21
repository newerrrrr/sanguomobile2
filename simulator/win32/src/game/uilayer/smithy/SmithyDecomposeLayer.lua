
--铁匠铺:分解
local SmithyData = require("game.uilayer.smithy.SmithyData")
local SmithyDecomposeLayer = class("SmithyDecomposeLayer",require("game.uilayer.base.BaseLayer"))

function SmithyDecomposeLayer:ctor()
  SmithyDecomposeLayer.super.ctor(self)
  print("SmithyDecomposeLayer:ctor")

  self.equipArray = SmithyData:instance():getEquipForDecompose()
  self.selectedArray = {}
end 

function SmithyDecomposeLayer:onEnter()
  print("SmithyDecomposeLayer:onEnter")
  local layer = cc.CSLoader:createNode("Smithrecast_Decomposition.csb") --g_gameTools.LoadCocosUI("Smithrecast_Decomposition.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
  end 
end 

function SmithyDecomposeLayer:onExit() 
  print("SmithyDecomposeLayer:onExit") 
end 

function SmithyDecomposeLayer:initBinding(scaleNode)
  local Panel_1 = scaleNode:getChildByName("Panel_1")
  local lbTitle1 = Panel_1:getChildByName("Text_2")
  self.decomposeBg = Panel_1:getChildByName("Image_13")
  local imgAdd1 = Panel_1:getChildByName("Image_kuang01")
  local imgAdd2 = Panel_1:getChildByName("Image_kuang02")
  local imgAdd3 = Panel_1:getChildByName("Image_kuang03")
  local imgAdd4 = Panel_1:getChildByName("Image_kuang04")
  local imgAdd5 = Panel_1:getChildByName("Image_kuang05")
  local imgRemove1 = Panel_1:getChildByName("Image_jianhao01")
  local imgRemove2 = Panel_1:getChildByName("Image_jianhao02")
  local imgRemove3 = Panel_1:getChildByName("Image_jianhao03")
  local imgRemove4 = Panel_1:getChildByName("Image_jianhao04")
  local imgRemove5 = Panel_1:getChildByName("Image_jianhao05")

  self.btnBatchAdd = Panel_1:getChildByName("Button_1")
  local lbBatchAdd = Panel_1:getChildByName("Text_3") 

  local Panel_2 = scaleNode:getChildByName("Panel_2")
  local lbTitle2 = Panel_2:getChildByName("Text_5")
  self.listView = Panel_2:getChildByName("ListView_1")
  self.btnDecompose = Panel_2:getChildByName("Button_1")
  local lbDecompose = Panel_2:getChildByName("Text_3") 

  lbTitle1:setString(g_tr("decompose_tip1"))
  lbBatchAdd:setString(g_tr("batchAdd"))
  lbTitle2:setString(g_tr("decompose_tip2"))
  lbDecompose:setString(g_tr("decompose"))

  self.btnAddArray = {imgAdd1, imgAdd2, imgAdd3, imgAdd4, imgAdd5}
  self.imgRemoveArray = {imgRemove1, imgRemove2, imgRemove3, imgRemove4, imgRemove5}
  for i=1, #self.btnAddArray do 
    self.btnAddArray[i]:setTag(i) 
    self.imgRemoveArray[i]:setVisible(false)
    self:regBtnCallback(self.btnAddArray[i], handler(self, self.onManualAdd)) 
  end 
  
  self:regBtnCallback(self.btnBatchAdd, handler(self, self.onBatchAdd))
  self:regBtnCallback(self.btnDecompose, handler(self, self.onDecompose))
  self:regBtnCallback(self.btnClose, handler(self, self.close))

  --播放圆盘背景动画
  local armature, animation = g_gameTools.LoadCocosAni(
    "anime/TieJiangPuChongZhu_MoRenXunHuanDi/TieJiangPuChongZhu_MoRenXunHuanDi.ExportJson"
    , "TieJiangPuChongZhu_MoRenXunHuanDi"
    -- , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )
  armature:setPosition(cc.p(self.decomposeBg:getContentSize().width/2, self.decomposeBg:getContentSize().height/2))
  self.decomposeBg:addChild(armature)
  animation:play("Animation1")    
end 


function SmithyDecomposeLayer:showSelectedEquips(equipArray)
  --reset 
  self.selectedArray = equipArray
  for i=1, 5 do 
    self.btnAddArray[i]:removeAllChildren()
    self.imgRemoveArray[i]:setVisible(false)
  end
  
  local function getIcon(equId, num, gridSize)
    local icon = require("game.uilayer.common.EquipmentIcon"):create(equId)
    if icon then 
      icon:setPosition(cc.p(gridSize.width/2, gridSize.height/2))  
      icon:setTag(100) 
      icon:setCount(num, num>1, false)
      icon:setNameVisible(false)   
    end 

    return icon 
  end 

  local count = 1
  local gridSize = self.btnAddArray[1]:getContentSize()
  for k, v in pairs(equipArray) do 
    local item = g_data.equipment[v.item_id]
    if item then 
      if item.equip_type == 0 then --万能装备叠加显示在一格
        local icon = getIcon(v.item_id, v._selNum, gridSize)
        if icon and count <= 5 then 
          self.btnAddArray[count]:addChild(icon) 
          self.imgRemoveArray[count]:setVisible(true) 
          count = count + 1
        end 

      else --普通装备展开显示
        for i=1, v._selNum do  
          local icon = getIcon(v.item_id, 1, gridSize)
          if icon  and count <= 5 then 
            self.btnAddArray[count]:addChild(icon) 
            self.imgRemoveArray[count]:setVisible(true) 
            count = count + 1
          end           
        end 
      end 
    end 
  end 

  self:showMaterialsList() 
end 

function SmithyDecomposeLayer:showMaterialsList()

  self.listView:removeAllChildren()

  self.gainedMat = SmithyData:instance():getMatAfterDecomposed(self.selectedArray)

  local dataLen = #self.gainedMat 
  if dataLen > 0 then 
    self.listView:setBounceEnabled(true)
    self.listView:setScrollBarEnabled(false)
    local col = 3 
    local idx, child, viewItem
    local itemCount = math.ceil(dataLen/col)
    local gridSize = self.listView:getContentSize().width/col
    local iconSize = 94 
    for i=1, itemCount do 
      viewItem = ccui.Layout:create()
      viewItem:setContentSize(cc.size(gridSize*col, gridSize))
      for k=1, col do 
        idx = (i-1) * col + k 
        if idx <= dataLen then 
          child = require("game.uilayer.common.DropItemView").new(self.gainedMat[idx][1], self.gainedMat[idx][2], self.gainedMat[idx][3])
          if child then 
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

function SmithyDecomposeLayer:clearAndReset()
  self.equipArray = SmithyData:instance():getEquipForDecompose()

  self.selectedArray = {}
  for i=1, 5 do 
    self.btnAddArray[i]:removeAllChildren()
    self.imgRemoveArray[i]:setVisible(false)
  end
  self.listView:removeAllChildren()
  self.isPlayingAnim = false 
end 

--手动添加
function SmithyDecomposeLayer:onManualAdd(sender) 
  if self.isPlayingAnim then 
    print("==== isPlayingAnim")
    return 
  end 

  local index = sender:getTag() 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  --如果已选则清除
  local icon = sender:getChildByTag(100)
  if icon then 
    local equId = icon:getEquipId()
    for k, v in pairs(self.selectedArray) do 
      if v.item_id == equId then 
        local item = g_data.equipment[v.item_id]
        if item then 
          if item.equip_type == 0 then --万能装备
            v._selNum = 0 
          else 
            v._selNum = v._selNum - 1 
          end 
        end 

        if v._selNum <= 0 then --该类装备全部被移除时
          v._selNum = 0 
          v._isSelected = false 
          self.selectedArray[k] = nil 
        end 

        sender:removeAllChildren()
        self.imgRemoveArray[index]:setVisible(false)
        break 
      end 
    end 

    self:showMaterialsList()

  else --手动添加
    
    local function selecteResult(dataArray) 
      print("selecteResult", #dataArray) 

      self:showSelectedEquips(dataArray)
    end 

    local layer = require("game.uilayer.smithy.EquipmentListLayer").new(SmithyData.listSelectType.Mulitiple, self.equipArray)
    layer:setSelectedCountMax(5) 
    layer:setUserCallback(selecteResult) 
    g_sceneManager.addNodeForUI(layer) 
  end 
end 

--自动添加
function SmithyDecomposeLayer:onBatchAdd()
  print("onBatchAdd")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self.isPlayingAnim then 
    print("==== isPlayingAnim")
    return 
  end 

  local equipArray = {}

  --只能批量添加白绿装备,并且未被佩戴, 万能装备只允许批量添加白色
  SmithyData:resetEquipFlag(self.equipArray)
  local count = 0
  local item 
  for k, v in pairs(self.equipArray) do 
    item = g_data.equipment[v.item_id]
    if item then 
      if (item.equip_type == 0 and item.quality_id <= 1) or (item.equip_type > 0 and item.star_level <= 2) then 

        v._selNum = math.min(v.num, 5-count)
        v._isSelected = true 
        table.insert(equipArray, v)

        count = count + v._selNum 
        if count >= 5 then 
          break 
        end 
      end 
    end 
  end 

  self:showSelectedEquips(equipArray)
end 

--开始分解
function SmithyDecomposeLayer:onDecompose()
  print("onDecompose") 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  if self.isPlayingAnim then 
    print("==== isPlayingAnim")
    return 
  end 

  local hasHighPriority = false --紫色品质以上
  local equips = {}
  for k, v in pairs(self.selectedArray) do 
    if v._isSelected then 
      for i = 1, v._selNum do 
        table.insert(equips, v.item_id) 
      end 
      if g_data.equipment[v.item_id] and g_data.equipment[v.item_id].quality_id >= 4 then 
        hasHighPriority = true 
      end 
    end 
  end 

  if #equips < 1 then 
    g_airBox.show(g_tr("pls_select_equip3"))
    return 
  end 

  --send msg
  local function decomposeResult(result, data)
    print("decomposeResult:", result)
    if result then 
      --self.gainedMat

      local function animEnd1()
        local icon 
        for k, v in pairs(self.btnAddArray) do 
          icon = v:getChildByTag(100)
          if icon then 
            v:removeChild(icon)
          end 
        end 
      end 
      
      local function animEnd2() 
        self:clearAndReset() 
      end 
      
      self.isPlayingAnim = true 
      self:playDecomposeAnim(self.decomposeBg, self.btnAddArray, animEnd1, animEnd2)
      if self:getDelegate() then 
        self:getDelegate():updatePlayerResource()
      end       
    end 
  end 


  local function startDecompose() 
    dump(self.selectedArray, "decompose equips")
    g_sgHttp.postData("Smithy/split", {itemId= equips}, decomposeResult) 
  end

  if hasHighPriority then 
    g_msgBox.show(g_tr("sureToDecompose"), g_tr("titleTip"), 2, 
                  function(event) 
                    if event == 0 then --确认
                      startDecompose() 
                    end 
                  end, 1)
  else 
    startDecompose() 
  end 
end 

function SmithyDecomposeLayer:playDecomposeAnim(target1, targetTbl, animEndCallback1, animEndCallback2)
  if nil == target1 or nil == targetTbl then return end 

  local armature , animation

  local function onMovementEventCallFunc2(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()
      if animEndCallback2 then 
        animEndCallback2() 
        animEndCallback2 = nil 
      end 
    end 
  end 

  local function onMovementEventCallFunc1(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()

      --2.播放销毁动画
      local icon  
      for k, v in pairs(targetTbl) do 
        icon = v:getChildByTag(100)
        if icon then 
          armature, animation = g_gameTools.LoadCocosAni(
            "anime/TieJiangPuChongZhu_RanJin/TieJiangPuChongZhu_RanJin.ExportJson"
            , "TieJiangPuChongZhu_RanJin"
            , onMovementEventCallFunc2
            --, onFrameEventCallFunc
            )
          armature:setPosition(cc.p(v:getContentSize().width/2, v:getContentSize().height/2))
          v:addChild(armature)
          animation:play("Animation1") 
        end 
      end 

      if animEndCallback1 then 
        animEndCallback1()
      end      
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


return  SmithyDecomposeLayer
