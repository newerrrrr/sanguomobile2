

--显示主公战报中的伤害信息
local MailContentBattleGodSkillDetail = class("MailContentBattleGodSkillDetail",require("game.uilayer.base.BaseLayer"))
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()


function MailContentBattleGodSkillDetail:ctor(skillInfos, mailData)
  MailContentBattleGodSkillDetail.super.ctor(self)
  self.mailData = mailData 
  self.infos = skillInfos 
end 

function MailContentBattleGodSkillDetail:onEnter()
  print("MailContentBattleGodSkillDetail:onEnter")
  local layer = g_gameTools.LoadCocosUI("mail_battle_content_pop.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showInfo()
  end 
end 

function MailContentBattleGodSkillDetail:onExit() 
  print("MailContentBattleGodSkillDetail:onExit") 
end 

function MailContentBattleGodSkillDetail:initBinding(rootNode) 
  self.lbTitle = rootNode:getChildByName("text") 
  rootNode:getChildByName("btn_close"):addClickEventListener(handler(self, self.close)) 
  self.listView = rootNode:getChildByName("ListView_1") 
end 

function MailContentBattleGodSkillDetail:showInfo()
  print("=== MailContentBattleGodSkillDetail:showInfo ")

  if nil == self.listView then return end 

  self.listView:removeAllChildren()
  -- self.listView:setItemsMargin(10)
  self.listView:setScrollBarEnabled(false)

  if nil == self.infos or #self.infos == 0 then return end 

  --标题
  local myPlayerId = g_PlayerMode.GetData().id 
  local pid = self.infos[1].pid 

  local nick = MailHelper:getPlayerNickAvatar(self.mailData, pid) 
  local name = myPlayerId==pid and g_tr("MasterTitle") or nick 
  self.lbTitle:setString(g_tr("towerArmyPlayer", {player = name}))

  local item = cc.CSLoader:createNode("mail_battle_content_god_skill_item.csb") 
  for k, v in pairs(self.infos) do 
    local itemNew = item:clone() 
    local root = itemNew:getChildByName("item") 
    local pic_gen = root:getChildByName("pic_gen")
    local name_gen = root:getChildByName("name_gen")
    local lbDesc = root:getChildByName("desc")

    local data = MailHelper:getGodGeneralSkilDesc(v, self.mailData)
    name_gen:setString(data.genName)
    if data.genName ~= "" then 
      MailHelper:loadGeneralSoldierIcon(pic_gen, g_Consts.DropType.General, v.gid*100+1, v.star)
    end 

    lbDesc:setTextAreaSize(cc.size(600, 0)) 
    lbDesc:setString(data.desc)
    g_gameTools.createRichText(lbDesc, data.desc)

    self.listView:pushBackCustomItem(itemNew) 
  end 
end 


return MailContentBattleGodSkillDetail 
