local loadingFunc = {}
setmetatable(loadingFunc,{__index = _G})
setfenv(1,loadingFunc)



--在这里面加入进主城以前需要调用的函数
--注意:
--自己写自己的函数,名字不重复就行
--每个函数都要做到可以重复调用,因为如果失败,可能会再次尝试调用
--函数中的执行必须是同步,不能用任何异步调用
--函数中不要做任何计算操作,只允许做请求消息写入缓存,或者加载某些特定资源
--函数必须返回一个bool值,成功true失败false
--有任何一个调用结果为false都将阻止玩家进入游戏




function ntpServerTime()
	return g_clock.ntpServerTime()
end

--合并loading请求接口
--如果要使用这个接口，请务必在g_requestManager 里面的onRequestComboAutoUpdate方法里面注册相应的处理
--参数说明： url为接口，field为参数
function requestCombo() --使用前先看上面的注释，务必！！务必！！务必
  local list = 
  {
      {url ="King/getInfo",field = {}},
      {url ="Guild/comboGuildMemberInfo",field = {}},
      {url ="Lottery/checkPlayerLotteryInfo",field = {}},
      {url ="limit_match/showLimitMatch",field = {}},
      {url ="Player/getBuff",field = {}},
      {url ="Mail/getList",field = {type=g_MailMode.getPreReqMailTypeWhenEnter(), direction=0, id=0}},
      {url ="Mail/getUnread", field = {}},
      -- {url ="common/comboChat", field = {}},
      {url ="common/lastWorldChatMsg", field = {}},
  }   
  return g_requestManager.RequestCombo(list)
end

function requestDataIndex()
  local list = 
    {
      "Player",
      "PlayerBuild",
      "PlayerMission",
      "PlayerArmyUnit",
      "PlayerItem",
      "PlayerSoldier",
      "PlayerArmy",
      "PlayerHelp",
      "PlayerOnlineAward",
      "PlayerInfo",
      "PlayerSignAward",
      "PlayerTarget",
      "PlayerMasterSkill",
      "PlayerTalent",
      "PlayerEquipMaster",
      "PlayerMill",
      "PlayerSoldierInjured",
      "PlayerGrowth",
      "PlayerGeneral",
      "PlayerScience",
      "PlayerEquipment",
      "PlayerNewbieActivityLogin",
      "PlayerNewbieActivityCharge",
      "PlayerNewbieActivityConsume",
      "PlayerShop",
    }
  return g_requestManager.RequestDataIndex(list)
end

--function requestPlayer()
--	return g_PlayerMode.RequestData()
--end


--function requestPlayerBuild()
--	return g_PlayerBuildMode.RequestData()
--end

--function requestAlliance()
--  return g_AllianceMode.reqAllAllianceData()
--end

--function requestTask()
--  return g_TaskMode.reqBaseData()
--end

--连接net服务器
function connectNetServer()
  local userCode = g_Account.getLoginUserCode()
  if userCode and userCode ~= "" then
     return true
  end
  g_gameCommon.sgNetInit()
  return true 
end

--function requestArmyUnit()
--    return g_ArmyUnitMode.RequestData()
--end

--function requestBag()
--	return g_BagMode.RequestData()
--end

--function requestSoldier()
--    return g_SoldierMode.RequestData()
--end

--function requestArmy()
--    return g_ArmyMode.RequestData()
--end

--function requestKingInfo()
--    return g_kingInfo.RequestData()
--end

--function requestPlayerHelp()
--    return g_PlayerHelpMode.RequestData()
--end

--限时奖励活动
--function requestLimitRewardInfo()
--    return g_limitRewardData.RequestData()
--end

--function requestPlayerInfo()
--    return g_playerInfoData.RequestData()
--end

--function requestActivityInfo()
--	return g_activityData.RequestData()
--end

function RequestActivityGiftInfo()
	return g_activityData.RequestGiftList()
end

--function requestSign()
--	return g_actSign.RequestData()
--end

--function requestSevenTarget()
--	return g_actSevenDayTarget.RequestData()
--end

--function requestSkill()
--    return g_MasterSkillMode.RequestData()
--end

--function requestZhuanPan()
--    return g_zhuanPanData.RequestData()
--end

--function requestTalent()
--    return g_MasterTalentMode.RequestData()
--end

--function requestMasterEquipment()
--    return g_MasterEquipMode.RequestData()
--end

function SendNotificationClientID()
	local platform = cc.Application:getInstance():getTargetPlatform()
	if platform == cc.PLATFORM_OS_ANDROID then
		local cid = g_sdkManager.getGeTuiClientId()
		if cid and type(cid) == "string" and cid ~= "" then
			local function onRecv(result, msgData)
				if result == true then
					cToolsForLua:setBadge(0)
				end
			end
			g_sgHttp.postData("player/updateClientId", { clientId = cid , deviceToken = "" , deviceType = 2 }, onRecv)
		end
	elseif platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD then
		--local cid = cTools_getNotificationClientid()
        local cid = g_sdkManager.getGeTuiClientId()
		local token = cTools_getNotificationDeviceToken()
		if cid and type(cid) == "string" and cid ~= "" then
			local function onRecv(result, msgData)
				if result == true then
					cToolsForLua:setBadge(0)
				end
			end
			g_sgHttp.postData("player/updateClientId", { clientId = cid , deviceToken = (token and token or "") , deviceType = 1 }, onRecv)
		end
	end
	return true
end

function initGuide()
    --初始化新手引导步骤，用服务器记录的id传入
    g_guideData.setCurrentGuideInfoById(g_guideData.getCurrentServerStepId())
    g_guideData.setServerOutOfOrderGuideInfo(g_guideData.getSavedOutOfOrderStepIds())
    return true
end

function loadingMapRes_1()
	cc.SpriteFrameCache:getInstance():addSpriteFrames("homeImage/homeImage.plist","homeImage/homeImage.png")
	return true
end

function loadingMapRes_2()
	cc.SpriteFrameCache:getInstance():addSpriteFrames("animeFps/city/city.plist","animeFps/city/city.png")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("animeFps/city/city_move.plist","animeFps/city/city_move.png")
	return true
end

function loadingWorldRes_1()
	cc.SpriteFrameCache:getInstance():addSpriteFrames("worldmap/worldmap_image.plist","worldmap/worldmap_image.png")
	return true
end

function loadingWorldRes_2()
	local textureCache = cc.Director:getInstance():getTextureCache()
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	for index = 1, 3, 1  do		--预加载前3张
		local textureName = string.format("worldmap/map_build_%d.png",index)
		if textureCache:addImage(textureName) then
			local plistName = string.format("worldmap/map_build_%d.plist",index)
			spriteFrameCache:addSpriteFrames(plistName,textureName)
		else
			break
		end
	end
	return true
end

function loadingWorldRes_3()
	local textureCache = cc.Director:getInstance():getTextureCache()
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	for index = 4, 6, 1  do		--预加载4-6张
		local textureName = string.format("worldmap/map_build_%d.png",index)
		if textureCache:addImage(textureName) then
			local plistName = string.format("worldmap/map_build_%d.plist",index)
			spriteFrameCache:addSpriteFrames(plistName,textureName)
		else
			break
		end
	end
	return true
end

function loadingWorldRes_4()
	local textureCache = cc.Director:getInstance():getTextureCache()
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	for index = 7, 10, 1  do		--预加载7-10张
		local textureName = string.format("worldmap/map_build_%d.png",index)
		if textureCache:addImage(textureName) then
			local plistName = string.format("worldmap/map_build_%d.plist",index)
			spriteFrameCache:addSpriteFrames(plistName,textureName)
		else
			break
		end
	end
	return true
end

function loadingWorldRes_5()
	local textureCache = cc.Director:getInstance():getTextureCache()
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	for index = 1, 3, 1  do	--预加载前3张
		local textureName = string.format("animeFps/battle/battle_%d.png",index)
		if textureCache:addImage(textureName) then
			local plistName = string.format("animeFps/battle/battle_%d.plist",index)
			spriteFrameCache:addSpriteFrames(plistName,textureName)
		else
			break
		end
	end
	return true
end

function loadingWorldRes_6()
	local textureCache = cc.Director:getInstance():getTextureCache()
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	for index = 4, 6, 1  do	--预加载4-6张
		local textureName = string.format("animeFps/battle/battle_%d.png",index)
		if textureCache:addImage(textureName) then
			local plistName = string.format("animeFps/battle/battle_%d.plist",index)
			spriteFrameCache:addSpriteFrames(plistName,textureName)
		else
			break
		end
	end
	return true
end

function loadingWorldRes_7()
	local textureCache = cc.Director:getInstance():getTextureCache()
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	for index = 7, 10, 1  do	--预加载7-10张
		local textureName = string.format("animeFps/battle/battle_%d.png",index)
		if textureCache:addImage(textureName) then
			local plistName = string.format("animeFps/battle/battle_%d.plist",index)
			spriteFrameCache:addSpriteFrames(plistName,textureName)
		else
			break
		end
	end
	return true
end

--function requestMillData()
--    return g_millData.RequestData()
--end

--function requestPlayerBuffData()
--    return g_BuffMode.RequestData()
--end

--function requestAllGeneralBuffData()
--    g_BuffMode.RequestAllGeneralBuffData()
--    return true
--end

--function requestInjuredSoldierData()
--    return g_PlayerSoldierInjuredMode.requestData()
--end

--function requestGrownFundData()
--    return g_playerGrownFundData.RequestData()
--end

--function requestGeneralData()
--    return g_GeneralMode.RequestData()
--end

--function requestTimeLimitMatchData()
--    return require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").RequestData()
--end

-- function requestChatData()
--     return g_chatData.RequestAllData(false)
-- end

-- function requestMailData()
--     return g_MailMode.preLoadMailDataWhenEnter()
-- end

--function requestScienceData()
--    return g_ScienceMode.RequestData() 
--end

--function requestEquipmentData() 
--    return g_EquipmentlMode.RequestData() 
--end 

--function requestAllianceManorData() 
--    --聯盟管理者需要預加載聯盟領地數據
--    if g_AllianceMode.isAllianceManager() then
--        return g_allianceManorData.RequestData() 
--    end
--    return true
--end 

return loadingFunc
