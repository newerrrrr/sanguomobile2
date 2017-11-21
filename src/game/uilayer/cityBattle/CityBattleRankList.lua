local CityBattleRankList = class("CityBattleRankList",require("game.uilayer.base.BaseLayer"))

local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode")

local viewObj
local curTabIndex 

function CityBattleRankList:ctor()
  CityBattleRankList.super.ctor(self)

  viewObj = self

  local layer = g_gameTools.LoadCocosUI("CityBattle_popup04.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer)

    local data = CityBattleMode:getRankListData() 
    if nil == data or nil == data.lastReqTime or data.lastReqTime + 30 < os.time() then 
      CityBattleMode:RequestRankList(true, handler(self, self.updateUI)) 
    else 
      self:updateUI(1) 
    end 
  end 
end 

function CityBattleRankList:onEnter()
  print("CityBattleRankList:onEnter")
end 

function CityBattleRankList:onExit() 
  print("CityBattleRankList:onExit") 
  viewObj = nil 
end 

function CityBattleRankList:initBinging(layer)

  self.scale_node = layer:getChildByName("scale_node") 
  self.scale_node:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("city_battle_rank_title"))
  self.scale_node:getChildByName("text_0"):setString(g_tr("city_battle_rank_id"))
  self.scale_node:getChildByName("text_1"):setString(g_tr("city_battle_rank_name"))
  self.scale_node:getChildByName("text_2"):setString(g_tr("city_battle_rank_info"))
  self.scale_node:getChildByName("text_3"):setString(g_tr("city_battle_rank_value")) 

  local btnClose = self.scale_node:getChildByName("close_btn") 
  local btnHelp = self.scale_node:getChildByName("Image_wenh") 
  self:regBtnCallback(btnClose, handler(self, self.close))
  self:regBtnCallback(btnHelp, handler(self, self.onHelp))

  --魏蜀吴按钮
  local onListFunc = {self.onListWei,self.onListShu, self.onListWu}
  for i=1, 3 do 
    local btn = self.scale_node:getChildByName("Button_"..i) 
    btn:getChildByName("Text_1"):setString(g_tr("city_battle_camp"..i))
    self:regBtnCallback(btn, handler(self, onListFunc[i]))
    btn:getChildByName("Image_1"):loadTexture(g_resManager.getResPath(g_data.country_camp_list[i].camp_pic))
  end 
end 

function CityBattleRankList:initData()
  if self.campData then return end 

  local data = CityBattleMode:getRankListData() 
  if nil == data then return end 
  -- dump(data, "==data")
  local tmpData = {{}, {}, {}}
  for k, v in pairs(data) do 
    if type(v) == "table" then 
      if v.camp_id and v.camp_id > 0 and v.camp_id <= 3 then 
        table.insert(tmpData[v.camp_id], v) 
      end 
    end 
  end 

  local hasData = false 
  for i = 1, 3 do 
    if #tmpData[i] > 0 then 
      hasData = true 
      table.sort(tmpData[i], function(a, b) return a.rank < b.rank  end ) 
    end 
  end 

  if hasData then 
    self.campData = tmpData 
  end 
  dump(self.campData, "===self.campData")
end 

function CityBattleRankList:onListWei()
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  if curTabIndex == 1 then return end 
  self:updateUI(1) 
end 

function CityBattleRankList:onListShu()
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  if curTabIndex == 2 then return end 
  self:updateUI(2) 
end 

function CityBattleRankList:onListWu() 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  if curTabIndex == 3 then return end 
  self:updateUI(3) 
end 

function CityBattleRankList:highlightTab(index)
  for i=1, 3 do 
    local btn = self.scale_node:getChildByName("Button_"..i) 
    btn:setHighlighted(i == index)
  end 
end 

function CityBattleRankList:updateUI(idx)
  if nil == viewObj then return end 

  self:initData()

  local index = idx or curTabIndex or 1 
  curTabIndex = index 
  self:highlightTab(index) 
  self:showRankList(index) 
end 

function CityBattleRankList:showRankList(index)

  local listView = self.scale_node:getChildByName("ListView_1")
  listView:removeAllChildren()

  if nil == self.campData then return end 
  
  local tt = self.campData[index] 
  if #tt < 1 then return end  

  local function getDataByRank(rank)
    for k, v in pairs(tt) do 
      if v.rank and v.rank == rank then 
        return v 
      end 
    end 
    return 
  end 

  local rankMax = math.min(10, tt[#tt].rank) 
  for i = 1, rankMax do 
    local item = cc.CSLoader:createNode("CityBattle_popup04_list1.csb")  
    item:getChildByName("Image_1"):setVisible(i == 1)
    item:getChildByName("Image_2"):setVisible(i == 2)
    item:getChildByName("Image_3"):setVisible(i == 3)
    item:getChildByName("Text_sz"):setString(""..i)  
    
    local info = getDataByRank(i) 
    if info then 
      local iconId = info.rank < 3 and 1083001 or 1083002 --排名1,2为勇者，其他为羽林军
      item:getChildByName("Image_ch1"):loadTexture(g_resManager.getResPath(iconId))
      item:getChildByName("Text_mz"):setString(string.format("S%d  %s  %s", info.server_id, info.guild_name, info.nick))
      item:getChildByName("Text_yyz"):setString(string.format("%d", info.score))
    else 
      item:getChildByName("Text_mz"):setString(g_tr("city_battle_rank_reclaim"))
      item:getChildByName("Text_yyz"):setString("")
    end 
    listView:pushBackCustomItem(item) 
  end 
end 

function CityBattleRankList:onHelp()
  require("game.uilayer.common.HelpInfoBox"):show(58)
end 

return CityBattleRankList 
