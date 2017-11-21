
--购买弹框

local activityArrowExchangeItemPop = class("activityArrowExchangeItemPop",require("game.uilayer.base.BaseLayer"))
local viewObj 


function activityArrowExchangeItemPop:ctor(prop, ownMedal)
  activityArrowExchangeItemPop.super.ctor(self)

  viewObj = self 

  self.prop = prop 
  self.maxNum = math.min(100, math.floor(ownMedal/self.prop.price))
  self.selNum = 1
  self.callback = callback 

  local layer = g_gameTools.LoadCocosUI("Archery_main_store2.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    self:updateUI()
  end 
end 

function activityArrowExchangeItemPop:onEnter()
  print("activityArrowExchangeItemPop:onEnter") 
end 

function activityArrowExchangeItemPop:onExit() 
  print("activityArrowExchangeItemPop:onExit") 
  viewObj = nil 
end 


function activityArrowExchangeItemPop:initBinging(layer)

  local mask = layer:getChildByName("mask") 
  self:regBtnCallback(mask, handler(self, self.close))

  self.root = layer:getChildByName("scale_node") 
  self.root:getChildByName("Text_c2"):setString(g_tr("shopItemDetail"))
  self.pic = self.root:getChildByName("Image_i2")
  self.price = self.root:getChildByName("Text_s1")
  self.name = self.root:getChildByName("Text_s2")
  self.desc = self.root:getChildByName("Text_s2_0")
  self.root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose")) 
  local btnBuy = self.root:getChildByName("Button_1")
  btnBuy:getChildByName("Text_4"):setString(g_tr("arrow_exchange"))
  self:regBtnCallback(btnBuy, handler(self, self.onBuyItem))
  self.lbNeedMedal = btnBuy:getChildByName("Text_4_0")
  

  local function sliderEvent(sender, eventType)
    if eventType == ccui.SliderEventType.percentChanged then
      self.selNum = math.floor(self.maxNum*sender:getPercent()/100)
      self:updateSelNum(true)
    elseif eventType == ccui.SliderEventType.slideBallUp then
      if self.maxNum == 0 then 
        g_airBox.show(g_tr("exchange_not_enough_medal"))
        sender:setPercent(0)
      end 
    end
  end 
  self.slider = self.root:getChildByName("Slider_1")
  self.slider:addEventListener(sliderEvent)
  self:updateSelNum()

  local btnAdd = self.root:getChildByName("btn_add")
  local btnReduce = self.root:getChildByName("btn_reduce")
  self:regBtnCallback(btnAdd, handler(self, self.onAddNum))
  self:regBtnCallback(btnReduce, handler(self, self.onReduce))
end 

function activityArrowExchangeItemPop:updateUI()
  if nil == viewObj then return end 
  if nil == self.prop then return end 

  local icon = require("game.uilayer.common.DropItemView").new(tonumber(self.prop.drop[1]), tonumber(self.prop.drop[2]), tonumber(self.prop.drop[3])) 
  if icon then 
    icon:setNameVisible(false) 
    -- icon:enableTip() 
    self.name:setString(icon:getName())
    self.desc:setString(icon:getDesc())
    self.price:setString(""..self.prop.price)
    icon:setPosition(cc.p(self.pic:getContentSize().width/2, self.pic:getContentSize().height/2))
    self.pic:addChild(icon)         
  else 
    self.name:setString("")
    self.desc:setString("")
    self.price:setString("")
  end 
end 

function activityArrowExchangeItemPop:updateSelNum(isFromSlider)
  if self.selNum > self.maxNum then 
    self.selNum = self.maxNum
  end 
  if self.selNum < 0 then 
    self.selNum = 0
  end 

  if not isFromSlider then 
    self.slider:setPercent(math.floor(100*self.selNum/self.maxNum))
  end 
  self.root:getChildByName("Text_num"):setString(""..self.selNum)
  self.lbNeedMedal:setString(""..self.selNum*self.prop.price)
end 

function activityArrowExchangeItemPop:onBuyItem() 
  if nil == self.prop then return end 

  if self.selNum == 0 then 
    if self.maxNum > 0 then 
      g_airBox.show(g_tr("plsSelectBuildCount"))
    else 
      g_airBox.show(g_tr("exchange_not_enough_medal"))
    end 
    return
  end 

  local function onRecv(result, data)
    if nil == viewObj then return end 

    g_busyTip.hide_1()
    if result then 
      dump(data, "====data")
      g_airBox.show(g_tr("exchange_ok"))

      g_gameCommon.dispatchEvent("UpdateArrowMatchInfo", {medals = data.left_medal})    

      self:close() 
    end 
  end 
  g_sgHttp.postData("Arrow/doExchange", {exchangeId = tonumber(self.prop.id), num = self.selNum}, onRecv, true) 
  g_busyTip.show_1() 
end 

function activityArrowExchangeItemPop:onAddNum()
  if self.selNum < self.maxNum then 
    self.selNum = self.selNum + 1  
    self:updateSelNum()
  end 
end 

function activityArrowExchangeItemPop:onReduce()
  if self.selNum > 0 then 
    self.selNum = self.selNum - 1
    self:updateSelNum()  
  end 
end 


return activityArrowExchangeItemPop 

