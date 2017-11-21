
local MailHelper = require("game.uilayer.mail.MailHelper"):instance()
local MailContentSystem = class("MailContentSystem",require("game.uilayer.base.BaseLayer"))
local MailType = MailHelper:getMailTypeEnum() 

local layerObj --当前layer对象
function MailContentSystem:ctor(listItem)
  MailContentSystem.super.ctor(self)
  layerObj = self 
  self.listItem = listItem --关联的某一个邮件列表项
end 

function MailContentSystem:onEnter()
  print("MailContentSystem:onEnter")

  local layer = cc.CSLoader:createNode("mail_system_content.csb")
  if layer then 
    self:addChild(layer) 
    self:initBinding(layer) 
    self:showInfo()
  end 
end 

function MailContentSystem:onExit() 
  print("MailContentSystem:onExit") 
  layerObj = nil 
end 

function MailContentSystem:initBinding(rootNode)
  local top_panel = rootNode:getChildByName("top_panel")
  self.imgTitleBg = top_panel:getChildByName("img_title_bg")
  self.lbTitle = top_panel:getChildByName("Text_title")
  self.lbTime = top_panel:getChildByName("text_time")

  self.btnMark = top_panel:getChildByName("img_label")
  local btnDelete = top_panel:getChildByName("img_delete")
  local btnBack = top_panel:getChildByName("btn_back")
  self.listView = rootNode:getChildByName("ListView_3")
  self.btnFetch = rootNode:getChildByName("Button_2")
  self.lbFetch = self.btnFetch:getChildByName("Text")

  self:regBtnCallback(self.btnMark, handler(self, self.onMarkMail))
  self:regBtnCallback(btnDelete, handler(self, self.onDeleteMail))
  self:regBtnCallback(btnBack, handler(self, self.onGoBack))
  self:regBtnCallback(self.btnFetch, handler(self, self.onFetch))

  --根据自定义功能显示相应字串(暂时定义为领取附件功能)
  --已领取则按钮置灰
  local mail = self.listItem:getData().mail 
  self:setFetchStatus(mail)
  
  MailHelper:setImgGray(self.btnMark, mail.status==0)  
end 

function MailContentSystem:showInfo()
  self.listView:removeAllChildren()
  self.listView:setItemsMargin(8)
  self.listView:setScrollBarEnabled(false)

  if nil == self.listItem then return end 
  local mail = self.listItem:getData().mail 

  --标题
  self.lbTitle:setString(g_tr("systemMail")) --mail.title
  if self.lbTitle:getContentSize().width > 100 then --调整标题背景长度
    self.imgTitleBg:setContentSize(cc.size(self.lbTitle:getContentSize().width+80, self.imgTitleBg:getContentSize().height))
    self.lbTitle:setPosition(cc.p(self.imgTitleBg:getPositionX()+self.imgTitleBg:getContentSize().width/2, self.imgTitleBg:getPositionY()))
  end 

  --时间
  local tt = os.date("*t", mail.create_time)
  self.lbTime:setString(string.format("%d-%d-%d %02d:%02d:%02d",tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))


  local function getRankTopStr(top3)
    local strTop = ""
    if top3 then 
      local v 
      for k = 1, 3 do 
        v = top3[k]
        if v then 
          if v.guild_short == "" then 
            strTop = strTop .. "\n" .. g_tr("top_"..k) .. v.nick
          else 
            strTop = strTop .. "\n" .. g_tr("top_"..k) .. "("..v.guild_short..")" .. v.nick 
          end 
        end 
      end 
    end 
    return strTop 
  end 

  --1.文字详情
  local widget1 = cc.CSLoader:createNode("mail_system_content_info.csb")
  local infoRoot = widget1:getChildByName("bg_info")
  local lbPreSender = infoRoot:getChildByName("Text_from")
  local lbSender = infoRoot:getChildByName("Text_from_0")
  local textRegion = infoRoot:getChildByName("Panel_text_region")
  local infoDesc = infoRoot:getChildByName("Text_info")
  local pic = infoRoot:getChildByName("pic")
  MailHelper:loadResIcon(pic, 1020091)

  lbPreSender:setString(g_tr("mailSender"))
  lbSender:setString(g_tr("systemMail")) 
  if mail.type == MailType.KingWarGift then --国王礼包 
    if mail.data.kingName then 
      lbSender:setString(mail.data.kingName)
    end 
    infoDesc:setString(g_tr("kingGiftDesc", {name = mail.data.kingName}) or "")

  elseif mail.type == MailType.PowerLostCompensation then --战力损失补偿
    infoDesc:setString(g_tr("llimitRankTips6")) 

  elseif mail.type == MailType.LimitRankGift then --限时比赛排名礼包
    local str = g_tr("limitRankGift")
    if mail.data.rank then 
      str = g_tr("llimitRankTips1", {num = mail.data.rank})
    end 
    str = str .. getRankTopStr(mail.data.top3)
    infoDesc:setString(str) 

  elseif mail.type == MailType.LimitTotalRankGift then --限时比赛总排名礼包
    local str = g_tr("limitTotalRankGift")
    if mail.data.rank then
      str = g_tr("llimitRankTips2", {num = mail.data.rank})
    end  
    str = str .. getRankTopStr(mail.data.top3) 
    infoDesc:setString(str) 

  elseif mail.type == MailType.LimitRankKingFight then --限时比赛国王战奖励
    local str = g_tr("limitTotalRankGift")
    if mail.data.rank then
      str = g_tr("llimitRankTips8", {num = mail.data.rank})
    end  
    str = str .. getRankTopStr(mail.data.top3) 
    infoDesc:setString(str) 

  elseif mail.type == MailType.GuildMissionRankGift then --联盟限时比赛总排名礼包
    local str = g_tr("guildMissionRankGift")
    if mail.data.rank then
      str = g_tr("llimitRankTips3", {num = mail.data.rank})
    end  
    str = str .. getRankTopStr(mail.data.top3)
    infoDesc:setString(str) 

  elseif mail.type == MailType.GuildMissionScoreGift then --联盟限时比赛积分礼包
    infoDesc:setString(g_tr("guildMissionScoreGift")) 
    if mail.data.score then 
      infoDesc:setString(g_tr("llimitRankTips4", {num = mail.data.score})) 
    end  
    
  elseif mail.type == MailType.LimitScoreGift then --限时比赛阶段礼包
    infoDesc:setString(g_tr("limitScoreGift"))   
    if mail.data.step_point then 
      infoDesc:setString(g_tr("llimitRankTips5", {num = mail.data.step_point})) 
    end  

  elseif mail.type == MailType.GuildPayGift then --联盟充值礼包
    infoDesc:setString(g_tr("guildPayGiftDesc", {name = mail.data.nick}))

  elseif mail.type == MailType.FirstJointGuild then --第一次加入联盟
    infoDesc:setString(g_tr("llimitRankTips7"))

  elseif mail.type == MailType.BigDeal then --大额充值
    infoDesc:setString(g_tr("largeRechargeTips"))

  elseif mail.type == MailType.HuangJinGift then --黄巾起义波次奖励
    infoDesc:setString(g_tr("huangjinGiftDesc", {count = mail.data.wave or 1})) 
  
  elseif mail.type == MailType.KingAppoint then --皇帝任命
    local str = ""
    local targetName = ""
    if mail.from_guild_short ~= "" then 
      targetName = "("..mail.from_guild_short..")"
    end 
    targetName = targetName .. (mail.data.target_player_nick or "")
    if mail.data.target_player_job then 
      local item = g_data.king_appoint[mail.data.target_player_job]
      if item then 
        if item.type == 1 then --升职
          str = g_tr("promoteTips", {name = targetName, job = g_tr(item.position_name)})
        else 
          str = g_tr("demotionTips", {name = targetName, job = g_tr(item.position_name)})
        end  
      end 
    end 
    infoDesc:setString(str)

  elseif mail.type == MailType.BecomeKing then --皇帝登基
    infoDesc:setString(g_tr("becomeKingTips", {name = mail.data.king_nick or ""})) 

  elseif mail.type == MailType.PlayerCreateAcountTip then --玩家创建账号tips
    if mail.data.mail_tips_id and g_data.email_tips[tonumber(mail.data.mail_tips_id)] then 
      infoDesc:setString(g_tr(g_data.email_tips[tonumber(mail.data.mail_tips_id)].desc)) 
    end 

  elseif mail.type == MailType.GodGeneralExpItem then --神武将经验道具
    infoDesc:setString(g_tr("godGenExpItemDesc"))

  elseif mail.type == MailType.ActivityWillOpen then --即将开启的活动 
    local actName = "" 
    local actSubName = ""
    if mail.data.activity_id == 1002 then --
      lbSender:setString(g_tr("limitActWillOpen")) 
      actName = g_tr("limitedMatchTitle")
      if mail.data.activity_sub_id then 
        actSubName = g_tr("limitedMatchTypeName"..mail.data.activity_sub_id)
      end 
    elseif mail.data.activity_id == 1003 then
      lbSender:setString(g_tr("allianceActWillOpen")) 
      actName = g_tr("allianceTask")
      if mail.data.activity_sub_id then 
        actSubName = g_tr("allianceType"..mail.data.activity_sub_id)
      end 
    end 
    infoDesc:setString(g_tr("activityWillOpen", {name = actName, subName = actSubName}))
  
  elseif mail.type == MailType.GuildMissionGift then --联盟活动礼包
    lbSender:setString(g_tr("allianceMissionGiftTitle")) 
    infoDesc:setString(g_tr("allianceMissionGiftDesc", {guild = mail.data.guildName, name = mail.data.LeaderName}))

  elseif mail.type == MailType.WuDouRoundGift then --武斗赛季奖励
    local name = ""
    local id = tonumber(mail.data.duel_rank_id)
    if g_data.duel_rank[id] then 
      name = g_tr(g_data.duel_rank[id].rank_name)
    end 
    lbSender:setString(g_tr("wudouRoundGift"))
    infoDesc:setString(g_tr("wudouRoundGiftDesc",{rank = name, point = mail.data.score}))

  elseif mail.type == MailType.CrossRewardJoined then --跨服战参与奖励(包含胜败)
    if mail.data.is_win and mail.data.is_win > 0 then 
      lbSender:setString(g_tr("crossJoinedAndWinTitle")) 
      infoDesc:setString(g_tr("crossJoinedAndWin")) 
    else 
      lbSender:setString(g_tr("crossJoinedAndLostTitle")) 
      infoDesc:setString(g_tr("crossJoinedAndLost")) 
    end 
    
  elseif mail.type == MailType.CrossRewardNotJoined then --跨服战未参与(包含胜败)
    if mail.data.is_win and mail.data.is_win > 0 then 
      lbSender:setString(g_tr("crossNotJoinedAndWinTitle")) 
      infoDesc:setString(g_tr("crossNotJoinedAndWin")) 
    else 
      lbSender:setString(g_tr("crossNotJoinedAndLostTitle")) 
      infoDesc:setString(g_tr("crossNotJoinedAndLost")) 
    end 

  elseif mail.type == MailType.CrossUnselected then --跨服战落选
    lbSender:setString(g_tr("crossUnselectedNoticeTitle")) 
    infoDesc:setString(g_tr("crossUnselectedNotice")) 

  elseif mail.type == MailType.CrossLeaderJoinNotice then --盟主/副盟主参加跨服战通知
    lbSender:setString(g_tr("crossLeaderJoinNoticeTitle")) 
    infoDesc:setString(g_tr("crossLeaderJoinNotice", {num = mail.data.round or 1})) 

  elseif mail.type == MailType.TestPayReturn then --封测充值返利3倍元宝
    local count
    if mail.item and mail.item[1] then 
      count = string.formatnumberlogogram(mail.item[1][3])
    end 
    lbSender:setString(g_tr("testPayReturnTitle")) 
    infoDesc:setString(g_tr("testPayReturnDesc", {num = count})) 

  elseif mail.type == MailType.CityBattleAwardYuLinJun then --城战羽林军奖励 
    local campName = "X"
    local rankName = ""
    if mail.data.camp_id then 
      campName = g_tr(g_data.country_camp_list[mail.data.camp_id].camp_name)
    end 
    
    for k, v in pairs(g_data.country_battle_title) do 
      if v.rank == mail.data.rank then 
        rankName = g_tr(v.title_name)
        break 
      end 
    end 
    lbSender:setString(g_tr("mailYinlinjunAwardTitle", {country = campName}))     
    infoDesc:setString(g_tr("mailYinlinjunAwardDesc", {count = mail.data.score, name = rankName}))

  elseif mail.type == MailType.CityBattleAward then --城战奖励 
    local strCity = ""
    if mail.data.city_id then 
      strCity = g_tr(g_data.country_city_map[tonumber(mail.data.city_id)].ctiy_name)
    end 
    local strTitle = ""
    local strDesc = ""
    if mail.data.in_flag == 1 then --城门
      strTitle = g_tr("mailCityDoorBattleAwardTitle", {name = strCity})
      strDesc = g_tr("mailCityDoorBattleAwardDesc", {name = strCity})
    else 
      strTitle = g_tr("mailCityBattleAwardTitle", {name = strCity})
      if mail.data.is_attacker > 0 then  
        if mail.data.is_win > 0 then 
          strDesc = g_tr("mailCityBattleAtkAwardWin", {name = strCity})
        else 
          strDesc = g_tr("mailCityBattleAtkAwardLost", {name = strCity})
        end 
      else 
        if mail.data.is_win > 0 then 
          strDesc = g_tr("mailCityBattleDefAwardWin", {name = strCity})
        else 
          strDesc = g_tr("mailCityBattleDefAwardLost", {name = strCity})
        end 
      end 
    end 
    lbSender:setString(strTitle)
    infoDesc:setString(strDesc)

  elseif mail.type == MailType.CityBattleTokenAward then --城战报名奖励
    lbSender:setString(g_tr("mailCityBattleTokenTitle"))
    infoDesc:setString(g_tr("mailCityBattleTokenDesc")) 
    
  elseif mail.type == MailType.CityBattleTaskAward then --城战联盟任务奖励
    lbSender:setString(g_tr("mailCityBattleTaskAwardTitle"))
    infoDesc:setString(g_tr("mailCityBattleTaskAwardDesc")) 

  elseif mail.type == MailType.CityBattleSignFail then --普通报名落选
    local strCity = ""
    if mail.data.city_id then 
      strCity = g_tr(g_data.country_city_map[tonumber(mail.data.city_id)].ctiy_name)
    end     
    lbSender:setString(g_tr("mailCityBattleSignFailTitle", {cityName=strCity}))
    infoDesc:setString(g_tr("mailCityBattleSignFailDesc", {cityName=strCity})) 

  elseif mail.type == MailType.CityBattleCampWiner then --赛季优胜奖励
    lbSender:setString(g_tr("mailCityBattleCampWinerTitle"))
    infoDesc:setString(g_tr("mailCityBattleCampWinerDesc"))

  elseif mail.type == MailType.ArcheryLocalRankAward then --射箭本服排名奖励
    lbSender:setString(g_tr("mailArcheryLocalRankAwardTitle"))
    infoDesc:setString(g_tr("mailArcheryLocalRankAwardDesc", {num = mail.data.rank}))

  elseif mail.type == MailType.ArcheryGlobalRakAward then --射箭跨服排名奖励
    lbSender:setString(g_tr("mailArcheryGlobalRankAwardTitle"))
    infoDesc:setString(g_tr("mailArcheryGlobalRankAwardDesc", {num = mail.data.rank}))

  else 
    if mail.from_player_name and mail.from_player_name ~= "" then 
      lbSender:setString(mail.from_player_name)
    end 
    infoDesc:setString(tostring(mail.msg))
  end 
  lbSender:setPositionX(lbPreSender:getPositionX()+lbPreSender:getContentSize().width)

  --文字自动换行
  local textRec = textRegion:getContentSize() --默认文字区域,超出则需要自动扩展
  local strSize = infoDesc:getContentSize()
  if strSize.width > textRec.width then 
    infoDesc:setTextAreaSize(cc.size(textRec.width, 0))
    infoDesc:ignoreContentAdaptWithSize(false)
    strSize = infoDesc:getContentSize()
  end 

  --根据文字高度来调整widget高度 
  local deltaH = strSize.height - textRec.height 
  if deltaH > 0 then 
    infoRoot:setPositionY(infoRoot:getPositionY() + deltaH)
    widget1:setContentSize(cc.size(widget1:getContentSize().width, widget1:getContentSize().height+deltaH))
  end 

  self.listView:pushBackCustomItem(widget1) 

  --2.道具
  local len = #mail.item
  local pageCount = math.ceil(len/6)
  if pageCount > 0 then 
    local widget2 = cc.CSLoader:createNode("mail_system_content_gift.csb")
    local newWidget, pic, idx, icon, itype, id, count  
    widget2:retain()
    for i=1, pageCount do 
      newWidget = widget2:clone()
      for j=1, 6 do  
        pic = newWidget:getChildByName(string.format("pic_%d", j))        
        idx = (i-1)*6 + j
        if idx <= len then 
          itype = mail.item[idx][1]
          id = mail.item[idx][2]
          count = mail.item[idx][3] or 1 
          icon = require("game.uilayer.common.DropItemView").new(itype, id, count)
          if icon then 
            icon:setScale(pic:getContentSize().width/icon:getContentSize().width)
            icon:setPosition(cc.p(pic:getContentSize().width/2, pic:getContentSize().height/2))
            icon:setNameVisible(true)
            pic:addChild(icon)
          end 

        else 
          pic:setVisible(false) 
        end 
      end 
      self.listView:pushBackCustomItem(newWidget) 
    end 
    widget2:release()
  end 
end 

function MailContentSystem:onMarkMail()
  print("onMarkMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  if self:getDelegate() then 
    local ret = self:getDelegate():doMarkMails({self.listItem})
    if ret then 
      MailHelper:setImgGray(self.btnMark, self.listItem:getData().mail.status == 0)
    end 
  end 
end 

function MailContentSystem:onDeleteMail()
  print("onDeleteMail")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local mail = self.listItem:getData().mail 
  local canFetched = #mail.item > 0 and mail.read_flag < 2 
  if canFetched then 
    g_airBox.show(g_tr("plsFetchFirst"))    
    return 
  end 
  if self:getDelegate() then 
    self:getDelegate():doDeleteMails({self.listItem})
  end 
end 

function MailContentSystem:onGoBack()
  if self:getDelegate() then 
    self:getDelegate():onGoBack()
  end 
end 

--领取附件
function MailContentSystem:onFetch()
  print("onFetch")
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  
  local data = self.listItem:getData() 
  if data.mail.type == MailType.CrossLeaderJoinNotice then --报名参赛跨服战
    local function reqJoinResult(result, tmp)
      print("reqJoinResult:", result)
      if result then 
        data.mail.memo.exec_flag = 1 
        self.listItem:setData(data)

        --更新数据库
        g_MailMode.setMailData(MailHelper.viewType.System, data.mail)

        --更新当前界面
        self:setFetchStatus(data.mail) 
      end 
    end 
    g_sgHttp.postData("cross/applyToJoinBattle", {mail_id = data.mail.id}, reqJoinResult) 
  else 

    local function fetchResult(result, data)
      print("fetchResult", result)
      if nil == layerObj then return end 
      
      if result then 
        -- g_airBox.show(g_tr("fetchSucess"))
        
        --更新邮件列表项
        local data = self.listItem:getData()
        data.mail.read_flag = 2 
        self.listItem:setData(data)
        
        --更新数据库
        g_MailMode.setMailData(MailHelper.viewType.System, data.mail)
        
        --更新当前界面
        self:setFetchStatus(data.mail)

        dump(data.mail.item, "data.mail.item")
        require("game.uilayer.task.AwardsToast").show(data.mail.item)
      end 
    end 
    g_sgHttp.postData("Mail/fetchItem", {mailIds = {self.listItem:getData().mail.id}}, fetchResult) 
  end 
end 

function MailContentSystem:setFetchStatus(mail)
  if mail.type == MailType.CrossLeaderJoinNotice then 
    local hasJoined = false 
    if mail.memo and mail.memo.exec_flag and mail.memo.exec_flag > 0 then 
      hasJoined = true 
    end 
    local str = hasJoined and "appSucc" or "signUpMatch" 
    self.btnFetch:setVisible(true)
    self.lbFetch:setVisible(true)

    self.lbFetch:setString(g_tr(str))
    self.btnFetch:setEnabled(not hasJoined)
  else 
    --根据自定义功能显示相应字串(暂时定义为领取附件功能)
    --已领取则按钮置灰
    self.btnFetch:setVisible(#mail.item > 0)
    self.lbFetch:setVisible(#mail.item > 0)

    if self.btnFetch:isVisible() then 
      local canFetched = #mail.item > 0 and mail.read_flag < 2 
      local str = canFetched and "fetch2" or "isFetched"
      self.btnFetch:setEnabled(canFetched)
      self.lbFetch:setString(g_tr(str)) 
    end 
  end 
end 

return MailContentSystem 
