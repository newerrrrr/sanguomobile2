
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailContentChat = class("MailContentChat",require("game.uilayer.base.BaseLayer"))
local MailType = MailHelper:getMailTypeEnum() 


local layerObj --当前layer对象
function MailContentChat:ctor(listItem)
  MailContentChat.super.ctor(self)
  layerObj = self 

  -- assert(listItem, "null listItem")
  self.listItem = listItem 
  self.data = listItem:getData() --关联的某一个邮件列表项

  --每一条聊天项ui_widget 
  self.chatItem1 = cc.CSLoader:createNode("mail_chat01.csb") --对方
  self.chatItem2 = cc.CSLoader:createNode("mail_chat02.csb") --自己
  self.chatItem1:retain()
  self.chatItem2:retain()
end 

function MailContentChat:onEnter()
  print("MailContentChat:onEnter")

  local layer = cc.CSLoader:createNode("mail_chat.csb")
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer) 
    self.chatData = MailHelper:GetChatDataByMinId(self.data.mail.type, self.data.mail.connect_id, 0)
    local function sortById(a, b)
      return a.id < b.id 
    end 
    table.sort(self.chatData, sortById)

    self:showChatList(self.chatData) 
  end 
end 

function MailContentChat:onExit() 
  print("MailContentChat:onExit") 
  layerObj = nil 
  self.chatItem1:release()
  self.chatItem2:release()
end 

function MailContentChat:initBinding(rootNode)
  local top_panel = rootNode:getChildByName("top_panel")
  
  local btnFriend = top_panel:getChildByName("img_player")
  local btnBack = top_panel:getChildByName("btn_back")
  self.listView = rootNode:getChildByName("ListView_3")
  local nodeInput = rootNode:getChildByName("Panel_input")
  local btnSend = rootNode:getChildByName("btn_send")
  local lbSend = btnSend:getChildByName("Text")

  lbSend:setString(g_tr("send"))
  self:regBtnCallback(btnFriend, handler(self, self.onSelectFriend))
  -- self:regBtnCallback(self.btnMark, handler(self, self.onMarkMail))
  -- self:regBtnCallback(btnDelete, handler(self, self.onDeleteMail))
  self:regBtnCallback(btnSend, handler(self, self.onSendMail))
  self:regBtnCallback(btnBack, handler(self, self.onGoBack))

  -- local function editboxEventHandler(eventType)
  --   if eventType == "began" then
  --   -- triggered when an edit box gains focus after keyboard is shown<br>
  --   elseif eventType == "ended" then
  --   -- triggered when an edit box loses focus after keyboard is hidden.<br>
  --   elseif eventType == "changed" then
  --   elseif eventType == "return" then
  --   end
  -- end
  local size = nodeInput:getContentSize()
  self.editor = ccui.EditBox:create(size, "cocos/cocostudio_res/alliance/alliance_05.png")
  -- self.editor:setMaxLength(100)
  self.editor:setFontColor(cc.c3b(255, 255, 255))
  self.editor:setPosition(cc.p(size.width/2, size.height/2))
  -- self.editor:registerScriptEditBoxHandler(editboxEventHandler)
  nodeInput:addChild(self.editor)

  btnFriend:setVisible(self.data.mail.type == MailType.ChatGroup)

  -- MailHelper:setImgGray(self.btnMark, self.data.mail.status==0)
end 

--聊天记录列表
function MailContentChat:showChatList(mailTbl)
  self.listView:removeAllChildren()
  self.listView:setItemsMargin(10)
  self.listView:setScrollBarEnabled(false)

  for i=1, #mailTbl do 
    self:insertChatItem(mailTbl[i], -1)
  end 
  self.listView:doLayout()
  self.listView:jumpToBottom()

  --下拉/上拉刷新控件
  local PullToRefreshControl = require("game.uilayer.common.PullToRefreshControl").new()
  PullToRefreshControl:addListner(self.listView, handler(self, self.onPullUpRefresh), nil)
  PullToRefreshControl:setTag(123)
  self.listView:addChild(PullToRefreshControl)
end 

--追加一条聊天项 
--index: 0:在最前面插入  -1:在最后追加
function MailContentChat:insertChatItem(mail, index) 

  local item 
  if tostring(mail.from_player_id) == "0" then --系统发的提示邮件

    item = ccui.Widget:create()   
    local text = ccui.Text:create(tostring(mail.msg), "Arial", 26) --g_gameTools.createLabelDefaultFont
    item:addChild(text)
    text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    text:setAnchorPoint(cc.p(0, 1))
    text:setTextColor(cc.c3b(253, 208, 110))
    local bgSize = self.chatItem1:getContentSize() 
    local gap = 100 
    local strSize = text:getContentSize() 
    if strSize.width > bgSize.width-2*gap then 
      text:setTextAreaSize(cc.size(bgSize.width-2*gap, 0))
      text:ignoreContentAdaptWithSize(false)
      strSize = text:getContentSize()
    end 
    text:setPosition(cc.p((bgSize.width-strSize.width)/2, strSize.height))
    item:setContentSize(cc.size(bgSize.width, strSize.height))

  else 
    local myPlayerId = tostring(g_PlayerMode.GetData().id)
    item = (tostring(mail.from_player_id) == myPlayerId) and self.chatItem2:clone() or self.chatItem1:clone() 

    local rootNode = item:getChildByName("Panel_1")
    local lbTime = rootNode:getChildByName("Text_time")
    local imgContentBg = rootNode:getChildByName("Image_bg")
    local nodeRegion = rootNode:getChildByName("Panel_region")
    local lbContent = rootNode:getChildByName("Text_1")
    if target ~= cc.PLATFORM_OS_ANDROID and target ~= cc.PLATFORM_OS_WINDOWS then 
      lbContent:setFontName("Heiti SC")
      lbContent:setFontSize(lbContent:getFontSize())
    end 
    
    local tt = os.date("*t", mail.create_time)
    lbTime:setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))

    if mail.from_player_avatar then 
      local id = tonumber(mail.from_player_avatar)
      if nil == id or id == 0 then 
        id = 1020143 
      end 
      MailHelper:loadPlayerIcon(rootNode:getChildByName("pic"), id) 
      rootNode:getChildByName("Text_name"):setString(mail.from_player_name)
    end 

    --聊天内容自动换行
    local strRegion = nodeRegion:getContentSize()
    lbContent:setString(tostring(mail.msg))
    local strSize = lbContent:getContentSize()
    if strSize.width > strRegion.width then 
      lbContent:setTextAreaSize(cc.size(strRegion.width, 0))
      lbContent:ignoreContentAdaptWithSize(false)
      strSize = lbContent:getContentSize()
    end 
    if strSize.height < strRegion.height then 
      lbContent:setPositionY(nodeRegion:getPositionY()-(strRegion.height-strSize.height)/2)
    end 

    --调整背景高度
    local deltaH = strSize.height - strRegion.height
    if deltaH > 0 then 
      imgContentBg:setContentSize(cc.size(imgContentBg:getContentSize().width, imgContentBg:getContentSize().height+deltaH+2))
      item:setContentSize(cc.size(item:getContentSize().width, item:getContentSize().height+deltaH+2))
      rootNode:setPositionY(deltaH)
    end 
  end 

  if item then 
    if index >= 0 then 
      self.listView:insertCustomItem(item, index)
    else 
      self.listView:pushBackCustomItem(item) 
    end 
  end 
end 

--下拉更新旧聊天记录
function MailContentChat:onPullUpRefresh()
  print("onPullUpRefresh")

  --计算最小邮件id
  local minId = 0xFFFFFFFF
  for k, v in pairs(self.chatData) do 
    if v.id < minId then 
      minId = v.id 
    end 
  end 
  if minId == 0xFFFFFFFF then minId = 0 end 
  
  local data = MailHelper:GetChatDataByMinId(self.data.mail.type, self.data.mail.connect_id, minId)
  if #data > 0 then 
    table.sort(self.chatData, function(a, b) return a.id < b.id end )

    for i=1, #data do 
      self:insertChatItem(data[i], 0)
      table.insert(self.chatData, 1, data[i])
    end 
    self.listView:doLayout()
    self.listView:jumpToBottom()
  end 
end 

--上拉更新
-- function MailContentChat:onPullDownRefresh()
--   print("onPullDownRefresh")

-- end 

--添加聊天成员
function MailContentChat:onSelectFriend()
  print("onSelectFriend")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  local function onSelectPlayer(tbl)
    print("onSelectPlayer")
    
    if #tbl > 0 then 
      local data = self.listItem:getData() 
      --筛选出新加入的玩家
      local isSameName 
      local newPlayerIds = {}

      for k, v in pairs(tbl) do 
        isSameName = false 
        for i, member in pairs(data.groupMembers) do 
          if v.Player.nick == member.nick then 
            isSameName = true 
            break 
          end 
        end 
        if not isSameName then 
          table.insert(newPlayerIds, v.player_id)
        end 
      end 

      --通知服务器
      if #newPlayerIds > 0 then 
        local function addToChatGroupResult(result, msgData)
          print("addToChatGroupResult: result=", result)
          if result then 
            data.groupMembers = msgData.groupMember 
            self.listItem:setData(data) 
            g_MailMode.setMailData(MailHelper.viewType.ChatInfo, data.mail, data.groupMembers)
            
            self:updateNewChatLog()
          end 
        end         
        g_sgHttp.postData("Mail/groupAddPlayer", {groupId=data.mail.connect_id, playerIds=newPlayerIds}, addToChatGroupResult) 
      end 
    end 
  end 

  --退出组群的同时删除该邮件
  local function onQuitGuild()
    local function quitResult(result, msgData)
      print("onQuitGuild, result=", result)
      if result then 
        self:onDeleteMail()
      end 
    end 
    g_sgHttp.postData("Mail/groupQuit", {groupId=self.listItem:getData().mail.connect_id}, quitResult) 
  end 

  local names = {}
  local members = self.listItem:getData().groupMembers 
  if members and #members > 0 then 
    for k, v in pairs(members) do 
      table.insert(names, v.nick)
    end 
    local layer = require("game.uilayer.common.SelectGuildPlayerView").new() 
    layer:setSaveCallback(onSelectPlayer) 
    layer:setQuitCallback(onQuitGuild) 
    g_sceneManager.addNodeForUI(layer) 
    layer:initSelectedState(names, false)
  end 
end 


--收藏/取消收藏
function MailContentChat:onMarkMail()
  print("onMarkMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  if self:getDelegate() then 
    local ret = self:getDelegate():doMarkMails({self.listItem})
    if ret then 
      self.data = self.listItem:getData()
      MailHelper:setImgGray(self.btnMark, self.data.mail.status==0)
    end 
  end 
end 

function MailContentChat:onDeleteMail()
  print("onDeleteMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  if self:getDelegate() then 
    self:getDelegate():doDeleteMails({self.listItem})
  end 
end 

function MailContentChat:onGoBack()
  if self:getDelegate() then 
    self:getDelegate():onGoBack()
  end 
end 

function MailContentChat:updateNewChatLog()
  local maxId = 0
  for k, v in pairs(self.chatData) do 
    if v.id > maxId then 
      maxId = v.id 
    end 
  end 
  local newMails = MailHelper:getNewestChatDataByMaxId(self.data.mail.type, self.data.mail.connect_id, maxId, true)
  dump(newMails, "send new mail:")
  for i=1, #newMails do 
    self:insertChatItem(newMails[i], -1)
    table.insert(self.chatData, newMails[i])
  end 
  self.listView:doLayout()
  self.listView:jumpToBottom()
end 

function MailContentChat:onSendMail()
  print("onSendMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local str = self.editor:getText()
  if str:len() <= 0 then 
    g_airBox.show(g_tr("noContent"))
    return 
  end 

  local function sendResult(result, data)
    print("sendResult:", result)
    if result then 
      self.editor:setText("")
      self:updateNewChatLog()
    end 
  end 

  --type: 2:发送给群组里的多人;  1:发送给单人(groupId)
  local sendtype = (self.data.mail.type == MailType.ChatGroup) and 2 or 1
  local receiver = self.data.mail.connect_id 
  g_sgHttp.postData("Mail/chat", {type = sendtype, toPlayer = receiver, msg = str}, sendResult) 
end 

--收到新邮件通知时更新聊天记录显示
function MailContentChat:updateNewMails(data)
  if nil == data then return end 
  
  print("MailContentChat:updateNewMails")

  local newMails = MailHelper:getNewestChatDataByMaxId(data.mail_type, data.connect_id, math.max(0, data.mail_id-1), false)
  dump(newMails, "newMails")
  for i=1, #newMails do 
    --同一组聊天项才更新到当前界面
    if self.data.mail.connect_id == newMails[i].connect_id then 
      self:insertChatItem(newMails[i], -1)
      table.insert(self.chatData, newMails[i])
      
      if self:getDelegate() then --通知服务器已读 
        self:getDelegate():setMailIsRead(MailHelper.viewType.ChatInfo, self.listItem)
      end 
    end 
  end 
  self.listView:doLayout()
  self.listView:jumpToBottom()
end 

function MailContentChat:appendNewChat(mail)
  print("appendNewChat")
  if nil == mail then return end 

  if self.data.mail.connect_id == mail.connect_id then
    local newMails = MailHelper:getNewestChatDataByMaxId(mail.type, mail.connect_id, math.max(0, mail.id-1), false)
    for i=1, #newMails do 
      self:insertChatItem(newMails[i], -1)
      table.insert(self.chatData, newMails[i])
    end 
    self.listView:doLayout()
    self.listView:jumpToBottom()

    if self:getDelegate() then --通知服务器已读 
      self:getDelegate():setMailIsRead(MailHelper.viewType.ChatInfo, self.listItem)
    end     
  end 
end 


return MailContentChat 
