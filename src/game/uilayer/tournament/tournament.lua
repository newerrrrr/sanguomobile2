local tournament = {}
setmetatable(tournament,{__index = _G})
setfenv(1,tournament)

--武斗

--require("game.uilayer.tournament.tournament").show()

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

local c_touch_state = {
	no = 0,
	showAuto = 1,
	moveSelf = 2,
	atkAngle = 3,
	sklAngle = 4,
}

local MAX_ROUND = 20

local OPERATE_TIP_TIME = 2

local m_ScaleTime = helpModelMD.BESE_SCALE_TIME

local m_GmaeStateObject = nil
local m_OperateStateObject = nil
local m_StepDataObject = nil

local m_Root = nil

local m_BattleRoot = nil

local m_MapBottom = nil
local m_InfoRoot = nil
local m_RoleRoot = nil
local m_MapTop = nil
local m_AtkEffectRoot = nil
local m_MapGuideRoot = nil

local m_A_attackRange = nil
local m_A_attackRange_temp = nil --增加攻击范围的临时显示控件
local m_A_skillRange = nil
local m_A_moveRange = nil
local m_A_moveRange_temp = nil   --增加移动范围
local m_B_attackRange = nil
local m_B_attackRange_temp = nil --增加攻击范围的临时显示控件
local m_B_skillRange = nil
local m_B_moveRange = nil
local m_B_moveRange_temp = nil   --增加移动范围
local m_A_Role = nil
local m_B_Role = nil
local m_Manual_Role_Ghost = nil

local m_SurfaceRoot = nil

local m_SurfaceTop = nil
local m_SurfaceCancel = nil
local m_SurfaceSkill = nil
local m_SurfaceComplete = nil

local m_SceneEffectRoot = nil

local m_GuideEffectArmature_1 = nil
local m_GuideEffectAnimation_2 = nil

local m_TempAutomatic = false

local m_ManualPlace = "A"
local m_AutoPlace = "B"

local m_TouchState = c_touch_state.no

local m_ServerData = nil

local m_GuideAngleIsTiped = false

local m_Operate_tip_time = OPERATE_TIP_TIME

local function clearGlobal()
	math.randomseed(os.time())
	m_GmaeStateObject = nil
	m_OperateStateObject = nil
	m_StepDataObject = nil
	m_Root = nil
	m_BattleRoot = nil
	m_MapBottom = nil
	m_InfoRoot = nil
	m_RoleRoot = nil
	m_MapTop = nil
	m_AtkEffectRoot = nil
	m_MapGuideRoot = nil
	m_A_attackRange = nil
    m_A_attackRange_temp = nil
	m_A_skillRange = nil
	m_A_moveRange = nil
    m_A_moveRange_temp = nil
	m_B_attackRange = nil
	m_B_skillRange = nil
	m_B_moveRange = nil
	m_A_Role = nil
	m_B_Role = nil
	m_Manual_Role_Ghost = nil
	m_SurfaceRoot = nil
	m_SurfaceTop = nil
	m_SurfaceCancel = nil
	m_SurfaceSkill = nil
	m_SurfaceComplete = nil
	m_SurfaceAutomatic = nil
	m_SceneEffectRoot = nil
	m_GuideEffectArmature_1 = nil
	m_GuideEffectAnimation_2 = nil
	m_ManualPlace = "A"
	m_AutoPlace = "B"
	m_TouchState = c_touch_state.no
	m_ServerData = nil
	m_GuideAngleIsTiped = false
	m_Operate_tip_time = OPERATE_TIP_TIME
	
	m_TempAutomatic = false
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
	
	m_Operate_tip_time = OPERATE_TIP_TIME * (g_saveCache.tournament_count_save + 1)
	
	m_ServerData = clone(serverData)
	
	m_ManualPlace = m_ServerData.selfGroup == "A" and "A" or "B"
	m_AutoPlace = m_ServerData.selfGroup == "A" and "B" or "A"
	
	schedulerModelMD.ready()
	schedulerModelMD.setScaleTime(m_ScaleTime)
	
	m_GmaeStateObject = stateModelMD.createGmaeState()
	m_OperateStateObject = stateModelMD.createOperateState()
	
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
	
	--地图引导层
	m_MapGuideRoot = _createBattleChildNode()
	m_BattleRoot:addChild(m_MapGuideRoot, 6)
	
	--拖动及方向引导
	m_GuideEffectArmature_1 , m_GuideEffectAnimation_2 = g_gameTools.LoadCocosAni("anime/Effect_LeiTaiSaiZhiYin/Effect_LeiTaiSaiZhiYin.ExportJson", "Effect_LeiTaiSaiZhiYin", nil, nil)
	schedulerModelMD.resetNodeSchedulerAndActionManage(m_GuideEffectArmature_1)
	m_MapGuideRoot:addChild(m_GuideEffectArmature_1)
	m_GuideEffectArmature_1:setVisible(false)
	
	--测试顶点连线
	if cToolsForLua:isDebugVersion() then
		m_BattleRoot:addChild(mapModelMD.createDebug(mapConfigID), 999999999)
	end

	local touchListener = cc.EventListenerTouchOneByOne:create()
	touchListener:setSwallowTouches(true)
	touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	touchListener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, m_BattleRoot)
	
	------------------------------------------------------------
	
	--界面根节点
	m_SurfaceRoot = cc.Node:create()
	m_SurfaceRoot:setContentSize(g_display.size)
	m_SurfaceRoot:ignoreAnchorPointForPosition(false)
	m_SurfaceRoot:setAnchorPoint(cc.p(0.5, 0.5))
	m_SurfaceRoot:setPosition(g_display.center)
	rootLayer:addChild(m_SurfaceRoot, 2)
	
	--上面主界面
	m_SurfaceTop = surfaceModelMD.createTop(tournament)
	m_SurfaceRoot:addChild(m_SurfaceTop)

	--取消按钮界面
	m_SurfaceCancel = surfaceModelMD.createCancel()
	m_SurfaceRoot:addChild(m_SurfaceCancel)
	
	--技能按钮界面
	m_SurfaceSkill = surfaceModelMD.createSkill()
	m_SurfaceRoot:addChild(m_SurfaceSkill)
	
	--完成按钮界面
	m_SurfaceComplete = surfaceModelMD.createComplete()
	m_SurfaceRoot:addChild(m_SurfaceComplete)

	--自动按钮界面
	m_SurfaceAutomatic = surfaceModelMD.createAutomatic()
	m_SurfaceRoot:addChild(m_SurfaceAutomatic)
	if g_saveCache.tournament_count_save <= 3 then
		m_SurfaceAutomatic:setVisible(false)
	end
	
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
		m_SurfaceCancel.lua_onSeasonStateChange(season)
		m_SurfaceSkill.lua_onSeasonStateChange(season)
		m_SurfaceComplete.lua_onSeasonStateChange(season)
	end
	m_GmaeStateObject.setSeasonStateChangeNotice(seasonStateChangeNotice)
	
	
	--回合变化通知
	local function roundStateChangeNotice(round)
		onRoundStateNotice(round)
		m_SurfaceTop.lua_onRoundStateChange(round)
		m_SurfaceCancel.lua_onRoundStateChange(round)
		m_SurfaceSkill.lua_onRoundStateChange(round)
		m_SurfaceComplete.lua_onRoundStateChange(round)
	end
	m_GmaeStateObject.setRoundStateChangeNotice(roundStateChangeNotice)
	
	--设置到第一场第一回合
	m_GmaeStateObject.addSeason()
	
	
	--操作状态变化通知
	local function operateStateChangeNotice(operateState)
		onOperateStateNotice(operateState)
		m_SurfaceTop.lua_onOperateStateChange(operateState)
		m_SurfaceCancel.lua_onOperateStateChange(operateState)
		m_SurfaceSkill.lua_onOperateStateChange(operateState)
		m_SurfaceComplete.lua_onOperateStateChange(operateState)
	end
	m_OperateStateObject.setOperateStateChangeNotice(operateStateChangeNotice)
	
	--设置到准备状态
	m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.readying)
	
	local function playReadying()
		local function startControl()
			--开始操作
			m_A_Role.lua_PlayBuffWind()
			m_B_Role.lua_PlayBuffWind()
			if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.readying then
				m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.move)
			end
		end
		local function playGuildDialog()
			--引导对话框
			if g_saveCache.tournament_count_save >= 1 then
				startControl()
				return
			end
			local dialogConfig = g_data.duel_guide[m_GmaeStateObject.getSeason()]
			if dialogConfig == nil then
				startControl()
				return
			end
			local index = 1
			local function playGuildDialogStep()
				local dialogStepConfig = dialogConfig.steps[index]
				if dialogStepConfig == nil then
					startControl()
				else
					index = index + 1
					local guildDialog = require("game.uilayer.common.DialogueLayer"):create(
						g_tr(dialogStepConfig[1])
						, playGuildDialogStep
						, dialogStepConfig[2]
						)
					g_sceneManager.addNodeForUI(guildDialog)
				end
			end
			playGuildDialogStep()
		end
		local function playStart()
			--开始战斗动画
			playAutoSceneEffect(
				"anime/Effect_LeiTaiGuoChangText_ZhanDouKaiShi/Effect_LeiTaiGuoChangText_ZhanDouKaiShi.ExportJson"
				, "Effect_LeiTaiGuoChangText_ZhanDouKaiShi"
				, "ZhanDouKaiShi"
				, playGuildDialog
				)
		end
		local function playFirst()
			--播放先手方动画
			local season_first = m_StepDataObject.getFirst(m_GmaeStateObject.getSeason())
			local firstAniName = nil
			if season_first == 1 then
				firstAniName = ("A" == m_ManualPlace and "WoFanHuiHe" or "DuiFanHuiHe")
			elseif season_first == 2 then
				firstAniName = ("B" == m_ManualPlace and "WoFanHuiHe" or "DuiFanHuiHe")
			else
				firstAniName = "DuiFanHuiHe"
			end
			playAutoSceneEffect(
				"anime/Effect_LeiTaiGuoChangText_HuiHe/Effect_LeiTaiGuoChangText_HuiHe.ExportJson"
				, "Effect_LeiTaiGuoChangText_HuiHe"
				, firstAniName
				, playStart
				)
		end
		--播放场次数动画
		playAutoSceneEffect(
			"anime/Effect_LeiTaiGuoChangText_HuiHe/Effect_LeiTaiGuoChangText_HuiHe.ExportJson"
			, "Effect_LeiTaiGuoChangText_HuiHe"
			, "HuiHe_"..tostring(m_GmaeStateObject.getSeason())
			, playFirst
			)
	end
	g_autoCallback.addCocosList(playReadying, 1.5--[[ / m_ScaleTime--]])
	
	cc.Director:getInstance():setNextDeltaTimeZero(true)
	
	return rootLayer
end


--得到对应位置的信息
local function _getPlaceInfo(place)
	if place == "A" then
		return m_A_Role , m_A_moveRange , m_A_attackRange , m_A_skillRange
	elseif place == "B" then
		return m_B_Role , m_B_moveRange , m_B_attackRange , m_B_skillRange
	end
end


--重置位置信息展示根据角色
local function _resetRangeInfoDisplayWithRole(role , moveRange , attackRange , skillRange)
	local pos = role.lua_getPosition()
	local angle = role.lua_getRotation()
	if moveRange then
		moveRange.lua_setPosition(pos)
	end
	if attackRange then
		attackRange.lua_setPosition(pos)
		attackRange.lua_setRotation(angle)
	end
	if skillRange then
		skillRange.lua_setPosition(pos)
		skillRange.lua_setRotation(angle)
	end
end


--更新1
function update_1(dt)
	if m_OperateStateObject == nil or m_A_Role == nil or m_B_Role == nil then
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
	
	--更新对方范围，随时可能提示
	local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
	_resetRangeInfoDisplayWithRole(at_role, at_moveRange, at_attackRange, at_skillRange)
	
	--手动方
	local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
	
	--更新地图引导位置
	m_GuideEffectArmature_1:setPosition(mt_role.lua_getPosition())
	if m_GuideEffectArmature_1:isVisible() == false
		and not m_SurfaceComplete.lua_isShowGuild() 
			then
		local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())

        --眩晕
        local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
        --定身
        local has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.fixed)
        --没有眩晕
		if not has_buff_dizzy then
			if os.time() - m_LastOperateTime > OPERATE_TIP_TIME then
				if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.attack then
					if mt_current_heroData.attack_angle_range < 360 and m_GuideAngleIsTiped == false then
						m_GuideEffectArmature_1:setVisible(true)
						m_GuideEffectAnimation_2:play("Animation2", -1 , 1)
					end
				elseif m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.skill then
					if mt_current_heroData.skill_angle_range < 360 and m_GuideAngleIsTiped == false then
						m_GuideEffectArmature_1:setVisible(true)
						m_GuideEffectAnimation_2:play("Animation2", -1 , 1)
					end
				elseif m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.move then
                    --没有定身
                    if not has_buff_fixed then
					    m_GuideEffectArmature_1:setVisible(true)
					    m_GuideEffectAnimation_2:play("Animation1", -1 , 1)
                    end
				end
			end
		end
	end
	
	if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.attack then
		--攻击状态下更新攻击范围圈
		local angle = mt_role.lua_getRotation()
		mt_attackRange.lua_setRotation(angle)
	end
	
	if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.skill then
		--技能状态下更新技能范围圈
		if mt_skillRange then
			local angle = mt_role.lua_getRotation()
			mt_skillRange.lua_setRotation(angle)
		end
	end
	
	if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.move
		or m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.attack 
		or m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.skill
			then
		local pos1 = mt_role:lua_getPosition()
		local pos2 = m_Manual_Role_Ghost:lua_getPosition()
		local direction1 = mt_role:lua_getDirection()
		local direction2 = m_Manual_Role_Ghost:lua_getDirection()
		if pos1.x - 0.001 > pos2.x or pos1.x + 0.001 < pos2.x or pos1.y - 0.001 > pos2.y or pos1.y + 0.001 < pos2.y or direction1 ~= direction2 then
			m_Manual_Role_Ghost:setVisible(true)
			mt_role.lua_setOpacity(150)
		else
			m_Manual_Role_Ghost:setVisible(false)
			mt_role.lua_setOpacity(255)
		end
	else
		local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
		mt_role.lua_setOpacity(255)
		m_Manual_Role_Ghost:setVisible(false)
	end
	
	--update z order
	m_Manual_Role_Ghost.lua_UpdateZOrder(dt)
	m_A_Role.lua_UpdateZOrder(dt)
	m_B_Role.lua_UpdateZOrder(dt)
end


--初始化双方这一场次的角色
local function _createRole(a_hero, a_point, a_angle, b_hero, b_point, b_angle)
	if m_A_Role then
		m_A_Role:removeFromParent()
	end

	if m_A_moveRange then
		m_A_moveRange:removeFromParent()
	end

    if m_A_moveRange_temp then
        m_A_moveRange_temp:removeFromParent()
        m_A_moveRange_temp = nil
    end

	if m_A_attackRange then
		m_A_attackRange:removeFromParent()
	end

    if m_A_attackRange_temp then
        m_A_attackRange_temp:removeFromParent()
        m_A_attackRange_temp = nil
    end

	if m_A_skillRange then
		m_A_skillRange:removeFromParent()
	end

	if m_B_Role then
		m_B_Role:removeFromParent()
	end

	if m_B_moveRange then
		m_B_moveRange:removeFromParent()
	end

    if m_B_moveRange_temp then
        m_B_moveRange_temp:removeFromParent()
        m_B_moveRange_temp = nil
    end

	if m_B_attackRange then
		m_B_attackRange:removeFromParent()
	end

    if m_B_attackRange_temp then
        m_B_attackRange_temp:removeFromParent()
        m_B_attackRange_temp = nil
    end

	if m_B_skillRange then
		m_B_skillRange:removeFromParent()
	end
	if m_Manual_Role_Ghost then
		m_Manual_Role_Ghost:removeFromParent()
	end
	
	--A
	m_A_Role = roleModelMD.createRole(a_hero.model_res_id,"A")
	m_A_Role.lua_setPosition(a_point)
	m_A_Role.lua_setRotation(a_angle)
	m_RoleRoot:addChild(m_A_Role, 1)
	
	m_A_moveRange = helpModelMD.createMoveRange(a_hero.move_range)
	m_A_moveRange.lua_setPosition(a_point)
	m_A_moveRange:setVisible(false)
	m_InfoRoot:addChild(m_A_moveRange, 1)
	
	m_A_attackRange = helpModelMD.createAttackRange(a_hero.attack_min_range, a_hero.attack_max_range, a_hero.attack_angle_range)
	m_A_attackRange.lua_setPosition(a_point)
	m_A_attackRange.lua_setRotation(a_angle)
	m_A_attackRange:setVisible(false)
	m_InfoRoot:addChild(m_A_attackRange, 2)
	
	if a_hero.skill_configId ~= 0 then
		m_A_skillRange = helpModelMD.createSkillRange(a_hero.skill_min_range, a_hero.skill_max_range, a_hero.skill_angle_range)
		m_A_skillRange.lua_setPosition(a_point)
		m_A_skillRange.lua_setRotation(a_angle)
		m_A_skillRange:setVisible(false)
		m_InfoRoot:addChild(m_A_skillRange, 3)
	else
		m_A_skillRange = nil
	end
	
	--B
	m_B_Role = roleModelMD.createRole(b_hero.model_res_id,"B")
	m_B_Role.lua_setPosition(b_point)
	m_B_Role.lua_setRotation(b_angle)
	m_RoleRoot:addChild(m_B_Role, 1)
	
	m_B_moveRange = helpModelMD.createMoveRange(b_hero.move_range)
	m_B_moveRange.lua_setPosition(b_point)
	m_B_moveRange:setVisible(false)
	m_InfoRoot:addChild(m_B_moveRange, 1)
	
	m_B_attackRange = helpModelMD.createAttackRange(b_hero.attack_min_range, b_hero.attack_max_range, b_hero.attack_angle_range)
	m_B_attackRange.lua_setPosition(b_point)
	m_B_attackRange.lua_setRotation(b_angle)
	m_B_attackRange:setVisible(false)
	m_InfoRoot:addChild(m_B_attackRange, 2)
	
	if b_hero.skill_configId ~= 0 then
		m_B_skillRange = helpModelMD.createSkillRange(b_hero.skill_min_range, b_hero.skill_max_range, b_hero.skill_angle_range)
		m_B_skillRange.lua_setPosition(b_point)
		m_B_skillRange.lua_setRotation(b_angle)
		m_B_skillRange:setVisible(false)
		m_InfoRoot:addChild(m_B_skillRange, 3)
	else
		m_B_skillRange = nil
	end
	
	--ghost
	if m_ManualPlace == "A" then
		m_Manual_Role_Ghost = roleModelMD.createRole(a_hero.model_res_id,"A")
		m_Manual_Role_Ghost.lua_setPosition(a_point)
		m_Manual_Role_Ghost.lua_setRotation(a_angle)
		m_Manual_Role_Ghost:setVisible(false)
		m_RoleRoot:addChild(m_Manual_Role_Ghost, 1)
	elseif m_ManualPlace == "B" then
		m_Manual_Role_Ghost = roleModelMD.createRole(b_hero.model_res_id,"B")
		m_Manual_Role_Ghost.lua_setPosition(b_point)
		m_Manual_Role_Ghost.lua_setRotation(b_angle)
		m_Manual_Role_Ghost:setVisible(false)
		m_RoleRoot:addChild(m_Manual_Role_Ghost, 1)
	end
end


--场次变化通知
function onSeasonStateNotice(season)
	if season == 1 then
		--第一场初始化双方数据
		m_StepDataObject = stepDataModelMD.createNewData(m_ServerData["A"], m_ServerData["B"], m_MapBottom.lua_getLeftStartPoint(), m_MapBottom.lua_getLeftStartAngle(), m_MapBottom.lua_getRightStartPoint(), m_MapBottom.lua_getRightStartAngle())
	    --m_StepDataObject.SetXunYuSkill("A")
    end
	
	--创建本场角色与范围信息
	_createRole(
		m_StepDataObject.stepData.A["hero_"..tostring(season)]
		, m_StepDataObject.stepData.A.startPoint
		, m_StepDataObject.stepData.A.startAngle
		, m_StepDataObject.stepData.B["hero_"..tostring(season)]
		, m_StepDataObject.stepData.B.startPoint
		, m_StepDataObject.stepData.B.startAngle
		)
	
	--每场开始时取消自动战斗状态
	--m_SurfaceAutomatic.lua_setAutomatic(false)
end



--回合变化通知
function onRoundStateNotice(round)
	m_GuideEffectArmature_1:setVisible(false)
	m_LastOperateTime = os.time()
	m_SurfaceComplete.lua_setShowGuild(false)
	
	--初始化回合数据
	m_StepDataObject.newRound(m_GmaeStateObject.getSeason(), round)
	
	local mt_point = m_StepDataObject.getOriginPoint(m_ManualPlace, m_GmaeStateObject.getSeason(), round)
	local mt_angle = m_StepDataObject.getOriginAngle(m_ManualPlace, m_GmaeStateObject.getSeason(), round)
	
	local at_point = m_StepDataObject.getOriginPoint(m_AutoPlace, m_GmaeStateObject.getSeason(), round)
	local at_angle = m_StepDataObject.getOriginAngle(m_AutoPlace, m_GmaeStateObject.getSeason(), round)
	
	--重置 mt
	local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
	mt_role.lua_setPosition(mt_point)
	mt_role.lua_setRotation(mt_angle)
	mt_moveRange.lua_setPosition(mt_point)
	
	--重置 残影
	m_Manual_Role_Ghost.lua_setPosition(mt_point)
	m_Manual_Role_Ghost.lua_setRotation(mt_angle)
	
	--重置 at
	local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
	at_role.lua_setPosition(at_point)
	at_role.lua_setRotation(at_angle)
	at_moveRange.lua_setPosition(at_point)
	
	local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), round)
	
	local at_current_heroData = m_StepDataObject.getHeroCurrentData(m_AutoPlace, m_GmaeStateObject.getSeason(), round)
	
	--检测mt buff是否有漏掉显示
	mt_role.lua_CheckBuffDisplay(mt_current_heroData.buffs)
	
	--检测at buff是否有漏掉显示
	at_role.lua_CheckBuffDisplay(at_current_heroData.buffs)
	
	--眩晕
	local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
    --定身
    local has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.fixed)
    
	if not m_SurfaceAutomatic.lua_Automatic() then
		--非自动战斗
		m_TempAutomatic = false
        --眩晕
		if has_buff_dizzy then
			local function jumpAttack()
				m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.attack)
			end
			g_autoCallback.addCocosList(jumpAttack, 0.0 / m_ScaleTime)
		end
        --定身
        if has_buff_fixed then
            local function jumpAttack()
				m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.attack)
			end
			g_autoCallback.addCocosList(jumpAttack, 0.0 / m_ScaleTime)
        end
	else
		--自动战斗
		m_TempAutomatic = true
		local function jumpAuto()
			--计算自动AI
			
			local at_hero_data = m_StepDataObject.getHeroCurrentData(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
			
			local mt_hero_data = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
			
			local at_can_move = true
			
			local at_can_attack = true
			
			local at_can_skill = at_hero_data.skill_configId ~= 0 and at_hero_data.skill_need_sp <= at_hero_data.hero_current_sp
			
			local mt_can_move = true
			
			local mt_can_attack = true
			
			local mt_can_skill = mt_hero_data.skill_configId ~= 0 and mt_hero_data.skill_need_sp <= mt_hero_data.hero_current_sp
			
			
			--眩晕
			local at_has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(at_hero_data, buffsModelMD.m_BuffType.dizzy)
			if at_has_buff_dizzy then
				at_can_move = false
				at_can_attack = false
				at_can_skill = false
			end

			--眩晕
			local mt_has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_hero_data, buffsModelMD.m_BuffType.dizzy)
			if mt_has_buff_dizzy then
				mt_can_move = false
				mt_can_attack = false
				mt_can_skill = false
			end

            --定身
            local at_has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(at_hero_data, buffsModelMD.m_BuffType.fixed)
            if at_has_buff_fixed then
			    at_can_move = false
            end

            --定身
            local mt_has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_hero_data, buffsModelMD.m_BuffType.fixed)
            if mt_has_buff_fixed then
			    mt_can_move = false
            end

            local mt_add_move_range = stepDataModelMD.getBuffValue(mt_hero_data,mt_hero_data,nil,buffsModelMD.m_BuffType.addMoveRange)

            local at_add_move_range = stepDataModelMD.getBuffValue(at_hero_data,at_hero_data,nil,buffsModelMD.m_BuffType.addMoveRange)

			local point1 , angle1 , skill1 , point2 , angle2 , skill2 = AIModelMD.AI_operate_point_angle_skill_automatic(
				m_ServerData[m_ManualPlace].duel_rank_id
				, mt_hero_data.move_range + mt_add_move_range
				, mt_can_move
				, mt_hero_data.weapon_type
				, mt_hero_data.attack_min_range
				, mt_hero_data.attack_max_range
				, mt_hero_data.attack_angle_range
				, mt_can_attack
				, mt_hero_data.skill_min_range
				, mt_hero_data.skill_max_range
				, mt_hero_data.skill_angle_range
				, mt_can_skill
				, clone(m_StepDataObject.getOriginPoint(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				, clone(m_StepDataObject.getOriginAngle(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				
				, m_ServerData[m_AutoPlace].duel_rank_id
				, at_hero_data.move_range + at_add_move_range
				, at_can_move
				, at_hero_data.weapon_type
				, at_hero_data.attack_min_range
				, at_hero_data.attack_max_range
				, at_hero_data.attack_angle_range
				, at_can_attack
				, at_hero_data.skill_min_range
				, at_hero_data.skill_max_range
				, at_hero_data.skill_angle_range
				, at_can_skill
				, clone(m_StepDataObject.getOriginPoint(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				, clone(m_StepDataObject.getOriginAngle(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				
				, clone(helpModelMD.m_RoleRadius)
				, clone(helpModelMD.m_MoveSinDivCos)
				, checkMapPoint			
			)
			
			local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
			if mt_role then
				--写入自动操作
				m_StepDataObject.setOperatePoint(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), point1)
				m_StepDataObject.setOperateAngle(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), angle1)
				m_StepDataObject.setOperateSkill(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), skill1)
			end
			
			--写入AI操作
			m_StepDataObject.setOperatePoint(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), point2)
			m_StepDataObject.setOperateAngle(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), angle2)
			m_StepDataObject.setOperateSkill(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), skill2)
			
			m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.waitPlay)
			
		end
		g_autoCallback.addCocosList(jumpAuto, 0.0 / m_ScaleTime)
	end
	
end


--操作状态变化通知
function onOperateStateNotice(state)
	m_GuideEffectArmature_1:setVisible(false)
	m_LastOperateTime = os.time()
	m_SurfaceComplete.lua_setShowGuild(false)
	
	local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
	local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
		at_moveRange:setVisible(false)
        if m_B_moveRange_temp then
            m_B_moveRange_temp:setVisible(false)
        end
		at_attackRange:setVisible(false)
		if at_skillRange then
			at_skillRange:setVisible(false)
		end
	if state == stateModelMD.m_OperateState.readying then
		mt_moveRange:setVisible(false)
		mt_attackRange:setVisible(false)
		if mt_skillRange then
			mt_skillRange:setVisible(false)
		end
	elseif state == stateModelMD.m_OperateState.move then
		
		mt_attackRange:setVisible(false)
		if mt_skillRange then
			mt_skillRange:setVisible(false)
		end

        if m_A_moveRange_temp then
            m_A_moveRange_temp:removeFromParent()
            m_A_moveRange_temp = nil
        end
        
        local addVar = stepDataModelMD.getBuffValue( mt_current_heroData,mt_current_heroData,nil,buffsModelMD.m_BuffType.addMoveRange)
        if addVar > 0 then
            if m_A_moveRange_temp == nil then
                m_A_moveRange_temp = helpModelMD.createMoveRange(mt_current_heroData.move_range + addVar)
	            m_A_moveRange_temp.lua_setPosition(mt_role.lua_getPosition())
	            m_InfoRoot:addChild(m_A_moveRange_temp, 1)
            end
        else
            mt_moveRange:setVisible(true)
        end
		
		--眩晕
		local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
		if has_buff_dizzy then
			mt_moveRange:setVisible(false)
            if m_A_moveRange_temp then
                m_A_moveRange_temp:setVisible(false)
            end
		end
        --定身
        local has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.fixed)
        if has_buff_fixed then
			mt_moveRange:setVisible(false)
            if m_A_moveRange_temp then
                m_A_moveRange_temp:setVisible(false)
            end
		end
        
	elseif state == stateModelMD.m_OperateState.attack then
		mt_moveRange:setVisible(false)
        if m_A_moveRange_temp then
            m_A_moveRange_temp:setVisible(false)
        end

        if m_A_moveRange_temp then
            m_A_moveRange_temp:setVisible(false)
        end
        --mt_attackRange:setVisible(true)

		if mt_skillRange then
			mt_skillRange:setVisible(false)
		end

		--将 mt_attackRange 位置设置到当前位置
		local pos = mt_role.lua_getPosition()
		local angle = mt_role.lua_getRotation()
		if mt_attackRange then
			mt_attackRange.lua_setPosition(pos)
			mt_attackRange.lua_setRotation(angle)
		end

        if m_A_attackRange_temp then
            m_A_attackRange_temp:removeFromParent()
            m_A_attackRange_temp = nil
        end
        
        --local has_buff_addAtkRange = stepDataModelMD.findBuffWithTypeId(mt_current_heroData,buffsModelMD.m_BuffType.addAtkRange)
        local addVar = stepDataModelMD.getBuffValue( mt_current_heroData,mt_current_heroData,nil,buffsModelMD.m_BuffType.addAtkRange)

        if addVar > 0 then
            if m_A_attackRange_temp == nil then
                m_A_attackRange_temp = helpModelMD.createAttackRange(mt_current_heroData.attack_min_range, (mt_current_heroData.attack_max_range + addVar), mt_current_heroData.attack_angle_range )
	            m_A_attackRange_temp.lua_setPosition(pos)
	            m_A_attackRange_temp.lua_setRotation(angle)
	            m_A_attackRange_temp:setVisible(true)
	            m_InfoRoot:addChild(m_A_attackRange_temp, 2)
            end
        else
            mt_attackRange:setVisible(true)
        end
        
		
		--还未进行范围引导
		m_GuideAngleIsTiped = false
		
		--眩晕
		local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
		if has_buff_dizzy then
			mt_attackRange:setVisible(false)
			m_SurfaceComplete.lua_setShowGuild(true)
		end
		
		if mt_current_heroData.attack_angle_range >= 360 then
			if mt_current_heroData.skill_configId == 0 or mt_current_heroData.hero_current_sp < mt_current_heroData.skill_need_sp then
				--不能放技能
				m_SurfaceComplete.lua_setShowGuild(true) --有360范围并且无法释放技能,不需要引导直接完成.
			end
		end
		
	elseif state == stateModelMD.m_OperateState.skill then
		mt_moveRange:setVisible(false)
        if m_A_moveRange_temp then
            m_A_moveRange_temp:setVisible(false)
        end
		mt_attackRange:setVisible(false)
		if mt_skillRange then
			mt_skillRange:setVisible(true)
			--将 mt_skillRange 位置设置到当前位置
			local pos = mt_role.lua_getPosition()
			local angle = mt_role.lua_getRotation()
			mt_skillRange.lua_setPosition(pos)
			mt_skillRange.lua_setRotation(angle)
		end

		--还未进行范围引导
		m_GuideAngleIsTiped = false	
		
		if mt_current_heroData.skill_angle_range >= 360 then
			m_SurfaceComplete.lua_setShowGuild(true) --有360范围不需要引导,直接完成
		end
		
	elseif state == stateModelMD.m_OperateState.waitPlay then
		mt_moveRange:setVisible(false)
        if m_A_moveRange_temp then
            m_A_moveRange_temp:setVisible(false)
        end
		mt_attackRange:setVisible(false)
		if mt_skillRange then
			mt_skillRange:setVisible(false)
		end
		
		local at_hero_data = m_StepDataObject.getHeroCurrentData(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
		
		local mt_hero_data = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
		
		
		local at_can_move = true
		
		local at_can_attack = true
		
		local at_can_skill = at_hero_data.skill_configId ~= 0 and at_hero_data.skill_need_sp <= at_hero_data.hero_current_sp
		
		
		local mt_can_move = true
		
		local mt_can_attack = true
		
		local mt_can_skill = mt_hero_data.skill_configId ~= 0 and mt_hero_data.skill_need_sp <= mt_hero_data.hero_current_sp
		
		
		--眩晕
		local at_has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(at_hero_data, buffsModelMD.m_BuffType.dizzy)
		if at_has_buff_dizzy then
			at_can_move = false
			at_can_attack = false
			at_can_skill = false
		end
		
		--眩晕
		local mt_has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_hero_data, buffsModelMD.m_BuffType.dizzy)
		if mt_has_buff_dizzy then
			mt_can_move = false
			mt_can_attack = false
			mt_can_skill = false
		end

         --定身
        local at_has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(at_hero_data, buffsModelMD.m_BuffType.fixed)
        if at_has_buff_fixed then
			at_can_move = false
        end

        --定身
        local mt_has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_hero_data, buffsModelMD.m_BuffType.fixed)
        if mt_has_buff_fixed then
			mt_can_move = false
        end

        --沉默
        local mt_has_buff_silence = stepDataModelMD.checkHasBuffWithTypeId(mt_hero_data, buffsModelMD.m_BuffType.silence)
        if mt_has_buff_silence then
            mt_can_skill = false
        end

        --沉默
        local at_has_buff_silence = stepDataModelMD.checkHasBuffWithTypeId(at_hero_data, buffsModelMD.m_BuffType.silence)
        if at_has_buff_silence then
            at_can_skill = false
        end


        
        local mt_add_move_range = stepDataModelMD.getBuffValue(mt_hero_data,mt_hero_data,nil,buffsModelMD.m_BuffType.addMoveRange)

        local at_add_move_range = stepDataModelMD.getBuffValue(at_hero_data,at_hero_data,nil,buffsModelMD.m_BuffType.addMoveRange)


		if not m_TempAutomatic then
			--计算AI
			local point , angle , skill = AIModelMD.AI_operate_point_angle_skill(
				m_ServerData[m_AutoPlace].duel_rank_id
				, at_hero_data.move_range + at_add_move_range
				, at_can_move
				, at_hero_data.weapon_type
				, at_hero_data.attack_min_range
				, at_hero_data.attack_max_range
				, at_hero_data.attack_angle_range
				, at_can_attack
				, at_hero_data.skill_min_range
				, at_hero_data.skill_max_range
				, at_hero_data.skill_angle_range
				, at_can_skill
				, clone(m_StepDataObject.getOriginPoint(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				, clone(m_StepDataObject.getOriginAngle(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				
				, m_ServerData[m_ManualPlace].duel_rank_id
				, mt_hero_data.move_range + mt_add_move_range
				, mt_can_move
				, mt_hero_data.weapon_type
				, mt_hero_data.attack_min_range
				, mt_hero_data.attack_max_range
				, mt_hero_data.attack_angle_range
				, mt_can_attack
				, mt_hero_data.skill_min_range
				, mt_hero_data.skill_max_range
				, mt_hero_data.skill_angle_range
				, mt_can_skill
				, clone(m_StepDataObject.getOriginPoint(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				, clone(m_StepDataObject.getOriginAngle(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				
				, clone(m_StepDataObject.getOperatePoint(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				, clone(m_StepDataObject.getOperateAngle(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				, clone(m_StepDataObject.getOperateSkill(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
				
				, clone(helpModelMD.m_RoleRadius)
				, clone(helpModelMD.m_MoveSinDivCos)
				, checkMapPoint
			)
			--写入AI操作
			m_StepDataObject.setOperatePoint(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), point)
			m_StepDataObject.setOperateAngle(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), angle)
			m_StepDataObject.setOperateSkill(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), skill)
		end
		
		--计算效果
		operateForce()
		
		--播放
		if m_TempAutomatic and m_GmaeStateObject.getRound() == 1 then
			local t = m_GmaeStateObject.getSeason() == 1 and 5.0 or 3.5
			g_autoCallback.addCocosList(playAction, t / m_ScaleTime)
		else	
			playAction()
		end
		
	end
end

local t_moveSlefOffset = cc.p(0, 0)

--触摸开始
function onTouchBegan(touch, event)
	if m_Root == nil then
		return false
	end
	if m_TouchState ~= c_touch_state.no
		or m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.readying 
		or m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.waitPlay 
			then
		return false
	end
	
	local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	--眩晕
	local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy )
    --定身
	local has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.fixed )

	if (not has_buff_dizzy) and (not has_buff_fixed) then --眩晕/定身
	
		if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.move then
			--选择移动
			local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
			if mt_role and mt_role.lua_checkTouchWorldPoint(touch:getLocation()) then
				t_moveSlefOffset = cc.pSub(mt_role.lua_getPosition(), cTools_worldToNodeSpace_position(m_RoleRoot, touch:getLocation()))
				m_TouchState = c_touch_state.moveSelf
				m_GuideEffectArmature_1:setVisible(false)
				m_LastOperateTime = os.time()
				return true
			end
		end
		
	end

    local at_current_heroData = m_StepDataObject.getHeroCurrentData(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	--m_B_attackRange_temp
	--查看对方
	local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
	if at_role then
		if at_role.lua_checkTouchWorldPoint(touch:getLocation()) then
			--at_moveRange:setVisible(true)
			if m_B_moveRange_temp then
                m_B_moveRange_temp:removeFromParent()
                m_B_moveRange_temp = nil
            end

            if m_B_attackRange_temp then
                m_B_attackRange_temp:removeFromParent()
                m_B_attackRange_temp = nil
            end

            local addVar = stepDataModelMD.getBuffValue( at_current_heroData,at_current_heroData,nil,buffsModelMD.m_BuffType.addMoveRange)
            if addVar > 0 then
                if m_B_moveRange_temp == nil then
                    m_B_moveRange_temp = helpModelMD.createMoveRange(at_current_heroData.move_range + addVar)
	                m_B_moveRange_temp.lua_setPosition(at_role.lua_getPosition())
	                m_InfoRoot:addChild(m_B_moveRange_temp, 1)
                end
            else
                at_moveRange:setVisible(true)
            end

            --local has_buff_addAtkRange = stepDataModelMD.findBuffWithTypeId(at_current_heroData, buffsModelMD.m_BuffType.addAtkRange)
            local addVar = stepDataModelMD.getBuffValue( at_current_heroData,at_current_heroData,nil,buffsModelMD.m_BuffType.addAtkRange )
            if addVar > 0 then
                if m_B_attackRange_temp == nil then
                    m_B_attackRange_temp = helpModelMD.createAttackRange(at_current_heroData.attack_min_range, at_current_heroData.attack_max_range + addVar, at_current_heroData.attack_angle_range)
	                m_B_attackRange_temp.lua_setPosition(at_role.lua_getPosition())
	                m_B_attackRange_temp.lua_setRotation(at_role.lua_getRotation())
	                m_B_attackRange_temp:setVisible(true)
	                m_InfoRoot:addChild(m_B_attackRange_temp, 2)
                end
            else
                at_attackRange:setVisible(true)
            end

            local has_buff_confusion = stepDataModelMD.checkHasBuffWithTypeId( at_current_heroData, buffsModelMD.m_BuffType.confusion)
            if has_buff_confusion then
                at_attackRange:setVisible(false)
                if m_B_attackRange_temp then
                    m_B_attackRange_temp:setVisible(false)
                end
            end

			if at_skillRange then
				at_skillRange:setVisible(true)
			end
			m_TouchState = c_touch_state.showAuto
			return true
		end
	end
	
	if has_buff_dizzy then --眩晕
		return false
	end
	
	if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.attack then
		--选择攻击范围
		m_TouchState = c_touch_state.atkAngle
		return true
	elseif m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.skill then
		--选择技能范围
		m_TouchState = c_touch_state.sklAngle
		return true
	end
	
	return false
end


--触摸移动
function onTouchMoved(touch, event)
	if m_Root == nil then
		return
	end
	local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
    --眩晕
	local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
    --定身
	local has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.fixed )

    local has_buff_confusion = stepDataModelMD.checkHasBuffWithTypeId( mt_current_heroData, buffsModelMD.m_BuffType.confusion)
    --不可操作
	if has_buff_dizzy then --眩晕
		return
	end
	
	if m_TouchState == c_touch_state.moveSelf then
        --没有定身
        if not has_buff_fixed then
		    local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
		    if mt_role then
			    local hero = m_StepDataObject.getHeroInitData(m_ManualPlace, m_GmaeStateObject.getSeason())
			    if hero then
				    local originPoint = m_StepDataObject.getOriginPoint(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
				    local wangPoint = cc.pAdd(cTools_worldToNodeSpace_position(m_RoleRoot, touch:getLocation()), t_moveSlefOffset)
				    --补充buff判定
                    local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
                    local addVar = stepDataModelMD.getBuffValue( mt_current_heroData,mt_current_heroData,nil,buffsModelMD.m_BuffType.addMoveRange)
				    wangPoint = helpModelMD.checkMovePoint(originPoint, wangPoint, hero.move_range + addVar)
				    local finalPoint = m_MapBottom.lua_checkWantNodePoint(originPoint, wangPoint, hero.move_range + addVar)
				    mt_role.lua_setPosition(finalPoint)
			    end
		    end
		    m_GuideEffectArmature_1:setVisible(false)
		    m_LastOperateTime = os.time()
        end
	end
	
	if m_TouchState == c_touch_state.atkAngle then
		--选择攻击范围
		local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
		if mt_role then
			local pos1 = cTools_worldToNodeSpace_position(m_RoleRoot, touch:getLocation())
			local pos2 = mt_role.lua_getPosition()
			mt_role.lua_setRotation(cToolsForLua:calc2VecAngle(1.0, 0.0, pos1.x - pos2.x, pos1.y - pos2.y))

            if m_A_attackRange_temp then
                m_A_attackRange_temp.lua_setRotation(cToolsForLua:calc2VecAngle(1.0, 0.0, pos1.x - pos2.x, pos1.y - pos2.y))
            end

            if has_buff_confusion then
                mt_attackRange:setVisible(false)
                if m_A_attackRange_temp then
                    m_A_attackRange_temp:setVisible(false)
                end
            end

		end
		m_GuideEffectArmature_1:setVisible(false)
		m_LastOperateTime = os.time()
		m_GuideAngleIsTiped = true
	end
	
	if m_TouchState == c_touch_state.sklAngle then
		--选择技能范围
		local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
		if mt_role then
			local pos1 = cTools_worldToNodeSpace_position(m_RoleRoot, touch:getLocation())
			local pos2 = mt_role.lua_getPosition()
			mt_role.lua_setRotation(cToolsForLua:calc2VecAngle(1.0, 0.0, pos1.x - pos2.x, pos1.y - pos2.y))
		end
		m_GuideEffectArmature_1:setVisible(false)
		m_LastOperateTime = os.time()
		m_GuideAngleIsTiped = true
	end
end


--触摸结束
function onTouchEnded(touch, event)
    
	if m_Root == nil then
		return
	end
	if m_TouchState == c_touch_state.no then
		return
	end
	
	local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
    --眩晕
	local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
    --定身
	local has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.fixed)
    --混乱
    local has_buff_confusion = stepDataModelMD.checkHasBuffWithTypeId( mt_current_heroData, buffsModelMD.m_BuffType.confusion)

	if has_buff_dizzy then --眩晕
		if m_TouchState == c_touch_state.showAuto then
			local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
			if at_role then
				at_moveRange:setVisible(false)
				at_attackRange:setVisible(false)
				if at_skillRange then
					at_skillRange:setVisible(false)
				end
			end
		end
		m_TouchState = c_touch_state.no
		return
	end
	
	if m_TouchState == c_touch_state.moveSelf then
        --定身
        if has_buff_fixed then
            if m_TouchState == c_touch_state.showAuto then
			    local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
			    if at_role then
				    at_moveRange:setVisible(false)
				    at_attackRange:setVisible(false)
				    if at_skillRange then
					    at_skillRange:setVisible(false)
				    end
			    end
		    end
            m_TouchState = c_touch_state.no
            return 
        else
		    m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.attack)
		    m_GuideEffectArmature_1:setVisible(false)
		    m_LastOperateTime = os.time()
            if has_buff_confusion then
                local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
                mt_attackRange:setVisible(false)
                if m_A_attackRange_temp then
                    m_A_attackRange_temp:setVisible(false)
                end 
            end
        end

	elseif m_TouchState == c_touch_state.showAuto then
		local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
		if at_role then
			at_moveRange:setVisible(false)
			at_attackRange:setVisible(false)

			if at_skillRange then
				at_skillRange:setVisible(false)
			end

            if m_B_attackRange_temp then
                m_B_attackRange_temp:setVisible(false)
            end

            if m_B_moveRange_temp then
                m_B_moveRange_temp:setVisible(false)
            end
		end
	elseif m_TouchState == c_touch_state.atkAngle then
		--选择攻击范围
		m_GuideEffectArmature_1:setVisible(false)
		m_LastOperateTime = os.time()
		if mt_current_heroData.skill_configId == 0 or mt_current_heroData.hero_current_sp < mt_current_heroData.skill_need_sp then
			--不能放技能
			m_SurfaceComplete.lua_setShowGuild(true)
		end
		m_GuideAngleIsTiped = true
	elseif m_TouchState == c_touch_state.sklAngle then
		--选择技能范围
		m_GuideEffectArmature_1:setVisible(false)
		m_LastOperateTime = os.time()
		m_SurfaceComplete.lua_setShowGuild(true)
		m_GuideAngleIsTiped = true
	end
	
	m_TouchState = c_touch_state.no
end


--触摸取消
function onTouchCancelled(touch, event)
	if m_Root == nil then
		return
	end
	if m_TouchState == c_touch_state.no then
		return
	end
	
	local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())

	--眩晕
    local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
    --定身
	local has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.fixed)

	if has_buff_dizzy then --眩晕
		if m_TouchState == c_touch_state.showAuto then
			local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
			if at_role then
				at_moveRange:setVisible(false)
				at_attackRange:setVisible(false)
				if at_skillRange then
					at_skillRange:setVisible(false)
				end
			end
		end
		m_TouchState = c_touch_state.no
		return
	end
	
	if m_TouchState == c_touch_state.moveSelf then
		if has_buff_fixed then
            if m_TouchState == c_touch_state.showAuto then
			    local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
			    if at_role then
				    at_moveRange:setVisible(false)
				    at_attackRange:setVisible(false)
				    if at_skillRange then
					    at_skillRange:setVisible(false)
				    end
			    end
		    end
            m_TouchState = c_touch_state.no
            return 
        else
		    m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.attack)
		    m_GuideEffectArmature_1:setVisible(false)
		    m_LastOperateTime = os.time()
        end
	elseif m_TouchState == c_touch_state.showAuto then
		local at_role , at_moveRange , at_attackRange , at_skillRange = _getPlaceInfo(m_AutoPlace)
		if at_role then
			at_moveRange:setVisible(false)
			at_attackRange:setVisible(false)
			if at_skillRange then
				at_skillRange:setVisible(false)
			end
		end
	elseif m_TouchState == c_touch_state.atkAngle then
		--选择攻击范围
		m_GuideEffectArmature_1:setVisible(false)
		m_LastOperateTime = os.time()
		if mt_current_heroData.skill_configId == 0 or mt_current_heroData.hero_current_sp < mt_current_heroData.skill_need_sp then
			--不能放技能
			m_SurfaceComplete.lua_setShowGuild(true)
		end
		m_GuideAngleIsTiped = true
	elseif m_TouchState == c_touch_state.sklAngle then
		--选择技能范围
		m_GuideEffectArmature_1:setVisible(false)
		m_LastOperateTime = os.time()
		m_SurfaceComplete.lua_setShowGuild(true)
		m_GuideAngleIsTiped = true
	end
	
	m_TouchState = c_touch_state.no
end


--取消按钮
function onCancelButton()
	if m_OperateStateObject == nil then
		return 
	end
	
    if m_A_attackRange_temp then
        m_A_attackRange_temp:setVisible(false)
    end

    if m_B_attackRange_temp then
        m_B_attackRange_temp:setVisible(false)
    end

	local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	--眩晕
	local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
	if has_buff_dizzy then
		g_airBox.show(g_tr("tournament_dizzy"))
		return
	end

    --定身
	local has_buff_fixed = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.fixed)
	
	if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.attack then
        --定身
        if not has_buff_fixed then
		    local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
		    if mt_role then
			    mt_role.lua_setPosition(m_StepDataObject.getOriginPoint(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
			    mt_role.lua_setRotation(m_StepDataObject.getOriginAngle(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound()))
		    end
		    m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.move)
        end

	elseif m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.skill then
		m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.attack)
	end
end


--技能按钮
function onSkillButton()
	if m_OperateStateObject == nil then
		return 
	end

	if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.attack then
		
		local mt_current_heroData = m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
		
		--眩晕
		local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.dizzy)
		if has_buff_dizzy then
			g_airBox.show(g_tr("tournament_dizzy"))
			return
		end

        --沉默
        local has_buff_silence = stepDataModelMD.checkHasBuffWithTypeId(mt_current_heroData, buffsModelMD.m_BuffType.silence)
        if has_buff_silence then
            g_airBox.show(g_tr("tournament_silence"))
            return
        end
		
		if mt_current_heroData.hero_current_sp < mt_current_heroData.skill_need_sp then
			g_airBox.show(g_tr("tournament_spNotFull"))
			return --SP不够
		end
		
		m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.skill)
	end
end


--完成
function onCompletButton()
	if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.attack 
		or m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.skill 
		then
		local mt_role , mt_moveRange , mt_attackRange , mt_skillRange = _getPlaceInfo(m_ManualPlace)
        if m_A_attackRange_temp then
            m_A_attackRange_temp:setVisible(false)
        end
		
		if m_B_attackRange_temp then
			m_B_attackRange_temp:setVisible(false)
        end

        if m_A_moveRange_temp then
            m_A_moveRange_temp:setVisible(false)    
        end

        if m_B_moveRange_temp then
			m_B_moveRange_temp:setVisible(false)
        end
        
		if mt_role then
			--写入操作
			m_StepDataObject.setOperatePoint(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), mt_role.lua_getPosition())
			m_StepDataObject.setOperateAngle(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), mt_role.lua_getRotation())
			local skill = (m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.skill and 1 or 0)
			m_StepDataObject.setOperateSkill(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), skill)
		end
		m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.waitPlay)
	end
end

function _vecNormalize(vec)
	local n = vec.x * vec.x + vec.y * vec.y
	if n == 1.0 then
		return cc.p(vec.x, vec.y)
	end
	n = math.sqrt(n)
	if n < 0.00000001 then --2e-37
		return cc.p(vec.x, vec.y)
	end
	n = 1.0 / n
	return cc.p(vec.x * n, vec.y * n)
end

local function _angleNormalize(angle)
	local v = (math.abs(angle) > 360) and math.mod(angle, 360) or angle
	v = ((v < 0) and (360 + v) or (v))
	return v
end

local function _operateAngleRange(targetAngle, originAngle, rangeAngle)
	if cToolsForLua:isDebugVersion() then
		if rangeAngle > 360 then
			g_airBox.show("攻击范围超过360！检查配置！", 3)
		end
	end
	local range = _angleNormalize(rangeAngle)
	if range >= 360 then
		return true
	end
	local target = _angleNormalize(targetAngle)
	local origin = _angleNormalize(originAngle)
	local target = _angleNormalize(targetAngle)
	local origin = _angleNormalize(originAngle)
	local sub = math.abs(target - origin)
	if sub > 180.0 then
		sub = math.abs(sub - 360)
	end
	return (sub <= range / 2)
end

local function _operateRange(d_min, d_max, r_min, r_max)
	return (
		(d_min >= r_min and d_min <= r_max) 
		or (d_min <= r_min and d_min >= r_max)
		or (d_max >= r_min and d_max <= r_max)
		or (d_max <= r_min and d_max >= r_max)
		or (r_min >= d_min and r_min <= d_max)
		or (r_min <= d_min and r_min >= d_max)
		or (r_max >= d_min and r_max <= d_max)
		or (r_max <= d_min and r_max >= d_max)
	)
end

local function _operateLineCircle(origin, direction, t, center, radius)
	local D = direction
	local O_C = cc.p(origin.x - center.x, origin.y - center.y)
	local A = D.x * D.x + D.y * D.y
	local B = 2.0 * (O_C.x * D.x + O_C.y * D.y)
	local C = (O_C.x * O_C.x + O_C.y * O_C.y) - radius * radius
	
	local d = B * B - 4.0 * A * C
	if d < 0.0 then
		return false
	end
	
	local t0 = (-B - math.sqrt(d)) / (2 * A)
	if t0 >= 0.0 and t0 <= t then
		return true
	end
	
	local t1 = (-B + math.sqrt(d)) / (2 * A)
	if t1 >= 0.0 and t1 <= t then
		return true
	end
	
	return false
end

function _operateIntersectionLineCircle(target_point, self_point, self_angle, atk_min_range, atk_max_range, atk_angle_range)
	if atk_max_range - atk_min_range < 2 or atk_max_range < 2 or atk_angle_range < 2 then
		if cToolsForLua:isDebugVersion() then
			g_airBox.show("攻击距离或角度不符合正常逻辑！检查配置！", 3)
		end
		return false
	end
	
	local angle_1 = self_angle - atk_angle_range / 2
	local line_1_origin = cc.p(self_point.x + math.cos(angle_1 * math.pi / 180.0) * atk_min_range, self_point.y + math.sin(angle_1 * math.pi / 180.0) * atk_min_range)
	local line_1_end = cc.p(self_point.x + math.cos(angle_1 * math.pi / 180.0) * atk_max_range, self_point.y + math.sin(angle_1 * math.pi / 180.0) * atk_max_range)
	local line_1_dv = cc.pSub(line_1_end, line_1_origin)
	local line_1_dv_n = _vecNormalize(line_1_dv)
	local line_1_t = math.sqrt(line_1_dv.x * line_1_dv.x + line_1_dv.y * line_1_dv.y)
	
	if _operateLineCircle(line_1_origin, line_1_dv_n, line_1_t, target_point, helpModelMD.m_RoleRadius) then
		return true
	end
	
	local angle_2 = self_angle + atk_angle_range / 2
	local line_2_origin = cc.p(self_point.x + math.cos(angle_2 * math.pi / 180.0) * atk_min_range, self_point.y + math.sin(angle_2 * math.pi / 180.0) * atk_min_range)
	local line_2_end = cc.p(self_point.x + math.cos(angle_2 * math.pi / 180.0) * atk_max_range, self_point.y + math.sin(angle_2 * math.pi / 180.0) * atk_max_range)
	local line_2_dv = cc.pSub(line_2_end, line_2_origin)
	local line_2_dv_n = _vecNormalize(line_2_dv)
	local line_2_t = math.sqrt(line_2_dv.x * line_2_dv.x + line_2_dv.y * line_2_dv.y)
	
	if _operateLineCircle(line_2_origin, line_2_dv_n, line_2_t, target_point, helpModelMD.m_RoleRadius) then
		return true
	end
	
	return false
end

--self_heroData 先手方
--target_heroData 后手方
--回合开始时
function _subCountBuff_roundOperateStart(self_heroData, self_roundEnd_play_data, target_heroData, target_roundEnd_play_data)
	--减少自己用过的BUFF
	local self_subBuffs = stepDataModelMD.subCountWithTypeIds(self_heroData, {
			[buffsModelMD.m_BuffType.fixed] = true,
		})
	for k , v in pairs(self_subBuffs) do
		self_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
	--减少对手用过的BUFF
	local target_subBuffs = stepDataModelMD.subCountWithTypeIds(target_heroData, {
			[buffsModelMD.m_BuffType.fixed] = true,
		})
	for k , v in pairs(target_subBuffs) do
		target_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
end

--移动结束后
function _subCountBuff_roundMoveOver(self_heroData, self_roundEnd_play_data, target_heroData, target_roundEnd_play_data)
    --减少自己用过的BUFF
	local self_subBuffs = stepDataModelMD.subCountWithTypeIds(self_heroData, {
			[buffsModelMD.m_BuffType.diaoXue] = true,
            [buffsModelMD.m_BuffType.addMoveRange] = true,
		})
	for k , v in pairs(self_subBuffs) do
		self_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
	--减少对手用过的BUFF
	local target_subBuffs = stepDataModelMD.subCountWithTypeIds(target_heroData, {
			[buffsModelMD.m_BuffType.diaoXue] = true,
            [buffsModelMD.m_BuffType.addMoveRange] = true,
		})
	for k , v in pairs(target_subBuffs) do
		target_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
end

--self_heroData 先手方
--target_heroData 后手方

--减少BUFF在先手方攻击计算完成时
function _subCountBuff_firstAttackOperateEnd(self_heroData, self_roundEnd_play_data, target_heroData, target_roundEnd_play_data)
	--减少自己用过的BUFF
	local self_subBuffs = stepDataModelMD.subCountWithTypeIds(self_heroData, {
			[buffsModelMD.m_BuffType.attackAdd] = true,
            [buffsModelMD.m_BuffType.skillLess] = true,
            [buffsModelMD.m_BuffType.doubleHurt] = true,
            --吸血BUFF在攻击完之后减少
            [buffsModelMD.m_BuffType.suckBlood] = true,
            [buffsModelMD.m_BuffType.addAtkRange] = true,
            [buffsModelMD.m_BuffType.silence] = true,
            [buffsModelMD.m_BuffType.confusion] = true,
            
		})
	for k , v in pairs(self_subBuffs) do
		self_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
	--减少对手用过的BUFF
	local target_subBuffs = stepDataModelMD.subCountWithTypeIds(target_heroData, {
			[buffsModelMD.m_BuffType.hurtSub] = true,
			[buffsModelMD.m_BuffType.reflectHurt] = true,
            [buffsModelMD.m_BuffType.suckBlood] = true,
            [buffsModelMD.m_BuffType.doubleHurt] = true,
            [buffsModelMD.m_BuffType.mianSi] = true,
		})
	for k , v in pairs(target_subBuffs) do
		target_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
end

--self_heroData 先手方
--target_heroData 后手方

--减少BUFF在先手方因为BUFF原因不能攻击时
function _subCountBuff_firstCanNotAttack(self_heroData, self_roundEnd_play_data, target_heroData, target_roundEnd_play_data)
	--减少自己用过的BUFF
	local self_subBuffs = stepDataModelMD.subCountWithTypeIds(self_heroData, {
			[buffsModelMD.m_BuffType.dizzy] = true,
			[buffsModelMD.m_BuffType.attackAdd] = true,
            [buffsModelMD.m_BuffType.skillLess] = true,
            [buffsModelMD.m_BuffType.doubleHurt] = true,
            --吸血BUFF在不能攻击的情况下减少（不能攻击的时候使用了技能）
            [buffsModelMD.m_BuffType.suckBlood] = true,
            [buffsModelMD.m_BuffType.addAtkRange] = true,
            [buffsModelMD.m_BuffType.silence] = true,
            [buffsModelMD.m_BuffType.confusion] = true,
            
		})
	for k , v in pairs(self_subBuffs) do
		self_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
	--减少对手用过的BUFF
	local target_subBuffs = stepDataModelMD.subCountWithTypeIds(target_heroData, {
			[buffsModelMD.m_BuffType.hurtSub] = true,
			[buffsModelMD.m_BuffType.reflectHurt] = true,
            --吸血BUFF在不能攻击的情况下减少（不能攻击的时候使用了技能）
            [buffsModelMD.m_BuffType.suckBlood] = true,
            [buffsModelMD.m_BuffType.doubleHurt] = true,
            [buffsModelMD.m_BuffType.mianSi] = true,
		})
	for k , v in pairs(target_subBuffs) do
		target_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
end

--self_heroData 后手方
--target_heroData 先手方

--减少BUFF在后手方攻击计算完成时
function _subCountBuff_secondAttackOperateEnd(self_heroData, self_roundEnd_play_data, target_heroData, target_roundEnd_play_data)
	--减少自己用过的BUFF
	local self_subBuffs = stepDataModelMD.subCountWithTypeIds(self_heroData, {
			[buffsModelMD.m_BuffType.attackAdd] = true,
            [buffsModelMD.m_BuffType.skillLess] = true,
			[buffsModelMD.m_BuffType.wuliSub] = true,
            [buffsModelMD.m_BuffType.doubleHurt] = true,
            --吸血BUFF在攻击完之后减少
            [buffsModelMD.m_BuffType.suckBlood] = true,
            [buffsModelMD.m_BuffType.addAtkRange] = true,
            [buffsModelMD.m_BuffType.silence] = true,
            [buffsModelMD.m_BuffType.confusion] = true,
            
		})
	for k , v in pairs(self_subBuffs) do
		self_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
	--减少对手用过的BUFF
	local target_subBuffs = stepDataModelMD.subCountWithTypeIds(target_heroData, {
			[buffsModelMD.m_BuffType.hurtSub] = true,
			[buffsModelMD.m_BuffType.wuliSub] = true,
			[buffsModelMD.m_BuffType.reflectHurt] = true,
            [buffsModelMD.m_BuffType.suckBlood] = true,
            [buffsModelMD.m_BuffType.doubleHurt] = true,
            [buffsModelMD.m_BuffType.mianSi] = true,
		})
	for k , v in pairs(target_subBuffs) do
		target_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
end

--self_heroData 后手方
--target_heroData 先手方

--减少BUFF在后手方因为BUFF原因不能攻击时
function _subCountBuff_secondCanNotAttack(self_heroData, self_roundEnd_play_data, target_heroData, target_roundEnd_play_data)
	--减少自己用过的BUFF
	local self_subBuffs = stepDataModelMD.subCountWithTypeIds(self_heroData, {
			[buffsModelMD.m_BuffType.dizzy] = true,
			[buffsModelMD.m_BuffType.attackAdd] = true,
            [buffsModelMD.m_BuffType.skillLess] = true,
			[buffsModelMD.m_BuffType.wuliSub] = true,
            [buffsModelMD.m_BuffType.doubleHurt] = true,
            --吸血BUFF在不能攻击的情况下减少（不能攻击的时候使用了技能）
            [buffsModelMD.m_BuffType.suckBlood] = true,
            [buffsModelMD.m_BuffType.addAtkRange] = true,
            [buffsModelMD.m_BuffType.silence] = true,
            [buffsModelMD.m_BuffType.confusion] = true,
            
		})
	for k , v in pairs(self_subBuffs) do
		self_roundEnd_play_data.subBuffs[tostring(k)] = true
	end
	--减少对手用过的BUFF
	local target_subBuffs = stepDataModelMD.subCountWithTypeIds(target_heroData, {
			[buffsModelMD.m_BuffType.hurtSub] = true,
			[buffsModelMD.m_BuffType.wuliSub] = true,
			[buffsModelMD.m_BuffType.reflectHurt] = true,
            [buffsModelMD.m_BuffType.suckBlood] = true,
            [buffsModelMD.m_BuffType.doubleHurt] = true,
            [buffsModelMD.m_BuffType.mianSi] = true,
		})
	for k , v in pairs(target_subBuffs) do
		target_roundEnd_play_data.subBuffs[tostring(k)] = true
    end
end

--删除当前BUFF
function _subRmoveBuffCount(heroData,roundEnd_play_data,TypeId)
    local subBuffs = stepDataModelMD.subEndWithTypeIds(heroData,{
            [TypeId] = true
		})
	for k , v in pairs(subBuffs) do
		roundEnd_play_data.subBuffs[tostring(k)] = true
	end
end



--计算伤害效果
function operateForce()
	if m_StepDataObject == nil then
		return
	end
	
	local first = m_StepDataObject.getFirst(m_GmaeStateObject.getSeason())
	
	
	local f_place = first == 1 and "A" or "B"
	
	local s_place = first == 2 and "A" or "B"
	
	
	local f_role , f_moveRange , f_attackRange , f_skillRange = _getPlaceInfo(f_place)
	
	local s_role , s_moveRange , s_attackRange , s_skillRange = _getPlaceInfo(s_place)
	
	
	local f_current_heroData = m_StepDataObject.getHeroCurrentData(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local f_origin_point = m_StepDataObject.getOriginPoint(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local f_origin_angle = m_StepDataObject.getOriginAngle(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local f_operate_point = m_StepDataObject.getOperatePoint(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local f_operate_angle = m_StepDataObject.getOperateAngle(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local f_operate_skill = m_StepDataObject.getOperateSkill(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	
	local s_current_heroData = m_StepDataObject.getHeroCurrentData(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local s_origin_point = m_StepDataObject.getOriginPoint(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local s_origin_angle = m_StepDataObject.getOriginAngle(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local s_operate_point = m_StepDataObject.getOperatePoint(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local s_operate_angle = m_StepDataObject.getOperateAngle(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	local s_operate_skill = m_StepDataObject.getOperateSkill(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	
	
	--回合结束最终位置数据
	local f_final_point = cc.p(f_operate_point.x, f_operate_point.y)
	local f_final_angle = f_operate_angle
	
	local s_final_point = cc.p(s_operate_point.x, s_operate_point.y)
	local s_final_angle = s_operate_angle
	
	--结果英雄数据
	local f_results_heroData = clone(f_current_heroData)
	
	local s_results_heroData = clone(s_current_heroData)
	
	--攻击结果播放数据
	local f_atk_play_data = clone(stepDataModelMD.c_atk_play_data)
	stepDataModelMD.atkInitSetting(
		f_atk_play_data
		, f_results_heroData.hero_max_hp
		, f_results_heroData.hero_current_hp
		, f_results_heroData.hero_max_sp
		, f_results_heroData.hero_current_sp
		, f_operate_point
		, f_operate_angle
		, f_final_point
		, f_final_angle
		, f_current_heroData.attack_min_range
		, f_current_heroData.attack_max_range
		, f_current_heroData.skill_min_range
		, f_current_heroData.skill_max_range
		)
	local s_atk_play_data = clone(stepDataModelMD.c_atk_play_data)
	stepDataModelMD.atkInitSetting(
		s_atk_play_data
		, s_results_heroData.hero_max_hp
		, s_results_heroData.hero_current_hp
		, s_results_heroData.hero_max_sp
		, s_results_heroData.hero_current_sp
		, s_operate_point
		, s_operate_angle
		, s_final_point
		, s_final_angle
		, s_current_heroData.attack_min_range
		, s_current_heroData.attack_max_range
		, s_current_heroData.skill_min_range
		, s_current_heroData.skill_max_range
		)
	--回合末播放数据
	local f_roundEnd_play_data = clone(stepDataModelMD.c_roundEnd_play_data)
	
	local s_roundEnd_play_data = clone(stepDataModelMD.c_roundEnd_play_data)
	--回合开始
    _subCountBuff_roundOperateStart(f_results_heroData, f_roundEnd_play_data, s_results_heroData, s_roundEnd_play_data)
	
    --dump(f_results_heroData)

    --先手掉血
    local has_buff_diaoXue = stepDataModelMD.findBuffWithTypeId(f_results_heroData,buffsModelMD.m_BuffType.diaoXue)
    if has_buff_diaoXue then
        local configData = g_data.duel_buff[has_buff_diaoXue.buffId]
        g_custom_loadFunc("OperateBuff", "(v1)", " return "..configData.client_formula)
        local dx = math.ceil(externFunctionOperateBuff(s_results_heroData))
        dx = math.min( f_results_heroData.hero_current_hp,dx)
        f_results_heroData.hero_current_hp = math.max(0, f_results_heroData.hero_current_hp - dx)
        f_atk_play_data.before_move_end_hp = dx
        f_atk_play_data.action_move_change_hp = true
        f_atk_play_data.after_blow_cur_hp = f_results_heroData.hero_current_hp
        f_atk_play_data.move_blow_cur_hp = f_atk_play_data.after_blow_cur_hp
    end
    
    --后手掉血
    local has_buff_diaoXue = stepDataModelMD.findBuffWithTypeId(s_results_heroData,buffsModelMD.m_BuffType.diaoXue)
    if has_buff_diaoXue then
        local configData = g_data.duel_buff[has_buff_diaoXue.buffId]
        g_custom_loadFunc("OperateBuff", "(v1)", " return "..configData.client_formula)
        local dx = math.ceil(externFunctionOperateBuff(f_results_heroData))
        dx = math.min( s_results_heroData.hero_current_hp,dx)
        s_results_heroData.hero_current_hp = math.max(0, s_results_heroData.hero_current_hp - dx)
        s_atk_play_data.before_move_end_hp = dx
        s_atk_play_data.action_move_change_hp = true
        s_atk_play_data.after_blow_cur_hp = s_results_heroData.hero_current_hp
        s_atk_play_data.move_blow_cur_hp = s_atk_play_data.after_blow_cur_hp
    end

    local f_mianSi_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.mianSi)
    if f_mianSi_buff then
        if f_results_heroData.hero_current_hp <= 0 then
            local configData = g_data.duel_buff[f_mianSi_buff.buffId]
            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
            local back_hp = math.ceil(externFunctionOperateBuff(f_results_heroData, s_results_heroData) * f_results_heroData.hero_max_hp)
            f_atk_play_data.back_hp = back_hp
            f_results_heroData.hero_current_hp = math.min(f_results_heroData.hero_max_hp,back_hp)
            f_atk_play_data.action_move_back_hp = true
            f_atk_play_data.after_blow_cur_hp = f_results_heroData.hero_current_hp
            _subRmoveBuffCount(f_results_heroData,f_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
        end
    end

    local s_mianSi_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.mianSi) 
    if s_mianSi_buff then
        if s_results_heroData.hero_current_hp <= 0 then
            local configData = g_data.duel_buff[s_mianSi_buff.buffId]
            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
            local back_hp = math.ceil(externFunctionOperateBuff(s_results_heroData, f_results_heroData) * s_results_heroData.hero_max_hp)
            s_atk_play_data.back_hp = back_hp
            s_results_heroData.hero_current_hp = math.min(s_results_heroData.hero_max_hp,back_hp)
            s_atk_play_data.action_move_back_hp = true
            s_atk_play_data.after_blow_cur_hp = s_results_heroData.hero_current_hp
            _subRmoveBuffCount(s_results_heroData, s_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
        end
    end
    
    --先手死亡
	if f_results_heroData.hero_current_hp <= 0 then
		f_atk_play_data.action_diaoxue_death = true
	end
						
	--后手死亡
	if s_results_heroData.hero_current_hp <= 0 then
		s_atk_play_data.action_diaoxue_death = true
	end

    --移动结束
    _subCountBuff_roundMoveOver(f_results_heroData, f_roundEnd_play_data, s_results_heroData, s_roundEnd_play_data)

	do --先手方----------------------------------------------------------------------------------------------
       
		local canAtkAction = true
		
		local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.dizzy)
		
		if has_buff_dizzy then
			--有眩晕
			canAtkAction = false
		end
		
		if canAtkAction then
			--能攻击
            local has_buff_silence = stepDataModelMD.checkHasBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.silence)

			if f_operate_skill == 1 and not has_buff_silence then
				--技能攻击
				
				if f_results_heroData.hero_current_sp >= f_results_heroData.skill_need_sp then
					
					f_atk_play_data.action_skill = true
					
					--启动前给自身BUFF
					for k , v in pairs(f_results_heroData.skill_buffs_before_self) do
						--写入武将数据
						stepDataModelMD.addHeroBuffWithBuffId(f_results_heroData, k)
						--写入播放数据
						f_atk_play_data.addBuffs_before_self[tostring(k)] = true
					end
					
					--扣SP
					local sub_sp = f_results_heroData.skill_need_sp
					f_results_heroData.hero_current_sp = f_results_heroData.hero_current_sp - sub_sp
					f_atk_play_data.after_usedSkill_cur_sp = f_results_heroData.hero_current_sp
					
					local dv = cc.pSub(s_operate_point, f_operate_point)
					local dv_angle = cToolsForLua:calc2VecAngle(1.0, 0.0, dv.x, dv.y)
					local dt_cer = math.sqrt(dv.x * dv.x + dv.y * dv.y)	--两人相距中心距离
					local dt_min = dt_cer - helpModelMD.m_RoleRadius	--两人相距最小距离
					local dt_max = dt_cer + helpModelMD.m_RoleRadius	--两人相距最大距离
					
					local isHit = false
					if _operateAngleRange(dv_angle, f_operate_angle, f_results_heroData.skill_angle_range) then
						isHit = _operateRange(dt_min, dt_max, f_results_heroData.skill_min_range, f_results_heroData.skill_max_range)
					else
						isHit = _operateIntersectionLineCircle(s_operate_point, f_operate_point, f_operate_angle
							, f_results_heroData.skill_min_range, f_results_heroData.skill_max_range, f_results_heroData.skill_angle_range)
					end
					
					if isHit then
						--命中
						
						f_atk_play_data.action_hit = true
						
						--启动前给对方BUFF
						for k , v in pairs(f_results_heroData.skill_buffs_before_target) do
                            if stepDataModelMD.randomHeroBuff(f_results_heroData,k) then
							    --写入武将数据
							    stepDataModelMD.addHeroBuffWithBuffId(s_results_heroData, k)
							    --写入播放数据
							    s_atk_play_data.addBuffs_before_target[tostring(k)] = true
                            end
						end
						
						
						--基础五属性修改BUFF
						local f_origin_base = stepDataModelMD.operateChangeBaseBuff(f_results_heroData)
						local s_origin_base = stepDataModelMD.operateChangeBaseBuff(s_results_heroData)
						
						--自己攻击增加BUFF
						local addAtkPercentValue = 0
						local self_attack_add_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.attackAdd)
						if self_attack_add_buff then
							local configData = g_data.duel_buff[self_attack_add_buff.buffId]
							g_custom_loadFunc("OperateBuff", "(v1,v2,distance)", " return "..configData.client_formula)
							addAtkPercentValue = externFunctionOperateBuff(f_results_heroData,s_results_heroData,dt_cer)
						end
						
						--对方伤害减免BUFF
						local subHurtPercentValue = 0
						local target_hurt_sub_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.hurtSub)
						if target_hurt_sub_buff then
							local configData = g_data.duel_buff[target_hurt_sub_buff.buffId]
							g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
							subHurtPercentValue = externFunctionOperateBuff(s_results_heroData, f_results_heroData)
						end

                        --对方技能伤害减少的BUFF
                        local skillLessPercentValue = 0
                        local self_skill_less_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.skillLess)
                        if self_skill_less_buff then
                            local configData = g_data.duel_buff[self_skill_less_buff.buffId]
                            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
							skillLessPercentValue = externFunctionOperateBuff(s_results_heroData, f_results_heroData)
                        end
						
                        --对方承受伤害加倍
                        local doubleHurtPercentValue = 0
                        local double_hurt_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.doubleHurt)
                        if double_hurt_buff then
                            local configData = g_data.duel_buff[double_hurt_buff.buffId]
                            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                            doubleHurtPercentValue = externFunctionOperateBuff(s_results_heroData, f_results_heroData)
                        end
                        
						--扣hp
						local sub_hp = math.ceil(stepDataModelMD.operateSkillForceWithServerData(f_results_heroData, s_results_heroData)
						 * (1 + addAtkPercentValue)
						 * (1 - subHurtPercentValue)
                         * (1 - skillLessPercentValue)
                         * (1 + doubleHurtPercentValue)
						)

						s_results_heroData.hero_current_hp = math.max(0, s_results_heroData.hero_current_hp - sub_hp)
                        s_atk_play_data.hit_hp = sub_hp
						s_atk_play_data.after_blow_cur_hp = s_results_heroData.hero_current_hp
						
						--反伤
						local target_reflectHurt_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.reflectHurt)
						if target_reflectHurt_buff then
							local configData = g_data.duel_buff[target_reflectHurt_buff.buffId]
							g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
							local reflectHurt_hp = math.ceil(sub_hp * externFunctionOperateBuff(s_results_heroData, f_results_heroData))
                            f_atk_play_data.hit_hp = f_atk_play_data.hit_hp + reflectHurt_hp
							f_results_heroData.hero_current_hp = math.max(0, f_results_heroData.hero_current_hp - reflectHurt_hp)
							f_atk_play_data.after_hit_cur_hp = f_results_heroData.hero_current_hp
							f_atk_play_data.action_hit_change_hp = true
						end
						
                        --吸血
                        local suck_blood_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.suckBlood)
                        if suck_blood_buff then
                            local configData = g_data.duel_buff[suck_blood_buff.buffId]
                            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                            local reflectHurt_hp = math.ceil(sub_hp * externFunctionOperateBuff(f_results_heroData,s_results_heroData))
                            f_atk_play_data.back_hp = f_atk_play_data.back_hp + reflectHurt_hp
                            f_results_heroData.hero_current_hp = math.min(f_results_heroData.hero_max_hp,f_results_heroData.hero_current_hp + reflectHurt_hp)
                            f_atk_play_data.after_hit_cur_hp = f_results_heroData.hero_current_hp
                            f_atk_play_data.action_back_hp = true
                        end
                        
                        local f_mianSi_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.mianSi)
                        if f_mianSi_buff then
                            if f_results_heroData.hero_current_hp <= 0 then
                                local configData = g_data.duel_buff[f_mianSi_buff.buffId]
                                g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                local back_hp = math.ceil(externFunctionOperateBuff(f_results_heroData, s_results_heroData) * f_results_heroData.hero_max_hp)
                                f_atk_play_data.back_hp = back_hp
                                f_results_heroData.hero_current_hp = math.min(f_results_heroData.hero_max_hp,back_hp)
                                f_atk_play_data.action_back_hp = true
                                f_atk_play_data.after_hit_cur_hp = f_results_heroData.hero_current_hp
                                _subRmoveBuffCount(f_results_heroData,f_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
                            end
                        end

                        local s_mianSi_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.mianSi) 
                        if s_mianSi_buff then
                            if s_results_heroData.hero_current_hp <= 0 then
                                local configData = g_data.duel_buff[s_mianSi_buff.buffId]
                                g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                local back_hp = math.ceil(externFunctionOperateBuff(s_results_heroData, f_results_heroData) * s_results_heroData.hero_max_hp)
                                s_atk_play_data.back_hp = back_hp
                                s_results_heroData.hero_current_hp = math.min(s_results_heroData.hero_max_hp,back_hp)
                                s_atk_play_data.action_back_hit_hp = true
                                s_atk_play_data.after_blow_cur_hp = s_results_heroData.hero_current_hp
                                _subRmoveBuffCount(s_results_heroData, s_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
                            end
                        end

						--恢复基础五属性
						stepDataModelMD.resumeChangeBaseBuff(f_results_heroData, f_origin_base)
						stepDataModelMD.resumeChangeBaseBuff(s_results_heroData, s_origin_base)
						
						--减少BUFF
						_subCountBuff_firstAttackOperateEnd(f_results_heroData, f_roundEnd_play_data, s_results_heroData, s_roundEnd_play_data)
						
						--启动后给对方BUFF
						for k , v in pairs(f_results_heroData.skill_buffs_after_target) do
                            if k ~= buffsModelMD.m_BuffType.dizzy then
							    --写入武将数据
							    stepDataModelMD.addHeroBuffWithBuffId(s_results_heroData, k)
							    --写入播放数据
							    s_atk_play_data.addBuffs_after_target[tostring(k)] = true
                            end
						end
						
						--检测先手攻击后先手死亡（反伤等）
						if f_results_heroData.hero_current_hp <= 0 then
							f_atk_play_data.action_hit_death = true
						end
						
						--检测先手攻击后后手死亡
						if s_results_heroData.hero_current_hp <= 0 then
							s_atk_play_data.action_death = true
						end
						
					else
						--未命中
                        local back_full_sp_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.backFullSp)
						if back_full_sp_buff then
                            local configData = g_data.duel_buff[back_full_sp_buff.buffId]
                            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                            local bcakSpNum = externFunctionOperateBuff(f_results_heroData,s_results_heroData)
                            f_results_heroData.hero_current_sp = bcakSpNum
                            f_atk_play_data.after_usedSkill_cur_sp = f_results_heroData.hero_current_sp
                        end
						--减少BUFF
						_subCountBuff_firstAttackOperateEnd(f_results_heroData, f_roundEnd_play_data, s_results_heroData, s_roundEnd_play_data)	
						
					end
					
					--启动后给自身BUFF
					for k , v in pairs(f_results_heroData.skill_buffs_after_self) do
						--写入武将数据
						stepDataModelMD.addHeroBuffWithBuffId(f_results_heroData, k)
						--写入播放数据
						f_atk_play_data.addBuffs_after_self[tostring(k)] = true
					end
					
					--张辽瞬移
					if 
                    f_results_heroData.skill_configId == helpModelMD.ZHANGLIAO_SKILL or 
                    f_results_heroData.skill_configId == helpModelMD.XIAHOUDUN_SKILL
                    then
						local dv = cc.pSub(s_operate_point, f_final_point)
						local dl = math.sqrt(dv.x * dv.x + dv.y * dv.y)
						if dl > 100 then
							local s = 100 / dl
							local newPos = cc.pSub(s_operate_point, cc.p(dv.x * s, dv.y * s))
							if checkMapPoint(newPos) then
								f_final_point = newPos
								f_final_angle = cToolsForLua:calc2VecAngle(1.0, 0.0, dv.x, dv.y)
								f_atk_play_data.atk_teleporting_pos = f_final_point
								f_atk_play_data.atk_teleporting_angle = f_final_angle
							end
						end
					end
					
				else
					--SP不够
					
					--减少BUFF
					_subCountBuff_firstAttackOperateEnd(f_results_heroData, f_roundEnd_play_data, s_results_heroData, s_roundEnd_play_data)
					
				end
				
			else
                
				--普通攻击
				f_atk_play_data.action_attack = true
                --混乱
				local f_confusion_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.confusion)
                if f_confusion_buff then
					f_atk_play_data.action_attack = false
                end

				--启动前给自身BUFF
				for k , v in pairs(f_results_heroData.attack_buffs_before_self) do
					--写入武将数据
					stepDataModelMD.addHeroBuffWithBuffId(f_results_heroData, k)
					--写入播放数据
					f_atk_play_data.addBuffs_before_self[tostring(k)] = true
				end
				
				local dv = cc.pSub(s_operate_point, f_operate_point)
				local dv_angle = cToolsForLua:calc2VecAngle(1.0, 0.0, dv.x, dv.y)
				local dt_cer = math.sqrt(dv.x * dv.x + dv.y * dv.y)	--两人相距中心距离
				local dt_min = dt_cer - helpModelMD.m_RoleRadius	--两人相距最小距离
				local dt_max = dt_cer + helpModelMD.m_RoleRadius	--两人相距最大距离
				
				local isHit = false
               
                --local addAtkVar = 0
                local addAtkVar = stepDataModelMD.getBuffValue( f_results_heroData,f_results_heroData,nil,buffsModelMD.m_BuffType.addAtkRange )

				if _operateAngleRange(dv_angle, f_operate_angle, f_results_heroData.attack_angle_range) then
					isHit = _operateRange(dt_min, dt_max, f_results_heroData.attack_min_range, f_results_heroData.attack_max_range + addAtkVar)
				else
					isHit = _operateIntersectionLineCircle(s_operate_point, f_operate_point, f_operate_angle
						, f_results_heroData.attack_min_range, f_results_heroData.attack_max_range, f_results_heroData.attack_angle_range)
				end
				
				if isHit then
					--命中
                    f_atk_play_data.action_hit = true
                    
					--启动前给对方BUFF
					for k , v in pairs(f_results_heroData.attack_buffs_before_target) do
						--写入武将数据
						stepDataModelMD.addHeroBuffWithBuffId(s_results_heroData, k)
						--写入播放数据
						s_atk_play_data.addBuffs_before_target[tostring(k)] = true
					end
					
					
					--基础五属性修改BUFF
					local f_origin_base = stepDataModelMD.operateChangeBaseBuff(f_results_heroData)
					local s_origin_base = stepDataModelMD.operateChangeBaseBuff(s_results_heroData)
					
					--自己攻击增加BUFF
					local addAtkPercentValue = 0
					local self_attack_add_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.attackAdd)
					if self_attack_add_buff then
						local configData = g_data.duel_buff[self_attack_add_buff.buffId]
						g_custom_loadFunc("OperateBuff", "(v1,v2,distance)", " return "..configData.client_formula)
						addAtkPercentValue = externFunctionOperateBuff(f_results_heroData, s_results_heroData,dt_cer)
					end
					
					--对方伤害减免BUFF
					local subHurtPercentValue = 0
					local target_hurt_sub_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.hurtSub)
					if target_hurt_sub_buff then
						local configData = g_data.duel_buff[target_hurt_sub_buff.buffId]
						g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
						subHurtPercentValue = externFunctionOperateBuff(s_results_heroData, f_results_heroData)
					end
					
                    --对方承受伤害加倍
                    local doubleHurtPercentValue = 0
                    local double_hurt_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.doubleHurt)
                    if double_hurt_buff then
                        local configData = g_data.duel_buff[double_hurt_buff.buffId]
                        g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                        doubleHurtPercentValue = externFunctionOperateBuff(s_results_heroData, f_results_heroData)
                    end
                    
					--扣hp
					local sub_hp = math.ceil(stepDataModelMD.operateAttackForceWithServerData(f_results_heroData, s_results_heroData)
					 * (1 + addAtkPercentValue)
					 * (1 - subHurtPercentValue)
                     * (1 + doubleHurtPercentValue)
					)
					s_results_heroData.hero_current_hp = math.max(0, s_results_heroData.hero_current_hp - sub_hp)
                    s_atk_play_data.hit_hp = sub_hp
					s_atk_play_data.after_blow_cur_hp = s_results_heroData.hero_current_hp
					
					--反伤
					local target_reflectHurt_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.reflectHurt)
					if target_reflectHurt_buff then
						local configData = g_data.duel_buff[target_reflectHurt_buff.buffId]
						g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
						local reflectHurt_hp = math.ceil(sub_hp * externFunctionOperateBuff(s_results_heroData, f_results_heroData))
                        f_atk_play_data.hit_hp = f_atk_play_data.hit_hp + reflectHurt_hp
						f_results_heroData.hero_current_hp = math.max(0, f_results_heroData.hero_current_hp - reflectHurt_hp)
						f_atk_play_data.after_hit_cur_hp = f_results_heroData.hero_current_hp
						f_atk_play_data.action_hit_change_hp = true
					end
					
                    local f_mianSi_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.mianSi)
                    if f_mianSi_buff then
                        if f_results_heroData.hero_current_hp <= 0 then
                            local configData = g_data.duel_buff[f_mianSi_buff.buffId]
                            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                            local back_hp = math.ceil(externFunctionOperateBuff(f_results_heroData, s_results_heroData) * f_results_heroData.hero_max_hp)
                            f_atk_play_data.back_hp = back_hp
                            f_results_heroData.hero_current_hp = math.min(f_results_heroData.hero_max_hp,back_hp)
                            f_atk_play_data.action_back_hp = true
                            f_atk_play_data.after_hit_cur_hp = f_results_heroData.hero_current_hp
                            _subRmoveBuffCount(f_results_heroData,f_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
                        end
                    end

                    local s_mianSi_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.mianSi) 
                    if s_mianSi_buff then
                        if s_results_heroData.hero_current_hp <= 0 then
                            local configData = g_data.duel_buff[s_mianSi_buff.buffId]
                            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                            local back_hp = math.ceil(externFunctionOperateBuff(s_results_heroData, f_results_heroData) * s_results_heroData.hero_max_hp)
                            s_atk_play_data.back_hp = back_hp
                            s_results_heroData.hero_current_hp = math.min(s_results_heroData.hero_max_hp,back_hp)
                            s_atk_play_data.action_back_hit_hp = true
                            s_atk_play_data.after_blow_cur_hp = s_results_heroData.hero_current_hp
                            _subRmoveBuffCount(s_results_heroData,s_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
                        end
                    end


					--恢复基础五属性
					stepDataModelMD.resumeChangeBaseBuff(f_results_heroData, f_origin_base)
					stepDataModelMD.resumeChangeBaseBuff(s_results_heroData, s_origin_base)
					
					--减少BUFF
					_subCountBuff_firstAttackOperateEnd(f_results_heroData, f_roundEnd_play_data, s_results_heroData, s_roundEnd_play_data)
					
					--启动后给对方BUFF
					for k , v in pairs(f_results_heroData.attack_buffs_after_target) do
						--写入武将数据
						stepDataModelMD.addHeroBuffWithBuffId(s_results_heroData, k)
						--写入播放数据
						s_atk_play_data.addBuffs_after_target[tostring(k)] = true
					end
					
					--检测先手攻击后先手死亡（反伤等）
					if f_results_heroData.hero_current_hp <= 0 then
                        f_atk_play_data.action_hit_death = true
					end
						
					--检测先手攻击后后手死亡
					if s_results_heroData.hero_current_hp <= 0 then
                        s_atk_play_data.action_death = true
					end
					
				else
					--未命中
					--减少BUFF
					_subCountBuff_firstAttackOperateEnd(f_results_heroData, f_roundEnd_play_data, s_results_heroData, s_roundEnd_play_data)
				
				end
				
				--启动后给自身BUFF
				for k , v in pairs(f_results_heroData.attack_buffs_after_self) do
					--写入武将数据
					stepDataModelMD.addHeroBuffWithBuffId(f_results_heroData, k)
					--写入播放数据
					f_atk_play_data.addBuffs_after_self[tostring(k)] = true
				end
				
			end
			
		else
			--因为BUFF原因无法攻击
			
			--减少BUFF
			_subCountBuff_firstCanNotAttack(f_results_heroData, f_roundEnd_play_data, s_results_heroData, s_roundEnd_play_data)	
			
		end
		
	end
	
	
	do --后手方----------------------------------------------------------------------------------------------
        
		local canAtkAction = true
		
		local has_buff_dizzy = stepDataModelMD.checkHasBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.dizzy)
		
		if has_buff_dizzy then
			--有眩晕
			canAtkAction = false
		end
		
		if canAtkAction then
		
			if s_results_heroData.hero_current_hp > 0 and f_results_heroData.hero_current_hp > 0 then
				
                local has_buff_silence = stepDataModelMD.checkHasBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.silence)

				if s_operate_skill == 1 and not has_buff_silence then
					--技能攻击
					if s_results_heroData.hero_current_sp >= s_results_heroData.skill_need_sp then
						
						s_atk_play_data.action_skill = true
						
						--启动前给自身BUFF
						for k , v in pairs(s_results_heroData.skill_buffs_before_self) do
							--写入武将数据
							stepDataModelMD.addHeroBuffWithBuffId(s_results_heroData, k)
							--写入播放数据
							s_atk_play_data.addBuffs_before_self[tostring(k)] = true
						end
						
						--扣SP
						local sub_sp = s_results_heroData.skill_need_sp
						s_results_heroData.hero_current_sp = s_results_heroData.hero_current_sp - sub_sp
						s_atk_play_data.after_usedSkill_cur_sp = s_results_heroData.hero_current_sp
						
						local dv = cc.pSub(f_operate_point, s_operate_point)
						local dv_angle = cToolsForLua:calc2VecAngle(1.0, 0.0, dv.x, dv.y)
						local dt_cer = math.sqrt(dv.x * dv.x + dv.y * dv.y)	--两人相距中心距离
						local dt_min = dt_cer - helpModelMD.m_RoleRadius	--两人相距最小距离
						local dt_max = dt_cer + helpModelMD.m_RoleRadius	--两人相距最大距离
						
						local isHit = false
						if _operateAngleRange(dv_angle, s_operate_angle, s_results_heroData.skill_angle_range) then
							isHit = _operateRange(dt_min, dt_max, s_results_heroData.skill_min_range, s_results_heroData.skill_max_range)
						else
							isHit = _operateIntersectionLineCircle(f_operate_point, s_operate_point, s_operate_angle
								, s_results_heroData.skill_min_range, s_results_heroData.skill_max_range, s_results_heroData.skill_angle_range)
						end
						
						if isHit then
							--命中
							
							s_atk_play_data.action_hit = true
							
							
							--启动前给对方BUFF
							for k , v in pairs(s_results_heroData.skill_buffs_before_target) do
                                
                                if stepDataModelMD.randomHeroBuff(s_results_heroData,k) then

								    --写入武将数据
								    stepDataModelMD.addHeroBuffWithBuffId(f_results_heroData, k)
								    --写入播放数据
								    f_atk_play_data.addBuffs_before_target[tostring(k)] = true
                                end
							end
							
							
							--基础五属性修改BUFF
							local f_origin_base = stepDataModelMD.operateChangeBaseBuff(f_results_heroData)
							local s_origin_base = stepDataModelMD.operateChangeBaseBuff(s_results_heroData)
							
							
							--自己攻击增加BUFF
							local addAtkPercentValue = 0
							local self_attack_add_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.attackAdd)
							if self_attack_add_buff then
								local configData = g_data.duel_buff[self_attack_add_buff.buffId]
								g_custom_loadFunc("OperateBuff", "(v1,v2,distance)", " return "..configData.client_formula)
								addAtkPercentValue = externFunctionOperateBuff(s_results_heroData, f_results_heroData,dt_cer)
							end
							
							--对方伤害减免BUFF
							local subHurtPercentValue = 0
							local target_hurt_sub_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.hurtSub)
							if target_hurt_sub_buff then
								local configData = g_data.duel_buff[target_hurt_sub_buff.buffId]
								g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
								subHurtPercentValue = externFunctionOperateBuff(f_results_heroData, s_results_heroData)
							end

                            --对方技能伤害减少的BUFF
                            local skillLessPercentValue = 0
                            local self_skill_less_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.skillLess)
                            if self_skill_less_buff then
                                local configData = g_data.duel_buff[self_skill_less_buff.buffId]
                                g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
							    skillLessPercentValue = externFunctionOperateBuff(f_results_heroData, s_results_heroData)
                            end
                            
                            --对方承受伤害加倍
                            local doubleHurtPercentValue = 0
                            local double_hurt_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.doubleHurt)
                            if double_hurt_buff then
                                local configData = g_data.duel_buff[double_hurt_buff.buffId]
                                g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                doubleHurtPercentValue = externFunctionOperateBuff(f_results_heroData, s_results_heroData)
                            end

							--扣hp
							local sub_hp = math.ceil(stepDataModelMD.operateSkillForceWithServerData(s_results_heroData, f_results_heroData)
							 * (1 + addAtkPercentValue)
							 * (1 - subHurtPercentValue)
                             * (1 - skillLessPercentValue)
                             * (1 + doubleHurtPercentValue)
							)
                            
							f_results_heroData.hero_current_hp = math.max(0, f_results_heroData.hero_current_hp - sub_hp)
                            f_atk_play_data.hit_hp = sub_hp
							f_atk_play_data.after_blow_cur_hp = f_results_heroData.hero_current_hp
                            
							--反伤
							local target_reflectHurt_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.reflectHurt)
							if target_reflectHurt_buff then
								local configData = g_data.duel_buff[target_reflectHurt_buff.buffId]
								g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
								local reflectHurt_hp = math.ceil(sub_hp * externFunctionOperateBuff(f_results_heroData, s_results_heroData))
                                s_atk_play_data.hit_hp = s_atk_play_data.hit_hp + reflectHurt_hp
								s_results_heroData.hero_current_hp = math.max(0, s_results_heroData.hero_current_hp - reflectHurt_hp)
								s_atk_play_data.after_hit_cur_hp = s_results_heroData.hero_current_hp
								s_atk_play_data.action_hit_change_hp = true
							end
                            
                            --吸血
                            local suck_blood_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.suckBlood)
                            if suck_blood_buff then
                                local configData = g_data.duel_buff[suck_blood_buff.buffId]
                                g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                local reflectHurt_hp = math.ceil(sub_hp * externFunctionOperateBuff(s_results_heroData,f_results_heroData))
                                s_atk_play_data.back_hp = s_atk_play_data.back_hp + reflectHurt_hp
                                s_results_heroData.hero_current_hp = math.min(s_results_heroData.hero_max_hp,s_results_heroData.hero_current_hp + reflectHurt_hp)
                                s_atk_play_data.after_hit_cur_hp = s_results_heroData.hero_current_hp
                                s_atk_play_data.action_back_hp = true
                            end
                            
                            local s_mianSi_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.mianSi) 
                            if s_mianSi_buff then
                                if s_results_heroData.hero_current_hp <= 0 then
                                    local configData = g_data.duel_buff[s_mianSi_buff.buffId]
                                    g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                    local back_hp = math.ceil(externFunctionOperateBuff(s_results_heroData, f_results_heroData) * s_results_heroData.hero_max_hp)
                                    s_atk_play_data.back_hp = back_hp
                                    s_results_heroData.hero_current_hp = math.min(s_results_heroData.hero_max_hp,back_hp)
                                    s_atk_play_data.action_back_hp = true
                                    s_atk_play_data.after_hit_cur_hp = s_results_heroData.hero_current_hp
                                    _subRmoveBuffCount(s_results_heroData,s_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
                                end
                            end

                            local f_mianSi_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.mianSi)
                            if f_mianSi_buff then
                                if f_results_heroData.hero_current_hp <= 0 then
                                    local configData = g_data.duel_buff[f_mianSi_buff.buffId]
                                    g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                    local back_hp = math.ceil(externFunctionOperateBuff(f_results_heroData, s_results_heroData) * f_results_heroData.hero_max_hp)
                                    f_atk_play_data.back_hp = back_hp
                                    f_results_heroData.hero_current_hp = math.min(f_results_heroData.hero_max_hp,back_hp)
                                    f_atk_play_data.action_back_hit_hp = true
                                    f_atk_play_data.after_blow_cur_hp = f_results_heroData.hero_current_hp
                                    _subRmoveBuffCount(f_results_heroData,f_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
                                end
                            end


							--恢复基础五属性
							stepDataModelMD.resumeChangeBaseBuff(f_results_heroData, f_origin_base)
							stepDataModelMD.resumeChangeBaseBuff(s_results_heroData, s_origin_base)
							
							--减少BUFF
							_subCountBuff_secondAttackOperateEnd(s_results_heroData, s_roundEnd_play_data, f_results_heroData, f_roundEnd_play_data)
							
							--启动后给对方BUFF
							for k , v in pairs(s_results_heroData.skill_buffs_after_target) do
								--写入武将数据
								stepDataModelMD.addHeroBuffWithBuffId(f_results_heroData, k)
								--写入播放数据
								f_atk_play_data.addBuffs_after_target[tostring(k)] = true
							end
							
							--检测后手攻击后后手死亡（反伤等）
							if s_results_heroData.hero_current_hp <= 0 then
								s_atk_play_data.action_hit_death = true
							end
							
							--检测后手攻击后先手死亡
							if f_results_heroData.hero_current_hp <= 0 then
								f_atk_play_data.action_death = true
							end
							
						else
							--未命中
                            local back_full_sp_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.backFullSp)
							if back_full_sp_buff then
                                local configData = g_data.duel_buff[back_full_sp_buff.buffId]
                                g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                local bcakSpNum = externFunctionOperateBuff(s_results_heroData,f_results_heroData)
                                s_results_heroData.hero_current_sp = bcakSpNum
                                s_atk_play_data.after_usedSkill_cur_sp = s_results_heroData.hero_current_sp
                            end
							--减少BUFF
							_subCountBuff_secondAttackOperateEnd(s_results_heroData, s_roundEnd_play_data, f_results_heroData, f_roundEnd_play_data)
							
						end
						
						--启动后给自身BUFF
						for k , v in pairs(s_results_heroData.skill_buffs_after_self) do
							--写入武将数据
							stepDataModelMD.addHeroBuffWithBuffId(s_results_heroData, k)
							--写入播放数据
							s_atk_play_data.addBuffs_after_self[tostring(k)] = true
						end
						
						--张辽瞬移
						if 
                            s_results_heroData.skill_configId == helpModelMD.ZHANGLIAO_SKILL or 
                            s_results_heroData.skill_configId == helpModelMD.XIAHOUDUN_SKILL 
                        then
							local dv = cc.pSub(f_final_point, s_final_point)
							local dl = math.sqrt(dv.x * dv.x + dv.y * dv.y)
							if dl > 100 then
								local s = 100 / dl
								local newPos = cc.pSub(f_final_point, cc.p(dv.x * s, dv.y * s))
								if checkMapPoint(newPos) then
									s_final_point = newPos
									s_final_angle = cToolsForLua:calc2VecAngle(1.0, 0.0, dv.x, dv.y)
									s_atk_play_data.atk_teleporting_pos = s_final_point
									s_atk_play_data.atk_teleporting_angle = s_final_angle
								end
							end
						end
						
					else
						--SP不够
						
						--减少BUFF
						_subCountBuff_secondAttackOperateEnd(s_results_heroData, s_roundEnd_play_data, f_results_heroData, f_roundEnd_play_data)
					end
					
				else
                    
					--普通攻击
					s_atk_play_data.action_attack = true
                    --混乱
				    local s_confusion_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.confusion)
                    if s_confusion_buff then
					    s_atk_play_data.action_attack = false
                    end
                    
					--启动前给自身BUFF
					for k , v in pairs(s_results_heroData.attack_buffs_before_self) do
						--写入武将数据
						stepDataModelMD.addHeroBuffWithBuffId(s_results_heroData, k)
						--写入播放数据
						s_atk_play_data.addBuffs_before_self[tostring(k)] = true
					end
					
					local dv = cc.pSub(f_operate_point, s_operate_point)
					local dv_angle = cToolsForLua:calc2VecAngle(1.0, 0.0, dv.x, dv.y)
					local dt_cer = math.sqrt(dv.x * dv.x + dv.y * dv.y)	--两人相距中心距离
					local dt_min = dt_cer - helpModelMD.m_RoleRadius	--两人相距最小距离
					local dt_max = dt_cer + helpModelMD.m_RoleRadius	--两人相距最大距离
					
                    --增加攻击距离
                    --local addAtkVar = 0
                    local addAtkVar = stepDataModelMD.getBuffValue( s_results_heroData,s_results_heroData,nil,buffsModelMD.m_BuffType.addAtkRange )
                    
					local isHit = false
					if _operateAngleRange(dv_angle, s_operate_angle, s_results_heroData.attack_angle_range) then
						isHit = _operateRange(dt_min, dt_max, s_results_heroData.attack_min_range, s_results_heroData.attack_max_range + addAtkVar)
					else
						isHit = _operateIntersectionLineCircle(f_operate_point, s_operate_point, s_operate_angle
							, s_results_heroData.attack_min_range, s_results_heroData.attack_max_range, s_results_heroData.attack_angle_range)
					end
					
					if isHit then
						--命中
						
						s_atk_play_data.action_hit = true
						
						--启动前给对方BUFF
						for k , v in pairs(s_results_heroData.attack_buffs_before_target) do
							--写入武将数据
							stepDataModelMD.addHeroBuffWithBuffId(f_results_heroData, k)
							--写入播放数据
							f_atk_play_data.addBuffs_before_target[tostring(k)] = true
						end
						
						
						--基础五属性修改BUFF
						local f_origin_base = stepDataModelMD.operateChangeBaseBuff(f_results_heroData)
						local s_origin_base = stepDataModelMD.operateChangeBaseBuff(s_results_heroData)
						
						
						--自己攻击增加BUFF
						local addAtkPercentValue = 0
						local self_attack_add_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.attackAdd)
						if self_attack_add_buff then
							local configData = g_data.duel_buff[self_attack_add_buff.buffId]
							g_custom_loadFunc("OperateBuff", "(v1,v2,distance)", " return "..configData.client_formula)
							addAtkPercentValue = externFunctionOperateBuff(s_results_heroData,f_results_heroData,dt_cer)
						end
						
						--对方伤害减免BUFF
						local subHurtPercentValue = 0
						local target_hurt_sub_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.hurtSub)
						if target_hurt_sub_buff then
							local configData = g_data.duel_buff[target_hurt_sub_buff.buffId]
							g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
							subHurtPercentValue = externFunctionOperateBuff(f_results_heroData, s_results_heroData)
						end
						
                        --对方承受伤害加倍
                        local doubleHurtPercentValue = 0
                        local double_hurt_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.doubleHurt)
                        if double_hurt_buff then
                            local configData = g_data.duel_buff[double_hurt_buff.buffId]
                            g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                            doubleHurtPercentValue = externFunctionOperateBuff(f_results_heroData, s_results_heroData)
                        end
                     
						--扣hp
						local sub_hp = math.ceil(stepDataModelMD.operateAttackForceWithServerData(s_results_heroData, f_results_heroData)
						 * (1 + addAtkPercentValue)
						 * (1 - subHurtPercentValue)
                         * (1 + doubleHurtPercentValue)
						)
						f_results_heroData.hero_current_hp = math.max(0, f_results_heroData.hero_current_hp - sub_hp)
                        f_atk_play_data.hit_hp = sub_hp
						f_atk_play_data.after_blow_cur_hp = f_results_heroData.hero_current_hp

						--反伤
						local target_reflectHurt_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.reflectHurt)
						if target_reflectHurt_buff then
							local configData = g_data.duel_buff[target_reflectHurt_buff.buffId]
							g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
							local reflectHurt_hp = math.ceil(sub_hp * externFunctionOperateBuff(f_results_heroData, s_results_heroData))
                            s_atk_play_data.hit_hp = s_atk_play_data.hit_hp + reflectHurt_hp
							s_results_heroData.hero_current_hp = math.max(0, s_results_heroData.hero_current_hp - reflectHurt_hp)
							s_atk_play_data.after_hit_cur_hp = s_results_heroData.hero_current_hp
							s_atk_play_data.action_hit_change_hp = true
						end

                        local s_mianSi_buff = stepDataModelMD.findBuffWithTypeId(s_results_heroData, buffsModelMD.m_BuffType.mianSi) 
                        if s_mianSi_buff then
                            if s_results_heroData.hero_current_hp <= 0 then
                                local configData = g_data.duel_buff[s_mianSi_buff.buffId]
                                g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                local back_hp = externFunctionOperateBuff(s_results_heroData, f_results_heroData)  * s_results_heroData.hero_max_hp
                                s_atk_play_data.back_hp = back_hp
                                s_results_heroData.hero_current_hp = math.min(s_results_heroData.hero_max_hp,back_hp)
                                s_atk_play_data.action_back_hp = true
                                s_atk_play_data.after_hit_cur_hp = s_results_heroData.hero_current_hp
                                _subRmoveBuffCount(s_results_heroData,s_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
                            end
                        end

                        local f_mianSi_buff = stepDataModelMD.findBuffWithTypeId(f_results_heroData, buffsModelMD.m_BuffType.mianSi)
                        if f_mianSi_buff then
                            if f_results_heroData.hero_current_hp <= 0 then
                                local configData = g_data.duel_buff[f_mianSi_buff.buffId]
                                g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
                                local back_hp = math.ceil(externFunctionOperateBuff(f_results_heroData, s_results_heroData) * f_results_heroData.hero_max_hp)
                                f_atk_play_data.back_hp = back_hp
                                f_results_heroData.hero_current_hp = math.min(f_results_heroData.hero_max_hp,back_hp)
                                f_atk_play_data.action_back_hit_hp = true
                                f_atk_play_data.after_blow_cur_hp = f_results_heroData.hero_current_hp
                                _subRmoveBuffCount(f_results_heroData,f_roundEnd_play_data,buffsModelMD.m_BuffType.mianSi)
                            end
                        end
                        
						--恢复基础五属性
						stepDataModelMD.resumeChangeBaseBuff(f_results_heroData, f_origin_base)
						stepDataModelMD.resumeChangeBaseBuff(s_results_heroData, s_origin_base)
						
						--减少BUFF
						_subCountBuff_secondAttackOperateEnd(s_results_heroData, s_roundEnd_play_data, f_results_heroData, f_roundEnd_play_data)
						
						--启动后给对方BUFF
						for k , v in pairs(s_results_heroData.attack_buffs_after_target) do
							--写入武将数据
							stepDataModelMD.addHeroBuffWithBuffId(f_results_heroData, k)
							--写入播放数据
							f_atk_play_data.addBuffs_after_target[tostring(k)] = true
						end
						
						--检测后手攻击后后手死亡（反伤等）
						if s_results_heroData.hero_current_hp <= 0 then
							s_atk_play_data.action_hit_death = true
						end
						
						--检测后手攻击后先手死亡
						if f_results_heroData.hero_current_hp <= 0 then
                            f_atk_play_data.action_death = true
						end
						
					else
						--未命中
						
						--减少BUFF
						_subCountBuff_secondAttackOperateEnd(s_results_heroData, s_roundEnd_play_data, f_results_heroData, f_roundEnd_play_data)
						
					end
					
					--启动后给自身BUFF
					for k , v in pairs(s_results_heroData.attack_buffs_after_self) do
						--写入武将数据
						stepDataModelMD.addHeroBuffWithBuffId(s_results_heroData, k)
						--写入播放数据
						s_atk_play_data.addBuffs_after_self[tostring(k)] = true
					end
					
				end
				
			else
				--某一方死翘翘
				
				--减少BUFF
				_subCountBuff_secondAttackOperateEnd(s_results_heroData, s_roundEnd_play_data, f_results_heroData, f_roundEnd_play_data)
				
			end
			
		else
			--因为BUFF原因无法攻击
			
			--减少BUFF
			_subCountBuff_secondCanNotAttack(s_results_heroData, s_roundEnd_play_data, f_results_heroData, f_roundEnd_play_data)
		
		end
		
	end
	
	
	do --回合结束时的buff以及恢复计算----------------------------------------------------------------------------------------------
		
		stepDataModelMD.roundEndInitSetting(f_roundEnd_play_data, f_results_heroData.hero_max_hp, f_results_heroData.hero_current_hp
			, f_results_heroData.hero_max_sp, f_results_heroData.hero_current_sp)
		
		stepDataModelMD.roundEndInitSetting(s_roundEnd_play_data, s_results_heroData.hero_max_hp, s_results_heroData.hero_current_hp
			, s_results_heroData.hero_max_sp, s_results_heroData.hero_current_sp)
		
		if f_results_heroData.hero_current_hp > 0 then --先手方还活着----------------------------------------------------------------------------------------------
		
			--补充buff判定
			
			--恢复SP
			local restore_sp = math.min(f_results_heroData.hero_max_sp - f_results_heroData.hero_current_sp, f_results_heroData.hero_restore_sp)
			if restore_sp > 0 then
				f_results_heroData.hero_current_sp = f_results_heroData.hero_current_sp + restore_sp
				f_roundEnd_play_data.after_restore_cur_sp = f_results_heroData.hero_current_sp
			end
		
		end
		
		if s_results_heroData.hero_current_hp > 0 then --后手方还活着----------------------------------------------------------------------------------------------
			
			--补充buff判定
			
			--恢复SP
			local restore_sp = math.min(s_results_heroData.hero_max_sp - s_results_heroData.hero_current_sp, s_results_heroData.hero_restore_sp)
			if restore_sp > 0 then
				s_results_heroData.hero_current_sp = s_results_heroData.hero_current_sp + restore_sp
				s_roundEnd_play_data.after_restore_cur_sp = s_results_heroData.hero_current_sp
			end
			
			
		end
	
	end
	
	
	local season_outcome , season_win = false , 0
	do --胜负判定
		
		if f_results_heroData.hero_current_hp <= 0 then
			if s_results_heroData.hero_current_hp > 0 then
				--后手胜利
				season_outcome = true
				season_win = (s_place == "A" and 1 or 2)
			else
				--平局
				season_outcome = true
				season_win = 0
			end
		elseif s_results_heroData.hero_current_hp <= 0 then
			if f_results_heroData.hero_current_hp > 0 then
				--先手胜利
				season_outcome = true
				season_win = (f_place == "A" and 1 or 2)
			else
				--平局
				season_outcome = true
				season_win = 0
			end
		elseif m_GmaeStateObject.getRound() >= MAX_ROUND then
			--到达最大回合数，平局
			season_outcome = true
			season_win = 0
		end
		
	end
	
	
	--写入结果
	m_StepDataObject.setFinalPoint(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), f_final_point)
	m_StepDataObject.setFinalAngle(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), f_final_angle)
	m_StepDataObject.setResultsHeroPart(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), f_results_heroData)
	
	m_StepDataObject.setAtkPlayData(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), f_atk_play_data)
	m_StepDataObject.setRoundEndPlayData(f_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), f_roundEnd_play_data)
	
	m_StepDataObject.setFinalPoint(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), s_final_point)
	m_StepDataObject.setFinalAngle(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), s_final_angle)
	m_StepDataObject.setResultsHeroPart(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), s_results_heroData)
	
	m_StepDataObject.setAtkPlayData(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), s_atk_play_data)
	m_StepDataObject.setRoundEndPlayData(s_place, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound(), s_roundEnd_play_data)
	
	if season_outcome then
		m_StepDataObject.setWin(m_GmaeStateObject.getSeason(), season_win)
	end
	
end


--播放
function playAction()
	if m_StepDataObject == nil or m_A_Role == nil or m_B_Role == nil then
		return
	end
	
	local first = m_StepDataObject.getFirst(m_GmaeStateObject.getSeason())
	
	
	local f_place = first == 1 and "A" or "B"
	
	local s_place = first == 2 and "A" or "B"
	
	
	local f_role , f_moveRange , f_attackRange , f_skillRange = _getPlaceInfo(f_place)
	
	local s_role , s_moveRange , s_attackRange , s_skillRange = _getPlaceInfo(s_place)
	
	
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
	
	local season_outcome = m_StepDataObject.getOutcome(m_GmaeStateObject.getSeason())
	
	
	--下一步骤
	local function playNextStep()
		if season_outcome then
			--下一场次
			nextSeason()
		else
			--下一回合
			nextRound()
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
			m_AtkEffectRoot:addChild(helpModelMD.createSubHpText(f_atk_play_data.hit_hp, f_role.lua_getPosition(), s_role.lua_getPosition()))
            
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
				m_AtkEffectRoot:addChild(helpModelMD.createSubHpText(f_atk_play_data.hit_hp, f_role.lua_getPosition(), s_role.lua_getPosition()))
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
		if f_atk_play_data.action_skill and ( f_skill_configId == helpModelMD.ZHANGLIAO_SKILL or f_skill_configId == helpModelMD.XIAHOUDUN_SKILL ) then
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


--检测地图点
function checkMapPoint(pos)
	if m_MapBottom then
		return m_MapBottom.lua_checkNodePoint(pos)
	end
	return false
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

--获得手动武将当前数据
function getCurrentManualHeroData()
	if m_StepDataObject then
		return m_StepDataObject.getHeroCurrentData(m_ManualPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	end
end

--获得自动武将当前数据
function getCurrentAutoHeroData()
	if m_StepDataObject then
		return m_StepDataObject.getHeroCurrentData(m_AutoPlace, m_GmaeStateObject.getSeason(), m_GmaeStateObject.getRound())
	end
end

--获得手动武将初始化数据
function getInitManualHeroData(season)
	if m_StepDataObject then
		return m_StepDataObject.getHeroInitData(m_ManualPlace, season)
	end
end

--获得自动武将初始化数据
function getInitAutoHeroData(season)
	if m_StepDataObject then
		return m_StepDataObject.getHeroInitData(m_AutoPlace, season)
	end
end

--获得双方名字
function getPlayerName()
	if m_ServerData then
		return {["A"] = m_ServerData["A"].player_name , ["B"] = m_ServerData["B"].player_name}
	end
end

--进入下一回合
function nextRound()
	if m_GmaeStateObject and m_OperateStateObject then
		local function addRoundCallback()
			if m_GmaeStateObject and m_OperateStateObject then
				local operate = m_OperateStateObject.getOperateState()
				m_GmaeStateObject.addRound()
				local function startControl()
					--开始操作
					m_A_Role.lua_PlayBuffWind()
					m_B_Role.lua_PlayBuffWind()
					if m_OperateStateObject.getOperateState() == operate then
						m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.move)
					end
				end
				startControl()
			end
		end
		g_autoCallback.addCocosList( addRoundCallback , 1.0 / m_ScaleTime)
	end
end

--进入下一场次
function nextSeason()
	if m_GmaeStateObject and m_OperateStateObject then
		local function addRoundCallback()
			if m_GmaeStateObject and m_OperateStateObject then
				local function onNext()
					if m_GmaeStateObject.getSeason() >= 3 then
						local jsonStepData = cjson.encode(m_StepDataObject.stepData)
						--cToolsForLua:writeStringToFile(jsonStepData, string.len(jsonStepData), "C:/Users/lihansong/Desktop/wudouhuiheshuju.txt")
						local season_win_1 = m_StepDataObject.getWin(1)
						local season_win_2 = m_StepDataObject.getWin(2)
						local season_win_3 = m_StepDataObject.getWin(3)
						local resultInfo = {
							["result"] = {
								["1"] = season_win_1,
								["2"] = season_win_2,
								["3"] = season_win_3,
								["backplay"] = jsonStepData
							},
							["info"] = m_ServerData
						}
						require("game.uilayer.fightperipheral.FightResult").show(resultInfo)
						local last_tournament_count = g_saveCache.tournament_count_save
						g_saveCache.tournament_count_save = last_tournament_count + 1
					else
						if m_GmaeStateObject.getSeason() >= 2 and m_StepDataObject.getWin(1) == m_StepDataObject.getWin(2) then
							--提前分出胜负
							local jsonStepData = cjson.encode(m_StepDataObject.stepData)
							--cToolsForLua:writeStringToFile(jsonStepData, string.len(jsonStepData), "C:/Users/lihansong/Desktop/wudouhuiheshuju.txt")
							local season_win_1 = m_StepDataObject.getWin(1)
							local season_win_2 = m_StepDataObject.getWin(2)
							local season_win_3 = 0
							local resultInfo = {
								["result"] = {
									["1"] = season_win_1,
									["2"] = season_win_2,
									["3"] = season_win_3,
									["backplay"] = jsonStepData
								},
								["info"] = m_ServerData
							}
							require("game.uilayer.fightperipheral.FightResult").show(resultInfo)
							local last_tournament_count = g_saveCache.tournament_count_save
							g_saveCache.tournament_count_save = last_tournament_count + 1
						else
							local function startControl()
								--开始操作
								m_A_Role.lua_PlayBuffWind()
								m_B_Role.lua_PlayBuffWind()
								
								if m_OperateStateObject.getOperateState() == stateModelMD.m_OperateState.readying then
									m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.move)
								end
								
							end
							local function playGuildDialog()
								--引导对话框
								if g_saveCache.tournament_count_save >= 1 then
									startControl()
									return
								end
								local dialogConfig = g_data.duel_guide[m_GmaeStateObject.getSeason()]
								if dialogConfig == nil then
									startControl()
									return
								end
								local index = 1
								local function playGuildDialogStep()
									local dialogStepConfig = dialogConfig.steps[index]
									if dialogStepConfig == nil then
										startControl()
									else
										index = index + 1
										local guildDialog = require("game.uilayer.common.DialogueLayer"):create(
											g_tr(dialogStepConfig[1])
											, playGuildDialogStep
											, dialogStepConfig[2]
											,nil
											,nil
											,nil
											,true
											)
										g_sceneManager.addNodeForUI(guildDialog)
									end
								end
								playGuildDialogStep()
							end
							local function playStart()
								--开始战斗动画
								playAutoSceneEffect(
									"anime/Effect_LeiTaiGuoChangText_ZhanDouKaiShi/Effect_LeiTaiGuoChangText_ZhanDouKaiShi.ExportJson"
									, "Effect_LeiTaiGuoChangText_ZhanDouKaiShi"
									, "ZhanDouKaiShi"
									, playGuildDialog
									)
							end
							local function playFirst()
								--播放先手方动画
								local season_first = m_StepDataObject.getFirst(m_GmaeStateObject.getSeason())
								local firstAniName = nil
								if season_first == 1 then
									firstAniName = ("A" == m_ManualPlace and "WoFanHuiHe" or "DuiFanHuiHe")
								elseif season_first == 2 then
									firstAniName = ("B" == m_ManualPlace and "WoFanHuiHe" or "DuiFanHuiHe")
								else
									firstAniName = "DuiFanHuiHe"
								end
								playAutoSceneEffect(
									"anime/Effect_LeiTaiGuoChangText_HuiHe/Effect_LeiTaiGuoChangText_HuiHe.ExportJson"
									, "Effect_LeiTaiGuoChangText_HuiHe"
									, firstAniName
									, playStart
									)
							end
							local function playSeasonCount()
								--播放场次数动画
								playAutoSceneEffect(
									"anime/Effect_LeiTaiGuoChangText_HuiHe/Effect_LeiTaiGuoChangText_HuiHe.ExportJson"
									, "Effect_LeiTaiGuoChangText_HuiHe"
									, "HuiHe_"..tostring(m_GmaeStateObject.getSeason())
									, playFirst
									)
							end
							local armature , animation =  nil, nil
							local function onMovementEventCallFunc(armature, eventType, name)
								if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
									if name == "Guang" then
										m_GmaeStateObject.addSeason()
										m_OperateStateObject.setOperateState(stateModelMD.m_OperateState.readying)
										cc.Director:getInstance():setNextDeltaTimeZero(true)
										animation:play("Kai")
									elseif name == "Kai" then
										armature:removeFromParent()
										playSeasonCount()
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
				end
				
				--播放结果动画
				local season_win = m_StepDataObject.getWin(m_GmaeStateObject.getSeason())
				local winAniName = nil
				if season_win == 0 then
					winAniName = "PingJu"
				elseif season_win == 1 then
					winAniName = ("A" == m_ManualPlace and "ZhanDouShengLi" or "ZhanDouShiBai")
				elseif season_win == 2 then
					winAniName = ("B" == m_ManualPlace and "ZhanDouShengLi" or "ZhanDouShiBai")
				else
					winAniName = "PingJu"
				end
				playAutoSceneEffect(
				"anime/Effect_LeiTaiGuoChangText_ShengLiShiBai/Effect_LeiTaiGuoChangText_ShengLiShiBai.ExportJson"
				, "Effect_LeiTaiGuoChangText_ShengLiShiBai"
				, winAniName
				, onNext
				)
				
			end
		end
		g_autoCallback.addCocosList( addRoundCallback , 1.0 / m_ScaleTime)
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





return tournament