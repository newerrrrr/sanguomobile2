local ActivityMainLayer = class("ActivityMainLayer",require("game.uilayer.base.BaseLayer"))

local openList = nil

--打开指定的活动页面
function ActivityMainLayer.show(activityId,para)
	local isVaild = require("game.uilayer.activity.ActivityMainLayer").checkIsVaildActivity(activityId)
	if not isVaild then
		return g_airBox.show(g_tr("activityNotVaild"))
	end
	
	local activityType = g_data.activity[activityId].path_type
	g_sceneManager.addNodeForUI(ActivityMainLayer:create(activityType,activityId,para))
end

--在这里添加具体的活动页面
function ActivityMainLayer:createSubActivityLayer(activityServerInfo, para)

	--{"id":1,"activity_name":0,"activity_id":1003,"activity_para":"[]","show_time":1466524800,"start_time":1466524800,"end_time":1466783999,"calculate_reward":0,"create_time":0}
	local activityId = activityServerInfo.activity_id
	--activityId = 1001
	print("activityId:",activityId)
	local layer = nil
	if activityId == 1002 then
		layer = require("game.uilayer.activity.timelimitmatch.ActivityTimeLimitMatch"):create()
	elseif activityId == 1003 then --联盟任务
		layer = require("game.uilayer.activity.allianceMission.ActivityAllianceMission"):create(self, para)
	elseif activityId == 1007 then
		layer = require("game.uilayer.activity.sevenTarget.actSevenDayView").new(handler(self, self.close))
		g_guideManager.execute()
	elseif activityId == 1008 then --喜迎财神
		layer = require("game.uilayer.activity.luckyDraw.ActivityLuckyDrawView").new()
	elseif activityId == 1009 then --大富翁
		layer = require("game.uilayer.activity.activityZhuanPan.ActivityZhuanPanLayer"):create()
	elseif activityId == 1010 then --成长基金
		layer = require("game.uilayer.activity.fund.ActivityFundLayer"):create()
	elseif activityId == 1011 then
		layer = require("game.uilayer.activity.monthcard.MonthCard").new()
	elseif activityId == 1099 then
		layer = require("game.uilayer.activity.activityMoney.activity_moneyView").new()
	elseif activityId == 1016 then --facebook 分享
		layer = require("game.uilayer.activity.share.ShareLayer").new()
	elseif activityId == 1017 then --累计登陆
		layer = require("game.uilayer.activity.loginReward.LoginRewardView").new()
	elseif activityId == 1018 then --累计充值
		layer = require("game.uilayer.activity.activityMoney.MoreChargeView").new()
	elseif activityId == 1019 then
		layer = require("game.uilayer.activity.activityDrop.ActDropView").new()
	elseif activityId == 1021 then
		layer = require("game.uilayer.activity.activityKingWar.ActivityKingWarLayer"):create()
	elseif activityId == 1022 then
		layer = require("game.uilayer.activity.activityWaste.WaistView").new()
	elseif activityId == 1023 then
		layer = require("game.uilayer.activity.wheel.WheelView").new()
	elseif activityId == 1025 then
		layer = require("game.uilayer.activity.crossServer.MatchView").new(handler(self, self.close))
	elseif activityId == 1026 then
		layer = require("game.uilayer.activity.activityExchange.exchangeMain"):create()
	elseif activityId == 1027 then
		layer = require("game.uilayer.activity.panic.PanicView").new()
	elseif activityId == 1028 then
		layer = require("game.uilayer.activity.activityJiTian.jiTianMain"):create()
    elseif activityId == 1029 then
        layer = require("game.uilayer.activity.activityCityBattle.ActivityCitiyBattleMain"):create()
	elseif activityId == 2004 then
		layer = require("game.uilayer.activity.firstpay.ActivityFirstPayLayer"):create()
	elseif activityId == 2001 then 
		layer = require("game.uilayer.activity.activityServer.NewbieLogin").new(1)
	elseif activityId == 2002 then
		layer = require("game.uilayer.activity.activityServer.NewbieLogin").new(2)
	elseif activityId == 2003 then
		layer = require("game.uilayer.activity.activityServer.NewbieCost").new()
	--elseif activityId == 2005 then --活动已经永久关闭
		--if require("localization.langConfig").getCountryCode() == "zhcn" then
			--layer = require("game.uilayer.activity.activityRebate.rebateMain"):create()
		--end
	elseif activityId == 1030 then --限定活动(日本通活动)
		layer = require("game.uilayer.activity.activityAreaLimit.ActivityAreaLimitView"):create()

	elseif activityId == 1031 then --蓬莱礼包
		layer = require("game.uilayer.activity.activityPenglaiGift.ActivityPenglaiGiftView").create()
	elseif activityId == 1032 then --箭术大赛
		layer = require("game.uilayer.activity.activityArrowMatch.activityArrowMatchView").create()		
	end

	return layer
end

--在这里添加具体活动的提示信息
--列表标签是否显示new
local isNewByActivityId = function(activityId) --new 的图标
	local isNew = false
	if activityId == 1002 then --限时比赛
		isNew = require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").isNew()
	elseif activityId == 1003 then --联盟任务
		isNew = require("game.uilayer.activity.allianceMission.AllianceMissionMode"):hasNewMission()	
	end
	
	return isNew
end

--列表标签是否显示红点
local isTipByActivityId = function(activityId) --红点的图标
	local isTip = false
	if activityId == 1008 then --喜迎财神
		isTip = require("game.uilayer.activity.luckyDraw.ActivityLuckyDrawMode"):instance():canDrawMoney()
	elseif activityId == 1010 then --成长基金
		if g_playerGrownFundData.GetData() and not g_playerGrownFundData.isFinished() then
			isTip = (not g_playerGrownFundData.checkIsBuy()) or g_playerGrownFundData.checkIsHaveAward()
		end
	elseif activityId == 1009 then --大富翁
		isTip = require("game.uilayer.activity.activityZhuanPan.ActivityZhuanPanLayer").redPointShow()
	elseif activityId == 1011 then
		isTip = g_moneyData.cardShow()
	elseif activityId == 1099 then
		isTip = g_moneyData.giftNew()
	elseif activityId == 1007 then
		isTip = g_actSevenDayTarget.getResult()
	elseif activityId == 1016 then --facebook分享
		isTip = tonumber(g_playerInfoData.GetData().facebook_share_count) == 0
	elseif activityId == 1023 then
		if g_BagMode.findItemNumberById(52003) > 0 then
			isTip = true
		end
	end

	return isTip
end

ActivityMainLayer.updateActivityOpenList = function()
	 openList = clone(g_activityData.GetData())
	 if g_playerInfoData.IsOpen() then --7天发展任务
		table.insert(openList,{activity_id = 1007})
	 end
	 
--	 if g_luckyDrawData.IsOpen() then --喜迎财神
--		table.insert(openList,{activity_id = 1008})
--	 end

	 --神将降临（首充活动）
	 if require("game.uilayer.activity.firstpay.ActivityFirstPayLayer").isOpen() then
		table.insert(openList,{activity_id = 2004})
	 end

	 if g_activityData.ShowNewbieIcon() == true then
		table.insert(openList,{activity_id = 2001})
		table.insert(openList,{activity_id = 2002})
		table.insert(openList,{activity_id = 2003})
	 end

	 --充值返利（活动已经永久关闭）
	 --if require("localization.langConfig").getCountryCode() == "zhcn" then
		--table.insert(openList,{activity_id = 2005})
	 --end
	
	 for key, var in pairs(g_data.activity) do
		if var.date_type == 1 then --永久性活动
			local needShow = true
			
			if var.id == 1010 then --成长基金
				needShow = not g_playerGrownFundData.isFinished()
			elseif var.id == 1016 then --facebook分享
				needShow = require("localization.langConfig").getCountryCode() ~= "zhcn"
			end
		
			if needShow then
				table.insert(openList,{activity_id = var.id})
			end
		end
	 end
	 
	 if openList then
		table.sort(openList,function(a,b)
		 return g_data.activity[a.activity_id].show_order < g_data.activity[b.activity_id].show_order
		end)
	 end
end

ActivityMainLayer.getOpenListByActivityType = function(activityType)
	ActivityMainLayer.updateActivityOpenList()
	local list = {}
	for key, var in pairs(openList) do
		if g_data.activity[var.activity_id].path_type == activityType then
			table.insert(list,var)
		end
	end
	return list
end

local reqActivityOpenList = function()
	--需要显示的活动
	g_activityData.RequestDataAsync()
end


function ActivityMainLayer.checkIsVaildActivity(activityId)
	local isVaild = false
	local list = ActivityMainLayer.getOpenList()
	for key, var in ipairs(list) do
		if tonumber(var.activity_id) == activityId then
			isVaild = true 
			break
		end
	end
	return isVaild
end

function ActivityMainLayer.getOpenList()
	if openList == nil then
	 reqActivityOpenList()
	end
	
	if openList == nil then
		return {}
	end
	
	return openList
end

--活动模块是否有新的提示信息
function ActivityMainLayer.checkIsHaveTip(activityType)
	local haveTip = false
	
	if activityType == nil then --默认普通活动
		activityType = g_activityData.ActivityType.Normal
	end
	
	if openList == nil then
	 reqActivityOpenList()
	end
	
	if openList then
		for key, var in ipairs(openList) do
				if g_data.activity[var.activity_id].path_type == activityType then
				if isTipByActivityId(var.activity_id) or isNewByActivityId(var.activity_id) then
					haveTip = true
					break
				end
			end
		end
	end
	return haveTip
end

function ActivityMainLayer.getActivityCacheTag(activityId)
	assert(activityId)
	local activityCacheTag = g_PlayerMode.GetData().user_code.."_activity_"
	return activityCacheTag..activityId
end

function ActivityMainLayer.getServerOpenInfoByActivityId(activityId)
	local serverInfo = nil
	if openList == nil then
	 reqActivityOpenList()
	end
	
	if openList then
		for key, var in ipairs(openList) do
			if var.activity_id == activityId then
				serverInfo = var
				break
			end
		end
	end
	
	--{"id":1,"activity_name":0,"activity_id":1003,"activity_para":"[]","show_time":1466524800,"start_time":1466524800,"end_time":1466783999,"calculate_reward":0,"create_time":0}
	return serverInfo
end

function ActivityMainLayer:ctor(activityType,activityId,para)
	ActivityMainLayer.super.ctor(self)
	
	self._activityType = activityType
	
	local uiLayer =g_gameTools.LoadCocosUI("activity_main.csb",5)
	self:addChild(uiLayer)
	g_resourcesInterface.installResources(uiLayer)
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	local closeBtn = baseNode:getChildByName("Button_x")
	closeBtn:setTouchEnabled(true)
	closeBtn:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			g_activityData.SetInActivity(false)
			self:close()
		end
	end)
	
	g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.ACTIVITY)
	
	baseNode:getChildByName("Text_49"):setString(g_tr("activityTitleStr0"))
	if self._activityType > 0 then
		baseNode:getChildByName("Text_49"):setString(g_tr("activityTitleStr"..self._activityType))
	end	
	
	local leftListView = baseNode:getChildByName("ListView_2")
	self._leftListView = leftListView
 
	local function listViewEvent(sender, eventType)
		if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			print("touched:",sender:getCurSelectedIndex())
			self:changePage(sender:getCurSelectedIndex() + 1)
		end
	end
	leftListView:addEventListener(listViewEvent)

	local timeTable = g_clock.getCurServerTime(true)

	print("sever day now: yy--mm--dd", timeTable.year,timeTable.month,timeTable.day)
	print("sever time now:currentTime hh-mm-ss:",timeTable.hour,timeTable.min,timeTable.sec)

	--local currentDay = timeTable.year * 10000 + timeTable.month * 100 + timeTable.day
	
	if activityId then
		self._defaultGotoPageParams = {}
		self._defaultGotoPageParams.activityId = activityId
		self._defaultGotoPageParams.para = para
	end
	
	self._inited = false
end

function ActivityMainLayer:onEnter()
	
	local initLayerHandler = function(result, msgData)
		g_busyTip.hide_1()
		ActivityMainLayer.updateActivityOpenList()
		--显示
		local itemModel = cc.CSLoader:createNode("activity_parts.csb")
		itemModel:getChildByName("Image_1"):setTouchEnabled(true)
		
		local currentOpenList = {}

		dump(openList, "=== origin openList")
		do
		if openList then
				for key, var in ipairs(openList) do
					local needShow = false
					local config = g_data.activity[var.activity_id]
					if self._activityType == g_activityData.ActivityType.All then
						needShow = true
					else
						needShow = config.path_type == self._activityType
					end

					if var.status and var.status == 0 then 
						needShow = false 
					end 

					if needShow then
						table.insert(currentOpenList,var)
						local item = itemModel:clone()
						self._leftListView:pushBackCustomItem(item)
						
						item:getChildByName("Text_1"):enableOutline(cc.c4b(0, 0, 0,255),1)
						item:getChildByName("Text_1"):setString(g_tr(config.activity_name))
						item:getChildByName("Image_2"):setVisible(false)
						item:getChildByName("Image_huodong"):loadTexture(g_resManager.getResPath(config.type_icon))
						item:getChildByName("Image_3"):setVisible(isTipByActivityId(var.activity_id))
						item:getChildByName("Image_4"):setVisible(isNewByActivityId(var.activity_id))
					end
			 end
		 end
		end
		
		self._activitiesToShow = currentOpenList
		
		self._showPanel = self._baseNode:getChildByName("container")
		
		self._changePageIdx = 1
		
		self._inited = true
		
		if self._defaultGotoPageParams then
			self:doGotoPage(self._defaultGotoPageParams)
		else
			if openList and #openList > 0 then
				self:changePage(self._changePageIdx,true)
			end
		end
	end

	g_busyTip.show_1()
	g_activityData.RequestDataAsync(initLayerHandler)
	
	--for test 打开所有活动入口
	--[[do
		openList = {}
		for key, var in pairs(g_data.activity) do
			table.insert(openList,{activity_id = var.id,start_time = 0, end_time = 0})
		end
	end]]
	
	
end

function ActivityMainLayer:changePage(idx,forceFefresh, para)

	if self._changePageIdx == idx and not forceFefresh then
		return 
	end
	
	if #self._activitiesToShow <= 0 then
		return
	end
	
	self._changePageIdx = idx
	
	local items = self._leftListView:getItems()
	for key, item in ipairs(items) do
		item:getChildByName("Image_2"):setVisible(false)
	end
	
	local item = items[self._changePageIdx]
	item:getChildByName("Image_2"):setVisible(true)
	self._showPanel:removeAllChildren()
	
	local activityServerInfo = self._activitiesToShow[self._changePageIdx]
	local layer = self:createSubActivityLayer(activityServerInfo, para)
	if layer then
		self._showPanel:addChild(layer)
	end
	
	--更新标签红点/new
	item:getChildByName("Image_3"):setVisible(isTipByActivityId(activityServerInfo.activity_id))
	item:getChildByName("Image_4"):setVisible(isNewByActivityId(activityServerInfo.activity_id))
	
end

--请使用show方法
--function ActivityMainLayer:gotoPageByActivityId(activityId, para)
--	
--	self._defaultGotoPageParams = {}
--	self._defaultGotoPageParams.activityId = activityId
--	self._defaultGotoPageParams.para = para
--	
--	if self._inited == true then
--		self:doGotoPage(self._defaultGotoPageParams)
--	end 
--end

function ActivityMainLayer:doGotoPage(defaultGotoPageParams)
	if defaultGotoPageParams == nil then
		return
	end

	local activityId = defaultGotoPageParams.activityId
	local para = defaultGotoPageParams.para
	
--	if not ActivityMainLayer.checkIsVaildActivity(activityId) then
--		g_airBox.show(g_tr("activityNotVaild"))
--		return
--	end
	
	local idx = 0
	local percent = 0
	for key, var in ipairs(self._activitiesToShow) do
		if tonumber(var.activity_id) == activityId then
		 idx = key
		 percent = (key-1)/#self._activitiesToShow*100
		 break
		end
	end
 
	if idx > 0 then
		self:changePage(idx, true, para)
		if idx > 4 then
			self._leftListView:forceDoLayout() 
		end
		self._leftListView:jumpToPercentVertical(percent)
	end
end


return ActivityMainLayer