local worldMapLayer_uiLayer = {}
setmetatable(worldMapLayer_uiLayer,{__index = _G})
setfenv(1,worldMapLayer_uiLayer)

local changeMapScene = require("game.maplayer.changeMapScene")

local RequestTimeMD = require "game.mapcitybattle.worldMapLayer_requestTime"
local helperMd = require "game.mapcitybattle.worldMapLayer_helper"

deadTipStr = g_tr("guild_war_fh_desc_org")
local m_isAutoFuhuoing = false
local m_isRound1ChangeRoundViewHaveShow = false

local m_Root = nil
local m_RightDownInfo = nil
local m_PlayerInfo = nil
local m_tipInfo = nil
local m_updateView = {}
local m_guideInfo  = nil

local m_topCenterView = nil
local m_LastShow_bigTileIndex = nil
local m_localBuildData = nil
local m_toushicheControl = nil
local m_passiveSkillListView = nil

local tipContinueKillList = {}
local tipSelfKillList = {}

local m_battleId = 0

tipStrConfig = {}
for key, var in pairs(g_data.war_info) do
	tipStrConfig[var.type_name] = var
end

local function clearGlobal()
	m_Root = nil
	m_RightDownInfo = nil
	m_PlayerInfo = nil
	m_tipInfo = nil
	m_updateView = {}
	m_guideInfo  = nil
	m_topCenterView = nil
	m_LastShow_bigTileIndex = nil
	m_localBuildData = nil
	m_toushicheControl = nil
	m_passiveSkillListView = nil
	m_isAutoFuhuoing = false
	m_isRound1ChangeRoundViewHaveShow = false
	tipContinueKillList = {}
	tipSelfKillList = {}
end

local active_skill_target_data = nil
local _init_active_skill_target = function()
	if active_skill_target_data == nil then
		active_skill_target_data = {}
		for key, var in pairs(g_data.active_skill_target) do
			local m_key = var.scene_id..var.battle_skill_id..var.side..var.section_id..""
			active_skill_target_data[m_key] = var
		end
	end
end

--scene_id 1联盟战 2城门战 3 城内站
--battle_skill_id 城战技能id
--side 1攻击方 2防守方
--section_id 当前自己所在区域
local _get_active_skill_target_data = function(scene_id,battle_skill_id,side,section_id)
	local key = scene_id..battle_skill_id..side..section_id..""
	return active_skill_target_data[key]
end

_init_active_skill_target()

--判断某个主动技能当前是否可用
--返回结果：canUse,targetArea,activeSkillTargetConfig
--canUse：是否能使用
--targetArea：作用的区域， -1表示在准备阶段 0表示没有或者不需要返回可用区域，1-5代表将要最终区域
--主动计作用目标的配置信息
local function _checkActiveSkillCanUse(skillId)
	local canUse = false
	local targetArea = 0
	local activeSkillTargetConfig = nil
	
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
	
		--是否是在准备阶段
		local isPrepareStatus = false
		local battleStatus = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().getRealStatus()
		if battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_ATTACK_READY
		or battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_DEFEND_READY 
		then
			isPrepareStatus = true--not g_cityBattle_cross_ui_dataHelper.requirePlayer().hasSelectedOnMap() --并且没有选择过复活点
		end		
		
		if isPrepareStatus then
			targetArea = -1
			return canUse,targetArea,activeSkillTargetConfig
		end		
		
		if g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().is_in_map ~= 1 then
			return canUse,targetArea,activeSkillTargetConfig
		end
		
		local area = tonumber(g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().area)
		if area == nil or area == 0 then
			return canUse,targetArea,activeSkillTargetConfig
		end
		
		local skillConfig = g_data.battle_skill[skillId]
		local areaStr = ""
		local targetName = ""

		if skillId == 10098 then --业火冲天
			local scene_id,battle_skill_id,side,section_id
			scene_id = 1
			battle_skill_id = skillId
			side = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().IsAttacker() and 1 or 2
			section_id = area
			activeSkillTargetConfig = _get_active_skill_target_data(scene_id,battle_skill_id,side,section_id)
			assert(activeSkillTargetConfig)
			canUse = activeSkillTargetConfig.client_target_area > 0
			targetArea = activeSkillTargetConfig.client_target_area

		elseif skillId == 10105 then --破胆怒吼
			local scene_id,battle_skill_id,side,section_id
			scene_id = 1
			battle_skill_id = skillId
			side = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().IsAttacker() and 1 or 2
			section_id = area
			activeSkillTargetConfig = _get_active_skill_target_data(scene_id,battle_skill_id,side,section_id)
			assert(activeSkillTargetConfig)
			canUse = activeSkillTargetConfig.client_target_area > 0
			targetArea = activeSkillTargetConfig.client_target_area
		elseif skillId == 10111 then --无双乱舞
			canUse = true
		elseif skillId == 10110 then --五雷轰顶
			canUse = true
		else
			canUse = true
		end
	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
		--是否是在准备阶段
		local isPrepareStatus = false
		local battleStatus = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().getRealStatus()
		if battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_READY_SEIGE
		or battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_READY_MELEE 
		then
			isPrepareStatus = true--not g_cityBattle_cross_ui_dataHelper.requirePlayer().hasSelectedOnMap() --并且没有选择过复活点
		end		
		
		if isPrepareStatus then
			targetArea = -1
			return canUse,targetArea,activeSkillTargetConfig
		end		
		
		if g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().is_in_map ~= 1 then
			return canUse,targetArea,activeSkillTargetConfig
		end
		
		local area = tonumber(g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().section)
		if area == nil or area == 0 then
			return canUse,targetArea,activeSkillTargetConfig
		end
		
		local skillConfig = g_data.battle_skill[skillId]
		local areaStr = ""
		local targetName = ""
		
		if skillId == 10098 then --业火冲天
			local scene_id,battle_skill_id,side,section_id
			scene_id = g_cityBattleInfoData.IsDoorMap() and 2 or 3
			battle_skill_id = skillId
			side = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().IsAttacker() and 1 or 2
			section_id = area
			activeSkillTargetConfig = _get_active_skill_target_data(scene_id,battle_skill_id,side,section_id)
			assert(activeSkillTargetConfig)
			canUse = activeSkillTargetConfig.client_target_area > 0
			targetArea = activeSkillTargetConfig.client_target_area
		elseif skillId == 10105 then --破胆怒吼
			local scene_id,battle_skill_id,side,section_id
			scene_id = g_cityBattleInfoData.IsDoorMap() and 2 or 3
			battle_skill_id = skillId
			side = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().IsAttacker() and 1 or 2
			section_id = area
			print("~~~~~scene_id,battle_skill_id,side,section_id:",scene_id,battle_skill_id,side,section_id)
			activeSkillTargetConfig = _get_active_skill_target_data(scene_id,battle_skill_id,side,section_id)
			assert(activeSkillTargetConfig)
			canUse = activeSkillTargetConfig.client_target_area > 0
			targetArea = activeSkillTargetConfig.client_target_area
		else
			canUse = true
		end
	end
	
	return canUse,targetArea,activeSkillTargetConfig
end

--右上角信息出现时的效果
local function _runTipOutAction(item)
	if item == nil then
		return
	end
	
	item:setCascadeOpacityEnabled(true)
	item:setOpacity(60)
	item:getChildByName("Panel_1"):setPositionX(200)
	local move = cc.MoveTo:create(0.35,cc.p(0,item:getChildByName("Panel_1"):getPositionY()))
  item:getChildByName("Panel_1"):runAction(move)
	local action = cc.Sequence:create( cc.FadeTo:create(0.5,255) , cc.DelayTime:create(10.5) , cc.FadeTo:create(1.0,0) , cc.RemoveSelf:create() ) 
	item:runAction(action)
	
end

local isTipContinueKilling = false

local function _showContinueKill()
	if isTipContinueKilling then
		return
	end
	
	local showData = tipContinueKillList[1] --'type'=>'continuekill', 'nick'=>xxx, 'avatar'=>xxx, 'num'=>nnn
	if showData then
		isTipContinueKilling = true
		local con = cc.Node:create()
		local uilayer = cc.CSLoader:createNode("guildwar_panel5.csb")
		local str = g_tr("guild_war_kill_keep",{nick = showData.nick})
		
		local orgLabel = uilayer:getChildByName("scale_node"):getChildByName("Text_1")
		
		local orgPosX = orgLabel:getPositionX()
		local orgWidth = orgLabel:getContentSize().width
		local richText = g_gameTools.createRichText(orgLabel,str)
		local size = richText:getRealSize()
		richText:setPositionX(orgPosX + orgWidth/2 - size.width/2)
	
		local avatarId = tonumber(showData.avatar)
		local resConfig = g_data.res_head[avatarId]
		uilayer:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Image_renw"):loadTexture(g_resManager.getResPath(resConfig.bust_icon))
		
		local container = cc.Node:create()
		container:setCascadeOpacityEnabled(true)
		local str = g_gameTools.SectionToChinese(tonumber(showData.num)).."连破" --这里特殊需求，不要用多语言 直接用简体中文
		if showData.isFirstBlood then
			str = "首破" --这里特殊需求，不要用多语言 直接用简体中文
		end
		local txt = cc.Label:createWithBMFont("cocostudio_res/fnt/chn_kill_num.fnt", str, cc.TEXT_ALIGNMENT_CENTER)
		txt:setAnchorPoint(cc.p(0.5, 0.5))
		container:addChild(txt)
		
		local panelCon = uilayer:getChildByName("scale_node"):getChildByName("Panel_dw")
		local size = panelCon:getContentSize()
		panelCon:addChild(container)
		container:setPosition(cc.p(size.width/2,size.height/2))
		
		con:addChild(uilayer)
		g_sceneManager.addNodeForTopEffect(con)
		local posx = g_display.cx + g_display.visibleSize.width /2 - 395
		local posy = g_display.cy
		con:setPosition(cc.p(posx,posy))
		
		con:setCascadeOpacityEnabled(true)
	  con:setOpacity(0)
	  local function rootLayerEventHandler(eventType)
			if eventType == "enter" then
			elseif eventType == "exit" then
				table.remove(tipContinueKillList,1)
				isTipContinueKilling = false
				_showContinueKill()
	    end
	  end
	  con:registerScriptHandler(rootLayerEventHandler)
	  local action = cc.Sequence:create( cc.FadeTo:create(0.25,255) , cc.DelayTime:create(3) , cc.FadeTo:create(0.15,0) , cc.RemoveSelf:create() ) 
	  con:runAction(action)
		
	end
end

function isNeedShowOtherArmy()
	local hideArmyBtn = m_PlayerInfo:getChildByName("scale_node"):getChildByName("Panel_dj")
	local checkBox = hideArmyBtn:getChildByName("CheckBox_1")
	return not checkBox:isSelected()
end

--显示连杀动画
function tipContinueKill(data)
	
	if data then --'type'=>'continuekill', 'nick'=>xxx, 'avatar'=>xxx, 'num'=>nnn
		if data.isFirstBlood or (data.nick ~= g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().nick and tonumber(data.num)%5 == 0) then --提示连杀的规则
			table.insert(tipContinueKillList,data)
			_showContinueKill()
		end
	end
	
end

local isTipSelfKilling = false
local function _showSelfKill()
	if isTipSelfKilling then
		return
	end
	
	local showData = tipSelfKillList[1] --'type'=>'continuekill', 'nick'=>xxx, 'avatar'=>xxx, 'num'=>nnn
	if showData then
		isTipSelfKilling = true
		local con = cc.Node:create()
		local animPath = "anime/Effect_KuaFuPoText/Effect_KuaFuPoText.ExportJson"
		local armature , animation = nil,nil
		local function onMovementEventCallFunc(armature , eventType , name)
			if ccs.MovementEventType.complete == eventType then
				con:removeFromParent()
			end
		end
	
		armature , animation = g_gameTools.LoadCocosAni(
		animPath
		, "Effect_KuaFuPoText"
		, onMovementEventCallFunc
		--, onFrameEventCallFunc
		)
		
		local container = cc.Node:create()
		local txt = cc.Label:createWithBMFont("cocostudio_res/fnt/big_kill_num.fnt", showData.num.."", cc.TEXT_ALIGNMENT_CENTER)
		txt:setAnchorPoint(cc.p(0.5, 0.5))
		container:addChild(txt)
		armature:getBone("Number"):addDisplay(container,0)
		
		con:addChild(armature)
		animation:play("Animation1")
		g_sceneManager.addNodeForTopEffect(con)
		local posx = g_display.cx --+ g_display.visibleSize.width /2 - 50
		local posy = g_display.cy
		con:setPosition(cc.p(posx,posy))
		
	  local function rootLayerEventHandler(eventType)
			if eventType == "enter" then
			elseif eventType == "exit" then
				table.remove(tipSelfKillList,1)
				isTipSelfKilling = false
				_showSelfKill()
	    end
	  end
	  con:registerScriptHandler(rootLayerEventHandler)
	  
	end
end

function tipSelfKill(data)
	if data then --'type'=>'continuekill', 'nick'=>xxx, 'avatar'=>xxx, 'num'=>nnn
		if data.nick == g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().nick then
			table.insert(tipSelfKillList,data)
			_showSelfKill()
		end
	end
end

local m_CurrentShowList = {}
local function pushList(widget)
	local h = widget:getContentSize().height + 10
	for k , v in pairs(m_CurrentShowList) do
		v:runAction(cc.MoveBy:create(0.13,cc.p(0.0,h)))
	end
	m_CurrentShowList[ (#m_CurrentShowList) + 1 ] = widget
end

local function popList(widget)
	for k , v in pairs(m_CurrentShowList) do
		if v == widget then
			table.remove(m_CurrentShowList,k)
			break
		end
	end
end

--在屏幕中央提示一条消息
function tipMsg(str) 
	
	local con = cc.Node:create()
	local item = cc.CSLoader:createNode("guildwar_panel2_list_msg.csb")
	local rich = g_gameTools.createRichText(item:getChildByName("Panel_1"):getChildByName("Text_1"),str)
	local size = rich:getRealSize()
	local sizeL = cc.size(size.width + 30,size.height)
	item:setContentSize(sizeL)
	--rich:setAnchorPoint(cc.p(0,0))
	--rich:setPosition(cc.p(rich:getPositionX(),size.height))
	item:getChildByName("Panel_1"):getChildByName("Image_1"):setContentSize(sizeL)
	item:getChildByName("Panel_1"):setPositionY(size.height)
	con:addChild(item)
	con:setContentSize(sizeL)
	local pos = cc.p(g_display.center.x - sizeL.width/2 ,g_display.center.y + 100)
	con:setPosition(pos)
	
	con:setScaleY(0.1)
	local function rootLayerEventHandler(eventType)
		if eventType == "enter" then
			pushList(con)
		elseif eventType == "exit" then
			popList(con)
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
    end
  end
  con:registerScriptHandler(rootLayerEventHandler)
	con:runAction( cc.Sequence:create( cc.ScaleTo:create(0.13,1.0) , cc.DelayTime:create(8.5) , cc.ScaleTo:create(0.13,1.0,0.1,1.0) , cc.RemoveSelf:create() ) )
	g_sceneManager.addNodeForTopMsgBox(con)
end

function create()

	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
		 if eventType == "enter" then
				--schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateQueue, 1.0 , false)
		 elseif eventType == "exit" then
--				for k , v in ipairs(schedulers) do
--					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
--				end
			elseif eventType == "enterTransitionFinish" then
			elseif eventType == "exitTransitionStart" then
			elseif eventType == "cleanup" then
				if(rootLayer == m_Root)then
					clearGlobal()
				end
			end
	end
	rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	m_PlayerInfo = g_gameTools.LoadCocosUI("guildwar_01.csb",1)
	rootLayer:addChild(m_PlayerInfo)
	
	local hideArmyBtn = m_PlayerInfo:getChildByName("scale_node"):getChildByName("Panel_dj")
	m_PlayerInfo:getChildByName("scale_node"):getChildByName("Panel_dj"):getChildByName("Text_2"):setString(g_tr("citybttle_area_army_show"))
	local checkBox = hideArmyBtn:getChildByName("CheckBox_1")
	checkBox:setSelected(false)
	hideArmyBtn:addClickEventListener(function(sender)
		checkBox:setSelected(not checkBox:isSelected())
		require "game.mapcitybattle.worldMapLayer_bigMap".setOthersArmyShow(not checkBox:isSelected())
	end)
	
	m_passiveSkillListView = m_PlayerInfo:getChildByName("scale_node"):getChildByName("ListView_1")
	m_passiveSkillListView:setScrollBarEnabled(false)
	
	m_PlayerInfo:getChildByName("scale_node"):getChildByName("Text_ysz1"):setString("")
	
	m_PlayerInfo:getChildByName("scale_node"):getChildByName("Image_3"):setTouchEnabled(true)
	m_PlayerInfo:getChildByName("scale_node"):getChildByName("Image_3"):addClickEventListener(function()
		local layer = require("game.uilayer.citybattle_map_ui.GuildWarSettingsLayer"):create()
		g_sceneManager.addNodeForUI(layer)
	end)
	
	m_tipInfo = g_gameTools.LoadCocosUI("guildwar_panel2.csb",3)
	rootLayer:addChild(m_tipInfo)
	m_tipInfo:getChildByName("Panel_1"):setCascadeOpacityEnabled(true)
	m_tipInfo:getChildByName("Panel_1"):setOpacity(0)

	local fhBtn = m_tipInfo:getChildByName("scale_node"):getChildByName("Button_1")
	fhBtn:getChildByName("Text_3"):setString(g_tr("guild_war_guide_fh_txt"))
	fhBtn:setVisible(false)
	fhBtn:addClickEventListener(function()
		local layer = require("game.uilayer.guildwar.GuildWarResurgenceLayer"):create(deadTipStr)
		g_sceneManager.addNodeForUI(layer)
	end)
	
	local animPath = "anime/Effect_LiJiFuHuoAnNiu/Effect_LiJiFuHuoAnNiu.ExportJson"
	local armature , animation = g_gameTools.LoadCocosAni(
	animPath
	, "Effect_LiJiFuHuoAnNiu"
	, function()
	
	end
	--, onFrameEventCallFunc
	)
	fhBtn:addChild(armature)
	armature:setPosition(cc.p(fhBtn:getContentSize().width/2,fhBtn:getContentSize().height/2))
	animation:play("Animation1")
	
	local qcBtn = m_tipInfo:getChildByName("scale_node"):getChildByName("Button_2")
	qcBtn:getChildByName("Text_3"):setString(g_tr("guild_war_canmove"))
	qcBtn:setVisible(false)
	qcBtn:addClickEventListener(function()
			require("game.uilayer.citybattle_map_ui.GuildWarFuHuoDianLayer").show(true)
	end)
	
	local listView = m_tipInfo:getChildByName("scale_node"):getChildByName("ListView_1")
	listView:setScrollBarEnabled(false)
	listView:setTouchEnabled(false)
	listView:setItemsMargin(5)
	g_gameCommon.addEventHandler(g_Consts.CustomEvent.CityBattleMapEvent, function(_,data)
		
--		hammerTaken
--		hammerBroken
--		crossbowAttackHammer
--		ladderTaken
--		ladderBroken
--		crossbowAttackLadder
--		ladderDone
--		catapultTaken
--		catapultBroken
--		catapultAttack
--		crossbowTaken
--		playerDead
--		doorBroken
--		hammerAttackDoor
--		playerAttackDoor

		
		--['type'=>'firstblood', 'fromNick'=>xxx, 'toNick'=>yyy]
		--['type'=>'continuekill', 'nick'=>xxx, 'avatar'=>xxx, 'num'=>nnn]

		

--	
--玩家城池	
--	X玩家进入复活状态	playerDead, ['nick'=>xxx]
--	
--城门	
--	敌军击破了城门X！	doorBroken，[, 'x'=>xxx, 'y'=>xxx]
--	受到的伤害（攻城锤） hammerAttackDoor，['reduce'=>xxx, 'rest'=>xxx, 'from_x'=>xxx, 'from_y'=>xxx, 'to_x'=>xxx, 'to_x'=>xxx]
--	受到的伤害（玩家）  playerAttackDoor，['nick'=>xxx, 'reduce'=>xxx, 'rest'=>xxx, 'x'=>xxx, 'y'=>xxx]
--	
	  print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~get notice")
	  dump(data)
	  
	  
		local mapStatus = changeMapScene.getCurrentMapStatus()
		if not (mapStatus == changeMapScene.m_MapEnum.citybattle) then
			return
		end
	  
	  if data.Data.type == "firstblood" then
	  	local m_data = {
	  	--['type'=>'firstblood', 'fromNick'=>xxx, 'toNick'=>yyy]
		  --['type'=>'continuekill', 'nick'=>xxx, 'avatar'=>xxx, 'num'=>nnn]
			  type = "continuekill",
			  nick = data.Data.fromNick,
			  avatar = data.Data.fromAvatar,
			  num = 1,
			  isFirstBlood = true
		  }
		  
			tipContinueKill(m_data)
		end
		
		if data.Data.type == "continuekill" then
			tipContinueKill(data.Data)
			tipSelfKill(data.Data)
		end
	  
		if data.Data.type == "firstblood" or data.Data.type == "continuekill" then
			return
		end 
		
		if tipStrConfig[data.Data.type] == nil then
			return
		end 
		
		local currentMapType = require("game.mapcitybattle.worldMapLayer_bigMap").getCurrentMapType()
		if g_cityBattleInfoData.GetCurrentMapType() ~= currentMapType then
			return
		end
		
		print("tip Start~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		
		local item = cc.CSLoader:createNode("guildwar_panel2_list1.csb")
		local str = ""
		local strNotice = ""
		local isFromSelf = false
		
		--占领攻城锤
		if data.Data.type == "hammerTaken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.nick,map_id = buildName})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.nick,map_id = buildName})
			end
			
		end
		
		--攻城锤被破坏
		if data.Data.type == "hammerBroken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{map_id = buildName})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{map_id = buildName})
			end
			
		end
		
		--床弩攻击攻城锤
		if data.Data.type == "crossbowAttackHammer" then
			
			local fromX = tonumber(data.Data.from_x)
			local fromY = tonumber(data.Data.from_y)
			local fromSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(fromX,fromY)
			local fromMapConfigData = g_data.map_element[fromSpBuildData.cross_map_element_id]
			local fromBuildName = g_tr(fromMapConfigData.name)
			
			local targetX = tonumber(data.Data.to_x)
			local targetY = tonumber(data.Data.to_y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{from_map_id = fromBuildName,to_map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{from_map_id = fromBuildName,to_map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			
			end
			
		end
		
		--云梯被占领
		if data.Data.type == "ladderTaken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.nick,map_id = buildName})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.nick,map_id = buildName})
			end
			
			
		end
		
		--云梯被破坏
		if data.Data.type == "ladderBroken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{map_id = buildName})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{map_id = buildName})
			end
			
		end
		
		--床弩攻击云梯
		if data.Data.type == "crossbowAttackLadder" then
			
			local fromX = tonumber(data.Data.from_x)
			local fromY = tonumber(data.Data.from_y)
			local fromSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(fromX,fromY)
			local fromMapConfigData = g_data.map_element[fromSpBuildData.cross_map_element_id]
			local fromBuildName = g_tr(fromMapConfigData.name)
			
			local targetX = tonumber(data.Data.to_x)
			local targetY = tonumber(data.Data.to_y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{from_map_id = fromBuildName,to_map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{from_map_id = fromBuildName,to_map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			
			end
			
		end
		
		--云梯搭建完成
		if data.Data.type == "ladderDone" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{map_id = buildName})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{map_id = buildName})
			
			end
			
		end
		
		--占领投石车
		if data.Data.type == "catapultTaken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.nick,map_id = buildName})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.nick,map_id = buildName})
			
			end
			
		end
		
		--投石车被击破
		if data.Data.type == "catapultBroken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.nick,map_id = buildName})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.nick,map_id = buildName})
			
			end
			
		end
		
		--投石车攻击
		if data.Data.type == "catapultAttack" or data.Data.type == "catapultCounterAttack" then
			
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{fromNick = data.Data.fromNick,toNick =  data.Data.toNick,reduce = data.Data.reduce})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{fromNick = data.Data.fromNick,toNick =  data.Data.toNick,reduce = data.Data.reduce})
			
			end
			
		end
		
		--占领床弩
		if data.Data.type == "crossbowTaken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.nick,map_id = buildName})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.nick,map_id = buildName})
			end
			
			
		end
		
		--玩家死完
		if data.Data.type == "playerDead" then
			
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{fromNick = data.Data.from_nick,toNick =  data.Data.to_nick})
			
			if data.Data.to_nick == g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().nick then
				deadTipStr = g_tr("guild_war_fh_desc",{nick = data.Data.from_nick})
				--local layer = require("game.uilayer.guildwar.GuildWarResurgenceLayer"):create(deadTipStr)
				--g_sceneManager.addNodeForUI(layer)
				tipMsg(deadTipStr)
			else
				if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
					strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{fromNick = data.Data.from_nick,toNick =  data.Data.to_nick})
				
				end
			end
			
		end
		
		--城门被击破
		if data.Data.type == "doorBroken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{map_id = buildName})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{map_id = buildName})
			
			end
			
		end
		
		--攻城锤攻击城门
		if data.Data.type == "hammerAttackDoor" then
			
			local fromX = tonumber(data.Data.from_x)
			local fromY = tonumber(data.Data.from_y)
			local fromSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(fromX,fromY)
			local fromMapConfigData = g_data.map_element[fromSpBuildData.cross_map_element_id]
			local fromBuildName = g_tr(fromMapConfigData.name)
			
			local targetX = tonumber(data.Data.to_x)
			local targetY = tonumber(data.Data.to_y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{from_map_id = fromBuildName,to_map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{from_map_id = fromBuildName,to_map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			
			end
			
		end
		
		--玩家攻击城门
		if data.Data.type == "playerAttackDoor" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.nick,map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.nick,map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			
			end
		end
		
		--大本营被击破
		if data.Data.type == "baseBroken" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.nick,map_id = buildName})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.nick,map_id = buildName})
			end
		end
		
		--攻击大本营
		if data.Data.type == "baseAttack" then
			
			local targetX = tonumber(data.Data.x)
			local targetY = tonumber(data.Data.y)
--			local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
--			local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local mapStatus = changeMapScene.getCurrentMapStatus()
			local mapConfigData = nil
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
			else
				mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
			end
			local buildName = g_tr(mapConfigData.name)
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.nick,map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.nick,map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			end
		end
		
		if data.Data.type == "skill_10110" then --技能：五雷轰顶
			local fromNick = data.Data.fromNick
			
			isFromSelf = (data.Data.fromNick == g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().nick)
			
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{fromNick = fromNick,second = data.Data.second})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{fromNick = fromNick,second = data.Data.second})
			end
			
			local targetPlayerIds = data.Data.toPlayerIds or {}
			local myPlayerId = tonumber(g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().player_id)
			for key, playerId in pairs(targetPlayerIds) do
				if tonumber(playerId) == myPlayerId then
					local str = g_tr(tipStrConfig[data.Data.type].info_desc2,{fromNick = fromNick,second = data.Data.second})
					tipMsg(str)
					break
				end
			end
				
		end
		
		if data.Data.type == "skill_10098" then --技能：业火冲天
			
			local targetX = tonumber(data.Data.to_x)
			local targetY = tonumber(data.Data.to_y)
			local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
			local buildName = ""
			local mapConfigData = nil
			if targetSpBuildData then
				local mapStatus = changeMapScene.getCurrentMapStatus()
				if mapStatus == changeMapScene.m_MapEnum.guildwar then
					mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
				else
					mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
				end
				buildName = g_tr(mapConfigData.name)
			else
				buildName = data.Data.toNick or ""
				mapConfigData = g_data.map_element[1501] --固定是玩家
			end
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{nick = data.Data.fromNick,map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{nick = data.Data.fromNick,map_id = buildName,reduce = data.Data.reduce,rest = data.Data.rest})
			end
			
			isFromSelf = (data.Data.fromNick == g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().nick)
			
			local playEffect = function()
				local num = data.Data.reduce or 0
				require "game.mapcitybattle.worldMapLayer_bigMap".play_fire_attack_effect(num,mapConfigData,cc.p(targetX,targetY))
			end
			
			if isFromSelf then
				require "game.mapcitybattle.changeMapScene".gotoWorld_BigTileIndex(cc.p(targetX,targetY),playEffect)
			else
				playEffect()
			end
			
		end
		
		if data.Data.type == "skill_10105" then --技能：破胆怒吼
			local fromNick = data.Data.fromNick
			
			isFromSelf = (data.Data.fromNick == g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().nick)
			
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{fromNick = fromNick,toArea = data.Data.toArea})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{fromNick = fromNick,toArea = data.Data.toArea})
			end
			
			local targetPlayerIds = data.Data.toPlayerIds or {}
			local myPlayerId = tonumber(g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().player_id)
			for key, playerId in pairs(targetPlayerIds) do
				if tonumber(playerId) == myPlayerId then
					local str = g_tr(tipStrConfig[data.Data.type].info_desc2,{fromNick = fromNick,toArea = data.Data.toArea})
					tipMsg(str)
					break
				end
			end
			
		end
		
		if data.Data.type == "skill_10111" then --技能：无双乱舞
			str = g_tr(tipStrConfig[data.Data.type].info_desc,{fromNick = data.Data.fromNick,toNick =  data.Data.toNick})
			if tipStrConfig[data.Data.type].info_type == 1 or tipStrConfig[data.Data.type].info_type == 2 then
				strNotice = g_tr(tipStrConfig[data.Data.type].info_desc1,{fromNick = data.Data.fromNick,toNick =  data.Data.toNick})
			end
			
			isFromSelf = (data.Data.fromNick == g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().nick)
			
			--仅自己和目标
			if tipStrConfig[data.Data.type].info_type == 2 then
				local selfIsTarget = (data.Data.toNick == g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().nick)
				if isFromSelf then
					tipMsg(strNotice)
				end
				
				if selfIsTarget then
					strNotice = g_tr(tipStrConfig[data.Data.type].info_desc2,{fromNick = data.Data.fromNick,toNick =  data.Data.toNick})
					tipMsg(strNotice)
				end
			end
		end
		
		local configData = tipStrConfig[data.Data.type]
		if configData and configData.info_type == 1 then
			--屏幕中间提示消息
			--上浮消息
			tipMsg(strNotice)
		elseif configData and configData.info_type == 0 then
			--右上角提示消息
			local rich = g_gameTools.createRichText(item:getChildByName("Panel_1"):getChildByName("Text_1"),str)
			local size = rich:getRealSize()
			local sizeL = cc.size(size.width + 13,size.height)
			item:setContentSize(sizeL)
			--rich:setAnchorPoint(cc.p(0,0))
			--rich:setPosition(cc.p(rich:getPositionX(),size.height))
			item:getChildByName("Panel_1"):getChildByName("Image_1"):setContentSize(sizeL)
			item:getChildByName("Panel_1"):setPositionY(size.height)
			listView:insertCustomItem(item,0)
			_runTipOutAction(item)
			listView:doLayout()
			
			g_autoCallback.addCocosList(function()
				listView:scrollToTop(0.5,true)
			end,0.25)
		elseif configData and configData.info_type == 2 then
			--上浮消息 --改用短连接
--			if isFromSelf then
--				tipMsg(strNotice)
--			end
		end
		
	end,listView)

	m_toushicheControl = g_gameTools.LoadCocosUI("guildwar_panel1.csb",6)
	rootLayer:addChild(m_toushicheControl)

	m_guideInfo = g_gameTools.LoadCocosUI("guildwar_panel4.csb",7)
	rootLayer:addChild(m_guideInfo)
	m_guideInfo:getChildByName("scale_node"):getChildByName("Image_10"):getChildByName("Text_17"):setString(g_tr("guild_war_guide_title"))
	local areaStatuslistView = m_guideInfo:getChildByName("scale_node"):getChildByName("ListView_1")
	areaStatuslistView:setScrollBarEnabled(false)
	areaStatuslistView:setTouchEnabled(false)
	
	--坐标信息
	m_topCenterView = g_gameTools.LoadCocosUI("guildwar_03.csb",2)
	rootLayer:addChild(m_topCenterView)
	
	--搜索坐标
	m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_1"):addClickEventListener(function()
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local jumpMapLayer = require("game.uilayer.map.jumpMapLayer")
		g_sceneManager.addNodeForUI( jumpMapLayer:create() )
	end)
	
	m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Text_dq"):setString(g_tr("guild_war_area_title"))
	
	m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Image_9"):setTouchEnabled(false)
	m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Image_8"):setTouchEnabled(true)
	m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Image_8"):addClickEventListener(function()
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
		bigMap.closeSmallMenu()
		bigMap.closeInputMenu()
		bigMap.changeBigTileIndex_Manual(g_cityBattle_cross_ui_dataHelper.requirePlayer().GetPosition(),true)
	end)

	m_RightDownInfo = g_gameTools.LoadCocosUI("guildwar_02.csb",9)
	rootLayer:addChild(m_RightDownInfo)
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Button_1"):getChildByName("Text_17"):setString(g_tr("mainMailBtn"))
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Button_1"):addClickEventListener(function()
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		g_sceneManager.addNodeForUI(require("game.uilayer.mail.MailBaseLayer").new())	 
	end)
	
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Button_3"):getChildByName("Text_4"):setString(g_tr("guild_war_army"))
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Button_3"):addClickEventListener(function()
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		g_sceneManager.addNodeForUI(require("game.uilayer.drill.CityBattleDrillView").new())
	end)
	
	--使用主动技能
	local function useActiveSkill(serverData)
		if serverData == nil then
			return
		end
		
		if tonumber(g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().is_in_map) == 0 then
			--如果玩家城池当前不在地图上（死亡等情况）
			tipMsg(g_tr("guild_war_use_skill_not_in_map"))
			return
		end
		
		local canUse,targetArea,activeSkillTargetConfig = _checkActiveSkillCanUse(tonumber(serverData.skill_id))
		if canUse then
			--打开主动技使用界面
			local layer = require("game.uilayer.guildwar.GuildWarUseSkillLayer"):create(serverData,targetArea,activeSkillTargetConfig)
			g_sceneManager.addNodeForUI(layer)
		else
			if targetArea == -1 then
				--处于准备阶段
				tipMsg(g_tr("guild_war_use_skill_no_start"))
			else
				--不能使用主动技
				tipMsg(g_tr("guild_war_use_skill_no_target"))
			end
		end
		
	end
	
	--主动技1
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn1"):setTouchEnabled(true)
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn1"):addClickEventListener(function()
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local serverData = m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn1").serverData
		useActiveSkill(serverData)
	end)
	
	--主动技2
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn2"):setTouchEnabled(true)
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn2"):addClickEventListener(function()
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local serverData = m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn2").serverData
		useActiveSkill(serverData)
	end)
	
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Button_4"):getChildByName("Text_4"):setString(g_tr("guild_war_zhanluetu"))
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Button_4"):addClickEventListener(function()
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		require("game.uilayer.citybattle_map_ui.GuildWarFuHuoDianLayer").show()
	end)
	
	local homeBtn = m_RightDownInfo:getChildByName("scale_node"):getChildByName("Button_dituanniu1")
	homeBtn:getChildByName("Text_16"):setString(g_tr("guild_war_gohome"))
	homeBtn:addClickEventListener(function()
			--g_airBox.show("聯盟戰期間不允許退出當前地圖")
			local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
			bigMap.closeSmallMenu()
			bigMap.closeInputMenu()
			bigMap.changeBigTileIndex_Manual(g_cityBattle_cross_ui_dataHelper.requirePlayer().GetPosition(),true)
		
			--require("game.maplayer.changeMapScene").changeToHome()
	end)
	
	local btnFengHuoTai = m_RightDownInfo:getChildByName("scale_node"):getChildByName("Image_TheFlames")
	btnFengHuoTai:getChildByName("Text_2"):setString(g_tr("menu_lookout"))
	btnFengHuoTai:setVisible(false)
	
	local tipBox = m_RightDownInfo:getChildByName("scale_node"):getChildByName("Image_3")
	tipBox:setVisible(false)
	tipBox:getChildByName("Text_3"):setString(g_tr("guild_war_no_solider_tip"))
	
	rootLayer:setVisible(false)
	return rootLayer
end

--更新箭头方向
function updateShow_arrow(currentBigTileIndex , homeBigTileIndex , currentPositionCenter)
	if m_Root == nil then
		return
	end

	m_tipInfo:getChildByName("Panel_1"):stopAllActions()
	m_tipInfo:getChildByName("Panel_1"):setOpacity(255)
	local action = cc.Sequence:create(cc.DelayTime:create(0.5) , cc.FadeTo:create(1.0,0)) 
	m_tipInfo:getChildByName("Panel_1"):runAction(action)
	
	local MapHelper = require "game.mapcitybattle.worldMapLayer_helper"
	local pos = MapHelper.out_bigTileIndex_2_position(currentBigTileIndex,m_tipInfo:getChildByName("Panel_1"):getChildByName("Image_4"):getContentSize())
  m_tipInfo:getChildByName("Panel_1"):getChildByName("Image_4"):getChildByName("Image_3"):setPosition(pos)

	local arrowCon = m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_2")
	
	local arrow = arrowCon:getChildByName("Image_9")
	local label = arrowCon:getChildByName("Text_8_0")
	local labelValue = arrowCon:getChildByName("Text_8_1")
	labelValue:setString("0")
	
	local positionCenter = helperMd.bigTileIndex_2_positionCenter(homeBigTileIndex)
	local world_position = require("game.mapcitybattle.worldMapLayer_bigMap").position_2_worldPosition( cc.p(positionCenter.x, positionCenter.y + helperMd.m_SingleSizeHalf.height) )
	local visibleRect = cc.rect(g_display.left, g_display.bottom, g_display.visibleSize.width, g_display.visibleSize.height)
	local playerData = g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData()
	if world_position and cc.rectContainsPoint(visibleRect, world_position) == false and playerData.is_in_map == 1 then
		
		arrow:setVisible(true)
		local distanceVec = cc.p( homeBigTileIndex.x - currentBigTileIndex.x , homeBigTileIndex.y - currentBigTileIndex.y )
		local distance = math.floor( math.sqrt( distanceVec.x * distanceVec.x + distanceVec.y * distanceVec.y ) )
		
		label:setString(g_tr("worldmap_KM"))
		labelValue:setString(""..distance)
		local homePositionCenter = helperMd.bigTileIndex_2_positionCenter( homeBigTileIndex)
		local posDistanceVec = cc.p( homePositionCenter.x - currentPositionCenter.x , homePositionCenter.y - currentPositionCenter.y )
		local angle = cToolsForLua:calc2VecAngle(1,0,posDistanceVec.x,posDistanceVec.y)
		arrow:setRotation( angle * -1 )
	else
		arrow:setVisible(false)
	end
end

--更新坐标显示
function updateShow_bigTileIndex(bigTileIndex)
	if m_Root == nil then
		return
	end
	
	if m_LastShow_bigTileIndex == nil or m_LastShow_bigTileIndex.x ~= bigTileIndex.x or m_LastShow_bigTileIndex.y ~= bigTileIndex.y then
		m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Text_8"):setString(g_tr("guild_war_build_current_pos")..string.format("x:%d y:%d",bigTileIndex.x,bigTileIndex.y))
		m_LastShow_bigTileIndex = cc.p(bigTileIndex.x, bigTileIndex.y)
	end
end

--更新邮件按钮数字
function updateMailTips(mailCounts) 
	if m_Root and m_RightDownInfo then 
		m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_1"):setVisible(mailCounts > 0)
		m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Text_1"):setString(mailCounts.."")
	end 
end

--增加一个界面到更新列表
function addUpdateView(view)
	table.insert(m_updateView,view)
end

function removeUpdateView(view) 
	for key, var in pairs(m_updateView) do
		if view == var then
			m_updateView[key] = nil
			break
		end
	end
end

--被动技能图标
function showPassiveSkillIcon()
	if m_Root == nil then
		return
	end
	
--[id] => Integer (25959)
--[general_id] => Integer (20022)
--[exp] => Integer (0)
--[lv] => Integer (1)
--[star_lv] => Integer (0)
--[weapon_id] => Integer (1008400)
--[armor_id] => Integer (0)
--[horse_id] => Integer (0)
--[zuoji_id] => Integer (0)
--[skill_lv] => Integer (0)
--[build_id] => Integer (0)
--[army_id] => Integer (0)
--[force_rate] => Integer (0)
--[intelligence_rate] => Integer (0)
--[governing_rate] => Integer (0)
--[charm_rate] => Integer (0)
--[political_rate] => Integer (0)
--[stay_start_time] => Integer (0)
--[cross_skill_id_1] => Integer (0)
--[cross_skill_lv_1] => Integer (0)
--[cross_skill_id_2] => Integer (0)
--[cross_skill_lv_2] => Integer (0)
--[cross_skill_id_3] => Integer (0)
--[cross_skill_lv_3] => Integer (0)
--[status] => Integer (0)
	
	m_passiveSkillListView:removeAllChildren()
	local listViewSize = m_passiveSkillListView:getContentSize()
	
	local generalList = g_cityBattle_cross_ui_dataHelper.requireGeneral().GetData()
	
	local sameSkillList = {}
	do --找出相同的技能，值分别相加
		for key, var in pairs(generalList) do
			for i=1, 3 do
				local skillId = tonumber(var["cross_skill_id_"..i])
				if skillId > 0 then
					local skillConfig = g_data.battle_skill[skillId]
					if skillConfig.if_active == 0 and skillConfig.buff_type_exclude == 0 then
						if sameSkillList[skillId] == nil then
							sameSkillList[skillId] = {}
							sameSkillList[skillId].v1 = 0
							sameSkillList[skillId].v2 = 0
						end
					
						local serverData = var
						local currentGeneral = {}
						currentGeneral.cdata = g_GeneralMode.getGeneralByOriginalId(serverData.general_id)
						currentGeneral.ndata = serverData
						local showData = require("game.uilayer.godGeneral.GodGeneralMode"):instance():getBattleSkillFormula(currentGeneral,i)
						if showData then
							sameSkillList[skillId].v1 = sameSkillList[skillId].v1 + showData.v1
							sameSkillList[skillId].v2 = sameSkillList[skillId].v2 + showData.v2
						end
					end
				end
			end
		end
	end
	
	do --显示技能图标
		for skillId, var in pairs(sameSkillList) do
			local skillConfig = g_data.battle_skill[skillId]
			local itemIcon = g_resManager.getRes(skillConfig.skill_res)
			itemIcon:setAnchorPoint(cc.p(0.5,0.5))
			local scale = listViewSize.height/itemIcon:getContentSize().height
			local targetSize = cc.size(itemIcon:getContentSize().width*scale,itemIcon:getContentSize().height*scale)
			local con = ccui.Widget:create()
			con:setContentSize(targetSize)
			itemIcon:setPosition(cc.p(targetSize.width/2,targetSize.height/2))
			itemIcon:setScale(scale)
			con:addChild(itemIcon)
			m_passiveSkillListView:pushBackCustomItem(con)
			
			local rddsc_org = g_tr(skillConfig.skill_description,{ num = var.v1, numnext = "",buff = var.v2,buffnext = ""} )
			g_itemTips.tipStr(con,g_tr(skillConfig.skill_name),rddsc_org)
			
		end
	end

	local crossGuildData = g_cityBattle_cross_ui_dataHelper.requireCrossGuildOrCityBattleCamp().GetData()

	local buffs = {"buff_move_ids","buff_cityattack_ids","buff_buildattack_ids","buff_relocation_ids","buff_enemyreturn_ids"} --如果服务器有增加，这里也需要跟着增加
	for _, mkey in ipairs(buffs) do
		if crossGuildData[mkey] then
			for key, var in pairs(crossGuildData[mkey]) do
				local skillConfig = g_data.battle_skill[tonumber(key)]
				if skillConfig.if_active == 0 and skillConfig.buff_type_exclude ~= 2 then  --buff_type_exclude为2时 不显示技能图标
					local itemIcon = g_resManager.getRes(skillConfig.skill_res)
					itemIcon:setAnchorPoint(cc.p(0.5,0.5))
					local scale = listViewSize.height/itemIcon:getContentSize().height
					local targetSize = cc.size(itemIcon:getContentSize().width*scale,itemIcon:getContentSize().height*scale)
					local con = ccui.Widget:create()
					con:setContentSize(targetSize)
					itemIcon:setPosition(cc.p(targetSize.width/2,targetSize.height/2))
					itemIcon:setScale(scale)
					con:addChild(itemIcon)
					
					m_passiveSkillListView:pushBackCustomItem(con)
					
					local numValue = var
					if skillConfig.num_type == 1 then
						numValue = string.format("%.2f",var * 100)
					else
						numValue = math.floor(numValue)
					end
					
					local rddsc_org = g_tr(skillConfig.skill_description,{ num = numValue, numnext = "",buff = "",buffnext = ""} )
					
					--如果被动技能buff_type_exclude 为1 描述读特殊字段
					if skillConfig.buff_type_exclude == 1 then
						 rddsc_org = g_tr(skillConfig.active_skill_area_desc,{ num = numValue, numnext = "",buff = "",buffnext = ""} )
					end
					
					g_itemTips.tipStr(con,g_tr(skillConfig.skill_name),rddsc_org)
				end
			end
		end
	end
end

--主动技能图标
function showActiveSkillIcon()
	if m_Root == nil then
		return
	end
	
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn1"):setVisible(false)
	m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn2"):setVisible(false)
	
	
	local mapStatus = changeMapScene.getCurrentMapStatus()

	
	--主动技能图标
	local activeSkills = g_cityBattle_cross_ui_dataHelper.requireMasterSkill().GetData()
	for key, var in ipairs(activeSkills) do
		if var.rest_times > 0 then
			local skillConfig = g_data.battle_skill[tonumber(var.skill_id)]
			m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn"..key):getChildByName("Image_jineng2"):loadTexture(g_resManager.getResPath(skillConfig.skill_res))
			m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn"..key):setVisible(true)
			local canUse,targetArea,activeSkillTargetConfig = _checkActiveSkillCanUse(tonumber(var.skill_id))
			if canUse then
				m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn"..key):getChildByName("Image_jineng2"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
			else
				m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn"..key):getChildByName("Image_jineng2"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
			end
			m_RightDownInfo:getChildByName("scale_node"):getChildByName("Panel_jn"..key).serverData = var
		end
	end
end

--更新左上角显示的信息
function updatePlayerInfo() 
	if m_Root and m_PlayerInfo then
		
		local mapStatus = changeMapScene.getCurrentMapStatus()
		if mapStatus == changeMapScene.m_MapEnum.citybattle then
			
			--兵力
			do
				local loadingBar = m_PlayerInfo:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("LoadingBar_1")
				local currentNum,currentMax = g_cityBattle_cross_ui_dataHelper.requireSoldier().GetCurentSoldierNumber()
				local percent = currentNum/currentMax*100
				loadingBar:setPercent(percent)
			end
			
			--城防值
			do
				local loadingBar = m_PlayerInfo:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("LoadingBar_1")
				local percent = g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().wall_durability/g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().wall_durability_max*100
				loadingBar:setPercent(percent)
			end
			
			--元宝显示
			local count = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
			m_PlayerInfo:getChildByName("scale_node"):getChildByName("Text_ysz1"):setString(count.."")
			
			--所在区域
			local str = ""
			local idx = g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData().section
			if type(idx) == "number" then
				str = g_tr("guild_war_area_nowat",{idx = idx})
			end
			
			m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Text_8_0"):setString(str)
			
			do
				for key, var in pairs(m_updateView) do
					if var.updateView then
						var:updateView()
					end
				end
			end
			
		end
		
	end
end

local _timeProgressBar = nil
--右上角迁城/复活cd（城战）
function updateChangeLocation()
	if m_Root == nil then
		return
	end
	
	if _timeProgressBar == nil then
		local con = m_tipInfo:getChildByName("scale_node"):getChildByName("Panel_7"):getChildByName("Panel_8")
		local conSize = con:getContentSize()
		local bg = cc.Sprite:create("cocos/cocostudio_res/huodong/wap_hui1.png")
		con:addChild(bg)
		bg:setPosition(cc.p(conSize.width/2,conSize.height/2))
		
		
		local imgPath = "cocos/cocostudio_res/huodong/wap_hui2.png"
 		local cd = cc.ProgressTimer:create(cc.Sprite:create(imgPath))
    cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    cd:setPosition(cc.p(conSize.width/2,conSize.height/2))
    con:addChild(cd)
    _timeProgressBar = cd
	end
	
	local labelPreTime = m_tipInfo:getChildByName("scale_node"):getChildByName("Panel_7"):getChildByName("Text_sz")
	local finishTime = 0
	
	local fhBtn = m_tipInfo:getChildByName("scale_node"):getChildByName("Button_1")
	fhBtn:setVisible(false)
	
	local qcBtn = m_tipInfo:getChildByName("scale_node"):getChildByName("Button_2")
	qcBtn:setVisible(false)
	
	local labelRealPre = m_tipInfo:getChildByName("scale_node"):getChildByName("Panel_7"):getChildByName("Text_10")
	if g_cityBattlePlayerData.GetData().is_dead == 1 then --死亡状态，等待cd复活
	
			labelRealPre:setString(g_tr("guild_war_revive_cd_tip"))
			
			m_tipInfo:getChildByName("scale_node"):getChildByName("Panel_7"):setVisible(true)
			
			--立即复活功能已经去除
			--fhBtn:setVisible(true)
			
			local deadTimes = g_cityBattlePlayerData.GetData().dead_times
			
			local cdTime = tonumber(g_data.country_basic_setting[51].data) + (tonumber(g_data.country_basic_setting[65].data) * deadTimes)
			if g_cityBattleInfoData.IsAttacker() then
				cdTime = tonumber(g_data.country_basic_setting[63].data) + (tonumber(g_data.country_basic_setting[64].data) * deadTimes)
			end
			
			finishTime = g_cityBattlePlayerData.GetData().dead_time + cdTime + 1
			
			local currentTime = g_clock.getCurServerTime()
			local endTime = finishTime
			local secondsLeft = endTime - currentTime
			
			local timerFinishHandler = function()
					secondsLeft = 0
					labelPreTime:setString(g_tr("guild_war_can_revive"))
					fhBtn:getChildByName("Text_3_0"):setString("0")
					fhBtn:setVisible(false)
					m_tipInfo:getChildByName("scale_node"):getChildByName("Panel_7"):setVisible(false)
					
					if not m_isAutoFuhuoing then
						m_isAutoFuhuoing = true
						local function onRecv(result, msgData)
							m_isAutoFuhuoing = false
				  		g_busyTip.hide_1()
				      if(result==true)then
					       require "game.mapcitybattle.worldMapLayer_bigMap".requestMapAllData_Manual()
					       tipMsg(g_tr("guild_war_fh_success"))
					       local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
								 bigMap.closeSmallMenu()
								 bigMap.closeInputMenu()
								 bigMap.changeBigTileIndex_Manual(g_cityBattlePlayerData.GetPosition(),true)
					    end
					  end
						g_busyTip.show_1()
						if g_cityBattleInfoData.GetCurrentMapType() == 1 then
							g_sgHttp.postData("City_Battle/siegeRevive",{},onRecv,true)
						else
							g_sgHttp.postData("City_Battle/meleeRevive",{},onRecv,true)
						end
						
					end
					
			end
			
			
			local updateTimeStr = function()
				currentTime = g_clock.getCurServerTime()
				local secondsLeft = endTime - currentTime
				if secondsLeft < 0 then
					timerFinishHandler()
				else
					local percent = (cdTime - secondsLeft)/cdTime * 100
					_timeProgressBar:setPercentage(percent)
					labelPreTime:setString(""..secondsLeft)

					local costPrice = tonumber(g_data.country_basic_setting[52].data)
					local costNum = secondsLeft * costPrice / tonumber(g_data.country_basic_setting[51].data)
					fhBtn:getChildByName("Text_3_0"):setString(math.floor(costNum).."")
				end
			end
			
		  if finishTime - g_clock.getCurServerTime() > 0 then
			  updateTimeStr()
			else
				timerFinishHandler()
		  end
	else
			--迁城cd
			
			labelRealPre:setString(g_tr("guild_war_move_cd_tip"))
			m_tipInfo:getChildByName("scale_node"):getChildByName("Panel_7"):setVisible(true)
			deadTipStr = g_tr("guild_war_fh_desc_org")
			
			--labelPreTime:setTextColor(cc.c4b(255,255,255,255))
			qcBtn:setVisible(false)
			
			if g_cityBattle_cross_ui_dataHelper.requireBattleInfo().IsDoorMap() and g_cityBattle_cross_ui_dataHelper.requireBattleInfo().IsAttacker() then 
				--城内战攻击方不显示迁城（cd/按钮）相关的信息
				m_tipInfo:getChildByName("scale_node"):getChildByName("Panel_7"):setVisible(false)
			else
				--buff减少的Cd秒数
				local buff_relocation = g_cityBattleCamp.GetData().buff_relocation or 0
				
				local cdTime = tonumber(g_data.country_basic_setting[54].data) - buff_relocation
				
				finishTime = g_cityBattlePlayerData.GetData().change_location_time + cdTime
	
				local currentTime = g_clock.getCurServerTime()
				local endTime = finishTime
				local secondsLeft = endTime - currentTime
				
				local timerFinishHandler = function()
						secondsLeft = 0
						--labelPreTime:setTextColor(cc.c4b(0,255,0,255))
						labelPreTime:setString(g_tr("guild_war_canmove"))
						qcBtn:setVisible(true)
						m_tipInfo:getChildByName("scale_node"):getChildByName("Panel_7"):setVisible(false)
				end
				
				local updateTimeStr = function()
					currentTime = g_clock.getCurServerTime()
					local secondsLeft = endTime - currentTime
					if secondsLeft < 0 then
						timerFinishHandler()
					else
						local percent = (cdTime - secondsLeft)/cdTime * 100
						_timeProgressBar:setPercentage(percent)
						labelPreTime:setString(""..secondsLeft)
					end
				end
			  
			  if finishTime - g_clock.getCurServerTime() > 0 then
				  updateTimeStr()
				else
					timerFinishHandler()
			  end
		  end
		end

end

--进/出地图
function viewChangeShow()
	if m_Root then
		
		local hideArmyBtn = m_PlayerInfo:getChildByName("scale_node"):getChildByName("Panel_dj") --进显示自己相关部队的勾选按钮
		local mapStatus = changeMapScene.getCurrentMapStatus()
		if  mapStatus == changeMapScene.m_MapEnum.citybattle then
			m_Root:setVisible(true)
			
			if mapStatus == changeMapScene.m_MapEnum.citybattle and require("game.mapcitybattle.worldMapLayer_bigMap").isMapTest == true then
				return
			end
			
			hideArmyBtn:setVisible(true)
			
			--新的一场战斗
			if m_battleId ~= g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().id then
				m_isRound1ChangeRoundViewHaveShow = false
				m_battleId = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().id
			end
			
			
			updatePlayerInfo()
			showPassiveSkillIcon()
			showActiveSkillIcon()
			--updateCityBattleGuide()
			
			--更新圆形头像
			local playerData = g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData()
			local resConfig = g_data.res_head[ playerData.avatar_id ]
			if resConfig == nil then
					playerData.avatar_id = 1
			end
			local iconid = g_data.res_head[ playerData.avatar_id ].head_icon
			local icon = m_PlayerInfo:getChildByName("scale_node"):getChildByName("Image_3")
			icon:removeAllChildren()
			
			local clipper = require("game.uilayer.master.MasterMode").createCircleHead(g_resManager.getResPath(iconid))
			clipper:setPosition( cc.p( icon:getContentSize().width/2,icon:getContentSize().height/2 ) )
			icon:addChild(clipper)
			
			--剩余时间
			m_Root:stopAllActions()
			
--			local preTimeLabel = m_tipInfo:getChildByName("scale_node"):getChildByName("Text_2")
			local preTimeLabel1 = m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_3"):getChildByName("Text_2")
			
			local timeLabel = m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_3"):getChildByName("Text_1")
			local updateTimeStr = function() --每秒更新
				

				updateChangeLocation()
	
				
				local currentTime = g_clock.getCurServerTime()
				local endTime = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().start_time
				
				local preTimeStr = ""
				local preTimeStr1 = ""
				
				local battleStatus = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().status
--				STATUS_READY 	= 0,
--		    STATUS_ATTACK_READY = 1,
--		    STATUS_ATTACK = 2,
--		    STATUS_ATTACK_CLAC = 3,
--		    STATUS_DEFEND_READY = 4,
--		    STATUS_DEFEND = 5,
--		    STATUS_DEFEND_CLAC = 6,
--		    STATUS_FINISH = 7,

--		    STATUS_DEFAULT = 0,
--		    STATUS_READY_SEIGE = 1,
--		    STATUS_SEIGE = 2,
--		    STATUS_CLAC_SEIGE = 3,
--				STATUS_READY_MELEE = 4,
--		    STATUS_MELEE = 5,
--		    STATUS_CLAC_MELEE = 6,
--		    STATUS_FINISH = 7,

				if battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_DEFAULT then
					endTime = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().start_time
					preTimeStr = g_tr("guild_war_status_ready")
					preTimeStr1 = g_tr("guild_war_status_ready1")
				elseif battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_READY_SEIGE 
				or battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_SEIGE then
					if currentTime <= g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().real_start_time then
						preTimeStr = g_tr("guild_war_status_atk_ready")
						preTimeStr1 = g_tr("guild_war_status_atk_ready1")
						endTime = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().real_start_time
					else
						preTimeStr = g_tr("guild_war_status_atk")
						preTimeStr1 = g_tr("guild_war_status_atk1")
						endTime = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().real_start_time + tonumber(g_data.country_basic_setting[12].data) * 60
					end
				elseif battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_READY_MELEE
				or battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_MELEE then
					local changeTime = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().GetData().melee_time

					if currentTime <= changeTime then
						endTime = changeTime
						preTimeStr = g_tr("guild_war_status_def_ready")
						preTimeStr1 = g_tr("guild_war_status_def_ready1")
					else
						endTime = changeTime + tonumber(g_data.country_basic_setting[14].data) * 60
						preTimeStr = g_tr("guild_war_status_def")
						preTimeStr1 = g_tr("guild_war_status_def1")
					end
				end 
				
--				preTimeLabel:setString(preTimeStr)
				preTimeLabel1:setString(preTimeStr1)
				
				local secondsLeft = endTime - currentTime
				if secondsLeft < 0 then
					secondsLeft = 0
					timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft,g_gameTools.ClockType.MINSSCONDS))
				else
					timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft,g_gameTools.ClockType.MINSSCONDS))
					
					if secondsLeft > 2 and secondsLeft < 6 then 
						local realStatus = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().getRealStatus()
						if realStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_READY_SEIGE
						or realStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_READY_MELEE 
						then
							require("game.effectlayer.kingTime").show()
						end
					end
					
				end
				
				if battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_CLAC_SEIGE 
				or battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_CLAC_MELEE
				then
					timeLabel:setString(g_tr("guild_war_clac"))
--				elseif battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_ATTACK_READY
				elseif battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_READY_MELEE
				then
				elseif battleStatus == g_cityBattle_cross_ui_dataHelper.requireBattleInfo().StatusType.STATUS_FINISH then
					m_Root:stopAllActions()
					timeLabel:setString(g_tr("guild_war_finish"))
				end
			end
      
      local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
      local action = cc.RepeatForever:create(seq)
      m_Root:runAction(action)
			
			updateTimeStr()
		else
			m_Root:setVisible(false)
			m_Root:stopAllActions()
			tipContinueKillList = {}
			tipSelfKillList = {}
		end
	end
end

--城门战结束界面
function showRoundChangeView() 
	if m_Root then
		require("game.uilayer.cityBattle.CityDoorReport").Show()
	end
end

--城内战结束界面
function showResultView() 
	if require("game.mapcitybattle.worldMapLayer_bigMap").isMapTest == true then
		return
	end

	if m_Root then
		require("game.uilayer.cityBattle.CityBattleFinish").Show()
	end
end



function fenghuotai_show() 
	if m_Root and m_RightDownInfo then 
		 
		 local mapStatus = changeMapScene.getCurrentMapStatus()
		 if mapStatus == changeMapScene.m_MapEnum.guildwar then
		 		local btnFengHuoTai = m_RightDownInfo:getChildByName("scale_node"):getChildByName("Image_TheFlames")
		 		btnFengHuoTai:setVisible(true)
		 end
	end
end

function fenghuotai_hide() 
	if m_Root and m_RightDownInfo then 
		 
		 local mapStatus = changeMapScene.getCurrentMapStatus()
		 if mapStatus == changeMapScene.m_MapEnum.guildwar then
		 		local btnFengHuoTai = m_RightDownInfo:getChildByName("scale_node"):getChildByName("Image_TheFlames")
		 		btnFengHuoTai:setVisible(false)
		 end
	end
end

function updateLocalBuildData()
	
end



local attackDatas = nil
local defenseDatas = nil

local _initDataFunc = function()
	if attackDatas == nil or defenseDatas == nil then
		attackDatas = {}
		defenseDatas = {}
		for key, var in pairs(g_data.country_recommend_tips) do
			if var.location == 1 then
				table.insert(attackDatas,var)
			elseif var.location == 2 then
				table.insert(defenseDatas,var)
			else
				assert(false,"invaild location type")
			end
		end
		
		local sortFunc = function(a,b)
			return a.priority < b.priority
		end
		table.sort(attackDatas,sortFunc)
		table.sort(defenseDatas,sortFunc)
	end
end

local function updateUI()
	if m_Root == nil then
		return
	end
	local isAtacker = false	
	isAtacker = g_cityBattle_cross_ui_dataHelper.requireBattleInfo().IsAttacker()

	m_PlayerInfo:getChildByName("scale_node"):getChildByName("Image_g1"):setVisible(isAtacker)
	m_PlayerInfo:getChildByName("scale_node"):getChildByName("Image_g2"):setVisible(not isAtacker)
	
	updateArmyTip()
				
end

local m_neiChengScoreRichTxt = nil
function checkAndShowResult()
	if m_Root == nil then
		return
	end

	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus ~= changeMapScene.m_MapEnum.citybattle then
		return
	end
	
	--显示城内战积分
	local isDoorMap = g_cityBattleInfoData.IsDoorMap()
	m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_4"):setVisible(not isDoorMap)
	if not isDoorMap then
		local battleInfo = g_cityBattleInfoData.GetData()
		local str = g_tr("citybttle_camp_scores",{num1 = math.floor(tonumber(battleInfo.attack_score)),num2 = math.floor(tonumber(battleInfo.defend_score))})
		local orgLabel = m_topCenterView:getChildByName("scale_node"):getChildByName("Panel_4"):getChildByName("Text_8")
		if m_neiChengScoreRichTxt == nil then
			m_neiChengScoreRichTxt = g_gameTools.createRichText(orgLabel,str)
		end
		local orgPosX = orgLabel:getPositionX()
		local orgWidth = orgLabel:getContentSize().width
		m_neiChengScoreRichTxt:setRichText(str)
		local size = m_neiChengScoreRichTxt:getRealSize()
		m_neiChengScoreRichTxt:setPositionX(orgPosX + orgWidth/2 - size.width/2)
	end
	
	--是否有资格进入城内战
	if not isDoorMap then
		if not g_cityBattleInfoData.CanEnterMeleeRound() then
			showRoundChangeView()
			return
		end
	end
	
	--更新缩略图
	local mapImgPath = "cocos/cocostudio_res/huodong/wap_guildwar_small_map2.png"
	if isDoorMap then
		mapImgPath = "cocos/cocostudio_res/huodong/wap_guildwar_small_map1.png"
	end
	m_tipInfo:getChildByName("Panel_1"):getChildByName("Image_1"):loadTexture(mapImgPath)
	
	local battleStatus = g_cityBattleInfoData.GetData().status
--				STATUS_READY 	= 0,
--		    STATUS_ATTACK_READY = 1,
--		    STATUS_ATTACK = 2,
--		    STATUS_ATTACK_CLAC = 3,
--		    STATUS_DEFEND_READY = 4,
--		    STATUS_DEFEND = 5,
--		    STATUS_DEFEND_CLAC = 6,
--		    STATUS_FINISH = 7,

--    
--    STATUS_DEFAULT = 0,
--    STATUS_READY_SEIGE = 1,
--    STATUS_SEIGE = 2,
--    STATUS_CLAC_SEIGE = 3,
--		STATUS_READY_MELEE = 4,
--    STATUS_MELEE = 5,
--    STATUS_CLAC_MELEE = 6,
--    STATUS_FINISH = 7,
	if battleStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_SEIGE 
	then
		if not m_isRound1ChangeRoundViewHaveShow then
			m_isRound1ChangeRoundViewHaveShow = true
			showRoundChangeView()
		end
--				elseif battleStatus == g_cityBattleInfoData.StatusType.STATUS_READY_SEIGE
	elseif battleStatus == g_cityBattleInfoData.StatusType.STATUS_READY_MELEE
	then
		if not m_isRound1ChangeRoundViewHaveShow then
			m_isRound1ChangeRoundViewHaveShow = true
			showRoundChangeView()
		end
	elseif battleStatus == g_cityBattleInfoData.StatusType.STATUS_FINISH
	--or battleStatus == g_cityBattleInfoData.StatusType.STATUS_DEFEND_CLAC --这个状态不再弹出结算界面
	then
		showResultView()
	else
		local currentMapType = require("game.mapcitybattle.worldMapLayer_bigMap").getCurrentMapType()
		if g_cityBattleInfoData.GetCurrentMapType() ~= currentMapType then
			if not m_isRound1ChangeRoundViewHaveShow then
				m_isRound1ChangeRoundViewHaveShow = true
				showRoundChangeView()
			end
		end
	end
end

--更新城内战各区域占领状态
function updateSecionList()
	if m_Root == nil then
		return
	end
	
	local listView = m_guideInfo:getChildByName("scale_node"):getChildByName("ListView_1")
			
	if g_cityBattleInfoData.IsDoorMap() then
		listView:setVisible(false)
		return
	else
		listView:setVisible(true)
	end
	
	listView:removeAllChildren()
	
	local myCampId = g_cityBattlePlayerData.GetData().camp_id
	for i=1, 5 do
		local color = cc.c4b(246,43,48,255)
		local item = cc.CSLoader:createNode("guildwar_panel4_liast1.csb")
		item:getChildByName("Text_1_0"):setString(g_tr("citybttle_area_idx",{num = i}))
		
		local str = ""
		local campId = require("game.mapcitybattle.worldMapLayer_bigMap").getOccupationCampBySecionId(i)
		if campId == 0 then
			color = cc.c4b(255,216,0,255)
			str = g_tr("citybttle_area_empty")
		else
			if myCampId == campId then
				color = cc.c4b(92,171,247,255)
				str = g_tr("citybttle_area_self")
			else
				color = cc.c4b(246,43,48,255)
				str = g_tr("citybttle_area_target")
			end
		end
		item:getChildByName("Text_1_0_0"):setTextColor(color)
		item:getChildByName("Text_1_0_0"):setString(str)
		listView:pushBackCustomItem(item)
	end
end

--require("game.mapcitybattle.worldMapLayer_uiLayer").updateArmyTip()
--更新军团按钮的提示气泡
function updateArmyTip()
	if m_Root == nil or m_RightDownInfo == nil then
		return
	end
	
		--军团有没有兵
	local tipBox = m_RightDownInfo:getChildByName("scale_node"):getChildByName("Image_3")
	tipBox:setVisible(g_cityBattleArmyUnit.GeneralWithSoldier())

end

function onMapUpdate(msgData)
--	g_gameCommon.dispatchEvent(g_Consts.CustomEvent.CityBattleMapEvent, {type = "cross",Data = {
--		type = "test_1asdasdfaasdff",
--		
--	}}) 
--	
--	g_gameCommon.dispatchEvent(g_Consts.CustomEvent.CityBattleMapEvent, {type = "cross",Data = {
--		type = "test_2阿射點發阿斯頓發射點發啊第三方 ",
--		
--	}}) 
--	
--	g_gameCommon.dispatchEvent(g_Consts.CustomEvent.CityBattleMapEvent, {type = "cross",Data = {
--		type = "test_3阿薩德法師打發撒的發生的法師打發是的發生的發生的發生打發adfsdf545adsfas",
--		
--	}}) 
	
	
	print("onMapUpdate--begin")
	
--for test
--	--'type'=>'continuekill', 'nick'=>xxx, 'avatar'=>xxx, 'num'=>nnn
--	tipContinueKill({type =  "continuekill",num = 5,nick = "七个字",avatar = 1})
--	tipContinueKill({type =  "continuekill",num = 15,nick = "名字最多七个字",avatar = 2})
--	tipContinueKill({type =  "continuekill",num = 25,nick = "名字最多七个字",avatar = 3})
--	
--
--	tipSelfKill({type =  "continuekill",num = 5,nick = "nick113",avatar = 3})
--	tipSelfKill({type =  "continuekill",num = 15,nick = "nick113",avatar = 3})
--	tipSelfKill({type =  "continuekill",num = 25,nick = "nick113",avatar = 3})
	
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		
		if require("game.mapguildwar.worldMapLayer_bigMap").isMapTest == true then
			return
		end
	
		require("game.mapguildwar.guildWarEnterEffect").playBattleRondAnimation()
		updateGuide()
	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
		if require("game.mapcitybattle.worldMapLayer_bigMap").isMapTest == true then
			return
		end
	
		--require("game.mapcitybattle.mapEnterEffect").playBattleRondAnimation()
		updateGuide()
		updateSecionList()

	end
	
	updateTouShiCheControl(msgData)
	updateUI()
	showActiveSkillIcon()
	
	print("onMapUpdate--end")
end

function getServerPreName(guidId)
	guidId = tostring(guidId)
	return "S"..string.sub(guidId,1,string.len(guidId)-6).." "
end

function updateTouShiCheControl(msgData)
	if m_Root == nil or m_toushicheControl == nil or msgData == nil then
		return
	end
	
	m_toushicheControl:setVisible(false)
	
	m_toushicheControl:getChildByName("scale_node"):getChildByName("Text_1"):setString(g_tr("guild_war_tsc_target"))
	m_toushicheControl:getChildByName("scale_node"):getChildByName("Text_1_0"):setString("")
	m_toushicheControl:getChildByName("scale_node"):getChildByName("Text_1_0_0"):setString("")
	
	if msgData.catapult then
		
		local listView = m_toushicheControl:getChildByName("scale_node"):getChildByName("ListView_1")
		listView:setScrollBarEnabled(false)
		listView:removeAllChildren()
		m_toushicheControl:stopAllActions()
		if msgData.catapult.target then
			m_toushicheControl:setVisible(true)
			if table.nums(msgData.catapult.target) > 0 then

				local buttonList = {}
				
				--local canAttackTime = msgData.catapult.attack_time + tonumber(g_data.warfare_service_config[9].data)
				local canAttackTime = msgData.catapult.attack_time + msgData.catapult.attack_cd --投石车攻击cd改为服务器发放
				
				local currentTime = g_clock.getCurServerTime()
				
				local function updateTimeStr()
					currentTime = g_clock.getCurServerTime()
					if currentTime > canAttackTime then
						for key, var in pairs(buttonList) do
							var:setEnabled(true)
						end
						m_toushicheControl:getChildByName("scale_node"):getChildByName("Text_1_0"):setString(g_tr("guild_war_tsc_status_atk"))
					else
						m_toushicheControl:getChildByName("scale_node"):getChildByName("Text_1_0"):setString(g_tr("guild_war_tsc_status_cd")..math.max(canAttackTime - currentTime,0)..g_tr("second"))
					end
				end
				
				local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
	      local action = cc.RepeatForever:create(seq)
	      m_toushicheControl:runAction(action)
	      updateTimeStr()
				
				
				local mapStatus = changeMapScene.getCurrentMapStatus()
						
				for key, var in pairs(msgData.catapult.target) do
					local item = cc.CSLoader:createNode("guildwar_panel1_list1.csb")
					table.insert(buttonList,item:getChildByName("Button_1"))
					
					item:getChildByName("Image_2"):setTouchEnabled(true)
					item:getChildByName("Image_2"):addClickEventListener(function()
						require "game.mapcitybattle.changeMapScene".gotoWorld_BigTileIndex(cc.p(tonumber(var.x),tonumber(var.y)))
						
					end)
					
					local countryName = ""
					if var.camp_id and tonumber(var.camp_id) > 0 then
						countryName = "("..g_tr(g_data.country_camp_list[tonumber(var.camp_id)].short_name)..")"
					end
					
					item:getChildByName("Text_1"):setString(countryName..var.nick)
					item:getChildByName("Text_2"):setString(g_tr("guild_war_tsc_target_hp"))
					item:getChildByName("Text_3"):setString(var.wall_durability.."")
					item:getChildByName("Button_1"):getChildByName("Text_1_0"):setString(g_tr("guild_war_tsc_target_atk"))
					item:getChildByName("Button_1"):addClickEventListener(function()
						
						
				    local function gotoSuccessHandler()
			    		local function onRecv(result, msgData)
				    		g_busyTip.hide_1()
				        if(result==true)then
						       
						    end
						  end
						  g_busyTip.show_1()
					    g_sgHttp.postData("City_Battle/useCatapult",{x = tonumber(var.x),y = tonumber(var.y)},onRecv,true)
					    RequestTimeMD.CanNotRequestSecondsWithin(2.5, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
				    end 

				    require "game.mapcitybattle.changeMapScene".gotoWorld_BigTileIndex(cc.p(tonumber(var.x),tonumber(var.y)),gotoSuccessHandler)

					end)
					item:getChildByName("Button_1"):setEnabled(currentTime > canAttackTime)
					listView:pushBackCustomItem(item)
				end
			else
				m_toushicheControl:getChildByName("scale_node"):getChildByName("Text_1_0_0"):setString(g_tr("guild_war_tsc_target_empty"))
			end
		end
	else
		m_toushicheControl:setVisible(false)
		m_toushicheControl:stopAllActions()
	end
	
end

local _btnRegisted = false

local _guildContainer = nil

local _lastGuideList = {}

local _checkConditions = function(data)
	
	if require("game.mapcitybattle.worldMapLayer_bigMap").isMapTest == true then
		return false
	end
	
	local campId = g_cityBattlePlayerData.GetData().camp_id
	
	local isVaildCamp = false
	
	if campId == data.camp or data.camp == 0 then
		isVaildCamp = true 
	end
	
	local conditions = data.open_type
	
	local isMatch = true
	for _, open_type in ipairs(conditions) do
		if open_type == 1 then --	1	城门战
			isMatch = (g_cityBattleInfoData.IsDoorMap() and isVaildCamp)
		elseif open_type == 2 then --	2	城内战
			isMatch = ((not g_cityBattleInfoData.IsDoorMap()) and isVaildCamp)
		end
		
		if isMatch == false then
			break
		end
	end
	return isMatch
end

function updateGuide()
	
	if m_Root and m_guideInfo then 
		_initDataFunc()
	
		local currentDatas = nil
		if g_cityBattleInfoData.IsAttacker() then
			currentDatas = attackDatas
		else
			currentDatas = defenseDatas
		end
		
		--主线
		local mainMatchedList = {}
		do
			local matchedList = {}
			local a_mainTask = nil
			local b_mainTask = nil
			
			for key, var in ipairs(currentDatas) do

				if var.task_type == 1 then
					if _checkConditions(var) then
						
						if a_mainTask == nil then
							if var.path_type == 1 then
								a_mainTask = var
								table.insert(matchedList,var)
							end
						end
						
						if b_mainTask == nil then
							if var.path_type == 2 then
								b_mainTask = var
								table.insert(matchedList,var)
							end
						end
						
					end
					
				end
				
				if a_mainTask and b_mainTask then
					break
				end
				
--				if #matchedList == 2 then
--					break
--				end
			end
			mainMatchedList = matchedList
		end
		
		--支线
		local sideMatchedList = {}
		do
			local matchedList = {}
			for key, var in ipairs(currentDatas) do
				if var.task_type == 2 then
					if _checkConditions(var) then
						table.insert(matchedList,var)
					end
				end
				
			end
			sideMatchedList = matchedList
		end
		
		local buttonListPanle = {
			m_guideInfo:getChildByName("scale_node"):getChildByName("Button_2"),
			m_guideInfo:getChildByName("scale_node"):getChildByName("Button_1"),
			m_guideInfo:getChildByName("scale_node"):getChildByName("Button_2_0"),
			m_guideInfo:getChildByName("scale_node"):getChildByName("Button_1_0"),
		}
			
		if _guildContainer == nil then
			_guildContainer = cc.Node:create()
			m_guideInfo:getChildByName("scale_node"):addChild(_guildContainer)

			for key, var in ipairs(buttonListPanle) do
				var:setVisible(false)
			end
			
		end
		

		local finalList = {}
		for key, mainData in ipairs(mainMatchedList) do
			table.insert(finalList,mainData)
			for _, sideData in ipairs(sideMatchedList) do
				if sideData.to_target == mainData.id then
					table.insert(finalList,sideData)
					break
				end
			end
		end
		
--		print("~~~~~~~~~~~~~~~~~~~~~~",finalList)
--		dump(finalList)
		
		do --check is have new guide
			local changed = false
			for key, var in pairs(finalList) do
				if _lastGuideList[var.id] == nil then
					changed = true
					break
				end
			end
			
			if not changed then
				changed = table.nums(finalList) ~= table.nums(_lastGuideList)
			end
			
			if not changed then
				--没有变化 直接return
				return
			end
		end
		
		_guildContainer:removeAllChildren()
		
		local buttonList = {}
		
		local createGuideItem = function(data)
			local item = nil 
			if data.task_type == 1 then
				item = m_guideInfo:getChildByName("scale_node"):getChildByName("Button_1"):clone()
			elseif data.task_type == 2 then
				item = m_guideInfo:getChildByName("scale_node"):getChildByName("Button_2"):clone()
			end
			
			if item then
				item:setVisible(true)
				item:getChildByName("Text_1"):enableOutline(cc.c4b(0, 0, 0,255),1)
				item:getChildByName("Text_1"):setString(g_tr(data.desc))
				_guildContainer:addChild(item)
				item.data = data
				table.insert(buttonList,item)
			end
		end
		
		--显示列表
		for key, var in pairs(finalList) do
			createGuideItem(var)
		end
		print("guide changed ~~~~~~~~~~~~~~~~~~~~~~~~~")
		
		do --播放动画
			for key, var in pairs(buttonList) do
				if var.data.task_type == 1 then
				
					local function onMovementEventCallFunc(armature , eventType , name)
						if ccs.MovementEventType.complete == eventType then
							armature:removeFromParent()
						end
					end
				
					local animPath = "anime/Effect_ZhuXianRenWuZiTiQieHuan/Effect_ZhuXianRenWuZiTiQieHuan.ExportJson"
					local armature , animation = g_gameTools.LoadCocosAni(
					animPath
					, "Effect_ZhuXianRenWuZiTiQieHuan"
					, onMovementEventCallFunc
					--, onFrameEventCallFunc
					)
					
					var:addChild(armature)
					animation:play("Animation1")
					
					local size = var:getContentSize()
					armature:setPosition(cc.p(size.width/2,size.height/2))
				end
			end
		end
		
		do
			_lastGuideList = {}
			for key, var in pairs(finalList) do
				_lastGuideList[var.id] = var
			end
		end
		
		
		do --显示
			
			
			local btnDw = m_guideInfo:getChildByName("scale_node"):getChildByName("Button_2")
		
			local startY = btnDw:getPositionY()
			local startX = btnDw:getPositionX()
			
			local idx = 1
			for i=#finalList, 1, -1 do
				local btn = buttonList[idx]
				btn:setVisible(true)
				btn:setPosition(cc.p(startX,startY + (btn:getContentSize().height + 19)*(i - 1)))
				idx = idx + 1
			end
			
			for key, var in ipairs(buttonList) do
				
				--var:setPosition(cc.p(startX,startY + (var:getContentSize().height + 19)*(key - 1)))
				
				var:addClickEventListener(function(sender)
					local data = sender.data
					print("id:",data.id)
					if data.skip_type == 1 then
--							data.skip_show[1] = 37
--							data.skip_show[2] = 61
--						
							require "game.mapcitybattle.changeMapScene".gotoWorld_BigTileIndex(cc.p(data.skip_show[1],data.skip_show[2]),function()
							local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
							local originBigTileIndex = cc.p(data.skip_show[1],data.skip_show[2])
							local serverData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getSpBuildDataBy_xy(originBigTileIndex.x,originBigTileIndex.y)
							local configData = g_data.map_element[tonumber(serverData.map_element_id)]
							bigMap.play_arrow(serverData, configData, originBigTileIndex)
						end)
					elseif data.skip_type == 2 then
						g_sceneManager.addNodeForUI(require("game.uilayer.citybattle_map_ui.GuildWarSpBuildList"):create(data.skip_show[1],data.skip_show[2]))
					elseif data.skip_type == 3 then
						local layer = require("game.uilayer.citybattle_map_ui.GuildWarFuHuoDianLayer"):create()
						g_sceneManager.addNodeForUI(layer)
						layer:tipArea(data.skip_show)
					elseif data.skip_type == 4 then
						g_sceneManager.addNodeForUI(require("game.uilayer.drill.CityBattleDrillView").new())
					elseif data.skip_type == 5 then
							require "game.mapcitybattle.changeMapScene".gotoWorld_BigTileIndex(cc.p(data.skip_show[1],data.skip_show[2]),function()
							local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
							local originBigTileIndex = cc.p(data.skip_show[1],data.skip_show[2])
							local configData = g_data.map_element[30801]
							bigMap.play_area_guide(nil, configData, originBigTileIndex)
						end)
					end
				end)
			end
			
				--标题定位
			local titleImg = m_guideInfo:getChildByName("scale_node"):getChildByName("Image_10")
			titleImg:setVisible(false)
			if #finalList > 0 then
				titleImg:setVisible(true)
			  local posY = buttonList[1]:getPositionY()
				local size = btnDw:getContentSize()
				titleImg:setPositionY(posY +  size.height + 10)
			end
			
			local areaStatuslistView = m_guideInfo:getChildByName("scale_node"):getChildByName("ListView_1")
			areaStatuslistView:setPositionY(titleImg:getPositionY() + 20)

			
--			local idx = 1
--			for i=#finalList, 1, -1 do
--				buttonList[idx]:setVisible(true)
--				buttonList[idx]:getChildByName("Text_1"):setString(g_tr(finalList[i].desc))
--				buttonList[idx].data = finalList[i]
--				idx = idx + 1
--			end

		end
	end
end


return worldMapLayer_uiLayer