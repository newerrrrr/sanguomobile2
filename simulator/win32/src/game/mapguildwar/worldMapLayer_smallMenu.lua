local worldMapLayer_smallMenu = {}
setmetatable(worldMapLayer_smallMenu,{__index = _G})
setfenv(1,worldMapLayer_smallMenu)

local HelperMD = require "game.mapguildwar.worldMapLayer_helper"
local QueueHelperMD = require "game.mapguildwar.worldMapLayer_queueHelper"

local c_IndexArray = {
	[1] = {
		[1] = 1,
	},
	[2] = {
		[1] = 6,
		[2] = 7,
	},
	[3] = {
		[1] = 1,
		[2] = 8,
		[3] = 9,
	},
	[4] = {
		[1] = 2,
		[2] = 6,
		[3] = 3,
		[4] = 7,
	},
	[5] = {
		[1] = 1,
		[2] = 4,
		[3] = 8,
		[4] = 9,
		[5] = 5,
	},
}


local c_tip_effect_tag = 99554736


local function _getResType(map_element_origin_id)
	if map_element_origin_id == HelperMD.m_MapOriginType.world_gold then
		return g_Consts.AllCurrencyType.Gold
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_food then
		return g_Consts.AllCurrencyType.Food
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_wood then
		return g_Consts.AllCurrencyType.Wood
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_stone then
		return g_Consts.AllCurrencyType.Stone
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_iron then
		return g_Consts.AllCurrencyType.Iron
	end
end


--不用每次取
local m_MyPlayerData = nil


--是否属于自己
local function isMySelf(buildServerData)
	return buildServerData.player_id ~= 0 and buildServerData.player_id == m_MyPlayerData.player_id
end


--是否属于自己联盟
local function isSelfGuild(buildServerData)
	return buildServerData.guild_id ~= 0 and buildServerData.guild_id == g_guildWarPlayerData.getGuildId()
end


--是否建造中
local function isConstruction(buildServerData)
	return buildServerData.status == HelperMD.m_MapBuildStatus.build
end


--耐久度是否不满
local function isNotFullOfDurability(buildServerData)
	return buildServerData.durability < buildServerData.max_durability
end


--是否有任何队列正在这个建筑里做queueType类型的事情
local function isHaveQueueDoing(buildServerData,queueType)
	local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
		if buildServerData.id == v.to_map_id then
			if v.type == queueType then
				return v
			end
		end
	end
	return nil
end


--是否有自己队列正在这个建筑里做queueType类型的事情
local function isHaveSelfQueueDoing(buildServerData,queueType)
	local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
		if buildServerData.id == v.to_map_id then
			if v.player_id == m_MyPlayerData.player_id and v.type == queueType then
				return v
			end
		end
	end
	return nil
end


--是否有自己联盟成员(不包括自己)正在这个建筑里做queueType类型的事情
local function isHaveSelfGuildQueueDoing(buildServerData,queueType)
	if g_guildWarPlayerData.getGuildId() ~= 0 then
		local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
		local currentQueueDatas = bigMap.getCurrentQueueDatas()
		for k , v in pairs(currentQueueDatas.Queue) do
			assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
			if buildServerData.id == v.to_map_id then
				if v.player_id ~= m_MyPlayerData.player_id and v.guild_id == g_guildWarPlayerData.getGuildId() and v.type == queueType then
					return v
				end
			end
		end
	end
	return nil
end


--是否有非自己以及非自己联盟队列正在这个建筑里做queueType类型的事情
local function isHaveOtherQueueDoing(buildServerData,queueType)
	local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
		if buildServerData.id == v.to_map_id then
			if v.player_id ~= m_MyPlayerData.player_id and (v.guild_id == 0 or v.guild_id ~= g_guildWarPlayerData.getGuildId())	and v.type == queueType then
				return v
			end
		end
	end
	return nil
end


--建筑菜单
function create_with_buildServerData(buildServerData , tipMenuId)
	
	local bigMap = require "game.mapguildwar.worldMapLayer_bigMap"
	
	m_MyPlayerData = g_guildWarPlayerData.GetData()
	
	local widget = cc.CSLoader:createNode("worldMap_01.csb")
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition( HelperMD.buildServerData_2_buildCenterPosition(buildServerData) )
	widget:getChildByName("Panel_1"):setTouchEnabled(false)
	
	local function widgetEventHandler(eventType)
		if eventType == "enter" then
			if buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.guild_tower 
			or buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche 
			then
				local top_effect_node = bigMap.getBuildTopEffectNode(buildServerData)
				if top_effect_node and top_effect_node.lua_playRange then
					top_effect_node.lua_playRange()
				end
			end
			g_guideManager.execute()
		elseif eventType == "exit" then
			if buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.guild_tower
			or buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche 
			then
				local top_effect_node = bigMap.getBuildTopEffectNode(buildServerData)
				if top_effect_node and top_effect_node.lua_hideRange then
					top_effect_node.lua_hideRange()
				end
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
		end
	end
	widget:registerScriptHandler(widgetEventHandler)
	
	local map_element_origin_id = tonumber(buildServerData.map_element_origin_id)
	
	--最终需要的key
	local menu_Key = 1
	
	if map_element_origin_id == HelperMD.m_MapOriginType.guild_fort then-------------------------------------------------------------------联盟堡垒
		if g_guildWarPlayerData.getGuildId() == 0 then
			--自己没公会
			menu_Key = 9
		elseif isSelfGuild(buildServerData) then
			--属于自己公会
			if isConstruction(buildServerData) then
				--建造中
				menu_Key = 2
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_BUILD) then
					--自己建造
					menu_Key = 3
				end
			else
				--非建造中
				menu_Key = 1 	
				if isNotFullOfDurability(buildServerData) then
					--耐久不满
					menu_Key = 5
					if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_REPAIR) then
						--自己修理中
						menu_Key = 6
					end
				else
					--满耐久
					menu_Key = 1
					if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_DEFEND) then
						--自己驻守中
						menu_Key = 4
					end
				end
			end
		else
			--不属于自己公会
			if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.battleHall) ~= nil then
				--自己有战争大厅
				menu_Key = 7
			else
				--自己没有战争大厅
				menu_Key = 8
			end
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_tower then---------------------------------------------------------------联盟箭塔
		if isSelfGuild(buildServerData) then
			--属于自己公会
			if isConstruction(buildServerData) then
				--建造中
				menu_Key = 2
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDTOWER_BUILD) then
					--自己建造
					menu_Key = 4
				end
			else
				--非建造中
				menu_Key = 1
			end
		else
			--不属于自己公会
			menu_Key = 3
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_gold then---------------------------------------------------------------联盟金矿
		if isSelfGuild(buildServerData) then
			--属于自己公会
			if isConstruction(buildServerData) then
				--建造中
				menu_Key = 2
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_BUILD) then
					--自己建造
					menu_Key = 3
				end
			else
				--非建造中
				menu_Key = 1
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_ING) then
					--自己采集
					menu_Key = 4
				end
			end
		else
			--不属于自己公会
			menu_Key = 5
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_food then---------------------------------------------------------------联盟粮田
		if isSelfGuild(buildServerData) then
			--属于自己公会
			if isConstruction(buildServerData) then
				--建造中
				menu_Key = 2
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_BUILD) then
					--自己建造
					menu_Key = 3
				end
			else
				--非建造中
				menu_Key = 1
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_ING) then
					--自己采集
					menu_Key = 4
				end
			end
		else
			--不属于自己公会
			menu_Key = 5
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_wood then---------------------------------------------------------------联盟伐木场
		if isSelfGuild(buildServerData) then
			--属于自己公会
			if isConstruction(buildServerData) then
				--建造中
				menu_Key = 2
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_BUILD) then
					--自己建造
					menu_Key = 3
				end
			else
				--非建造中
				menu_Key = 1
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_ING) then
					--自己采集
					menu_Key = 4
				end
			end
		else
			--不属于自己公会
			menu_Key = 5
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_stone then---------------------------------------------------------------联盟石料场
		if isSelfGuild(buildServerData) then
			--属于自己公会
			if isConstruction(buildServerData) then
				--建造中
				menu_Key = 2
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_BUILD) then
					--自己建造
					menu_Key = 3
				end
			else
				--非建造中
				menu_Key = 1
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_ING) then
					--自己采集
					menu_Key = 4
				end
			end
		else
			--不属于自己公会
			menu_Key = 5
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_iron then---------------------------------------------------------------联盟铁矿场
		if isSelfGuild(buildServerData) then
			--属于自己公会
			if isConstruction(buildServerData) then
				--建造中
				menu_Key = 2
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_BUILD) then
					--自己建造
					menu_Key = 3
				end
			else
				--非建造中
				menu_Key = 1
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_ING) then
					--自己采集
					menu_Key = 4
				end
			end
		else
			--不属于自己公会
			menu_Key = 5
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_cache then---------------------------------------------------------------联盟仓库
		if isSelfGuild(buildServerData) then
			--属于自己公会
			if isConstruction(buildServerData) then
				--建造中
				menu_Key = 2
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_GUILDWAREHOUSE_BUILD) then
					--自己建造
					menu_Key = 4
				end
			else
				--非建造中
				menu_Key = 1
			end
		else
			--不属于自己公会
			menu_Key = 3
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_gold then---------------------------------------------------------------金矿
		if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己采集
			menu_Key = 3
		elseif isHaveSelfGuildQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己联盟的其他人采集
			menu_Key = 2
		elseif isHaveOtherQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--其他人采集
			menu_Key = 4
		else
			--无人采集
			menu_Key = 1
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_food then--------------------------------------------------------------粮田
		if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己采集
			menu_Key = 3
		elseif isHaveSelfGuildQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己联盟的其他人采集
			menu_Key = 2
		elseif isHaveOtherQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--其他人采集
			menu_Key = 4
		else
			--无人采集
			menu_Key = 1
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_wood then--------------------------------------------------------------伐木场
		if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己采集
			menu_Key = 3
		elseif isHaveSelfGuildQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己联盟的其他人采集
			menu_Key = 2
		elseif isHaveOtherQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--其他人采集
			menu_Key = 4
		else
			--无人采集
			menu_Key = 1
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_stone then--------------------------------------------------------------石料场
		if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己采集
			menu_Key = 3
		elseif isHaveSelfGuildQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己联盟的其他人采集
			menu_Key = 2
		elseif isHaveOtherQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--其他人采集
			menu_Key = 4
		else
			--无人采集
			menu_Key = 1
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.world_iron then--------------------------------------------------------------铁矿场
		if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己采集
			menu_Key = 3
		elseif isHaveSelfGuildQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--自己联盟的其他人采集
			menu_Key = 2
		elseif isHaveOtherQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING) then
			--其他人采集
			menu_Key = 4
		else
			--无人采集
			menu_Key = 1
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.player_home then--------------------------------------------------------------城堡
		if isMySelf(buildServerData) then
			--自己城堡
			menu_Key = 1
		elseif isSelfGuild(buildServerData) then
			--自己联盟的其他玩家城堡
			local queueSD = require "game.mapguildwar.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_CITYASSIST_ING)
			if queueSD then
				--自己在援助
				menu_Key = 5
			else
				--自己没有援助
				menu_Key = 2
			end
		else
			--别人的城堡
			if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.battleHall) ~= nil then
				--自己有战争大厅
				menu_Key = 3
			else
				--自己没有战争大厅
				menu_Key = 4
			end
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.king_castle then--------------------------------------------------------------王城
		if g_guildWarPlayerData.getGuildId() == 0 then
			--自己没公会
			menu_Key = 5
		else
			if g_kingInfo.isKingBattleStarted() then
				--王城交战中
				menu_Key = 2
			else
				--王城非交战中
				if buildServerData.guild_id == 0 then
					--无领主
					menu_Key = 1
				else
					--有领主
					if isSelfGuild(buildServerData) then
						--自己联盟
						menu_Key = 3
					else
						--其他联盟
						menu_Key = 4
						
					end
					
				end
			end
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.camp_middle then--------------------------------------------------------------中级营寨
		if g_guildWarPlayerData.getGuildId() == 0 then
			--自己没公会
			menu_Key = 6
		else
			if g_kingInfo.isKingBattleStarted() then
				--国王战交战中
				if buildServerData.guild_id == 0 then
					--中立状态
					menu_Key = 2
				else
					--非中立状态
					if isSelfGuild(buildServerData) then
						--自己联盟
						if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_KINGTOWN_DEFENCE)
							or isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCE)
							or isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCEASIST)
							then
							--有自己驻军
							menu_Key = 4
						else
							--没有自己驻军
							menu_Key = 3
						end
					else
						--其他联盟
						menu_Key = 5
					end
				end
			else
				--国王战未开始
				menu_Key = 1
			end
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.camp_low then--------------------------------------------------------------低级营寨
		if g_guildWarPlayerData.getGuildId() == 0 then
			--自己没公会
			menu_Key = 6
		else
			if g_kingInfo.isKingBattleStarted() then
				--国王战交战中
				if buildServerData.guild_id == 0 then
					--中立状态
					menu_Key = 2
				else
					--非中立状态
					if isSelfGuild(buildServerData) then
						--自己联盟
						if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_KINGTOWN_DEFENCE)
							or isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCE)
							or isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCEASIST)
							then
							--有自己驻军
							menu_Key = 4
						else
							--没有自己驻军
							menu_Key = 3
						end
					else
						--其他联盟
						menu_Key = 5
					end
				end
			else
				--国王战未开始
				menu_Key = 1
			end
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.stronghold then--------------------------------------------------------------据点
		if buildServerData.player_id == 0 then
			--无人
			menu_Key = 1
		elseif isMySelf(buildServerData) then
			--自己
			menu_Key = 3
		elseif isSelfGuild(buildServerData) then
			--自己联盟的其他人
			menu_Key = 2
		else
			--其他人
			menu_Key = 4
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gongchengchui then--------------------------------------------------------------攻城锤
		if g_guildWarBattleInfoData.IsAttacker() then --攻击方
			
			local gate_1_InitData = g_data.cross_map_config[2]
			local gate_1_ServerData = g_guildWarMapSpBuildData.getSpBuildDataBy_xy(gate_1_InitData.x,gate_1_InitData.y)
			local gate_1_IsBroken = gate_1_ServerData and tonumber(gate_1_ServerData.durability) == 0 --A门是否被击破
			if gate_1_IsBroken then
				menu_Key = 4
			else
				if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_HAMMER_ING) then
					--自己驻守
					menu_Key = 3
				elseif isHaveSelfGuildQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_HAMMER_ING) then
					--自己联盟的其他人驻守
					menu_Key = 2
				elseif isHaveOtherQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_HAMMER_ING) then
					--其他人驻守
					menu_Key = 4
				else
					--无人驻守
					menu_Key = 1
				end
			end
		else --防守方
			menu_Key = 4
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gate then--------------------------------------------------------------城门
		if g_guildWarBattleInfoData.IsAttacker() and buildServerData.durability > 0  then --攻击方
			menu_Key = 1
		else --防守方
			menu_Key = 2
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_war_chuangnu then--------------------------------------------------------------床弩
		
		widget:setPositionX(widget:getPositionX() + 50)
		
		if not g_guildWarBattleInfoData.IsAttacker() then --攻击方
			if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_CROSSBOW_ING) then
				--自己驻守
				menu_Key = 3
			elseif isHaveSelfGuildQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_CROSSBOW_ING) then
				--自己联盟的其他人驻守
				menu_Key = 2
			elseif isHaveOtherQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_CROSSBOW_ING) then
				--其他人驻守
				menu_Key = 4
			else
				--无人驻守
				menu_Key = 1
				
				local currentBuildIdx = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(buildServerData.x,buildServerData.y).build_num
				if currentBuildIdx == 1 or currentBuildIdx == 2 then
					--城门A
					local gate_1_InitData = g_data.cross_map_config[2]
					local gate_1_ServerData = g_guildWarMapSpBuildData.getSpBuildDataBy_xy(gate_1_InitData.x,gate_1_InitData.y)
					local gate_1_IsBroken = tonumber(gate_1_ServerData.durability) == 0 --A门是否被击破
					if gate_1_IsBroken then
						menu_Key = 4
					end
				elseif currentBuildIdx == 3 or currentBuildIdx == 4 then
					--云梯
					local yuntiInitData = g_data.cross_map_config[5]
					local yunTiServerData = g_guildWarMapSpBuildData.getSpBuildDataBy_xy(yuntiInitData.x,yuntiInitData.y)
					local wf_ladder_max_progress = tonumber(g_data.warfare_service_config[16].data) 
					local yunti_IsHold =  tonumber(yunTiServerData.resource) >= wf_ladder_max_progress --云梯是否被占领
					if yunti_IsHold then
						menu_Key = 4
					end
				end
			end
		else --防守方
			menu_Key = 4
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_war_yunti then--------------------------------------------------------------云梯
		if g_guildWarBattleInfoData.IsAttacker() then --攻击方
			local maxValue = tonumber(g_data.warfare_service_config[16].data)
   		if buildServerData.resource >= maxValue then
   			menu_Key = 4
   		else
	   		if isHaveSelfQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_LADDER_ING) then
					--自己驻守
					menu_Key = 3
				elseif isHaveSelfGuildQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_LADDER_ING) then
					--自己联盟的其他人驻守
					menu_Key = 2
				elseif isHaveOtherQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_LADDER_ING) then
					--其他人驻守
					menu_Key = 4
				else
					--无人驻守
					menu_Key = 1
				end
   		end
		else --防守方
			menu_Key = 4
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then--------------------------------------------------------------投石车
		if g_guildWarBattleInfoData.IsSelfOccupationArea(buildServerData.area) then --投石车属于我方
			if buildServerData.player_id == 0 then
				--无人
				menu_Key = 1
			elseif isMySelf(buildServerData) then
				--自己
				menu_Key = 3
			elseif isSelfGuild(buildServerData) then
				--自己联盟的其他人
				menu_Key = 2
			else
				--其他人
				menu_Key = 4
			end
		else --投石车属于对方 不可占领
			if buildServerData.player_id == 0 then
				menu_Key = 4 --无人
			else
				menu_Key = 5 --敌人驻守
			end
			
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_war_base_camp then--------------------------------------------------------------大本营
		if g_guildWarBattleInfoData.IsAttacker() then --攻击方
			menu_Key = 1
		else --防守方
			menu_Key = 2
		end
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_war_wall then--------------------------------------------------------------城墙
	elseif map_element_origin_id == HelperMD.m_MapOriginType.guild_war_fuhuodian then--------------------------------------------------------------复活点
	else
		assert(false,"error : not found table with map_element_origin_id = "..tostring(map_element_origin_id))
	end
	
	
	--传递的数据
	local playerData_belong = nil
	if buildServerData.player_id ~= 0 then
		playerData_belong = bigMap.getCurrentAreaDatas().Player[tostring(buildServerData.player_id)]
	end
	local guildData_belong = nil
	if buildServerData.guild_id ~= 0 then
		guildData_belong = bigMap.getCurrentAreaDatas().Guild[tostring(buildServerData.guild_id)]
	end
	
	
	--先隐藏所有
	for i = 1 , 99 ,1 do
		local b = widget:getChildByName(string.format("Panel_anniu%02d",i))
		if b then
			b:setVisible(false)
		else
			break
		end
	end
	
	
	--缓存
	local cache_data = {}
	widget.lua_cache_data = cache_data
	
	--cell缓存
	widget.lua_cache_data.cellArray = {}
	
	--按钮缓存
	widget.lua_cache_data.buttonArray = {}
	
	--打开动画是否完成
	local open_animation_completed = false
	
	--点中
	local function onCellButton(sender, eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
				require("game.mapguildwar.worldMapLayer_smallMenuClick").onClick(
					widget.lua_cache_data.buttonArray[sender]
					, g_data.map_element[tonumber(buildServerData.map_element_id)]
					, buildServerData 
					, nil
					, playerData_belong
					, guildData_belong
					, nil
					)
				bigMap.closeSmallMenu()
			end
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	
	--建筑菜单组配置
	local menu_cell_types = g_data.map_build_menu[map_element_origin_id]["build_menu_"..tostring(menu_Key)]
	
	if map_element_origin_id == HelperMD.m_MapOriginType.player_home then --联盟战城堡
		menu_cell_types = g_data.map_build_menu[99999]["build_menu_"..tostring(menu_Key)]
	end
	
	local count = table.total(menu_cell_types)
	local num = 0
	for k , v in pairs(menu_cell_types) do
		num = num + 1
		local cell = widget:getChildByName(string.format("Panel_anniu%02d", c_IndexArray[count][num]))
		widget.lua_cache_data.cellArray[(#(widget.lua_cache_data.cellArray)) + 1] = cell
		cell:setVisible(true)
		local cellConfig = g_data.build_menu_type[v]
		cell:getChildByName("Text_2"):setString(g_tr(cellConfig.name))
		local button = cell:getChildByName("Image_1_0")
		widget.lua_cache_data.buttonArray[button] = v
		button:loadTexture(g_data.sprite[cellConfig.img].path)
		button:addTouchEventListener(onCellButton)
		
		--注册新手引导nodeId
		g_guideManager.registComponent(7000000 + v,button)
	end
	
	
	--下面部分
	do
		local bottom = widget:getChildByName("Panel_2")
		bottom:getChildByName("Text_time"):setVisible(false)
		
		if map_element_origin_id == HelperMD.m_MapOriginType.world_gold 
			or map_element_origin_id == HelperMD.m_MapOriginType.world_food
			or map_element_origin_id == HelperMD.m_MapOriginType.world_wood
			or map_element_origin_id == HelperMD.m_MapOriginType.world_stone
			or map_element_origin_id == HelperMD.m_MapOriginType.world_iron
				then
			local resource_num = buildServerData.resource
			local qd = isHaveQueueDoing(buildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING)
			if qd then
				resource_num = resource_num - qd.target_info.speed / 60 *	math.max(0, g_clock.getCurServerTime() - qd.create_time)
			end
			resource_num = math.ceil(resource_num)
			if resource_num < 0 then
				resource_num = 0
			end
			--显示剩余资源
			bottom:getChildByName("Text_1"):setVisible(false)
			local resPanel = bottom:getChildByName("Panel_zhu")
			resPanel:setVisible(true)
			resPanel:getChildByName("Text_1"):setString(string.format("X:%d Y:%d", buildServerData.x, buildServerData.y))
			resPanel:getChildByName("Text_2"):setString(tostring(resource_num))
			local cnt , iconPath = g_gameTools.getPlayerCurrencyCount(_getResType(map_element_origin_id))
			resPanel:getChildByName("Image_13"):loadTexture(iconPath)
		else
			--隐藏剩余资源
			bottom:getChildByName("Panel_zhu"):setVisible(false)
			bottom:getChildByName("Text_1"):setVisible(true)
			bottom:getChildByName("Text_1"):setString(string.format("X:%d Y:%d", buildServerData.x, buildServerData.y))
		end
		
		--联盟战不显示收藏按钮
		bottom:getChildByName("Image_4"):setVisible(false)
		
		--[[
		if map_element_origin_id == HelperMD.m_MapOriginType.player_home and isMySelf(buildServerData) then
			--自己的城堡不显示
			bottom:getChildByName("Image_4"):setVisible(false)
		else
			bottom:getChildByName("Image_4"):setVisible(true)
			local function onSaveIndexButton(sender, eventType)
				if eventType == ccui.TouchEventType.ended then
					require("game.mapguildwar.worldMapLayer_pecialClick").onClick_SaveIndex(cc.p(buildServerData.x,buildServerData.y), g_data.map_element[tonumber(buildServerData.map_element_id)], buildServerData)
					bigMap.closeSmallMenu()
				end
			end
			bottom:getChildByName("Image_4"):addTouchEventListener(onSaveIndexButton)
		end
		--]]
		bottom:getChildByName("Panel_3"):setVisible(false)
	end
	
	
	
	
	--监听建筑关闭
	local function update_buildingMenu(dt)
		if bigMap.getCurrentAreaDatas().Map[tostring(buildServerData.id)] == nil then
			bigMap.closeSmallMenu()
		end
	end
	widget:scheduleUpdateWithPriorityLua( update_buildingMenu, 0 )
	
	
	--tip菜单
	if tipMenuId then
		local tipId = tonumber(tipMenuId)
		for k , v in pairs(widget.lua_cache_data.buttonArray) do
			k:removeChildByTag(c_tip_effect_tag)
			if v == tipId then
				local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_XinShouYuanKuangXunHuan/Effect_XinShouYuanKuangXunHuan.ExportJson", "Effect_XinShouYuanKuangXunHuan")
				k:addChild(armature,0,c_tip_effect_tag)
				local size = k:getContentSize()
				armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
				animation:play("Animation1")
			end
		end
	end
	
	
	--打开动画
	local function playOpenAnimation()
		local basic_panel = widget:getChildByName("Panel_SpecialEffects")
		local basic_position = cc.p(basic_panel:getPositionX(), basic_panel:getPositionY())
		for k , v in ipairs(widget.lua_cache_data.cellArray) do
			local origin_position = cc.p(v:getPositionX(), v:getPositionY())
			local vec = cc.pSub(origin_position, basic_position)
			v:setPosition(cc.pSub(origin_position,cc.pSetLength(vec, cc.pGetLength(vec) * 0.75)))
			v:setScale(0.5)
			local action = cc.Spawn:create(cc.EaseBounceOut:create(cc.MoveTo:create(0.45, origin_position)) , cc.ScaleTo:create(0.2,1.0) )
			v:runAction(action)
		end
		basic_panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.45), cc.CallFunc:create(function() open_animation_completed = true end)))
	end
	playOpenAnimation()
	
	
	return widget
end



--是否属于自己
local function isMySelf_queue(queueServerData)
	return queueServerData.player_id ~= 0 and queueServerData.player_id == m_MyPlayerData.player_id
end


--是否是返回主城
local function isToHome_queue(queueServerData)
	local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	local player = currentQueueDatas.Player[tostring(queueServerData.player_id)]
	assert(player,"")
	return (player ~= nil and player.x == queueServerData.to_x and player.y == queueServerData.to_y)
end


--自己是否有子集结队伍在这个队伍中
local function isSelfHaveQueueInQueue_queue(queueServerData)
	local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		if v.player_id == m_MyPlayerData.player_id and v.parent_queue_id == queueServerData.id then
			return v
		end
	end
	return nil
end


--行军队伍菜单
function create_with_queueServerData(queueServerData , tipMenuId)
	
	local bigMap = require "game.mapguildwar.worldMapLayer_bigMap"
	
	m_MyPlayerData = g_guildWarPlayerData.GetData()
	
	--这个菜单的坐标在调用处实时计算
	local widget = cc.CSLoader:createNode("worldMap_01.csb")
	widget:setAnchorPoint(cc.p(0.5,0.5))
	--widget:getChildByName("Panel_1"):setTouchEnabled(false)
	local function widgetEventHandler(eventType)
				if eventType == "enter" then
			bigMap.setMapScrollViewTouchEnabled(false)
			g_guideManager.execute()
		elseif eventType == "exit" then
			bigMap.setMapScrollViewTouchEnabled(true)
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
				end
		end
		widget:registerScriptHandler(widgetEventHandler)
	
	
	--队伍菜单,采用屏蔽事件,自己关自己
	local function onCloseButton(sender, eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			bigMap.closeSmallMenu()
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	widget:getChildByName("Panel_1"):addTouchEventListener(onCloseButton)
	
	
	
	--最终需要的key
	local menu_Key = nil
	
	if QueueHelperMD.isGatherType(queueServerData) then
		--集结类型
		if QueueHelperMD.isGatherGotoType(queueServerData) then
			--合体出发
			if isMySelf_queue(queueServerData) then
				--我就是主集结
				menu_Key = 5
			elseif isSelfHaveQueueInQueue_queue(queueServerData) then
				--我是子集结
				menu_Key = 6
			else
				--其他玩家的部队
				menu_Key = 4
			end
		elseif QueueHelperMD.isGatherReturnType(queueServerData) then
			--集结返回
			if isMySelf_queue(queueServerData) then
				--自己部队
				if QueueHelperMD.isGatherMidReturnType(queueServerData) then
					--撤回集结着家
					menu_Key = 8
				else
					--非撤回集结着家
					menu_Key = 3
				end
			else
				--其他玩家的部队
				menu_Key = 4
			end
		else
			--还在集结中
			if isMySelf_queue(queueServerData) then
				--自己部队
				--跑去加入别人集结
				menu_Key = 7
			else
				--其他玩家的部队
				menu_Key = 4
			end
		end
	else
		--非集结类型
		if isMySelf_queue(queueServerData) then
			--自己部队
			if queueServerData.type == QueueHelperMD.QueueTypes.TYPE_GUILDWAREHOUSE_FETCHGOTO then
				--联盟仓库存取(去)
				menu_Key = 10
			elseif queueServerData.type == QueueHelperMD.QueueTypes.TYPE_GUILDWAREHOUSE_FETCHRETURN then
				--联盟仓库存取(返)
				menu_Key = 11
			else
				if isToHome_queue(queueServerData) then
					--回城
					if QueueHelperMD.isDetectType(queueServerData) then
						--侦查
						menu_Key = 9
					elseif QueueHelperMD.isFetchItemType(queueServerData) then	
						--拿取
						menu_Key = 13
					else
						--普通
						menu_Key = 3
					end
				else
					--非回城
					if QueueHelperMD.isDetectType(queueServerData) then
						--侦查
						menu_Key = 2
					elseif QueueHelperMD.isFetchItemType(queueServerData) then	
						--拿取
						menu_Key = 12
					else
						--普通
						menu_Key = 1
					end
				end
			end
		else
			--其他玩家的部队
			menu_Key = 4
		end
	end
	
	--传递的数据
	local playerData_belong = nil
	if queueServerData.player_id ~= 0 then
		playerData_belong = bigMap.getCurrentQueueDatas().Player[tostring(queueServerData.player_id)]
	end
	local guildData_belong = nil
	if queueServerData.guild_id ~= 0 then
		guildData_belong = bigMap.getCurrentQueueDatas().Guild[tostring(queueServerData.guild_id)]
	end
	
	--先隐藏所有
	for i = 1 , 99 ,1 do
		local b = widget:getChildByName(string.format("Panel_anniu%02d",i))
		if b then
			b:setVisible(false)
		else
			break
		end
	end
	
	--缓存
	local cache_data = {}
	widget.lua_cache_data = cache_data
	
	--cell缓存
	widget.lua_cache_data.cellArray = {}
	
	--按钮缓存
	widget.lua_cache_data.buttonArray = {}
	
	--打开动画是否完成
	local open_animation_completed = false
	
	--点中
	local function onCellButton(sender, eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
				local teamNode = bigMap.getTeamInterface(queueServerData)
				if teamNode and teamNode.lua_TouchEnable then
					require("game.mapguildwar.worldMapLayer_smallMenuClick").onClick(
										widget.lua_cache_data.buttonArray[sender]
										, nil
										, nil
										, queueServerData
										, playerData_belong
										, guildData_belong
										, nil
										)
				end
				bigMap.closeSmallMenu()
			end
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	
	--其他菜单组配置
	local menu_cell_types = g_data.marching_troops_menu[2]["build_menu_"..tostring(menu_Key)]
	
	local count = table.total(menu_cell_types)
	local num = 0
	for k , v in pairs(menu_cell_types) do
		num = num + 1
		local cell = widget:getChildByName(string.format("Panel_anniu%02d", c_IndexArray[count][num]))
		widget.lua_cache_data.cellArray[(#(widget.lua_cache_data.cellArray)) + 1] = cell
		cell:setVisible(true)
		if v == 136 then --队列加速按钮 联盟战模式下需要特殊显示额外内容
			local changeMapScene = require("game.maplayer.changeMapScene")
			local mapStatus = changeMapScene.getCurrentMapStatus()
			if mapStatus == changeMapScene.m_MapEnum.guildwar then
				local panel = cc.CSLoader:createNode("tubiaotie1.csb")
				cell:addChild(panel)
				local icon,num = require("game.uilayer.mainSurface.mainSurfaceQueueWorld").getGuildWarSpeedCost()
				if icon then
					local con = panel:getChildByName("Image_1")
					con:addChild(icon)
					panel:getChildByName("Text_1_0"):setString(num.."")
					icon:setPosition(cc.p(con:getContentSize().width/2,con:getContentSize().height/2))
					local scale = con:getContentSize().width/icon:getContentSize().width
					icon:setScale(scale)
				end
				panel:setPosition(cc.p(cell:getContentSize().width/2 - panel:getContentSize().width/2,10))
			end
		end
		
		local cellConfig = g_data.build_menu_type[v]
		cell:getChildByName("Text_2"):setString(g_tr(cellConfig.name))
		local button = cell:getChildByName("Image_1_0")
		widget.lua_cache_data.buttonArray[button] = v
		button:loadTexture(g_data.sprite[cellConfig.img].path)
		button:addTouchEventListener(onCellButton)
		
		--注册新手引导nodeId
		g_guideManager.registComponent(7000000 + v,button)
	end
	
	
	--下面部分
	local text_time_label = nil
	do
		local bottom = widget:getChildByName("Panel_2")
		bottom:getChildByName("Panel_zhu"):setVisible(false)
		bottom:getChildByName("Text_1"):setVisible(true)
		local str = string.format("X:%d Y:%d ", queueServerData.to_x, queueServerData.to_y)
		if guildData_belong then
			str = str.."("..guildData_belong.short_name..")"
		end
		if playerData_belong then
			str = str..playerData_belong.nick
		end
		bottom:getChildByName("Text_1"):setString(str)
		bottom:getChildByName("Image_4"):setVisible(false)
		bottom:getChildByName("Panel_3"):setVisible(true)
		text_time_label = bottom:getChildByName("Text_time")
		text_time_label:setVisible(true)
		text_time_label:setString("")
		--跳转
		local function onJump(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				bigMap.closeSmallMenu()
				bigMap.closeInputMenu()
				bigMap.changeBigTileIndex_Manual(cc.p(queueServerData.to_x, queueServerData.to_y),true)
			end
		end
		bottom:addTouchEventListener(onJump)
	end
	
	
	--监听队伍位置或关闭
	local last_show_end_time = 0
	local function update_teamMenu(dt)
		local teamNode = bigMap.getTeamInterface(queueServerData)
		if teamNode then
			local position = cc.p(teamNode:getPositionX(),teamNode:getPositionY())
			widget:setPosition(position)
			bigMap.changePosition_Manual(position)
			local t = queueServerData.end_time - g_clock.getCurServerTime()
			if last_show_end_time ~= t then
				text_time_label:setString(g_gameTools.convertSecondToString(t > 0 and t or 0))
			end
		else
			bigMap.closeSmallMenu()
		end
	end
	widget:scheduleUpdateWithPriorityLua( update_teamMenu, 0 )
	update_teamMenu(0.01666)
	
	--tip菜单
	if tipMenuId then
		local tipId = tonumber(tipMenuId)
		for k , v in pairs(widget.lua_cache_data.buttonArray) do
			k:removeChildByTag(c_tip_effect_tag)
			if v == tipId then
				local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_XinShouYuanKuangXunHuan/Effect_XinShouYuanKuangXunHuan.ExportJson", "Effect_XinShouYuanKuangXunHuan")
				k:addChild(armature,0,c_tip_effect_tag)
				local size = k:getContentSize()
				armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
				animation:play("Animation1")
			end
		end
	end
	
	
	--打开动画
	local function playOpenAnimation()
		local basic_panel = widget:getChildByName("Panel_SpecialEffects")
		local basic_position = cc.p(basic_panel:getPositionX(), basic_panel:getPositionY())
		for k , v in ipairs(widget.lua_cache_data.cellArray) do
			local origin_position = cc.p(v:getPositionX(), v:getPositionY())
			local vec = cc.pSub(origin_position, basic_position)
			v:setPosition(cc.pSub(origin_position,cc.pSetLength(vec, cc.pGetLength(vec) * 0.75)))
			v:setScale(0.5)
			local action = cc.Spawn:create(cc.EaseBounceOut:create(cc.MoveTo:create(0.45, origin_position)) , cc.ScaleTo:create(0.2,1.0) )
			v:runAction(action)
		end
		basic_panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.45), cc.CallFunc:create(function() open_animation_completed = true end)))
	end
	playOpenAnimation()
	
	
	return widget
end



--空地菜单
function create_with_bigTileIndex(bigTileIndex , tipMenuId)
	
	do --联盟战空地不需要菜单
	
		return
	end
	
	--m_MyPlayerData = g_guildWarPlayerData.GetData()
	
	local bigMap = require "game.mapguildwar.worldMapLayer_bigMap"
	
	local widget = cc.CSLoader:createNode("worldMap_01.csb")
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition( HelperMD.bigTileIndex_2_positionCenter(bigTileIndex) )
	--widget:getChildByName("Panel_1"):setTouchEnabled(false)
	
	local function widgetEventHandler(eventType)
		if eventType == "enter" then
			g_guideManager.execute()
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
		end
	end
	widget:registerScriptHandler(widgetEventHandler)
	
	--空地菜单,采用屏蔽事件,自己关自己
	local function onCloseButton(sender, eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			bigMap.closeSmallMenu()
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	widget:getChildByName("Panel_1"):addTouchEventListener(onCloseButton)
	
	
	--最终需要的key
	local menu_Key = 1 --g_guildWarPlayerData.isAllianceManager() and 2 or 1

	
	--先隐藏所有
	for i = 1 , 99 ,1 do
		local b = widget:getChildByName(string.format("Panel_anniu%02d",i))
		if b then
			b:setVisible(false)
		else
			break
		end
	end
	
	--缓存
	local cache_data = {}
	widget.lua_cache_data = cache_data
	
	--cell缓存
	widget.lua_cache_data.cellArray = {}
	
	--按钮缓存
	widget.lua_cache_data.buttonArray = {}
	
	--打开动画是否完成
	local open_animation_completed = false
	
	--点中
	local function onCellButton(sender, eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
				require("game.mapguildwar.worldMapLayer_smallMenuClick").onClick(
					widget.lua_cache_data.buttonArray[sender]
					, nil
					, nil
					, nil
					, nil
					, nil
					, bigTileIndex
					)
				bigMap.closeSmallMenu()
			end
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	
	--其他菜单组配置
	local menu_cell_types = g_data.marching_troops_menu[1]["build_menu_"..tostring(menu_Key)]
	
	local count = table.total(menu_cell_types)
	local num = 0
	for k , v in pairs(menu_cell_types) do
		num = num + 1
		local cell = widget:getChildByName(string.format("Panel_anniu%02d", c_IndexArray[count][num]))
		widget.lua_cache_data.cellArray[(#(widget.lua_cache_data.cellArray)) + 1] = cell
		cell:setVisible(true)
		local cellConfig = g_data.build_menu_type[v]
		cell:getChildByName("Text_2"):setString(g_tr(cellConfig.name))
		local button = cell:getChildByName("Image_1_0")
		widget.lua_cache_data.buttonArray[button] = v
		button:loadTexture(g_data.sprite[cellConfig.img].path)
		button:addTouchEventListener(onCellButton)
		
		--注册新手引导nodeId
		g_guideManager.registComponent(7000000 + v,button)
	end
	
	
	--下面部分
	do
		local bottom = widget:getChildByName("Panel_2")
		bottom:getChildByName("Panel_zhu"):setVisible(false)
		bottom:getChildByName("Text_1"):setVisible(true)
		bottom:getChildByName("Text_1"):setString(string.format("X:%d Y:%d", bigTileIndex.x, bigTileIndex.y))
		--bottom:getChildByName("Image_4"):setVisible(true)
		bottom:getChildByName("Text_time"):setVisible(false)
		local function onSaveIndexButton(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				require("game.mapguildwar.worldMapLayer_pecialClick").onClick_SaveIndex(bigTileIndex, nil, nil)
				bigMap.closeSmallMenu()
			end
		end
		bottom:getChildByName("Image_4"):addTouchEventListener(onSaveIndexButton)
		bottom:getChildByName("Panel_3"):setVisible(false)
	end

	
	--tip菜单
	if tipMenuId then
		local tipId = tonumber(tipMenuId)
		for k , v in pairs(widget.lua_cache_data.buttonArray) do
			k:removeChildByTag(c_tip_effect_tag)
			if v == tipId then
				local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_XinShouYuanKuangXunHuan/Effect_XinShouYuanKuangXunHuan.ExportJson", "Effect_XinShouYuanKuangXunHuan")
				k:addChild(armature,0,c_tip_effect_tag)
				local size = k:getContentSize()
				armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
				animation:play("Animation1")
			end
		end
	end

	
	--打开动画
	local function playOpenAnimation()
		local basic_panel = widget:getChildByName("Panel_SpecialEffects")
		local basic_position = cc.p(basic_panel:getPositionX(), basic_panel:getPositionY())
		for k , v in ipairs(widget.lua_cache_data.cellArray) do
			local origin_position = cc.p(v:getPositionX(), v:getPositionY())
			local vec = cc.pSub(origin_position, basic_position)
			v:setPosition(cc.pSub(origin_position,cc.pSetLength(vec, cc.pGetLength(vec) * 0.75)))
			v:setScale(0.5)
			local action = cc.Spawn:create(cc.EaseBounceOut:create(cc.MoveTo:create(0.45, origin_position)) , cc.ScaleTo:create(0.2,1.0) )
			v:runAction(action)
		end
		basic_panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.45), cc.CallFunc:create(function() open_animation_completed = true end)))
	end
	playOpenAnimation()
	

	return widget
end


--设置提示点击的菜单ID
function setTipMenuID( tipMenuId )
	local widget = require "game.mapguildwar.worldMapLayer_bigMap".getSmallMenu()
	if widget then
		
		local tipId = tipMenuId and tonumber(tipMenuId) or -1
		for k , v in pairs(widget.lua_cache_data.buttonArray) do
			k:removeChildByTag(c_tip_effect_tag)
			if v == tipId then
				local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_XinShouYuanKuangXunHuan/Effect_XinShouYuanKuangXunHuan.ExportJson", "Effect_XinShouYuanKuangXunHuan")
				k:addChild(armature,0,c_tip_effect_tag)
				local size = k:getContentSize()
				armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
				animation:play("Animation1")
			end
		end
		
	end
end


return worldMapLayer_smallMenu