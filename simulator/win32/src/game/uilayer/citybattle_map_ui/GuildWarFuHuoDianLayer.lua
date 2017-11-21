local GuildWarFuHuoDianLayer = class("GuildWarFuHuoDianLayer",function()
	return cc.Layer:create()
end)

local HelperMD = require "game.mapcitybattle.worldMapLayer_helper"


--STATUS_DEFAULT = 0,
--STATUS_READY_SEIGE = 1,
--STATUS_SEIGE = 2,
--STATUS_CLAC_SEIGE = 3,
--STATUS_READY_MELEE = 4,
--STATUS_MELEE = 5,
--STATUS_CLAC_MELEE = 6,
--STATUS_FINISH = 7,
    
--强制选择复活点时的超时时间
local function _getSelectEndTime()
	local battleStatus = g_cityBattleInfoData.GetData().status
	
	local currentTime = g_clock.getCurServerTime()
	local endTime = g_clock.getCurServerTime() + 30
	if battleStatus == g_cityBattleInfoData.StatusType.STATUS_READY_SEIGE 
	or battleStatus == g_cityBattleInfoData.StatusType.STATUS_SEIGE then
		if currentTime <= g_cityBattleInfoData.GetData().real_start_time then --准备阶段
			--至少留30秒操作时间
			endTime = math.max(g_cityBattleInfoData.GetData().real_start_time,g_clock.getCurServerTime() + 30)
		else --开战阶段
			endTime = g_clock.getCurServerTime() + 30
		end
	elseif battleStatus == g_cityBattleInfoData.StatusType.STATUS_READY_MELEE
	or battleStatus == g_cityBattleInfoData.StatusType.STATUS_MELEE then
		if currentTime <= g_cityBattleInfoData.GetData().melee_time then
			--至少留30秒操作时间
			endTime = math.max(g_cityBattleInfoData.GetData().melee_time,g_clock.getCurServerTime() + 30)
		else
			endTime = g_clock.getCurServerTime() + 30
		end
	end
	
	return endTime
end

local function _createAinmation(type)
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setContentSize(cc.size(0.0,0.0))
	ret:setAnchorPoint(cc.p(0.0,0.0))
	
	local isPlayed1 = false
	
	local animPath = "anime/Effect_ZhanLueTuTiShi/Effect_ZhanLueTuTiShi.ExportJson"
	local armature , animation = nil,nil
	local isPlayRound = true
	
	local creat_ain = function()
		armature , animation = g_gameTools.LoadCocosAni(
		animPath
		, "Effect_ZhanLueTuTiShi"
		, function()
		end
		--, onFrameEventCallFunc
		)
		ret:addChild(armature)
		animation:play("Animation2")
	end
	
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.complete == eventType then
			if type == 1 and isPlayed1 == false then
				isPlayed1 = true
				armature:removeFromParent()
				creat_ain()
			end
		end
	end

	armature , animation = g_gameTools.LoadCocosAni(
	animPath
	, "Effect_ZhanLueTuTiShi"
	, onMovementEventCallFunc
	--, onFrameEventCallFunc
	)
	ret:addChild(armature)
	
	if type == 1 then
		animation:play("Animation1")
	elseif type == 2 then
		animation:play("Animation2")
	end
	
	return ret
end


--确保使用show()方法只能打开一个界面
local m_instanceLayer = nil

function GuildWarFuHuoDianLayer.show(needPlayAnination)
--	if g_cityBattleInfoData.IsAttacker() then
--		return
--	end
	local layer = nil
	if m_instanceLayer == nil then
		layer = GuildWarFuHuoDianLayer:create(needPlayAnination)
		g_sceneManager.addNodeForUI(layer)
	end
	return layer
end

function GuildWarFuHuoDianLayer:tipArea(areaIds)
	if table.nums(areaIds) <= 0 then
		return
	end

	for key, areaId in pairs(areaIds) do
		local con = self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..areaId)
		if g_cityBattleInfoData.IsAttacker() then
			con = self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..areaId)
		end
		
		local effNode = con:getChildByName("Eff1")
		if effNode == nil then
			effNode = cc.Node:create()
			con:addChild(effNode)
			effNode:setName("Eff1")
	  else
	  	effNode:removeAllChildren()
		end
		local anim = _createAinmation(1)
		effNode:addChild(anim)
		
		local size = con:getContentSize()
		anim:setPosition(cc.p(size.width*0.5,size.height*0.5))
	end	
end

function GuildWarFuHuoDianLayer:ctor(needPlayAnination)
	
	self._needPlayAnination = needPlayAnination
	self:registerScriptHandler(function(eventType)
    if eventType == "enter" then
			require("game.mapcitybattle.worldMapLayer_uiLayer").addUpdateView(self)
			require("game.uilayer.mainSurface.mainSurfaceChat").setChatBarVisible(false)
			m_instanceLayer = self
--			local function retHandler(result,msgData)
--				g_busyTip.hide_1()
--				self:createSmallMap(self._baseNode:getChildByName("Image_5"))
--			end
--			g_busyTip.show_1()
--			g_cityBattleCampPlayersData.RequestDataAsync(retHandler)
			self:createSmallMap(self._baseNode:getChildByName("Image_5"))
			
    elseif eventType == "exit" then
			require("game.mapcitybattle.worldMapLayer_uiLayer").removeUpdateView(self)
			m_instanceLayer = nil
			require("game.uilayer.mainSurface.mainSurfaceChat").setChatBarVisible(true)
    end 
  end )
	
	local csbName = "guildwar_fuhuodian05.csb"
	if g_cityBattleInfoData.IsDoorMap() then
		csbName = "guildwar_fuhuodian04.csb"
	end
	 
	local uiLayer =  g_gameTools.LoadCocosUI(csbName,5)
	self:addChild(uiLayer)
	
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	
	self._baseNode:getChildByName("Text_1"):setString(g_tr("guild_war_zhanluetu"))
	
	local closeBtn = self._baseNode:getChildByName("close_btn")
		closeBtn:setTouchEnabled(true)
		closeBtn:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			self:removeFromParent()
		end
	end)

	local ChatMode = require("game.uilayer.chat.ChatMode")
	local ChatType = ChatMode.getChatTypeEnum()
	local rich = g_gameTools.createRichText(self._baseNode:getChildByName("Panel_liaot"):getChildByName("Text_3"),"")
	local updateChat = function()
		local str = ChatMode.getNewestBattleChatContent(ChatType.CityBattle)
		if str ~= "" then
			rich:setRichText(str)
		end
	end
	
	self._baseNode:getChildByName("Panel_liaot"):getChildByName("Button_1"):setTouchEnabled(false)
	self._baseNode:getChildByName("Panel_liaot"):setTouchEnabled(true)
	self._baseNode:getChildByName("Panel_liaot"):addClickEventListener(function()
		g_sceneManager.addNodeForUI(require("game.uilayer.chat.ChatLayer").new(ChatType.CityBattle))
	end)
	
	do
		local seq = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(updateChat))
	  local action = cc.RepeatForever:create(seq)
	  self._baseNode:getChildByName("Panel_liaot"):runAction(action)
		updateChat()
	end
	
	local areaMaxNum = 4
	if not g_cityBattleInfoData.IsDoorMap() then
		areaMaxNum = 5
	end
	
	do --注册每个复活点区域点击
		for i=1, areaMaxNum do
			self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):addClickEventListener(function()
					self:onClickFuHuoDian(i)
			end)
			--self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Text_4"):setString(g_tr("guild_war_build_fuhuodian_desc"))
			self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Text_4"):setString(g_tr("guild_war_area_name_"..i))
			
			self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):addClickEventListener(function()
					self:onClickFuHuoDian(i)
			end)
			--self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Text_4"):setString(g_tr("guild_war_build_fuhuodian_desc"))
			self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Text_4"):setString(g_tr("guild_war_area_name_"..i))
		end
		
		
		
	end
	
	self._selectEndTime = _getSelectEndTime()
	self._lastBattleStatus = g_cityBattleInfoData.GetData().status
	
	do --说明文字
		for i=1, 7 do
			self._baseNode:getChildByName("Panel_tis"):getChildByName("Panel_"..i):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc"..i))
		end
	end
	self:updateView()
end

function GuildWarFuHuoDianLayer:onClickFuHuoDian(posIdx,isAutoSelect)
	print("posIdx",posIdx)

	local onRecv = function(result,msgData)
		g_busyTip.hide_1()
		if result == true then
			require "game.mapcitybattle.worldMapLayer_bigMap".requestMapAllData_Manual()
			if isAutoSelect == true then
				g_airBox.show(g_tr("guild_war_slect_cd_timeout"))
			end
			if m_instanceLayer then
				self:removeFromParent()
			end
			
			require "game.mapcitybattle.changeMapScene".gotoWorld_BigTileIndex(g_cityBattlePlayerData.GetPosition())
			require("game.mapcitybattle.worldMapLayer_uiLayer").showActiveSkillIcon()
		end
	end
	
	local isFirstSelect = not g_cityBattlePlayerData.hasSelectedOnMap()
	
	local doChangeHandler = function(areaId)
		
		if isFirstSelect then
			g_busyTip.show_1()
			if g_cityBattleInfoData.IsDoorMap() then
				g_sgHttp.postData("City_Battle/siegeChangeLocation",{area = areaId},onRecv,true) --选择出生点
			else
				g_sgHttp.postData("City_Battle/meleeChangeLocation",{section = areaId},onRecv,true)
			end
		else
			if g_cityBattlePlayerData.GetData().is_dead == 1 then --死亡状态,选择复活点
				print("nothing ....")
			else --迁城
				if g_cityBattleInfoData.IsDoorMap() then
					g_sgHttp.postData("City_Battle/siegeChangeLocation",{area = areaId},onRecv,true)
				else
					g_sgHttp.postData("City_Battle/meleeChangeLocation",{section = areaId},onRecv,true)
				end
			end
		end
	end
	
	if isAutoSelect == true then
		--自动选择出生点时，防守方默认为区域4
		local isAttacker = g_cityBattleInfoData.IsAttacker()
		if g_cityBattleInfoData.IsDoorMap() then
			if not isAttacker then
				posIdx = 4
			end
		else
			if isAttacker then
				posIdx = 6
			else
				posIdx = 7
			end
		end
	
		doChangeHandler(posIdx)
	else
		local tipStr = g_tr("guild_war_change_location")
		if isFirstSelect then
			tipStr = g_tr("guild_war_select_location")
		else
			if g_cityBattlePlayerData.GetData().is_dead == 1 then --死亡状态
				return
			end
		end
		
		g_msgBox.show(tipStr,nil,nil,function(event)
			if event == 0 then
				doChangeHandler(posIdx)
			end
		end,1)
	end
	
end

function GuildWarFuHuoDianLayer:updateView()
	
	local currentStatus = g_cityBattleInfoData.GetData().status
	if self._lastBattleStatus ~= currentStatus then
			self._selectEndTime = _getSelectEndTime()
			self._lastBattleStatus = currentStatus
			
			if currentStatus == g_cityBattleInfoData.StatusType.STATUS_FINISH
			or currentStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_SEIGE
			or currentStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_MELEE
			then
				self:removeFromParent()
				return
			end
	end
	
	self:stopAllActions()

	local labelPreTime = self._baseNode:getChildByName("Panel_time"):getChildByName("Text_time2")
	local timeLabel = self._baseNode:getChildByName("Panel_time"):getChildByName("Text_time1")
	local labelTimeGreen = self._baseNode:getChildByName("Panel_time"):getChildByName("Text_time2_0")
	labelTimeGreen:setString("")
	
	
	local closeBtn = self._baseNode:getChildByName("close_btn")
	closeBtn:setVisible(true)
	
	local hasSelectedOnMap = g_cityBattlePlayerData.hasSelectedOnMap()
	if hasSelectedOnMap then --已经进过战场,不强制选择复活点，可以选择关闭
	
		if g_cityBattlePlayerData.GetData().is_dead == 1 then --死亡状态，等待cd复活
			self._selectEndTime = g_cityBattlePlayerData.GetData().dead_time + tonumber(g_data.country_basic_setting[51].data)
		
			labelPreTime:setString(g_tr("guild_war_revive_cd"))
			
			local currentTime = g_clock.getCurServerTime()
			local endTime = self._selectEndTime
			local secondsLeft = endTime - currentTime
			
			local timerFinishHandler = function()
					secondsLeft = 0
					self:stopAllActions()
					labelTimeGreen:setString(g_tr("guild_war_can_revive"))
					labelPreTime:setString("")
			end
			
			local updateTimeStr = function()
				currentTime = g_clock.getCurServerTime()
				local secondsLeft = endTime - currentTime
				if secondsLeft < 0 then
					timerFinishHandler()
				else
					labelTimeGreen:setString("")
					timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft,g_gameTools.ClockType.MINSSCONDS))
				end
			end
		  
		  if self._selectEndTime - g_clock.getCurServerTime() > 0 then
			  local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
			  local action = cc.RepeatForever:create(seq)
			  self:runAction(action)
			  
			  updateTimeStr()
			else
				timerFinishHandler()
		  end
		else
			--迁城cd
			self._baseNode:getChildByName("Panel_time"):setVisible(true)
			if g_cityBattleInfoData.IsDoorMap() and g_cityBattleInfoData.IsAttacker() then
				self._baseNode:getChildByName("Panel_time"):setVisible(false)
			end
			
			
			--buff减少的Cd秒数
			local buff_relocation = g_cityBattle_cross_ui_dataHelper.requireCrossGuildOrCityBattleCamp().GetData().buff_relocation or 0
			
			self._selectEndTime = g_cityBattlePlayerData.GetData().change_location_time + tonumber(g_data.country_basic_setting[54].data) - buff_relocation
		
			labelPreTime:setString(g_tr("guild_war_move_cd"))
			
			local currentTime = g_clock.getCurServerTime()
			local endTime = self._selectEndTime
			local secondsLeft = endTime - currentTime
			
			local timerFinishHandler = function()
					secondsLeft = 0
					self:stopAllActions()
					labelTimeGreen:setString(g_tr("guild_war_canmove"))
					labelPreTime:setString("")
			end
			
			local updateTimeStr = function()
				currentTime = g_clock.getCurServerTime()
				local secondsLeft = endTime - currentTime
				if secondsLeft < 0 then
					timerFinishHandler()
				else
					labelTimeGreen:setString("")
					timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft,g_gameTools.ClockType.MINSSCONDS))
				end
			end
		  
		  if self._selectEndTime - g_clock.getCurServerTime() > 0 then
			  local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
			  local action = cc.RepeatForever:create(seq)
			  self:runAction(action)
			  
			  updateTimeStr()
			else
				timerFinishHandler()
		  end
		end
	
		
	else
		closeBtn:setVisible(false)
		labelPreTime:setString(g_tr("guild_war_slect_cd"))
		
		local currentTime = g_clock.getCurServerTime()
		local endTime = self._selectEndTime
		local secondsLeft = endTime - currentTime
		
		local timerFinishHandler = function()
				secondsLeft = 0
				timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft,g_gameTools.ClockType.MINSSCONDS))
				self:stopAllActions()
		end
		
		local updateTimeStr = function()
			currentTime = g_clock.getCurServerTime()
			secondsLeft = endTime - currentTime
			if secondsLeft < 0 then
				timerFinishHandler()
				local defaultAreaId = g_cityBattleInfoData.GetCurrentDefaultArea()
				self:onClickFuHuoDian(defaultAreaId,true)
			else
				timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft,g_gameTools.ClockType.MINSSCONDS))
			end
		end
	  
	  if secondsLeft > 0 then
		  local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
		  local action = cc.RepeatForever:create(seq)
		  self:runAction(action)
			
			updateTimeStr()
		else
			timerFinishHandler()
		end
	end	

	local isAttacker = g_cityBattleInfoData.IsAttacker()
	self._baseNode:getChildByName("Panel_zu"):setVisible(isAttacker)
	self._baseNode:getChildByName("Panel_lan"):setVisible(not isAttacker)
	
	local areaMaxNum = 4
	if not g_cityBattleInfoData.IsDoorMap() then
		areaMaxNum = 5
	end
	
	local myCampId = g_cityBattlePlayerData.GetData().camp_id
	do
		if self._baseNode:getChildByName("Panel_zu"):isVisible() then
			for i=1, areaMaxNum do
					self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):setTouchEnabled(false)
					self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_15"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
		  		self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_16"):setVisible(false)
					self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_17"):setVisible(false)
					
					--城内战区域占领状态
					if not g_cityBattleInfoData.IsDoorMap() then
						local campId = require("game.mapcitybattle.worldMapLayer_bigMap").getOccupationCampBySecionId(i)
						if campId == 0 then
							self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_15"):setVisible(true)
							self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_16"):setVisible(false)
							self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_17"):setVisible(false)
						else
							if myCampId == campId then
								self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_15"):setVisible(false)
								self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_16"):setVisible(true)
								self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_17"):setVisible(false)
							else
								self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_15"):setVisible(false)
								self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_16"):setVisible(false)
								self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Image_17"):setVisible(true)
							end
						end
					end
					
		  end
		  
		  local list = g_cityBattleInfoData.GetCurrentArea()
		  for key, var in pairs(list) do
		  	
		  	if not hasSelectedOnMap or self._needPlayAnination == true then
			  	local con = self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..var)
			  	local effNode = con:getChildByName("Eff")
			  	if effNode == nil then
						effNode = cc.Node:create()
						con:addChild(effNode)
						effNode:setName("Eff")
				  else
				  	effNode:removeAllChildren()
			  	end
		  		local anim = _createAinmation(2)
		  		effNode:addChild(anim)
		  		
			  	local size = con:getContentSize()
			  	anim:setPosition(cc.p(size.width*0.5,size.height*0.5))
			  end
		  	
		  	self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..var):setTouchEnabled(true)
		  	self._baseNode:getChildByName("Panel_zu"):getChildByName("Panel_"..var):getChildByName("Image_15"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
		  end
	  end
	end
	
	do
		if self._baseNode:getChildByName("Panel_lan"):isVisible() then
			for i=1, areaMaxNum do
					self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):setTouchEnabled(false)
					self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_15"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
					self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_16"):setVisible(false)
					self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_17"):setVisible(false)	  
					
					--城内战区域占领状态
					if not g_cityBattleInfoData.IsDoorMap() then
						local campId = require("game.mapcitybattle.worldMapLayer_bigMap").getOccupationCampBySecionId(i)
						if campId == 0 then
							self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_15"):setVisible(true)
							self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_16"):setVisible(false)
							self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_17"):setVisible(false)
						else
							if myCampId == campId then
								self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_15"):setVisible(false)
								self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_16"):setVisible(true)
								self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_17"):setVisible(false)
							else
								self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_15"):setVisible(false)
								self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_16"):setVisible(false)
								self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..i):getChildByName("Image_17"):setVisible(true)
							end
						end
					end
					
		  end
		  
		  local list = g_cityBattleInfoData.GetCurrentArea()
		  for key, var in pairs(list) do
		  	
		  	if not hasSelectedOnMap or self._needPlayAnination == true then
			  	local con = self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..var)
			  	local effNode = con:getChildByName("Eff")
			  	if effNode == nil then
						effNode = cc.Node:create()
						con:addChild(effNode)
						effNode:setName("Eff")
				  else
				  	effNode:removeAllChildren()
			  	end
		  		local anim = _createAinmation(2)
		  		effNode:addChild(anim)
		  		
			  	local size = con:getContentSize()
			  	anim:setPosition(cc.p(size.width*0.5,size.height*0.5))
		  	end
		  	self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..var):setTouchEnabled(true)
		  	self._baseNode:getChildByName("Panel_lan"):getChildByName("Panel_"..var):getChildByName("Image_15"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
		  end
	  end
	end
	
--	guild_war_gongchengchui = 301, --攻城锤
--	
--	guild_war_gate = 302,	--城门
--	
--	guild_war_chuangnu = 303,	--床弩
--	
--	guild_war_yunti = 304,	--云梯
--	
--	guild_war_toushiche = 305,	--投石车
--	
--	guild_war_base_camp = 306,	--大本营
--	
--	guild_war_wall = 307,	--城墙
--	
--	guild_war_fuhuodian = 308,	--复活点
	
	local isAttacker = g_cityBattleInfoData.IsAttacker()
	--更新小地图上各个建筑的状态
	for key, var in pairs(g_data.city_battle_map_config) do
		if var.city_battle_map_element_id > 0 and var.part == g_cityBattleInfoData.GetCurrentMapType() then
			local panel = nil
			local mapOriginType = g_data.map_element[var.city_battle_map_element_id].origin_id
			if mapOriginType == HelperMD.m_MapOriginType.guild_war_gongchengchui then
				panel = self._baseNode:getChildByName("Panel_cmc"):getChildByName("Panel_"..var.build_num)
				panel:getChildByName("Image_16"):setVisible(false)
				panel:getChildByName("Image_17"):setVisible(false)
				local buildServerData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(var.x,var.y)
				local isHavePlayer = buildServerData and tonumber(buildServerData.player_id) > 0 
				if isHavePlayer then
					if isAttacker then
						panel:getChildByName("Image_16"):setVisible(true)
					else
						panel:getChildByName("Image_17"):setVisible(true)
					end
				else
				
				end
				panel:getChildByName("Text_4"):setString("")
				
			elseif mapOriginType == HelperMD.m_MapOriginType.guild_war_gate then
				panel = self._baseNode:getChildByName("Panel_cm"):getChildByName("Panel_"..var.build_num)
				panel:getChildByName("Image_16"):setVisible(false)
				panel:getChildByName("Image_17"):setVisible(false)
				local buildServerData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(var.x,var.y)
				local isBroken = buildServerData and tonumber(buildServerData.durability) == 0
				if isBroken then
					if isAttacker then
						panel:getChildByName("Image_16"):setVisible(true)
					else
						--panel:getChildByName("Image_17"):setVisible(true)
					end
					panel:getChildByName("Text_4"):setString(g_tr("guild_war_status_wallbroken"))
				else
					if isAttacker then
						--panel:getChildByName("Image_17"):setVisible(true)
					else
						panel:getChildByName("Image_16"):setVisible(true)
					end
					panel:getChildByName("Text_4"):setString(g_tr("guild_war_status_wallnormal"))
				end
				panel:getChildByName("Text_4"):setString("")
			elseif mapOriginType == HelperMD.m_MapOriginType.guild_war_chuangnu then
				panel = self._baseNode:getChildByName("Panel_sfn"):getChildByName("Panel_"..var.build_num)
				panel:getChildByName("Image_16"):setVisible(false)
				panel:getChildByName("Image_17"):setVisible(false)
				
				local buildServerData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(var.x,var.y)
				local isHavePlayer = buildServerData and tonumber(buildServerData.player_id) > 0 
				if isHavePlayer then
					if isAttacker then
						panel:getChildByName("Image_17"):setVisible(true)
					else
						panel:getChildByName("Image_16"):setVisible(true)
					end
					panel:getChildByName("Text_4"):setString(g_tr("guild_war_status_chuannuzhanling"))
				else
					panel:getChildByName("Text_4"):setString(g_tr("guild_war_status_chuannunormal"))
				end
				panel:getChildByName("Text_4"):setString("")
			elseif mapOriginType == HelperMD.m_MapOriginType.guild_war_yunti then
				panel = self._baseNode:getChildByName("Panel_yunt"):getChildByName("Panel_"..var.build_num)
				panel:getChildByName("Image_16"):setVisible(false)
				panel:getChildByName("Image_17"):setVisible(false)
				local buildServerData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(var.x,var.y)
				local wf_ladder_max_progress = tonumber(g_data.country_basic_setting[42].data) 
				
				local isGeted = buildServerData and tonumber(buildServerData.resource) >= wf_ladder_max_progress 
				if isGeted then
					if isAttacker then
					else
						panel:getChildByName("Image_17"):setVisible(true)
					end
					panel:getChildByName("Text_4"):setString(g_tr("guild_war_status_yuntizhanling"))
				else
					panel:getChildByName("Text_4"):setString(g_tr("guild_war_status_yuntinormal"))
				end
				
				panel:getChildByName("Text_4"):setString("")
			elseif mapOriginType == HelperMD.m_MapOriginType.guild_war_toushiche then
				print("var.build_num:",var.build_num)
				panel = self._baseNode:getChildByName("Panel_gcc"):getChildByName("Panel_"..var.build_num)
				panel:getChildByName("Image_16"):setVisible(false)
				panel:getChildByName("Image_17"):setVisible(false)
				
				local function isSelfGuild(buildServerData)
					return buildServerData.camp_id ~= 0 and buildServerData.camp_id == g_cityBattlePlayerData.getCampId()
				end
				
				local buildServerData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(var.x,var.y)
				
				local isGeted = buildServerData and tonumber(buildServerData.player_id) > 0
				if isGeted then
					if isSelfGuild(buildServerData) then
						panel:getChildByName("Image_16"):setVisible(true)
					else
						panel:getChildByName("Image_17"):setVisible(true)
					end
					panel:getChildByName("Text_4"):setString(g_tr("guild_war_status_toushichezhanling"))
				else
					panel:getChildByName("Text_4"):setString(g_tr("guild_war_status_toushichenormal"))
				end
				panel:getChildByName("Text_4"):setString("")
			elseif mapOriginType == HelperMD.m_MapOriginType.guild_war_base_camp then
			elseif mapOriginType == HelperMD.m_MapOriginType.guild_war_wall then
			elseif mapOriginType == HelperMD.m_MapOriginType.guild_war_fuhuodian then
			end
		end
	end
end


function GuildWarFuHuoDianLayer:createSmallMap(map)
    local MapHelper = require "game.mapcitybattle.worldMapLayer_helper"
    local _guidData = require "game.mapcitybattle.worldMapLayer_bigMap".getSelfGuildPlayerBuilds()--g_cityBattleCampPlayersData.GetData()
    local _map = map
    local _mode = _map:getChildByName("tap_0")
    local _myTap = _map:getChildByName("tap")
    local _size = _map:getContentSize()
    local _myPos = g_cityBattlePlayerData.GetPosition()
    if _guidData then
        for key, var in pairs(_guidData) do
            if _myPos.x ~= tonumber(var.x) and _myPos.y ~= tonumber(var.y) then
                local pos = cc.p( tonumber(var.x),tonumber(var.y))
                local m_pos = MapHelper.out_bigTileIndex_2_position(pos,_size)
                local sp = _mode:clone()
                sp:setPosition(m_pos)
                _map:addChild(sp)
            end
        end
    end

    local myPos = MapHelper.out_bigTileIndex_2_position(_myPos,_size)
    _myTap:setPosition(myPos)


    _mode:setVisible(false)
end

return GuildWarFuHuoDianLayer