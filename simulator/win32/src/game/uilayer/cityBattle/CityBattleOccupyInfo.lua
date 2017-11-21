local CityBattleOccupyInfo = class("CityBattleOccupyInfo",require("game.uilayer.base.BaseLayer"))

local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode")

local viewObj

function CityBattleOccupyInfo:ctor()
  CityBattleOccupyInfo.super.ctor(self)

  viewObj = self

  local layer = g_gameTools.LoadCocosUI("CityBattle_popup03.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer)

    local data = CityBattleMode:getOccupyInfo() 
    if nil == data or nil == data.lastReqTime or data.lastReqTime + 30 < os.time() then 
      CityBattleMode:RequestOccupyInfo(true, handler(self, self.updateUI)) 
    else   
      self:updateUI(data)
    end 
  end 
end 

function CityBattleOccupyInfo:onEnter()
  print("CityBattleOccupyInfo:onEnter")
end 

function CityBattleOccupyInfo:onExit() 
  print("CityBattleOccupyInfo:onExit") 
  viewObj = nil 
end 


function CityBattleOccupyInfo:initBinging(layer)

  self.scale_node = layer:getChildByName("scale_node")

  self.scale_node:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("allianceRankDetail"))

  local btnClose = self.scale_node:getChildByName("close_btn") 
  local btnConfirm = self.scale_node:getChildByName("Button_q1") 
  self:regBtnCallback(btnClose, handler(self, self.close))
  self:regBtnCallback(btnConfirm, handler(self, self.close))

  btnConfirm:getChildByName("Text_19"):setString(g_tr("confirm"))

  for i=1, 3 do --魏蜀吴旗子
    local img_flag = g_resManager.getRes(g_data.country_camp_list[i].camp_pic)
    local node = self.scale_node:getChildByName("Panel_q"..i)
    img_flag:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
    node:addChild(img_flag) 
  end 

  self.scale_node:getChildByName("Text_jf1"):setString(g_tr("city_battle_occupy_count", {num = ""}))
  self.scale_node:getChildByName("Text_jf2"):setString(g_tr("city_battle_occupy_count", {num = ""}))
  self.scale_node:getChildByName("Text_jf3"):setString(g_tr("city_battle_occupy_count", {num = ""}))
  self.scale_node:getChildByName("Text_jf4"):setString(g_tr("city_battle_occupy_score", {score = ""}))
  self.scale_node:getChildByName("Text_jf5"):setString(g_tr("city_battle_occupy_score", {score = ""}))
  self.scale_node:getChildByName("Text_jf6"):setString(g_tr("city_battle_occupy_score", {score = ""}))

  local listView = self.scale_node:getChildByName("ListView_1") 
  listView:removeAllChildren() 
end 


function CityBattleOccupyInfo:updateUI(serverData) 
  print("updateUI")

  if nil == viewObj then return end 
  if nil == self.scale_node or nil == serverData then return end 

  -- dump(serverData, "serverData")
  if serverData.camp_data then 
    local item 
    for k, v in pairs(serverData.camp_data) do 
      item = g_data.country_camp_list[v.camp_id]
      if item then 
        self.scale_node:getChildByName("Text_jf"..v.camp_id):setString(g_tr("city_battle_occupy_count", {num = v.city_number}))
        self.scale_node:getChildByName("Text_jf"..(v.camp_id+3)):setString(g_tr("city_battle_occupy_score", {score = v.camp_score}))
      end 
    end 
  end 

  local listView = self.scale_node:getChildByName("ListView_1") 
  listView:removeAllChildren() 

  if serverData.cityBattle_data then 
    local tbl = clone(serverData.cityBattle_data)
    table.sort(tbl, function(a, b) return a.start_time > b.start_time end)

    for k, v in pairs(tbl) do 
      if v.win_camp > 0 then 
        local tt = g_clock.getCurServerTimeWithTimezone(v.start_time, true) 
        local strTime = string.format("%d-%d-%d", tt.year, tt.month, tt.day)
        local item_city = g_data.country_city_map[v.city_id] 
        local country = g_tr("city_battle_camp"..v.win_camp)
        local strCity = item_city and g_tr(item_city.ctiy_name) or "X"
        local strScore = item_city and item_city.point or "?" 
        local str = g_tr("city_battle_occupy_item",{time = strTime, camp = country, city = strCity, score = strScore})

        local size = cc.size(listView:getContentSize().width, 30)
        local node = ccui.Widget:create()      
        node:setContentSize(size)
        local richText = g_gameTools.createNoModeRichText(str, {fontSize = 24, width = size.width, height = size.height})
        richText:setAnchorPoint(cc.p(0, 0.5)) 
        richText:setPosition(cc.p(0, size.height/2))
        node:addChild(richText)
        
        listView:pushBackCustomItem(node) 
      end 
    end 
  end 
end 




return CityBattleOccupyInfo

