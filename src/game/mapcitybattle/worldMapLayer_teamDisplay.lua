local worldMapLayer_teamDisplay = {}
setmetatable(worldMapLayer_teamDisplay,{__index = _G})
setfenv(1,worldMapLayer_teamDisplay)

local HelperMD = require "game.mapcitybattle.worldMapLayer_helper"
local TeamRoleMD = require "game.mapcitybattle.worldMapLayer_teamRole"
local QueueHelperMD = require "game.mapcitybattle.worldMapLayer_queueHelper"


c_playAttackTime = 5 --sec 动画播放的时间

c_opacity_distance = 100


--侦查
function createDisplay_Detect(queueServerData, beginPosition, endPosition)
	
	local directionVector = cc.p(endPosition.x - beginPosition.x, endPosition.y - beginPosition.y)
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setContentSize(cc.size(1.0,1.0))	--不能为0
	ret:setPosition(cc.p(0,0))
	
	local display = TeamRoleMD.create_Horse()
	display:setPosition(cc.p(0,0))
	display:lua_play_run(directionVector)
	ret:addChild(display)
	
	return ret , cc.p(0,0)
end


local c_Formation_Carriage = {
	[1] = {
		position = cc.p(0.0, 30.0),
		createFunc = TeamRoleMD.create_Spear,
	},
	[2] = {
		position = cc.p(0.0, 0.0),
		createFunc = TeamRoleMD.create_ResourceCar,
	},
	[3] = {
		position = cc.p(0.0, -30.0),
		createFunc = TeamRoleMD.create_Spear,
	},
}
--采集
function createDisplay_Carriage(queueServerData, beginPosition, endPosition)
	local directionVector = cc.p(endPosition.x - beginPosition.x, endPosition.y - beginPosition.y)
	local angle = cToolsForLua:calc2VecAngle(1, 0, directionVector.x, directionVector.y)
	local sinAngle = math.sin(angle * 0.01745329252)
	local cosAngle = math.cos(angle * 0.01745329252)
	
	local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setContentSize(cc.size(1.0,1.0))	--不能为0
	ret:setPosition(cc.p(0,0))
	
	local displayTab = {} -- { display , position , }
	
	for k , v in ipairs(c_Formation_Carriage) do
		local tab = {}
		displayTab[(#displayTab) + 1] = tab
		
		tab.position = cc.p(v.position.x * cosAngle - v.position.y * sinAngle, v.position.y * cosAngle + v.position.x * sinAngle)
		tab.display = v.createFunc()	--创建
		tab.display:setPosition(tab.position)
		tab.display:lua_play_run(directionVector)
		ret:addChild(tab.display, 100000000 - math.floor(tab.position.y * 100))
	end
	
	if QueueHelperMD.isCouldPossiblyPlayAttack(queueServerData) then
		--有可能打斗的类型
		ret.lua_playAttack = function(targetBuildServerData, isWin)
			--这里扩散队伍进行打斗
			
			for k , v in ipairs(displayTab) do
				
				v.display:lua_play_attack_origin(directionVector, targetBuildServerData)
				
			end
			
		end
	end
	
	return ret , cc.p(0,0)
end


local c_Max_Team_Image_Size = cc.size(96.0, 74.0)

local c_First_Row_offset = -36.0

--士兵权重
local c_Troops_Weight = {
	[g_ArmyUnitMode.m_SoldierOriginType.infantry] = 1,	--步兵 86 86
	[g_ArmyUnitMode.m_SoldierOriginType.cavalry] = 2,	--骑兵 118	118
	[g_ArmyUnitMode.m_SoldierOriginType.archer] = 3,	--弓兵 86 86
	[g_ArmyUnitMode.m_SoldierOriginType.vehicles] = 4,	--投石车 46 78
}
--士兵创建
local c_Troops_Create = {
	[g_ArmyUnitMode.m_SoldierOriginType.infantry] = TeamRoleMD.create_Infantry,	--步兵 86 86
	[g_ArmyUnitMode.m_SoldierOriginType.cavalry] = TeamRoleMD.create_Cavalry,	--骑兵 118	118
	[g_ArmyUnitMode.m_SoldierOriginType.archer] = TeamRoleMD.create_Arrow,		--弓兵 86 86
	[g_ArmyUnitMode.m_SoldierOriginType.vehicles] = TeamRoleMD.create_Throw,	--投石车 46 78
}
--6队(数据队)
local c_Formation_6 = {
	[1] = cc.p(0.0, c_Max_Team_Image_Size.height * 0.5),
	[2] = cc.p(0.0, c_Max_Team_Image_Size.height * -0.5),
	
	[3] = cc.p(c_Max_Team_Image_Size.width * -1.0, c_Max_Team_Image_Size.height * 0.5),
	[4] = cc.p(c_Max_Team_Image_Size.width * -1.0, c_Max_Team_Image_Size.height * -0.5),
	
	[5] = cc.p(c_Max_Team_Image_Size.width * -2.0, c_Max_Team_Image_Size.height * 0.5),
	[6] = cc.p(c_Max_Team_Image_Size.width * -2.0, c_Max_Team_Image_Size.height * -0.5),
	
	centerY = 0.0,
}
--9队(固定队) 千万不能某一种近战或远战超过6个
local c_Formation_9 = {
	[1] = { position = cc.p(0.0, c_Max_Team_Image_Size.height), createFunc = TeamRoleMD.create_Infantry } ,
	[2] = { position = cc.p(0.0, 0.0), createFunc = TeamRoleMD.create_Infantry } ,
	[3] = { position = cc.p(0.0, c_Max_Team_Image_Size.height * -1.0), createFunc = TeamRoleMD.create_Infantry } ,
	
	[4] = { position = cc.p(c_Max_Team_Image_Size.width * -1.0, c_Max_Team_Image_Size.height), createFunc = TeamRoleMD.create_Arrow } ,
	[5] = { position = cc.p(c_Max_Team_Image_Size.width * -1.0, 0.0), createFunc = TeamRoleMD.create_Arrow } ,
	[6] = { position = cc.p(c_Max_Team_Image_Size.width * -1.0, c_Max_Team_Image_Size.height * -1.0), createFunc = TeamRoleMD.create_Arrow } ,
	
	[7] = { position = cc.p(c_Max_Team_Image_Size.width * -2.0, c_Max_Team_Image_Size.height), createFunc = TeamRoleMD.create_Throw } ,
	[8] = { position = cc.p(c_Max_Team_Image_Size.width * -2.0, 0.0), createFunc = TeamRoleMD.create_Throw } ,
	[9] = { position = cc.p(c_Max_Team_Image_Size.width * -2.0, c_Max_Team_Image_Size.height * -1.0), createFunc = TeamRoleMD.create_Throw } ,
	
	totalWidth = c_Max_Team_Image_Size.width * 2,
}
--部队
function createDisplay_Troops(queueServerData, beginPosition, endPosition)
	local directionVector = cc.p(endPosition.x - beginPosition.x, endPosition.y - beginPosition.y)
	local angle = cToolsForLua:calc2VecAngle(1, 0, directionVector.x, directionVector.y)
	local sinAngle = math.sin(angle * 0.01745329252)
	local cosAngle = math.cos(angle * 0.01745329252)
	
	local myPlayerData = g_cityBattlePlayerData.GetData()
	
	local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setContentSize(cc.size(1.0,1.0))	--不能为0
	ret:setPosition(cc.p(0,0))	
	
	local displayTab = {} -- { display , position , }
	local team_weight = 0
	
--[[	queueServerData.army_type = {}
	queueServerData.army_type[20001] = 1
	queueServerData.army_type[20002] = 2
	queueServerData.army_type[20003] = 2
	queueServerData.army_type[20004] = 3
	queueServerData.army_type[20005] = 4
	queueServerData.army_type[20006] = 1--]]
	
	local army_count = table.total(queueServerData.army_type)
	
	local near_count = 0	--几个近战
	local far_count = 0		--几个远战
	
	if QueueHelperMD.isGatherGotoType(queueServerData)
		or army_count == 0
			then
		--9队,无头像,全队
		for k , v in ipairs(c_Formation_9) do
			local tab = {}
			displayTab[(#displayTab) + 1] = tab
			tab.position = cc.p(v.position.x, v.position.y)
			tab.display = v.createFunc(nil, nil)
			if tab.display.lua_AttackType == "near" then
				near_count = near_count + 1
				tab.place_count = near_count
			elseif tab.display.lua_AttackType == "far" then
				far_count = far_count + 1
				tab.place_count = far_count
			end
		end
		team_weight = c_Formation_9.totalWidth
	else
		--6队,有头像,数据队
		local teamTab = {}
		for k , v in pairs(queueServerData.army_type) do
			teamTab[(#teamTab) + 1] = { general_original_id = tonumber(k) , soldierType = v }
		end
		local function sortFunc(a, b)
			return c_Troops_Weight[a.soldierType] < c_Troops_Weight[b.soldierType]
		end
		table.sort(teamTab, sortFunc)
		for k , v in ipairs(teamTab) do
			local tab = {}
			displayTab[(#displayTab) + 1] = tab
			tab.position = cc.p(c_Formation_6[k].x, c_Formation_6[k].y)
			if queueServerData.player_id == myPlayerData.player_id then
				tab.display = c_Troops_Create[v.soldierType](v.general_original_id, k % 2)
			else
				tab.display = c_Troops_Create[v.soldierType](v.general_original_id, nil)
			end
			if tab.display.lua_AttackType == "near" then
				near_count = near_count + 1
				tab.place_count = near_count
			elseif tab.display.lua_AttackType == "far" then
				far_count = far_count + 1
				tab.place_count = far_count
			end
		end
		if army_count % 2 ~= 0 then
			local tab = displayTab[#displayTab]
			tab.position.y = c_Formation_6.centerY
		end
		local tc = (#teamTab)
		if tc > 2 then
			local c = ((tc % 2 == 0) and tc or (tc + 1))
			team_weight = c_Max_Team_Image_Size.width * (c - 2) * 0.5
		end
	end
	
	--调整之后再加入
	for k , v in ipairs(displayTab) do
		v.position.x = v.position.x + team_weight * 0.5
		v.position = cc.p(v.position.x * cosAngle - v.position.y * sinAngle, v.position.y * cosAngle + v.position.x * sinAngle)
		v.display:setPosition(v.position)
		v.display:lua_play_run(directionVector)
		ret:addChild(v.display, 100000000 - math.floor(v.position.y * 100))
		v.display:setCascadeOpacityEnabled(true)
	end
	
	--触发结束
	local start_end = nil
	
	if queueServerData.player_id == myPlayerData.player_id 
		and queueServerData.from_x == myPlayerData.x 
		and queueServerData.from_y == myPlayerData.y 
		and queueServerData.create_time < g_clock.getCurServerTime() + 8
		then
		--自己的队伍 并且出发点为自己主城 并且出发在8秒以内
		
		start_end = function ()
			for k , v in ipairs(displayTab) do	
				v.display:setOpacity(255)
			end
			ret:unscheduleUpdate()
		end
		
		local origin_pos = cc.p(beginPosition.x, beginPosition.y)
		local origin_angle = ((angle < 0) and (360 + angle) or (angle))
		
		--更新刚出发的情况
		local function start_update(dt)
			local startComplete = true
			for k , v in ipairs(displayTab) do
				local mapPos = bigMap.worldPosition_2_position(cTools_NodeSpaceToWorld_position(v.display:getParent(), v.position))
				if mapPos then
					local dv = cc.p(mapPos.x - origin_pos.x, mapPos.y - origin_pos.y)
					local cur_angle = cToolsForLua:calc2VecAngle(1, 0, dv.x, dv.y)
					cur_angle = ((cur_angle < 0) and (360 + cur_angle) or (cur_angle))
					local sub_angle = origin_angle - cur_angle
					if (sub_angle < -90 and sub_angle > -270) or (sub_angle > 90 and  sub_angle < 270) then
						startComplete = false
						v.display:setOpacity(0)
					else
						local distance = math.sqrt( dv.x * dv.x + dv.y * dv.y )
						if distance < c_opacity_distance then
							startComplete = false
							v.display:setOpacity(255 / c_opacity_distance * distance)
						else
							v.display:setOpacity(255)
						end
					end
				end
			end
			if startComplete then
				ret:unscheduleUpdate()
			end
		end
		ret:scheduleUpdateWithPriorityLua(start_update, 0)
		
	end
	
	
	if QueueHelperMD.isCouldPossiblyPlayAttack(queueServerData) then
		--有可能打斗的类型
		ret.lua_playAttack = function(targetBuildServerData, isWin)
			if start_end then
				start_end()	--先关闭可能开着的出发更新
			end
			
			local targetPosition = cTools_worldToNodeSpace_position(ret, bigMap.position_2_worldPosition( HelperMD.buildServerData_2_buildCenterPosition(targetBuildServerData) ) )
			
			for k , v in ipairs(displayTab) do
				if v.display.lua_AttackType == "near" then
					--v.display:lua_play_attack_origin(directionVector, targetBuildServerData)
					v.display:lua_play_attack_move(targetPosition, targetBuildServerData, near_count - v.place_count + 1, angle + 180.0)
				elseif v.display.lua_AttackType == "far" then
					--v.display:lua_play_attack_origin(directionVector, targetBuildServerData)
					v.display:lua_play_attack_move(targetPosition, targetBuildServerData, far_count - v.place_count + 1, angle + 180.0)
				end
			end
			
		end
	end	
	
	--位置偏移
	local offsetPosition = cc.p(team_weight / 2 - c_First_Row_offset, 0)
	offsetPosition = cc.p((offsetPosition.x * cosAngle - offsetPosition.y * sinAngle) * -1.0, 
		(offsetPosition.y * cosAngle + offsetPosition.x * sinAngle) * -1.0)
		
	return ret , offsetPosition
end



--国王战王城发出的NPC部队
function createDisplay_KingCityOutNPC(queueServerData, beginPosition, endPosition)
	local directionVector = cc.p(endPosition.x - beginPosition.x, endPosition.y - beginPosition.y)
	
	local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setContentSize(cc.size(1.0,1.0))	--不能为0
	ret:setPosition(cc.p(0,0))
	
	local display = TeamRoleMD.create_KingCityOutNPC()
	display:setPosition(cc.p(0,0))
	display:lua_play_run(directionVector)
	ret:addChild(display)
	
	if QueueHelperMD.isCouldPossiblyPlayAttack(queueServerData) then
		--有可能打斗的类型
		ret.lua_playAttack = function(targetBuildServerData, isWin)
			
			display:lua_play_attack_origin(directionVector, targetBuildServerData)
			
		end
	end
	
	return ret , cc.p(0,0)
end


--黄巾起义的NPC部队
function createDisplay_HJNPC(queueServerData, beginPosition, endPosition)
	local directionVector = cc.p(endPosition.x - beginPosition.x, endPosition.y - beginPosition.y)
	
	local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setContentSize(cc.size(1.0,1.0))	--不能为0
	ret:setPosition(cc.p(0,0))
	
	local display = TeamRoleMD.create_HJNPC()
	display:setPosition(cc.p(0,0))
	display:lua_play_run(directionVector)
	ret:addChild(display)
	
	if QueueHelperMD.isCouldPossiblyPlayAttack(queueServerData) then
		--有可能打斗的类型
		ret.lua_playAttack = function(targetBuildServerData, isWin)
			
			display:lua_play_attack_origin(directionVector, targetBuildServerData)
			
		end
	end
	
	return ret , cc.p(0,0)
end

--城战部队
function createDisplay_CityBattle(queueServerData, beginPosition, endPosition)
	local directionVector = cc.p(endPosition.x - beginPosition.x, endPosition.y - beginPosition.y)
	
	local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setContentSize(cc.size(1.0,1.0))	--不能为0
	ret:setPosition(cc.p(0,0))
	
	local display = TeamRoleMD.create_CityBattle()
	display:setPosition(cc.p(0,0))
	display:lua_play_run(directionVector)
	ret:addChild(display)
	
	if QueueHelperMD.isCouldPossiblyPlayAttack(queueServerData) then
		--有可能打斗的类型
		ret.lua_playAttack = function(targetBuildServerData, isWin)
			
			display:lua_play_attack_origin(directionVector, targetBuildServerData)
			
		end
	end
	
	return ret , cc.p(0,0)
end




return worldMapLayer_teamDisplay