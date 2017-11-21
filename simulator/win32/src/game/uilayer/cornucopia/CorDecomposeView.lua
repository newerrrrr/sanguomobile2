
--观星台:熔炼
local CorDecomposeView = class("CorDecomposeView",require("game.uilayer.base.BaseLayer"))


local viewObj
function CorDecomposeView:ctor(delegate)
  CorDecomposeView.super.ctor(self)
  print("CorDecomposeView:ctor")
  self.delegate = delegate 
  self.isPlayingAnim = false 
  self:initMatInfos()
end 

function CorDecomposeView:onEnter()
  print("CorDecomposeView:onEnter")
  viewObj = self 

  local layer = cc.CSLoader:createNode("GodGenerals_Smithrecast_Synthesis1.csb") 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:updateUI()
  end 
end 

function CorDecomposeView:onExit() 
  print("CorDecomposeView:onExit") 
  viewObj = nil 
end 

function CorDecomposeView:initMatInfos() 
  self.matInfo = {}
  for i = 51001, 51006 do 
    local info = {}
    info.id = i 
    info.ownNum = g_BagMode.findItemNumberById(i) 
    info.selectedNum = 0
    table.insert(self.matInfo, info)
  end 
end 


function CorDecomposeView:initBinding(scaleNode)
  local Panel_1 = scaleNode:getChildByName("Panel_ronglian1")
  
  Panel_1:getChildByName("Text_1"):setString(g_tr("corDecomposeTips"))

  self.animNode = Panel_1:getChildByName("Image_kuang07")
  self:playBackGroundAnim(Panel_1:getChildByName("Panel_bg_anim"), cc.p(183, 24))

  self.imgIcon = {}
  self.imgAdd = {}
  self.imgRemove = {}
  local node, imgAdd, imgRemove 
  for i = 1, 6 do 
    node = Panel_1:getChildByName("Image_kuang0"..i)
    imgAdd = Panel_1:getChildByName("Image_add0"..i) 
    imgRemove = Panel_1:getChildByName("Image_remove0"..i)

    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, self.matInfo[i].id, 0)
    if item then 
      item:setScale(node:getContentSize().width/item:getContentSize().width)
      item:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
      item:setNameVisible(false)
      node:addChild(item) 
    end 

    imgAdd:setVisible(true)
    imgRemove:setVisible(false)
    node:setTag(i) 
    self:regBtnCallback(node, handler(self, self.onManualAdd)) 
    self.imgIcon[i] = item 
    self.imgAdd[i] = imgAdd 
    self.imgRemove[i] = imgRemove 
  end 

  local btnBatchAdd = Panel_1:getChildByName("Button_yjtj")
  btnBatchAdd:getChildByName("Text_1"):setString(g_tr("batchAdd"))
  self:regBtnCallback(btnBatchAdd, handler(self, self.onBatchAdd)) 

  local Panel_2 = scaleNode:getChildByName("Panel_ronglian2")
  Panel_2:getChildByName("Text_5"):setString(g_tr("corDecomposeTips2"))

  self.listView = Panel_2:getChildByName("ListView_1") 

  local btnDecompose = Panel_2:getChildByName("Button_fj")
  btnDecompose:getChildByName("Text_1"):setString(g_tr("coT5"))
  self:regBtnCallback(btnDecompose, handler(self, self.onStartDecompose)) 

  self:updateUI()
end 

function CorDecomposeView:onManualAdd(sender) 
  print("onManualAdd")
  if self:getInAni() then return end 

  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local k = sender:getTag() 

  --如果已选则清除
  if self.matInfo[k].selectedNum > 0 then 
    self.matInfo[k].selectedNum = 0 

    self:updateUI()

  else 
    --手动添加
    local function selecteResult(dataArray) 
      print("selecteResult")
      if nil == viewObj then return end 

      self.matInfo = dataArray 
      self:updateUI()
    end 

    local layer = require("game.uilayer.cornucopia.CorDecomposeSelectView").new(self.matInfo, selecteResult)
    g_sceneManager.addNodeForUI(layer) 
  end 
end 

function CorDecomposeView:onBatchAdd() 
  print("onBatchAdd")

  if self:getInAni() then return end 

  for k, v in pairs(self.matInfo) do 
    self.matInfo[k].selectedNum = math.min(99, v.ownNum)
  end 
  self:updateUI() 
end 

function CorDecomposeView:updateUI() 
  print("updateUI")

  for k, v in pairs(self.matInfo) do 
    if self.imgIcon[k] then 
      self.imgIcon[k]:setCountEnabled(v.selectedNum > 0)
      self.imgIcon[k]:setIconIsGray(v.selectedNum == 0)
      self.imgIcon[k]:setCount(string.format("%d/%d", v.selectedNum, v.ownNum)) 
    end 

    if self.imgAdd[k] then 
      self.imgAdd[k]:setVisible(v.selectedNum == 0)
    end 

    if self.imgRemove[k] then 
      self.imgRemove[k]:setVisible(v.selectedNum > 0)
    end 
  end 

  --更新右边获得材料 
  self:showGainedMats() 
end 

function CorDecomposeView:onStartDecompose() 
  print("onStartDecompose")

  if self:getInAni() then return end 

  local function decomposeResult(result, data)
    print("decomposeResult:", result)

    if nil == viewObj then return end 

    if result then 

      self.isPlayingAnim = true 

      local function animEnd()
        if nil == viewObj then return end 

        self.isPlayingAnim = false 
        self:initMatInfos() --clear
        self:updateUI() 

        if self.delegate then 
          self.delegate:updateTopRes()
        end 
      end 
      self:playDecomposeAnim(animEnd) 
    end 
  end 

  local function reqToDecompose()
    print("reqToDecompose()")
    --提示选择盔甲
    local items = {}
    local totalSelCount = 0 
    for k, v in pairs(self.matInfo) do 
      if v.selectedNum > 0 then 
        items[tostring(v.id)] = v.selectedNum
        totalSelCount = totalSelCount + v.selectedNum 
      end 
    end 
    if totalSelCount == 0 then 
      g_airBox.show(g_tr("corDecomposeSelectTips"))
      return 
    end 

    --开始熔炼
    g_sgHttp.postData("pub/smeltingGodArmor", {itemList = items}, decomposeResult) 
  end 

  --头部和肩部熔炼时需要提示
  if self.matInfo[1].selectedNum > 0 or self.matInfo[2].selectedNum > 0 then 
    g_msgBox.show(g_tr("corDecomposePopDesc"), g_tr("corDecomposePopTitle"), nil, function(eventType)
        if eventType == 0 then --确定
          reqToDecompose()
        end 
      end, 
      1)
    return 
  else 
    reqToDecompose()
  end 
end 

function CorDecomposeView:showGainedMats()
  self.listView:removeAllChildren()
  self.listView:setBounceEnabled(true)
  self.listView:setScrollBarEnabled(false)

  local mats = self:getGainedMats()

  local dataLen = #mats
  if dataLen > 0 then 
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
          child = require("game.uilayer.common.DropItemView").new(mats[idx][1], mats[idx][2], mats[idx][3]) 
          if child then 
            child:setPosition(cc.p(k*gridSize-gridSize/2, gridSize/2)) 
            child:setScale(iconSize/child:getContentSize().width) 
            child:setNameVisible(false) 
            viewItem:addChild(child) 
          end 
        end 
      end 
      self.listView:pushBackCustomItem(viewItem) 
    end 
  end 
end 

function CorDecomposeView:getGainedMats()
  local tbl = {}

  local function combineMat(mat, multiple)
    local addCount = mat[3] * multiple

    local found = false 

    for k, v in pairs(tbl) do 
      if v[2] == mat[2] then --已存在则合并数量
        tbl[k][3] = tbl[k][3] + addCount
        found = true 
        break 
      end 
    end 

    if not found then 
      table.insert(tbl, {mat[1], mat[2], addCount})
    end 
  end 

  local item, drop  
  for k, v in pairs(self.matInfo) do 
    if v.selectedNum > 0 then 
      item = g_data.item[v.id]
      if item and item.decomposition and item.decomposition > 0 then 
        drop = g_data.drop[item.decomposition] 
        if drop then 
          for i, mat in pairs(drop.drop_data) do 
            combineMat(mat, v.selectedNum) 
          end 
        end 
      end 
    end 
  end 

  return tbl 
end 

function CorDecomposeView:playBackGroundAnim(node, pos)
  local armature, animation = g_gameTools.LoadCocosAni(
    "anime/Effect_NewRongLianBeiJing/Effect_NewRongLianBeiJing.ExportJson"
    , "Effect_NewRongLianBeiJing"
    -- , onMovementEventCallFunc1
    --, onFrameEventCallFunc
    )
  armature:setPosition(pos or cc.p(0, 0))
  node:addChild(armature)
  animation:play("Animation1")  
end 

function CorDecomposeView:playDecomposeAnim(animEndCallback)
  if nil == viewObj then return end 

  self.animNode:removeAllChildren()

  local armature, animation

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

      --2.播放闪爆动画 
      armature, animation = g_gameTools.LoadCocosAni(
        "anime/Effect_NewRongLian/Effect_NewRongLian.ExportJson"
        , "Effect_NewRongLian"
        , onMovementEventCallFunc2
      )
      armature:setPosition(cc.p(self.animNode:getContentSize().width/2, self.animNode:getContentSize().height/2))
      self.animNode:addChild(armature)
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
  armature:setPosition(cc.p(self.animNode:getContentSize().width/2, self.animNode:getContentSize().height/2))
  self.animNode:addChild(armature)
  animation:play("Animation1")  
end 

function CorDecomposeView:getInAni()
  return self.isPlayingAnim  
end

return  CorDecomposeView
