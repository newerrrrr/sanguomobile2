
--奖牌兑换

local activityArrowExchangeView = class("activityArrowExchangeView",require("game.uilayer.base.BaseLayer"))
local viewObj 


function activityArrowExchangeView:ctor(data)
  activityArrowExchangeView.super.ctor(self)

  viewObj = self 

  self.data = data 

  local layer = g_gameTools.LoadCocosUI("Archery_main5.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    self:showLeftTime() 
    self:showItemList()
  end 
end 

function activityArrowExchangeView:onEnter()
  print("activityArrowExchangeView:onEnter") 

  g_gameCommon.addEventHandler("UpdateArrowMatchInfo", handler(self, self.onEventHandler), self)
end 

function activityArrowExchangeView:onExit() 
  print("activityArrowExchangeView:onExit") 
  viewObj = nil 

  g_gameCommon.removeAllEventHandlers(self)

  if self.timer then 
    self:unschedule(self.timer)
    self.timer = nil 
  end 
end 


function activityArrowExchangeView:initBinging(layer)
  self.root = layer:getChildByName("scale_node") 

  local btnClose = self.root:getChildByName("close_btn") 
  self:regBtnCallback(btnClose, handler(self, self.close))

  self.root:getChildByName("Text_mingc"):setString(g_tr("arrow_medal_exchange"))
  self.root:getChildByName("Text_sp"):setString(g_tr("arrow_own_medal"))
  self.root:getChildByName("Text_bfb1"):setString("")
  self.root:getChildByName("Text_ds1"):setString(g_tr("arrow_exchange_count_down"))
  self.lbTime = self.root:getChildByName("Text_ds2")

  self.listView = self.root:getChildByName("ListView_1") 

  if self.data then 
    self.root:getChildByName("Text_bfb1"):setString(""..self.data.player_arrow.playerArrowInfo.medal) 
  end 
end 


function activityArrowExchangeView:onLocalRank() 
  if nil == self.data then return end 

  self.btnLocal:setHighlighted(true)
  self.btnGlobal:setHighlighted(false)
  self:showRankList(self.data.player_arrow.sysLocalRank)
end 

function activityArrowExchangeView:onGlobalRank()
  if nil == self.data then return end 

  self.btnLocal:setHighlighted(false)
  self.btnGlobal:setHighlighted(true)
  self:showRankList(self.data.player_arrow.sysGlobalRank)
end 

function activityArrowExchangeView:onShowAward()

end 

function activityArrowExchangeView:showItemList()
  if nil == self.data then return end 

  local shop = self.data.activity.activity_para.shop
  if nil == shop then return end 
  dump(shop) 

  self.listView:removeAllChildren()
  self.listView:setItemsMargin(20)
  -- self.listView:setScrollBarEnabled(false)
  
  local numPerLine = 3
  local idx_s = 1 
  local idx_e = #shop
  local rows = math.ceil(idx_e/numPerLine) 
  local item = cc.CSLoader:createNode("Archery_main5_list1.csb") 
  for k=1, rows do 
    local layout = ccui.Layout:create()  
    local itemLineSize = cc.size(self.listView:getContentSize().width, item:getContentSize().height) 
    local gridSize = cc.size(itemLineSize.width/numPerLine, itemLineSize.height)
    layout:setContentSize(itemLineSize) 

    for j = 1, numPerLine do 

      if idx_s > idx_e then break end 

      local item_new = item:clone()
      local node = item_new:getChildByName("goods")
      local pic = node:getChildByName("pic")
      local v = shop[idx_s]
      local icon = require("game.uilayer.common.DropItemView").new(tonumber(v.drop[1]), tonumber(v.drop[2]), tonumber(v.drop[3])) 
      if icon then 
        icon:setNameVisible(false) 
        -- icon:enableTip() 
        node:getChildByName("name"):setString(icon:getName())
        icon:setPosition(cc.p(pic:getContentSize().width/2, pic:getContentSize().height/2))
        pic:addChild(icon) 

        pic:setTag(idx_s)
        pic:setTouchEnabled(true)
        pic:addClickEventListener(function(sender) 
          self:showBuyBox(sender:getTag())
          end) 
      else 
        node:getChildByName("name"):setString("")
        node:getChildByName("Text_7"):setString("")
      end 
      node:getChildByName("Text_7"):setString(""..v.price)
      item_new:setPosition(cc.p((j-1)*gridSize.width, 0))
      layout:addChild(item_new) 

      idx_s = idx_s + 1 
    end 
    self.listView:pushBackCustomItem(layout) 
  end   
end 


function activityArrowExchangeView:showLeftTime()
  if nil == self.data then return end 

  local targetTime = self.data.activity.end_time 

  local function updateTime()
    if nil == viewObj then return end 

    local leftTime = math.max(0, targetTime - g_clock.getCurServerTime()) 

    if leftTime < 1 then 
      self:unschedule(self.timer)
      self.timer = nil 

      self.lbTime:setString(g_tr("arrow_awarding"))
    else 
      self.lbTime:setString(g_gameTools.convertSecondToString(leftTime)) 
    end 
  end 

  if self.timer then 
    self:unschedule(self.timer)
    self.timer = nil 
  end 

  local leftTime = math.max(0, targetTime - g_clock.getCurServerTime()) 
  if leftTime > 0 then 
    self.lbTime:setString(g_gameTools.convertSecondToString(leftTime))
    self.timer = self:schedule(updateTime, 1.0) 
  else 
    self.lbTime:setString(g_tr("arrow_awarding"))
  end 
end 

--显示购买框
function activityArrowExchangeView:showBuyBox(index)
  if nil == self.data then return end 

  local prop = self.data.activity.activity_para.shop[index]
  if nil == prop then return end 

  local ownMedal = self.data.player_arrow.playerArrowInfo.medal 
  local view = require("game.uilayer.activity.activityArrowMatch.activityArrowExchangeItemPop"):create(prop, ownMedal) 
  g_sceneManager.addNodeForUI(view)   
end 


function activityArrowExchangeView:onEventHandler(obj, info)
  print("activityArrowExchangeView:onEventHandler")

  dump(info, "====info")
  if nil == viewObj then return end 

  if nil == info then return end 

  if info.medals then 
    self.root:getChildByName("Text_bfb1"):setString(""..info.medals) 
    self.data.player_arrow.playerArrowInfo.medal = info.medals 
  end 

  if info.addMedals then --增加奖牌
    self.data.player_arrow.playerArrowInfo.medal = self.data.player_arrow.playerArrowInfo.medal + info.addMedals
    self.root:getChildByName("Text_bfb1"):setString(""..self.data.player_arrow.playerArrowInfo.medal)
  end   
end 

return activityArrowExchangeView 

