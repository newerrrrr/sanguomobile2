
--本服/全服排行

local activityArrowRankView = class("activityArrowRankView",require("game.uilayer.base.BaseLayer"))
local viewObj 


function activityArrowRankView:ctor(rankData)
  activityArrowRankView.super.ctor(self)

  viewObj = self 

  self.data = rankData 

  local layer = g_gameTools.LoadCocosUI("Archery_panel1.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer) 
    self:showLeftTime() 
    self:onLocalRank() 
  end 
end 

function activityArrowRankView:onEnter()
  print("activityArrowRankView:onEnter") 
end 

function activityArrowRankView:onExit() 
  print("activityArrowRankView:onExit") 
  viewObj = nil 
end 

function activityArrowRankView:initBinging(layer)
  self.root = layer:getChildByName("scale_node") 

  local btnClose = self.root:getChildByName("close_btn") 
  self:regBtnCallback(btnClose, handler(self, self.close))

  self.root:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("arrow_rank_title"))

  self.btnLocal = self.root:getChildByName("Button_h1")
  self.btnGlobal = self.root:getChildByName("Button_h2")
  self.btnLocal:getChildByName("Text_h1"):setString(g_tr("arrow_rank_local"))
  self.btnGlobal:getChildByName("Text_h1"):setString(g_tr("arrow_rank_global"))
  self:regBtnCallback(self.btnLocal, handler(self, self.onLocalRank))
  self:regBtnCallback(self.btnGlobal, handler(self, self.onGlobalRank))

  local btnAward = self.root:getChildByName("Button_jl")
  btnAward:getChildByName("Text_15"):setString(g_tr("arrow_award"))
  self:regBtnCallback(btnAward, handler(self, self.onShowAward)) 

  self.lbPreTime = self.root:getChildByName("Text_ds1") 
  self.lbTime = self.root:getChildByName("Text_ds2")  
  self.listView = self.root:getChildByName("ListView_1") 
end 

function activityArrowRankView:showRankList(data)
  if nil == data then return end 

  dump(data, "===showRankList") 

  self.listView:removeAllChildren()

  local MailHelper = require("game.uilayer.mail.MailHelper"):instance() 

  for k, v in pairs(data) do 
    local item = cc.CSLoader:createNode("Archery_panel1_list1.csb") 
    local node = item:getChildByName("scale_node")

    node:getChildByName("Text_shuzi1"):setString(""..v.rank)
    node:getChildByName("Image_shuz1"):setVisible(v.rank == 1)
    node:getChildByName("Image_shuz2"):setVisible(v.rank == 2)
    node:getChildByName("Image_shuz3"):setVisible(v.rank == 3)

    local iconHead = node:getChildByName("Image_w2")
    MailHelper:loadPlayerIcon(iconHead, v.avatar_id)
    node:getChildByName("Text_m1"):setString("S"..v.server_id.."."..v.nick)
    node:getChildByName("Text_m2"):setString(g_tr("peripheral_rank_txt1", {guild_name= (v.guild_short_name or "")}))
    node:getChildByName("Text_4"):setString(g_tr("arrow_best_scroe"))
    node:getChildByName("Text_4_0"):setString(""..v.best_general_total)

    self.listView:pushBackCustomItem(item) 
  end 
end 

function activityArrowRankView:onLocalRank() 
  if nil == self.data then return end 

  self.btnLocal:setHighlighted(true)
  self.btnGlobal:setHighlighted(false)
  self:showRankList(self.data.player_arrow.sysLocalRank)
end 

function activityArrowRankView:onGlobalRank()
  if nil == self.data then return end 

  self.btnLocal:setHighlighted(false)
  self.btnGlobal:setHighlighted(true)
  self:showRankList(self.data.player_arrow.sysGlobalRank)
end 

function activityArrowRankView:onShowAward()
  if nil == self.data then return end 

  local view = require("game.uilayer.activity.activityArrowMatch.activityArrowRankAwardsView"):create(self.data)
  --g_sceneManager.addNodeForUI(view)  
  self:addChild(view)
end 

function activityArrowRankView:showLeftTime()
  if nil == self.data then return end 

  local targetTime = self.data.activity.activity_para.arcEndTime


  local function updateTime()
    if nil == viewObj then return end 

    local leftTime = math.max(0, targetTime - g_clock.getCurServerTime()) 

    if leftTime < 1 then 
      self:unschedule(self.timer)
      self.timer = nil 
      self.lbPreTime:setString(g_tr("arrow_awarding"))
      self.lbTime:setString("")
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
    self.lbPreTime:setString(g_tr("arrow_award_count_down"))
    self.lbTime:setString(g_gameTools.convertSecondToString(leftTime))
    self.timer = self:schedule(updateTime, 1.0) 
  else 
    self.lbPreTime:setString(g_tr("arrow_awarding"))
    self.lbTime:setString("")
  end 
end 

return activityArrowRankView 

