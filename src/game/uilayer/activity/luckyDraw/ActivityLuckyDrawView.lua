
--幸运抽奖(喜迎财神)

local ActivityLuckyDrawView = class("ActivityLuckyDrawView", require("game.uilayer.base.BaseLayer"))
local LuckyDrawMode = require("game.uilayer.activity.luckyDraw.ActivityLuckyDrawMode"):instance()


function ActivityLuckyDrawView:ctor()
  ActivityLuckyDrawView.super.ctor(self)
  self.isOpen = true  
  
end

function ActivityLuckyDrawView:onEnter()
  print("ActivityLuckyDrawView:onEnter")
  self:initUI()
end 

function ActivityLuckyDrawView:onExit() 
  print("ActivityLuckyDrawView:onExit") 
end 

function ActivityLuckyDrawView:initUI() 
  local layer = cc.CSLoader:createNode("Mammon_main1.csb") 
  if layer then 
    self.root = layer 
    self:addChild(layer) 

    local lbTime = layer:getChildByName("Text_2")
    layer:getChildByName("Text_1"):setString(g_tr("actLeftTime"))
    local btnDraw = layer:getChildByName("Button_2")
    btnDraw:getChildByName("Text_7"):setString(g_tr("goodLucky"))
    self:regBtnCallback(btnDraw, handler(self, self.onLuckyDraw))

    btnDraw:getChildByName("Text_9"):setString(g_tr("leftCounts"))

    self.imgObj = {}
    self.lbFnt = {}
    for i=1, 5 do 
      table.insert(self.imgObj, layer:getChildByName("Image_k"..i))

      local label = layer:getChildByName("BitmapFontLabel_"..i) 
      -- label:setVisible(false)
      label:setString("0")
      table.insert(self.lbFnt, label)
    end 
    --背景动画 
    LuckyDrawMode:playStarAnim(layer:getChildByName("Image_21"))

    local info = g_luckyDrawData.GetData()
    if info then 
      self:showLeftTime(lbTime, info.end_time) 
      self:updateMoneyCount()
    else 
      lbTime:setString("")
    end 
  end 
end 


function ActivityLuckyDrawView:showLeftTime(label, targetTime)
  local function updateTime()
    local dt = targetTime - g_clock.getCurServerTime()
    if dt <= 0 then      
      dt = 0 
      self:unschedule(self.timer)
      self.timer = nil 
      self.isOpen = false 
    end 
    label:setString(g_gameTools.convertSecondToString(dt))
  end 

  if self.timer then 
    self:unschedule(self.timer)
    self.timer = nil 
  end 

  label:setString("")
  local leftTime = targetTime - g_clock.getCurServerTime() 
  if leftTime > 0 then 
    label:setString(g_gameTools.convertSecondToString(leftTime)) 
    self.timer = self:schedule(updateTime, 1.0) 
  else 
    self.isOpen = false
  end
end 

--更新剩余次数和下次需要花费的元宝数
function ActivityLuckyDrawView:updateMoneyCount()
  self.costMoney = nil 
  local info = g_luckyDrawData.GetData() 
  if self.root and info then 
    local btn = self.root:getChildByName("Button_2") 
    btn:getChildByName("Text_8_0"):setString(g_tr("CountsNum",{count=math.max(0, 10-info.times)}))
    local nextIdx = info.times + 1 
    if g_data.quick_money[nextIdx] then 
      local costId = g_data.quick_money[nextIdx].cost_id 
      self.costMoney = LuckyDrawMode:getCostByUsedCounts(costId, nextIdx)
      print("getCostByUsedCounts:", costId, info.times, self.costMoney) 
      if self.costMoney then 
        btn:getChildByName("Text_8"):setString(""..self.costMoney)
      end 
    end 
  end 
end 

function ActivityLuckyDrawView:onLuckyDraw(sender)
  print("onLuckyDraw")

  if not self.isOpen then 
    g_airBox.show(g_tr("actIsClosed"))
    return
  end 

  if self.costMoney and g_PlayerMode.getDiamonds() < self.costMoney then 
    g_airBox.show(g_tr("no_enough_money"))
    return 
  end 
  
  local info = g_luckyDrawData.GetData() 
  if info and info.times >= 10 then 
    g_airBox.show(g_tr("drawCountUsedOut")) 
    return 
  end 
  
  local function drawResult(result, data)
    print("drawResult:", result)
    if result then 
      LuckyDrawMode:incressUsedCounts() 
      self:updateMoneyCount()
      self:playScrollNumAnim(data.gem_num) 
    end 
  end 
  
  g_sgHttp.postData("Lottery/quickMoney", {}, drawResult) 
end 

function ActivityLuckyDrawView:playScrollNumAnim(num)
  if self.fntTimer then 
    self:unschedule(self.fntTimer)
    self.fntTimer = nil 
  end 

  local strNum = num and string.format("%05d", num) or "00000"
  for i=1, 5 do 
    self.lbFnt[i]:setVisible(false)
    self.lbFnt[i]:setString(string.sub(strNum, i, i))
  end 

  --播放滚动动画
  LuckyDrawMode:playScrollNumAnim(self.imgObj)

  local function playScrollNumEndAnim()
    local idx = 5     
    local function animEnd(index)
      if index and index <= 5 then 
        self.lbFnt[index]:setVisible(true)
      end 
    end 

    local function updateFntNum()
      if idx > 0 then 
        local tmpFnt = self.lbFnt[idx]:clone()
        tmpFnt:setVisible(true) 
        LuckyDrawMode:playNumScrollEndAnim(self.imgObj[idx], tmpFnt, animEnd, idx)

        idx = idx - 1 
      else 
        if self.fntTimer then 
          self:unschedule(self.fntTimer)
          self.fntTimer = nil 
        end 

        require("game.uilayer.task.AwardsToast").show({{1, 10700, num}})
        require("game.effectlayer.fireworks").show()
      end 
    end

    if self.fntTimer then 
      self:unschedule(self.fntTimer)
      self.fntTimer = nil 
    end 
    self.fntTimer = self:schedule(updateFntNum, 0.16) 
  end 

  self:performWithDelay(playScrollNumEndAnim, 0.2)
end 


return ActivityLuckyDrawView 
