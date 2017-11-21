
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailContentWritePop = class("MailContentWritePop",require("game.uilayer.base.BaseLayer"))
local layerObj --当前layer对象

--isSendToAlliance:是否是联盟邮件,如果是联盟邮件则没有收件人, 也不可以选择联盟成员 
--recvName: 指定收件人,如果是联盟全体,则不填
function MailContentWritePop:ctor(isSendToAlliance, recvName)
  MailContentWritePop.super.ctor(self)
  layerObj = self 
  self.isSendToAlliance = isSendToAlliance 
  self.recvName = recvName 
end 

function MailContentWritePop:onEnter()
  print("MailContentWritePop:onEnter")

  local layer = g_gameTools.LoadCocosUI("mail_alliance_write.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
  end 
end 

function MailContentWritePop:onExit() 
  print("MailContentWritePop:onExit") 
  layerObj = nil 
end 

function MailContentWritePop:initBinding(scaleNode)
  local content_popup = scaleNode:getChildByName("content_popup")
  local btnClose = content_popup:getChildByName("close_btn")
  local lbTitle = content_popup:getChildByName("img_title_bg"):getChildByName("text")
  local nodeWrite = content_popup:getChildByName("Panel_1")

  self:regBtnCallback(btnClose, handler(self, self.close))
  lbTitle:setString(g_tr("sendMail"))

  local layer = require("game.uilayer.mail.MailContentWrite").new(self.isSendToAlliance, self.recvName)
  if layer then 
    layer:setSuccessCallback(handler(self, self.close)) 
    nodeWrite:addChild(layer) 
  end 
end 


return MailContentWritePop 
