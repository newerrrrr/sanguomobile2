
local Science = require("game.uilayer.science.Science")
local ScienceLayer = class("ScienceLayer",require("game.uilayer.base.BaseLayer"))
local animTag = Science:instance():getAnimTagEnum()
local sciTag = {
  tag_list_item_child = 999,
  tag_list_item_begin = 1000,
  tag_learn_begin = 2000,
  tag_learning = 2001,
  tag_learn_complete = 2002
  }

--scienceType: 1:军事, 2:内政
--preFocusSciId: 首次进入需要高亮的科技表id, 如science表的8401
function ScienceLayer:ctor(scienceType, preFocusSciId)
  ScienceLayer.super.ctor(self)
  print("ScienceLayer:ctor", scienceType, preFocusSciTypeId)

  g_ScienceMode.GetData()

  dump(g_ScienceMode.GetData())

  self.scienceType = scienceType
  if preFocusSciId and g_data.science[preFocusSciId] then 
    self.preFocusSciTypeId = g_data.science[preFocusSciId].science_type_id
  end 
  print("@@@ learning science:", Science:instance():getLearningScience())
end 

function ScienceLayer:onEnter()
  print("ScienceLayer:onEnter")

  self.listItem1 = cc.CSLoader:createNode("tech_tree_1.csb")
  self.listItem1:retain()
  self.listItem2 = cc.CSLoader:createNode("tech_tree_2.csb")
  self.listItem2:retain()
  self.tech_item = cc.CSLoader:createNode("tech_item.csb") 
  self.tech_item:retain()
  
  local layer = g_gameTools.LoadCocosUI("tech_tree_main.csb",5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showScienceTree(self.scienceType)

    g_resourcesInterface.installResources(layer)
  end 
end 

function ScienceLayer:onExit() 
  print("ScienceLayer:onExit") 
  self.tech_item:release()
  self.listItem1:release()
  self.listItem2:release()

  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer)
    self.frameLoadTimer = nil 
  end   
end 

function ScienceLayer:initBinding(scaleNode)
  local lbTitle = scaleNode:getChildByName("Text_bt")
  local btnClose = scaleNode:getChildByName("close_btn")
  local btnArmy = scaleNode:getChildByName("Button_1")
  local lbArmy = scaleNode:getChildByName("Button_1"):getChildByName("Text")
  local btnPolity = scaleNode:getChildByName("Button_2")
  local lbPolity = scaleNode:getChildByName("Button_2"):getChildByName("Text")
  self.listView = scaleNode:getChildByName("ListView_1") 

  self.btnScience = {btnArmy, btnPolity}
  self:regBtnCallback(btnClose, handler(self, self.close))
  self:regBtnCallback(btnArmy, handler(self, self.onScienceArmy))
  self:regBtnCallback(btnPolity, handler(self, self.onSciencePolity))
  lbTitle:setString(g_tr_original("sciTitle"))
  lbArmy:setString(g_tr_original("scienceArmy"))
  lbPolity:setString(g_tr_original("sciencePolity"))
end 


function ScienceLayer:onScienceArmy()
  print("onScienceArmy")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self.scienceType == 1 then return end 

  self:showScienceTree(1)
end 

function ScienceLayer:onSciencePolity() 
  print("onSciencePolity") 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self.scienceType == 2 then return end 
  self:showScienceTree(2) 
end 

function ScienceLayer:showScienceTree(scienceType)
  print("showScienceTree:", scienceType)

  scienceType = scienceType or 1 
  for i=1, 2 do 
    self.btnScience[i]:setHighlighted(i==scienceType)
  end 

  self.scienceType = scienceType 

  self.listView:removeAllChildren()
  local listItem = (scienceType == 1) and self.listItem1 or self.listItem2 
  self.idx_s = (scienceType == 1) and 1 or 84 
  self.idx_e = (scienceType == 1) and 83 or 143 

  if listItem then 
    self.listView:setInnerContainerSize(listItem:getContentSize())
    self.listView:addChild(listItem)
    self.listView:jumpToLeft()
    self:initTree(listItem)
  end 
end 

function ScienceLayer:onTouchNodeItem(sender)
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local idx = sender:getTag() - sciTag.tag_list_item_begin 
  print("onTouchItem", idx)
  if idx >= 1 and idx <= 143 then 
    local layer = require("game.uilayer.science.SciencePopup").new() 
    layer:setDelegate(self)
    g_sceneManager.addNodeForUI(layer)
    local modeData = Science:instance():getModeData()
    local state = Science:instance():getStateByType(idx)
    print("==idx, state=", idx, state)

    if state == 1 then --可学习
      layer:showLearnablePop(modeData[idx])
    elseif state == 2 then --科技已满
      layer:showFinishPop(modeData[idx]) 
    elseif state == 3 then --正在学习
      layer:showLearnningPop(modeData[idx])
    elseif state == 4 then --条件开启
      layer:showLearnablePop(modeData[idx]) 
    elseif state == 5 then --建筑等级不足
      layer:showLearnablePop(modeData[idx]) 
    end 
  else 
    print("invalid idx of item !")
  end 
end 

function ScienceLayer:updateNodeItem(scienceMode, needResetTimer)
  local function showLeftTime(targetTime, label, icon)
    local function updateTime()
      local dt = targetTime - g_clock.getCurServerTime()
      if dt <= 0 then        
        dt = 0 
        self:unschedule(self.buildTimer)
        self.buildTimer = nil 
      end 

      local hour = math.floor(dt/3600)
      local min = math.floor((dt%3600)/60)
      local sec = math.floor(dt%60)
      label:setString(string.format("%02d:%02d:%02d", hour, min, sec)) 

      if dt <= 0 then 
        Science:instance():stopLearningAnim(icon)
        Science:instance():playLearnCompleteAnim(icon)

        g_ScienceMode.RequestData()  --重新更新服务器数据
        self:checkIsFinish()
        self:updateNodeItem(self.animSciMode) --更新科技树icon状态
      end 
    end 

    if needResetTimer and self.buildTimer then 
      self:unschedule(self.buildTimer)
      self.buildTimer = nil 
    end 

    Science:instance():stopLearningAnim(icon)

    --播放正在研究动画
    if targetTime > g_clock.getCurServerTime() then    
      local dt = targetTime - g_clock.getCurServerTime()
      local hour = math.floor(dt/3600)
      local min = math.floor((dt%3600)/60)
      local sec = math.floor(dt%60)
      label:setString(string.format("%02d:%02d:%02d", hour, min, sec)) 
      self.buildTimer = self:schedule(updateTime, 1.0)

      Science:instance():playLearningAnim(icon)
      self.animSciMode = scienceMode 
    else 
      label:setString("")
    end 
  end 




  if nil == self.listItem then return end 

  local idx = scienceMode:getTypeId() 
  if idx < self.idx_s or idx > self.idx_e then return end 

  local itemLayout = self.listItem:getChildByName("drag_content"):getChildByName(string.format("item_%d", idx))
  local child = itemLayout:getChildByTag(sciTag.tag_list_item_child)
  if nil == child then 
    child = self.tech_item:clone()
    child:setTag(sciTag.tag_list_item_child)
    child:setPosition(cc.p(-child:getContentSize().width/2, -child:getContentSize().height/2))      
    itemLayout:addChild(child) 
  end 

  --初始化item
  local item = child:getChildByName("item")
  local icon = item:getChildByName("pic") 
  local lbLevel = item:getChildByName("level") 
  local lbName = item:getChildByName("name")
  local lbTime = item:getChildByName("time")
  item:setTag(sciTag.tag_list_item_begin + idx)
  self:regBtnCallback(item, handler(self, self.onTouchNodeItem))
  local curLv, maxLv = scienceMode:getCurMaxLevel()
  lbLevel:setString(string.format("%d/%d", curLv, maxLv)) 
  if curLv >= maxLv then 
    lbLevel:setTextColor(cc.c3b(72, 255, 98))
  end 
  --剩余时间
  showLeftTime(scienceMode:getEndTime(), lbTime, icon)

  if scienceMode:isLearningEnd() then 
    print("=== isLearningEnd:", idx)
    self:checkIsFinish(scienceMode)
  end 

  local baseInfo = scienceMode:getBaseInfo()
  lbName:setString(g_tr(baseInfo.name))
  icon:loadTexture(g_resManager.getResPath(baseInfo.img))
  if baseInfo.build_level > Science:instance():getScienceBuildLevel() then 
    icon:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.shaderMode.shader_gray))
  end 
  
  --高亮动画
  if icon:getChildByTag(animTag.hightlight) then 
    icon:removeChildByTag(animTag.hightlight) 
  end 
  if self.preFocusSciTypeId and self.preFocusSciTypeId == idx then --高亮该项科技
    self.preFocusSciTypeId = nil 
    Science:instance():playHighlightAnim(icon)
  end 

  --新手引导
  if self.scienceType == 1 and idx == self.idx_s then --军事第一项
    g_guideManager.registComponent(1001110, icon)
    g_guideManager.execute()
  end 
end 


--采用分帧加载, 提升界面流畅性
function ScienceLayer:initTree(listItem)
  local idx_s = self.idx_s 
  local idx_e = self.idx_e 

  self.listItem = listItem 

  local function frameLoadItems()
    local modeData = Science:instance():getModeData()
    local endIndex = math.min(idx_s+3, idx_e)
    for i=idx_s, endIndex do 
      self:updateNodeItem(modeData[i])
    end 

    idx_s = endIndex+1 
    if idx_s > idx_e then 
      if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
      end 
    end 
  end 

  if self.buildTimer then 
    self:unschedule(self.buildTimer)
    self.buildTimer = nil 
  end 

  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end 
  self.frameLoadTimer = self:schedule(frameLoadItems, 0) 
end 

--将学习结束的通知服务器
function ScienceLayer:checkIsFinish(scienceMode)
  local function checkResult(result, data)
    print("checkIsFinish result:", result)
    if result then 
      if scienceMode then 
        scienceMode:setLearningEnd()
        self:updateNodeItem(scienceMode)
      end 
    end 
  end 
  g_sgHttp.postData("Science/finish", {}, checkResult) 
end 



return ScienceLayer 