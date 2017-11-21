g_isDebug = cToolsForLua:isDebugVersion()
g_gameTools = require("game.gametools.gameTools")
g_autoCallback = require("game.gametools.autoCallback")
g_gameManager = require("game.manager.gameManager")
g_sceneManager = require("game.manager.sceneManager")
g_musicManager = require("game.manager.musicManager")
g_resManager = require("game.manager.resManager")
g_requestManager = require("game.manager.requestManager")
g_timeManager = require("game.manager.timeManager")
g_sdkManager = require("game.manager.sdkManager")
g_netCommand = require("game.uilayer.base.NetCommand")
g_channelManager = require("game.manager.channelManager")
g_gameStateManager = require("game.manager.gameStateManager")
g_appStatusManager = require("game.manager.appStatusManager")

g_saveCache = require("game.gametools.saveCache")

--这两个是公用提示框,一个是确认框g_msgBox.show(...),一个是飘字g_airBox.show(...)
g_msgBox = require("game.msgboxlayer.msgBox")
g_airBox = require("game.msgboxlayer.airBox")

g_busyTip = require("game.msgboxlayer.busyTip")
--网络差提示动画
g_poorNetworkTip = require("game.msgboxlayer.poorNetworkTip")

g_PlayerMode = require("game.gamedata.playerData")
g_PlayerBuildMode = require("game.gamedata.playerBuild")

--general--
g_GeneralMode = require("game.gamedata.GeneralData")
--bag--
g_BagMode = require("game.gamedata.BagData")
--college--
g_StudyMode = require("game.gamedata.StudyData")
--xiaochang--
g_ArmyMode = require("game.gamedata.ArmyData")

g_ArmyUnitMode = require("game.gamedata.ArmyUnitData")
--soldier--
g_SoldierMode = require("game.gamedata.SoldierData")

g_PlayerHelpMode = require("game.gamedata.PlayerHelp")

g_EquipmentlMode = require("game.gamedata.EquipmentlData")
--主公宝物
g_MasterEquipMode = require("game.gamedata.MasterEquipData")
--主公天赋
g_MasterTalentMode = require("game.gamedata.MasterTalentData")

g_MasterSkillMode = require("game.gamedata.MasterSkillData")

g_ScienceMode = require("game.gamedata.scienceData")

g_PlayerPubMode = require("game.gamedata.PlayerPub")

g_AllianceMode = require("game.gamedata.Alliance")

g_PlayerSoldierInjuredMode = require("game.gamedata.InjuredSoldierData")
--地图收藏夹
g_MapCollectMode = require("game.gamedata.MapCollectData")

g_TaskMode = require("game.gamedata.TaskData")

g_Account = require("game.gamedata.Account")

--const
g_Consts = require("game.gamedata.Consts")
g_gameCommon = require("game.gametools.gameCommon")

g_MailMode = require("game.gamedata.MailData")
--陷阱
g_TrapMode = require("game.gamedata.TrapData")
--buff
g_BuffMode = require("game.gamedata.BuffData")

--资源通用
g_resourcesInterface = require("game.gametools.resourcesInterface")

--国王战info
g_kingInfo = require("game.gamedata.kingInfoData")

--引导
g_guideNodes = require("game.guidelayer.guideNodes")
g_guideData = require("game.guidedata.guideData")
g_guideManager = require("game.manager.guideManager")

g_playerShop = require("game.gamedata.playerShop")

g_chatData = require("game.gamedata.ChatData")

g_itemTips = require("game.gametools.itemTips")

g_shopMarketData = require("game.gamedata.ShopMarketData")

g_limitRewardData = require("game.gamedata.LimitRewardData")

g_moneyData = require("game.gamedata.MoneyData")

g_battleHallData = require("game.gamedata.BattleHallData")

g_playerInfoData = require("game.gamedata.playerInfoData")
--联盟任务数据
g_allianceMissionData = require("game.gamedata.AllianceMissionData")

g_actSevenDayTarget = require("game.gamedata.SevenDayTarget")

g_actSign = require("game.gamedata.SignData")

g_luckyDrawData = require("game.gamedata.LuckyDrawData")
--磨坊
g_millData = require("game.gamedata.millData")
--成长基金
g_playerGrownFundData =require("game.gamedata.playerGrownFundData")
--联盟留言
g_allianceCommentData = require("game.gamedata.allianceCommentData")
--转盘数据
g_zhuanPanData = require("game.gamedata.ZhuanPanData")

g_playerGuildData = require("game.gamedata.PlayerGuildData")

g_activityData = require("game.gamedata.ActivityData")

g_groundData = require("game.gamedata.GroundData")

g_wallData = require("game.gamedata.WallData")

g_corData = require("game.gamedata.CornucopiaData")

g_wallData = require("game.gamedata.WallData")

g_allianceManorData = require("game.gamedata.allianceManorData")

g_expeditionData = require("game.gamedata.expeditionData")

g_guildWarPlayerData = require("game.gamedata.guildWarPlayerData")

g_expeditionData = require("game.gamedata.expeditionData")

g_crossSoldier = require("game.gamedata.CrossSoldier")

g_crossGeneral = require("game.gamedata.CrossGeneral")

g_crossArmy = require("game.gamedata.CrossArmy")

g_crossArmyUnit= require("game.gamedata.CrossArmyUnit")

g_guildWarBattleInfoData = require("game.gamedata.guildWarBattleInfoData")

g_guildWarMapSpBuildData= require("game.gamedata.guildWarMapSpBuildData")

g_crossGuild = require("game.gamedata.CrossGuild")

g_crossPlayerMasterskill = require("game.gamedata.CrossPlayerMasterskill")

--城战
g_cityBattlePlayerData = require("game.gamedata.cityBattlePlayerData")

g_cityBattleSoldier = require("game.gamedata.CityBattleSoldier")

g_cityBattleGeneral = require("game.gamedata.CityBattleGeneral")

g_cityBattleArmy = require("game.gamedata.CityBattleArmy")

g_cityBattleArmyUnit= require("game.gamedata.CityBattleArmyUnit")

g_cityBattleInfoData = require("game.gamedata.cityBattleInfoData")

g_cityBattleMapSpBuildData= require("game.gamedata.cityBattleMapSpBuildData")

g_cityBattleCamp = require("game.gamedata.CityBattleCamp")

g_cityBattlePlayerMasterskill = require("game.gamedata.CityBattlePlayerMasterskill")

g_cityBattle_cross_ui_dataHelper = require("game.mapcitybattle.cityBattle_cross_ui_dataHelper")

g_cityBattleCamp = require("game.gamedata.CityBattleCamp")