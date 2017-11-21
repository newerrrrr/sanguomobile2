
--本服/全服排行奖励

local activityArrowRankAwardsView = class("activityArrowRankAwardsView",require("game.uilayer.base.BaseLayer"))
local viewObj 


function activityArrowRankAwardsView:ctor(data)
  activityArrowRankAwardsView.super.ctor(self)

  viewObj = self 

  self.data = data 

  local layer = g_gameTools.LoadCocosUI("CityBattle_popup06.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    self:onLocalRankAwards() 
  end 
end 

function activityArrowRankAwardsView:onEnter()
  print("activityArrowRankAwardsView:onEnter") 
end 

function activityArrowRankAwardsView:onExit() 
  print("activityArrowRankAwardsView:onExit") 
  viewObj = nil 
end 

function activityArrowRankAwardsView:initBinging(layer)
  self.root = layer:getChildByName("scale_node") 

  local btnClose = self.root:getChildByName("close_btn") 
  self:regBtnCallback(btnClose, handler(self, self.close))
  self.root:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("arrow_rank_award"))
  self.btnLocal = self.root:getChildByName("Button_1")
  self.btnGlobal = self.root:getChildByName("Button_2")
  self.btnLocal:getChildByName("Text_1"):setString(g_tr("arrow_rank_local"))
  self.btnGlobal:getChildByName("Text_1"):setString(g_tr("arrow_rank_global"))
  self:regBtnCallback(self.btnLocal, handler(self, self.onLocalRankAwards))
  self:regBtnCallback(self.btnGlobal, handler(self, self.onGlobalRankAwards))

  self.listView = self.root:getChildByName("Panel_h2"):getChildByName("ListView_1")
end 

function activityArrowRankAwardsView:showAwardsList(data)
  if nil == data then return end 

  -- dump(data, "===showRankList") 

  self.listView:removeAllChildren()

  for k, v in pairs(data) do 
    local item = cc.CSLoader:createNode("CityBattle_popup06_list1.csb") 
    item:getChildByName("Text_"):setString(g_tr("arrow_rank_rang"))
    item:getChildByName("Text__0"):setString(string.format("%d-%d", v.from, v.to))
    item:getChildByName("Text__0_0"):setString(g_tr("arrow_award"))
    local list = item:getChildByName("ListView_1")
    list:setScrollBarEnabled(false)

    for i, prop in pairs(v.drop) do 
      local icon = require("game.uilayer.common.DropItemView").new(tonumber(prop[1]), tonumber(prop[2]), tonumber(prop[3]))
      if icon then 
        icon:setNameVisible(false) 
        icon:setScale(0.8)
        icon:enableTip()
        list:pushBackCustomItem(icon) 
      end 
    end 

    self.listView:pushBackCustomItem(item) 
  end 
end 

function activityArrowRankAwardsView:onLocalRankAwards() 
  if nil == self.data then return end 

  self.btnLocal:setHighlighted(true)
  self.btnGlobal:setHighlighted(false)
  self:showAwardsList(self.data.activity.activity_para.localRank)
end 

function activityArrowRankAwardsView:onGlobalRankAwards()
  if nil == self.data then return end 

  self.btnLocal:setHighlighted(false)
  self.btnGlobal:setHighlighted(true)
  self:showAwardsList(self.data.activity.activity_para.globalRank)
end 



return activityArrowRankAwardsView 

