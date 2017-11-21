

--显示主公战报中的部队详情
local MailContentBattlePlayerDetail = class("MailContentBattlePlayerDetail",require("game.uilayer.base.BaseLayer"))
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local BattleSubType = MailHelper:getBattleSubTypeEnum() 

function MailContentBattlePlayerDetail:ctor(subType, playerInfo)
  MailContentBattlePlayerDetail.super.ctor(self)
  self.subType = subType 
  self.playerInfo = playerInfo 
end 

function MailContentBattlePlayerDetail:onEnter()
  print("MailContentBattlePlayerDetail:onEnter")
  local layer = g_gameTools.LoadCocosUI("mail_battle_content_pop.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showInfo()
  end 
end 

function MailContentBattlePlayerDetail:onExit() 
  print("MailContentBattlePlayerDetail:onExit") 
end 


function MailContentBattlePlayerDetail:initBinding(rootNode)
  self.lbTitle = rootNode:getChildByName("text")
  rootNode:getChildByName("btn_close"):addClickEventListener(handler(self, self.close))
  self.listView = rootNode:getChildByName("ListView_1")
end 


function MailContentBattlePlayerDetail:showInfo()
  print("=== MailContentBattlePlayerDetail:showInfo ")

  if nil == self.listView then return end 

  self.listView:removeAllChildren()
  self.listView:setItemsMargin(10)
  self.listView:setScrollBarEnabled(false)

  -- dump(self.playerInfo, "===self.playerInfo")
  if nil == self.playerInfo then return end 


  --标题
  local myPlayerId = g_PlayerMode.GetData().id 
  if self.playerInfo.nick and self.playerInfo.nick ~= "" then 
    local name = myPlayerId==self.playerInfo.player_id and g_tr("MasterTitle") or self.playerInfo.nick 
    self.lbTitle:setString(g_tr("towerArmyPlayer", {player = name}))
  elseif self.subType == BattleSubType.King_PVE or self.subType == BattleSubType.King_NPC then 
    self.lbTitle:setString(g_tr("battleNpc")) --国王战PVE/NPC
  else 
    self.lbTitle:setString("") 
  end 


  --部队详情 
  local troopItem = self:getTroopInfoItem() 
  if troopItem then 
    self.listView:pushBackCustomItem(troopItem) 
  end 
end 


--武将详情
function MailContentBattlePlayerDetail:getTroopInfoItem()
  local tbl1 = {}
  for key, item in pairs(self.playerInfo.unit) do 
    if key == "tower" then --箭塔
      item.type = "tower"
      table.insert(tbl1, item)

    elseif key == "trap" then --陷阱
      for k, v in pairs(item) do 
        v.type = "trap"
        table.insert(tbl1, v)
      end 
    else 
      item.type = "general"
      item.gen_id = 100*tonumber(item.general_id)+1
      item.gen_starlv = item.general_star 
      table.insert(tbl1, 1, item)
    end 
  end 
  
  
  local itemNew, rootNode
  local pos_y = 0 
  local nodeTroops = ccui.Widget:create()
  local troopItem = cc.CSLoader:createNode("mail_battle_content_6.csb")
  troopItem:retain()

  for i=1, #tbl1 do 
    itemNew = troopItem:clone()
    rootNode = itemNew:getChildByName("Panel_1")
    local pic_gen = rootNode:getChildByName("pic_general")
    local name_gen = rootNode:getChildByName("name_general")
    local pic_soldier = rootNode:getChildByName("pic_general_0")
    local pic_level = rootNode:getChildByName("Image_1")
    local name_soldier = rootNode:getChildByName("name_general_0")
    local lbRecall = rootNode:getChildByName("label_sl")

    rootNode:getChildByName("label_1"):setString(g_tr("survive%{val}", {val=tbl1[i].live_num}))
    rootNode:getChildByName("label_2"):setString(g_tr("damage%{val}", {val=tbl1[i].injure_num}))
    rootNode:getChildByName("label_3"):setString(g_tr("kill%{val}", {val=tbl1[i].kill_num}))
    rootNode:getChildByName("label_4"):setString(g_tr("killed%{val}", {val=tbl1[i].killed_num}))
    name_gen:setString("")
    name_soldier:setString("")
    lbRecall:setString("")

    pic_level:setVisible(false)
    if tbl1[i].type == "general" then 
      local item1 = g_data.general[tbl1[i].gen_id]
      local item2 = g_data.soldier[tbl1[i].soldier_id]
      if item1 then 
        MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, tbl1[i].gen_id, tbl1[i].gen_starlv)
        name_gen:setString(g_tr(item1.general_name))
      else 
        pic_gen:setVisible(false)
        -- MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, 0) --默认icon        
      end 
      
      if item2 then 
        MailHelper:loadGeneralSoldierIcon(pic_soldier, g_Consts.DropType.Soldier, tbl1[i].soldier_id)  
        name_soldier:setString(g_tr(item2.soldier_name))
      else 
        -- pic_soldier:setVisible(false)
        MailHelper:loadGeneralSoldierIcon(pic_soldier, g_Consts.DropType.Soldier, 20019)--显示默认士兵 
        name_soldier:setVisible(false)
      end 

      MailHelper:showSoldierAttrTips(pic_soldier, tbl1[i].soldier_id, tbl1[i].attack, tbl1[i].defend, tbl1[i].life) 

      if tbl1[i].revive_num and tonumber(tbl1[i].revive_num) > 0 then 
        lbRecall:setString(g_tr("recallNum", {num=tbl1[i].revive_num}))
      end 
    else 
      pic_soldier:setVisible(false)
      name_soldier:setVisible(false)

      if tbl1[i].type == "trap" then 
        if g_data.trap[tbl1[i].soldier_id] then 
          -- MailHelper:loadResIcon(pic_gen, g_data.trap[tbl1[i].soldier_id].img_head)
          MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.Trap, tbl1[i].soldier_id)   
          name_gen:setString(g_tr(g_data.trap[tbl1[i].soldier_id].trap_name))                
        end 
      elseif tbl1[i].type == "tower" then 
        MailHelper:loadResIcon(pic_gen, g_data.map_element[201].img_mail)
        name_gen:setString(g_tr(g_data.map_element[201].name))   
      end 
    end 

    pos_y = pos_y - itemNew:getContentSize().height 
    itemNew:setPosition(cc.p(0, pos_y))
    nodeTroops:addChild(itemNew)
  end 
  
  local tmp = ccui.Widget:create()
  tmp:setContentSize(cc.size(troopItem:getContentSize().width, -pos_y))
  nodeTroops:setPosition(cc.p(0, -pos_y))
  tmp:addChild(nodeTroops) 

  troopItem:release()

  return tmp 
end 


return MailContentBattlePlayerDetail 
