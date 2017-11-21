local surfaceModel = {}
setmetatable(surfaceModel,{__index = _G})
setfenv(1,surfaceModel)

--武斗UI界面

local schedulerModelMD = require("game.uilayer.tournament.schedulerModel")
local stateModelMD = require("game.uilayer.tournament.stateModel")

local c_tag_HpAction = 19115564
local c_tag_headImage = 19115565


local function _createHeadClip(parent, t)
	local size = parent:getContentSize()
	
	local clipNode = cc.ClippingNode:create()
	clipNode:ignoreAnchorPointForPosition(false)
	clipNode:setAnchorPoint(cc.p(0.0, 0.0))
	clipNode:setPosition(cc.p(0.0, 0.0))
	clipNode:setContentSize(size)
	clipNode:setInverted(false)
	clipNode:setAlphaThreshold(0.5)
	parent:addChild(clipNode)
	
	local stencil = cc.Sprite:create(t == 1 and "tournament/wud_touxiang1meng1.png" or "tournament/wud_touxiang2meng2.png")
	stencil:ignoreAnchorPointForPosition(false)
	stencil:setAnchorPoint(cc.p(0.5, 0.5))
	stencil:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
	clipNode:setStencil(stencil)
	
	return clipNode
end

local function _createHeadX(parent)
	local size = parent:getContentSize()
	local Ximage = cc.Sprite:create("tournament/wud_touxiang3.png")
	Ximage:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
	parent:addChild(Ximage)
	return Ximage
end

local function _createHeadO(parent)
	local size = parent:getContentSize()
	local Ximage = cc.Sprite:create("tournament/wud_touxiang4.png")
	Ximage:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
	parent:addChild(Ximage)
	return Ximage
end

local function _createHeadP(parent)
	local size = parent:getContentSize()
	local Ximage = cc.Sprite:create("tournament/wud_touxiang5.png")
	Ximage:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
	parent:addChild(Ximage)
	return Ximage
end


function createTop(model)
	local widget = g_gameTools.LoadCocosUI("Arena_character.csb", 2)

	local scale_node = widget:getChildByName("scale_node")
	
	local roundText = scale_node:getChildByName("Text_7")
	
	--roundText:setString(g_tr("tournament_round",{cur = 1 , max = 3}))
	roundText:setString("")
	
	local playerNmaes = model.getPlayerName()
	
	---------------------------------------------------------------------------
	
	
	local panel_left = scale_node:getChildByName("Panel_1")
	
	local left_hero_name = panel_left:getChildByName("Text_name1")
	
	local left_player_name = panel_left:getChildByName("Text_name1_0")
	left_player_name:setString(playerNmaes["A"])
	
	local left_LoadingBar_bottom = panel_left:getChildByName("LoadingBar_1")
	left_LoadingBar_bottom:setPercent(100)
	schedulerModelMD.resetNodeSchedulerAndActionManage(left_LoadingBar_bottom)
	
	local left_LoadingBar_top = panel_left:getChildByName("LoadingBar_2")
	left_LoadingBar_top:setPercent(100)
	
	local left_hp_text = panel_left:getChildByName("Text_zdl")
	left_hp_text:setString("")
	
	local left_head_first = panel_left:getChildByName("Image_tou1")
	local left_head_first_clip = _createHeadClip(left_head_first, 1)
	
	local left_head_second = panel_left:getChildByName("Image_tou2")
	local left_head_second_clip = _createHeadClip(left_head_second, 2)
	local left_head_second_X = _createHeadX(left_head_second)
	local left_head_second_O = _createHeadO(left_head_second)
	local left_head_second_P = _createHeadP(left_head_second)
	
	local left_head_third = panel_left:getChildByName("Image_tou3")
	local left_head_third_clip = _createHeadClip(left_head_third, 2)
	local left_head_third_X = _createHeadX(left_head_third)
	local left_head_third_O = _createHeadO(left_head_third)
	local left_head_third_P = _createHeadP(left_head_third)
	
	---------------------------------------------------------------------------
	
	
	local panel_right = scale_node:getChildByName("Panel_2")
	
	local right_hero_name = panel_right:getChildByName("Text_name1")
	
	local right_player_name = panel_right:getChildByName("Text_name1_0")
	right_player_name:setString(playerNmaes["B"])
	
	local right_LoadingBar_bottom = panel_right:getChildByName("LoadingBar_1")
	right_LoadingBar_bottom:setPercent(100)
	schedulerModelMD.resetNodeSchedulerAndActionManage(right_LoadingBar_bottom)
	
	local right_LoadingBar_top = panel_right:getChildByName("LoadingBar_2")
	right_LoadingBar_top:setPercent(100)
	
	local right_hp_text = panel_right:getChildByName("Text_zdl")
	right_hp_text:setString("")
	
	local right_head_first = panel_right:getChildByName("Image_tou1")
	local right_head_first_clip = _createHeadClip(right_head_first, 1)
	
	local right_head_second = panel_right:getChildByName("Image_tou2")
	local right_head_second_clip = _createHeadClip(right_head_second, 2)
	local right_head_second_X = _createHeadX(right_head_second)
	local right_head_second_O = _createHeadO(right_head_second)
	local right_head_second_P = _createHeadP(right_head_second)
	
	local right_head_third = panel_right:getChildByName("Image_tou3")
	local right_head_third_clip = _createHeadClip(right_head_third, 2)
	local right_head_third_X = _createHeadX(right_head_third)
	local right_head_third_O = _createHeadO(right_head_third)
	local right_head_third_P = _createHeadP(right_head_third)
	
	---------------------------------------------------------------------------
	
	
	local function _setHpPercent(top, bottom, var, isAction)
		local a = (isAction == nil and true or isAction)
		top:setPercent(var)
		bottom:stopActionByTag(c_tag_HpAction)
		if a then
			local s = bottom:getPercent()
			local t = var
			local d = (t - s) / 30
			local c = 0
			local function onHpAction()
				c = c + d
				local v = s + c
				if s > t then
					if v <= t then
						bottom:stopActionByTag(c_tag_HpAction)
						bottom:setPercent(t)
					else
						bottom:setPercent(v)
					end
				elseif s < t then
					if v >= t then
						bottom:stopActionByTag(c_tag_HpAction)
						bottom:setPercent(t)
					else
						bottom:setPercent(v)
					end
				else
					bottom:stopActionByTag(c_tag_HpAction)
					bottom:setPercent(t)
				end
			end
			local function onStartHpAction()
				bottom:stopActionByTag(c_tag_HpAction)
				local act = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.016), cc.CallFunc:create(onHpAction)))
				act:setTag(c_tag_HpAction)
				bottom:runAction(act)
			end
			local act = cc.Sequence:create(cc.DelayTime:create(0.28), cc.CallFunc:create(onStartHpAction))
			act:setTag(c_tag_HpAction)
			bottom:runAction(act)
		else
			bottom:setPercent(var)
		end
	end
	
	function widget.lua_setLeftHP(c, m)
		left_hp_text:setString(string.format("%d/%d", c, m))
		_setHpPercent(left_LoadingBar_top, left_LoadingBar_bottom, c / m * 100, true)
	end
	
	function widget.lua_setRightHP(c, m)
		right_hp_text:setString(string.format("%d/%d", c, m))
		_setHpPercent(right_LoadingBar_top, right_LoadingBar_bottom, c / m * 100, true)
	end
	
	local function _setHeadIcon(node_first, node_second, node_third, node_X_second, node_X_third, node_O_second, node_O_third, node_P_second, node_P_third, head_id_first, head_id_second, head_id_third, is_X_second, is_X_third, is_O_second, is_O_third, is_P_second, is_P_third)
		do
			node_first:removeChildByTag(c_tag_headImage)
			local parentSize = node_first:getContentSize()
			local headImage = cc.Sprite:create(g_data.sprite[head_id_first].path)
			local imageSize = headImage:getContentSize()
			headImage:setScale(parentSize.width / imageSize.width)
			headImage:setPosition(cc.p(parentSize.width * 0.5, parentSize.height * 0.5))
			node_first:addChild(headImage, 0, c_tag_headImage)
		end
		do
			node_second:removeChildByTag(c_tag_headImage)
			local parentSize = node_second:getContentSize()
			local headImage = cc.Sprite:create(g_data.sprite[head_id_second].path)
			local imageSize = headImage:getContentSize()
			headImage:setScale(parentSize.width / imageSize.width)
			headImage:setPosition(cc.p(parentSize.width * 0.5, parentSize.height * 0.5))
			node_second:addChild(headImage, 0, c_tag_headImage)
			node_X_second:setVisible(is_X_second)
			node_O_second:setVisible(is_O_second)
			node_P_second:setVisible(is_P_second)
		end
		do
			node_third:removeChildByTag(c_tag_headImage)
			local parentSize = node_third:getContentSize()
			local headImage = cc.Sprite:create(g_data.sprite[head_id_third].path)
			local imageSize = headImage:getContentSize()
			headImage:setScale(parentSize.width / imageSize.width)
			headImage:setPosition(cc.p(parentSize.width * 0.5, parentSize.height * 0.5))
			node_third:addChild(headImage, 0, c_tag_headImage)
			node_X_third:setVisible(is_X_third)
			node_O_third:setVisible(is_O_third)
			node_P_third:setVisible(is_P_third)
		end
	end
	
	function widget.lua_setLeftHeadIconAndX(head_id_first, head_id_second, head_id_third, is_X_second, is_X_third, is_O_second, is_O_third, is_P_second, is_P_third)
		_setHeadIcon(left_head_first_clip, left_head_second_clip, left_head_third_clip, left_head_second_X, left_head_third_X, left_head_second_O, left_head_third_O, left_head_second_P, left_head_third_P, head_id_first, head_id_second, head_id_third, is_X_second, is_X_third, is_O_second, is_O_third, is_P_second, is_P_third)
	end
	
	function widget.lua_setRightHeadIconAndX(head_id_first, head_id_second, head_id_third, is_X_second, is_X_third, is_O_second, is_O_third, is_P_second, is_P_third)
		_setHeadIcon(right_head_first_clip, right_head_second_clip, right_head_third_clip, right_head_second_X, right_head_third_X, right_head_second_O, right_head_third_O, right_head_second_P, right_head_third_P, head_id_first, head_id_second, head_id_third, is_X_second, is_X_third, is_O_second, is_O_third, is_P_second, is_P_third)
	end
	
	function widget.lua_onSeasonStateChange(season)
		local l1_hero , l2_hero , l3_hero , r1_hero , r2_hero , r3_hero = model.getInitHeroData()
		if season == 1 then
			left_hero_name:setString(g_tr(g_data.general[l1_hero.hero_configId].general_name))
			right_hero_name:setString(g_tr(g_data.general[r1_hero.hero_configId].general_name))
			widget.lua_setLeftHeadIconAndX(
				g_data.general[l1_hero.hero_configId].general_icon
				, g_data.general[l2_hero.hero_configId].general_icon
				, g_data.general[l3_hero.hero_configId].general_icon
				, false
				, false
				, false
				, false
				, false
				, false
				)
			widget.lua_setRightHeadIconAndX(
				g_data.general[r1_hero.hero_configId].general_icon
				, g_data.general[r2_hero.hero_configId].general_icon
				, g_data.general[r3_hero.hero_configId].general_icon
				, false
				, false
				, false
				, false
				, false
				, false
				)
		elseif season == 2 then
			left_hero_name:setString(g_tr(g_data.general[l2_hero.hero_configId].general_name))
			right_hero_name:setString(g_tr(g_data.general[r2_hero.hero_configId].general_name))
			local win_1 = model.getSeasonWin(1)
			widget.lua_setLeftHeadIconAndX(
				g_data.general[l2_hero.hero_configId].general_icon
				, g_data.general[l3_hero.hero_configId].general_icon
				, g_data.general[l1_hero.hero_configId].general_icon
				, false
				, (win_1 == 2 and true or false)
				, false
				, (win_1 == 1 and true or false)
				, false
				, (win_1 == 0 and true or false)
				)
			widget.lua_setRightHeadIconAndX(
				g_data.general[r2_hero.hero_configId].general_icon
				, g_data.general[r3_hero.hero_configId].general_icon
				, g_data.general[r1_hero.hero_configId].general_icon
				, false
				, (win_1 == 1 and true or false)
				, false
				, (win_1 == 2 and true or false)
				, false
				, (win_1 == 0 and true or false)
				)
		elseif season == 3 then
			left_hero_name:setString(g_tr(g_data.general[l3_hero.hero_configId].general_name))
			right_hero_name:setString(g_tr(g_data.general[r3_hero.hero_configId].general_name))
			local win_1 = model.getSeasonWin(1)
			local win_2 = model.getSeasonWin(2)
			widget.lua_setLeftHeadIconAndX(
				g_data.general[l3_hero.hero_configId].general_icon
				, g_data.general[l1_hero.hero_configId].general_icon
				, g_data.general[l2_hero.hero_configId].general_icon
				, (win_1 == 2 and true or false)
				, (win_2 == 2 and true or false)
				, (win_1 == 1 and true or false)
				, (win_2 == 1 and true or false)
				, (win_1 == 0 and true or false)
				, (win_2 == 0 and true or false)
				)
			widget.lua_setRightHeadIconAndX(
				g_data.general[r3_hero.hero_configId].general_icon
				, g_data.general[r1_hero.hero_configId].general_icon
				, g_data.general[r2_hero.hero_configId].general_icon
				, (win_1 == 1 and true or false)
				, (win_2 == 1 and true or false)
				, (win_1 == 2 and true or false)
				, (win_2 == 2 and true or false)
				, (win_1 == 0 and true or false)
				, (win_2 == 0 and true or false)
				)
		end
	end
	
	function widget.lua_onRoundStateChange(round)
		roundText:setString(tostring(round))
		
		local left_hero = model.getCurrentLeftHeroData()
		local right_hero = model.getCurrentRightHeroData()
		
		left_hp_text:setString(string.format("%d/%d", left_hero.hero_current_hp, left_hero.hero_max_hp))
		_setHpPercent(left_LoadingBar_top, left_LoadingBar_bottom, left_hero.hero_current_hp / left_hero.hero_max_hp * 100, false)
		
		right_hp_text:setString(string.format("%d/%d", right_hero.hero_current_hp, right_hero.hero_max_hp))
		_setHpPercent(right_LoadingBar_top, right_LoadingBar_bottom, right_hero.hero_current_hp / right_hero.hero_max_hp * 100, false)
	end
	
	function widget.lua_onOperateStateChange(operateState)
		
	end
	
	return widget
end


function createCancel()
	local widget = g_gameTools.LoadCocosUI("Arena_Button.csb", 9)

	local scale_node = widget:getChildByName("scale_node")
	
	local closeButton = scale_node:getChildByName("Button_1")
	
	closeButton:getChildByName("Text_1"):setString(g_tr("tournament_cancel"))
	
	function onCancelButton(sender)
		require("game.uilayer.tournament.tournament").onCancelButton()
	end
	closeButton:addClickEventListener(onCancelButton)
	
	function widget.lua_onSeasonStateChange(season)
		
	end
	
	function widget.lua_onRoundStateChange(round)
		
	end
	
	function widget.lua_onOperateStateChange(operateState)
		if operateState == stateModelMD.m_OperateState.attack then
			widget:setVisible(true)
		elseif operateState == stateModelMD.m_OperateState.skill then
			widget:setVisible(true)
		else
			widget:setVisible(false)
		end
	end
	
	return widget
end


function createSkill()
	local widget = g_gameTools.LoadCocosUI("Arena_Skill.csb", 9)

	local scale_node = widget:getChildByName("scale_node")
	
	local skillButton = scale_node:getChildByName("Image_jineg")
	
	function onSkillButton(sender)
		require("game.uilayer.tournament.tournament").onSkillButton()
	end
	skillButton:addClickEventListener(onSkillButton)
	
	local skillButtonSide = scale_node:getChildByName("Image_touming") --Image_touming Image_2
	local size = skillButtonSide:getContentSize()
	local skillButton_armature , skillButton_animation = g_gameTools.LoadCocosAni("anime/Effect_LeiTaiSaiJiNengTuBiaoXunHuan/Effect_LeiTaiSaiJiNengTuBiaoXunHuan.ExportJson", "Effect_LeiTaiSaiJiNengTuBiaoXunHuan", nil, nil)
	schedulerModelMD.resetNodeSchedulerAndActionManage(skillButton_armature)
	skillButton_armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
	skillButtonSide:addChild(skillButton_armature)
	skillButton_armature:setVisible(false)
	currentCanUse = false
	
	local timeText = scale_node:getChildByName("Text_1")
	
	local timeLoadingBar = scale_node:getChildByName("LoadingBar_3")
	
	
	function widget.lua_onSeasonStateChange(season)
		local manual_hero = require("game.uilayer.tournament.tournament").getInitManualHeroData(season)
		if manual_hero.skill_configId ~= 0 then
			widget:setVisible(true)
            --有转换技能英雄替换他的技能图标
            local icon_path = g_data.sprite[g_data.general[manual_hero.hero_configId].skill_icon].path
            if manual_hero.change_skill_hero then
                icon_path = g_data.sprite[g_data.general[manual_hero.change_skill_hero.hero_configId].skill_icon].path
            end
			skillButton:loadTexture(icon_path)
		else
			widget:setVisible(false)
		end
	end
	
	function widget.lua_onRoundStateChange(round)
		local manual_hero = require("game.uilayer.tournament.tournament").getCurrentManualHeroData()
		if manual_hero.skill_configId ~= 0 then
			timeLoadingBar:setPercent(100 - math.min(math.max(manual_hero.hero_current_sp / manual_hero.hero_max_sp * 100, 0), 100))
			local s = manual_hero.hero_current_sp - manual_hero.skill_need_sp
			if s >= 0 then
				--可以释放
				currentCanUse = true
				timeText:setVisible(false)
			else
				--不可释放
				currentCanUse = false
				timeText:setVisible(true)
				timeText:setString(tostring(math.ceil(s / manual_hero.hero_restore_sp * -1)))
			end
		end
	end
	
	function widget.lua_onOperateStateChange(operateState)
		local manual_hero = require("game.uilayer.tournament.tournament").getCurrentManualHeroData()
		if manual_hero and manual_hero.skill_configId ~= 0 then
			if operateState == stateModelMD.m_OperateState.attack then
				widget:setVisible(true)
				if currentCanUse then
					skillButton_armature:setVisible(true)
					skillButton_animation:play("Animation2", -1, 1)
				else
					skillButton_armature:setVisible(false)
				end
			elseif operateState == stateModelMD.m_OperateState.skill then
				widget:setVisible(true)
				skillButton_armature:setVisible(true)
				skillButton_animation:play("Animation1", -1, 1)
			else
				widget:setVisible(false)
				skillButton_armature:setVisible(false)
			end
		end
	end
	
	
	return widget
end


function createComplete()
	local widget = g_gameTools.LoadCocosUI("Arena_Skill_Left.csb", 9)

	local scale_node = widget:getChildByName("scale_node")
	
	local completButton = scale_node:getChildByName("Button_1")
	
	completButton:getChildByName("Text_1"):setString(g_tr("tournament_complete"))
	
	function onCompletButton(sender)
		require("game.uilayer.tournament.tournament").onCompletButton()
	end
	completButton:addClickEventListener(onCompletButton)
	
	local size = completButton:getContentSize()
	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_AnNiuDianJiTiShi/Effect_AnNiuDianJiTiShi.ExportJson", "Effect_AnNiuDianJiTiShi", nil, nil)
	schedulerModelMD.resetNodeSchedulerAndActionManage(armature)
	armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
	completButton:addChild(armature)
	armature:setVisible(true)
	animation:play("Animation1", -1, 1)
	
	function widget.lua_setShowGuild(isOpen)
		armature:setVisible(isOpen)
	end
	
	function widget.lua_isShowGuild()
		return armature:isVisible()
	end
	
	function widget.lua_onSeasonStateChange(season)
		
	end
	
	function widget.lua_onRoundStateChange(round)
		
	end
	
	function widget.lua_onOperateStateChange(operateState)
		if operateState == stateModelMD.m_OperateState.attack then
			widget:setVisible(true)
		elseif operateState == stateModelMD.m_OperateState.skill then
			widget:setVisible(true)
		else
			widget:setVisible(false)
		end
	end
	
	return widget
end


function createAutomatic()
	local widget = g_gameTools.LoadCocosUI("Arena_Skill_automatic.csb", 7)

	local scale_node = widget:getChildByName("scale_node")
	
	scale_node:getChildByName("Text_1"):setString(g_tr("tournament_automatic"))
	
	local checkBox = scale_node:getChildByName("CheckBox_1")
	checkBox:setSelected(g_saveCache.tournament_auto == 1 and true or false)	
	
	local function selectedEvent(sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			g_airBox.show(g_tr("tournament_automatic_open"))
			g_saveCache.tournament_auto = 1
		elseif eventType == ccui.CheckBoxEventType.unselected then
			g_airBox.show(g_tr("tournament_automatic_close"))
			g_saveCache.tournament_auto = 0
		end
	end
	checkBox:addEventListenerCheckBox(selectedEvent) 
	
	function widget.lua_setAutomatic(v)
		if v then
			g_saveCache.tournament_auto = 1
		else
			g_saveCache.tournament_auto = 0
		end
		checkBox:setSelected(v)	
	end
	
	function widget.lua_Automatic()
		return checkBox:isSelected()
	end
	
	return widget
end


function createJump()
	local widget = g_gameTools.LoadCocosUI("Arena_Skill_Skip.csb", 9)

	local scale_node = widget:getChildByName("scale_node")
	
	local jumpButton = scale_node:getChildByName("Button_1")
	
	jumpButton:getChildByName("Text_1"):setString(g_tr("tournament_jump"))
	
	function onJumpButton(sender)
		require("game.uilayer.tournament.tournament_backplay").onJumpButton()
	end
	jumpButton:addClickEventListener(onJumpButton)
	
	function widget.lua_onSeasonStateChange(season)
		
	end
	
	function widget.lua_onRoundStateChange(round)
		
	end
	
	return widget
end


function createChangeSpeed(scale)
	local widget = g_gameTools.LoadCocosUI("Arena_Skill_double.csb", 9)

	local scale_node = widget:getChildByName("scale_node")
	
	local changeSpeedButton = scale_node:getChildByName("Button_1")
	
	changeSpeedButton:getChildByName("Text_1"):setString(g_tr("tournament_speed", {speed = scale}))
	
	function onChangeSpeedButton(sender)
		local current = require("game.uilayer.tournament.tournament_backplay").onChangeSpeedButton()
		changeSpeedButton:getChildByName("Text_1"):setString(g_tr("tournament_speed", {speed = current}))
	end
	changeSpeedButton:addClickEventListener(onChangeSpeedButton)
	
	function widget.lua_onSeasonStateChange(season)
		
	end
	
	function widget.lua_onRoundStateChange(round)
		
	end
	
	return widget
end



return surfaceModel