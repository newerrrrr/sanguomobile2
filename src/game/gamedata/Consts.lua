--g_Consts
local constsMode = {}
setmetatable(constsMode,{__index = _G})
setfenv(1,constsMode)



Currency = {
  ["Money"] = 1,   --元宝
}

DropType = {
  Resource        = 1,  --资源(黄金、粮草、木材、石材、铁材、白银)
  Props           = 2,  --道具
  General         = 3,  --武将
  Equipment       = 4,  --装备.
  MasterEquipment = 7,  --主公宝物（主公装备）
  Soldier         = 8,  --士兵
  Trap            = 999,  --陷阱 （前端使用，数值段落没有这个）
}

--文本颜色
ColorType = {
  Normal =  cc.c4b(255,255,255,255),
  Red    =  cc.c4b(255,0,0,255),
  Green  =  cc.c4b(0,255,0,255),
  Blue   =  cc.c4b(0,0,255,255),
  Gray   =  cc.c4b(150,150,150,255),
}


--所有货币类型，与策划配置表中所填的CostType对应
--[[
1 黄金
2 粮食
3 木头
4 石材
5 铁块
6 白银
7 gem（元宝）
8 个人荣誉
9 体力
10 主公经验
11 联盟科技经验
12 联盟荣誉
13 锦囊
14 铜钱
15 勾玉
16 VIP点数
20 战勋
]]
AllCurrencyType = { 
  Gold = 1,
  Food = 2,
  Wood = 3,
  Stone = 4,
  Iron = 5,
  Silver = 6,
  Gem = 7,
  PlayerHonor = 8,
  Move = 9,
  PlayerExp = 10,
  AllianceTechExp = 11,
  AllianceHonor = 12,
  JinNang = 13,
  Coin = 14,
  Gouyu = 15,
  VipExp = 16,
  ZhanXun = 20,
  XuanTie = 21,
  JiangYin = 22, 
  JunZi = 23,
}



--长连接消息id
NetMsg = {
  ["LoginReq"]                = 10000, --登录
  ["LoginRsp"]                = 10001, 
  ["HeartBeatReq"]            = 10002, --心跳包
  ["HeartBeatRsp"]            = 10003,
  ["ServerPushReq"]           = 10004, --后台推送
  ["ServerPushRsp"]           = 10005,
  ["ChatSendReq"]             = 10008, --聊天
  ["ChatSendRsp"]             = 10009, 
  ["PauseServerHeartBeatReq"] = 10010, --请求是否将服务端心跳包检测暂停
}

--消耗道具分类
UseItemType = {
  ["Common"]  = 207, --通用  
  ["Build"]   = 208,  --建筑  
  ["Soldier"] = 209,--造兵 
  ["Health"]  = 210, --医疗  
  ["Study"]   = 211,  --研究  
  ["Quick"]   = 217,  --行军加速
  ["GuildQuick"] = 218, --联盟战行军加速
  ["MOVE"]    = 225,   --行动力药水  
  ["EXP"]     = 232,    --经验药水  
  ["Trap"]    = 235,   --陷阱
  ["GodGenerralExp"] = 512  --神武将经验药水
}

--行军种类：1.采集，2.打怪，3.出征，4.侦查，5.搬运资源
--行军类型
FightType = {
  ["Collect"]    = 1, --采集
  ["Monster"]    = 2, --打怪
  ["Expedition"] = 3, --出征，集结,制造联盟建筑,攻击资源，士兵支援
  ["Detect"]     = 4, --侦查
  ["MoveRes"]    = 5, --搬运资源
}

FightCostPowerType =
{
    CostSpy = 41,       --侦查
    CostCastle = 42,    --城池战
    CostCollect = 43,   --资源战或采集资源
    CostNpc = 44,       --打野外小怪
    CostTeam = 45,      --集结发起者行动力消耗
    CostAid = 46,       --协助驻防
    CostYuxi = 86,      --获取和氏璧行动力消耗
    CostJudian = 87,    --攻打据点行动力消耗
    CostNpcTeamAid = 88,--参与集结
    CostFree = 0
}

KingWarStatusType = {
  ["Ready"]        = 0,  --准备
  ["Fight"]        = 1,  --正在进行
  ["OverBilling"]  = 2,  --结束战斗结算
  ["Enthrone"]     = 3, --选举
  ["EnthroneOver"] = 4, --选举结束
}

--商城类型
ShopType = {
  ALLIANCE        = "shopTypeAlliance",--联盟商店进货
  ALLIANCE_PLAYER = "shopTypeAlliancePlayer", --联盟商店玩家
  NORMAL          = "shopTypeNormal",--普通商店
  MARKET          = "shopTypeMarket",
  PUB             = "shopTypePub" --对酒
}



--货币icon的起始Id 
--local costType = g_data.cost[10001].cost_type
--local iconId = g_Consts.CurrencyDefaultId + costType
--local iconPath = g_resManager.getResPath(iconId)
--imageView:loadTexture(iconPath)
CurrencyDefaultId     = 1999000

--联盟图标默认id
AllianceIconDefaultId = 1001


--用户事件枚举
CustomEvent = {
  NewMail       = 1,
  Chat          = 2,
  Guild_Help    = 3,
  Queue         = 4,
  PayResult     = 5,
  PlayerTarget  = 6,
  Item          = 7,
  Attacked      = 8,
  CloseTower    = 9,
  KingPoint     = 10,
  MerryGoRound  = 11,
  Money         = 12,
  GuildInvite   = 13,
  GuildAccept   = 14,
  GuildScience  = 15,
  PoorNetWork   = 16, 
  UpdateGenAttr = 17,
  GuildApply    = 18,
  GiudeTrigged  = 19, --成功触发了一步新手引导
  PkRecive      = 20, --武斗受到挑战
  NewbieShowTip = 21,
  GuildWarMapEvent = 22,--联盟战地图事件
  Pay = 23, --任何成功付费行为
  AnySdkUserActionResult = 24,--anysdk的UserAction事件接收
  AnySdkPayResult = 25,--anysdk的Pay事件接收
  DrawCardUpdateTip = 26, --更新观星台的红点
  CityBattleMapEvent = 27, --城战地图事件
}


--资源加速道具ID
ResAddSpeedItemId = {
  [g_PlayerBuildMode.m_BuildOriginType.gold] = 22403,
  [g_PlayerBuildMode.m_BuildOriginType.food] = 22404,
  [g_PlayerBuildMode.m_BuildOriginType.wood] = 22405,
  [g_PlayerBuildMode.m_BuildOriginType.stone] = 22406,
  [g_PlayerBuildMode.m_BuildOriginType.iron] = 22407,
}


--战斗脚本服务器可能的延迟时间
BattleScriptDelayTime    = 0.8


--UI上的通用资源显示优先级
resourcesInterfaceZOrder = 99

--排行榜类型
RankType = {
  ["alliencePower"]    = 1,
  ["allienceEnemyDie"] = 2,
  ["power"]            = 3,
  ["enemyDie"]         = 4,
  ["house"]            = 5,
  ["level"]            = 6,
}

--战力提升
--[[
训练步兵
训练骑兵
训练弓兵
训练车兵
建造陷阱
招募武将
装备升星
研究科技
激活天赋
配置宝物
升级建筑
搜索怪物
完成任务
]]--
PowerUpType = {
  ["trainInfantry"] = 1,
  ["trainCavalry"]  = 2,
  ["trainArcher"]   = 3,
  ["trainVehicles"] = 4,
  ["buildTrap"]     = 5,
  ["club"]          = 6,
  ["equipStarUp"]   = 7,
  ["science"]       = 8,
  ["talent"]        = 9,
  ["master"]        = 10,
  ["buildUp"]       = 11,
  ["fight"]         = 12,
  ["mission"]       = 13,
}

ItemPathType = {
  ["world"] = 1,
  ["compose"] = 2, --铁匠铺合成
  ["mofang"] = 3, --磨坊
  ["shop"] = 4,
  ["decompose"] = 5, --铁匠铺分解
  ["recast"] = 6, --铁匠铺重铸
  ["cornucopia"] = 8, --占星
  ["dayfall"] = 9, --天陨
  ["godCombine"] = 10,--神武将合成
  ["drink"] = 11, --对酒
  ["meritorious"] = 12,--功勋商店
  ["jitian"] = 13, --祭天
  ["rongLian"] = 14, --炼熔
  ["killBlame"]    = 100,
  ["allianceShop"] = 101, --联盟商店
  ["activity"]     = 102, --活动
  ["silkShop"]     = 103, --锦囊商店
  ["warShop"]     = 104, --战争商店
  ["cbShopLuoyang"]     = 201, --城战-洛阳商铺
  ["cbShopChengdu"]     = 202, --城战-成都商铺
  ["cbShopJianye"]     = 203, --城战-建业商铺
  ["cbShopXiangyang"]     = 204, --城战-襄阳商铺
}

BannerType={
  ["noActivity"] = 0,
  ["kill"] = 1,
  ["mission"] = 2,
  ["activity"] = 3,
  ["money"] = 4,
}

MapFindPointElementId = {
  ["HSB"] = 1901, --和氏璧
  ["JD"]  = 2001, --"据点"
}

SaveMarkType = {
  ["mark"]   = 0,    --标记
  ["friend"] = 1,  --朋友
  ["enemy"]  = 2,   --敌人
}

CountryType = {
  ["wei"] = 1,
  ["shu"] = 2,
  ["wu"] = 3,
  ["qun"] = 4,
}

CityBattleStatus = 
{
    NOT_START = -1,--比赛未开始
    SIGN_FIRST = 0,--诸侯报名
    SIGN_NORMAL = 1,--正常报名
    SELECT_PLAYER = 2,--筛选玩家中
    SELECT_PLAYER_FINISH = 3,--筛选玩家结束
    DOING = 4,--比赛中
    CLAC_REWARD = 5,--比赛发奖结算
    FINISH = 6,--比赛完成

}

return constsMode