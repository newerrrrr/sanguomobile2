
--联盟邮件邀请界面
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailContentAlliance = class("MailContentAlliance",require("game.uilayer.base.BaseLayer"))
local MailType = MailHelper:getMailTypeEnum() 


local layerObj --当前layer对象
function MailContentAlliance:ctor(listItem)
  MailContentAlliance.super.ctor(self)
  layerObj = self 
  self.listItem = listItem 
end 

function MailContentAlliance:onEnter()
  print("MailContentAlliance:onEnter")

  local layer = cc.CSLoader:createNode("mail_alliance_content.csb")
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer) 
  end 
end 

function MailContentAlliance:onExit() 
  print("MailContentAlliance:onExit") 
  layerObj = nil 
end 

function MailContentAlliance:initBinding(rootNode)
  local mail = self.listItem:getData().mail 
  local top_panel = rootNode:getChildByName("top_panel")
  self.btnMark = top_panel:getChildByName("img_label")
  local btnDelete = top_panel:getChildByName("img_delete")
  local btnBack = top_panel:getChildByName("btn_back")
  local lbTime = top_panel:getChildByName("text_time") 
  self:regBtnCallback(self.btnMark, handler(self, self.onMark)) 
  self:regBtnCallback(btnDelete, handler(self, self.onDeleteMail)) 
  self:regBtnCallback(btnBack, handler(self, self.onGoBack))

  local tt = os.date("*t", mail.create_time)
  lbTime:setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))

  MailHelper:setImgGray(self.btnMark, mail.status==0)

  local nodeInvite = rootNode:getChildByName("Panel_invite") 
  local nodeRefuse = rootNode:getChildByName("Panel_refuse") 
  local nodePromote = rootNode:getChildByName("Panel_promote") 
  local nodeGather = rootNode:getChildByName("Panel_gather") 
  local nodeMoveCity = rootNode:getChildByName("Panel_move_city") 
  local nodeCastleAtk = rootNode:getChildByName("Panel_castle_attacked") 
  nodeInvite:setVisible(false)
  nodeRefuse:setVisible(false)
  nodePromote:setVisible(false)
  nodeGather:setVisible(false)
  nodeMoveCity:setVisible(false)
  nodeCastleAtk:setVisible(false)

  local mailtype = self.listItem:getData().mail.type 

  if mailtype == MailType.AllianceInvite then   --邀请
    nodeInvite:setVisible(true)

    --玩家信息
    local lbTitle1 = nodeInvite:getChildByName("label_1") 
    local picSender = nodeInvite:getChildByName("pic_player") 
    local lbSenderInfo1 = nodeInvite:getChildByName("text_player") 
    local lbSenderInfo2 = nodeInvite:getChildByName("text_player_0") 
    lbTitle1:setString(g_tr("invitePlayer"))
    lbSenderInfo1:setString(g_tr("guild%{name}inviteYourJoinIn", {name=mail.data.from_guild.name}))
    lbSenderInfo2:setString(mail.data.from_player.nick)
    MailHelper:loadPlayerIcon(picSender, tonumber(mail.data.from_player.avatar_id))
    nodeInvite:getChildByName("pic_0"):loadTexture(g_resManager.getResPath(1010007))

    --公会信息
    local campName = ""
    if mail.data.from_guild.camp_id and tonumber(mail.data.from_guild.camp_id) > 0 then 
      campName = g_tr("city_battle_short_camp"..mail.data.from_guild.camp_id) 
    end 
    local lbTitle2 = nodeInvite:getChildByName("label_2") 
    local picGuild = nodeInvite:getChildByName("pic_alliance") 
    local lbGuildName = nodeInvite:getChildByName("text_guild_name") 
    local lbGuildLeader = nodeInvite:getChildByName("text_guild_leader") 
    local lbGuildPreCount = nodeInvite:getChildByName("text_guild_count_1") 
    local lbGuildCount = nodeInvite:getChildByName("text_guild_count_2") 
    local lbGuildPrePower = nodeInvite:getChildByName("text_guild_power_1") 
    local lbGuildPower = nodeInvite:getChildByName("text_guild_power_2") 
    lbTitle2:setString(g_tr("guildInfo"))
    lbGuildPreCount:setString(g_tr("membersCount"))
    lbGuildPrePower:setString(g_tr("Power"))
    lbGuildName:setString(mail.data.from_guild.name..campName)
    lbGuildLeader:setString(mail.data.guild_leader.nick)
    lbGuildCount:setString(""..mail.data.from_guild.num) 
    lbGuildPower:setString(""..mail.data.from_guild.guild_power) 
    if mail.data.from_guild.icon_id and mail.data.from_guild.icon_id > 0 then 
      picGuild:loadTexture(g_resManager.getResPath(g_data.alliance_flag[mail.data.from_guild.icon_id].res_flag))
    end 

    self.btnRefuse = nodeInvite:getChildByName("btn_refuse") 
    self.btnSend = nodeInvite:getChildByName("btn_send") 
    self.btnAgree = nodeInvite:getChildByName("btn_agree") 
    self.btnRefuse:getChildByName("Text"):setString(g_tr("mainAllianceRefuse")) 
    self.btnSend:getChildByName("Text"):setString(g_tr("mainAllianceSend")) 
    self.btnAgree:getChildByName("Text"):setString(g_tr("mainAllianceJoint"))

    self:regBtnCallback(self.btnRefuse, handler(self, self.onRefuse)) 
    self:regBtnCallback(self.btnSend, handler(self, self.onSendMail)) 
    self:regBtnCallback(self.btnAgree, handler(self, self.onJoinIn)) 
    
    --如果已经处理过拒绝或同意,则将按钮置灰
    if mail.memo and mail.memo.exec_flag then 
      self.btnRefuse:setEnabled(mail.memo.exec_flag == 0)
      self.btnAgree:setEnabled(mail.memo.exec_flag == 0)
    end 

  elseif mailtype == MailType.AllianceApproval or 
         mailtype == MailType.AllianceQuit or 
         mailtype == MailType.GuildLeaderImpeach or 
         mailtype == MailType.AllianceChangeCamp then --拒绝/被赶出联盟/被弹劾/阵营转移

    nodeRefuse:setVisible(true)
 
    local lbInfo1 = nodeRefuse:getChildByName("Text_from")  
    local lbInfo2 = nodeRefuse:getChildByName("Text_title")  
    if mailtype == MailType.AllianceApproval then 
      lbInfo1:setString(g_tr("guild%{name}refuseNotice", {name=mail.data.from_guild.name}))
      lbInfo2:setString(g_tr("guild%{name1}%{name2}refuseYourApply", {name1=mail.data.from_guild.name, name2=mail.data.from_player.nick}))
    elseif mailtype == MailType.AllianceQuit then 
      lbInfo1:setString(g_tr("guildRemovedNotice", {name=mail.data.from_guild.name}))
      lbInfo2:setString(g_tr("remvovedFromGuild", {guild=mail.data.from_guild.name, name=mail.data.from_player.nick}))
    elseif mailtype == MailType.GuildLeaderImpeach then 
      lbInfo1:setString(g_tr("impeachTitle"))
      lbInfo2:setString(g_tr("leaderImpeach", {name = mail.data.from_nick}))
    elseif mailtype == MailType.AllianceChangeCamp then 
      local campName = "X"
      if mail.data.new_camp_id and mail.data.new_camp_id > 0 then 
        campName = g_tr(g_data.country_camp_list[mail.data.new_camp_id].camp_name)
      end       
      lbInfo1:setString(g_tr("chat_country_changed_title", {country = campName}))
      lbInfo2:setString(g_tr("chat_country_changed", {country = campName}))
    end 

    if mail.data.from_player then 
      MailHelper:loadPlayerIcon(nodeRefuse:getChildByName("Image_1"), tonumber(mail.data.from_player.avatar_id))
    else 
      --显示系统图标
      MailHelper:loadResIcon(nodeRefuse:getChildByName("Image_1"), 1020091)
    end 

  elseif mailtype == MailType.AllianceRankChange then --晋升/降级
    nodePromote:setVisible(true)
    local lbInfo1 = nodePromote:getChildByName("Text_from")  
    local lbInfo2 = nodePromote:getChildByName("Text_title") 
    local picSender = nodePromote:getChildByName("Image_1") 
    local str = mail.data.from_guild.GuildRankName[mail.data.to_rank]
    if str == "" then 
      str = g_tr("allianceRankName"..(mail.data.to_rank or 1))
    end 
    if mail.data.to_rank > mail.data.from_rank then 
      lbInfo1:setString(g_tr("guild%{name}promoteNotice", {name=mail.data.from_guild.name}))
      lbInfo2:setString(g_tr("bePromoted", {name1=mail.data.from_player.nick, name2 = str}))
    else 
      lbInfo1:setString(g_tr("guild%{name}degrateNotice", {name=mail.data.from_guild.name}))
      lbInfo2:setString(g_tr("beDegrated", {name1=mail.data.from_player.nick, name2 = str}))
    end 
    MailHelper:loadPlayerIcon(picSender, tonumber(mail.data.from_player.avatar_id))
    nodePromote:getChildByName("Image_2"):loadTexture(g_resManager.getResPath(1010007))

  elseif mailtype == MailType.AllianceGather then --集结
    nodeGather:setVisible(true) 
    local title = MailHelper:getGatherInfoStr(mail)
    local tt = os.date("*t", mail.data.end_time)
    local strTime = string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec)
    nodeGather:getChildByName("label_1"):setString(g_tr("gatherPlayer"))
    nodeGather:getChildByName("text_player"):setString(title)
    nodeGather:getChildByName("text_gather_time"):setString(g_tr("gatherTime", {time=strTime}))
    nodeGather:getChildByName("label_2"):setString(g_tr("armyProperty"))


    --军团长
    print("mail.data.leader_general_id", mail.data.leader_general_id)
    nodeGather:getChildByName("text_guild_leader"):setString(g_tr("armyHead").."：")
    nodeGather:getChildByName("text_guild_leader_1"):setString(g_tr(g_data.general[mail.data.leader_general_id*100+1].general_name))
    --出征武将
    nodeGather:getChildByName("text_battle_gen"):setString(g_tr("armyEnter").."：")
    nodeGather:getChildByName("text_battle_gen_1"):setString(""..mail.data.general_num)
    --战斗力
    nodeGather:getChildByName("text_power"):setString(g_tr("Power"))
    nodeGather:getChildByName("text_power_1"):setString(""..mail.data.power)
    nodeGather:getChildByName("text_soldier_num"):setString(g_tr("armyNumber").."：")
    nodeGather:getChildByName("text_bu"):setString(g_tr("infantry").."：")    
    nodeGather:getChildByName("text_qi"):setString(g_tr("cavalry").."：")
    nodeGather:getChildByName("text_gong"):setString(g_tr("archer").."：")
    nodeGather:getChildByName("text_che"):setString(g_tr("vehicles").."：")
    nodeGather:getChildByName("text_fuzhong"):setString(g_tr("weight").."：")
    nodeGather:getChildByName("text_bu1"):setString(""..(mail.data.soldier["1"] or 0))
    nodeGather:getChildByName("text_qi1"):setString(""..(mail.data.soldier["2"] or 0))
    nodeGather:getChildByName("text_gong1"):setString(""..(mail.data.soldier["3"] or 0))
    nodeGather:getChildByName("text_che1"):setString(""..(mail.data.soldier["4"] or 0))
    nodeGather:getChildByName("text_fuzhong1"):setString(""..mail.data.weight)
    nodeGather:getChildByName("btn_gather"):getChildByName("Text"):setString(g_tr("gotoGatherPos"))
    self.btnGather = nodeGather:getChildByName("btn_gather")
    if mail.data.end_time > g_clock.getCurServerTime() then 
      self.btnGather:addClickEventListener(handler(self, self.onGather))
    else 
      self.btnGather:setEnabled(false)
    end 
    local pic = nodeGather:getChildByName("pic_player")
    local pic_0 = nodeGather:getChildByName("pic_0")
    MailHelper:loadPlayerIcon(pic, mail.data.from_player_avatar)
    pic_0:loadTexture(g_resManager.getResPath(1010007))

  elseif mailtype == MailType.AllianceMoveInvite then --联盟邀请迁城
    nodeMoveCity:setVisible(true)
    
    local root = rootNode:getChildByName("Panel_move_city")
    MailHelper:loadPlayerIcon(root:getChildByName("Image_1"), tonumber(mail.data.from_player.avatar_id))
    root:getChildByName("Image_2"):loadTexture(g_resManager.getResPath(1010007))
    local str = "("..mail.data.from_player.guild_short_name..")" .. mail.data.from_player.nick
    root:getChildByName("Text_from"):setString(str) 
    local lbStr1 = root:getChildByName("Text_title1")
    local lbStr2 = root:getChildByName("Text_title2")
    lbStr1:setString(g_tr("inviteToMoveCity", {name = mail.data.from_player.nick}))
    lbStr2:setString(g_tr("toPos", {x = mail.data.x, y = mail.data.y}))
    lbStr2:setPositionX(lbStr1:getPositionX() + lbStr1:getContentSize().width)
    
    self.btnAgree = root:getChildByName("Button_1")
    self.btnRefuse = root:getChildByName("Button_2")
    self.btnAgree:getChildByName("Text"):setString(g_tr("agree"))
    self.btnRefuse:getChildByName("Text"):setString(g_tr("refuse"))
    self.btnAgree:addClickEventListener(handler(self, self.onAgreeToMoveCity))
    self.btnRefuse:addClickEventListener(handler(self, self.onRefuseToMoveCity))
    --如果已经处理过拒绝或同意,则将按钮置灰
    if mail.memo and mail.memo.exec_flag then 
      self.btnAgree:setEnabled(mail.memo.exec_flag == 0)
      self.btnRefuse:setEnabled(mail.memo.exec_flag == 0)
    end 

  elseif mailtype == MailType.AtkWarning or mailtype == MailType.DetectedWarning then --联盟堡垒被攻打/侦察预警
    nodeCastleAtk:setVisible(true)
    if mail.data.playerAvatar then 
      MailHelper:loadPlayerIcon(nodeCastleAtk:getChildByName("Image_1"), mail.data.playerAvatar)
    end 
    local guildStr = mail.data.guildName
    if mail.data.guildShort ~= "" then 
      guildStr = "("..mail.data.guildShort..")"..mail.data.guildName
    end 
    nodeCastleAtk:getChildByName("Image_2"):loadTexture(g_resManager.getResPath(1010007))
    nodeCastleAtk:getChildByName("Text_from"):setString(guildStr)
    nodeCastleAtk:getChildByName("Text_title"):setString(mail.data.playerNick)
    local lbTips = nodeCastleAtk:getChildByName("Text_title1")
    local lbPos = nodeCastleAtk:getChildByName("Text_title2") 
    local btn = nodeCastleAtk:getChildByName("Button_1") 
    local strTips = (mailtype == MailType.AtkWarning) and "playerAtkMyCastle" or "playerDetectMyCastle" 
    lbTips:setString(g_tr(strTips, {name = mail.data.playerNick}))
    lbPos:setString("(X:"..mail.data.x.."  ".."Y:"..mail.data.y..")")
    lbPos:setPositionX(lbTips:getPositionX()+lbTips:getContentSize().width+20)

    local function onGotoPos()
      print("onGotoPos")
      require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex({x = mail.data.x, y = mail.data.y})
      self:getDelegate():close()    
    end     
    btn:getChildByName("Text"):setString(g_tr("castleAssist"))
    btn:addClickEventListener(onGotoPos) 
  end 

end 


function MailContentAlliance:onMark() 
  print("onMark") 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  if self:getDelegate() then 
    local ret = self:getDelegate():doMarkMails({self.listItem}) 
    if ret then 
      MailHelper:setImgGray(self.btnMark, self.listItem:getData().mail.status==0) 
    end 
  end 
end 

function MailContentAlliance:onDeleteMail()
  print("onDeleteMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self:getDelegate() then 
    self:getDelegate():doDeleteMails({self.listItem})
  end 
end 

function MailContentAlliance:onGoBack()
  if self:getDelegate() then 
    self:getDelegate():onGoBack()
  end 
end 

--拒绝加入联盟
function MailContentAlliance:onRefuse()
  print("onRefuse")
  g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH) 
  self.btnRefuse:setEnabled(false) 
  self.btnAgree:setEnabled(false) 
  local function refuseResult(result, data)
    print("refuseResult:", result)
    if result then 
      --更新数据
      local data = self.listItem:getData()
      data.mail.memo.exec_flag = 1 
      self.listItem:setData(data)
      
      g_MailMode.setMailData(MailHelper.viewType.Alliance, data.mail)
    end 
  end 
  g_sgHttp.postData("guild/refuseInvite", {mail_id = self.listItem:getData().mail.id}, refuseResult) 
end 

--给全体联盟成员发邮件
function MailContentAlliance:onSendMail() 
  print("onSendMail") 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 

  local recvName = self.listItem:getData().mail.data.from_player.nick 
  local pop = require("game.uilayer.mail.MailContentWritePop").new(false, recvName) 
  g_sceneManager.addNodeForUI(pop) 
end 

--同意加入联盟邀请
function MailContentAlliance:onJoinIn() 
  print("onJoinIn") 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
  self.btnRefuse:setEnabled(false) 
  self.btnAgree:setEnabled(false) 

  if g_AllianceMode.getSelfHaveAlliance() then 
    g_airBox.show(g_tr("GuildForbitToJoinAgain"))
    return 
  end 

  local function agreeResult(result, data)
    print("agreeResult:", result)
    if result then 
      local data = self.listItem:getData()
      data.mail.memo.exec_flag = 1 
      self.listItem:setData(data)

      g_MailMode.setMailData(MailHelper.viewType.Alliance, data.mail)
    end 
  end 
  g_sgHttp.postData("guild/agreeInvite", {mail_id = self.listItem:getData().mail.id}, agreeResult) 
end 

--前往集结
function MailContentAlliance:onGather() 
  print("onGather")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 

  local mail = self.listItem:getData().mail 
  if mail.data.end_time <= g_clock.getCurServerTime() then 
    g_airBox.show(g_tr("gatherTimeExceed"))
    return 
  end 

  -- local function gatherSuccess()
  --   print("gatherSuccess")
  --   g_airBox.show(g_tr("gatherSuccess"))
  --   self.btnGather:setEnabled(false)
  -- end 

  -- local function gotoCollection(ArmyID,PlaySound,isUseMove)
  --   print("gotoCollection", ArmyID)
  --   if nil == ArmyID then return end 

  --   local BattleHallMode = require("game.uilayer.battleHall.BattleHallMode").new()
  --   BattleHallMode:gotoGather(mail.data.x, mail.data.y, mail.data.queue_id, ArmyID, gatherSuccess,isUseMove)
  -- end

  -- local setLayer = require("game.uilayer.battleSet.battleSettingView")
  -- setLayer:createLayer(gotoCollection, {x = mail.data.x, y = mail.data.y},g_Consts.FightType.Expedition) 
  g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleHallView").new())
  self:getDelegate():close() 
end 


function MailContentAlliance:onAgreeToMoveCity() 
  print("onAgreeToMoveCity")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 

  self.btnRefuse:setEnabled(false) 
  self.btnAgree:setEnabled(false) 

  local function agreeResult(result, data)
    print("agreeResult:", result)
    if result then 
      local data = self.listItem:getData()
      data.mail.memo.exec_flag = 1 
      self.listItem:setData(data)

      g_MailMode.setMailData(MailHelper.viewType.Alliance, data.mail)

      --开始跳转
      require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex({x = data.mail.data.x, y = data.mail.data.y})
      self:getDelegate():close() 
    end 
  end 
  g_sgHttp.postData("guild/handleChangeCastleLocation", {mail_id = self.listItem:getData().mail.id}, agreeResult) 
end 

function MailContentAlliance:onRefuseToMoveCity() 
  print("onRefuseToMoveCity")
  g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH) 
  self.btnRefuse:setEnabled(false) 
  self.btnAgree:setEnabled(false) 

  local function refuseResult(result, data)
    print("refuseResult:", result)
    if result then 
      local data = self.listItem:getData()
      data.mail.memo.exec_flag = 1 
      self.listItem:setData(data)

      g_MailMode.setMailData(MailHelper.viewType.Alliance, data.mail)
    end 
  end 
  g_sgHttp.postData("guild/handleChangeCastleLocation", {mail_id = self.listItem:getData().mail.id}, refuseResult) 
end 

return MailContentAlliance 
