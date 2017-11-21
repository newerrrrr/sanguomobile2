
local Science = require("game.uilayer.science.Science")
local SciencePopup = class("SciencePopup",require("game.uilayer.base.BaseLayer"))

function SciencePopup:ctor()
  SciencePopup.super.ctor(self)
end 

function SciencePopup:onEnter()
  print("SciencePopup:onEnter")
end 

function SciencePopup:onExit() 
  print("SciencePopup:onExit") 

end 

function SciencePopup:initWidget(itemMode)
  if nil == self.layer then 
    self.layer = g_gameTools.LoadCocosUI("tech_popup.csb",5) 
    if self.layer then 
      self:addChild(self.layer) 
      local scale_node = self.layer:getChildByName("scale_node")
      self.contentFrame = scale_node:getChildByName("content_popup")
      local lbTitle = self.contentFrame:getChildByName("bg_title"):getChildByName("Text")
      self.imgIcon = self.contentFrame:getChildByName("item"):getChildByName("pic")
      self.lbLevel = self.contentFrame:getChildByName("item"):getChildByName("level")
      self.lbName = self.contentFrame:getChildByName("item"):getChildByName("name")
      self.listView = self.contentFrame:getChildByName("ListView_2")       

      --立即完成
      self.nodeBuyComplete = self.contentFrame:getChildByName("Panel_complete") 
      local btnComplete = self.nodeBuyComplete:getChildByName("btn_complete") 
      local lbComplete = self.nodeBuyComplete:getChildByName("btn_complete"):getChildByName("Text_1") 
      self.lbMoney = self.nodeBuyComplete:getChildByName("text_price") 

      --道具加速
      self.btnSpeed = self.contentFrame:getChildByName("btn_jiasu") 
      local lbSpeed = self.btnSpeed:getChildByName("Text_1") 

      --开始升级
      self.nodeLearn = self.contentFrame:getChildByName("Panel_update") 
      local btnStudy = self.nodeLearn:getChildByName("btn_update") 
      local lbStudy = self.nodeLearn:getChildByName("btn_update"):getChildByName("Text_1") 
      self.lbTime = self.nodeLearn:getChildByName("text_time") 

      local btnClose = scale_node:getChildByName("content_popup"):getChildByName("close_btn")     
      local lbRequire = scale_node:getChildByName("bg_require"):getChildByName("Text") 

      local Panel_5 = scale_node:getChildByName("Panel_5")
      local lbPreCurLv = Panel_5:getChildByName("text_name_1")
      local lbPreNextLv = Panel_5:getChildByName("text_name_1_0") 
      self.lbCurLevel =  Panel_5:getChildByName("num_1")
      self.lbNextLevel =  Panel_5:getChildByName("num_3")
      self.lbBufInfo = Panel_5:getChildByName("text_desc") 

      self:regBtnCallback(btnComplete, handler(self, self.buyComplete))
      self:regBtnCallback(self.btnSpeed, handler(self, self.onItemSpeedup))
      self:regBtnCallback(btnStudy, handler(self, self.startLearning))
      self:regBtnCallback(btnClose, handler(self, self.close))

      lbTitle:setString(g_tr("scienceResearch"))
      lbComplete:setString(g_tr("completeImmediately"))
      lbStudy:setString(g_tr("startLearning"))
      lbRequire:setString(g_tr("researchRequirement"))
      lbPreCurLv:setString(g_tr("curLevel"))
      lbPreNextLv:setString(g_tr("nextLevel"))
      lbSpeed:setString(g_tr("itemSpeedup"))


      --新手引导
      g_guideManager.registComponent(1002110, btnStudy)
      g_guideManager.execute()       
    end 
  end

  if self.layer then 
    local baseInfo = itemMode:getBaseInfo()
    --科技名/等级
    self.lbName:setString(g_tr(baseInfo.name))
    local curLv, maxLv = itemMode:getCurMaxLevel()
    self.lbCurLevel:setString(string.format("%d/%d", curLv, maxLv))
    self.lbNextLevel:setString(string.format("%d/%d", math.min(curLv+1, maxLv), maxLv))

    --buf加成
    local curBuf, nextBuf = itemMode:getCurNextBufVal()
    print("===curBuf, nextBuf",curBuf, nextBuf)
    local strBuf = g_tr(baseInfo.description, {max_num = curBuf, next_max_num = nextBuf})
    self.lbBufInfo:setString(strBuf)

    --self.lbBufInfo:setVisible(false)
    if self.rich == nil then
      self.rich = g_gameTools.createRichText(self.lbBufInfo, strBuf)
    else
      --self.rich:removeAllProtectedChildrenWithCleanup(true)
      self.rich:setRichText(strBuf)
    end
  end 
end 

--科技已满
function SciencePopup:showFinishPop(itemMode)
  print("showFinishPop")
  self:initWidget(itemMode)
  if nil == self.layer then 
    return 
  end 

  Science:instance():stopLearningAnim(self.imgIcon)

  self.itemMode = itemMode 
  local baseInfo = itemMode:getBaseInfo()

  self.lbName:setString(g_tr(baseInfo.name))
  self.lbLevel:setString(string.format("%d/%d", baseInfo.max_level, baseInfo.max_level))
  self.lbLevel:setTextColor(cc.c3b(72, 255, 98))

  self.imgIcon:loadTexture(g_resManager.getResPath(baseInfo.img))

  self.nodeBuyComplete:setVisible(false)
  self.nodeLearn:setVisible(false)
  self.btnSpeed:setVisible(false)

  local contentLayer = self:getFinishContent(itemMode)
  if contentLayer then 
    self.listView:removeAllChildren() 
    self.listView:setInnerContainerSize(contentLayer:getContentSize()) 
    self.listView:setScrollBarEnabled(false) 
    self.listView:addChild(contentLayer) 
  end   
end 

--正在学习
function SciencePopup:showLearnningPop(itemMode)
  print("showLearnningPop")
  self:initWidget(itemMode)
  if nil == self.layer then 
    return 
  end  

  self.itemMode = itemMode 
  local baseInfo = itemMode:getBaseInfo()
  local curLv, maxLv = itemMode:getCurMaxLevel()
  self.lbName:setString(g_tr(baseInfo.name))
  self.lbLevel:setString(string.format("%d/%d", curLv, maxLv))
  self.imgIcon:loadTexture(g_resManager.getResPath(baseInfo.img))

  print("end_time, curtime", itemMode:getEndTime(), g_clock.getCurServerTime())
  local needTime, needMoney = Science:instance():getNeedTimeMoney(itemMode)
  self.lbMoney:setString(string.format("%d", needMoney)) 

  self.nodeBuyComplete:setVisible(true)
  self.btnSpeed:setVisible(true)
  self.nodeLearn:setVisible(false)

  local contentLayer = self:getLearningContent(itemMode)
  if contentLayer then 
    self.listView:removeAllChildren() 
    self.listView:setInnerContainerSize(contentLayer:getContentSize()) 
    self.listView:setScrollBarEnabled(false) 
    self.listView:addChild(contentLayer) 
    -- if self.listView:getContentSize().height > self.listView:getInnerContainerSize().height then 
      -- self.listView:setInertiaScrollEnabled(false)
    -- end 
  end 

  Science:instance():playLearningAnim(self.imgIcon)
end 

--可学习/条件开启
function SciencePopup:showLearnablePop(itemMode)
  print("getLearnablePop")
  self:initWidget(itemMode)
  if nil == self.layer then 
    return 
  end 
  self.itemMode = itemMode 

  Science:instance():stopLearningAnim(self.imgIcon)

  local baseInfo = itemMode:getBaseInfo()
  local curLv, maxLv = itemMode:getCurMaxLevel()
  self.lbName:setString(g_tr(baseInfo.name))
  self.lbLevel:setString(string.format("%d/%d", curLv, maxLv))
  self.imgIcon:loadTexture(g_resManager.getResPath(baseInfo.img))

  local size = self.contentFrame:getContentSize()
  self.nodeBuyComplete:setVisible(true)
  self.nodeLearn:setVisible(true)
  self.btnSpeed:setVisible(false)

  local contentLayer = self:getLearnableContent(itemMode)
  if contentLayer then 
    self.listView:removeAllChildren() 
    self.listView:setInnerContainerSize(contentLayer:getContentSize()) 
    self.listView:setScrollBarEnabled(false) 
    self.listView:addChild(contentLayer) 
  end  

  local needTime, needMoney = Science:instance():getNeedTimeMoney(itemMode)
  local hour = math.floor(needTime/3600) 
  local min = math.floor((needTime%3600)/60) 
  local sec = math.floor(needTime%60) 
  self.lbTime:setString(string.format("%02d:%02d:%02d", hour, min, sec)) 
  self.lbMoney:setString(string.format("%d", needMoney)) 
end 


function SciencePopup:showLeftTime(targetTime, label, lbCost)

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

    if lbCost then 
      local cost = math.ceil( math.pow( dt,0.911) * 0.085) 
      lbCost:setString(string.format("%d", cost))
    end 

    if dt <= 0 then 
      Science:instance():stopLearningAnim(self.imgIcon)
      Science:instance():playLearnCompleteAnim(self.imgIcon)

      self:getDelegate():checkIsFinish(self.itemMode)
      g_ScienceMode.RequestData()  --重新更新服务器数据
      self:getDelegate():updateNodeItem(self.itemMode) --更新科技树icon状态

      local status = Science:instance():getStateByType(self.itemMode:getTypeId()) 
      print("status", status)
      if status == 2 then --科技已满
        self:showFinishPop(self.itemMode)
      elseif status == 3 then --正在学习
        self:showLearnningPop(self.itemMode)
      else 
        self:showLearnablePop(self.itemMode)
      end 
    end 
  end 

  if self.buildTimer then 
    self:unschedule(self.buildTimer)
    self.buildTimer = nil 
  end 

  if targetTime > g_clock.getCurServerTime() then 
    updateTime()
    self.buildTimer = self:schedule(updateTime, 1.0)
  end 
end 

--科技已满详情
function SciencePopup:getFinishContent(itemMode)
  local baseInfo = itemMode:getBaseInfo()
  local layer = cc.CSLoader:createNode("tech_popup_list_3.csb")
  if layer then  
    layer:getChildByName("Text_1"):setVisible(false)
    layer:getChildByName("Text_2"):setVisible(false)
    layer:getChildByName("Text_3"):setString(g_tr("isTopScience"))

    return layer 
  end
end 

--可学习详情
function SciencePopup:getLearnableContent(itemMode) 
  local baseInfo = itemMode:getBaseInfo()

  --获取目标科技的信息
  local nextId = baseInfo.next_science 
  if not Science:instance():isLearned(baseInfo.id) then 
    nextId = baseInfo.id 
  end 
  local nextInfo = g_data.science[nextId]
  if nil == nextInfo then return end 

  local layer = cc.CSLoader:createNode("tech_popup_list_1.csb")
  if layer then 
    local nodeParent = layer:getChildByName("Panel_5")
    local iconBuild = nodeParent:getChildByName("text_tech_1"):getChildByName("Image_icon") 
    local lbBuildLevel = nodeParent:getChildByName("text_tech_1"):getChildByName("text_require_1") 
    local nodeTech = nodeParent:getChildByName("text_tech_2") 
    local nodeMat1 = nodeParent:getChildByName("get_material_row_1") 
    local nodeMat2 = nodeParent:getChildByName("get_material_row_2") 
    local nodeMat3 = nodeParent:getChildByName("get_material_row_3") 
    local nodeMat4 = nodeParent:getChildByName("get_material_row_4") 
    local nodeMat5 = nodeParent:getChildByName("get_material_row_5") 
    self.nodeMat = {nodeMat1, nodeMat2, nodeMat3, nodeMat4, nodeMat5}

    --建筑等级要求
    lbBuildLevel:setString(g_tr("scienceBuildLevel", {lv = nextInfo.build_level}))
    local buildLevel, build_id = Science:instance():getScienceBuildLevel()
    local color = buildLevel >= nextInfo.build_level and cc.c4b(255,255,255,255) or cc.c4b(255,0,0,255) 
    lbBuildLevel:setTextColor(color)
    if build_id then 
      iconBuild:loadTexture(g_resManager.getResPath(g_data.build[build_id].choose_img))
    end 

    --(下一级的)前提科技(动态增加)
    self.needTechIsOk = true 
    local x, y = nodeTech:getPosition()
    
    if (#nextInfo.condition_science == 1 and nextInfo.condition_science[1] == 0) then 
      nodeTech:setVisible(false)
    else 

      local item_new, color, sci 
      local count = 0  
      for k, id in pairs(nextInfo.condition_science) do 
        if id > 0 then 
          count = count + 1 
          if count == 1 then 
            item_new = nodeTech 
          else 
            item_new = nodeTech:clone()
            y = y - nodeTech:getContentSize().height
            item_new:setPosition(cc.p(x, y))
            nodeTech:getParent():addChild(item_new)
          end 

          sci = g_data.science[id]
          item_new:getChildByName("text_science"):setString(g_tr("tech_%{name}", {name=g_tr(sci.name),level=sci.level_id})) 
          item_new:getChildByName("Image_icon"):loadTexture(g_resManager.getResPath(sci.img))

          color = cc.c4b(255,255,255,255)
          if not Science:instance():isLearned(id) then 
            self.needTechIsOk = false 
            color = cc.c4b(255,0,0,255) 
          end 
          item_new:getChildByName("text_science"):setTextColor(color)
        end 
      end       
    end 

    --需要的材料(动态增加)
    self.hasEnoughMat = true 

    local matCount = 0 
    local matItemHeight = self.nodeMat[1]:getContentSize().height 
    for i=1, #self.nodeMat do 
      self.nodeMat[i]:setVisible(false)
    end 

    local allbuffs = g_BuffMode.GetData()
    local ownNum, costNum, path, color 
    for k, v in pairs(nextInfo.cost) do 
      matCount = matCount + 1 
      y = y - matItemHeight
      self.nodeMat[matCount]:setVisible(true)
      self.nodeMat[matCount]:setPosition(cc.p(x, y))

      local icon = self.nodeMat[matCount]:getChildByName("bg_text")
      local lbNum = self.nodeMat[matCount]:getChildByName("text_num")
      local btnMore = self.nodeMat[matCount]:getChildByName("btn_get_more")
      local imgPass = self.nodeMat[matCount]:getChildByName("Image_3")
      local imgFail = self.nodeMat[matCount]:getChildByName("Image_3_0")

      ownNum, path = g_gameTools.getPlayerCurrencyCount(v[1])
      icon:loadTexture(path)
      costNum = v[2]

      --buff：使科技升级所需的资源量减少      
      if allbuffs and allbuffs["research_cost_reduce"] then
        local val = tonumber(allbuffs["research_cost_reduce"].v)/10000
        if val > 0 then 
          costNum = math.ceil( costNum*(1-val) )
          print("buff mat cost:", v[2], costNum)
        end 
      end 

      if ownNum >= costNum then 
        color = cc.c4b(255,255,255,255)
        imgPass:setVisible(true)
        imgFail:setVisible(false)
        btnMore:setVisible(false)
      else 
        color = cc.c4b(255,0,0,255) 
        imgPass:setVisible(false)
        imgFail:setVisible(true) 
        btnMore:setVisible(true)  
        self.hasEnoughMat = false 
      end 

      lbNum:setString(ownNum.."/"..costNum) 
      lbNum:setTextColor(color)
      btnMore:setTag(v[1])
      btnMore:getChildByName("text"):setString(g_tr("getMoreMat"))
      self:regBtnCallback(btnMore, handler(self, self.onGetMoreMat))
    end 

    y = y - 25 
    nodeParent:setPositionY(-y)
    layer:setContentSize(cc.size(layer:getContentSize().width, -y))
  end 

  return layer 
end 

--正在学习详情
function SciencePopup:getLearningContent(itemMode)
  
  local layer = cc.CSLoader:createNode("tech_popup_list_3.csb")
  if layer then  
    layer:getChildByName("Text_1"):setString(g_tr("leftTime"))
    self.lbLeftTime = layer:getChildByName("Text_2")
    layer:getChildByName("Text_3"):setVisible(false)

    self:showLeftTime(itemMode:getEndTime(), self.lbLeftTime, self.lbMoney)

    return layer 
  end 
end 

--立即完成: 只有在可学习/正在学习 时才有效
function SciencePopup:buyComplete() 
  print("buyComplete")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if nil == self.itemMode then 
    return 
  end 

  local baseInfo = self.itemMode:getBaseInfo() 
  if not self.itemMode:isLearning() then     
    if Science:instance():getScienceBuildLevel() < baseInfo.build_level then 
      g_airBox.show(g_tr("sciBuildLowLevel"))
      return 
    end 

    if not self.needTechIsOk then 
      g_airBox.show(g_tr("preTechNotLearned"))
      return 
    end 
  end 

  local playerData = g_PlayerMode.GetData() 
  local myMoney = playerData.rmb_gem + playerData.gift_gem 
  local needTime, needMoney = Science:instance():getNeedTimeMoney(self.itemMode)
  print("myMoney,needMoney", myMoney,needMoney)
  if myMoney < needMoney then 
    g_airBox.show(g_tr("no_enough_money"))
    return 
  end 


  local function startToBuyFinish()
    --send msg 
    local function buyResult(result, data)
      print("buyResult:", result)
      if result then 

        Science:instance():stopLearningAnim(self.imgIcon)
        Science:instance():playLearnCompleteAnim(self.imgIcon)

        --数据已在后台 scienceData.lua 同步 
        local modeData = Science:instance():getModeData()
        local itemMode = modeData[self.itemMode:getTypeId()]
        local curLv, maxLv = itemMode:getCurMaxLevel()
        if curLv >= maxLv then --科技已满
          self:showFinishPop(itemMode)
        else 
          self:showLearnablePop(itemMode)
        end 

        --更新外部界面
        if self:getDelegate() then 
          self:getDelegate():updateNodeItem(itemMode, true)
        end 

      else --出错后同步下数据
        g_ScienceMode.RequestData(true)
      end 
    end 

    if self.buildTimer then 
      self:unschedule(self.buildTimer)
      self.buildTimer = nil 
    end 

    print("", self.itemMode:isLearning())
    if self.itemMode:isLearning() then --加速
      g_sgHttp.postData("Science/accelerate", {scienceTypeId=baseInfo.science_type_id, type=2}, buyResult) 
    else --立即完成
      g_sgHttp.postData("Science/begin", {scienceTypeId=baseInfo.science_type_id, type=2}, buyResult)  
    end 
  end 


  local needTime, needMoney = Science:instance():getNeedTimeMoney(self.itemMode)
  if self.itemMode:isLearning() then --正在学习中的加速
    g_msgBox.showSpeedUp(g_clock.getCurServerTime()+needTime, g_tr("speedUpSciLearningCD"), nil, nil, startToBuyFinish) 
  else 

    --另一科技正在升级中
    local sciName, mode = Science:instance():getLearningScience()
    local function onAccelerate() --正在学习加速
      local function acceResult(result, data)
        print("acceResult", result)
        if result then 
          if self:getDelegate() then 
            self:getDelegate():updateNodeItem(mode, true)
          end 
        else --出错后同步下数据
          g_ScienceMode.RequestData(true)          
        end 
      end 
      g_sgHttp.postData("Science/accelerate", {scienceTypeId = mode:getBaseInfo().science_type_id, type = 2}, acceResult) 
    end 

    if mode then 
      local needTime, needMoney = Science:instance():getNeedTimeMoney(mode)
      g_msgBox.showSpeedUp(g_clock.getCurServerTime()+needTime, g_tr("speedUpSciTips", {name = sciName, num = needMoney}), nil, nil, onAccelerate) 
    else 
      g_msgBox.showConsume(needMoney, g_tr("buyToFinishTips",{num = needMoney}), nil, nil, startToBuyFinish)
    end 
  end 
end 

--道具加速
function SciencePopup:onItemSpeedup(bNoSound)
  print("onItemSpeedup")
  if not bNoSound then 
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  end 

  local buildInfo = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.institute)
  if nil == buildInfo or nil == buildInfo[1] then return end 

  local function speedupResult()
    print("speedupResult")
    --数据已在后台 scienceData.lua 同步 
    local modeData = Science:instance():getModeData()
    local itemMode = modeData[self.itemMode:getTypeId()]
    --更新外部界面
    if self:getDelegate() then 
      self:getDelegate():updateNodeItem(itemMode, true)
    end 

    if self.buildTimer then 
      self:unschedule(self.buildTimer)
      self.buildTimer = nil 
    end 

    local leftTime = itemMode:getEndTime() - g_clock.getCurServerTime()            
    if leftTime > 0 then 
      self:showLeftTime(itemMode:getEndTime(), self.lbLeftTime, self.lbMoney)
    else 
      g_airBox.show(g_tr("sciLevelupSuccess"))
      Science:instance():stopLearningAnim(self.imgIcon)
      Science:instance():playLearnCompleteAnim(self.imgIcon)      
      local curLv, maxLv = itemMode:getCurMaxLevel()
      if curLv >= maxLv then --科技已满
        self:showFinishPop(itemMode)
      else 
        self:showLearnablePop(itemMode)
      end 
    end 
  end 

  local serverData = buildInfo[1]
  local position = serverData.position
  local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Study,speedupResult)
  g_sceneManager.addNodeForUI(view) 
end 

--开始学习
function SciencePopup:startLearning(sender)
  print("startLearning")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if nil == self.itemMode then return end 

  local baseInfo = self.itemMode:getBaseInfo() 
  if Science:instance():getScienceBuildLevel() < baseInfo.build_level then 
    g_airBox.show(g_tr("sciBuildLowLevel"))
    return 
  end 

  if not self.needTechIsOk then 
    g_airBox.show(g_tr("preTechNotLearned"))
    return 
  end 

  if not self.hasEnoughMat then 
    g_airBox.show(g_tr("no_enough_material"))
    return 
  end 

  local function startToLearn()
    --send msg 
    self.buildResult = function(result, data)
      print("buildResult:", result)
      if result then 
        --数据已在后台 scienceData.lua 同步 

        --显示正在学习详情
        self:showLearnningPop(self.itemMode)

        --更新外部界面
        if self:getDelegate() then 
          self:getDelegate():updateNodeItem(self.itemMode, true)
        end

        --弹出道具家属界面,方便小白玩家
        self:onItemSpeedup(true)

      else --出错后同步下数据
        g_ScienceMode.RequestData(true)          
      end 
      --新手引导 
      g_guideManager.execute() 
    end 
 
    g_sgHttp.postData("Science/begin", {scienceTypeId=baseInfo.science_type_id, type=1,steps=g_guideManager.getToSaveStepId()}, handler(self, self.buildResult)) 
    Science:instance():playLearnBeginAnim(self.imgIcon)      
  end 



  --另一科技正在升级中
  local sciName, mode = Science:instance():getLearningScience()
  local function onAccelerate() --正在学习加速
    local function acceResult(result, data)
      print("acceResult", result)
      if result then 
        if self:getDelegate() then 
          self:getDelegate():updateNodeItem(mode, true)
        end 
      else --出错后同步下数据
        g_ScienceMode.RequestData(true)         
      end 
    end 
    g_sgHttp.postData("Science/accelerate", {scienceTypeId = mode:getBaseInfo().science_type_id, type = 2}, acceResult) 
  end 

  if mode then 
    local needTime, needMoney = Science:instance():getNeedTimeMoney(mode)
    g_msgBox.showSpeedUp(g_clock.getCurServerTime()+needTime, g_tr("speedUpSciTips", {name = sciName, num = needMoney}), nil, nil, onAccelerate) 
  else 
    startToLearn()
  end 
end 

function SciencePopup:onGetMoreMat(sender)
  print("onGetMoreMat")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  self:removeFromParent()

  -- local shopLayer = require("game.uilayer.shop.ShopLayer"):create(g_Consts.ShopType.NORMAL)
  -- g_sceneManager.addNodeForUI(shopLayer)  

  require("game.uilayer.shop.UseResourceView").show(sender:getTag())
end 


return SciencePopup 