


local MailHelper = class("MailHelper")

MailHelper.viewType = g_gameTools.enum({"SendMail","ChatInfo","Alliance","SpyReport","BattleReport","System","CollectionReport","MonsterReport", "CrossFight", "CityBattle"})

local MailType = {
System                  = 1, --系统邮件 
ChatSingle              = 2, --聊天（单人）
ChatGroup               = 3, --聊天（多人） 
Detect                  = 10, --侦察
Detected                = 11, --被侦察
AtkCityWin              = 20, --攻城战斗胜利 
AtkCityLost             = 21, --攻城战斗失败 
DefenceCityWin          = 22, --守城战斗胜利 
DefenceCityLost         = 23, --守城战斗失败
AtkArmyWin              = 24, --攻击部队胜利 
AtkArmyLost             = 25, --攻击部队失败
DefenceArmyWin          = 26, --防守部队胜利 
DefenceArmyLost         = 27, --防守部队失败 
AtkNpcWin               = 28, --攻击怪物胜利
AtkNpcLost              = 29, --攻击怪物失败
CollectionReport        = 30, --采集报告 
OccupyReport            = 31, --占领报告 
AtkWarning              = 32, --联盟堡垒被攻打预警
AtkBossWin              = 33, --攻击BOSS胜利
AtkBossLost             = 34, --攻击BOSS失败
DetectedWarning         = 35, --联盟堡垒被侦察预警
AllianceInvite          = 40, --联盟邀请 
AllianceApply           = 41, --联盟申请 
AllianceApproval        = 42, --联盟审批(拒绝)
AllianceQuit            = 43, --被赶出联盟 
AllianceGather          = 44, --联盟集结信息 
AllianceRankChange      = 45, --联盟升降阶级
AllianceMoveInvite      = 46, --联盟邀请迁城
AllianceChangeCamp      = 1047, --阵营转移
KingWarGift             = 47, --国王战礼包
LimitRankGift           = 48, --限时比赛排名礼包
LimitTotalRankGift      = 49, --限时比赛总排名礼包
PowerLostCompensation   = 50, --战力损失补偿(系统)
GuildMissionRankGift    = 51, --联盟限时比赛总排名礼包
GuildMissionScoreGift   = 52, --联盟限时比赛积分礼包
LimitScoreGift          = 53, --限时比赛阶段礼包
GuildPayGift            = 54, --联盟充值礼包
FirstJointGuild         = 55, --第一次加入联盟
BigDeal                 = 56, --大额充值
HuangJinGift            = 57, --黄巾起义波次奖励
LimitRankKingFight      = 58, --显示比赛国王战排名礼包
KingAppoint             = 59, --官职任命
BecomeKing              = 60, --国王登基
PlayerCreateAcountTip   = 61, --玩家创建账号tips
GodGeneralExpItem       = 62, --神武将经验道具
GuildLeaderImpeach      = 63, --盟主弹劾
ActivityWillOpen        = 64, --即将开启的活动
GuildMissionGift        = 65, --联盟活动礼包
WuDouRoundGift          = 66, --武斗赛季奖励

CrossUnselected         = 67, --跨服战落选
TestPayReturn           = 68, --封测充值返利
CrossAtkCityWin         = 70, --跨服战攻城战斗胜利
CrossAtkCityLost        = 71, --跨服战攻城战斗失败
CrossDefCityWin         = 72, --跨服战守城战斗胜利
CrossDefCityLost        = 73, --跨服战守城战斗失败 
CrossAtkArmyWin         = 74, --跨服战攻击投石车胜利
CrossAtkArmyLost        = 75, --跨服战攻击投石车失败
CrossDefArmyWin         = 76, --跨服战防守投石车胜利
CrossDefArmyLost        = 77, --跨服战防守投石车失败
CrossAtkDoor            = 78, --跨服战攻击城门
CrossAtkBase            = 79, --跨服战攻击大本营

CrossRewardJoined       = 80, --跨服战参与奖励(包含胜败)
CrossRewardNotJoined    = 81, --跨服战未参与(包含胜败)
CrossLeaderJoinNotice   = 84, --盟主/副盟主参加跨服战通知

CityBattleAtkCityWin    = 90, --城战攻城战斗胜利
CityBattleAtkCityLost   = 91, --城战攻城战斗失败
CityBattleDefCityWin    = 92, --城战守城战斗胜利
CityBattleDefCityLost   = 93, --城战守城战斗失败
CityBattleAtkArmyWin    = 94, --城战攻击投石车胜利
CityBattleAtkArmyLost   = 95, --城战攻击投石车失败
CityBattleDefArmyWin    = 96, --城战防守投石车胜利
CityBattleDefArmyLost   = 97, --城战防守投石车失败
CityBattleAtkDoor       = 98, --城战攻击城门
CityBattleAtkBase       = 99, --城战攻击大本营

CityBattleAwardYuLinJun = 105, --城战羽林军奖励
CityBattleAward         = 106, --城战奖励
CityBattleTaskAward     = 107, --城战联盟任务奖励
CityBattleTokenAward    = 108, --城战报名奖励令牌
CityBattleSignFail      = 109, --普通报名落选
CityBattleCampWiner     = 110, --赛季优胜奖励
ArcheryLocalRankAward   = 111, --射箭本服排名奖励
ArcheryGlobalRakAward   = 112, --射箭跨服排名奖励
} 

local BattleSubType = {
  Normal      = 1,   --攻城战
  Resource    = 2,   --资源战
  Castle      = 3,   --联盟堡垒战
  King_PVP    = 4,   --国王战PVP
  King_PVE    = 5,   --国王战PVE
  King_NPC    = 6,   --国王战NPC
  Monster     = 7,   --打怪
  Boss        = 8,   --打Boss
  JudianFight = 9,   --据点战
  HuangJin    = 10,  --黄巾起义
  AtkCity     = 11,  --跨服战/城战攻击主城
  AtkArmy     = 12,  --跨服战/城战攻击投石车
  AtkDoor     = 13,  --跨服战/城战攻击城门
  AtkBase     = 14,  --跨服战/城战攻击大本营
}

local SpyType = {
  Normal    = 1, --侦察主城
  Castle    = 2, --侦察联盟堡垒  
  Resource  = 3, --侦察资源
  KingFight = 4, --国王战
  JuDian    = 5, --侦查据点
}


local mailCountPerPage = 5  



function MailHelper:instance()
  if nil == MailHelper._instance then 
    MailHelper._instance = MailHelper.new()
  end 

  return MailHelper._instance 
end 


--截断文字
--maxWidth:单行文字最大宽度
--fontSize: 字体大小
--suffix: 截断后添加的后缀字串
function MailHelper:getTrimedTitle(str, fontSize, maxWidth, suffix)
  local newStr = ""

  if str and type(str) == "string" and str:len() > 0 then 
    local ch, charW, len 
    local pos = 1
    local strWidth = 0 
    local extStr = ""

    while pos <= str:len() do
      ch = string.byte(str, pos) 
      if ch > 0x80 then --中文
        len = 3 
        charW = fontSize 
      elseif ch == 10 then --换行符 
        break 
      else  --ascii 字符
        len = 1 
        charW = fontSize/2 
      end 

      if strWidth + charW >= maxWidth then 
        pos = pos - 1 
        extStr = suffix or "..."
        break 
      end 

      strWidth = strWidth + charW 
      pos = pos + len 
    end 

    newStr = string.sub(str, 1, pos) .. extStr
  end 

  return newStr 
end 

--去掉字串前面的空格
function MailHelper:getTrimedSpace(str)
  local newStr = str
  
  if str and type(str) == "string" and str:len() > 0 then 
    local pos = 1
    while pos <= str:len() do
      if string.byte(str, pos) == 32 then 
        pos = pos + 1 
      else 
        break 
      end 
    end 

    if pos > 1 then 
      newStr = string.sub(str, pos)
    end 
  end 

  return newStr 
end 


--对收件人列表字串进行格式检查(每个收件人以分号隔开), 
--如果正确则返回收件人列表
function MailHelper:getRecvNames(str)
  
  --对单个字串进行检查,返回新的有效字串
  local function checkIsValidName(strName)
    local idx_s = 1
    local ch, len 

    --名字前面的空格去掉 
    while idx_s <= strName:len() do 
      ch = string.byte(strName, idx_s) 
      if ch == 32 then 
        idx_s = idx_s + 1 
      else 
        break 
      end 
    end 
    print("idx_s", idx_s)
    local idx_e = idx_s 
    while idx_e <= strName:len() do 
      ch = string.byte(strName, idx_e) 
      if ch > 0x80 then 
        len = 3 
      elseif ch == 10 or ch == 32 then --换行符/空格 都是非法
        return 
      else 
        len = 1 
      end 

      idx_e = idx_e + len 
    end 

    if idx_e >= idx_s + 1 then 
      return string.sub(strName, idx_s, idx_e-1)
    end 
  end 


  --检查所有收件人名字是否合法
  local result = true 
  local tbl = {}
  if str ~= "" then 
    local names = string.split(str,";")
    local tmp 

    if #names > 0 and names[#names] == "" then --将最后一个空字串去掉
      names[#names] = nil 
    end 

    for k, v in pairs(names) do 
      tmp = checkIsValidName(v)
      if tmp then 
        table.insert(tbl, tmp)
      else 
        result = false 
        break 
      end 
    end 
  else 
    result = false
  end 

  return result, tbl 
end 

--对邮件列表数据排序, 1. 未读 > 已读 , 2.分别对未读和已读再按时间排序
function MailHelper:sortMails(tbl, viewType)
  local function sortByFunc(tbl, idx_s, idx_e, sortFunc)
    if idx_e < idx_s + 1 then
      return 
    end 
    for i = idx_s, idx_e-1 do 
      local k = i 
      for j=i+1, idx_e do 
        if sortFunc(tbl[k], tbl[j]) then 
          k = j 
        end 
      end 

      if k > i then
        local tmp = tbl[k]
        tbl[k] = tbl[i]
        tbl[i] = tmp
      end 
    end 
  end 

  local function sortByTime(a, b) --时间先后
    return a.mail.create_time < b.mail.create_time 
  end 

  --如果是打怪报告/采集报告,则统一按时间排序
  if viewType == MailHelper.viewType.CollectionReport or viewType == MailHelper.viewType.MonsterReport then 
    sortByFunc(tbl, 1, #tbl, sortByTime)
    return 
  end 

  --1.先按已读未读排序
  table.sort(tbl, function(a, b) return a.mail.read_flag < b.mail.read_flag end)

  local idx_s = 1
  local idx_e = #tbl  
  if idx_e < idx_s + 1 then 
    return 
  end 

  --2.按时间先后
  local preType = tbl[idx_s].mail.read_flag
  for i=idx_s+1, idx_e do
    local curType = tbl[i].mail.read_flag
    if i < idx_e then
      if curType ~= preType then
        sortByFunc(tbl, idx_s, i-1, sortByTime)
        idx_s = i
        preType = curType
      end 
    else 
      if curType ~= preType then
        sortByFunc(tbl, idx_s, i-1, sortByTime)
      else
        sortByFunc(tbl, idx_s, i, sortByTime)
      end
    end
  end  
end 

--准备一页数据
function MailHelper:readyOnePageData(mailType, usrCallback) 
  if nil == mailType then return end 

  if mailType == MailHelper.viewType.SendMail then 
    if usrCallback then 
      usrCallback()
    end 
  else 

    local total, newCount = g_MailMode.getDataCount(mailType)
    print("readyOnePageData:total, newCount, mailType", total, newCount, mailType)
    if total >= mailCountPerPage then 
      if usrCallback then 
        usrCallback()
      end 
    else 
      local info = g_MailMode.getUnreadInfo() 
      if info[tostring(mailType)].count > newCount then --异步联网请求
        g_busyTip.show_1()
        g_MailMode.RequestData(mailType, 0, 0, true, function(result)
            g_busyTip.hide_1()
            if usrCallback then 
              usrCallback()
            end           
          end ) 
      else 
        --数据已经是最新
        if usrCallback then 
          usrCallback() 
        end 
      end 
    end 
  end 
end 


--获取旧的邮件列表 
--minId: 0：获取最新的一页数据(包含新数据), 否则返回比 minId 小的一页数据 (不包括minId)
function MailHelper:getListDataByMinId(mailType, minId, unReadCount)
  local tbl = {}
  local count = 0 
  local newCount = 0 
  local data = g_MailMode.getListData(mailType) 
  if #data > 0 then   --有数据的情况下
    self:sortMails(data, mailType)
    for k, v in pairs(data) do 
      if (minId == 0 or v.mail.id < minId) then 
        table.insert(tbl, v)
        count = count + 1 

        if v.mail.read_flag == 0 then 
          newCount = newCount + 1 
        elseif count > mailCountPerPage then 
          break 
        end 
      end 
    end 
  end 

  --如果当前数据中新邮件数 < 实际新邮件数, 则联网请求一次
  if unReadCount and unReadCount[tostring(mailType)] and unReadCount[tostring(mailType)] > newCount then 
    tbl = {}
    print("fetch new mail again...")
  end 

  if #tbl < mailCountPerPage then   --找不到足够的有效数据时, 联网请求一次
    local result, len = g_MailMode.RequestData(mailType, 0, minId) 
    if result and len > 0 then 
      tbl = {}
      count = 0 
      data = g_MailMode.getListData(mailType)
      self:sortMails(data, mailType)
      for k, v in pairs(data) do 
        if (minId == 0 or v.mail.id < minId) then 
          --如果是新邮件,则全部添加,否则总数不超过5封
          if v.mail.read_flag > 0 and count > mailCountPerPage then 
            break 
          end 
          table.insert(tbl, v)
          count = count + 1 
        end 
      end 
    end 
  end 

  print("getListDataByMinId:mailType, minId, len", mailType, minId, #tbl)
  return tbl 
end 

--获取新的邮件列表(无数量上限), 不包括 maxId 对应的邮件!!!
function MailHelper:getListDataByMaxId(viewType, maxId, isNeedRequestServer)

  if isNeedRequestServer then 
    local direction = maxId > 0 and 1 or 0     
    local result, len = g_MailMode.RequestData(viewType, direction, maxId) 
    print("getListDataByMaxId: result, len, maxId", result, len, maxId)
  end 

  local tbl = {}
  local data = g_MailMode.getListData(viewType) 
  for k, v in pairs(data) do 
    if v.mail.id > maxId then 
      table.insert(tbl, v) 
    end 
  end 

  return tbl 
end 

--tbl2数据合并到tbl1(数据有可能重叠), 返回合并后的数据以及被合并的数据
function MailHelper:mergeMailData(tbl1, tbl2)
  local data = {}
  local diff = {}

  for k, v in pairs(tbl1) do 
    table.insert(data, v) 
  end 

  local found
  for k, v in pairs(tbl2) do 
    found = false 
    for i, p in pairs(data) do 
      if v.mail.id == p.mail.id then 
        found = true 
      elseif (v.mail.type == 2 and p.mail.type == 2) or (v.mail.type == 3 and p.mail.type == 3) then --聊天项可合并
        if v.mail.connect_id == p.mail.connect_id then --属于同一会话
          found = true 
          if v.mail.create_time > p.mail.create_time then --如果该会话有最新的项则更新
            data[i] = v 
          end 
        end 
      end 

      if found then break end 
    end 

    if not found then 
      table.insert(diff, v)
    end 
  end 

  for k, v in pairs(diff) do 
    table.insert(data, v)
  end 
    
  return data, diff 
end 




--获取旧的聊天记录
--mailType: mail.type (2:单人  3:多人)
--connectId: 邮件信息里的connect_id
--minId: 0：获取第一页数据, 否则返回比 minId 小的数据(个数不超过mailCountPerPage)
function MailHelper:GetChatDataByMinId(mailType, connectId, minId)
  local tbl = {}
  local count = 0 

  local data = g_MailMode.getChatLogData(connectId) 
  if #data > 0 then   --有数据的情况下
    for i=1, #data do 
      if (minId == 0 or data[i].id < minId) and count < mailCountPerPage then 
        table.insert(tbl, data[i])
        count = count + 1 
      end 
    end 
  end 

  if #tbl < mailCountPerPage then   --找不到足够的有效数据时, 联网请求一次
    local result, len = g_MailMode.requestChatLog(mailType, connectId, 0, minId)
    if result and len > 0 then 
      data = g_MailMode.getChatLogData(connectId) 
      tbl = {}
      count = 0 
      for i=1, #data do 
        if (minId == 0 or data[i].id < minId) and count < mailCountPerPage then 
          table.insert(tbl, data[i])
          count = count + 1 
        end 
      end 
    end 
  end 
  
  print("===GetChatDataByMinId:type, conId,minId, len=", mailType, connectId, minId, #tbl)
  return tbl 
end 

--获取最新的邮件(id > maxId)
--mailType: mail.type (2:单人  3:多人)
--connectId: mail.connect_id
function MailHelper:getNewestChatDataByMaxId(mailType, connectId, maxId, isNeedRequestServer)
  print("==getNewestChatDataByMaxId:mailType, connectId, maxId", mailType, connectId, maxId)

  if isNeedRequestServer then 
    local result, len = g_MailMode.requestChatLog(mailType, connectId, 1, maxId)
  end 

  local tbl = {}
  local data = g_MailMode.getChatLogData(connectId) 
  for i=1, #data do 
    if maxId == 0 or data[i].id > maxId then --最新数据数量不限制
      table.insert(tbl, data[i])
    end 
  end     

  return tbl 
end 


function MailHelper:getCountPerPage()
  return mailCountPerPage 
end 


function MailHelper:setImgGray(img, isGray)
  if isGray then 
    img:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.shaderMode.shader_gray))
  else 
    img:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )    
  end 
end 

function MailHelper:getMailTypeEnum()
  return MailType 
end 

function MailHelper:getBattleSubTypeEnum()
  return BattleSubType 
end 

function MailHelper:getSpyTypeEnum()
  return SpyType 
end 

--是否是进攻战报
function MailHelper:isKindOfAtk(mailtype)
  if mailtype == MailType.AtkCityWin or mailtype == MailType.AtkCityLost 
    or mailtype == MailType.AtkArmyWin or mailtype == MailType.AtkArmyLost
    or mailtype == MailType.AtkNpcWin or mailtype == MailType.AtkNpcLost 
    or mailtype == MailType.CrossAtkCityWin or mailtype == MailType.CrossAtkCityLost
    or mailtype == MailType.CrossAtkArmyWin or mailtype == MailType.CrossAtkArmyLost
    or mailtype == MailType.CrossAtkDoor or mailtype == MailType.CrossAtkBase 
    or mailtype == MailType.CityBattleAtkCityWin or mailtype == MailType.CityBattleAtkCityLost
    or mailtype == MailType.CityBattleAtkArmyWin or mailtype == MailType.CityBattleAtkArmyLost
    or mailtype == MailType.CityBattleAtkDoor or mailtype == MailType.CityBattleAtkBase then 
    return true 
  end 

  return false 
end 

function MailHelper:isWin(mailData)
  local winFlag = mailData.data.win 
  if nil ~= winFlag and "" ~= winFlag then 
    return winFlag 
  end 

  local mailtype = mailData.type 
  if mailtype == MailType.AtkCityWin or mailtype == MailType.AtkArmyWin or mailtype == MailType.AtkNpcWin 
    or mailtype == MailType.DefenceCityWin or mailtype == MailType.DefenceArmyWin or mailtype == MailType.AtkBossWin 
    or mailtype == MailType.CrossAtkCityWin or mailtype == MailType.CrossDefCityWin 
    or mailtype == MailType.CrossAtkArmyWin or mailtype == MailType.CrossDefArmyWin
    or mailtype == MailType.CrossAtkDoor or mailtype == MailType.CrossAtkBase 
    or mailtype == MailType.CityBattleAtkCityWin or mailtype == MailType.CityBattleDefCityWin
    or mailtype == MailType.CityBattleAtkArmyWin or mailtype == MailType.CityBattleDefArmyWin
    or mailtype == MailType.CityBattleAtkDoor or mailtype == MailType.CityBattleAtkBase then 
    return true 
  end 
  
  return false 
end 

--是否跨服战/城战
function MailHelper:isCrossFight(mailData)
  if mailData.data.type == BattleSubType.AtkCity 
    or mailData.data.type == BattleSubType.AtkArmy 
    or mailData.data.type == BattleSubType.AtkDoor 
    or mailData.data.type == BattleSubType.AtkBase then 
    return true 
  end 

  return false 
end 

--是否攻打城门/大本营
function MailHelper:isAtkDoorAndBase(mailData)
  if mailData.data.type == BattleSubType.AtkDoor or mailData.data.type == BattleSubType.AtkBase then 
    return true 
  end 
  
  return false 
end 

--kindType: 1:全部, 2:进攻 3:防守
function MailHelper:getDataByBatKind(data, kindType)
  local tbl = {}

  if kindType == 1 then 
    tbl = data 
  elseif kindType == 2 then 
    for k, v in pairs(data) do 
      if self:isKindOfAtk(v.mail.type) then 
        table.insert(tbl, v)
      end 
    end 
  elseif kindType == 3 then 
    for k, v in pairs(data) do 
      if not self:isKindOfAtk(v.mail.type) then 
        table.insert(tbl, v)
      end 
    end     
  end 

  return tbl
end 

function MailHelper:getTowerLevel()
  local level = 0 
  local data = g_PlayerBuildMode.GetData()
  for k, v in pairs(data) do 
    if v.origin_build_id == 12 then 
      level = v.build_level 
      break 
    end 
  end 

  return level 
end 

function MailHelper:setOfflineAttackedMails(mails)
  self.offlineAtkMails = mails
end 

function MailHelper:getOfflineAttackedMails(mails)
  return self.offlineAtkMails 
end 

--首次登录时查询是否有被攻击的(未读的)战报, 数据放在loading
function MailHelper:isAttackedWhenOffline()
  local mails = MailHelper:getListDataByMaxId(MailHelper.viewType.BattleReport, 0, false) 
  local tbl = {} 
  for k, v in pairs(mails) do 
    if (v.mail.type == MailType.DefenceCityWin or v.mail.type == MailType.DefenceCityLost) and  v.mail.read_flag < 1 then 
      table.insert(tbl, v.mail) 
    end 
  end 
  self:setOfflineAttackedMails(tbl) 

  return #tbl > 0 
end 

function MailHelper:showGeneralAttrTips(btn, generalId)
  if nil == btn or nil == generalId then return end 

  local item = g_data.general[generalId]
  if item then --武将属性和装备属性加成 
    btn:setTouchEnabled(true)
    local title = g_tr("attribute")
    local wu = g_tr("wu").."：" .. item.general_force .. "\n"
    local zhi = g_tr("zhi").."：" .. item.general_intelligence .. "\n"
    local zheng = g_tr("zheng").."：" .. item.general_political .. "\n"
    local tong = g_tr("tong").."：" .. item.general_governing .. "\n"
    local mei = g_tr("mei").."：" .. item.general_charm .. "\n"
    local strTips = wu .. zhi .. zheng .. tong .. mei 
    g_itemTips.tipStr(btn, title, strTips) 
  end 
end 

function MailHelper:showSoldierAttrTips(btn, soldierId, atk, def, hp)
  if nil == btn then return end 

  local item_soldier = g_data.soldier[soldierId]
  if nil == item_soldier then return end 
  if nil == atk or nil == def or nil == hp then return end 

  --点击士兵头像显示基础属性+武将加成属性tips
  local atk_plus = math.floor(math.max(0, tonumber(atk) - item_soldier.attack))
  local def_plus = math.floor(math.max(0, tonumber(def) - item_soldier.defense))
  local hp_plus = math.floor(math.max(0, tonumber(hp) - item_soldier.life))
  local strAtk = g_tr("armyattack").."：" .. item_soldier.attack
  local strDef = g_tr("armydefense").."：" .. item_soldier.defense
  local strHp = g_tr("armylife") .."：".. item_soldier.life 
  if atk_plus > 0 then 
    strAtk = strAtk .. "|<#22,155,209#> +".. atk_plus.."|"
  end 
  if def_plus > 0 then 
    strDef = strDef .. "|<#22,155,209#> +".. def_plus.."|"
  end 
  if hp_plus > 0 then 
    strHp = strHp .. "|<#22,155,209#> +".. hp_plus.."|"
  end 

  local strTips = strAtk .."|<#\n#>|" .. strDef .. "|<#\n#>|" .. strHp
  btn:setTouchEnabled(true)
  local title = g_tr(item_soldier.soldier_name)..g_tr("attribute") 
  g_itemTips.tipStr(btn, title, strTips) 
end 

function MailHelper:loadGeneralSoldierIcon(target, type, configid, starlv)
  if nil == target then return end 

  target:removeAllChildren()
  local size = target:getContentSize() 
  if configid and configid > 1 then 
    local icon = require("game.uilayer.common.DropItemView").new(type, configid, 1)
    if icon then  
      icon:setCountEnabled(false)
      icon:setPosition(cc.p(size.width/2, size.height/2))
      target:addChild(icon)

      --显示星级
      if type == g_Consts.DropType.General and starlv then  
        icon:showGeneralServerStarLv(tonumber(starlv))
      end 
    end 

  else 
    if type == g_Consts.DropType.General then 
      print("load default gen icon..") 
      local icon = g_resManager.getRes(1020112) --默认icon
      local frame = g_resManager.getRes(1010007) --框
      icon:setPosition(cc.p(size.width/2, size.height/2))
      target:addChild(icon)    
      frame:setPosition(cc.p(size.width/2, size.height/2))
      target:addChild(frame)
    end 
  end 
end 

function MailHelper:loadPlayerIcon(target, avartarId)
  if nil == target then return end 
  target:removeAllChildren()
  local size = target:getContentSize() 
  if avartarId and type(avartarId) == "number" and avartarId > 0 then
    local icon 
    if g_data.res_head[avartarId] then 
      icon = g_resManager.getRes(g_data.res_head[avartarId].head_icon)

    elseif g_data.map_element[avartarId] then 
      icon = g_resManager.getRes(g_data.map_element[avartarId].img_mail)
      
    elseif g_data.npc[avartarId] then  
      icon = g_resManager.getRes(g_data.npc[avartarId].img_mail)

    elseif g_data.sprite[avartarId] then 
      icon = g_resManager.getRes(avartarId)
    end 
    if icon then  
      icon:setPosition(cc.p(size.width/2, size.height/2))
      target:addChild(icon)
    end 

    local frame = g_resManager.getRes(1010007) --框
    if frame then 
      frame:setPosition(cc.p(size.width/2, size.height/2))
      target:addChild(frame)  
    end 

  else --默认显示指定soldier icon
    MailHelper:loadGeneralSoldierIcon(target, g_Consts.DropType.Soldier, 20019)
  end 
end 


function MailHelper:loadResIcon(target, resId)
  if nil == target then return end 
  target:removeAllChildren()
  local size = target:getContentSize() 
  if resId then 
    local icon = g_resManager.getRes(resId)
    if icon then  
      icon:setPosition(cc.p(size.width/2, size.height/2))
      target:addChild(icon)
    end 
  end

  local frame = g_resManager.getRes(1010007) --框
  if frame then 
    frame:setPosition(cc.p(size.width/2, size.height/2))
    target:addChild(frame)  
  end 
end 

--集结邮件标题信息
function MailHelper:getGatherInfoStr(mail)
  local str = ""
  if mail and mail.type == MailType.AllianceGather then 
    str = mail.data.from_player_name
    local info = mail.data.target_info 
    if info then 
      local strPos = "(X:"..info.to_x .. ",Y:"..info.to_y ..")" 
      local guildName = ""
      if info.guild_name and info.guild_name ~= "" then 
        guildName = "("..info.guild_name..")"
      end   

      if info.type == "attackBoss" then --boss
        if info.element_id then 
          local item = g_data.map_element[info.element_id]
          if item then 
            str = g_tr("mailGatherInfo", {name = mail.data.from_player_name, info = g_tr("levelNum", {lv=item.level}).. g_tr(item.name)..strPos})
          end 
        end 

      elseif info.type == "attackBase" then --堡垒
        if info.element_id then 
          local item = g_data.map_element[info.element_id]
          if item then           
            str = g_tr("mailGatherInfo", {name = mail.data.from_player_name, info = guildName..g_tr(item.name)..strPos})
          end 
        end 

      elseif info.type == "attackTown" then --国王战
        local item = g_data.map_element[info.element_id]
        if item then           
          str = g_tr("mailGatherInfo", {name = mail.data.from_player_name, info = g_tr(item.name)..strPos})
        end 
        
      elseif info.type == "attackPlayer" then --玩家
        str = g_tr("mailGatherInfo", {name = mail.data.from_player_name, info = guildName..info.nick..strPos})
      end 
    end 
  end 

  return str 
end 


function MailHelper:addUnderLineForLabel(label, x, y, disableJump)
  if nil == label then return end 

  local function gotoPosition(sender)
    if nil == sender then return end 
    
    if disableJump then return end 
    
    --跨服战界面在的时候禁止跳转
    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    if mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then 
      g_airBox.show(g_tr("cannotQuickJumpWhenBattle"))
      return 
    end 

    local pos_x = string.match(sender:getString(),"x:(%d+)")
    local pos_y = string.match(sender:getString(),"y:(%d+)")
    print("gotoPosition:", pos_x, pos_y)
    if pos_x and pos_y then 
      require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex({x = tonumber(pos_x), y = tonumber(pos_y)})
      local view = g_MailMode.getMailView() 
      if view then 
        view:close()
      end 
    end 
  end 

  if x and y then 
    label:setString("(x:".. x .." y:"..y..")")
    label:setTouchEnabled(true)
    label:addClickEventListener(gotoPosition)

    label:removeAllChildren()
    local drawNode = cc.DrawNode:create()
    drawNode:setAnchorPoint(cc.p(0, 0.5))
    drawNode:drawLine(cc.p(0, 0), cc.p(label:getContentSize().width+5, 0), cc.c4f(0.1, 0.6, 0.8, 1))
    drawNode:setPosition(cc.p(0, 0))
    label:addChild(drawNode) 
  else 
    label:setString("")
  end 
end 

function MailHelper:getMailDataById(viewType, id)
  local data = g_MailMode.getMailData(viewType, id)
  if nil == data then 
    local result, len = g_MailMode.RequestData(viewType, 0, id+1) 
    print("getMailDataById: result, len: ", result, len)
    data = g_MailMode.getMailData(viewType, id)
  end 

  if data then 
    return data.mail 
  end 
end 

function MailHelper:setMailSharedTime(mailId, time)
  if nil == self.sharedTime then 
    self.sharedTime = {}
  end 
  self.sharedTime[mailId] = time 
end 

function MailHelper:canMailShared(mailId)
  local preTime = self.sharedTime and self.sharedTime[mailId] or 0 

  if g_clock.getCurServerTime() - preTime < 60 then 
    g_airBox.show(g_tr("chat_share_frequent"))
    return false 
  end 
  return true 
end 

function MailHelper:getPlayerNickAvatar(mailData, playerId) 
  if mailData.data.player1 and mailData.data.player1.players then 
    for k, v in pairs(mailData.data.player1.players) do 
      if v.player_id == playerId then 
        return v.nick, v.avatar 
      end 
    end 
  end 
  
  if mailData.data.player2 and mailData.data.player2.players then 
    for k, v in pairs(mailData.data.player2.players) do 
      if v.player_id == playerId then 
        return v.nick, v.avatar
      end 
    end 
  end 

  return ""
end 

--组织神武将技能伤害描述
function MailHelper:getGodGeneralSkilDesc(info, mailData)
  local result = {}

  result.genName = ""
  result.desc = ""
 
  if info and info.gid then 
    local genBase = g_data.general[info.gid*100+1] 
    if genBase then 
      result.genName = g_tr(genBase.general_name)

      local skill = g_data.combat_skill[genBase.general_combat_skill]
      if skill then 
        local strDesc = ""
        local nick1 = MailHelper:getPlayerNickAvatar(mailData, info.pid)
        local force = tostring(info.para)
        if skill.num_type == 1 then --百分比
          force = string.format("%.2f%%%%", info.para*100)
        end 

        if info.oppGeneralInfo then --神关羽,神黄忠单独处理
          if info.oppGeneralInfo.gid then 
            local oppGenName = info.oppGeneralInfo.gid > 0 and g_tr(g_data.general[info.oppGeneralInfo.gid*100+1].general_name) or ""
            local nick2 = MailHelper:getPlayerNickAvatar(mailData, info.oppGeneralInfo.pid)

            if info.gid == 10109 and not info.oppGeneralInfo.flag then --神黄忠失败时
              strDesc = g_tr("godGenHuangZhongTips", {player = nick1})

            elseif info.gid == 10072 then --荀彧成功/失败
              if not info.oppGeneralInfo.flag then 
                strDesc = g_tr("godGenXunYuTips", {player = nick1})
              else 
                local nick3 = MailHelper:getPlayerNickAvatar(mailData, info.oppGeneralInfo.pid2) 
                local oppGenName3 = info.oppGeneralInfo.gid2 > 0 and g_tr(g_data.general[info.oppGeneralInfo.gid2*100+1].general_name) or ""        
                strDesc = g_tr(skill.combat_info, {player=nick1, player1=nick2, name=oppGenName, player2=nick3,name1=oppGenName3, num=force, ifsuccess=g_tr("godGenWin")})
              end 

            elseif info.oppGeneralInfo.gid > 0 then --有武将时
              print("===@@@", g_tr(skill.combat_info))
              
              local batResult = info.oppGeneralInfo.flag and g_tr("godGenWin") or g_tr("godGenLost") 
              strDesc = g_tr(skill.combat_info, {player = nick1, player1 = nick2, name = oppGenName, num = force, ifsuccess = batResult})
            
            else --没有武将时
              local attrStr = info.gid == 10106 and "godGenTips" or "godGenTips2" --神关羽/神司马懿 对方没有武将
              strDesc = g_tr(attrStr, {player = nick1, num = force})              
            end 

          else --没有武将
            local attrStr = info.gid == 10106 and "godGenTips" or "godGenTips2" --神关羽/神司马懿 对方没有武将
            strDesc = g_tr(attrStr, {player = nick1, num = force})               
          end 

        elseif info.gid == 10110 then --神诸葛亮 
          strDesc = g_tr(skill.combat_info, {player = nick1, num = string.format("%.1f%%%%", info.para*100), num1 = info.num})

        elseif info.gid == 10098 then --神周瑜
          strDesc = g_tr(skill.combat_info, {player = nick1, num = string.format("%d",info.damage), num1 = info.num})

        elseif info.gid == 10089 then --神周泰
          local str = info.allDead and g_tr("godGenSoldierAllDie") or g_tr("godGenSoldierSurvive") 
          strDesc = g_tr(skill.combat_info, {player = nick1, num = string.format("%.1f%%%%", info.para*100), desc = str})

        elseif info.damage then --神孙策单独处理
          strDesc = g_tr(skill.combat_info, {player = nick1, num = force, damage = string.format("%d", info.damage)})
        
        else 
          strDesc = g_tr(skill.combat_info, {player = nick1, num = force})
        end 

        result.desc = strDesc 
      end 
    end 
  end 

  return result 
end 

function MailHelper:getDamageUnit(playerUnit)
  local unit = {}
  if playerUnit then 
    for k, v in pairs(playerUnit) do 
      if v.doDamage and v.takeDamage then 
        table.insert(unit, v)
      end 
    end 
  end 

  return unit 
end 

return MailHelper 
