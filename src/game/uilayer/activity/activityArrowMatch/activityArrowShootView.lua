
--射箭界面

local activityArrowShootView = class("activityArrowShootView",require("game.uilayer.base.BaseLayer"))
local ActivityArrowMode = require("game.uilayer.activity.activityArrowMatch.activityArrowMode")

local viewObj 
local dataDurty = false 
--
function activityArrowShootView:ctor(data, selectedGens, perCount, windDirId)
  activityArrowShootView.super.ctor(self)

  viewObj = self 

  self.data = data 
  self.selGens = selectedGens --当前上阵武将
  self.perCount = perCount or 1 --每次射箭数
  self.powerStatus = 0 -- 0:初始 1:动画展示 2:已设定
  self.angleStatus = 0  -- 0:初始 1:动画展示 2:已设定
  self.powerFrameIndex = 0
  self.angleFrameIndex = 0 

  self.powerVal = 0 --当前选中的力度值
  self.angleVal = 0  --当前选中的角度值

  self.curWind = windDirId or 3 --当前风向
  self.curWinVal = 0


  --每一帧对应的进度条参考值, 1--12 帧从0-100%, 13->23 帧100%->0
  self.powerFrameMap = { 1, 2,  3,  6,  10,  14,  19,  19, 29, 35,
                        37, 37, 36, 35, 29, 19,  19,  14,  10,  6,  
                        3 , 2,  1,  1,
                      }

  --每一帧对应的角度条参考值 1-15 从0-100%, 15->30帧100%->0
  self.angleFrameMap = {  1, 59, 119, 181, 246, 299, 369, 299, 246, 181,
                        119, 59, 1, 59, 119, 181, 246, 299, 369, 295, 
                        220, 145, 71, 1
                      } 

  math.newrandomseed()

  local layer = g_gameTools.LoadCocosUI("Archery_main1.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    g_resourcesInterface.installResources(layer)
  end 
end 

function activityArrowShootView:onEnter()
  print("activityArrowShootView:onEnter") 
end 

function activityArrowShootView:onExit() 
  print("activityArrowShootView:onExit") 
  viewObj = nil 
  if self:getDelegate() and dataDurty then 
    self:getDelegate():onReqData() 
  end 
end 


function activityArrowShootView:initBinging(layer)
  self.root = layer:getChildByName("scale_node") 

  local btnClose = self.root:getChildByName("close_btn") 
  self:regBtnCallback(btnClose, handler(self, self.close))

  local btnHelp = self.root:getChildByName("Button_wenh") 
  self:regBtnCallback(btnHelp, handler(self, self.onHelp))

  self.root:getChildByName("Text_mingc"):setString(g_tr("arrow_match"))
  self.root:getChildByName("Text_dqfx1"):setString(g_tr("arrow_cur_wind_dir"))  
  self.lbCurWinDir = self.root:getChildByName("Text_nf1")

  self.btnPray = self.root:getChildByName("Button_qfgb1")
  self.btnPray:getChildByName("Text_20"):setString(g_tr("arrow_pray_wind")) 
  self.btnChangePower = self.root:getChildByName("Button_1") 
  self.btnChangeWind = self.root:getChildByName("Button_2") 
  if self.perCount > 1 then --再来10次/再来1次
    self.root:getChildByName("Button_3"):setVisible(false)
    self.btnOnceAgain = self.root:getChildByName("Button_4") 
  else 
    self.root:getChildByName("Button_4"):setVisible(false)
    self.btnOnceAgain = self.root:getChildByName("Button_3") 
  end 
  
  self:regBtnCallback(self.btnPray, handler(self, self.onPrayWind))
  self:regBtnCallback(self.btnChangeWind, handler(self, self.onChangeAngleDir))
  self:regBtnCallback(self.btnChangePower, handler(self, self.onChangePower))
  self:regBtnCallback(self.btnOnceAgain, handler(self, self.onOnceAgain))  

  self.listView = self.root:getChildByName("Panel_1"):getChildByName("ListView_1")

  self.animPower, self.animAngle, self.animArrow = self:getAnim()
  local nodePowerAnim = self.root:getChildByName("Panel_power_anim")
  local nodeAngleAnim = self.root:getChildByName("Panel_angle_anim")
  local nodeArrowAnim = self.root:getChildByName("Panel_arrow_anim")
  nodePowerAnim:getChildByName("Text_ld1"):setString(g_tr("arrow_match_power"))
  nodeAngleAnim:getChildByName("Text_fx"):setString(g_tr("arrow_wind_direction"))
  nodePowerAnim:addChild(self.animPower)
  nodeAngleAnim:addChild(self.animAngle)
  nodeArrowAnim:addChild(self.animArrow)

  self.animArrow:getLHSAnimation():play("la")
  self.animArrow:getLHSAnimation():gotoAndPause(26)

  --默认
  self.btnChangePower:setVisible(true) 
  self.btnChangeWind:setVisible(false) 
  self.btnOnceAgain:setVisible(false) 
  self.btnPray:setVisible(true) 

  if g_data.shoot[self.curWind] then 
    self.lbCurWinDir:setString(g_tr(g_data.shoot[self.curWind].desc))
  end 
end 

 
function activityArrowShootView:onPrayWind() 

  if nil == self.data then return end 

  local function doPray()
    local function onRecv(result, data)
      g_busyTip.hide_1()
      print("=====result", result)
      if result then 
        if nil == viewObj then return end 

        local newWind = math.random(3, 5)
        while(newWind == self.curWind) do 
          newWind = math.random(3, 5) 
        end 
        self.curWind = newWind
        if g_data.shoot[self.curWind] then 
          self.lbCurWinDir:setString(g_tr(g_data.shoot[self.curWind].desc))
        end         
      end 
    end 

    g_sgHttp.postData("Arrow/doPray", {}, onRecv, true) 
    g_busyTip.show_1()  
  end 

  g_msgBox.show( g_tr("arrow_pray_tips",{num=self.data.activity.activity_para.prayPrice}), nil,nil,
    function(eventtype)
      --确定
      if eventtype == 0 then 
        doPray()
      end
    end , 1)
end 


function activityArrowShootView:onChangePower()
  self.powerStatus = self.powerStatus + 1 

  if self.powerStatus == 1 then --播放动画
    self.animPower:getLHSAnimation():play("lidu")
  else 
    local idx = self.powerFrameIndex+1
    if idx > #self.powerFrameMap then 
      idx = 1
    end 
    self.animPower:getLHSAnimation():gotoAndPause(idx)
    local maxVal = 0 
    for k, v in pairs(self.powerFrameMap) do 
      if v > maxVal then 
        maxVal = v 
      end 
    end 

    local percent = self.powerFrameMap[idx]/maxVal
    local item = g_data.shoot[2] 
    self.powerVal = item.min_value + math.floor((item.max_value - item.min_value)*percent)
    print("powerVal", self.powerVal)

    self.btnChangePower:setVisible(false) 
    self.btnChangeWind:setVisible(true)  
    self.btnOnceAgain:setVisible(false) 
    self.btnPray:setVisible(true) 

    --选完力度后播放拉弓动画
    self.animArrow:getLHSAnimation():play("la")   
  end 
end 

function activityArrowShootView:onChangeAngleDir() 
  self.angleStatus = self.angleStatus + 1 

  if self.angleStatus == 1 then --播放动画
    self.animAngle:getLHSAnimation():play("fengxiang") 
    self.animArrow:getLHSAnimation():play("zhunbei") 
  else 

    local idx = self.angleFrameIndex+1
    if idx > #self.angleFrameMap then 
      idx = 1
    end 
    self.animAngle:getLHSAnimation():gotoAndPause(idx)
    local maxVal = 0 
    for k, v in pairs(self.angleFrameMap) do 
      if v > maxVal then 
        maxVal = v 
      end 
    end 

    local percent = self.angleFrameMap[idx]/maxVal
    local item = g_data.shoot[1] 
    self.angleVal = item.min_value + math.floor((item.max_value - item.min_value)*percent)
    print("angleVal", self.angleVal)

    self.btnChangePower:setVisible(false) 
    self.btnChangeWind:setVisible(false) 
    self.btnOnceAgain:setVisible(false) 
    self.btnPray:setVisible(false) 

    self:startShoot()  
  end 
end 

--重新扣箭，选力度，选角度，射箭
function activityArrowShootView:onOnceAgain()
  
  --如果箭矢不足则提示购买
  local info = ActivityArrowMode.getArrowInfo()
  print("info.arrowNum", info.arrowNum)
  if info.arrowNum < self.perCount then 
    g_msgBox.show( g_tr("arrow_buy_arrow_tips"), nil,nil,
      function(eventtype)
        --确定
        if eventtype == 0 then 
          local view = require("game.uilayer.activity.activityArrowMatch.activityArrowShopView"):create(self.data.activity.activity_para.arrowPrice)
          g_sceneManager.addNodeForUI(view) 
        end
      end , 1)

    return 
  end 

  local function onPreArcherySuccess(leftArrow, windDir)
    if nil == viewObj then return end 

    self.powerStatus = 0 
    self.angleStatus = 0 

    self.btnChangePower:setVisible(true) 
    self.btnChangeWind:setVisible(false) 
    self.btnOnceAgain:setVisible(false) 
    self.btnPray:setVisible(true) 

    self.root:getChildByName("Panel_power_anim"):setVisible(true)
    self.root:getChildByName("Panel_angle_anim"):setVisible(true)

    self.animArrow:getLHSAnimation():play("la")
    self.animArrow:getLHSAnimation():gotoAndPause(26) 

    --风向复位
    self.curWind = windDir 
    if g_data.shoot[self.curWind] then 
      self.lbCurWinDir:setString(g_tr(g_data.shoot[self.curWind].desc))
    end 
  end 

  ActivityArrowMode.reqpreArchery(self.selGens, self.perCount, onPreArcherySuccess)
end 

function activityArrowShootView:onHelp()
  require("game.uilayer.common.HelpInfoBox"):show(112)
end 

function activityArrowShootView:getAnim()

  --力度动画
  local function onFrameEventCallFunc1(bone , frameEventName , originFrameIndex , currentFrameIndex)
    self.powerFrameIndex = currentFrameIndex
  end 

  local armature1, _ = g_gameTools.LoadCocosAni(
    "anime/archery_match_1/archery_match_1.ExportJson"
    ,"archery_match_1"
    ,nil --onMovementEventCallFunc
    ,onFrameEventCallFunc1
    )
  armature1:setPosition(cc.p(0, 0)) 


  --角度动画
  local function onFrameEventCallFunc2(bone , frameEventName , originFrameIndex , currentFrameIndex)
    self.angleFrameIndex = currentFrameIndex 
  end 
  local armature2, _ = g_gameTools.LoadCocosAni(
    "anime/archery_match_2/archery_match_2.ExportJson"
    ,"archery_match_2"
    , nil --onMovementEventCallFunc
    ,onFrameEventCallFunc2
    )
  armature2:setPosition(cc.p(0, 0)) 

  --弓箭动画(包含拉弓,准备,射箭)
  local armature3, _ = g_gameTools.LoadCocosAni(
    "anime/archery_match/archery_match.ExportJson"
    ,"archery_match"
    -- ,onMovementEventCallFunc
    -- ,onFrameEventCallFunc
    )
  armature3:setPosition(cc.p(28, 112)) 

  return armature1, armature2, armature3
end 


function activityArrowShootView:startShoot()
  if nil == self.data then return end 

  --优势阵营级其加成
  local camp_id = 1 
  local camp_plus = 0 
  local curTime = g_clock.getCurServerTime()
  for k, v in pairs(self.data.activity.activity_para.advantageGeneral) do 
    if curTime >= v.beginTime and curTime <= v.endTime then 
      camp_id = v.campId
      break
    end 
  end 
  
  local item = g_data.shoot[camp_id + 6]
  if item then 
    camp_plus = math.random(item.min_value, item.max_value)
  end 

  --武将随机事件的加成值
  self.randIdBak = {}
  local gen_plus = {}

  for i = 1 , 3 do 
    gen_plus[i] = {}  
    self.randIdBak[i] = {}
    for k = 1, self.perCount do 
      local rand_id = math.random(11, 27) --对应表id 
      item = g_data.shoot[rand_id] 
      gen_plus[i][k] = math.random(item.min_value, item.max_value)

      self.randIdBak[i][k] = rand_id 
    end 
  end 

  --风向随机值
  local windVal = 0 
  item = g_data.shoot[self.curWind]
  if item then 
    windVal = math.random(item.min_value, item.max_value) 
  end 

  local para = {}
  para.general_1 = self.selGens[1] or 0
  para.general_2 = self.selGens[2] or 0
  para.general_3 = self.selGens[3] or 0 
  para.angle = self.angleVal
  para.power = self.powerVal
  para.windValue = windVal
  para.campId = camp_id 
  para.campValue = camp_plus 
  para.randomValue_g1 = gen_plus[1]
  para.randomValue_g2 = gen_plus[2]
  para.randomValue_g3 = gen_plus[3]

  dump(para, "===para")
  local function onRecv(result, data)
    if nil == viewObj then return end 

    g_busyTip.hide_1()
    if result then 
      dump(data, "====data")
      dataDurty = true 

      self.animArrow:getLHSAnimation():play("she") 

      self:performWithDelay(function()
          if nil == viewObj then return end 
            self.root:getChildByName("Panel_power_anim"):setVisible(false)
            self.root:getChildByName("Panel_angle_anim"):setVisible(false)
        end, 0.2) 

      self:performWithDelay(function()
          if nil == viewObj then return end 
          self:showshootResult(data)
          self.btnOnceAgain:setVisible(true) 
        end, 1) 

    end 
  end 
  g_sgHttp.postData("Arrow/doArchery", para, onRecv, true) 
  g_busyTip.show_1()     
end 

function activityArrowShootView:showshootResult(resultData)
  self.listView:removeAllChildren()
  if nil == resultData then return end 

  local listWidth = self.listView:getContentSize().width 
  local bestScore = 0 
  local tmpIndex = 1 
  local totalMedals = 0 

  for k = 1, self.perCount do 
    if nil == resultData[k] then break end 

    if self.perCount > 1 then --10箭时,加入第几轮
      local richText = g_gameTools.createNoModeRichText(g_tr("arrow_shoot_index", {num=k}), {fontSize=24, width=listWidth, height=32})
      self.listView:pushBackCustomItem(richText)      
    end 

    local total = 0 
    for i =1, 3 do 
      local genName = g_tr(g_data.general[self.selGens[i]*100+1].general_name)
      local eventName = g_tr(g_data.shoot[self.randIdBak[i][k]].desc)
      local result = string.format("%.2f", resultData[k]["general_target"..i])
      local str = g_tr("arrow_shoot_notice", {gen=genName, event = eventName, num = result})
      local richText = g_gameTools.createNoModeRichText(str, {fontSize=24, width=listWidth, height=32})
      self.listView:pushBackCustomItem(richText)

      total = total + tonumber(result)
    end 
    local str = g_tr("arrow_shoot_notice2", {num = total, num2 = resultData[k].medalTotal})
    local richText = g_gameTools.createNoModeRichText(str, {fontSize=24, width=listWidth, height=36})  
    self.listView:pushBackCustomItem(richText)

    totalMedals = totalMedals + resultData[k].medalTotal 

    --获取最高积分对应的轮数
    if total > bestScore then 
      bestScore = total 
      tmpIndex = k 
    end    
  end 

  if self.perCount > 1 then --10箭时提示最佳成绩和总共获得奖牌数
    local str = g_tr("arrow_best_scrore", {rond = tmpIndex, score = bestScore, medal = totalMedals})
    local richText = g_gameTools.createNoModeRichText(str, {fontSize=24, width=listWidth, height=32})
    self.listView:pushBackCustomItem(richText)     
  end 

  g_gameCommon.dispatchEvent("UpdateArrowMatchInfo", {score = bestScore, addMedals = totalMedals} ) --更新积分
end 

return activityArrowShootView 

