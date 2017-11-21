local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailType = MailHelper:getMailTypeEnum() 
local AttackedNotice = class("AttackedNotice",require("game.uilayer.base.BaseLayer"))



function AttackedNotice:ctor()
  AttackedNotice.super.ctor(self)
end 

function AttackedNotice:onEnter()
  print("AttackedNotice:onEnter")
  self.mails = MailHelper:getOfflineAttackedMails() 
  local layer = g_gameTools.LoadCocosUI("mail_SuddenStrike_panel.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showAttackListInfo()
  end 
end 

function AttackedNotice:onExit() 
  print("AttackedNotice:onExit") 
end 

function AttackedNotice:initBinding(scaleNode)
  scaleNode:getChildByName("text1"):setString(g_tr_original("attackedByEnemy"))
  scaleNode:getChildByName("Text_2"):setString(g_tr_original("attackedWhenOffline"))
  scaleNode:getChildByName("Text_3"):setString(g_tr_original("attackDetails"))
  self.listView = scaleNode:getChildByName("ListView_1")
  self.btnDetail = scaleNode:getChildByName("Button_1")
  local btnClose = scaleNode:getChildByName("close_btn")

  self:regBtnCallback(btnClose, handler(self, self.close))
  self:regBtnCallback(self.btnDetail, handler(self, self.onDetail))
end 


function AttackedNotice:showAttackListInfo()
  self.listView:removeAllChildren()
  self.listView:setScrollBarEnabled(false)
  
  if nil == self.mails then return end 

  self.btnDetail:setEnabled(#self.mails > 0)

  local itemNew, tt, str, color 
  local listItem = cc.CSLoader:createNode("mail_SuddenStrike.csb")
  listItem:retain()
  for k, v in pairs(self.mails) do 
    itemNew = listItem:clone()
    itemNew:getChildByName("pic_0"):loadTexture(g_resManager.getResPath(1010007))
    if v.data.player2.avatar and v.data.player2.avatar > 0 and g_data.res_head[v.data.player2.avatar] then 
      itemNew:getChildByName("pic"):loadTexture(g_resManager.getResPath(g_data.res_head[v.data.player2.avatar].head_icon))
    end 

    local str = v.data.player2.guild_short_name == "" and v.data.player2.guild_name or ("("..v.data.player2.guild_short_name..")"..v.data.player2.guild_name)
    itemNew:getChildByName("text_guild"):setString(str)
    itemNew:getChildByName("text_name"):setString(v.data.player2.nick)
    
    str = (v.type == MailType.DefenceCityWin) and g_tr_original("defendWin") or g_tr_original("defendLost")
    color = (v.type == MailType.DefenceCityWin) and cc.c3b(9, 221, 9) or cc.c3b(255, 40, 50) 
    itemNew:getChildByName("text_1"):setString(str)
    itemNew:getChildByName("text_1"):setTextColor(color)

    tt = os.date("*t", v.create_time)
    itemNew:getChildByName("text_time"):setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))

    self.listView:pushBackCustomItem(itemNew) 
  end 
  listItem:release()
end 


function AttackedNotice:onDetail()
  g_sceneManager.addNodeForUI(require("game.uilayer.mail.MailBaseLayer").new(MailHelper.viewType.BattleReport)) 
  self:close()
end 

return AttackedNotice 
