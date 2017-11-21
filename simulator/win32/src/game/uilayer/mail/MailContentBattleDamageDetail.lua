

--显示主公战报中的伤害信息
local MailContentBattleDamageDetail = class("MailContentBattleDamageDetail",require("game.uilayer.base.BaseLayer"))
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local BattleSubType = MailHelper:getBattleSubTypeEnum() 

function MailContentBattleDamageDetail:ctor(subType, playerInfo, maxDoDamage, maxSuffeDamage)
  MailContentBattleDamageDetail.super.ctor(self)
  self.battleSubType = subType 
  self.playerInfo = playerInfo 
  self.maxDoDamage = maxDoDamage 
  self.maxSufferDamage = maxSuffeDamage 
end 

function MailContentBattleDamageDetail:onEnter()
  print("MailContentBattleDamageDetail:onEnter")
  local layer = g_gameTools.LoadCocosUI("mail_battle_content_pop.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showInfo()
  end 
end 

function MailContentBattleDamageDetail:onExit() 
  print("MailContentBattleDamageDetail:onExit") 
end 

function MailContentBattleDamageDetail:initBinding(rootNode) 
  self.lbTitle = rootNode:getChildByName("text") 
  rootNode:getChildByName("btn_close"):addClickEventListener(handler(self, self.close)) 
  self.listView = rootNode:getChildByName("ListView_1") 
end 

function MailContentBattleDamageDetail:showInfo()
  print("=== MailContentBattleDamageDetail:showInfo ")

  if nil == self.listView then return end 

  self.listView:removeAllChildren()
  -- self.listView:setItemsMargin(10)
  self.listView:setScrollBarEnabled(false)

  if nil == self.playerInfo or nil == self.playerInfo.unit then return end 

  --标题
  local myPlayerId = g_PlayerMode.GetData().id 
  if self.playerInfo.nick and self.playerInfo.nick ~= "" then 
    local name = myPlayerId==self.playerInfo.player_id and g_tr("MasterTitle") or self.playerInfo.nick 
    self.lbTitle:setString(g_tr("towerArmyPlayer", {player = name}))
  elseif self.battleSubType == BattleSubType.King_PVE or self.battleSubType == BattleSubType.King_NPC then 
    self.lbTitle:setString(g_tr("battleNpc")) --国王战PVE/NPC
  else 
    self.lbTitle:setString("") 
  end 

  local item = cc.CSLoader:createNode("mail_battle_content_damage_item.csb") 
  local unit = MailHelper:getDamageUnit(self.playerInfo.unit) 
  for k, v in pairs(unit) do 
    local itemNew = item:clone() 
    local root = itemNew:getChildByName("item") 
    local pic_gen = root:getChildByName("Image_t1")
    local name_gen = root:getChildByName("label1")
    local pic_soldier = root:getChildByName("Image_t2") 
    local name_soldier = root:getChildByName("label2") 

    local gen = g_data.general[100*v.general_id + 1]
    if gen then 
      MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, 100*v.general_id+1, v.general_star)
      name_gen:setString(g_tr(gen.general_name))
    else 
      name_gen:setString("")
    end 

    local soldierId = v.soldier_id 
    if v.soldier_id == 0 and v.general_id == 0 and 
      (self.battleSubType == BattleSubType.King_PVE or self.battleSubType == BattleSubType.King_NPC) then 
      soldierId = 20019 
    end 

    if soldierId and soldierId > 0 and g_data.soldier[soldierId] then 
      MailHelper:loadGeneralSoldierIcon(pic_soldier, g_Consts.DropType.Soldier, soldierId) 
      name_soldier:setString(g_tr(g_data.soldier[soldierId].soldier_name)) 
    else 
      pic_soldier:setVisible(false)
      name_soldier:setString("")
    end 

    root:getChildByName("Text_4"):setString(""..v.doDamage)
    root:getChildByName("Text_5"):setString(""..v.takeDamage)
    root:getChildByName("LoadingBar_1"):setPercent(math.min(100, 100*v.doDamage/self.maxDoDamage))
    root:getChildByName("LoadingBar_2"):setPercent(math.min(100, 100*v.takeDamage/self.maxSufferDamage))

    self.listView:pushBackCustomItem(itemNew) 
  end 
end 


return MailContentBattleDamageDetail 
