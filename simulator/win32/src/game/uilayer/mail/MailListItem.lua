
--邮件列表项
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailListItem = class("MailListItem", function() return ccui.Widget:create() end )
local MailType = MailHelper:getMailTypeEnum() 
local BattleSubType = MailHelper:getBattleSubTypeEnum() 
local SpyType = MailHelper:getSpyTypeEnum() 

function MailListItem:ctor()
  self:setTouchEnabled(true)
  self:setFocusEnabled(false)
end 

function MailListItem:create(viewType)
  self.viewType = viewType 

  local csbName
  if self.viewType == MailHelper.viewType.BattleReport 
    or self.viewType == MailHelper.viewType.CrossFight 
    or self.viewType == MailHelper.viewType.CityBattle then 
    csbName = "mail_battle_list_item.csb"
  elseif self.viewType == MailHelper.viewType.CollectionReport then --在函数 setData()里动态扩展
  elseif self.viewType == MailHelper.viewType.MonsterReport then 
  else 
    csbName = "mail_list_item.csb"
  end 

  self.widget =nil 
  if csbName then 
    self.widget = cc.CSLoader:createNode(csbName)
  end 
  
  local item = MailListItem.new()
  item:initBinding(self.widget)
  
  return item 
end 

function MailListItem:clone()
  local item = MailListItem.new()
  if self.widget then 
    local widget = self.widget:clone()
    item:initBinding(widget)
  end 

  return item 
end 

function MailListItem:initBinding(widget)
  if nil == widget then return end 
  
  self:setContentSize(widget:getContentSize())
  self:addChild(widget) 

  if self.viewType == MailHelper.viewType.BattleReport 
    or self.viewType == MailHelper.viewType.CrossFight 
    or self.viewType == MailHelper.viewType.CityBattle then 
    local bg = widget:getChildByName("bg")
    local btnSelect = bg:getChildByName("Image_select") 
    self.lbAtkSide = bg:getChildByName("Text_atk") 

    local btnClick = bg:getChildByName("Panel_click") --列表项点击选中响应区域
    self.lbBatPos = btnClick:getChildByName("Text_position") 
    self.nodeDetail = btnClick:getChildByName("Panel_1")
    self.lbAllKilled = btnClick:getChildByName("Text_allKilled")
    
    --相同变量名      
    self.lbTime = self.nodeDetail:getChildByName("Text_time") 
    self.imgSelect = bg:getChildByName("Image_selected") 
    self.imgTip = bg:getChildByName("ico_tips") 
    self.imgMark = bg:getChildByName("Image_xingxing") 

    --玩家自己
    local player_left = self.nodeDetail:getChildByName("player_left")
    self.imgBatMyHeader = player_left:getChildByName("pic") 
    local pic_0 = player_left:getChildByName("pic_0") 
    self.lbBatMyName = player_left:getChildByName("name") 
    local lbBatPrePower1 = player_left:getChildByName("label_1") 
    self.lbBatPower1 = player_left:getChildByName("num_1") 
    local lbBatPreSoldier1 = player_left:getChildByName("label_2") 
    self.lbBatSoldier1 = player_left:getChildByName("num_2") 
    pic_0:loadTexture(g_resManager.getResPath(1010007))

    --对方
    self.nodeAnemy = self.nodeDetail:getChildByName("player_right")
    local pic_1 = self.nodeAnemy:getChildByName("pic_0")
    self.imgBatWin = self.nodeDetail:getChildByName("pic_win") 
    self.imgBatFail = self.nodeDetail:getChildByName("pic_lose") 
    self.lbKing = self.nodeDetail:getChildByName("Text_king") 
    pic_1:loadTexture(g_resManager.getResPath(1010007))

    lbBatPrePower1:setString(g_tr("Power"))
    lbBatPreSoldier1:setString(g_tr("soldierCounts")..":")
    self.lbAllKilled:setString(g_tr("allMyArmyKilled"))
    self.lbKing:setString(g_tr("kingBattle"))
    btnSelect:addTouchEventListener(handler(self, self.onSelect))  
    btnClick:addClickEventListener(handler(self, self.onSelectItem)) 
    self.lbBatPos:addClickEventListener(handler(self, self.onGotoPos))  --位置超链接

  elseif self.viewType == MailHelper.viewType.CollectionReport then 
  elseif self.viewType == MailHelper.viewType.MonsterReport then 

  else --其他类型邮件
    local btnSelect = widget:getChildByName("img_select_bg") 
    self.imgSelect = widget:getChildByName("img_select") 

    local btnClick = widget:getChildByName("Panel_click") --列表项点击选中响应区域
    self.imgPortrait = btnClick:getChildByName("pic") 
    self.imgTip = btnClick:getChildByName("ico_tips") 
    self.lbSender = btnClick:getChildByName("Text_from") 
    self.lbTitle = btnClick:getChildByName("Text_title") 

    self.lbTime = widget:getChildByName("Text_time") 
    self.imgGift = widget:getChildByName("img_gift") 
    self.imgMark = widget:getChildByName("img_label") 
    local btnDelete = widget:getChildByName("img_delete") 

    btnClick:addClickEventListener(handler(self, self.onSelectItem)) 
    btnSelect:addTouchEventListener(handler(self, self.onSelect))  

    btnDelete:addClickEventListener(handler(self, self.onDelete))     
  end 


  if self.imgMark then 
    self.imgMark:setVisible(self.viewType ~= MailHelper.viewType.ChatInfo) 
    if self.imgMark:isVisible() then 
      self.imgMark:addClickEventListener(handler(self, self.onMark)) 
    end 
  end 

  --默认关闭
  self:setSelected(false) 
end 

function MailListItem:onSelectItem() 
  print("onSelectItem")
  if self:getItemTouchCallback() then 
    self:getItemTouchCallback()(self) 
  end 
end 

function MailListItem:setItemTouchCallback(callback) 
  self.itemTouchCallback = callback 
end 

function MailListItem:getItemTouchCallback() 
  return self.itemTouchCallback 
end 

--data的格式 data = {mail, chatLog = {}, groupMembers={}}
function MailListItem:setData(data)
  self._data = data 

  --初始化UI显示
  if data then 
    local mail = data.mail 

    --发件人, 标题
    if self.viewType == MailHelper.viewType.ChatInfo then  --聊天邮件

      local fontSize = self.lbTitle:getFontSize()
      local strWidthMax = self.lbTitle:getContentSize().width - fontSize*1.6          
      --聊天不显示标题,而显示发件人,其他显示标题
      local content = MailHelper:getTrimedTitle(tostring(mail.msg), fontSize, strWidthMax, "...")
      self.lbTitle:setString(content)
    
      local fromName = tostring(mail.from_player_name)
      if fromName == "" then --系统邮件
        fromName = g_tr("systemMail")
      else 
        fromName = g_tr("mailSender")..fromName
      end 

      if mail.connect_nick and mail.connect_nick ~= "" then 
        if mail.type == 2 then 
          fromName = g_tr("mailChatMember", {name = mail.connect_nick})
        elseif mail.type == 3 then 
          fromName = fromName .. "\n" .. g_tr("mailChatCreater", {name = mail.connect_nick})
        end 
      end 
      self.lbSender:setString(fromName) 
      if mail.from_player_avatar then 
        local id = tonumber(mail.from_player_avatar)
        if nil == id or id == 0 then 
          id = 1020143 
        end         
        MailHelper:loadPlayerIcon(self.imgPortrait, id)
      end 

    elseif self.viewType == MailHelper.viewType.Alliance then --联盟邮件
      local senderName = ""
      local titleStr = ""
      local avatarId 
      if mail.type == MailType.AllianceInvite then --邀请
        senderName = g_tr("mailSender") .. mail.data.from_player.nick 
        titleStr = g_tr("guild%{name}inviteYourJoinIn", {name=mail.data.from_guild.name})
        avatarId = mail.data.from_player.avatar_id

      elseif mail.type == MailType.AllianceApproval then --拒绝
        senderName = g_tr("mailSender") .. mail.data.from_player.nick 
        titleStr = g_tr("guild%{name}refuseNotice", {name=mail.data.from_guild.name})
        avatarId = mail.data.from_player.avatar_id

      elseif mail.type == MailType.AllianceRankChange then --晋升/降级
        senderName = g_tr("mailSender") .. mail.data.from_player.nick 
        local str = (mail.data.to_rank > mail.data.from_rank) and "guild%{name}promoteNotice" or "guild%{name}degrateNotice"        
        titleStr = g_tr(str, {name=mail.data.from_guild.name})
        avatarId = mail.data.from_player.avatar_id

      elseif mail.type == MailType.AllianceGather then --集结
        senderName = g_tr("%{name}InviteGather", {name=mail.data.from_player_name})
        -- titleStr = g_tr("%{name}InviteGatherAt", {name=mail.data.from_player_name, x=mail.data.x, y=mail.data.y})
        titleStr = MailHelper:getGatherInfoStr(mail)
        avatarId = mail.data.from_player_avatar

      elseif mail.type == MailType.AllianceQuit then --被剔除联盟
        senderName = g_tr("mailSender") .. mail.data.from_player.nick 
        titleStr = g_tr("remvovedFromGuild", {guild=mail.data.from_guild.name, name=mail.data.from_player.nick})
        avatarId = mail.data.from_player.avatar_id

      elseif mail.type == MailType.AllianceMoveInvite then --邀请迁城
        senderName = g_tr("mailSender") .. mail.data.from_player.nick 
        titleStr = g_tr("inviteToMoveCity", {name = mail.data.from_player.nick})..g_tr("toPos", {x = mail.data.x, y = mail.data.y})
        avatarId = mail.data.from_player.avatar_id

      elseif mail.type == MailType.AtkWarning then --联盟堡垒被攻打预警
        senderName = g_tr("mailSender") .. g_tr("system") 
        titleStr =  g_tr("playerAtkMyCastle", {name = mail.data.playerNick}) 
        avatarId = mail.data.playerAvatar 

      elseif mail.type == MailType.DetectedWarning then --联盟堡垒被侦察预警
        senderName = g_tr("mailSender") .. g_tr("system") 
        titleStr =  g_tr("playerDetectMyCastle", {name = mail.data.playerNick}) 
        avatarId = mail.data.playerAvatar  

      elseif mail.type == MailType.GuildLeaderImpeach then --盟主弹劾
        senderName = g_tr("impeachTitle")
        titleStr = g_tr("leaderImpeach", {name = mail.data.from_nick}) 
        MailHelper:loadResIcon(self.imgPortrait, 1020091) --系统图标

      elseif mail.type == MailType.AllianceChangeCamp then --阵营转移
        local campName = "X"
        if mail.data.new_camp_id and mail.data.new_camp_id > 0 then 
          campName = g_tr(g_data.country_camp_list[mail.data.new_camp_id].camp_name)

          local id = g_data.country_camp_list[mail.data.new_camp_id].camp_pic 
          self.imgPortrait:loadTexture(g_resManager.getResPath(id))
          -- MailHelper:loadResIcon(self.imgPortrait, id) --阵营旗子
        end     
        senderName = g_tr("chat_country_changed_title", {country = campName})
        titleStr = g_tr("chat_country_changed", {country = campName})

      end 

      self.lbSender:setString(senderName) 
      self.lbTitle:setString(titleStr) 
      if avatarId then 
        MailHelper:loadPlayerIcon(self.imgPortrait, tonumber(avatarId))
      end 

    elseif self.viewType == MailHelper.viewType.SpyReport then --侦查邮件
      if mail.type == MailType.Detected then 
        if mail.data.type == SpyType.Normal then --主城
          self.lbSender:setString(g_tr("castleWasDetected"))
          self.lbTitle:setString(g_tr("%{name}SpyYourCastle", {name = mail.data.target_player.nick}))

        elseif mail.data.type == SpyType.Resource then --资源点
          self.lbSender:setString(g_tr("resourceWasDetected"))
          self.lbTitle:setString(g_tr("%{name}SpyYourResource", {name = mail.data.target_player.nick}))  

        elseif mail.data.type == SpyType.JuDian then --据点
          self.lbSender:setString(g_tr("juDidanWasDetected"))
          self.lbTitle:setString(g_tr("%{name}SpyYourJudian", {name = mail.data.target_player.nick}))           
        end 
        MailHelper:loadPlayerIcon(self.imgPortrait, mail.data.target_player.avatar_id)
      else 

        self.lbSender:setString(g_tr("detectSuccess")) 
        if mail.data.type == SpyType.Normal then --侦查主城
          self.lbTitle:setString(g_tr("detect%{name}Info", {name = mail.data.target_player.nick}))
          MailHelper:loadPlayerIcon(self.imgPortrait, mail.data.target_player.avatar_id)

        elseif mail.data.type == SpyType.Resource then --侦查资源点
          self.lbTitle:setString("")
          if mail.data.map_element_id then 
            local item = g_data.map_element[mail.data.map_element_id]
            if item then 
              self.lbTitle:setString(g_tr("detect%{name}Info", {name = g_tr(item.name)}))
              MailHelper:loadResIcon(self.imgPortrait, item.img_mail)
            end 
          end 

        elseif mail.data.type == SpyType.Castle then --侦查联盟堡垒
          local str = ""
          if mail.data.map_element_id and mail.data.map_element_id > 0 then 
            if g_data.map_element[mail.data.map_element_id] then
              str = g_tr(g_data.map_element[mail.data.map_element_id].name)
              MailHelper:loadResIcon(self.imgPortrait, g_data.map_element[mail.data.map_element_id].img_mail)
            end 
          end 
          self.lbTitle:setString(g_tr("resDectetInfo", {name = str,x = mail.data.x, y = mail.data.y}))
        
        elseif mail.data.type == SpyType.KingFight then --侦查国王战
          local str = ""
          if mail.data.map_element_id and mail.data.map_element_id > 0 then 
            if g_data.map_element[mail.data.map_element_id] then
              str = g_tr(g_data.map_element[mail.data.map_element_id].name)
              MailHelper:loadResIcon(self.imgPortrait, g_data.map_element[mail.data.map_element_id].img_mail)
            end 
          end           
          self.lbTitle:setString(g_tr("resDectetInfo", {name = str,x = mail.data.x, y = mail.data.y})) 

        elseif mail.data.type == SpyType.JuDian then --侦查据点
          self.lbTitle:setString("")
          if mail.data.map_element_id then 
            local item = g_data.map_element[mail.data.map_element_id]
            if item then 
              self.lbTitle:setString(g_tr("detect%{name}Info", {name = g_tr(item.name)}))
              MailHelper:loadResIcon(self.imgPortrait, item.img_mail)
            end 
          end           
        end 
      end 
      
    elseif self.viewType == MailHelper.viewType.BattleReport 
        or self.viewType == MailHelper.viewType.CrossFight 
        or self.viewType == MailHelper.viewType.CityBattle then --战斗邮件
      self.lbBatPos:setString(g_tr("battlePos", {X = mail.data.x, Y = mail.data.y}))

      print("mail.data.all_dead", mail.data.all_dead)
      if mail.data.all_dead then --全军覆没
        self.lbAtkSide:setString(g_tr("attack"))
        self.nodeDetail:setVisible(false)
        self.lbAllKilled:setVisible(true) 
      else 
        self.nodeDetail:setVisible(true)
        self.lbAllKilled:setVisible(false)

        self.lbKing:setVisible(false)

        if mail.data.player1 then 
          if MailHelper:isKindOfAtk(mail.type) then --我是进攻方
            self.lbAtkSide:setString(g_tr("attack"))
          else 
            self.lbAtkSide:setString(g_tr("defense"))
          end 
          local avatar_1 = mail.data.player1.avatar and tonumber(mail.data.player1.avatar) or nil 

          print("mail.data.player1.avatar",mail.id, avatar_1)
          if self.imgBatMyHeader and avatar_1 and avatar_1 > 0 then 
            if mail.data.type == BattleSubType.Castle and not MailHelper:isKindOfAtk(mail.type) then --攻打联盟堡垒时, 我是防守方则显示堡垒图片
              MailHelper:loadResIcon(self.imgBatMyHeader, g_data.map_element[101].img_mail)
            else
              if g_data.res_head[avatar_1] then 
                MailHelper:loadPlayerIcon(self.imgBatMyHeader, avatar_1)
              else 
                print("invalid player avartar !!!!!!!!")
              end 
            end 
          end 
          self.lbBatMyName:setString(mail.data.player1.nick)
          self.lbBatPower1:setString(""..math.ceil(mail.data.player1.power/10000))
          self.lbBatSoldier1:setString(""..mail.data.player1.soldier_num)
        end

        if mail.data.player2 then 
          local player2 = self.nodeAnemy:getChildByName("Panel_player") 
          local alliance = self.nodeAnemy:getChildByName("Panel_alliance") 
          player2:getChildByName("label_1"):setString(g_tr("Power"))
          player2:getChildByName("label_2"):setString(g_tr("soldierCounts")..":")
          player2:setVisible(false) 
          alliance:setVisible(false)

          local pic = self.nodeAnemy:getChildByName("pic")
          local avatar_2 = mail.data.player2.avatar and tonumber(mail.data.player2.avatar) or nil 

          if mail.data.type == BattleSubType.Normal or mail.data.type == BattleSubType.Resource --攻城/攻打资源点 
            or mail.data.type == BattleSubType.AtkCity or mail.data.type == BattleSubType.AtkArmy then --跨服战攻击城门/投石车(人)
            player2:setVisible(true)            
            MailHelper:loadPlayerIcon(pic, avatar_2)
            player2:getChildByName("name"):setString(mail.data.player2.nick)            
            player2:getChildByName("num_1"):setString(""..math.ceil(mail.data.player2.power/10000))            
            player2:getChildByName("num_2"):setString(""..mail.data.player2.soldier_num)
            
          elseif mail.data.type == BattleSubType.Castle then --攻打联盟堡垒            
            alliance:setVisible(true) 
            alliance:getChildByName("name"):setString(mail.data.player2.nick or "") 
            if MailHelper:isKindOfAtk(mail.type) then --攻打联盟堡垒时, 被攻打的则显示堡垒图片
              MailHelper:loadResIcon(pic, g_data.map_element[101].img_mail)
            else 
              MailHelper:loadPlayerIcon(pic, avatar_2)
            end 

          elseif mail.data.type == BattleSubType.King_PVP or mail.data.type == BattleSubType.King_PVE or mail.data.type == BattleSubType.King_NPC then
            self.lbKing:setVisible(true) 
            player2:setVisible(true) 

            if avatar_2 and avatar_2 > 0 then
              if mail.data.type == BattleSubType.King_PVP and g_data.res_head[avatar_2] then 
                MailHelper:loadPlayerIcon(pic, avatar_2)

              elseif g_data.map_element[avatar_2] then  
                MailHelper:loadResIcon(pic, g_data.map_element[avatar_2].img_mail)

              elseif g_data.npc[avatar_2] then
                MailHelper:loadResIcon(pic, g_data.npc[avatar_2].img_mail)
              end 
            else 
              print("invalid avatar !!!!", avatar_2)
            end             
            player2:getChildByName("name"):setString(mail.data.player2.nick or "")
            player2:getChildByName("num_1"):setString(""..math.ceil(mail.data.player2.power/10000))            
            player2:getChildByName("num_2"):setString(""..mail.data.player2.soldier_num)

            --国王战的怪物不显示战斗力
            if mail.data.type == BattleSubType.King_PVE or mail.data.type == BattleSubType.King_NPC then 
              player2:getChildByName("label_1"):setVisible(false) 
              player2:getChildByName("num_1"):setVisible(false)
            end

          elseif mail.data.type == BattleSubType.AtkDoor or mail.data.type == BattleSubType.AtkBase then --跨服战、城战攻击城门/大本营
            if g_data.map_element[avatar_2] then  
              MailHelper:loadResIcon(pic, g_data.map_element[avatar_2].img_mail)

              player2:setVisible(true) 
              
              if mail.data.type == BattleSubType.AtkDoor then 
                if mail.data.player2.guild_name then --跨服战
                  player2:getChildByName("name"):setString(g_tr("crossCityDoor", {name = mail.data.player2.guild_name}))  
                else --城战,城门可能无归属
                  if mail.data.player2.camp_id and tonumber(mail.data.player2.camp_id) > 0 then 
                    player2:getChildByName("name"):setString(g_tr("crossCityDoor", {name = g_tr("city_battle_camp"..mail.data.player2.camp_id)}))              
                  else 
                    player2:getChildByName("name"):setString(g_tr("guild_war_build_desc7")) --只显示城门
                  end 
                end 
              else 
                player2:getChildByName("name"):setString(g_tr("crossCityBase", {name = mail.data.player2.guild_name})) 
              end 
              player2:getChildByName("label_1"):setVisible(false)
              player2:getChildByName("num_1"):setVisible(false)
              player2:getChildByName("label_2"):setString(g_tr("life").."：")
              player2:getChildByName("num_2"):setString(""..(mail.data.player2.newDurability or 0))              
            end 
          end 
        end 
        
        if MailHelper:isWin(mail) then 
          self.imgBatWin:setVisible(true)
          self.imgBatFail:setVisible(false)
        else 
          self.imgBatWin:setVisible(false)
          self.imgBatFail:setVisible(true)
        end 
      end 

    elseif self.viewType == MailHelper.viewType.CollectionReport then --采集报告
      self:initCollectionReport(mail)

    elseif self.viewType == MailHelper.viewType.MonsterReport then --怪物报告
      self:initMonsterReport(mail)

    else --系统邮件
      self.lbSender:setString(g_tr("mailSender") .. g_tr("systemMail")) 
      MailHelper:loadResIcon(self.imgPortrait, 1020091)

      if mail.type == MailType.KingWarGift then --国王礼包 
        self.lbTitle:setString(g_tr("kingGift")) 

      elseif mail.type == MailType.PowerLostCompensation then --战力损失补偿
        local str = g_tr("powerLostCompensition")
        if mail.data.text then 
          str = g_tr(tonumber(mail.data.text))
        end 
        self.lbTitle:setString(str) 

      elseif mail.type == MailType.LimitRankGift then --限时比赛排名礼包
        self.lbTitle:setString(g_tr("limitRankGift")) 

      elseif mail.type == MailType.LimitTotalRankGift then --限时比赛总排名礼包
        self.lbTitle:setString(g_tr("limitTotalRankGift")) 

      elseif mail.type == MailType.GuildMissionRankGift then --联盟限时比赛总排名礼包
        self.lbTitle:setString(g_tr("guildMissionRankGift")) 

      elseif mail.type == MailType.GuildMissionScoreGift then --联盟限时比赛积分礼包
        self.lbTitle:setString(g_tr("guildMissionScoreGift")) 

      elseif mail.type == MailType.LimitScoreGift then --限时比赛阶段礼包
        self.lbTitle:setString(g_tr("limitScoreGift")) 

      elseif mail.type == MailType.LimitRankKingFight then --国王战排名礼包
        self.lbTitle:setString(g_tr("kingFightRankGift")) 

      elseif mail.type == MailType.GuildPayGift then --联盟充值礼包
        self.lbTitle:setString(g_tr("guildPayGift")) 

      elseif mail.type == MailType.FirstJointGuild then --第一次加入联盟
        self.lbTitle:setString(g_tr("firstJoinGuildGift")) 

      elseif mail.type == MailType.BigDeal then --大额充值
        self.lbTitle:setString(g_tr("largeRechargeTitle")) 

      elseif mail.type == MailType.HuangJinGift then --黄巾起义波次奖励
        self.lbTitle:setString(g_tr("huangjinGiftTitle")) 

      elseif mail.type == MailType.KingAppoint then --皇帝任命
        local str = ""
        if mail.data.target_player_job and g_data.king_appoint[mail.data.target_player_job] then 
          if g_data.king_appoint[mail.data.target_player_job].type == 1 then --升职
            str = g_tr("promoteNotice")
          else 
            str = g_tr("demotionNotice")
          end  
        end 
        self.lbTitle:setString(str)

      elseif mail.type == MailType.BecomeKing then --皇帝登基
        self.lbTitle:setString(g_tr("becomeKingNotice")) 

      elseif mail.type == MailType.PlayerCreateAcountTip then --玩家创建账号tips
        if mail.data.mail_tips_id and g_data.email_tips[tonumber(mail.data.mail_tips_id)] then 
          self.lbTitle:setString(g_tr(g_data.email_tips[tonumber(mail.data.mail_tips_id)].title)) 
        else 
          self.lbTitle:setString(g_tr("newPlayerTips")) 
        end 

      elseif mail.type == MailType.GodGeneralExpItem then --神武将经验道具
        self.lbTitle:setString(g_tr("godGenExpItemTitle")) 

      elseif mail.type == MailType.ActivityWillOpen then --即将开启的活动
        if mail.data.activity_id == 1002 then --
          self.lbTitle:setString(g_tr("limitActWillOpen")) 
        elseif mail.data.activity_id == 1003 then
          self.lbTitle:setString(g_tr("allianceActWillOpen")) 
        end 
      
      elseif mail.type == MailType.GuildMissionGift then --联盟活动礼包
        self.lbTitle:setString(g_tr("allianceMissionGiftTitle"))

      elseif mail.type == MailType.WuDouRoundGift then --武斗赛季奖励
        self.lbTitle:setString(g_tr("wudouRoundGift"))

      elseif mail.type == MailType.CrossRewardJoined then --跨服战参与奖励(包含胜败)
        if mail.data.is_win and mail.data.is_win > 0 then 
          self.lbTitle:setString(g_tr("crossJoinedAndWinTitle")) 
        else 
          self.lbTitle:setString(g_tr("crossJoinedAndLostTitle")) 
        end 

      elseif mail.type == MailType.CrossRewardNotJoined then --跨服战未参与(包含胜败)
        if mail.data.is_win and mail.data.is_win > 0 then 
          self.lbTitle:setString(g_tr("crossNotJoinedAndWinTitle")) 
        else 
          self.lbTitle:setString(g_tr("crossNotJoinedAndLostTitle")) 
        end 

      elseif mail.type == MailType.CrossUnselected then --跨服战落选
        self.lbTitle:setString(g_tr("crossUnselectedNoticeTitle")) 

      elseif mail.type == MailType.CrossLeaderJoinNotice then --盟主/副盟主参加跨服战通知
        self.lbTitle:setString(g_tr("crossLeaderJoinNoticeTitle")) 
        
      elseif mail.type == MailType.TestPayReturn then --封测充值返利3倍元宝
        self.lbTitle:setString(g_tr("testPayReturnTitle")) 
      
      elseif mail.type == MailType.CityBattleAwardYuLinJun then --城战羽林军奖励 
        local campName = "X"
        if mail.data.camp_id then 
          campName = g_tr(g_data.country_camp_list[mail.data.camp_id].camp_name)
        end 
        self.lbTitle:setString(g_tr("mailYinlinjunAwardTitle", {country = campName})) 
        
      elseif mail.type == MailType.CityBattleAward then --城战奖励 
        local strCity = ""
        if mail.data.city_id then 
          strCity = g_tr(g_data.country_city_map[tonumber(mail.data.city_id)].ctiy_name)
        end 
        local str = ""
        if mail.data.in_flag == 1 then --城门
          str = g_tr("mailCityDoorBattleAwardTitle", {name = strCity})
        else 
          str = g_tr("mailCityBattleAwardTitle", {name = strCity})
        end 
        self.lbTitle:setString(str)

      elseif mail.type == MailType.CityBattleTokenAward then --城战报名奖励
        self.lbTitle:setString(g_tr("mailCityBattleTokenTitle"))

      elseif mail.type == MailType.CityBattleTaskAward then --城战联盟任务奖励
        self.lbTitle:setString(g_tr("mailCityBattleTaskAwardTitle"))

      elseif mail.type == MailType.CityBattleSignFail then --普通报名落选
        local strCity = ""
        if mail.data.city_id then 
          strCity = g_tr(g_data.country_city_map[tonumber(mail.data.city_id)].ctiy_name)
        end         
        self.lbTitle:setString(g_tr("mailCityBattleSignFailTitle", {cityName=strCity}))
        
      elseif mail.type == MailType.CityBattleCampWiner then --赛季优胜奖励
        self.lbTitle:setString(g_tr("mailCityBattleCampWinerTitle"))

      elseif mail.type == MailType.ArcheryLocalRankAward then --射箭本服排名奖励
        self.lbTitle:setString(g_tr("mailArcheryLocalRankAwardTitle"))

      elseif mail.type == MailType.ArcheryGlobalRakAward then --射箭跨服排名奖励
        self.lbTitle:setString(g_tr("mailArcheryGlobalRankAwardTitle"))
        
      else 
        local fontSize = self.lbTitle:getFontSize()
        local strWidthMax = self.lbTitle:getContentSize().width - fontSize*1.6        
        local content = MailHelper:getTrimedTitle(tostring(mail.msg), fontSize, strWidthMax, "...") 
        self.lbTitle:setString(content)  
      end 
    end 

    if self.lbTime then 
      local tt = os.date("*t", mail.create_time)
      self.lbTime:setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min,tt.sec))
    end 
    if self.imgTip then 
      self.imgTip:setVisible(mail.read_flag == 0) --新邮件tips
    end 
    if self.imgGift then 
      self.imgGift:setVisible(mail.item and #mail.item > 0 and mail.read_flag < 2) --附件 mail.read_flag==2表示已领取
    end 

    if self.imgMark then 
      MailHelper:setImgGray(self.imgMark, mail.status==0)
    end 
  end 
end 

function MailListItem:getData()
  return self._data 
end 

function MailListItem:setSelected(isSelected) 
  self.selectedState = isSelected
  if self.imgSelect then 
    self.imgSelect:setVisible(isSelected)
  end 
end 

function MailListItem:isSelected()
  return self.selectedState 
end 

--选中/取消当前邮件
function MailListItem:onSelect(sender,eventType) 
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  if eventType == ccui.TouchEventType.ended then  
    print("onSelect")
    self:setSelected(not self.selectedState)
  end 
end 

--收藏/取消收藏
function MailListItem:onMark() 
  print("onMark")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self:getDelegate() then 
    local ret = self:getDelegate():doMarkMails({self})
    if ret and self.imgMark then 
      MailHelper:setImgGray(self.imgMark, self._data.mail.status==0)
    end 
  end   
end 

--删除
function MailListItem:onDelete(sender,eventType) 
  print("onDelete")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self:getDelegate() then 
    self:getDelegate():doDeleteMails({self})
  end 
end 

function MailListItem:onGotoPos() 
  print("onGotoPos")
  require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex({x = self._data.mail.data.x, y = self._data.mail.data.y})
  self:getDelegate():close()   
end 


function MailListItem:setDelegate(delegate)
  self._delegate = delegate
end 

function MailListItem:getDelegate()
  return self._delegate
end 


function MailListItem:initCollectionReport(mail)
  self:setSelected(true) --默认全选(所有采集报告当做一封邮件处理)

  local pos_y = 0 
  local node = ccui.Widget:create()

  --标题 
  local widget_title = cc.CSLoader:createNode("mail_collection_content_1.csb") 
  local root = widget_title:getChildByName("Panel_1") 
  local resName = root:getChildByName("text_01")
  print("=====mail.data.element_id", mail.data.element_id)
  if g_data.map_element[mail.data.element_id] then 
    resName:setString(g_tr(g_data.map_element[mail.data.element_id].name))
  end 
  local lbPos = root:getChildByName("text_01_1")
  lbPos:setString("(X:"..mail.data.x.."  ".."Y:"..mail.data.y..")")
  lbPos:addClickEventListener(handler(self, self.onGotoPos))
  lbPos:setPositionX(resName:getPositionX()+resName:getContentSize().width+20)
  --draw line 
  lbPos:removeAllChildren()
  local drawNode = cc.DrawNode:create()
  drawNode:setAnchorPoint(cc.p(0, 0.5))
  drawNode:drawLine(cc.p(0, 0), cc.p(lbPos:getContentSize().width+5, 0), cc.c4f(0.1, 0.6, 0.8, 1))
  drawNode:setPosition(cc.p(0, 0))
  lbPos:addChild(drawNode)

  self.lbTime = root:getChildByName("text_01_0")
  
  pos_y = pos_y - widget_title:getContentSize().height 
  widget_title:setPosition(cc.p(0, pos_y))
  node:addChild(widget_title)

  local widget_mat = cc.CSLoader:createNode("mail_collection_content_2.csb")


  --采集的资源项
  local isJudianFight = mail.data.element_id == 2001 
  if not isJudianFight then --据点战不显示资源
    root = widget_mat:getChildByName("Panel_1") 
    root:getChildByName("name_time"):setString("")

    local pic = root:getChildByName("pic_general")
    local mat = {mail.data.resource.gold, mail.data.resource.food, mail.data.resource.wood, mail.data.resource.stone, mail.data.resource.iron}
    local matNames = {"assets1", "assets2", "assets3", "assets4", "assets5"} 
    local ownNum, path, collectNum, name 
    local gainCount = 0 
    for k, v in pairs(mat) do 
      if v > 0 then 
        gainCount = gainCount + 1 
        collectNum = v 
        ownNum, path = g_gameTools.getPlayerCurrencyCount(k)       
        name = g_tr(matNames[k])
        break 
      end 
    end 
    if path then 
      pic:loadTexture(path)
      root:getChildByName("name_general"):setString(name)
      root:getChildByName("name_time"):setString("+"..collectNum)
    end 

    if gainCount == 0 then --未获得任何资源
      pic:setVisible(false)
      root:getChildByName("name_general"):setString(g_tr("gainNothing"))
    end 
    pos_y = pos_y - widget_mat:getContentSize().height 
    widget_mat:setPosition(cc.p(0, pos_y))
    node:addChild(widget_mat)
  end 

  --掉落的道具
  local item, widget_new
  for k, v in pairs(mail.data.drop) do 
    if v[1] > 0 and v[2] > 0 then         
      if nil == item then 
        print("item:", v[1], v[2], v[3])
        item = require("game.uilayer.common.DropItemView").new(v[1], v[2], v[3])
      else 
        item:updateInfo(v[1], v[2], v[3])
      end
      widget_new = widget_mat:clone()
      root = widget_new:getChildByName("Panel_1") 
      root:getChildByName("pic_general"):loadTexture(item:getIconPath())
      root:getChildByName("name_general"):setString(item:getName())
      root:getChildByName("name_time"):setString("+"..v[3])
      pos_y = pos_y - widget_new:getContentSize().height 
      widget_new:setPosition(cc.p(0, pos_y))
      node:addChild(widget_new)
    end 
  end 

  --据点战时未获得锦囊,提示信息
  if isJudianFight and mail.data.drop and #mail.data.drop == 0 then 
    widget_new = widget_mat:clone()
    root = widget_new:getChildByName("Panel_1") 
    root:getChildByName("name_time"):setString("")
    root:getChildByName("pic_general"):setVisible(false)
    root:getChildByName("name_general"):setString(g_tr("gainNoJinNang")) 
    pos_y = pos_y - widget_new:getContentSize().height 
    widget_new:setPosition(cc.p(0, pos_y))
    node:addChild(widget_new)      
  end 

  --调整MailListItem大小
  self:setContentSize(cc.size(widget_title:getContentSize().width, -pos_y))
  node:setPosition(cc.p(0, -pos_y))
  self:addChild(node) 
end 


function MailListItem:initMonsterReport(mail)
  self:setSelected(true) --默认全选(所有采集报告当做一封邮件处理)

  if nil == mail then return end 

  local node = ccui.Widget:create()
  local pos_y = 0 
  local widget_new 
  local widget = cc.CSLoader:createNode("mail_monster_content_1.csb") 
  pos_y = pos_y - widget:getContentSize().height 
  widget:setPosition(cc.p(0, pos_y))
  node:addChild(widget)

  local isWin = MailHelper:isWin(mail)
  local root = widget:getChildByName("Panel_1")
  root:getChildByName("Image_victory"):setVisible(isWin)
  root:getChildByName("Image_fail"):setVisible(not isWin)

  --怪物信息
  local lbPos1 = root:getChildByName("Text_pos_1")
  local lbPos2 = root:getChildByName("Text_pos_2")
  lbPos1:setString(g_tr("battlePos2"))
  MailHelper:addUnderLineForLabel(lbPos2, mail.data.x, mail.data.y)
  lbPos2:setPositionX(lbPos1:getPositionX()+lbPos1:getContentSize().width)
  

  self.lbTime = root:getChildByName("Text_time")
  if mail.data.player2 and mail.data.player2.avatar then 
    local item = g_data.map_element[mail.data.player2.avatar]
    if item then 
      root:getChildByName("pic_0"):loadTexture(g_resManager.getResPath(item.img_mail))
      root:getChildByName("pic_1"):loadTexture(g_resManager.getResPath(1010007))
      root:getChildByName("Text_name"):setString(g_tr(item.name) .. " LV." .. item.level)
      root:getChildByName("Text_fail"):setString(g_tr("monsterFailTips", {lv = item.level, name = g_tr(item.name)}))
    end 
  end 

  if mail.data.type == 8 and mail.data.boss_lost_hp then --BOSS 
    root:getChildByName("Text_name1"):setString(g_tr("lostHp").." "..mail.data.boss_lost_hp)
    root:getChildByName("Text_name2"):setString(g_tr("leftHp").." "..mail.data.boss_left_hp)
  else 
    root:getChildByName("Text_name1"):setString("")
    root:getChildByName("Text_name2"):setString("")
  end 

  --玩家损耗信息
  local totalPower = 0 
  local totalSoldiers = 0 
  local totalHurts = 0 
  local totalLeft = 0 
  if mail.data.player1 then 
    for m, p in pairs(mail.data.player1.players) do 
      totalPower = totalPower + p.power
      for k, v in pairs(p.unit) do 
        totalSoldiers = totalSoldiers + v.soldier_num
        totalHurts = totalHurts + v.injure_num 
        totalLeft = totalLeft + v.live_num 
      end 
    end 
  end 
  totalPower = math.floor(totalPower/10000)
  root:getChildByName("Text_power1"):setString(g_tr("armyFightForce"))
  root:getChildByName("Text_power2"):setString(""..totalPower)
  root:getChildByName("Text_total1"):setString(g_tr("totalSoldiers"))
  root:getChildByName("Text_total2"):setString(""..totalSoldiers)
  root:getChildByName("Text_hurt1"):setString(g_tr("hurtNum"))
  root:getChildByName("Text_hurt2"):setString(""..totalHurts)
  root:getChildByName("Text_left1"):setString(g_tr("leftNum"))
  root:getChildByName("Text_left2"):setString(""..totalLeft)

  local nodeMat = root:getChildByName("Panel_9")
  local btnPower = root:getChildByName("Button_zhanli") 
  local lbFail = root:getChildByName("Text_fail")
  local arrow = nodeMat:getChildByName("Panel_arrow") 
  --如果有奖励则显示
  local listView = nodeMat:getChildByName("ListView_1")
  listView:setItemsMargin(10)
  listView:setScrollBarEnabled(false)

  nodeMat:setVisible(false)
  lbFail:setVisible(false)
  arrow:setVisible(false)
  local item = {}
  if mail.item and #mail.item > 0 then 
    item = mail.item 
  elseif mail.data.item and #mail.data.item > 0 then 
    item = mail.data.item 
  end 
  local len = #item
  if len > 0 then 
    nodeMat:setVisible(len > 0)
    arrow:setVisible(len > 6)
    for k, v in pairs(item) do 
      if v[1] > 0 and v[2] > 0 then 
        local dropItem = require("game.uilayer.common.DropItemView").new(v[1], v[2], v[3])
        if dropItem then 
          dropItem:setNameVisible(true)
          g_itemTips.tip(dropItem,v[1], v[2])
          listView:pushBackCustomItem(dropItem)
        end 
      else 
        print("@@@ invalid drop item !!!!", v[2])
      end 
    end 
  else 
    nodeMat:setVisible(false)
  end 
  local items = listView:getItems()
  listView:setTouchEnabled(items and #items > 6)

  if isWin then 
    if mail.data.type == 8 then --BOSS
      nodeMat:getChildByName("Text_success"):setString(g_tr("killBossAward"))
    else 
      nodeMat:getChildByName("Text_success"):setString(g_tr("battleAward"))
    end 
  elseif mail.data.type ~= 8 then 
    lbFail:setVisible(true)
  end 

  btnPower:setVisible(not isWin and mail.data.type ~= 8)
  if btnPower:isVisible() then 
    btnPower:getChildByName("Text_tisheng"):setString(g_tr("powerYourself"))
    btnPower:addClickEventListener(function()
      g_sceneManager.addNodeForUI(require("game.uilayer.power.PowerView").new()) 
      self:getDelegate():close() 
      end) 
  end 

  self:setContentSize(cc.size(widget:getContentSize().width, -pos_y))
  node:setPosition(cc.p(0, -pos_y))
  self:addChild(node) 
end 


return MailListItem 
