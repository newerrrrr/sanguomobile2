local worldMapLayer_queueHelper = {}
setmetatable(worldMapLayer_queueHelper,{__index = _G})
setfenv(1,worldMapLayer_queueHelper)

QueueTypes = {
	TYPE_RETURN                = 1, --回城
	TYPE_CITYBATTLE_GOTO		 = 101, --攻城
	TYPE_CITYBATTLE_RETURN	 = 102, --攻城回
	TYPE_ATTACKDOOR_GOTO		 = 201, --去攻城门
	TYPE_ATTACKDOOR_RETURN	 = 202, --去攻城门回
	TYPE_HAMMER_GOTO			 = 301, --去攻城锤
	TYPE_HAMMER_ING			 = 302, --占领攻城锤
	TYPE_HAMMER_RETURN		 = 303, --攻城锤回
	TYPE_ATTACKHAMMER_GOTO	 = 304, --去打攻城锤
	TYPE_ATTACKHAMMER_RETURN	 = 305, --打攻城锤回
	TYPE_CATAPULT_GOTO		 = 401, --去投石车
	TYPE_CATAPULT_ING			 = 402, --占领投石车
	TYPE_CATAPULT_RETURN		 = 403, --投石车回
	TYPE_LADDER_GOTO			 = 501, --去云梯
	TYPE_LADDER_ING			 = 502, --占领云梯
	TYPE_LADDER_RETURN		 = 503, --云梯回
	TYPE_CROSSBOW_GOTO		 = 601, --去床弩
	TYPE_CROSSBOW_ING			 = 602, --占领床弩
	TYPE_CROSSBOW_RETURN		 = 603, --床弩回
	TYPE_ATTACKBASE_GOTO		 = 701, --去攻大本营
	TYPE_ATTACKBASE_RETURN	 = 702, --攻大本营回
	TYPE_CITYSPY_GOTO       = 801, --侦查城堡
	TYPE_CITYSPY_RETURN     = 802, --侦查城堡回
	TYPE_CATAPULTSPY_GOTO   = 901, --侦查投石车
	TYPE_CATAPULTSPY_RETURN = 902, --侦查投石车回
}


--是否需要线段(有线段的情况下才有队伍显示在地图上)
function isNeedLine( serverData )
	return (
		serverData.type ~= QueueTypes.TYPE_GATHERDBATTLE_GOTO	--这个模式比较特殊,不处理显示
		and (serverData.from_x ~= serverData.to_x or serverData.from_y ~= serverData.to_y)
		)
end



--是否为定点队列(不需要线段的队列也未必是定点队列,必须用这个函数判定)
function isFixedPoint( serverData )
	return serverData.from_x == serverData.to_x and serverData.from_y == serverData.to_y
end



--是否是集结类型模式
function isGatherType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_GATHER_WAIT
		or serverData.type == QueueTypes.TYPE_GATHERBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_GATHER_GOTO
		or serverData.type == QueueTypes.TYPE_GATHER_STAY
		or serverData.type == QueueTypes.TYPE_GATHERDBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_GATHER_RETURN
		or serverData.type == QueueTypes.TYPE_GATHERD_MIDRETURN
		or serverData.type == QueueTypes.TYPE_ATTACKBASEGATHER_GOTO
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCE
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCEASIST
		or serverData.type == QueueTypes.TYPE_BOSSGATHER_GOTO
		)
end


--是否是集结第一阶段类型模式
function isGatherFirstStageType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_GATHER_WAIT
		or serverData.type == QueueTypes.TYPE_GATHER_GOTO
		or serverData.type == QueueTypes.TYPE_GATHER_STAY
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCE
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCEASIST
		)
end

--集结显示返回的特殊王城战
function isGatherShowBack(serverData)
	return (
		serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCE
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCEASIST
		)
end


--是否是集结等待类型模式
function isGatherWaitType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_GATHER_WAIT
		or serverData.type == QueueTypes.TYPE_GATHER_STAY
		)
end


--是否是集结合体出发的类型模式
function isGatherGotoType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_GATHERBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_GATHERDBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKBASEGATHER_GOTO
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_BOSSGATHER_GOTO
		)
end


--集结返回模式
function isGatherReturnType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_GATHERD_MIDRETURN
		or serverData.type == QueueTypes.TYPE_GATHER_RETURN
		)
end


--正常集结返回模式
function isGatherNormalReturnType(serverData)
	return ( serverData.type == QueueTypes.TYPE_GATHER_RETURN
		)
end


--是否为撤回集结者家
function isGatherMidReturnType(serverData)
	return serverData.type == QueueTypes.TYPE_GATHERD_MIDRETURN
end


--是否是需要返回通知模式
function isNeedBackNotice(serverData)
	return (
		serverData.type == QueueTypes.TYPE_RETURN
		or serverData.type == QueueTypes.TYPE_COLLECT_RETURN
		or serverData.type == QueueTypes.TYPE_NPCBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYASSIST_RETURN
		or serverData.type == QueueTypes.TYPE_GATHER_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDBASE_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDTOWER_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_RETURN
		or serverData.type == QueueTypes.TYPE_KINGTOWN_RETURN
		or serverData.type == QueueTypes.TYPE_DETECT_RETURN
		or serverData.type == QueueTypes.TYPE_FETCHITEM_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_FETCHRETURN
		
		--联盟战
		or serverData.type == QueueTypes.TYPE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKDOOR_RETURN
		or serverData.type == QueueTypes.TYPE_HAMMER_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKHAMMER_RETURN
		or serverData.type == QueueTypes.TYPE_CATAPULT_RETURN
		or serverData.type == QueueTypes.TYPE_LADDER_RETURN
		or serverData.type == QueueTypes.TYPE_CROSSBOW_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_RETURN
		)
end


--是否是需要返回请求army模式
function isNeedBackRequestArmy(serverData)
	return (
		serverData.type == QueueTypes.TYPE_RETURN
		or serverData.type == QueueTypes.TYPE_COLLECT_RETURN
		or serverData.type == QueueTypes.TYPE_NPCBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYASSIST_RETURN
		or serverData.type == QueueTypes.TYPE_GATHER_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDBASE_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDTOWER_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_RETURN
		or serverData.type == QueueTypes.TYPE_KINGTOWN_RETURN
		or serverData.type == QueueTypes.TYPE_DETECT_RETURN
		or serverData.type == QueueTypes.TYPE_FETCHITEM_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_FETCHRETURN
		
		--联盟战
		or serverData.type == QueueTypes.TYPE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKDOOR_RETURN
		or serverData.type == QueueTypes.TYPE_HAMMER_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKHAMMER_RETURN
		or serverData.type == QueueTypes.TYPE_CATAPULT_RETURN
		or serverData.type == QueueTypes.TYPE_LADDER_RETURN
		or serverData.type == QueueTypes.TYPE_CROSSBOW_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKDOOR_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKHAMMER_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_GOTO
		
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKDOOR_GOTO
		or serverData.type == QueueTypes.TYPE_HAMMER_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKHAMMER_GOTO
		or serverData.type == QueueTypes.TYPE_CATAPULT_GOTO
		or serverData.type == QueueTypes.TYPE_LADDER_GOTO
		or serverData.type == QueueTypes.TYPE_CROSSBOW_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_GOTO
		)
end


--是否是侦查类型模式
function isDetectType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_CITYSPY_GOTO
		or serverData.type == QueueTypes.TYPE_CITYSPY_RETURN
		or serverData.type == QueueTypes.TYPE_CATAPULTSPY_GOTO
		or serverData.type == QueueTypes.TYPE_CATAPULTSPY_RETURN
		)
end


--是否是拿取类型模式
function isFetchItemType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_FETCHITEM_GOTO
		or serverData.type == QueueTypes.TYPE_FETCHITEM_RETURN
		)
end


--是否是王城派出的NPC部队
function isKingCityOutNPC(serverData)
	return (
		serverData.type == QueueTypes.TYPE_KINGNPCATTACK_GOTO
		)
end


--是否是黄巾起义的NPC部队
function isHJNPC(serverData)
	return (
		serverData.type == QueueTypes.TYPE_HJNPCATTACK_GOTO
		)
end


--是否是需要马车出去的模式
function isPlayCarriageType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_COLLECT_GOTO
		or serverData.type == QueueTypes.TYPE_COLLECT_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_GOTO
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDTOWER_GOTO
		or serverData.type == QueueTypes.TYPE_GUILDTOWER_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_GOTO
		or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_FETCHGOTO
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_FETCHRETURN
		)
end	


--到达后有可能要播放攻击动画
function isCouldPossiblyPlayAttack(serverData)
	return (
		serverData.type == QueueTypes.TYPE_COLLECT_GOTO
		or serverData.type == QueueTypes.TYPE_NPCBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_GATHERBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_GUILDBASE_GOTO
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_GOTO
		or serverData.type == QueueTypes.TYPE_GUILDTOWER_GOTO
		or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_GOTO
		or serverData.type == QueueTypes.TYPE_KINGTOWN_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKBASEGATHER_GOTO
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_KINGNPCATTACK_GOTO
		or serverData.type == QueueTypes.TYPE_BOSSGATHER_GOTO
		or serverData.type == QueueTypes.TYPE_HJNPCATTACK_GOTO

		--联盟战
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKDOOR_GOTO
		or serverData.type == QueueTypes.TYPE_HAMMER_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKHAMMER_GOTO
		or serverData.type == QueueTypes.TYPE_CATAPULT_GOTO
		or serverData.type == QueueTypes.TYPE_LADDER_GOTO
		or serverData.type == QueueTypes.TYPE_CROSSBOW_GOTO
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_GOTO
		)
end


--变化后可能引起地图变化的类型
function isCouldPossiblyChangeMap(serverData)
	return (
		--联盟战
		serverData.type == QueueTypes.TYPE_HAMMER_ING
		or serverData.type == QueueTypes.TYPE_HAMMER_RETURN
		or serverData.type == QueueTypes.TYPE_CATAPULT_ING
		or serverData.type == QueueTypes.TYPE_CATAPULT_RETURN
		or serverData.type == QueueTypes.TYPE_CROSSBOW_ING
		or serverData.type == QueueTypes.TYPE_CROSSBOW_RETURN
		or serverData.type == QueueTypes.TYPE_LADDER_ING
		or serverData.type == QueueTypes.TYPE_LADDER_RETURN
		
		)
end


local function findQueueMapElement(map_id)
	if map_id then
		local d = require("game.mapguildwar.worldMapLayer_bigMap").getCurrentQueueDatas().MapElement[tostring(map_id)]
		if d then
			return g_data.map_element[d.map_element_id]
		end
	end
	return nil
end

--根据类型返回行动文字描述
function getQueueDesText(serverData)

	local ret = ""
	if serverData.type == QueueTypes.TYPE_RETURN 
		or serverData.type == QueueTypes.TYPE_COLLECT_RETURN
		or serverData.type == QueueTypes.TYPE_NPCBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYASSIST_RETURN
		or serverData.type == QueueTypes.TYPE_GATHER_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDBASE_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDTOWER_RETURN
		or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_RETURN
		or serverData.type == QueueTypes.TYPE_KINGTOWN_RETURN
		or serverData.type == QueueTypes.TYPE_DETECT_RETURN
		or serverData.type == QueueTypes.TYPE_FETCHITEM_RETURN
		
		--联盟战
		or serverData.type == QueueTypes.TYPE_RETURN
		or serverData.type == QueueTypes.TYPE_CITYBATTLE_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKDOOR_RETURN
		or serverData.type == QueueTypes.TYPE_HAMMER_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKHAMMER_RETURN
		or serverData.type == QueueTypes.TYPE_CATAPULT_RETURN
		or serverData.type == QueueTypes.TYPE_LADDER_RETURN
		or serverData.type == QueueTypes.TYPE_CROSSBOW_RETURN
		or serverData.type == QueueTypes.TYPE_ATTACKBASE_RETURN
		then
		ret = g_tr("queue_destext_back")
	elseif serverData.type == QueueTypes.TYPE_COLLECT_ING 
		or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_ING
		then
			local helperMD = require "game.mapguildwar.worldMapLayer_helper"
			local isStronghold = false
			local to_cf = findQueueMapElement(serverData.to_map_id)
			if to_cf and to_cf.origin_id == helperMD.m_MapOriginType.stronghold then
				isStronghold = true
			else
				local from_cf = findQueueMapElement(serverData.from_map_id)
				if from_cf and from_cf.origin_id == helperMD.m_MapOriginType.stronghold then
					isStronghold = true
				end
			end
			if isStronghold then
				ret = g_tr("queue_destext_stronghold")
			else
				ret = g_tr("queue_destext_collect")
			end
	elseif serverData.type == QueueTypes.TYPE_GUILDBASE_BUILD 
	or serverData.type == QueueTypes.TYPE_GUILDWAREHOUSE_BUILD
	or serverData.type == QueueTypes.TYPE_GUILDTOWER_BUILD
	or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_BUILD
		then
			ret = g_tr("queue_destext_build")
	elseif serverData.type == QueueTypes.TYPE_GUILDBASE_DEFEND
		or serverData.type == QueueTypes.TYPE_KINGTOWN_DEFENCE
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCE
		or serverData.type == QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCEASIST
		then
			ret = g_tr("queue_destext_defend")
	elseif serverData.type == QueueTypes.TYPE_GUILDBASE_REPAIR then
		ret = g_tr("queue_destext_repair")
	elseif serverData.type == QueueTypes.TYPE_CITYASSIST_ING then
		ret = g_tr("queue_destext_help")
	elseif serverData.type == QueueTypes.TYPE_DETECT_GOTO then
		ret = g_tr("queue_destext_detect")
	elseif serverData.type == QueueTypes.TYPE_FETCHITEM_GOTO then
		ret = g_tr("queue_destext_fetchItem")
	elseif serverData.type == QueueTypes.TYPE_HAMMER_ING then --占领攻城锤
		ret = g_tr("queue_destext_defend")
	elseif serverData.type == QueueTypes.TYPE_CATAPULT_ING then --占领投石车
		ret = g_tr("queue_destext_defend")
	elseif serverData.type == QueueTypes.TYPE_LADDER_ING then --占领云梯
		ret = g_tr("queue_destext_defend")
	elseif serverData.type == QueueTypes.TYPE_CROSSBOW_ING then --占领床弩
		ret = g_tr("queue_destext_defend")
	elseif isGatherFirstStageType(serverData) then
		ret = g_tr("queue_destext_gather")
	else
		ret = g_tr("queue_destext_runing")
	end
	return ret
end



--王大师专用，获取建造或修理时间
function getBuildOrRepairTime(x, y, origin_id)
	local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	local helper = require ("game.mapguildwar.worldMapLayer_helper")
	local queueType_1 , queueType_2 = nil , nil
	if origin_id == helper.m_MapOriginType.guild_fort then
		queueType_1 = QueueTypes.TYPE_GUILDBASE_BUILD
		queueType_2 = QueueTypes.TYPE_GUILDBASE_REPAIR
	elseif origin_id == helper.m_MapOriginType.guild_tower then
		queueType_1 = QueueTypes.TYPE_GUILDTOWER_BUILD
	elseif origin_id == helper.m_MapOriginType.guild_gold then
		queueType_1 = QueueTypes.TYPE_GUILDCOLLECT_BUILD
	elseif origin_id == helper.m_MapOriginType.guild_food then
		queueType_1 = QueueTypes.TYPE_GUILDCOLLECT_BUILD
	elseif origin_id == helper.m_MapOriginType.guild_wood then
		queueType_1 = QueueTypes.TYPE_GUILDCOLLECT_BUILD
	elseif origin_id == helper.m_MapOriginType.guild_stone then
		queueType_1 = QueueTypes.TYPE_GUILDCOLLECT_BUILD
	elseif origin_id == helper.m_MapOriginType.guild_iron then
		queueType_1 = QueueTypes.TYPE_GUILDCOLLECT_BUILD
	elseif origin_id == helper.m_MapOriginType.guild_cache then
		queueType_1 = QueueTypes.TYPE_GUILDWAREHOUSE_BUILD
	end
	if queueType_1 or queueType_2 then
		local currentQueueDatas = bigMap.getCurrentQueueDatas()
		for k , v in pairs(currentQueueDatas.Queue) do
			if v.to_x == x and v.to_y == y and ( (queueType_1 and v.type == queueType_1) or (queueType_2 and v.type == queueType_2) ) then
				return v.end_time
			end
		end
	end
	return nil
end

function getYunTiProgressTime(x, y, origin_id)
	local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	local helper = require ("game.mapguildwar.worldMapLayer_helper")
	local queueType = QueueTypes.TYPE_LADDER_ING
	
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		if v.to_x == x and v.to_y == y and v.type == queueType then
			return v.end_time
		end
	end

	return nil
end

return worldMapLayer_queueHelper