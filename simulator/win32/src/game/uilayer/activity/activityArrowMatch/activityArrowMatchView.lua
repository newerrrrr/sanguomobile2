
--射箭比赛入口

local activityArrowMatchView = class("activityArrowMatchView",require("game.uilayer.base.BaseLayer"))
local ActivityArrowMode = require("game.uilayer.activity.activityArrowMatch.activityArrowMode")
local viewObj
local isDataReady = false 

function activityArrowMatchView:ctor()
  activityArrowMatchView.super.ctor(self)

  viewObj = self
  self.curSel = {} --存放当前上阵的3名武将
  local layer = cc.CSLoader:createNode("activity4_mian10.csb")
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    self:onReqData() 
  end 
end 

function activityArrowMatchView:onEnter()
  print("activityArrowMatchView:onEnter")

  g_gameCommon.addEventHandler("UpdateArrowMatchInfo", handler(self, self.onEventHandler), self)
end 

function activityArrowMatchView:onExit() 
  print("activityArrowMatchView:onExit") 
  viewObj = nil 
  g_gameCommon.removeAllEventHandlers(self)
end 


function activityArrowMatchView:initBinging(layer)
  self.root = layer:getChildByName("Panel_s1") 

  self.root:getChildByName("Panel_js"):getChildByName("Text_s1"):setString(g_tr("arrow_left_time1"))
  self.root:getChildByName("Panel_js"):getChildByName("Text_d1"):setString(g_tr("arrow_left_time2"))
  self.lbActEndTime = self.root:getChildByName("Panel_js"):getChildByName("Text_s2")
  self.lbExEndTime = self.root:getChildByName("Panel_js"):getChildByName("Text_d2")
  self.lbActEndTime:setString("")
  self.lbExEndTime:setString("")

  self.root:getChildByName("Panel_1"):getChildByName("Text_mz1"):setString(g_tr("arrow_standby"))
  self.root:getChildByName("Panel_2"):getChildByName("Text_mz1"):setString(g_tr("arrow_standby"))
  self.root:getChildByName("Panel_3"):getChildByName("Text_mz1"):setString(g_tr("arrow_standby"))

  local Panel4 = self.root:getChildByName("Panel_4")
  Panel4:getChildByName("Text_dq1"):setString(g_tr("arrow_advantage_gen"))
  Panel4:getChildByName("Text_dq2"):setString("")

  self.lbBestScore = g_gameTools.createRichText(Panel4:getChildByName("Text_zj1"), g_tr("arrow_cur_point", {num = ""}))
  self.lbMyLocalRank = g_gameTools.createRichText(Panel4:getChildByName("Text_mc"), g_tr("arrow_my_local_rank", {rank = ""}))
  self.lbMyGlobalRank = g_gameTools.createRichText(Panel4:getChildByName("Text_kf"), g_tr("arrow_my_global_rank", {rank = ""}))
  self.lbMedalCount = g_gameTools.createRichText(Panel4:getChildByName("Text_sl"), g_tr("arrow_medal_count", {num = ""})) 

  local btnRank = Panel4:getChildByName("Button_a1")
  local btnExcharge = Panel4:getChildByName("Button_a2")
  local btnSelectGen = Panel4:getChildByName("Button_a3")
  local btnBuy = Panel4:getChildByName("Button_a4")
  btnRank:getChildByName("Text_12"):setString(g_tr("arrow_rank"))
  btnExcharge:getChildByName("Text_12"):setString(g_tr("arrow_exchange"))
  btnSelectGen:getChildByName("Text_12"):setString(g_tr("arrow_select_gen"))
  btnBuy:getChildByName("Text_12"):setString(g_tr("arrow_buy"))

  self:regBtnCallback(btnRank, handler(self, self.onShowRank))
  self:regBtnCallback(btnExcharge, handler(self, self.onExchange))
  self:regBtnCallback(btnSelectGen, handler(self, self.onSelectGen))
  self:regBtnCallback(btnBuy, handler(self, self.onBuy)) 

  Panel4:getChildByName("Text_yy1"):setString(g_tr("arrow_count"))
  Panel4:getChildByName("Text_yy2"):setString("")

  local btnStart = self.root:getChildByName("Button_ksbs") 
  self:regBtnCallback(btnStart, handler(self, self.onStart)) 

  --默认不勾选 十次 
  self.root:getChildByName("Panel_sc1"):getChildByName("Text_zssc"):setString(g_tr("arrow_more_ten"))
  local checkBox = self.root:getChildByName("Panel_sc1"):getChildByName("CheckBox_1")
  checkBox:setSelected(false)
end 


function activityArrowMatchView:updateUI()

  if nil == viewObj then return end 

  if nil == self.data then return end 

  self.lbBestScore:setRichText(g_tr("arrow_cur_point", {num = self.data.player_arrow.myMaxTarget}))
  self.lbMyLocalRank:setRichText(g_tr("arrow_my_local_rank", {rank = self.data.player_arrow.myLocalRank}))
  self.lbMyGlobalRank:setRichText(g_tr("arrow_my_global_rank", {rank = self.data.player_arrow.myGlobalRank}))
  self.lbMedalCount:setRichText(g_tr("arrow_medal_count", {num = self.data.player_arrow.playerArrowInfo.medal}))

  local Panel4 = self.root:getChildByName("Panel_4")
  Panel4:getChildByName("Text_yy2"):setString(""..self.data.player_arrow.playerArrowInfo.arrow)
  self:showLeftTime()

  --上阵武将
  self.curSel = {self.data.player_arrow.playerArrowInfo.general_1, 
                self.data.player_arrow.playerArrowInfo.general_2,
                self.data.player_arrow.playerArrowInfo.general_3}   
  self:updateBattleGen(self.curSel) 

  --优势阵营
  local curTime = g_clock.getCurServerTime()
  local advantageGeneral = self.data.activity.activity_para.advantageGeneral 
  dump(advantageGeneral, "===advantageGeneral")
  local camp_id = advantageGeneral[1].campId 
  for k, v in pairs(advantageGeneral) do 
    if curTime >= v.beginTime and curTime <= v.endTime then 
      camp_id = v.campId 
      break
    end 
  end 
  Panel4:getChildByName("Text_dq2"):setString(g_tr("city_battle_camp"..camp_id))
end 

--3名上阵武将
function activityArrowMatchView:updateBattleGen(genIds) 
  if nil == viewObj then return end 
  if nil == genIds then return end 
  if nil == self.root then return end 
  
  for i = 1, 3 do 
    local bigIcon = self.root:getChildByName("Image_r"..i)
    if genIds[i] and genIds[i] > 0 then 
      local item = g_data.general[genIds[i]*100+1]
      if item then 
        bigIcon:loadTexture(g_resManager.getResPath(item.general_big_icon)) 
        self.root:getChildByName("Panel_"..i):getChildByName("Text_mz1"):setString(g_tr(item.general_name))
      end 
    end 
  end 
end 

--更新积分，奖牌数，剩余箭矢
function activityArrowMatchView:onEventHandler(obj, info) --score, medals, arrowNum
  if nil == viewObj then return end 
  if nil == info then return end 

  local Panel4 = self.root:getChildByName("Panel_4")

  if info.score then 
    if tonumber(self.data.player_arrow.myMaxTarget) < info.score then 
      self.lbBestScore:setRichText(g_tr("arrow_cur_point", {num = info.score}))
      self.data.player_arrow.myMaxTarget = info.score 
    end 
  end 

  if info.medals then 
    self.lbMedalCount:setRichText(g_tr("arrow_medal_count", {num = info.medals}))
    self.data.player_arrow.playerArrowInfo.medal = info.medals
  end 

  if info.addMedals then --增加奖牌
    self.data.player_arrow.playerArrowInfo.medal = self.data.player_arrow.playerArrowInfo.medal + info.addMedals
    self.lbMedalCount:setRichText(g_tr("arrow_medal_count", {num = self.data.player_arrow.playerArrowInfo.medal}))
  end 

  if info.arrowNum then 
    Panel4:getChildByName("Text_yy2"):setString(""..info.arrowNum)
    self.data.player_arrow.playerArrowInfo.arrow = info.arrowNum 
  end 

  ActivityArrowMode.setArrowInfo(info) 
end 

function activityArrowMatchView:onReqData()
  print("activityArrowMatchView:onReqData")
  
  local function onRecv(result, data)
    isDataReady = true 

    g_busyTip.hide_1()
    if result then 
      if nil == viewObj then return end 

      self.data = data 
      dump(data, "====data") 

      --备份信息
      local info = {}
      info.score = tonumber(self.data.player_arrow.myMaxTarget)
      info.medals = self.data.player_arrow.playerArrowInfo.medal 
      info.arrowNum = self.data.player_arrow.playerArrowInfo.arrow 
      ActivityArrowMode.setArrowInfo(info)

      self:updateUI()
    end 
  end 

  g_sgHttp.postData("Arrow/main", {}, onRecv, true) 
  g_busyTip.show_1()  
end 

function activityArrowMatchView:onShowRank()
  if not isDataReady then return end 

  local view = require("game.uilayer.activity.activityArrowMatch.activityArrowRankView"):create(self.data)
  g_sceneManager.addNodeForUI(view)
end 

function activityArrowMatchView:onExchange()
  if not isDataReady then return end 

  local view = require("game.uilayer.activity.activityArrowMatch.activityArrowExchangeView"):create(self.data)
  g_sceneManager.addNodeForUI(view)  
end 

function activityArrowMatchView:onSelectGen()
  if not isDataReady then return end 

  local function selecteResult(data)
    if nil == data then return end 
    if nil == viewObj then return end 

    self.curSel = {}
    for k, v in pairs(data) do 
      table.insert(self.curSel, v.general_id)
    end 
    self:updateBattleGen(self.curSel)
  end 
  local view = require("game.uilayer.activity.activityArrowMatch.activityArrowSelectGenView"):create(self.curSel, selecteResult)
  g_sceneManager.addNodeForUI(view)
end 

function activityArrowMatchView:onBuy()
  if not isDataReady then return end 

  local view = require("game.uilayer.activity.activityArrowMatch.activityArrowShopView"):create(self.data.activity.activity_para.arrowPrice)
  g_sceneManager.addNodeForUI(view) 
end 

function activityArrowMatchView:onStart()
  if not isDataReady then return end 

  --未选武将则直接弹出武将选择界面
  if #self.curSel < 3 or self.curSel[1] == 0 or self.curSel[2] == 0 or self.curSel[3] == 0 then 
    -- g_airBox.show(g_tr("generalGarrisonSelectTip")) 
    self:onSelectGen() 
    return 
  end 

  local checkBox = self.root:getChildByName("Panel_sc1"):getChildByName("CheckBox_1")
  local perCount = checkBox:isSelected() and 10 or 1 

  local function onPreArcherySuccess(arrow, windDir)
    if nil == viewObj then return end 

    self.data.player_arrow.playerArrowInfo.arrow = arrow 
    local view = require("game.uilayer.activity.activityArrowMatch.activityArrowShootView"):create(self.data, self.curSel, perCount, windDir)
    view:setDelegate(self)
    g_sceneManager.addNodeForUI(view) 
  end 

  ActivityArrowMode.reqpreArchery(self.curSel, perCount, onPreArcherySuccess)
end 

function activityArrowMatchView:showLeftTime()

  if nil == self.data then return end 

  local targetTime1 = self.data.activity.activity_para.arcEndTime
  local targetTime2 = self.data.activity.end_time 

  local function updateTime()
    if nil == viewObj then return end 

    local leftTime1 = math.max(0, targetTime1 - g_clock.getCurServerTime()) 
    local leftTime2 = math.max(0, targetTime2 - g_clock.getCurServerTime()) 
    if leftTime1 < 1 then 
      self.lbActEndTime:setString(g_tr("arrow_match_end")) 
    else 
      self.lbActEndTime:setString(g_gameTools.convertSecondToString(leftTime1))
    end 
    if leftTime2 < 1 then 
      self.lbExEndTime:setString(g_tr("arrow_exchange_end"))
    else 
      self.lbExEndTime:setString(g_gameTools.convertSecondToString(leftTime2))  
    end 

    if leftTime1 < 1 and leftTime2 < 1 then 
      self:unschedule(self.timer)
      self.timer = nil 
    end 
  end 

  if self.timer then 
    self:unschedule(self.timer)
    self.timer = nil 
  end 

  local leftTime1 = math.max(0, targetTime1 - g_clock.getCurServerTime()) 
  local leftTime2 = math.max(0, targetTime2 - g_clock.getCurServerTime())   
  if leftTime1 > 0 or leftTime2 > 0 then 
    self.timer = self:schedule(updateTime, 1.0) 
  end 
  updateTime() 
end 


return activityArrowMatchView 

