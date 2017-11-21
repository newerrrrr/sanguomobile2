local FightPrepare = class("FightPrepare",function()
	return cc.Layer:create()
end)

--武将和位置是否发生过变化
local isPositionChanged = function(targetBattleStatusInfo)
	local exditionData = g_expeditionData.GetData()
	local onBattleStatusInfo =	
	{
		["1"] = exditionData.general_1,
		["2"] = exditionData.general_2,
		["3"] = exditionData.general_3
	}
	
	local isChanged = false
	for key, var in pairs(onBattleStatusInfo) do
		 if var ~= targetBattleStatusInfo[key] then
			 isChanged = true
			 break
		 end
	end
	
	return isChanged
end

--是不是3个位置都已经上了武将
local checkPosIsFull = function(targetBattleStatusInfo)
	local isVaildData = true
	if targetBattleStatusInfo["1"] == nil or targetBattleStatusInfo["1"] == 0 
	or targetBattleStatusInfo["2"] == nil or targetBattleStatusInfo["2"] == 0 
	or targetBattleStatusInfo["3"] == nil or targetBattleStatusInfo["3"] == 0 
	then
		isVaildData = false
	end
	return isVaildData
end

--保存上阵信息
local savePosition = function(targetBattleStatusInfo,callback)
	if not checkPosIsFull(targetBattleStatusInfo) then
		 g_airBox.show(g_tr("peripheral_prepare_general_error"))
		 return 
	end


	if isPositionChanged(targetBattleStatusInfo) then
		local function onRecv(result, msgData)
			g_busyTip.hide_1()
			if result == true then
				 if callback then
					callback()
				 end
			end
		end
		local general1 = targetBattleStatusInfo["1"] or 0
		local general2 = targetBattleStatusInfo["2"] or 0
		local general3 = targetBattleStatusInfo["3"] or 0
		g_busyTip.show_1()
		g_sgHttp.postData("pk/pkPosition",{general_1 = general1,general_2 = general2,general_3 = general3 ,steps = g_guideManager.getToSaveStepId()},onRecv,true)
	else
		if callback then
			callback()
		end
	end
end

--打开武斗场界面
function FightPrepare.show()
	--open condition
	local conditionBuildConfigId = tonumber(g_data.starting[97].data)
	local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(conditionBuildConfigId)
	if enoughCount > 0 then
		local needNum = tonumber(g_data.starting[99].data) --需要拥有的武将数量
		local num = table.nums(g_GeneralMode.getOwnedGenerals())
		if num < needNum then
			g_airBox.show(g_tr("openWuDouConditionGeneral",{cnt = needNum}))
		else
			g_sceneManager.addNodeForUI(FightPrepare:create())
		end
	else
		local buildInfo = g_data.build[conditionBuildConfigId]
		if buildInfo then
			g_airBox.show(g_tr("openWuDouCondition",{build_name = g_tr(buildInfo.build_name),build_lv = buildInfo.build_level}))
		end
	end
end

function FightPrepare:ctor()
		
	self._isPosing = false
	
	g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.TOURNAMENT)
	self:registerScriptHandler(function(eventType)
		if eventType == "enter" then
			g_expeditionData.SetView(self)
			local exditionData = g_expeditionData.GetData()
			if exditionData == nil then
				g_busyTip.show_1()
				g_expeditionData.RequestDataAsync(function(result, msgData)
					g_busyTip.hide_1()
					local view = g_expeditionData.GetView()
					if view then
						if result then
							view:init()
						else
							view:removeFromParent()
						end
					end
				end)
			else
				local awardExecTime = exditionData.award_exec_date
				local nextAwardExecTime = awardExecTime + 60 * 60 * 24
				local awardNeedUpdate = awardExecTime > 0 and nextAwardExecTime < g_clock.getCurServerTime()
				
				local dailyResetTime = exditionData.daily_reset_exec_date
				local nextDailyResetTime = dailyResetTime + 60 * 60 * 24
				local dailyResetNeedUpdate = dailyResetTime > 0 and nextDailyResetTime < g_clock.getCurServerTime()
				
				print("awardNeedUpdate:",dailyResetNeedUpdate)
				print("dailyResetNeedUpdate:",dailyResetNeedUpdate)
				
				if awardNeedUpdate or dailyResetNeedUpdate then
					g_busyTip.show_1()
					g_expeditionData.RequestDataAsync(function(result, msgData)
						g_busyTip.hide_1()
						if result == true then
							self:init()
						else
							self:removeFromParent()
						end
					end)
				else
					self:init()
				end
			end
		elseif eventType == "exit" then
			g_expeditionData.SetView(nil)
		end 
	end )
end

function FightPrepare:updateView()
	local baseNode = self._baseNode
	if baseNode == nil then
		return
	end
	
	local exditionData = g_expeditionData.GetData()
	local generalPanel = baseNode:getChildByName("Panel_s1")
	local rightPanel = baseNode:getChildByName("Panel_s2")
	generalPanel:getChildByName("Panel_4"):getChildByName("Text_pm1_0"):setString(exditionData.score.."")
	local rank = exditionData.duel_rank_id
	if rank < 1 then
		rank = 1
	end
	local rankConfig = g_data.duel_rank[rank]
	generalPanel:getChildByName("Panel_4"):getChildByName("Image_21"):loadTexture(g_resManager.getResPath(rankConfig.rank_pic))
	generalPanel:getChildByName("Panel_4"):getChildByName("Image_21_0"):loadTexture(g_resManager.getResPath(rankConfig.rank_number))
	
	self._onBattleStatusInfo =	
	{
		["1"] = exditionData.general_1,
		["2"] = exditionData.general_2,
		["3"] = exditionData.general_3
	}
	
	local rewardBtn = baseNode:getChildByName("buttonsCon"):getChildByName("Button_jl")
	rewardBtn:getChildByName("Image_2"):setVisible(g_expeditionData.IsHaveDailyTimesReward() or g_expeditionData.IsHaveDailyRankReward())

	local fightBtn = generalPanel:getChildByName("Button_3")
	local maxTimes = g_data.duel_initdata[1].default_num
	local currentLeftTimes = exditionData.free_search_times_per_day
	local buyTimes = exditionData.current_day_buy_times
	
	local str = g_tr("peripheral_fight_free_times",{current = currentLeftTimes,max = maxTimes})
	
	fightBtn:getChildByName("Image_1"):setVisible(false)
	
	if currentLeftTimes <= 0 then
		local costInfo = g_gameTools.getCostInfoByCostIdAndCount(g_data.duel_initdata[1].battle_cost,buyTimes + 1)
		str = g_tr("peripheral_fight_buy_cost",{cnt = costInfo.cost_num,costtype = g_tr("assets"..costInfo.cost_type)})
		fightBtn:getChildByName("Image_1"):setVisible(true)
		fightBtn:getChildByName("Image_1"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costInfo.cost_type))
	end
	
	fightBtn:getChildByName("Text_dq_1"):setString(str)
	
	local reportBtn = baseNode:getChildByName("buttonsCon"):getChildByName("Button_juntuan01")
	reportBtn:getChildByName("Image_2"):setVisible(g_expeditionData.isHaveNewReport)
	
	local preTimeLabel = baseNode:getChildByName("Text_djsj")
	local timeLabel = baseNode:getChildByName("Text_djsj_0")
	preTimeLabel:setString("")
	timeLabel:setString("")
	
	preTimeLabel:stopAllActions()
	local preStr = ""
	local finishTime = 0
	local roundInfo = exditionData.round_info
	if roundInfo.status == 1 then
		finishTime = roundInfo.end_time
		--赛季实际是结束时间前两小时结束，需做特殊处理
		if finishTime >	g_clock.getCurServerTime() then
			if finishTime - g_clock.getCurServerTime() < 60 * 60 * 2 then
				preStr = g_tr("peripheral_season_tip_open")
			end
		end
		preStr = g_tr("peripheral_season_tip_close")
	elseif roundInfo.status == 0 then
		finishTime = roundInfo.start_time
		preStr = g_tr("peripheral_season_tip_open")
	end
	preTimeLabel:setString(preStr)
	
	if finishTime > 0 then
		
		local updateTimeStr = function()
			local currentTime = g_clock.getCurServerTime()
			local secondsLeft = finishTime - currentTime
			if secondsLeft < 0 then
				secondsLeft = 0
				preTimeLabel:stopAllActions()
				g_expeditionData.RequestData()
			else
				timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft))
			end
		end
		
		local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
		local action = cc.RepeatForever:create(seq)
		preTimeLabel:runAction(action)
	else
		preStr = g_tr("peripheral_season_tip_err")
		preTimeLabel:setString(preStr)
	end
	
end

function FightPrepare:init()
	local uiLayer =	g_gameTools.LoadCocosUI("Arena_panel.csb",5)
	self:addChild(uiLayer)
	--g_resourcesInterface.installResources(uiLayer)
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	local closeBtn = baseNode:getChildByName("Button_1")
	closeBtn:setTouchEnabled(true)
	closeBtn:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			if self._isPosing == true then
				self:onAfterSave()
			else
				self:removeFromParent()
			end
			
			end
	end)
	
	baseNode:getChildByName("Button_2"):setVisible(false)
	baseNode:getChildByName("Text_jc1"):setString(g_tr("peripheral_title"))
	
	local helpBtn = baseNode:getChildByName("Button_wenh")
	helpBtn:addClickEventListener(function()
		require("game.uilayer.common.HelpInfoBox"):show(24)
	end)
	local generalPanel = baseNode:getChildByName("Panel_s1")
	local rightPanel = baseNode:getChildByName("Panel_s2")
	
	generalPanel:getChildByName("Panel_4"):getChildByName("Text_dq"):setString(g_tr("peripheral_current_rank"))
	generalPanel:getChildByName("Panel_4"):getChildByName("Text_dq_0"):setString(g_tr("peripheral_current_score"))
	
	local shopBtn = baseNode:getChildByName("buttonsCon"):getChildByName("Button_wd")
	shopBtn:getChildByName("Text_1"):setString(g_tr("peripheral_shop"))
	shopBtn:addClickEventListener(function()
		g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SHOP,{tag = 5})
	end)
	 

	--local listView = rightPanel:getChildByName("ListView_1")
	
	local buttonsCon = baseNode:getChildByName("buttonsCon")
	local buzhenBtn = baseNode:getChildByName("buttonsCon"):getChildByName("Button_6_0")
	self._buzhenBtn = buzhenBtn
	buzhenBtn:getChildByName("Text_1"):setString(g_tr("peripheral_prepare"))

	local okBtn = rightPanel:getChildByName("Button_6")
	okBtn:getChildByName("Text_1"):setString(g_tr("peripheral_prepare_done"))
	okBtn:addClickEventListener(function()
		local onAfterSave = function()
			self:onAfterSave()
			g_guideManager.execute()
		end
		savePosition(self._onBattleStatusInfo,onAfterSave)
	end)
	
--	local exditionData = g_expeditionData.GetData()
--	
--	generalPanel:getChildByName("Panel_4"):getChildByName("Text_pm1_0"):setString(exditionData.score.."")
--	--generalPanel:getChildByName("Panel_4"):getChildByName("Text_pm1"):setString("")
--	local rank = exditionData.duel_rank_id
--	if rank < 1 then
--		rank = 1
--	end
--	local rankConfig = g_data.duel_rank[rank]
--	generalPanel:getChildByName("Panel_4"):getChildByName("Image_21"):loadTexture(g_resManager.getResPath(rankConfig.rank_pic))
--	generalPanel:getChildByName("Panel_4"):getChildByName("Image_21_0"):loadTexture(g_resManager.getResPath(rankConfig.rank_number))

--	self._onBattleStatusInfo =	
--	{
--		["1"] = exditionData.general_1,
--		["2"] = exditionData.general_2,
--		["3"] = exditionData.general_3
--	}
--	
	
	self:updateView()

	local updateLargePic = function()
		for i=1, 3 do
			generalPanel:getChildByName("Image_r"..i.."_0"):setVisible(true)
			generalPanel:getChildByName("Image_r"..i.."_0"):setVisible(true)
			generalPanel:getChildByName("Image_r"..i.."_0"):setVisible(true)
			generalPanel:getChildByName("Image_r"..i):setVisible(false)
			generalPanel:getChildByName("Image_r"..i):setVisible(false)
			generalPanel:getChildByName("Image_r"..i):setVisible(false)
			generalPanel:getChildByName("Panel_"..i):getChildByName("Text_mz1"):setString(g_tr("peripheral_todo"))
		end
		
		for key, var in pairs(self._onBattleStatusInfo) do
			if var > 0 then
				local general = g_data.general[var*100 + 1]
				generalPanel:getChildByName("Image_r"..key):setVisible(true)
				generalPanel:getChildByName("Image_r"..key):loadTexture(g_resManager.getResPath(general.general_big_icon))
				generalPanel:getChildByName("Image_r"..key.."_0"):setVisible(false)
				generalPanel:getChildByName("Panel_"..key):getChildByName("Text_mz1"):setString(g_tr(general.general_name))
			end
		end
	end
	
	local changeBattleStatus = function(item)
		local currentPos = item.battlePos
		local currentGeneral = item.general
		print("currentPos:",currentPos)
		print("currentGeneral:",currentGeneral)
		for i = 1, 3 do
			if currentPos then
				 if self._onBattleStatusInfo[tostring(i)] == currentGeneral then
					 self._onBattleStatusInfo[tostring(i)] = nil
					 item.battlePos = nil
					 do
						 for i = 1, 3 do
							item:getChildByName("Image_num"..i):setVisible(false)
						 end
					 end
					 break
				 end
			else
				 if self._onBattleStatusInfo[tostring(i)] == nil or self._onBattleStatusInfo[tostring(i)] == 0 then
					 item.battlePos = i
					 self._onBattleStatusInfo[tostring(i)] = item.general
					 do
						 for i = 1, 3 do
							item:getChildByName("Image_num"..i):setVisible(false)
						 end
					 end
				 	 item:getChildByName("Image_num"..i):setVisible(true)
				 	 break
				 else
					
				 end
			end
		end
		
		updateLargePic()
	end
	
	updateLargePic()
	
	local enterBuzhen = function(sender)
		if self._isPosing == true then
			self:onAfterSave()
			return
		end
		self._isPosing = true
		local ownedGenerals = g_GeneralMode.getOwnedGenerals()
		local listView = rightPanel:getChildByName("ListView_1")
		--listView = g_gameTools.convertScrollView(listView)
		listView:removeAllChildren()
		local maxNum = table.nums(ownedGenerals)
		
		if g_guideManager.getLastShowStep() then
				ownedGenerals = clone(ownedGenerals)
				table.sort(ownedGenerals,function(a,b)
					return a.general_id == 20026 or a.general_id == 20022 or a.general_id == 10050
				end) 
		end
		
		if maxNum > 0 then
			local idx = 0
			local con = ccui.Widget:create()
			local maxRow = math.ceil(maxNum/3)
			local heightDistance = 0
			local itemModel = cc.CSLoader:createNode("Arena_panel1.csb") 
			local idx = 0
			local listSize = itemModel:getContentSize()
			local rowIdx = 0
			local posX = 0
			con:setContentSize(cc.size(listSize.width * 3,(listSize.height + heightDistance) * maxRow))
			
			local guideIdx = 1
			for key, generalServerData in pairs(ownedGenerals) do
				if idx > 0 and idx%3 == 0 then
					rowIdx = rowIdx+1
					posX = 0
				end
				local item = itemModel:clone()
				item.general = generalServerData.general_id
				con:addChild(item)
				
				if guideIdx <= 3 then --注册前3个
					g_guideManager.registComponent(9999401 + guideIdx,item)
					guideIdx = guideIdx + 1
				end
				
				item:setPositionX(posX)
				--item:setPositionY(rowIdx * listSize.height)
				item:setPositionY((listSize.height + heightDistance) * (maxRow - rowIdx - 1))
				--listView:pushBackCustomItem(item)
				do
				for i = 1, 3 do
					item:getChildByName("Image_num"..i):setVisible(false)
				end
				
				for key, generalId in pairs(self._onBattleStatusInfo) do
					if generalServerData.general_id == generalId then
						item.battlePos = tonumber(key)
						item:getChildByName("Image_num"..key):setVisible(true)
						break
					end
				end
				end
				
				local headContainer = item:getChildByName("Image_1")
				headContainer:removeAllChildren()
				local size = headContainer:getContentSize()
				
				item:getChildByName("Text_2"):setString("")
				

				
				local generalConfig = g_GeneralMode.getGeneralByOriginalId(generalServerData.general_id)
				local generalConfigId = generalConfig.id
--				if generalConfig.general_quality == g_GeneralMode.godQuality then
--					item:getChildByName("Text_2"):enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,1),2)
--					item:getChildByName("Text_2"):setString("Lv"..generalServerData.lv)
--				end
				
				local headView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.General,generalConfigId,generalServerData.lv)
				headContainer:addChild(headView)
				headView:setNameVisible(true)
				headView:showGeneralServerStarLv(generalServerData.star_lv)
				headView:setNameColor(cc.c3b(0, 0, 0))
				headView:setPosition(cc.p(size.width/2,size.height/2))
				local scale = size.width/headView:getContentSize().width
				headView:setScale(scale)
				
				local weaponTypeIcon = g_resManager.getRes(1012600 + generalConfig.weapon_type)
				if generalConfig.weapon_type > 0 and weaponTypeIcon then
					weaponTypeIcon:setPosition(cc.p(headView:getContentSize().width/2,headView:getContentSize().height - weaponTypeIcon:getContentSize().height/2 - 5))
					headView:addChild(weaponTypeIcon)
				end
				
				item:setTouchEnabled(true)
				item:addClickEventListener(function(sender)
					changeBattleStatus(sender)
					g_guideManager.execute()
				end)
				
				idx = idx + 1
				posX = posX + listSize.width
				
			end
			
			listView:pushBackCustomItem(con)
		end
		
		

		--right action
		do
			buttonsCon:setVisible(false)
			rightPanel:setPositionX(1300)
			rightPanel:setPositionY(33)
			rightPanel:setVisible(true)
			local move = cc.MoveTo:create(0.25,cc.p(808,33))
			rightPanel:runAction(move)
		end
		
		--left action
		do
			--generalPanel:getChildByName("Panel_4"):setVisible(false)
			generalPanel:getChildByName("Button_3"):setVisible(false)
			local move = cc.MoveTo:create(0.25,cc.p(-30,345))
			local scale = cc.ScaleTo:create(0.25,0.75)
			local sequence = cc.Spawn:create(move, scale)
			generalPanel:runAction(sequence)
		end
		
		if not g_guideManager.execute() then
			self:checkRankLevelUp()
		end
	end
	
	for i=1, 3 do
		generalPanel:getChildByName("Image_r"..i.."_0"):setTouchEnabled(true)
		generalPanel:getChildByName("Image_r"..i.."_0"):addClickEventListener(enterBuzhen)
	end
	buzhenBtn:addClickEventListener(enterBuzhen)
	
	do --点击大半身像退出布阵状态
		for key, var in pairs(self._onBattleStatusInfo) do
			if var > 0 then
			generalPanel:getChildByName("Image_r"..key):setTouchEnabled(true)
			generalPanel:getChildByName("Image_r"..key):addClickEventListener(function()
					 if self._isPosing == true then
					 self:onAfterSave()
				 end
			end)
			end
		end
	end
	
	buttonsCon:setVisible(true)
	rightPanel:setVisible(false)
	
	local rewardBtn = buttonsCon:getChildByName("Button_jl")
	rewardBtn:addClickEventListener(function()
		 g_sceneManager.addNodeForUI(require("game.uilayer.fightperipheral.FightReward"):create())
	end)
	rewardBtn:getChildByName("Text_1"):setString(g_tr("peripheral_reward"))
	
	local reportBtn = buttonsCon:getChildByName("Button_juntuan01")
	reportBtn:addClickEventListener(function()
		 g_expeditionData.isHaveNewReport = false
		 reportBtn:getChildByName("Image_2"):setVisible(g_expeditionData.isHaveNewReport)
		 g_sceneManager.addNodeForUI(require("game.uilayer.fightperipheral.FightReports"):create())
	end)
	reportBtn:getChildByName("Text_1"):setString(g_tr("peripheral_report"))
	
	local ranklistBtn = buttonsCon:getChildByName("Button_juntuan02")
	ranklistBtn:addClickEventListener(function()
		 g_sceneManager.addNodeForUI(require("game.uilayer.fightperipheral.FightRankList"):create())
	end)
	ranklistBtn:getChildByName("Text_1"):setString(g_tr("peripheral_ranklist"))
	
	local fightBtn = generalPanel:getChildByName("Button_3")
	fightBtn:addClickEventListener(function()
		g_guideManager.execute()
		if checkPosIsFull(self._onBattleStatusInfo) then
			local function onRecv(result, msgData)
				g_busyTip.hide_1()
				if result == true then
					 local selfPlaystates = msgData.me
					 local targetPlaystates = msgData.target
					 g_sceneManager.addNodeForSceneEffect(require("game.uilayer.fightperipheral.FightPreview"):create(selfPlaystates,targetPlaystates,msgData.pk_id))
				end
			end
	
			g_busyTip.show_1()
			g_sgHttp.postData("pk/pkMatch",{},onRecv,true) 
		else
			enterBuzhen()
			g_airBox.show(g_tr("peripheral_fight_general_error"))
		end
	end)
	
	g_guideManager.registComponent(9999401,buzhenBtn)
	g_guideManager.registComponent(9999405,okBtn)
	g_guideManager.registComponent(9999406,fightBtn)
	g_guideManager.execute()
end

function FightPrepare:checkRankLevelUp()
	local exditionData = g_expeditionData.GetData()
	local lastSmallRank = exditionData.prev_duel_rank_id
	if lastSmallRank < 1 then
		lastSmallRank = 1
	end
	local lastSmallRankConfig = g_data.duel_rank[lastSmallRank]
	local lastBigRank = lastSmallRankConfig.rank
	
	
	local smallRank = exditionData.duel_rank_id
	if smallRank < 1 then
		smallRank = 1
	end
	local rankConfig = g_data.duel_rank[smallRank]
	local bigRank = rankConfig.rank
		
	if smallRank > lastSmallRank then
		if bigRank > lastBigRank then --大段位提升
			require("game.uilayer.fightperipheral.FightRankLevelUpEffect").playBigRankLevelUp(lastSmallRank,smallRank)
		elseif smallRank > lastSmallRank then --小段位提升
			require("game.uilayer.fightperipheral.FightRankLevelUpEffect").playSmallRankLevelUp(lastSmallRank,smallRank)
		end
	end
	
	if lastSmallRank ~= smallRank then
		g_expeditionData.RequestAnimPlayedAsync()
	end
	
end

function FightPrepare:onAfterSave()
	self._isPosing = false
	local buttonsCon = self._baseNode:getChildByName("buttonsCon")
	local generalPanel = self._baseNode:getChildByName("Panel_s1")
	local rightPanel = self._baseNode:getChildByName("Panel_s2")
	
	buttonsCon:setVisible(true)
	--generalPanel:getChildByName("Panel_4"):setVisible(true)
	generalPanel:getChildByName("Button_3"):setVisible(true)
	rightPanel:setVisible(false)
	local move = cc.MoveTo:create(0.15,cc.p(13,345))
	local scale = cc.ScaleTo:create(0.15,1.0)
	local sequence = cc.Spawn:create(move, scale)
	generalPanel:runAction(sequence)
end

return FightPrepare