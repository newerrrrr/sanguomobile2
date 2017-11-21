local tournament_backplay = {}
setmetatable(tournament_backplay,{__index = _G})
setfenv(1,tournament_backplay)

--武斗回放

--require("game.uilayer.tournament.tournament_backplay").show()


local buffsModelMD = require("game.uilayer.tournament.buffsModel")
local helpModelMD = require("game.uilayer.tournament.helpModel")
local mapModelMD = require("game.uilayer.tournament.mapModel")
local roleModelMD = require("game.uilayer.tournament.roleModel")
local schedulerModelMD = require("game.uilayer.tournament.schedulerModel")
local skillsModelMD = require("game.uilayer.tournament.skillsModel")
local stepDataModelMD = require("game.uilayer.tournament.stepDataModel")
local surfaceModelMD = require("game.uilayer.tournament.surfaceModel")
local stateModelMD = require("game.uilayer.tournament.stateModel")
local AIModelMD = require("game.uilayer.tournament.AIModel")

local m_ScaleTime = helpModelMD.BESE_SCALE_TIME

local m_CanPlayAction = false

local m_GmaeStateObject = nil
local m_StepDataObject = nil

local m_ServerData = nil

local m_Root = nil
local m_BattleRoot = nil
local m_MapBottom = nil
local m_InfoRoot = nil
local m_RoleRoot = nil
local m_MapTop = nil
local m_AtkEffectRoot = nil
local m_SurfaceRoot = nil
local m_SurfaceTop = nil
local m_SurfaceJump = nil
local m_SurfaceChangeSpeed = nil
local m_SceneEffectRoot = nil

local m_A_Role = nil
local m_B_Role = nil

local m_isJump = false
local m_isPlayEnd = false

local function clearGlobal()
	
	m_ScaleTime = helpModelMD.BESE_SCALE_TIME
	
	m_CanPlayAction = false
	
	m_GmaeStateObject = nil
	m_StepDataObject = nil
	
	m_ServerData = nil
	
	m_Root = nil
	m_BattleRoot = nil
	m_MapBottom = nil
	m_InfoRoot = nil
	m_RoleRoot = nil
	m_MapTop = nil
	m_AtkEffectRoot = nil
	m_SurfaceRoot = nil
	m_SurfaceTop = nil
	m_SurfaceJump = nil
	m_SurfaceChangeSpeed = nil
	m_SceneEffectRoot = nil
	
	m_A_Role = nil
	m_B_Role = nil
	
	m_isJump = false
	m_isPlayEnd = false
	
end


local function _createBattleChildNode()
	local ret = cc.Node:create()
	ret:setContentSize(helpModelMD.m_DesignSize)
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5, 0.5))
	ret:setPosition(helpModelMD.m_Center)
	return ret
end

local function _create(serverData)
	
	g_gameManager.PlayedTournament = true
	
	clearGlobal()
	
	m_ServerData = clone(serverData)
	
	schedulerModelMD.ready()
	schedulerModelMD.setScaleTime(m_ScaleTime)
	
	m_GmaeStateObject = stateModelMD.createGmaeState()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	schedulerModelMD.resetNodeSchedulerAndActionManage(rootLayer)
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			g_sceneManager.hideMapRoot()
			schedulers[(#schedulers) + 1] = schedulerModelMD.scheduleScriptFunc(update_1, 0, false)
			g_musicManager.playMusic(g_data.sounds[5100004].sounds_path,true)
		elseif eventType == "exit" then
			g_sceneManager.showMapRoot()
			for k , v in ipairs(schedulers) do
				schedulerModelMD.unscheduleScriptEntry(v)
			end
			if require("game.maplayer.changeMapScene").getCurrentMapStatus() == require("game.maplayer.changeMapScene").m_MapEnum.home then
				g_musicManager.playMusic(g_data.sounds[5000002].sounds_path,true)
			else
				g_musicManager.playMusic(g_data.sounds[5000003].sounds_path,true)
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	do--屏蔽
		local function onTouchBegan(touch, event)
			return true
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(true)
		touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, rootLayer)
	end
	
	------------------------------------------------------------
	
	--战斗根节点
	m_BattleRoot = cc.Node:create()
	m_BattleRoot:setContentSize(helpModelMD.m_DesignSize)
	m_BattleRoot:ignoreAnchorPointForPosition(false)
	m_BattleRoot:setAnchorPoint(cc.p(0.5, 0.5))
	m_BattleRoot:setPosition(g_display.center)
	m_BattleRoot:setScale(g_display.scale)
	rootLayer:addChild(m_BattleRoot, 1)
	
	local mapConfigID = 1
	
	--地图底层
	m_MapBottom = mapModelMD.createBottom(mapConfigID)
	m_BattleRoot:addChild(m_MapBottom, 1)
	
	--信息层
	m_InfoRoot = _createBattleChildNode()
	m_BattleRoot:addChild(m_InfoRoot, 2)
	
	--角色层
	m_RoleRoot = _createBattleChildNode()
	m_BattleRoot:addChild(m_RoleRoot, 3)
	
	--地图遮罩层
	m_MapTop = mapModelMD.createTop(mapConfigID)
	m_BattleRoot:addChild(m_MapTop, 4)
	
	--特效层
	m_AtkEffectRoot = _createBattleChildNode()
	m_BattleRoot:addChild(m_AtkEffectRoot, 5)
	
	--测试顶点连线
	if cToolsForLua:isDebugVersion() then
		m_BattleRoot:addChild(mapModelMD.createDebug(mapConfigID), 999999999)
	end
	
	------------------------------------------------------------
	
	--界面根节点
	m_SurfaceRoot = cc.Node:create()
	m_SurfaceRoot:setContentSize(g_display.size)
	m_SurfaceRoot:ignoreAnchorPointForPosition(false)
	m_SurfaceRoot:setAnchorPoint(cc.p(0.5, 0.5))
	m_SurfaceRoot:setPosition(g_display.center)
	rootLayer:addChild(m_SurfaceRoot, 2)
	
	--上面主界面
	m_SurfaceTop = surfaceModelMD.createTop(tournament_backplay)
	m_SurfaceRoot:addChild(m_SurfaceTop)
	
	--跳过按钮
	m_SurfaceJump = surfaceModelMD.createJump()
	m_SurfaceRoot:addChild(m_SurfaceJump)
	
	--加速按钮
	m_SurfaceChangeSpeed = surfaceModelMD.createChangeSpeed(math.floor(m_ScaleTime / helpModelMD.BESE_SCALE_TIME + 0.001))
	m_SurfaceRoot:addChild(m_SurfaceChangeSpeed)


	------------------------------------------------------------
	
	--场景特效根节点
	m_SceneEffectRoot = cc.Node:create()
	m_SceneEffectRoot:setContentSize(g_display.size)
	m_SceneEffectRoot:ignoreAnchorPointForPosition(false)
	m_SceneEffectRoot:setAnchorPoint(cc.p(0.5, 0.5))
	m_SceneEffectRoot:setPosition(g_display.center)
	rootLayer:addChild(m_SceneEffectRoot, 3)

	
	--场次变化通知
	local function seasonStateChangeNotice(season)
		onSeasonStateNotice(season)
		m_SurfaceTop.lua_onSeasonStateChange(season)
		m_SurfaceJump.lua_onSeasonStateChange(season)
		m_SurfaceChangeSpeed.lua_onSeasonStateChange(season)
	end
	m_GmaeStateObject.setSeasonStateChangeNotice(seasonStateChangeNotice)
	
	--回合变化通知
	local function roundStateChangeNotice(round)
		onRoundStateNotice(round)
		m_SurfaceTop.lua_onRoundStateChange(round)
		m_SurfaceJump.lua_onRoundStateChange(round)
		m_SurfaceChangeSpeed.lua_onRoundStateChange(round)
	end
	m_GmaeStateObject.setRoundStateChangeNotice(roundStateChangeNotice)
	
	--设置到第一场第一回合
	m_GmaeStateObject.addSeason()
	
	
	local function playReadying()
		local function playGoto()
			--开始播放
			m_CanPlayAction = true
			g_autoCallback.addCocosList(playAction, 0.5 / m_ScaleTime)
		end
		--播放场次数动画
		playAutoSceneEffect(
			"anime/Effect_LeiTaiGuoChangText_HuiHe/Effect_LeiTaiGuoChangText_HuiHe.ExportJson"
			, "Effect_LeiTaiGuoChangText_HuiHe"
			, "HuiHe_"..tostring(m_GmaeStateObject.getSeason())
			, playGoto
			)
	end
	g_autoCallback.addCocosList(playReadying, 1.5--[[ / m_ScaleTime--]])
	
	cc.Director:getInstance():setNextDeltaTimeZero(true)
	
	return rootLayer
end


--得到对应位置的信息
local function _getPlaceInfo(place)
	if place == "A" then
		return m_A_Role
	elseif place == "B" then
		return m_B_Role
	end
end


--更新1
function update_1(dt)
	if m_A_Role == nil or m_B_Role == nil then
		return
	end
	
	if m_GmaeStateObject and m_StepDataObject then
		local s = m_GmaeStateObject.getSeason()
		if s >= 1 and s <= 3 then
			if not m_GmaeStateObject.preLoadRes(s, "A") then
				helpModelMD.preLoadHeroSkillRes(m_StepDataObject.getHeroInitData("A", s))
			elseif not m_GmaeStateObject.preLoadRes(s, "B") then
				helpModelMD.preLoadHeroSkillRes(m_StepDataObject.getHeroInitData("B", s))
			end
		end
	end
	
	--update z order
	m_A_Role.lua_UpdateZOrder(dt)
	m_B_Role.lua_UpdateZOrder(dt)
end


--初始化双方这一场次的角色
local function _createRole(a_hero, a_point, a_angle, b_hero, b_point, b_angle)
	if m_A_Role then
		m_A_Role:removeFromParent()
	end
	if m_B_Role then
		m_B_Role:removeFromParent()
	end
	
	--A
	m_A_Role = roleModelMD.createRole(a_hero.model_res_id,"A")
	m_A_Role.lua_setPosition(a_point)
	m_A_Role.lua_setRotation(a_angle)
	m_RoleRoot:addChild(m_A_Role, 1)
	
	--B
	m_B_Role = roleModelMD.createRole(b_hero.model_res_id,"B")
	m_B_Role.lua_setPosition(b_point)
	m_B_Role.lua_setRotation(b_angle)
	m_RoleRoot:addChild(m_B_Role, 1)
end


--场次变化通知
function onSeasonStateNotice(season)
	m_CanPlayAction = false
	
	if season == 1 then
		--第一场初始化双方数据
		--local backPlayData = cjson.decode(cTools_read_file_data("C:/Users/lihansong/Desktop/wudouhuiheshuju.txt"))
		m_StepDataObject = stepDataModelMD.createBackPlayData(cjson.decode(m_ServerData.backPlayData))
	end
	
	--创建本场角色信息
	_createRole(
		m_StepDataObject.stepData.A["hero_"..tostring(season)]
		, m_StepDataObject.stepData.A.startPoint
		, m_StepDataObject.stepData.A.startAngle
		, m_StepDataObject.stepData.B["hero_"..tostring(season)]
		, m_StepDataObject.stepData.B.startPoint
		, m_StepDataObject.stepData.B.startAngle
		)
end


--回合变化通知
function onRoundStateNotice(round)
	local a_point = m_StepDataObject.getOriginPoint("A", m_GmaeStateObject.getSeason(), round)
	local a_angle = m_StepDataObject.getOriginAngle("A", m_GmaeStateObject.getSeason(), round)
	
	local b_point = m_StepDataObject.getOriginPoint("B", m_GmaeStateObject.getSeason(), round)
	local b_angle = m_StepDataObject.getOriginAngle("B", m_GmaeStateObject.getSeason(), round)
	
	--重置 a
	local a_role  = _getPlaceInfo("A")
	a_role.lua_setPosition(a_point)
	a_role.lua_setRotation(a_angle)
	
	--重置 b
	local b_role  = _getPlaceInfo("B")
	b_role.lua_setPosition(b_point)
	b_role.lua_setRotation(b_angle)
	
	local a_current_heroData = m_StepDataObject.getHeroCurrentData("A", m_GmaeStateObject.getSeason(), round)
	
	local b_current_heroData = m_StepDataObject.getHeroCurrentData("B", m_GmaeStateObject.getSeason(), round)
	
	--检测mt buff是否有漏掉显示
	a_role.lua_CheckBuffDisplay(a_current_heroData.buffs)
	
	--检测at buff是否有漏掉显示
	b_role.lua_CheckBuffDisplay(b_current_heroData.buffs)
	
	--播放
	if m_CanPlayAction then
		g_autoCallback.addCocosList(playAction, 0.5 / m_ScaleTime)
	end
	
end


--播放
function playAction()
	if m_StepDataObject == nil or m_A_Role == nil or m_B_Role == nil then
		return
	end
	if m_isJump then
		return
	end	
	local first = m_StepDataObject.getFirst(m_GmaeStateObject.getSeason())
	
	
	local f_place = first == 1 and "A" or "B"
	
	local s_place = first == 2 and "A" or "B"
	
	
	local f_role = _getPlaceInfo(f_place)
	
	local s_role = _getPlaceInfo(s_place)
	
	
	local f_attack_configId , f_skill_configId
	do
		local f_current_heroData = m_StepDataObject.getHeroCurrentData(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
		f_attack_configId = f_current_heroData.attack_configId
		f_skill_configId = f_current_heroData.skill_configId
	end
	
	local s_attack_configId , s_skill_configId
	do
		local s_current_heroData = m_StepDataObject.getHeroCurrentData(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())	
		s_attack_configId = s_current_heroData.attack_configId
		s_skill_configId = s_current_heroData.skill_configId
	end
	
	
	local f_atk_play_data = m_StepDataObject.getAtkPlayData(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local f_roundEnd_play_data = m_StepDataObject.getRoundEndPlayData(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local s_atk_play_data = m_StepDataObject.getAtkPlayData(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local s_roundEnd_play_data = m_StepDataObject.getRoundEndPlayData(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	
	local hasNextRound = m_StepDataObject.testNextRound(m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local hasNextSeason = m_StepDataObject.testNextSeason(m_GmaeStateObject.getSeason())
	
	
	--下一步骤
	local function playNextStep()
		if m_isJump then
			return
		end
		if hasNextRound then
			--下一回合
			nextRound()
		elseif hasNextSeason then
			--下一场次
			nextSeason()
		else
			--结束播放
			onPlayEnd()
		end
	end
	
	
	--播放双方回合末信息以及buff
	local function playEndOfTurnAllBuff()
		
		local played = false
		local function onEndOfTurnComplete()
			if not played then
				played = true
				g_autoCallback.addCocosList(playNextStep , 0.3 / m_ScaleTime)
			end
		end
		
		local death_count = 0	--回合末死亡的个数
		
		if (not f_atk_play_data.action_death) and (not f_atk_play_data.action_hit_death) then
			--攻击完成后还活着才进行如下播放
			
			--处理回合末buff播放
			for k , v in pairs(f_roundEnd_play_data.subBuffs) do
				f_role.lua_RemoveBuffDisplay(k)
			end
			
			if f_roundEnd_play_data.action_death then
				--先手方buff死亡
				death_count = death_count + 1
				f_role.lua_Play_Death(nil, function () death_count = death_count - 1 if death_count <= 0 then onEndOfTurnComplete() end end)
			end
			
		else
			--先手方攻击时死亡,删除所有buff效果
			f_role.lua_RemoveAllBuffDisplay()
		end
		
		if (not s_atk_play_data.action_death) and (not s_atk_play_data.action_hit_death) then
			--攻击完成后还活着才进行如下播放
			
			--处理回合末buff播放
			for k , v in pairs(s_roundEnd_play_data.subBuffs) do
				s_role.lua_RemoveBuffDisplay(k)
			end
			
			if s_roundEnd_play_data.action_death then
				--后手方buff死亡
				death_count = death_count + 1
				s_role.lua_Play_Death(nil, function () death_count = death_count - 1 if death_count <= 0 then onEndOfTurnComplete() end end)
			end
			
		else
			--后手方攻击时死亡,删除所有buff效果
			s_role.lua_RemoveAllBuffDisplay()
		end
		
		if death_count <= 0 then
			g_autoCallback.addCocosList(onEndOfTurnComplete , 0.0)
		end
	end
	
	local secondEndCount = 0 --播放完成计数器,需要动作和特效都完成
	
	--后手方攻击动作完成
	local function onSecondAtkEnd()
		secondEndCount = secondEndCount + 1
		if secondEndCount >= 2 then
			if s_atk_play_data.action_hit_death then
				s_role.lua_Play_Death(nil, nil)
			end
			--进入回合末buff播放
			g_autoCallback.addCocosList(playEndOfTurnAllBuff , 0.0)
		end
	end
	
	--后手方流水线播放完成
	local function onSecondPipeliningComplete()
		secondEndCount = secondEndCount + 1
		--后手方主动加buff播放
		for k , v in pairs(s_atk_play_data.addBuffs_after_self) do
			s_role.lua_AddBuffDisplay(k)
		end
		--后手方主动减buff播放
		for k , v in pairs(s_atk_play_data.subBuffs_after_self) do
			s_role.lua_RemoveBuffDisplay(k)
		end
		--先手方被动加buff播放
		for k , v in pairs(f_atk_play_data.addBuffs_after_target) do
			f_role.lua_AddBuffDisplay(k)
		end
		--先手方被动减buff播放
		for k , v in pairs(f_atk_play_data.subBuffs_after_target) do
			f_role.lua_RemoveBuffDisplay(k)
		end
		if secondEndCount >= 2 then
			if s_atk_play_data.action_hit_death then
				s_role.lua_Play_Death(nil, nil)
			end
			--进入回合末buff播放
			g_autoCallback.addCocosList(playEndOfTurnAllBuff , 0.0)
		end
	end
	
	--后手攻击帧(如果有特效就是特效攻击帧)
	local function onSecondAtkFrame()
		if s_atk_play_data.action_hit then
		--命中
			f_role.lua_PlayHurtEffect()
			if f_atk_play_data.action_death then
				f_role.lua_Play_Blow(nil, nil, true, onSecondPipeliningComplete)
			else
				f_role.lua_Play_Blow(nil, onSecondPipeliningComplete, false, nil)
			end
			
			--飘字
			m_AtkEffectRoot:addChild(helpModelMD.createSubHpText(f_atk_play_data.hit_hp  , f_role.lua_getPosition(), s_role.lua_getPosition()))
			
			--面板扣血
			if f_place == "A" then
				m_SurfaceTop.lua_setLeftHP(f_atk_play_data.after_blow_cur_hp, f_atk_play_data.before_max_hp)
			else
				m_SurfaceTop.lua_setRightHP(f_atk_play_data.after_blow_cur_hp, f_atk_play_data.before_max_hp)
			end
			
            --面板回血
            if f_atk_play_data.action_back_hit_hp then
                m_AtkEffectRoot:addChild(helpModelMD.createPlusHpText(f_atk_play_data.back_hp , f_role.lua_getPosition(), s_role.lua_getPosition()))
                if f_place == "A" then
				    m_SurfaceTop.lua_setLeftHP(f_atk_play_data.after_blow_cur_hp, f_atk_play_data.before_max_hp)
			    else
				    m_SurfaceTop.lua_setRightHP(f_atk_play_data.after_blow_cur_hp, f_atk_play_data.before_max_hp)
			    end
            end

            --回血
            if s_atk_play_data.action_back_hp then
                m_AtkEffectRoot:addChild(helpModelMD.createPlusHpText( s_atk_play_data.back_hp , s_role.lua_getPosition(), f_role.lua_getPosition()))
                if s_place == "A" then
					m_SurfaceTop.lua_setLeftHP(s_atk_play_data.after_hit_cur_hp, s_atk_play_data.before_max_hp)
				else
					m_SurfaceTop.lua_setRightHP(s_atk_play_data.after_hit_cur_hp, s_atk_play_data.before_max_hp)
				end
            end 

            --扣血
			if s_atk_play_data.action_hit_change_hp then
				--飘字
				m_AtkEffectRoot:addChild(helpModelMD.createSubHpText(s_atk_play_data.hit_hp, s_role.lua_getPosition(), f_role.lua_getPosition()))
				--面板扣血
				if s_place == "A" then
					m_SurfaceTop.lua_setLeftHP(s_atk_play_data.after_hit_cur_hp, s_atk_play_data.before_max_hp)
				else
					m_SurfaceTop.lua_setRightHP(s_atk_play_data.after_hit_cur_hp, s_atk_play_data.before_max_hp)
				end
			end

		else
		--未命中
			if f_atk_play_data.action_death then
				f_role.lua_Play_Death(nil, onSecondPipeliningComplete)
			else
				g_autoCallback.addCocosList(onSecondPipeliningComplete , 0.0)
			end
		end
		
		--后手方主动加buff播放
		for k , v in pairs(s_atk_play_data.addBuffs_before_self) do
			s_role.lua_AddBuffDisplay(k)
		end
		--后手方主动减buff播放
		for k , v in pairs(s_atk_play_data.subBuffs_before_self) do
			s_role.lua_RemoveBuffDisplay(k)
		end
		--先手方被动加buff播放
		for k , v in pairs(f_atk_play_data.addBuffs_before_target) do
			f_role.lua_AddBuffDisplay(k)
		end
		--先手方被动减buff播放
		for k , v in pairs(f_atk_play_data.subBuffs_before_target) do
			f_role.lua_RemoveBuffDisplay(k)
		end
		
		--张辽技能
		if s_atk_play_data.action_skill and ( s_skill_configId == helpModelMD.ZHANGLIAO_SKILL or s_skill_configId == helpModelMD.XIAHOUDUN_SKILL ) then
			s_role.lua_setPosition(s_atk_play_data.atk_teleporting_pos)
			s_role.lua_setRotation(s_atk_play_data.atk_teleporting_angle)
		end
		
	end
	
	--播放后手方攻击
	local function playSecondAtk()
		if m_isJump then
			return
		end
		if s_atk_play_data.action_attack then
			--后手方普通攻击
			local configData = g_data.duel_skill[s_attack_configId]
			local skillNameAir = helpModelMD.createSkillNameAirImage(configData ,s_atk_play_data.move_pos)
			if skillNameAir then
				m_AtkEffectRoot:addChild(skillNameAir)
			end
			if configData.skill_src_res ~= 0 then
				--有起手特效
				playAtkEffect(configData, onSecondAtkFrame, s_atk_play_data.move_pos, f_atk_play_data.move_pos
					, s_atk_play_data.action_hit, s_atk_play_data.atk_angle, s_atk_play_data.attack_min_range, s_atk_play_data.attack_max_range)
				helpModelMD.playSound(configData.atk_ae)
				s_role.lua_Play_Attack(s_atk_play_data.atk_angle, nil, onSecondAtkEnd)
			else
				--无起手特效
				local function onRoleAtkFrame()
					local hasCallback = playAtkEffect(configData, onSecondAtkFrame, s_atk_play_data.move_pos, f_atk_play_data.move_pos
						, s_atk_play_data.action_hit, s_atk_play_data.atk_angle, s_atk_play_data.attack_min_range, s_atk_play_data.attack_max_range)
					if not hasCallback then
						g_autoCallback.addCocosList(onSecondAtkFrame , 0.0)
					end
				end
				helpModelMD.playSound(configData.atk_ae)
				s_role.lua_Play_Attack(s_atk_play_data.atk_angle, onRoleAtkFrame, onSecondAtkEnd)
			end
		elseif s_atk_play_data.action_skill then
			--后手方技能攻击
			local configData = g_data.duel_skill[s_skill_configId]
			local skillNameAir = helpModelMD.createSkillNameAirImage(configData ,s_atk_play_data.move_pos)
			if skillNameAir then
				m_AtkEffectRoot:addChild(skillNameAir)
			end
			if configData.skill_src_res ~= 0 then
				--有起手特效
				playAtkEffect(configData, onSecondAtkFrame, s_atk_play_data.move_pos, f_atk_play_data.move_pos
					, s_atk_play_data.action_hit, s_atk_play_data.atk_angle, s_atk_play_data.skill_min_range, s_atk_play_data.skill_max_range)
				helpModelMD.playSound(configData.atk_ae)
				s_role.lua_Play_Skill(s_atk_play_data.atk_angle, nil, onSecondAtkEnd)
			else
				--无起手特效
				local function onRoleAtkFrame()
					local hasCallback = playAtkEffect(configData, onSecondAtkFrame, s_atk_play_data.move_pos, f_atk_play_data.move_pos
						, s_atk_play_data.action_hit, s_atk_play_data.atk_angle, s_atk_play_data.skill_min_range, s_atk_play_data.skill_max_range)
					if not hasCallback then
						g_autoCallback.addCocosList(onSecondAtkFrame , 0.0)
					end
				end
				helpModelMD.playSound(configData.atk_ae)
				s_role.lua_Play_Skill(s_atk_play_data.atk_angle, onRoleAtkFrame, onSecondAtkEnd)
			end
		else
			--后手方愣
			g_autoCallback.addCocosList(onSecondAtkEnd , 0.0)
			g_autoCallback.addCocosList(onSecondPipeliningComplete , 0.0)
		end
	end
	
	local firstEndCount = 0 --播放完成计数器,需要动作和特效都完成
	
	--先手方攻击动作完成
	local function onFirstAtkEnd()
		firstEndCount = firstEndCount + 1
		if firstEndCount >= 2 then
			if s_atk_play_data.action_death or f_atk_play_data.action_hit_death then
				if f_atk_play_data.action_hit_death then
					f_role.lua_Play_Death(nil, nil)
				end
				--某一方死亡就进入回合末buff播放
				g_autoCallback.addCocosList(playEndOfTurnAllBuff , 0.0)
			else
				--播放后手方攻击
				g_autoCallback.addCocosList( playSecondAtk , 0.25 / m_ScaleTime)
			end
		end
	end
	
	--先手方流水线播放完成
	local function onFirstPipeliningComplete()
		firstEndCount = firstEndCount + 1
		--先手方主动加buff播放
		for k , v in pairs(f_atk_play_data.addBuffs_after_self) do
			f_role.lua_AddBuffDisplay(k)
		end
		--先手方主动减buff播放
		for k , v in pairs(f_atk_play_data.subBuffs_after_self) do
			f_role.lua_RemoveBuffDisplay(k)
		end
		--后手方被动加buff播放
		for k , v in pairs(s_atk_play_data.addBuffs_after_target) do
			s_role.lua_AddBuffDisplay(k)
		end
		--后手方被动减buff播放
		for k , v in pairs(s_atk_play_data.subBuffs_after_target) do
			s_role.lua_RemoveBuffDisplay(k)
		end
		if firstEndCount >= 2 then
			if s_atk_play_data.action_death or f_atk_play_data.action_hit_death then
				if f_atk_play_data.action_hit_death then
					f_role.lua_Play_Death(nil, nil)
				end
				--某一方死亡就进入回合末buff播放
				g_autoCallback.addCocosList(playEndOfTurnAllBuff , 0.0)
			else
				--播放后手方攻击
				g_autoCallback.addCocosList( playSecondAtk , 0.25 / m_ScaleTime)
			end
		end
	end
	
	--先手攻击帧(如果有特效就是特效攻击帧)
	local function onFirstAtkFrame()
		if f_atk_play_data.action_hit then
		--命中
			s_role.lua_PlayHurtEffect()
			if s_atk_play_data.action_death then
				s_role.lua_Play_Blow(nil, nil, true, onFirstPipeliningComplete)
			else
				s_role.lua_Play_Blow(nil, onFirstPipeliningComplete, false, nil)
			end
			
			--飘字
			m_AtkEffectRoot:addChild(helpModelMD.createSubHpText(s_atk_play_data.hit_hp , s_role.lua_getPosition(), f_role.lua_getPosition()))
			
			--面板扣血
			if s_place == "A" then
				m_SurfaceTop.lua_setLeftHP(s_atk_play_data.after_blow_cur_hp, s_atk_play_data.before_max_hp)
			else
				m_SurfaceTop.lua_setRightHP(s_atk_play_data.after_blow_cur_hp, s_atk_play_data.before_max_hp)
			end
			
            if s_atk_play_data.action_back_hit_hp then
                m_AtkEffectRoot:addChild(helpModelMD.createPlusHpText(s_atk_play_data.back_hp , s_role.lua_getPosition(), f_role.lua_getPosition()))
                if s_place == "A" then
				    m_SurfaceTop.lua_setLeftHP(s_atk_play_data.after_blow_cur_hp, s_atk_play_data.before_max_hp)
			    else
				    m_SurfaceTop.lua_setRightHP(s_atk_play_data.after_blow_cur_hp, s_atk_play_data.before_max_hp)
			    end
            end

            --回血
            if f_atk_play_data.action_back_hp then
                m_AtkEffectRoot:addChild(helpModelMD.createPlusHpText( f_atk_play_data.back_hp , f_role.lua_getPosition(), s_role.lua_getPosition()))
                if f_place == "A" then
					m_SurfaceTop.lua_setLeftHP(f_atk_play_data.after_hit_cur_hp, f_atk_play_data.before_max_hp)
				else
					m_SurfaceTop.lua_setRightHP(f_atk_play_data.after_hit_cur_hp, f_atk_play_data.before_max_hp)
				end
            end

            --扣血
			if f_atk_play_data.action_hit_change_hp then
				--飘字
				m_AtkEffectRoot:addChild(helpModelMD.createSubHpText( f_atk_play_data.hit_hp, f_role.lua_getPosition(), s_role.lua_getPosition()))
				--面板扣血
				if f_place == "A" then
					m_SurfaceTop.lua_setLeftHP(f_atk_play_data.after_hit_cur_hp, f_atk_play_data.before_max_hp)
				else
					m_SurfaceTop.lua_setRightHP(f_atk_play_data.after_hit_cur_hp, f_atk_play_data.before_max_hp)
				end
			end

		else
		--未命中
			if s_atk_play_data.action_death then
				s_role.lua_Play_Death(nil, onFirstPipeliningComplete)
			else
				g_autoCallback.addCocosList(onFirstPipeliningComplete , 0.0)
			end
		end
		
		--先手方主动加buff播放
		for k , v in pairs(f_atk_play_data.addBuffs_before_self) do
			f_role.lua_AddBuffDisplay(k)
		end
		--先手方主动减buff播放
		for k , v in pairs(f_atk_play_data.subBuffs_before_self) do
			f_role.lua_RemoveBuffDisplay(k)
		end
		--后手方被动加buff播放
		for k , v in pairs(s_atk_play_data.addBuffs_before_target) do
			s_role.lua_AddBuffDisplay(k)
		end
		--后手方被动减buff播放
		for k , v in pairs(s_atk_play_data.subBuffs_before_target) do
			s_role.lua_RemoveBuffDisplay(k)
		end
		
		--张辽技能
		if f_atk_play_data.action_skill and (f_skill_configId == helpModelMD.ZHANGLIAO_SKILL or f_skill_configId == helpModelMD.XIAHOUDUN_SKILL) then
			f_role.lua_setPosition(f_atk_play_data.atk_teleporting_pos)
			f_role.lua_setRotation(f_atk_play_data.atk_teleporting_angle)
		end
		
	end
	
	--双方都移动结束
	local function onAllMoveComplete()
        
        if f_atk_play_data.action_move_change_hp then
            m_AtkEffectRoot:addChild(helpModelMD.createSubHpText(f_atk_play_data.before_move_end_hp, f_role.lua_getPosition(), s_role.lua_getPosition()))
            --面板扣血
		    if f_place == "A" then
			    m_SurfaceTop.lua_setLeftHP(f_atk_play_data.move_blow_cur_hp, f_atk_play_data.before_max_hp)
		    else
			    m_SurfaceTop.lua_setRightHP(f_atk_play_data.move_blow_cur_hp, f_atk_play_data.before_max_hp)
		    end
        end
        
        if s_atk_play_data.action_move_change_hp then
            m_AtkEffectRoot:addChild(helpModelMD.createSubHpText(s_atk_play_data.before_move_end_hp, s_role.lua_getPosition(), f_role.lua_getPosition()))
            --面板扣血
		    if s_place == "A" then
			    m_SurfaceTop.lua_setLeftHP(s_atk_play_data.move_blow_cur_hp, s_atk_play_data.before_max_hp)
		    else
			    m_SurfaceTop.lua_setRightHP(s_atk_play_data.move_blow_cur_hp , s_atk_play_data.before_max_hp)
		    end
        end

        if f_atk_play_data.action_move_back_hp then
            m_AtkEffectRoot:addChild(helpModelMD.createPlusHpText( f_atk_play_data.back_hp , f_role.lua_getPosition(), s_role.lua_getPosition()))
            if f_place == "A" then
				m_SurfaceTop.lua_setLeftHP(f_atk_play_data.back_hp, f_atk_play_data.before_max_hp)
			else
				m_SurfaceTop.lua_setRightHP(f_atk_play_data.back_hp, f_atk_play_data.before_max_hp)
			end
        end

        --移动后是否回血
        if s_atk_play_data.action_move_back_hp then
            m_AtkEffectRoot:addChild(helpModelMD.createPlusHpText( s_atk_play_data.back_hp , s_role.lua_getPosition(), f_role.lua_getPosition()))
            if s_place == "A" then
				m_SurfaceTop.lua_setLeftHP(s_atk_play_data.back_hp, s_atk_play_data.before_max_hp)
			else
				m_SurfaceTop.lua_setRightHP(s_atk_play_data.back_hp, s_atk_play_data.before_max_hp)
			end
        end

        --是否是掉血死亡
        if s_atk_play_data.action_diaoxue_death or f_atk_play_data.action_diaoxue_death then
            if s_atk_play_data.action_diaoxue_death then
                s_role.lua_Play_Death(nil, nil)
            end

            if f_atk_play_data.action_diaoxue_death then
                f_role.lua_Play_Death(nil, nil)
            end

            g_autoCallback.addCocosList(playEndOfTurnAllBuff , 0.0)
            return
        end
        
		if f_atk_play_data.action_attack then
			--先手方普通攻击
			local configData = g_data.duel_skill[f_attack_configId]
			local skillNameAir = helpModelMD.createSkillNameAirImage(configData ,f_atk_play_data.move_pos)
			if skillNameAir then
				m_AtkEffectRoot:addChild(skillNameAir)
			end
			if configData.skill_src_res ~= 0 then
				--有起手特效
				playAtkEffect(configData, onFirstAtkFrame, f_atk_play_data.move_pos, s_atk_play_data.move_pos, f_atk_play_data.action_hit
					, f_atk_play_data.atk_angle, f_atk_play_data.attack_min_range, f_atk_play_data.attack_max_range)
				helpModelMD.playSound(configData.atk_ae)
				f_role.lua_Play_Attack(f_atk_play_data.atk_angle, nil, onFirstAtkEnd)
			else
				--无起手特效
				local function onRoleAtkFrame()
					local hasCallback = playAtkEffect(configData, onFirstAtkFrame, f_atk_play_data.move_pos, s_atk_play_data.move_pos
						, f_atk_play_data.action_hit, f_atk_play_data.atk_angle, f_atk_play_data.attack_min_range, f_atk_play_data.attack_max_range)
					if not hasCallback then
						g_autoCallback.addCocosList(onFirstAtkFrame , 0.0)
					end
				end
				helpModelMD.playSound(configData.atk_ae)
				f_role.lua_Play_Attack(f_atk_play_data.atk_angle, onRoleAtkFrame, onFirstAtkEnd)
			end
		elseif f_atk_play_data.action_skill then
			--先手方技能攻击
			local configData = g_data.duel_skill[f_skill_configId]
			local skillNameAir = helpModelMD.createSkillNameAirImage(configData ,f_atk_play_data.move_pos)
			if skillNameAir then
				m_AtkEffectRoot:addChild(skillNameAir)
			end
			if configData.skill_src_res ~= 0 then
				--有起手特效
				playAtkEffect(configData, onFirstAtkFrame, f_atk_play_data.move_pos, s_atk_play_data.move_pos
					, f_atk_play_data.action_hit, f_atk_play_data.atk_angle, f_atk_play_data.skill_min_range, f_atk_play_data.skill_max_range)
				helpModelMD.playSound(configData.atk_ae)
				f_role.lua_Play_Skill(f_atk_play_data.atk_angle, nil, onFirstAtkEnd)
			else
				--无起手特效
				local function onRoleAtkFrame()
					local hasCallback = playAtkEffect(configData, onFirstAtkFrame, f_atk_play_data.move_pos, s_atk_play_data.move_pos
						, f_atk_play_data.action_hit, f_atk_play_data.atk_angle, f_atk_play_data.skill_min_range, f_atk_play_data.skill_max_range)
					if not hasCallback then
						g_autoCallback.addCocosList(onFirstAtkFrame , 0.0)
					end
				end
				helpModelMD.playSound(configData.atk_ae)
				f_role.lua_Play_Skill(f_atk_play_data.atk_angle, onRoleAtkFrame, onFirstAtkEnd)
			end
		else
			--先手方愣
			g_autoCallback.addCocosList(onFirstAtkEnd , 0.0)
			g_autoCallback.addCocosList(onFirstPipeliningComplete , 0.0)
		end
	end
	
	do	--移动
		local move_count = 2
		local function onFirstMoveComplete()
			f_role.lua_setRotation(f_atk_play_data.atk_angle)
			move_count = move_count - 1
			if move_count <= 0 then
				onAllMoveComplete()
			end
		end
		local function onSecondMoveComplete()
			s_role.lua_setRotation(s_atk_play_data.atk_angle)
			move_count = move_count - 1
			if move_count <= 0 then
				onAllMoveComplete()
			end
		end
		--f
		f_role.lua_setPosition(m_StepDataObject.getOriginPoint(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
		f_role.lua_setRotation(m_StepDataObject.getOriginAngle(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
		f_role.lua_MoveTo(f_atk_play_data.move_pos, onFirstMoveComplete)
		--s
		s_role.lua_setPosition(m_StepDataObject.getOriginPoint(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
		s_role.lua_setRotation(m_StepDataObject.getOriginAngle(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
		s_role.lua_MoveTo(s_atk_play_data.move_pos, onSecondMoveComplete)
	end
	
	
end


--获得双方武将初始数据
function getInitHeroData()
	if m_StepDataObject then
		return m_StepDataObject.getHeroInitData("A", 1)
				, m_StepDataObject.getHeroInitData("A", 2)
				, m_StepDataObject.getHeroInitData("A", 3)
				, m_StepDataObject.getHeroInitData("B", 1)
				, m_StepDataObject.getHeroInitData("B", 2)
				, m_StepDataObject.getHeroInitData("B", 3)
	end
end

--获得战斗结果数据
function getSeasonWin(season)
	if m_StepDataObject then
		return m_StepDataObject.getWin(season)
	end
end

--获得左边武将当前数据
function getCurrentLeftHeroData()
	if m_StepDataObject then
		return m_StepDataObject.getHeroCurrentData("A", m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	end
end

--获得右边武将当前数据
function getCurrentRightHeroData()
	if m_StepDataObject then
		return m_StepDataObject.getHeroCurrentData("B", m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	end
end

--获得双方名字
function getPlayerName()
	if m_ServerData then
		return {["A"] = m_ServerData.playerData_A.name , ["B"] = m_ServerData.playerData_B.name}
	end
end

--点击跳过
function onJumpButton()
	if m_isJump then
		return
	end
	m_isJump = true
	onPlayEnd()
end


--点击加速
function onChangeSpeedButton()
	if m_ScaleTime < helpModelMD.BESE_SCALE_TIME * 3 then
		m_ScaleTime = m_ScaleTime + helpModelMD.BESE_SCALE_TIME
	else
		m_ScaleTime = helpModelMD.BESE_SCALE_TIME
	end
	schedulerModelMD.setScaleTime(m_ScaleTime)
	return math.floor(m_ScaleTime / helpModelMD.BESE_SCALE_TIME + 0.001)
end


--进入下一回合
function nextRound()
	if m_GmaeStateObject then
		local function addRoundCallback()
			if m_GmaeStateObject and m_isJump == false then
				m_GmaeStateObject.addRound()
			end
		end
		g_autoCallback.addCocosList( addRoundCallback , 0.5 / m_ScaleTime)
	end
end

--进入下一场次
function nextSeason()
	if m_GmaeStateObject then
		local function addRoundCallback()
			if m_GmaeStateObject and m_isJump == false  then
				local armature , animation =  nil, nil
				local function onMovementEventCallFunc(armature, eventType, name)
					if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
						if name == "Guang" then
							m_GmaeStateObject.addSeason()
							cc.Director:getInstance():setNextDeltaTimeZero(true)
							animation:play("Kai")
						elseif name == "Kai" then
							armature:removeFromParent()
							local function playGoto()
								--开始播放
								m_CanPlayAction = true
								g_autoCallback.addCocosList(playAction, 0.5 / m_ScaleTime)
							end
							--播放场次数动画
							playAutoSceneEffect(
								"anime/Effect_LeiTaiGuoChangText_HuiHe/Effect_LeiTaiGuoChangText_HuiHe.ExportJson"
								, "Effect_LeiTaiGuoChangText_HuiHe"
								, "HuiHe_"..tostring(m_GmaeStateObject.getSeason())
								, playGoto
								)
						end
					end
				end
				--播放过场动画
				armature , animation = g_gameTools.LoadCocosAni("anime/Effect_LeiTaiGuoChang_KaiChang/Effect_LeiTaiGuoChang_KaiChang.ExportJson", "Effect_LeiTaiGuoChang_KaiChang", onMovementEventCallFunc, nil)
				schedulerModelMD.resetNodeSchedulerAndActionManage(armature)
				local left_node = cc.Node:create()
				left_node:setAnchorPoint(cc.p(0.5, 0.5))
				left_node:addChild(m_StepDataObject.getHeroAllIconSprite("A", m_GmaeStateObject.getSeason() + 1))
				armature:getBone("Layer6"):addDisplay(left_node, 0)
				local right_node = cc.Node:create()
				right_node:setAnchorPoint(cc.p(0.5, 0.5))
				right_node:addChild(m_StepDataObject.getHeroAllIconSprite("B", m_GmaeStateObject.getSeason() + 1))
				armature:getBone("Layer9"):addDisplay(right_node, 0)
				armature:setPosition(g_display.center)
				m_SceneEffectRoot:addChild(armature)
				animation:play("Guang")
			end
		end
		g_autoCallback.addCocosList( addRoundCallback , 0.5 / m_ScaleTime)
	end
end


--播放攻击特效return返回是否有攻击帧特效，如果没有就不会调用atkFrameCallback
function playAtkEffect(configData, atkFrameCallback, originPoint, targetPoint, hit, angle, minRange, maxRange)
	local func = atkFrameCallback
	
	local function playBlowEffect()
		if hit and configData.skill_dst_res ~= 0 then
			--受击特效
			helpModelMD.playSound(configData.skill_dst_ae)
			m_AtkEffectRoot:addChild(skillsModelMD.createSkill(configData.skill_dst_res, originPoint, targetPoint, nil, hit, angle, minRange, maxRange))
		end
		if configData.skill_orbit_res ~= 0 then
			--有中间特效
			if func then
				func = nil
				atkFrameCallback()
			end
		end
	end
	
	local function playCenterEffect()
		if configData.skill_orbit_res ~= 0 then
			--中间特效
			helpModelMD.playSound(configData.skill_orbit_ae)
			m_AtkEffectRoot:addChild(skillsModelMD.createSkill(configData.skill_orbit_res, originPoint, targetPoint, playBlowEffect, hit, angle, minRange, maxRange))
		else
			if configData.skill_src_res ~= 0 then
				--有起手特效，但没有中间特效
				if func then
					func = nil
					atkFrameCallback()
				end
			end
			playBlowEffect()
		end
	end
	
	if configData.skill_src_res ~= 0 then
		--起手特效
		helpModelMD.playSound(configData.skill_src_ae)
		m_AtkEffectRoot:addChild(skillsModelMD.createSkill(configData.skill_src_res, originPoint, targetPoint, playCenterEffect, hit, angle, minRange, maxRange))
	else
		playCenterEffect()
	end
	
	return (configData.skill_src_res ~= 0 or configData.skill_orbit_res ~= 0)
end


--播放自动场景特效
function playAutoSceneEffect(pathName, projName, animationName, completeCallback)
	if m_SceneEffectRoot then
		local function onMovementEventCallFunc(armature, eventType, name)
			if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
				armature:removeFromParent()
				if completeCallback then
					completeCallback()
				end
			end
		end
		local armature , animation = g_gameTools.LoadCocosAni(pathName, projName, onMovementEventCallFunc, nil)
		schedulerModelMD.resetNodeSchedulerAndActionManage(armature)
		armature:setPosition(g_display.center)
		m_SceneEffectRoot:addChild(armature)
		animation:play(animationName)
	end
end


--播放全部结束
function onPlayEnd()
	if not m_StepDataObject then
		return
	end
	if m_isPlayEnd then
		return
	end
	m_isPlayEnd = true
	
	--g_airBox.show(g_tr("tournament_backplayEnd"))
	g_autoCallback.addCocosList(delete, 3.0)
end


--双方一共6个武将阵容
function show(serverData)
	g_sceneManager.addNodeForUI(_create(serverData))
end


--关闭
function delete()
	if m_Root then
		m_Root:removeFromParent()
	end
end


return tournament_backplay