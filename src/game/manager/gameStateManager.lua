local gameStateManager = {}
setmetatable(gameStateManager,{__index = _G})
setfenv(1,gameStateManager)

local m_FirstInGameFlag = false
local m_gameEnterTime 

function setFirstInGameFlag(var)
	m_FirstInGameFlag = var
end

function tryNoticeFirstInGame()
	if m_FirstInGameFlag then
		m_FirstInGameFlag = false
		onFirstInGameScene()
	end
end


--public


--第一次进入游戏场景的回调
function onFirstInGameScene()

--	dataType	Y	数据类型，1 为进入游戏，2 为创建角色，3 为角色升级，4 为退出
--	roleId	Y	角色 ID
--	roleName	Y	角色名称
--	roleLevel	Y	角色等级
--	zoneId	Y	服务器 ID
--	zoneName	Y	服务器名称
--	balance	Y	用户余额（RMB 购买的游戏币）
--	partyName	Y	帮派、公会等
--	vipLevel	Y	VIP 等级
--	roleCTime	Y	角色创建时间（单位：秒）（历史角色没记录时间的传 -1，新创建的角色必须要）
--	roleLevelMTime	Y	角色等级变化时间（单位：秒）（创建角色和进入游戏时传 -1）

	do --sdk登录角色信息 数据类型，1 为进入游戏，2 为创建角色，3 为角色升级，4 为退出
		g_sdkManager.addPlayerInfo(1)
	end
	
	
	if g_guideManager.getLastShowStep() then --是否有新手引导
		
		--迁城提示
		require("game.uilayer.recast.recastView").checkShowForInGame_haveGuide()
		
	else
			--如果聯盟戰期間 強制進入聯盟戰戰場
--		if g_activityData.GetCrossState() then
--			require("game.mapguildwar.changeMapScene").changeToWorld()
--			return
--		end
		
		--1.主城被攻击提示 
		if require("game.uilayer.mail.MailHelper"):instance():isAttackedWhenOffline() then 
			g_sceneManager.addNodeForUI(require("game.uilayer.mail.AttackedNotice").new()) 
		end 
		
		
		--7日新手目标
		--g_actSevenDayTarget.RequestSycData()

		
		local data = g_activityData.ShowBanner()
		--显示活动
		if data == g_Consts.BannerType.kill then
			g_sceneManager.addNodeForUI(require("game.uilayer.activity.activityBanner.ActivityBanner").new(1002))
		elseif data == g_Consts.BannerType.mission then
			g_sceneManager.addNodeForUI(require("game.uilayer.activity.activityBanner.ActivityBanner").new(1003))
		elseif data == g_Consts.BannerType.activity then
			g_sceneManager.addNodeForUI(require("game.uilayer.activity.activityBanner.ActBannerView").new())
		elseif data == g_Consts.BannerType.money then
			g_sceneManager.addNodeForUI(require("game.uilayer.money.BannerView").new())
		end
		
		--迁城提示
		require("game.uilayer.recast.recastView").checkShowForInGame_notGuide()

		--4/5 跨服战活动开启后，符合报名的盟主，在上线受到一个弹窗通知
		local crossData = g_activityData.GetCrossBasicInfo()
		if crossData and crossData.current_guild_info ~= nil and crossData.current_guild_info.first_king_status ~= 0 
			and crossData.current_guild_info.round_status == 0 and crossData.current_guild_info.guild_status == 0 and g_AllianceMode.isAllianceManager() then
			g_msgBox.show( g_tr("directAssign", {val = crossData.current_guild_info.current_round_id}),nil,nil,
						function ( eventtype )
								--确定
								if eventtype == 0 then 
									require("game.uilayer.activity.ActivityMainLayer").show(1025)
								end
						end , 1)
		end
		
		--神将下凡活动
		if require("game.uilayer.activity.firstpay.ActivityFirstPayLayer").isOpen() then
			g_sceneManager.addNodeForUI(require("game.uilayer.activity.firstpay.ActivityFirstPayBannerLayer"):create())
		end
	end
	
	g_BuffMode.RequestAllGeneralBuffData(true)
	
	if g_AllianceMode.isAllianceManager() then
				g_allianceManorData.RequestDataAsync() 
	end

	--记录第一次登录的战力和时间
	local time = g_saveCache["first_time_save"]
	local time1 = os.time()
	
	if not g_clock.isSameDay(time,time1) then
			g_saveCache["first_time_save"] = math.max(time,time1)
			g_saveCache["first_power_save"] = g_PlayerMode.GetData().power
	end
	
	local isZhcnGame = require("localization.langConfig").getCountryCode() == "zhcn"
	if isZhcnGame then
		--防沉迷提示
		initAntiAddictionNotice()
	end

	--充值满5000提示
	require("game.uilayer.common.ChargeTipOnce"):check() 
end


--防沉迷弹框(2小时提示一次)
function initAntiAddictionNotice()
  if nil == m_gameEnterTime then 
    m_gameEnterTime = g_clock.getCurServerTime() 
  end 

  local gap = 2*3600 
  local elapse = g_clock.getCurServerTime() - m_gameEnterTime 
  local nextSec = gap - elapse%(gap) 

  local function showAntiAddictionTips()
  	elapse = g_clock.getCurServerTime() - m_gameEnterTime 
    local hours = 2 * math.round(elapse/gap)
    if hours == 2 or hours == 4 or hours == 8 then --只弹 2,4,8小时
    	if not g_guideManager.getLastShowStep() then --无新手引导时才允许弹框
    		g_msgBox.show( g_tr("AntiAddictionTips", {num = hours}), g_tr("AntiAddictionTitle"),nil,nil) 
    	end 
    end 

	  if hours < 8 then 
		  nextSec = gap - elapse%(gap) 
		  g_autoCallback.addCocosList(showAntiAddictionTips, nextSec) 
		end 
  end 
  g_autoCallback.removeCocosList(showAntiAddictionTips)
  g_autoCallback.addCocosList(showAntiAddictionTips, nextSec) 
end 



return gameStateManager