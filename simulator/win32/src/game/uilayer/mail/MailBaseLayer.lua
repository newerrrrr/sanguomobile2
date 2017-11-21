


local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailBaseLayer = class("MailBaseLayer",require("game.uilayer.base.BaseLayer"))
local MailType = MailHelper:getMailTypeEnum() 
local Tag = {Mail = 1, PullControll = 2}
local layerObj --当前layer对象
local unReadInfo = {}

function MailBaseLayer:ctor(viewType)
  MailBaseLayer.super.ctor(self)
  print("MailBaseLayer:ctor")

  layerObj = self 
  self.enterView = viewType 
  self.isSelectedAll = false 
  self.mailsData = {}
end 

function MailBaseLayer:onEnter()
  print("MailBaseLayer:onEnter")
  
  local layer = g_gameTools.LoadCocosUI("mail.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer:getChildByName("scale_node")) 
    self:showMailTypeList(self.enterView)
  end 
  g_MailMode.setMailView(self)
  -- g_gameCommon.addEventHandler(g_Consts.CustomEvent.NewMail, MailBaseLayer.insertNewMail, self)
end 

function MailBaseLayer:onExit() 
  print("MailBaseLayer:onExit") 
  layerObj = nil 
  g_MailMode.setMailView(nil)
  -- g_gameCommon.removeAllEventHandlers(self)
end 

function MailBaseLayer:initBinding(scaleNode)

  self.imgBg = scaleNode:getChildByName("Image_dingtu") 
  local btnClose = scaleNode:getChildByName("close_btn") 
  local lbTitle = scaleNode:getChildByName("Text_1") 
  self.imgArrowUp = scaleNode:getChildByName("arrow_up") 
  self.imgArrowDwn = scaleNode:getChildByName("arrow_down") 

  --邮件种类
  self.typeList = scaleNode:getChildByName("ListView_left")

  --通用邮件列表
  self.nodeMailList = scaleNode:getChildByName("panel_list") 
  self.nodeSelectAll = self.nodeMailList:getChildByName("Panel_selectAll")
  local btnSelectAll = self.nodeSelectAll:getChildByName("img_select_bg")
  self.imgSelectAll =  self.nodeSelectAll:getChildByName("img_select")
  local lbAll = self.nodeSelectAll:getChildByName("Text")
  self.btnMark = self.nodeMailList:getChildByName("img_mark")
  self.btnDelete = self.nodeMailList:getChildByName("img_delete")
  self.mailListView = self.nodeMailList:getChildByName("ListView_1") 

  --邮件内容节点
  self.nodeContent = scaleNode:getChildByName("panel_content") 

  --战斗列表单选菜单栏
  self.nodeBattleBar = self.nodeMailList:getChildByName("Panel_battle") 
  local btnKindAll = self.nodeBattleBar:getChildByName("radio_all")
  local imgKindAll = btnKindAll:getChildByName("Image_selected")
  local lbKindAll = btnKindAll:getChildByName("Text") 

  local btnKindAtk = self.nodeBattleBar:getChildByName("radio_attack")
  local imgKindAtk = btnKindAtk:getChildByName("Image_selected")
  local lbKindAtk = btnKindAtk:getChildByName("Text") 

  local btnKindDefense = self.nodeBattleBar:getChildByName("radio_defense")
  local imgKindDefense = btnKindDefense:getChildByName("Image_selected")
  local lbKindDefense = btnKindDefense:getChildByName("Text") 
  self.imgKind = {imgKindAll, imgKindAtk, imgKindDefense}
  lbTitle:setString(g_tr("mail"))
  lbKindAll:setString(g_tr("allKinds"))
  lbKindAtk:setString(g_tr("attack"))
  lbKindDefense:setString(g_tr("defense"))
  self:regBtnCallback(btnKindAll, handler(self, self.onKindOfAllBatReport))
  self:regBtnCallback(btnKindAtk, handler(self, self.onKindOfAtkBatReport))
  self:regBtnCallback(btnKindDefense, handler(self, self.onKindOfDefenseBatReport))

  lbAll:setString(g_tr("selectAll"))
  self:regBtnCallback(btnClose, handler(self, self.onGoBack))
  self:regBtnCallback(btnSelectAll, handler(self, self.onSelectAll))
  self:regBtnCallback(self.btnMark, handler(self, self.onMarkMails))
  self:regBtnCallback(self.btnDelete, handler(self, self.onDeleteMails))

  self.imgSelectAll:setVisible(self.isSelectedAll)
end 

--邮件种类列表
function MailBaseLayer:showMailTypeList(viewType)
  self.typeArray = {
      {MailHelper.viewType.System, "system"},               
      {MailHelper.viewType.SpyReport, "spyReport"},
      {MailHelper.viewType.BattleReport, "battleReport"}, 
      {MailHelper.viewType.CrossFight, "crossFight"},
      {MailHelper.viewType.CityBattle, "mailCityBattle"},    
      {MailHelper.viewType.CollectionReport, "collectionReport"}, 
      {MailHelper.viewType.MonsterReport, "monsterReport"}, 
      {MailHelper.viewType.Alliance, "alliance"}, 
      {MailHelper.viewType.ChatInfo, "chatInfo"},           
      {MailHelper.viewType.SendMail, "sendMail"}       
    }

  local function onSelectItem(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then 
      g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
      local idx = sender:getCurSelectedIndex()
      self:hightlightMailTypeIdx(idx)
    end 
  end 

  local item = cc.CSLoader:createNode("mail_left_menu.csb") 
  item:getChildByName("ico_tips"):setVisible(false)
  item:setTouchEnabled(true)
  self.typeList:setItemModel(item)
  self.typeList:setScrollBarEnabled(false)
  self.typeList:addEventListener(onSelectItem)

  for k, v in ipairs(self.typeArray) do 
    item:getChildByName("Text"):setString(g_tr(v[2])) 
    self.typeList:pushBackDefaultItem() 
  end 

  local idx = 0 
  if viewType then 
    for k, v in pairs(self.typeArray) do 
      if v[1] == viewType then 
        idx = k - 1 
        break 
      end 
    end 
  end 
  self:hightlightMailTypeIdx(idx) 

  g_MailMode.updateNewMailTips()
end 

function MailBaseLayer:hightlightMailTypeIdx(idx)
  self.typeListIdx = idx 

  local item
  for i=0, #self.typeArray-1 do 
    item = self.typeList:getItem(i)
    if item then 
      item:getChildByName("Image_1"):setVisible(i ~= idx)
      item:getChildByName("Image_2"):setVisible(i == idx)  
    end 
  end 

  self.imgBg:setVisible(false)

  --显示一页数据
  local viewType = self.typeArray[self.typeListIdx+1][1]
  local function showListData()
    local battleKind = 1  --默认全部

    if viewType == MailHelper.viewType.SendMail then 
      self:showMailContent(viewType)

    elseif viewType == MailHelper.viewType.BattleReport then 
      self:onKindOfAllBatReport()

    else 
      self.mailsData = MailHelper:getListDataByMinId(viewType, 0, unReadInfo)
      self:showMailListByType(viewType, self.mailsData, battleKind) 
    end 
  end 
  MailHelper:readyOnePageData(viewType, showListData) 
end 

function MailBaseLayer:reloadMailList(viewType)
  print("reloadMailList:", viewType)
  local vType = self.typeArray[self.typeListIdx+1][1] 
  if vType == viewType then 
    if viewType == MailHelper.viewType.BattleReport then 
      self:onKindOfAllBatReport()
    else 
      self.mailsData = MailHelper:getListDataByMinId(viewType, 0)
      self:showMailListByType(viewType, self.mailsData, 1) 
    end     
  end 
end 

function MailBaseLayer:onTouchMailItem(listItem) 
  print("onTouchMailItem")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local viewType = self.typeArray[self.typeListIdx+1][1]
  self:setMailIsRead(viewType, listItem) 
  self:showMailContent(viewType, listItem)
end 

--邮件列表
function MailBaseLayer:showMailListByType(viewType, mailData, battleKind) 
  print("showMailListByType: viewType, dataLen, battleKind", viewType, #mailData, battleKind)

  self.nodeContent:removeAllChildren()
  self.nodeContent:setVisible(false)
  self.nodeMailList:setVisible(true)

  self.isSelectedAll = false 
  self.imgSelectAll:setVisible(self.isSelectedAll) 

  if viewType == MailHelper.viewType.BattleReport then 
    self.nodeBattleBar:setVisible(true) 
    for k, v in pairs(self.imgKind) do 
      v:setVisible(k == battleKind) 
    end 
  else 
    self.nodeBattleBar:setVisible(false)
  end 

  self.mailListView:removeAllChildren()
  --不使用listview的touch事件, 因为当list item 包含按钮时会同时都响应
  -- self.mailListView:addEventListener(onTouchMailItem) 
  self.mailListView:setScrollBarEnabled(false)
  self.mailListView:setItemsMargin(10)

  --下拉/上拉刷新控件
  if battleKind == 1 then --除了进攻战报和防守战报外, 其他情况均允许添加刷新控件 
    local PullToRefreshControl = require("game.uilayer.common.PullToRefreshControl").new()
    PullToRefreshControl:addListner(self.mailListView, handler(self, self.onPullUpRefresh), handler(self, self.onPullDownRefresh))
    PullToRefreshControl:setTag(Tag.PullControll) 
    self.mailListView:addChild(PullToRefreshControl) 
  end 

  if viewType == MailHelper.viewType.CollectionReport or viewType == MailHelper.viewType.MonsterReport then 
    self.nodeSelectAll:setVisible(false)
    self:setMailIsRead(viewType) --所有邮件设置为已读
    self.imgBg:setVisible(true)
  else 
    self.nodeSelectAll:setVisible(true)
    self.imgBg:setVisible(false)
  end 

  if viewType == MailHelper.viewType.CollectionReport 
    or viewType == MailHelper.viewType.MonsterReport 
    or viewType == MailHelper.viewType.ChatInfo then 
    self.btnMark:setVisible(false)
  else 
    self.btnMark:setVisible(true)
  end 

  --分帧加载列表
  self:frameLoadList(viewType, mailData, 3, true)
end 

--分帧加载列表 preLoadCount:预加载个数
function MailBaseLayer:frameLoadList(viewType, mailData, preLoadCount) 
  self.idx_s = 1 
  self.idx_e = #mailData 

  if self.frameLoadTimer then 
    self:unschedule(self.frameLoadTimer) 
    self.frameLoadTimer = nil  
  end 

  if self.idx_e < self.idx_s then return end 


  local listItem = require("game.uilayer.mail.MailListItem"):create(viewType) 
  listItem:retain()  

  local function insertMailItem(data)
    if nil == data then return end 

    local newItem = listItem:clone() 
    newItem:setTag(Tag.Mail)
    newItem:setDelegate(self)
    newItem:setItemTouchCallback(handler(self, self.onTouchMailItem))
    newItem:setData(data) 
    self.mailListView:pushBackCustomItem(newItem) 
  end 

  local function frameLoadItems()
    insertMailItem(mailData[self.idx_s]) 

    self.idx_s = self.idx_s + 1 
    if self.idx_s > self.idx_e then 
      if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
      end 
      listItem:release()

      --更新收藏/删除图标状态
      self:updateMarkImgState()
      self:updateDeleteImgState() 
    end 
  end 

  if preLoadCount and preLoadCount > 0 then 
    --先加载一部分,后续分帧加载
    local count = math.min(preLoadCount, self.idx_e)
    for i=1, count do 
      insertMailItem(mailData[i], isScrollEnable)
    end 
    
    self.mailListView:jumpToTop() 
    self.idx_s = self.idx_s + count 
  end 

  self.frameLoadTimer = self:schedule(frameLoadItems, 0) 
end 

--显示邮件详情
function MailBaseLayer:showMailContent(viewType, listItem) 
  print("showMailContent")

  self.nodeContent:setVisible(true)
  self.nodeMailList:setVisible(false)
  self.nodeContent:removeAllChildren() 

  local node
  if viewType == MailHelper.viewType.SendMail then 
    node = require("game.uilayer.mail.MailContentWrite").new()

  elseif viewType == MailHelper.viewType.ChatInfo then 
    node = require("game.uilayer.mail.MailContentChat").new(listItem)
  elseif viewType == MailHelper.viewType.Alliance then 
    node = require("game.uilayer.mail.MailContentAlliance").new(listItem)

  elseif viewType == MailHelper.viewType.SpyReport then 
    node = require("game.uilayer.mail.MailContentSpy").new(listItem)

  elseif viewType == MailHelper.viewType.BattleReport 
    or viewType == MailHelper.viewType.CrossFight 
    or viewType == MailHelper.viewType.CityBattle then 
    node = require("game.uilayer.mail.MailContentBattle").new(listItem)

  elseif viewType == MailHelper.viewType.System then 
    node = require("game.uilayer.mail.MailContentSystem").new(listItem) 

  elseif viewType == MailHelper.viewType.CollectionReport then --在MailListItem里动态扩展
  elseif viewType == MailHelper.viewType.MonsterReport then 

  end   

  if node then 
    node:setDelegate(self)
    node:setTag(100)
    self.nodeContent:addChild(node)
  end 
end 


--返回上一界面 
function MailBaseLayer:onGoBack()
  g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH) 

  local viewType = self.typeArray[self.typeListIdx+1][1]
  if viewType ~= MailHelper.viewType.SendMail and self.nodeContent:isVisible() then --从邮件详情返回到邮件列表 
    self.nodeContent:setVisible(false)
    self.nodeMailList:setVisible(true)
    self.nodeContent:removeAllChildren() 
  else 
    self:close()
  end 
end 

function MailBaseLayer:onSelectAll()
  print("onSelectAll")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if nil == self.mailListView then return end 

  self.isSelectedAll = not self.isSelectedAll 
  self.imgSelectAll:setVisible(self.isSelectedAll)

  for k, v in pairs(self.mailListView:getItems()) do 
    if v:getTag() == Tag.Mail then 
      v:setSelected(self.isSelectedAll) 
    end 
  end 
end 

--kindType: 1:全部, 2:进攻 3:防守
function MailBaseLayer:hightlightBatKind(kindType)
  self.batKindType = kindType 

  local viewType = self.typeArray[self.typeListIdx+1][1]
  local totalData = MailHelper:getListDataByMinId(viewType, 0, unReadInfo) 
  self.mailsData = MailHelper:getDataByBatKind(totalData, kindType)

  MailHelper:sortMails(self.mailsData, viewType)
  self:showMailListByType(viewType, self.mailsData, kindType) 
end 

function MailBaseLayer:onKindOfAllBatReport()
  print("onKindOfAllBatReport") 
  -- g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  self:hightlightBatKind(1)
end 

function MailBaseLayer:onKindOfAtkBatReport()
  print("onKindOfAtkBatReport") 
  -- g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  self:hightlightBatKind(2)
end 

function MailBaseLayer:onKindOfDefenseBatReport()
  print("onKindOfDefenseBatReport") 
  -- g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  self:hightlightBatKind(3)
end 

--下拉更新(获取新邮件)
function MailBaseLayer:onPullUpRefresh()
  print("onPullUpRefresh")
  local maxId = 0 
  for k, v in pairs(self.mailsData) do 
    if v.mail.id > maxId then 
      maxId = v.mail.id 
    end 
  end 

  print("onPullUpRefresh: maxId", maxId)
  local viewType = self.typeArray[self.typeListIdx+1][1]
  local tmp = MailHelper:getListDataByMaxId(viewType, maxId, true)
  if #tmp > 0 then 
    self.mailsData = MailHelper:mergeMailData(self.mailsData, tmp)
    MailHelper:sortMails(self.mailsData, viewType)
    
    local battleKind = 1 --显示全部
    self:showMailListByType(viewType, self.mailsData, battleKind)
  end     
end 

--上拉更新(获取旧邮件)
function MailBaseLayer:onPullDownRefresh()
  local minId = 0xFFFFFFFF
  for k, v in pairs(self.mailsData) do 
    if v.mail.id < minId then 
      minId = v.mail.id 
    end 
  end 

  if minId == 0xFFFFFFFF then minId = 0 end 

  print("onPullDownRefresh: minId", minId)
  local viewType = self.typeArray[self.typeListIdx+1][1]
  local tmp = MailHelper:getListDataByMinId(viewType, minId, unReadInfo)
  if #tmp > 0 then 
    local data, diff = MailHelper:mergeMailData(self.mailsData, tmp)
    self.mailsData = data

    if #diff > 0 then 
      self:frameLoadList(viewType, diff, #diff)
    end    
    -- MailHelper:sortMails(self.mailsData, viewType)
    -- local battleKind = 1 --显示全部
    -- self:showMailListByType(viewType, self.mailsData, battleKind)
  end 
end 

function MailBaseLayer:onAddMembers()
  print("onAddMembers") 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
end 

--将勾选的邮件收藏/反收藏
function MailBaseLayer:onMarkMails() 
  print("onMarkMails")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local mailItems = {}
  for k, v in pairs(self.mailListView:getItems()) do 
    if v:getTag() == Tag.Mail and v:isSelected() then 
      table.insert(mailItems, v)
    end 
  end 

  self:doMarkMails(mailItems)
end 

function MailBaseLayer:doMarkMails(mailItems)
  print("doMarkMails")

  local ret = false 

  local mailIds = {}
  for k, v in pairs(mailItems) do 
    table.insert(mailIds, v:getData().mail.id)
  end 

  if #mailIds < 1 then 
    g_airBox.show(g_tr("plsSelectMails"))
    return 
  end 

  local lockFlag = 1 - mailItems[1]:getData().mail.status 

  local function lockResult(result, data)
    print("lockResult:", result)

    if nil == layerObj then return end 

    if result then 
      local data 
      local viewType = self.typeArray[self.typeListIdx+1][1]
      for k, v in pairs(mailItems) do 
        data = v:getData()
        --更新每个item里的收藏图标显示状态
        data.mail.status = lockFlag 
        v:setData(data)

        --更新数据库
        g_MailMode.setMailData(viewType, data.mail)

        --更新公共收藏图标状态
        self:updateMarkImgState()        
      end 
    end 

    ret = result 
  end 

  g_sgHttp.postData("Mail/setLock",{mailIds=mailIds, lock=lockFlag}, lockResult) 

  return ret 
end 

--如果全部都收藏, 则置亮,否则置灰
function MailBaseLayer:updateMarkImgState()

  if not self.btnMark:isVisible() then return end 

  local hasMail = false 
  local allLockState = 0 
  local listItems = self.mailListView:getItems()
  for k, v in pairs(listItems) do 
    if v:getTag() == Tag.Mail then 
      hasMail = true 
      if v:getData().mail.status == 1 then 
        allLockState = 1 
        break 
      end 
    end 
  end 

  self.btnMark:setEnabled(hasMail)
  MailHelper:setImgGray(self.btnMark, allLockState==0)
end 

--如果列表为空则置灰,否则亮
function MailBaseLayer:updateDeleteImgState()
  local hasMail = false 
  for k, v in pairs(self.mailListView:getItems()) do 
    if v:getTag() == Tag.Mail then 
      hasMail = true 
      break 
    end 
  end   

  self.btnDelete:setEnabled(hasMail)
  self.btnMark:setEnabled(hasMail)
  MailHelper:setImgGray(self.btnDelete, not hasMail)
end 

--删除勾选的邮件(收藏的邮件不允许被删除)
function MailBaseLayer:onDeleteMails() 
  print("onDeleteMails")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local mailItems = {}
  for k, v in pairs(self.mailListView:getItems()) do 
    if v:getTag() == Tag.Mail and v:isSelected() then 
      table.insert(mailItems, v)
    end 
  end 

  self:doDeleteMails(mailItems)
end 

function MailBaseLayer:doDeleteMails(mailItems)
  print("---deleteMail---")
  local ret = false 

  local deletedItems = {}
  local deletedIds = {}
  local isLocked = false 
  local canFetched = false 
  local viewType = self.typeArray[self.typeListIdx+1][1]
  local mail
  for k, v in pairs(mailItems) do 
    mail = v:getData().mail
    if mail.status > 0 then 
      isLocked = true 
    end 
    
    --系统邮件中包含未领取的附件则禁止删除 
    if viewType == MailHelper.viewType.System and #mail.item > 0 and mail.read_flag < 2 then 
      canFetched = true 
    else 
      table.insert(deletedIds, v:getData().mail.id)
      table.insert(deletedItems, v)
    end 
  end 

  if #deletedIds < 1 then 
    if canFetched then 
      g_airBox.show(g_tr("plsFetchFirst")) 
    else 
      g_airBox.show(g_tr("plsSelectMails"))
    end 
    return 
  end 

  if isLocked then 
    g_airBox.show(g_tr("cannotDeleteLockedMail"))
    return 
  end 

  local viewType = self.typeArray[self.typeListIdx+1][1]

  local function deleteResult(result, data)
    if nil == layerObj then return end 
    print("deleteResult", result)

    if result then 
      local data 
      for key, item in pairs(deletedItems) do 
        for k, v in pairs(self.mailListView:getItems()) do 
          if v == item then 
            --删除相应数据
            for i, p in pairs(self.mailsData) do 
              if p.mail.id == v:getData().mail.id then 
                table.remove(self.mailsData, i)
                break 
              end 
            end 
            g_MailMode.deleteMailData(viewType, v:getData().mail)
            self.mailListView:removeChild(v)
            break 
          end 
        end   
      end 

      self:updateDeleteImgState()

      --快速更新剩余新邮件红点(不联网请求)
      local index = tostring(viewType) 
      local info = g_MailMode.getUnreadInfo()
      if info and info[index] and info[index].count > 0 then 
        if viewType == MailHelper.viewType.CollectionReport or viewType == MailHelper.viewType.MonsterReport then 
          g_MailMode.reduceUnreadCount(index, info[index].count)
        else 
          g_MailMode.reduceUnreadCount(index, #deletedIds)
        end 
        g_MailMode.updateUnreadUITips()
      end 

      --再次异步请求同步数据
      g_MailMode.updateNewMailTips() 
    end 

    ret = result 
  end 

  --采集报告和怪物报告一并删除, 其他只删除指定邮件
  local vtype = viewType
  if vtype ~= MailHelper.viewType.CollectionReport and vtype ~= MailHelper.viewType.MonsterReport then 
    vtype = 0
  end 
  g_sgHttp.postData("Mail/delete", {mailIds = deletedIds, type = vtype}, deleteResult) 

  --删除邮件后默认回到邮件列表界面
  if ret and self.nodeContent:isVisible() then --从邮件详情返回到邮件列表   
    self:onGoBack()
  end 

  return ret 
end 

--将新邮件标注为已读
--read_flag: 0:未读 1:已读  2:已领取
function MailBaseLayer:setMailIsRead(viewType, mailItem)
  print("setMailIsRead")
  local ids = {}

  if mailItem then 
    local data = mailItem:getData()
    if data.mail.read_flag > 0 then return end 

    data.mail.read_flag = 1
    mailItem:setData(data) 

    g_MailMode.setMailData(viewType, data.mail)
    ids = {data.mail.id}
  end 

  --快速更新剩余新邮件红点(不联网请求)
  local index = tostring(viewType) 
  local info = g_MailMode.getUnreadInfo()
  if info and info[index] and info[index].count > 0 then 
    if viewType == MailHelper.viewType.CollectionReport or viewType == MailHelper.viewType.MonsterReport then 
      g_MailMode.reduceUnreadCount(index, info[index].count)
    else 
      g_MailMode.reduceUnreadCount(index, 1)
    end 
    g_MailMode.updateUnreadUITips(nil, true) --考虑到聊天单个群组可能包含多条新聊天记录,所以暂时先不判断数据差异
  end 


  --联网异步请求更新新邮件红点
  local function setReadResult(result, data)
    print("setReadResult:", result)
    if nil == layerObj then return end 

    --再次异步请求同步数据
    g_MailMode.updateNewMailTips()
  end 

  local vtype = viewType
  if vtype ~= MailHelper.viewType.CollectionReport and vtype ~= MailHelper.viewType.MonsterReport then 
    vtype = 0
  end 
  --异步请求 
  g_sgHttp.postData("Mail/setRead",{mailIds = ids, type = vtype}, setReadResult, true)   
end 

--收到新邮件通知时更新列表显示
function MailBaseLayer:insertNewMail(data)
  print("MailBaseLayer:insertNewMail")

  if nil == data then return end 
  
  local maxId = 0 
  for k, v in pairs(self.mailsData) do 
    if v.mail.id > maxId then 
      maxId = v.mail.id 
    end 
  end 
  maxId = math.min(maxId, data.mail_id)
  print("maxId, data.mail_id", maxId, data.mail_id)

  local viewType = self.typeArray[self.typeListIdx+1][1]
  local mailData = MailHelper:getListDataByMaxId(viewType, math.max(0, maxId-1), false)

  if data.cata_type == viewType then  
    local mail 
    for i=1, #mailData do 
      local found = false 

      --如果不是新的聊天会话,则合并数据
      if mailData[i].mail.type == MailType.ChatSingle or mailData[i].mail.type == MailType.ChatGroup then 
        for k, v in pairs(self.mailListView:getItems()) do 
          if v:getTag() == Tag.Mail then 
            mail = v:getData().mail 
            if mail.type == mailData[i].mail.type and mail.connect_id == mailData[i].mail.connect_id then 
              found = true 

              --本地数据同步
              for m, p in pairs(self.mailsData) do 
                if mail.type == p.mail.type and mail.connect_id == p.mail.connect_id then 
                  self.mailsData[m].mail = mailData[i].mail 
                  break 
                end 
              end 
              --UI更新
              v:setData(mailData[i])

              --如果当前打开聊天界面, 则在后面追加聊天项
              if viewType == MailHelper.viewType.ChatInfo and self.nodeContent:isVisible() then
                local node = self.nodeContent:getChildByTag(100)
                if node and node.appendNewChat then 
                  node:appendNewChat(mailData[i].mail)
                end 
              end 
              break 
            end 
          end 
        end 
      end 

      --追加一条新的项
      if not found then 
        local item_new = require("game.uilayer.mail.MailListItem"):create(viewType) 
        item_new:setTag(Tag.Mail)
        item_new:setDelegate(self)
        item_new:setItemTouchCallback(handler(self, self.onTouchMailItem))
        item_new:setData(mailData[i])
        self.mailListView:insertCustomItem(item_new, 0) --在最前面插入
        --本地数据同步
        table.insert(self.mailsData, 1, mailData[i])
      end 
    end 
    g_MailMode.incressUnreadCount(tostring(viewType), #mailData)
  end 

  --联网请求新邮件个数
  g_MailMode.updateNewMailTips() 
end 

function MailBaseLayer:updateUnreadTips(unReadInfo)
  if nil == layerObj then return end 
  if nil == self.typeArray then return end 

  local pic, _type 
  for i=1, #self.typeArray do 
    item = self.typeList:getItem(i-1)
    if item then 
      _type = self.typeArray[i][1]          
      if _type ~= MailHelper.viewType.SendMail then 
        pic = item:getChildByName("ico_tips")
        pic:setVisible(unReadInfo[tostring(_type)].count > 0)
        pic:getChildByName("Text_num"):setString("" .. unReadInfo[tostring(_type)].count)
      else 
        item:getChildByName("ico_tips"):setVisible(false)
      end 
    end 
  end
end 

return MailBaseLayer 
