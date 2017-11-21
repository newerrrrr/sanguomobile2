
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailContentWrite = class("MailContentWrite",require("game.uilayer.base.BaseLayer"))
local layerObj --当前layer对象

--isSendToAlliance:是否是联盟邮件,如果是联盟邮件则没有收件人, 也不可以选择联盟成员 
--recvName: 指定收件人
function MailContentWrite:ctor(isSendToAlliance, recvName)
  MailContentWrite.super.ctor(self)
  layerObj = self 
  self.isSendToAlliance = isSendToAlliance 
  self.recvName = recvName 
end 

function MailContentWrite:onEnter()
  print("MailContentWrite:onEnter")

  local layer = cc.CSLoader:createNode("mail_write.csb")
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer) 
  end 
end 

function MailContentWrite:onExit() 
  print("MailContentWrite:onExit") 
  layerObj = nil 
end 

function MailContentWrite:initBinding(rootNode)
  local lbPreReceiver = rootNode:getChildByName("text_to") 
  local nodeRecv = rootNode:getChildByName("Panel_recv") 

  local lbPreContent = rootNode:getChildByName("text_content") 
  local imgContent = rootNode:getChildByName("content_bg") 
  local nodeContent = rootNode:getChildByName("content_node") 

  local btnFriend = rootNode:getChildByName("btn_members") 
  local btnSend = rootNode:getChildByName("btn_send") 
  local lbFriend = rootNode:getChildByName("btn_members"):getChildByName("Text") 
  local lbSend = rootNode:getChildByName("btn_send"):getChildByName("Text") 

  lbPreReceiver:setString(g_tr("mailReceiver"))
  lbPreContent:setString(g_tr("mailContent"))
  lbFriend:setString(g_tr("friends"))
  lbSend:setString(g_tr("send"))

  self:regBtnCallback(btnFriend, handler(self, self.onSelectPlayers)) 
  self:regBtnCallback(btnSend, handler(self, self.onSend)) 

  --1. 收件人
  local recvSize = nodeRecv:getContentSize()

  -- local clippingNode = cc.ClippingNode:create()
  -- clippingNode:setPosition(cc.p(nodeRecv:getPosition()))
  -- nodeRecv:getParent():addChild(clippingNode) --必须添加到同级或当前层,否则会屏蔽本身或其他区域(根据setInverted())
  -- clippingNode:setContentSize(recvSize)
  -- clippingNode:setInverted(false) --false则仅显示其child内容
  -- clippingNode:setAlphaThreshold(0.5)

  --收件人编辑框
  self.editorRecv = ccui.EditBox:create(recvSize, ccui.Scale9Sprite:create())
  self.editorRecv:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
  self.editorRecv:setFontSize(24)
  self.editorRecv:setFontColor(cc.c3b(255, 255, 255))  
  self.editorRecv:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
  -- self.editorRecv:registerScriptEditBoxHandler(recvEditboxEventHandler)
  self.editorRecv:setPosition(cc.p(recvSize.width/2, recvSize.height/2)) 
  nodeRecv:addChild(self.editorRecv) 
  -- clippingNode:setStencil(self.editorRecv) 
  -- clippingNode:addChild(self.editorRecv) 

  if self.isSendToAlliance then --发送给联盟全体
    self.editorRecv:setText(g_tr("allAllianceMembers"))
    self.editorRecv:setTouchEnabled(false)
    btnFriend:setVisible(false)

  elseif self.recvName then --发给指定收件人
    self.editorRecv:setText(self.recvName)
    btnFriend:setVisible(false) 

  else --手动选择收件人
--[[
    --在最上面盖一层触摸侦听
    local function onTouchRecvBegan(touch, event) 
      local pos = nodeRecv:convertToNodeSpace(touch:getLocation())
      if pos.x >= 0 and pos.x <= recvSize.width and pos.y >= 0 and pos.y <= recvSize.height then 
        self.isMoving = false 
        return true 
      end 
      return false 
    end 

    local function onTouchRecvMoved(touch, event) 
      self.isMoving = true 
      local deltaX = touch:getDelta().x
      local strWidth = self.lbRecv:getContentSize().width
      if strWidth > recvSize.width then 
        local x = self.lbRecv:getPositionX() + deltaX 
        local x_min = recvSize.width - strWidth 
        local x_max = 4 
        x = math.max(x_min, x) 
        x = math.min(x, x_max) 
        self.lbRecv:setPositionX(x) 
      else 
        self.lbRecv:setPositionX(4)
      end 
    end 

    local function onTouchRecvEnded(touch, event) 
      if not self.isMoving then -- 单击时触发输入编辑
        self.editorRecv:touchDownAction(self.editorRecv, ccui.TouchEventType.ended)
      end 
    end 

    local mask = cc.Layer:create()
    mask:setContentSize(recvSize)
    mask:setTouchEnabled(true)
    clippingNode:addChild(mask)

    local listener = cc.EventListenerTouchOneByOne:create()  
    listener:registerScriptHandler(onTouchRecvBegan, cc.Handler.EVENT_TOUCH_BEGAN )  
    listener:registerScriptHandler(onTouchRecvMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchRecvEnded, cc.Handler.EVENT_TOUCH_ENDED )  
    mask:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, mask)  
--]]
  end 

  --2.邮件内容
  local contentSizeMax = nodeContent:getContentSize()
  -- local function contentEditboxEventHandler(eventType, sender)
  --   if eventType == "began" then
  --   elseif eventType == "return" then
  --   end 
  -- end 
  self.editorContent = ccui.EditBox:create(contentSizeMax, ccui.Scale9Sprite:create())
  self.editorContent:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
  self.editorContent:setFontSize(24)
  self.editorContent:setFontColor(cc.c3b(255, 255, 255))
  self.editorContent:setPosition(cc.p(contentSizeMax.width/2, contentSizeMax.height/2))
  self.editorContent:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
  nodeContent:addChild(self.editorContent)  
  -- self.editorContent:registerScriptEditBoxHandler(contentEditboxEventHandler)
end 


function MailContentWrite:onSelectPlayers()
  print("onSelectPlayers")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if not g_AllianceMode.getSelfHaveAlliance() then --如果未加入公会,则不可选择盟友
    g_airBox.show(g_tr("battleHallNoAlliance"))
    return 
  end 
  
  local function onSelectPlayer(tbl)
    print("onSelectPlayer")
    if #tbl > 0 then 
      local str = ""
      for k, v in pairs(tbl) do 
        str = str .. v.Player.nick .. ";"
      end 
      self.editorRecv:setText(str)
    end 
  end 

  
  local layer = require("game.uilayer.common.SelectGuildPlayerView").new(true)
  layer:setSaveCallback(onSelectPlayer)
  g_sceneManager.addNodeForUI(layer) 

  local recvStr = self.editorRecv:getText()
  if recvStr ~= "" then 
    local result, names = MailHelper:getRecvNames(recvStr)
    if result then 
      layer:initSelectedState(names, true)
    end 
  end 
end 

function MailContentWrite:onSend()
  print("onSend")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  local function sendResult(result, data)
    print("sendResult:", result)
    if result then 
      g_airBox.show(g_tr("sendSuccess"))

      --reset 
      self.editorRecv:setText("")
      self.editorContent:setText("")
      --通知用户
      if self._successCallback then 
        self._successCallback() 
      end 
    end 
  end 

  --邮件内容
  local contentStr = MailHelper:getTrimedSpace(self.editorContent:getText()) 
  dump(contentStr, "contentStr")
  if contentStr == "" then 
    g_airBox.show(g_tr("noContent"))
    return 
  end  

  if self.isSendToAlliance then --联盟邮件
    g_sgHttp.postData("Mail/chat", {type = 3, msg = contentStr}, sendResult)

  else 
    --收件人
    local str = self.recvName or self.editorRecv:getText()
    if str == "" then 
      g_airBox.show(g_tr("noReceiver"))
      return 
    end 
    --收件人检测
    local result, recvNames = MailHelper:getRecvNames(str)
    if not result or #recvNames == 0 then 
      g_airBox.show(g_tr("invalidRecvName"))
      return 
    end 

    --type: 2:发送给群组里的多人;  4:发送给单人
    local sendtype = (#recvNames > 1) and 2 or 4 
    g_sgHttp.postData("Mail/chat", {type = sendtype, toPlayer = recvNames, msg = contentStr}, sendResult) 
  end 
end 


function MailContentWrite:setSuccessCallback(callback)
  self._successCallback = callback 
end 


return MailContentWrite 
