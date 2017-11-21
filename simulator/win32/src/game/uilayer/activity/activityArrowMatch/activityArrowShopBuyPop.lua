
--购买弹框

local activityArrowShopBuyPop = class("activityArrowShopBuyPop",require("game.uilayer.base.BaseLayer"))
local viewObj 


function activityArrowShopBuyPop:ctor(prop, ownMedal)
  activityArrowShopBuyPop.super.ctor(self)

  viewObj = self 

  self.prop = prop 
  self.callback = callback 

  local layer = g_gameTools.LoadCocosUI("Archery_main_store2.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    self:updateUI()
  end 
end 

function activityArrowShopBuyPop:onEnter()
  print("activityArrowShopBuyPop:onEnter") 
end 

function activityArrowShopBuyPop:onExit() 
  print("activityArrowShopBuyPop:onExit") 
  viewObj = nil 
end 


function activityArrowShopBuyPop:initBinging(layer)

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
end 

function activityArrowShopBuyPop:updateUI()
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

function activityArrowShopBuyPop:onBuyItem() 
  if nil == self.prop then return end 

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
  g_sgHttp.postData("Arrow/doExchange", {exchangeId = tonumber(self.prop.id)}, onRecv, true) 
  g_busyTip.show_1() 
end 


return activityArrowShopBuyPop 

