
--购买箭矢

local activityArrowShopView = class("activityArrowShopView",require("game.uilayer.base.BaseLayer"))
local ActivityArrowMode = require("game.uilayer.activity.activityArrowMatch.activityArrowMode")
local viewObj 


function activityArrowShopView:ctor(price)
  activityArrowShopView.super.ctor(self)

  viewObj = self 

  self.price = price  

  local layer = g_gameTools.LoadCocosUI("Archery_main_store1.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
  end 
end 

function activityArrowShopView:onEnter()
  print("activityArrowShopView:onEnter") 
end 

function activityArrowShopView:onExit() 
  print("activityArrowShopView:onExit") 
  viewObj = nil 
end 


function activityArrowShopView:initBinging(layer)

  local mask = layer:getChildByName("mask") 
  self:regBtnCallback(mask, handler(self, self.close))

  self.root = layer:getChildByName("scale_node") 
  self.root:getChildByName("Text_c2"):setString(g_tr("arrow_shop_title"))
  self.root:getChildByName("Text_nr"):setString(g_tr("arrow_shop_desc"))
  self.root:getChildByName("Image_a1"):getChildByName("Text_5"):setString(g_tr("arrow_shop_buy_one"))
  self.root:getChildByName("Image_a2"):getChildByName("Text_5"):setString(g_tr("arrow_shop_buy_ten"))
  local itemIcon1 = self.root:getChildByName("Image_a1"):getChildByName("Image_6") 
  local itemIcon2 = self.root:getChildByName("Image_a2"):getChildByName("Image_6") 

  local btnBuyOne = self.root:getChildByName("Button_1") 
  local btnBuyTen = self.root:getChildByName("Button_2") 
  self:regBtnCallback(btnBuyOne, handler(self, self.onBuyOne))
  self:regBtnCallback(btnBuyTen, handler(self, self.onBuyTen))

  if self.price then 
    btnBuyOne:getChildByName("Text_4"):setString(""..self.price)
    btnBuyTen:getChildByName("Text_4"):setString(""..(self.price*10))
    local info = ActivityArrowMode.getArrowInfo()
    self.root:getChildByName("Text_sm"):setString(g_tr("arrow_count2", {num= info.arrowNum}))
  else 
    btnBuyOne:getChildByName("Text_4"):setString("")
    btnBuyTen:getChildByName("Text_4"):setString("")
    self.root:getChildByName("Text_sm"):setString("")
  end 

  self.root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose")) 
end 

function activityArrowShopView:onBuyOne() 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
  self:reqToBuy(1) 
end 

function activityArrowShopView:onBuyTen()
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  self:reqToBuy(10)
end 

function activityArrowShopView:reqToBuy(count)
  if nil == self.price then return end 

  print("self.price=", self.price)
  print("cur money", g_PlayerMode.getDiamonds())

  local needGem = self.price * count 
  if g_PlayerMode.getDiamonds() < needGem then
    g_airBox.show(g_tr("no_enough_money"))
    return
  end

  local function onRecv(result, data)
    if nil == viewObj then return end 

    g_busyTip.hide_1()
    if result then 
      dump(data, "====data")
      g_airBox.show(g_tr("fundBuySuccessTip"))
      self.root:getChildByName("Text_sm"):setString(g_tr("arrow_count2", {num=data.now_arrow}))

      g_gameCommon.dispatchEvent("UpdateArrowMatchInfo", {arrowNum = data.now_arrow})  
    end 
    -- self:close() 
  end 
  g_sgHttp.postData("Arrow/buyArrow", {num = count}, onRecv, true) 
  g_busyTip.show_1()   
end 





return activityArrowShopView 

