local worldMapLayer_teamRuning = {}
setmetatable(worldMapLayer_teamRuning,{__index = _G})
setfenv(1,worldMapLayer_teamRuning)

local HelperMD = require "game.maplayer.worldMapLayer_helper"
local QueueHelperMD = require "game.maplayer.worldMapLayer_queueHelper"
local RequestTimeMD = require "game.maplayer.worldMapLayer_requestTime"
local TeamDisplayMD = require "game.maplayer.worldMapLayer_teamDisplay"
local BuildDisplayMD = require "game.maplayer.worldMapLayer_buildDisplay"

local k_QueueBattleEnum = {
	unknow = 0,				--无数据
	unHandle = 1,			--没处理
	notAttack = 2,			--没战斗
	win = 3,				--战斗胜利
	failed = 4,				--战斗失败
}

local c_ContentSize = cc.size(150,150)

local c_firstRequestWithinTime = 8 --第一次请求在多少时间内

local c_repeatRequestWithinTime = 8 --循环请求在多少时间内

local c_queryCanNotTime = 3 --每次发出查询请求的阻止网络请求时间


local function findQueueMapElement(map_id)
	if map_id then
		local d = require("game.maplayer.worldMapLayer_bigMap").getCurrentQueueDatas().MapElement[tostring(map_id)]
		if d then
			return g_data.map_element[d.map_element_id]
		end
	end
	return nil
end


--创建显示部分
local function _createDisplay(queueServerData, beginPosition, endPosition)
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setContentSize(cc.size(0,0))
	ret:setPosition(cc.p(c_ContentSize.width / 2, c_ContentSize.height / 2))

	local display , offsetPosition = nil , nil

	if QueueHelperMD.isDetectType(queueServerData) then
		--侦查类型(完全不会打架,也不可能是车出去)
		
		display , offsetPosition = TeamDisplayMD.createDisplay_Detect(queueServerData, beginPosition, endPosition)
		ret:addChild( display )
		
	elseif QueueHelperMD.isFetchItemType(queueServerData) then
		--拿取类型(完全不会打架,也不可能是车出去)
			
		display , offsetPosition = TeamDisplayMD.createDisplay_Detect(queueServerData, beginPosition, endPosition)
		ret:addChild( display )	
	
	else
		--非侦查类型
		
		if QueueHelperMD.isKingCityOutNPC(queueServerData) then
			--王城派出的NPC部队
			
			display , offsetPosition = TeamDisplayMD.createDisplay_KingCityOutNPC(queueServerData, beginPosition, endPosition)
			ret:addChild( display )
			ret.lua_playAttack = display.lua_playAttack --播放打斗函数
			
		elseif QueueHelperMD.isHJNPC(queueServerData) then
			--黄巾起义NPC部队
			
			display , offsetPosition = TeamDisplayMD.createDisplay_HJNPC(queueServerData, beginPosition, endPosition)
			ret:addChild( display )
			ret.lua_playAttack = display.lua_playAttack --播放打斗函数
			
		elseif QueueHelperMD.isPlayCarriageType(queueServerData) then
			--可能是马车出去
			
			local isStronghold = false
			local to_cf = findQueueMapElement(queueServerData.to_map_id)
			if to_cf and to_cf.origin_id == HelperMD.m_MapOriginType.stronghold then
				isStronghold = true
			else
				local from_cf = findQueueMapElement(queueServerData.from_map_id)
				if from_cf and from_cf.origin_id == HelperMD.m_MapOriginType.stronghold then
					isStronghold = true
				end
			end
			
			if isStronghold then
				--据点战部队出去
				
				display , offsetPosition = TeamDisplayMD.createDisplay_Troops(queueServerData, beginPosition, endPosition)
				ret:addChild( display )
				ret.lua_playAttack = display.lua_playAttack --播放打斗函数
				
			else
				--马车出去
				
				display , offsetPosition = TeamDisplayMD.createDisplay_Carriage(queueServerData, beginPosition, endPosition)
				ret:addChild( display )
				ret.lua_playAttack = display.lua_playAttack --播放打斗函数
				
			end
			
		else
			--部队出去
			
			display , offsetPosition = TeamDisplayMD.createDisplay_Troops(queueServerData, beginPosition, endPosition)
			ret:addChild( display )
			ret.lua_playAttack = display.lua_playAttack --播放打斗函数
			
		end
		
	end
	

	return ret , offsetPosition
end


--计算时间数据
local function _operatorTime(queueServerData)
	local ret = {
		--beginTime = nil,
		--endTime = nil,
	}
	ret.beginTime = queueServerData.create_time
	ret.endTime = queueServerData.end_time
	return ret
end


--是否需要延长请求时间
local function _opIsNeedRequestTimeExpand(myPlayerID, myGuildID , queueServerData, targetBuildServerData)
	return (
			queueServerData.player_id == myPlayerID 
			or (myGuildID ~= 0 and queueServerData.guild_id == myGuildID)
			or targetBuildServerData.player_id == myPlayerID
			or (myGuildID ~= 0 and targetBuildServerData.guild_id == myGuildID)
		)
end


--自己是否有子集结队伍在这个队伍中
local function _isSelfHaveQueueInQueue_queue(queueServerData, myPlayerID)
	local bigMap = require("game.maplayer.worldMapLayer_bigMap")
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		if v.player_id == myPlayerID and v.parent_queue_id == queueServerData.id then
			return v
		end
	end
	return nil
end


--是否需要播放攻击音效
local function _opIsNeedPlaySound(myPlayerID, queueServerData, targetBuildServerData)
	local ret = (
			queueServerData.player_id == myPlayerID 
			or targetBuildServerData.player_id == myPlayerID
		)
	if ret then
		return ret
	elseif QueueHelperMD.isGatherGotoType(queueServerData) then
		if _isSelfHaveQueueInQueue_queue(queueServerData, myPlayerID) then
			return true
		end
	end
	return false
end


--是否与自己完全相关
local function _opIsAboutMySelf(myPlayerID, queueServerData)
	return queueServerData.player_id == myPlayerID
end


--播放动态建筑反击动画
local function _playDynamicAttack(buildServerData, isWin, vec_back_attack)
	local tileData = require("game.maplayer.worldMapLayer_bigMap").getTileData_bigTileIndex(cc.p(buildServerData.x,buildServerData.y))
	if tileData then
		local build_id = tileData:getCustomName()
		if build_id and build_id ~= "" then
			local showNode = tileData:getShowNode()
			if showNode and showNode.lua_displayType == BuildDisplayMD.m_DisplayType.dynamic and showNode.lua_playAttack then
				showNode:lua_playAttack(isWin and BuildDisplayMD.m_BackType.death or BuildDisplayMD.m_BackType.standby)
				if showNode.lua_playAttackEffect then
					showNode:lua_playAttackEffect(vec_back_attack)
				end
			end
		end
	end
end


--行动队伍
function create_with_queueServerData(queueServerData, positionData)
	local retRootLayer = lhs.LHSOutNotVisitNode:create()
	retRootLayer:ignoreAnchorPointForPosition(false)
	retRootLayer:setAnchorPoint(cc.p(0.5,0.5))
	retRootLayer:setContentSize(c_ContentSize)	--不能为0
	retRootLayer:setVisibleOperat(true,cc.size(256,256))
	
	retRootLayer.lua_TouchEnable = true
	
	--反击向量
	local vec_back_attack = cc.pSub( positionData.beginPosition, positionData.endPosition )
	
	--显示
	local display , offsetPosition = _createDisplay(queueServerData, positionData.beginPosition, positionData.endPosition)
	retRootLayer:addChild(display)
	
	--时间数据
	local timeData = _operatorTime(queueServerData)
	
	--计算位置偏移函数
	local function opOffsetPosition(begin_time, end_time , current_time , begin_position , end_position)
		local tt = end_time - begin_time
		if tt <= 0.0167 or current_time >= end_time then
			return cc.p(end_position.x - begin_position.x, end_position.y - begin_position.y)
		else
			local ct = math.max(0, current_time - begin_time)
			return cc.p( (end_position.x - begin_position.x) / tt * ct, (end_position.y - begin_position.y) / tt * ct)
		end
	end
	
	--保存自己的玩家ID
	local myPlayerID = g_PlayerMode.GetData().id
	
	--保存自己的公会ID
	local myGuildID = g_AllianceMode.getGuildId()
	
	
	--战斗状态部分(有可能战斗时才有用)
	local battleStatusTab = {
		battleStatus = nil,
		postStatus = false,
		lastRequestTime = 0.0,
	}
	local function onRecvBattleStatus(result, msgData)
		battleStatusTab.postStatus = false
		if(result==true)then
			battleStatusTab.battleStatus = tonumber(msgData.battle)
		end
	end
	local function sendForBattle()
		battleStatusTab.postStatus = true
		battleStatusTab.lastRequestTime = socket.gettime()
		g_sgHttp.postData("map/queueBattleRet",{ queueId = queueServerData.id },onRecvBattleStatus,true)
	end
	
	local stopArrivalDoingUpdate = false
	local stopPositionUpdate = false
	
	--更新到达做的事
	local function updateArrival(current_time_real , current_time_unreal)
		if current_time_unreal >= timeData.endTime then
			--真实时间已经到了
			retRootLayer.lua_TouchEnable = false
			local subTime = current_time_real - timeData.endTime
			if display.lua_playAttack then
				--可能需要播放攻击动画
				local targetBuildServerData = require("game.maplayer.worldMapLayer_bigMap").getBuildServerData_originBigTileIndex(cc.p(queueServerData.to_x,queueServerData.to_y))
				if targetBuildServerData then
					
					if battleStatusTab.postStatus == false then ---没有在请求中
						
						local subTime = current_time_real - timeData.endTime
					
						if battleStatusTab.battleStatus == nil then 						    ------------------没请求过
							
							if subTime < c_firstRequestWithinTime then
								--c_firstRequestWithinTime秒内可以尝试请求
								if subTime >= g_Consts.BattleScriptDelayTime then
									sendForBattle()
									--发出请求后等待
									RequestTimeMD.CanNotRequestSecondsWithin(c_queryCanNotTime, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
								else
									--到第一次请求之间等待一下
									RequestTimeMD.CanNotRequestSecondsWithin(g_Consts.BattleScriptDelayTime - subTime + 0.1, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
								end
							else
								--大于第一次请求时机,无奈关闭
								stopArrivalDoingUpdate = true
								if _opIsAboutMySelf(myPlayerID, queueServerData) then
									--如果是自己的队列需要请求
									RequestTimeMD.RequestSecondsAfter(g_Consts.BattleScriptDelayTime, RequestTimeMD.m_Event_want.myQueueEnd)
								end
							end
							
						elseif battleStatusTab.battleStatus == k_QueueBattleEnum.unknow then	------------------无数据
						
							stopArrivalDoingUpdate = true
							if _opIsAboutMySelf(myPlayerID, queueServerData) then
								--如果是自己的队列需要请求
								RequestTimeMD.RequestSecondsAfter(g_Consts.BattleScriptDelayTime, RequestTimeMD.m_Event_want.myQueueEnd)
							end
							
						elseif battleStatusTab.battleStatus == k_QueueBattleEnum.unHandle then 	------------------没处理
						
							if subTime < c_repeatRequestWithinTime then
								--c_repeatRequestWithinTime秒内可以尝试请求
								if subTime >= g_Consts.BattleScriptDelayTime then
									if battleStatusTab.lastRequestTime + 0.75 < socket.gettime() then
										--尽量不要快速请求
										sendForBattle()
									end
									--发出请求后等待
									RequestTimeMD.CanNotRequestSecondsWithin(c_queryCanNotTime, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
								else
									--到第一次请求之间等待一下
									RequestTimeMD.CanNotRequestSecondsWithin(g_Consts.BattleScriptDelayTime - subTime + 0.1, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
								end
							else
								--大于请求时机,无奈关闭
								stopArrivalDoingUpdate = true
								if _opIsAboutMySelf(myPlayerID, queueServerData) then
									--如果是自己的队列需要请求
									RequestTimeMD.RequestSecondsAfter(g_Consts.BattleScriptDelayTime, RequestTimeMD.m_Event_want.myQueueEnd)
								end
							end
							
						elseif battleStatusTab.battleStatus == k_QueueBattleEnum.notAttack then	------------------没战斗
							
							stopArrivalDoingUpdate = true
							if _opIsAboutMySelf(myPlayerID, queueServerData) then
								--如果是自己的队列需要请求
								RequestTimeMD.RequestSecondsAfter(g_Consts.BattleScriptDelayTime, RequestTimeMD.m_Event_want.myQueueEnd)
							end
							
						elseif battleStatusTab.battleStatus == k_QueueBattleEnum.win then		------------------战斗胜利
							
							stopPositionUpdate = true
							retRootLayer:unscheduleUpdate()
							display.lua_playAttack(targetBuildServerData, true)
							_playDynamicAttack(targetBuildServerData, true, vec_back_attack)
							if queueServerData.player_id == myPlayerID then 
								--自己在战斗给结果提示
								g_autoCallback.addCocosList(function() g_airBox.show(g_tr("queue_battle_win")) end, TeamDisplayMD.c_playAttackTime)
							end
							if _opIsNeedPlaySound(myPlayerID, queueServerData, targetBuildServerData) then
								g_musicManager.playEffect(g_data.sounds[5000040].sounds_path)
							end
							if _opIsNeedRequestTimeExpand(myPlayerID, myGuildID, queueServerData, targetBuildServerData) then
								--如果与自己或自己公会相关的播放需要延迟请求时间
								RequestTimeMD.CanNotRequestSecondsWithin(TeamDisplayMD.c_playAttackTime, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
								RequestTimeMD.RequestSecondsAfter(TeamDisplayMD.c_playAttackTime + 0.35, RequestTimeMD.m_Event_want.myQueueEnd)
							end
							
						elseif battleStatusTab.battleStatus == k_QueueBattleEnum.failed then	------------------战斗失败
							
							stopPositionUpdate = true
							retRootLayer:unscheduleUpdate()
							display.lua_playAttack(targetBuildServerData, false)
							_playDynamicAttack(targetBuildServerData, false, vec_back_attack)
							if queueServerData.player_id == myPlayerID then 
								--自己在战斗给结果提示
								g_autoCallback.addCocosList(function() g_airBox.show(g_tr("queue_battle_lose")) end, TeamDisplayMD.c_playAttackTime)
							end
							if _opIsNeedPlaySound(myPlayerID, queueServerData, targetBuildServerData) then
								g_musicManager.playEffect(g_data.sounds[5000040].sounds_path)
							end
							if _opIsNeedRequestTimeExpand(myPlayerID, myGuildID, queueServerData, targetBuildServerData) then
								--如果与自己或自己公会相关的播放需要延迟请求时间
								RequestTimeMD.CanNotRequestSecondsWithin(TeamDisplayMD.c_playAttackTime, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
								RequestTimeMD.RequestSecondsAfter(TeamDisplayMD.c_playAttackTime + 0.35, RequestTimeMD.m_Event_want.myQueueEnd)
							end
							
						end
					end
				else
					--看不到目标的情况下
					stopArrivalDoingUpdate = true
					if _opIsAboutMySelf(myPlayerID, queueServerData) then
						--如果是自己的队列需要请求
						RequestTimeMD.RequestSecondsAfter(g_Consts.BattleScriptDelayTime, RequestTimeMD.m_Event_want.myQueueEnd)
					end
				end
			else--肯定没攻击动画
				stopArrivalDoingUpdate = true
				if _opIsAboutMySelf(myPlayerID, queueServerData) then
					--如果是自己的队列需要请求
					RequestTimeMD.RequestSecondsAfter(g_Consts.BattleScriptDelayTime, RequestTimeMD.m_Event_want.myQueueEnd)
				end
			end
		end
	end
	
	
	--更新位置
	local function updatePosition(current_time_real)
		local move_offset_time = g_Consts.BattleScriptDelayTime + ( queueServerData.accelerate_info.log and 0.05 or 0.5 )		
		local current_time_unreal_sub = math.max(math.min(timeData.endTime + move_offset_time, current_time_real), timeData.beginTime)
		if queueServerData.accelerate_info.log and _opIsAboutMySelf(myPlayerID, queueServerData) then
			--曾经使用过加速道具并且与自己有关的队列,走复杂运算
			--"accelerate_info":{"second":83 (origin 61) ,"log":[{"time":1451554165,"itemId":21701,"cutsecond":13},{"time":1451554168,"itemId":21701,"cutsecond":9}]}
			local begin_time = timeData.beginTime
			local end_time = timeData.beginTime + queueServerData.accelerate_info.second + move_offset_time --用原始到达时间开始计算
			local begin_position = cc.p(positionData.beginPosition.x, positionData.beginPosition.y)
			local end_position = cc.p(positionData.endPosition.x, positionData.endPosition.y)
			local current_position = cc.p(positionData.beginPosition.x, positionData.beginPosition.y)
			for k , v in ipairs(queueServerData.accelerate_info.log) do
				--移动量
				local offset_position = opOffsetPosition(begin_time, end_time, v.time, begin_position, end_position)
				--当前点向后推
				current_position = cc.pAdd(current_position, offset_position)
				--起始点向后推
				begin_position = cc.pAdd(begin_position, offset_position)
				--开始时间向后推
				begin_time = v.time
				--结束时间向前推
				end_time = end_time - v.cutsecond
			end
			retRootLayer:setPosition(cc.pAdd(cc.pAdd(current_position,  opOffsetPosition(begin_time, end_time, current_time_unreal_sub, begin_position, end_position)), offsetPosition))
		else
			--没有使用过加速道具或不是与自己相关的,全都走这种简单运算
			retRootLayer:setPosition(cc.pAdd(cc.pAdd(positionData.beginPosition, opOffsetPosition(timeData.beginTime, timeData.endTime + move_offset_time, current_time_unreal_sub , positionData.beginPosition, positionData.endPosition)), offsetPosition))
		end
	end
	
	
	
	--更新
	local function updateTeam(dt)
		
		local current_time_real = g_clock.getCurServerTimeMsecs()
		local current_time_unreal = math.max(math.min(timeData.endTime, current_time_real), timeData.beginTime)
		
		if not stopArrivalDoingUpdate then
			updateArrival(current_time_real, current_time_unreal)
		end
		
		if not stopPositionUpdate then
			updatePosition(current_time_real)
		end
		
	end
	retRootLayer:scheduleUpdateWithPriorityLua(updateTeam, 0)
	updateTeam(0.0166)
	
	
	do --触摸部分
		local function onTouchBegan(touch, event)
			if retRootLayer:isVisible() then
				return cc.rectContainsPoint(cc.rect(0,0,c_ContentSize.width,c_ContentSize.height),cTools_worldToNodeSpace_position(retRootLayer,touch:getLocation()))
			end
			return false
		end
		local function onTouchEnded(touch, event)
			if retRootLayer:isVisible() and cc.rectContainsPoint(cc.rect(0,0,c_ContentSize.width,c_ContentSize.height),cTools_worldToNodeSpace_position(retRootLayer,touch:getLocation())) then
				require "game.maplayer.worldMapLayer_bigMap".onClickTeam_queueServerData(queueServerData)
			end
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(true)
		touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		touchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener,retRootLayer)
	end
	
	
	return retRootLayer
end




return worldMapLayer_teamRuning