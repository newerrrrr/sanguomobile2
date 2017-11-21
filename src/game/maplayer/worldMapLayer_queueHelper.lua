local worldMapLayer_queueHelper = {}
setmetatable(worldMapLayer_queueHelper,{__index = _G})
setfenv(1,worldMapLayer_queueHelper)

QueueTypes = {
	TYPE_RETURN                = 1,--回城
	TYPE_COLLECT_GOTO          = 101,--去采集
	TYPE_COLLECT_ING           = 102,--采集中
	TYPE_COLLECT_RETURN        = 103,--采集返回
	TYPE_NPCBATTLE_GOTO        = 201,--去打野
	TYPE_BOSSGATHER_GOTO		 = 202,--集结去攻BOSS（发起方）
	TYPE_NPCBATTLE_RETURN      = 203,--打野返回
	TYPE_CITYBATTLE_GOTO       = 301,--去攻城
	TYPE_CITYBATTLE_RETURN     = 303,--攻城返回
	TYPE_CITYASSIST_GOTO       = 401,--去援助
	TYPE_CITYASSIST_ING        = 402,--援助中
	TYPE_CITYASSIST_RETURN     = 403,--援助返回
	TYPE_GATHER_WAIT           = 501,--集结中(发起方)
	TYPE_GATHERBATTLE_GOTO     = 502,--集结去攻城(发起方)
	TYPE_GATHER_GOTO           = 503,--集结中(援助方)去发起方家的路上
	TYPE_GATHER_STAY           = 504,--集结中(援助方)已经到发起方家
	TYPE_GATHERDBATTLE_GOTO    = 505,--集结去攻城(援助方)
	TYPE_GATHER_RETURN         = 506,--集结返回
	TYPE_GATHERD_MIDRETURN     = 507,--撤回集结者家
	TYPE_DETECT_GOTO           = 601,--侦查（去）
	TYPE_DETECT_RETURN         = 602,--侦查（返）
	TYPE_FETCHITEM_GOTO        = 603,--拿去物品（去）
	TYPE_FETCHITEM_RETURN      = 604,--拿去物品（返）
	TYPE_GUILDBASE_GOTO        = 701,--去堡垒
	TYPE_GUILDBASE_BUILD       = 702,--建造堡垒
	TYPE_GUILDBASE_REPAIR      = 703,--修理堡垒
	TYPE_GUILDBASE_RETURN      = 704,--堡垒返回
	TYPE_GUILDBASE_DEFEND      = 705,--驻守堡垒
	TYPE_GUILDWAREHOUSE_GOTO   = 706,--去联盟仓库
	TYPE_GUILDWAREHOUSE_RETURN = 707,--联盟仓库返回
	TYPE_GUILDWAREHOUSE_FETCHGOTO   = 729,--去联盟仓库存取
	TYPE_GUILDWAREHOUSE_FETCHRETURN = 730,--联盟仓库存取返回
	TYPE_GUILDWAREHOUSE_BUILD  = 708,--建造联盟仓库
	TYPE_GUILDTOWER_GOTO       = 709,--去联盟箭塔
	TYPE_GUILDTOWER_RETURN     = 710,--联盟箭塔返回
	TYPE_GUILDTOWER_BUILD      = 711,--建造联盟箭塔
	TYPE_GUILDCOLLECT_GOTO     = 712,--去联盟采集场
	TYPE_GUILDCOLLECT_RETURN   = 713,--联盟采集场返回
	TYPE_GUILDCOLLECT_BUILD    = 714,--建造联盟采集场
	TYPE_GUILDCOLLECT_ING      = 715,--联盟采集场采集
	TYPE_ATTACKBASE_GOTO       = 716,--去攻堡垒
	TYPE_ATTACKBASEGATHER_GOTO = 717,--集结去攻堡垒（发起方）
	TYPE_ATTACKBASE_RETURN     = 718,--攻堡垒回
	TYPE_KINGTOWN_GOTO		 = 720,--去王战城寨
	TYPE_KINGTOWN_DEFENCE		 = 721,--王战城寨驻防
	TYPE_KINGTOWN_RETURN		 = 722,--王战城寨回
	TYPE_KINGGATHERBATTLE_GOTO = 725,--集结去攻城寨(发起方)
	TYPE_KINGGATHERBATTLE_DEFENCE = 726,--王战城寨驻防(发起方)
	TYPE_KINGGATHERBATTLE_DEFENCEASIST = 727,--王战城寨驻防（援助方）
	TYPE_KINGNPCATTACK_GOTO 		= 728,--王战NPC去攻击
	TYPE_HJNPCATTACK_GOTO 		= 731,--黄巾起义NPC去攻击
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
		)
end


--是否是侦查类型模式
function isDetectType(serverData)
	return (
		serverData.type == QueueTypes.TYPE_DETECT_GOTO
		or serverData.type == QueueTypes.TYPE_DETECT_RETURN
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
		)
end


--变化后可能引起地图变化的类型
function isCouldPossiblyChangeMap(serverData)
	return (
		serverData.type == QueueTypes.TYPE_GUILDBASE_DEFEND
		or serverData.type == QueueTypes.TYPE_GUILDBASE_RETURN
		)
end


local function findQueueMapElement(map_id)
	if map_id then
		local d = require("game.maplayer.worldMapLayer_bigMap").getCurrentQueueDatas().MapElement[tostring(map_id)]
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
			then
		ret = g_tr("queue_destext_back")
	elseif serverData.type == QueueTypes.TYPE_COLLECT_ING 
			or serverData.type == QueueTypes.TYPE_GUILDCOLLECT_ING
				then
		local helperMD = require "game.maplayer.worldMapLayer_helper"
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
	elseif isGatherFirstStageType(serverData) then
		ret = g_tr("queue_destext_gather")
	else
		ret = g_tr("queue_destext_runing")
	end
	return ret
end



--王大师专用，获取建造或修理时间
function getBuildOrRepairTime(x, y, origin_id)
	local bigMap = require("game.maplayer.worldMapLayer_bigMap")
	local helper = require ("game.maplayer.worldMapLayer_helper")
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



return worldMapLayer_queueHelper