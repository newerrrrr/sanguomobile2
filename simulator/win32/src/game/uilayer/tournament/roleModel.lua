local roleModel = {}
setmetatable(roleModel,{__index = _G})
setfenv(1,roleModel)

local schedulerModelMD = require("game.uilayer.tournament.schedulerModel")
local helpModelMD = require("game.uilayer.tournament.helpModel")
local buffsModelMD = require("game.uilayer.tournament.buffsModel")

--武斗角色

local c_res_prefix = "tournament/role/"

local c_res_suffix = ".json"

local c_attack_frame_event = "123"

local c_move_speed = 150.0

local c_actionName = {
	bei = {
		standby = "beimian_daiji",
		move = "beimian_zou",
		blow = "beimian_shouji",
		death = "beimian_siwang",
		attack = "beimian_gongji",
		skill = "beimian_jineng",
	},
	bei45 = {
		standby = "beiche_daiji",
		move = "beiche_zou",
		blow = "beiche_shouji",
		death = "beiche_siwang",
		attack = "beiche_gongji",
		skill = "beiche_jineng",
	},
	ce = {
		standby = "chemian_daiji",
		move = "chemian_zou",
		blow = "chemian_shouji",
		death = "chemian_siwang",
		attack = "chemian_gongji",
		skill = "chemian_jineng",
	},
	zheng45 = {
		standby = "zhengche_daiji",
		move = "zhengche_zou",
		blow = "zhengche_shouji",
		death = "zhengche_siwang",
		attack = "zhengche_gongji",
		skill = "zhengche_jineng",
	},
	zheng = {
		standby = "zhengmian_daiji",
		move = "zhengmian_zou",
		blow = "zhengmian_shouji",
		death = "zhengmian_siwang",
		attack = "zhengmian_gongji",
		skill = "zhengmian_jineng",
	},
}


local c_tag_move_act = 15612345


function createRole(modelConfigID,place)
	
	local modelConfigData = g_data.generalanims[modelConfigID]
	
	local configInfo = {
		projNameA = modelConfigData.path_1,
        projNameB = modelConfigData.path_2,
	}
	
	local touchSize = cc.size(70, 120)
	
	local ret = cc.Node:create()
	ret:setCascadeOpacityEnabled(true)
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5, 0.0))
	ret:setContentSize(cc.size(touchSize.width, touchSize.height))
	schedulerModelMD.resetNodeSchedulerAndActionManage(ret)
	
	if cToolsForLua:isDebugVersion() then
		local drawNode = cc.DrawNode:create()
		drawNode:ignoreAnchorPointForPosition(false)
		drawNode:setContentSize(cc.size(1.0, 1.0))
		drawNode:setAnchorPoint(cc.p(0.0, 0.0))
		drawNode:setPosition(cc.p(touchSize.width * 0.5, 0.0))
		drawNode:drawCircle(cc.p(0.0,0.0), helpModelMD.m_RoleRadius, 0, 60, false, cc.c4f(1.0, 0.0, 1.0, 0.5))
		schedulerModelMD.resetNodeSchedulerAndActionManage(drawNode)
		ret:addChild(drawNode, 999999999)
	end
	
	local mirrorNode = cc.Node:create()
	mirrorNode:setCascadeOpacityEnabled(true)
	mirrorNode:ignoreAnchorPointForPosition(false)
	mirrorNode:setAnchorPoint(cc.p(0.5, 0.5))
	mirrorNode:setContentSize(cc.size(1, 1))
	mirrorNode:setPosition(cc.p(touchSize.width * 0.5, 0.0))
	schedulerModelMD.resetNodeSchedulerAndActionManage(mirrorNode)
	ret:addChild(mirrorNode, 1)
	
	local buffNode = cc.Node:create()
	buffNode:setCascadeOpacityEnabled(true)
	buffNode:ignoreAnchorPointForPosition(false)
	buffNode:setAnchorPoint(cc.p(0.5, 0.5))
	buffNode:setContentSize(cc.size(1, 1))
	buffNode:setPosition(cc.p(touchSize.width * 0.5, 0.0))
	schedulerModelMD.resetNodeSchedulerAndActionManage(buffNode)
	ret:addChild(buffNode, 2)
	buffNode.lua_buffIds = {}
	
	local effectNode = cc.Node:create()
	effectNode:setCascadeOpacityEnabled(true)
	effectNode:ignoreAnchorPointForPosition(false)
	effectNode:setAnchorPoint(cc.p(0.5, 0.5))
	effectNode:setContentSize(cc.size(1, 1))
	effectNode:setPosition(cc.p(touchSize.width * 0.5, 0.0))
	schedulerModelMD.resetNodeSchedulerAndActionManage(effectNode)
	ret:addChild(effectNode, 2)
	
    local projName = place == "A" and configInfo.projNameA or configInfo.projNameB
	
	local skeletonNode = sp.SkeletonAnimation:create(c_res_prefix..projName.."/"..projName..".json", c_res_prefix..projName.."/"..projName..".atlas", 1.0)
	schedulerModelMD.resetNodeSchedulerAndActionManage(skeletonNode)
	mirrorNode:addChild(skeletonNode)
	
	local status = {
		current_direction = nil,
		current_angle = nil,
		current_actionNames = nil,
		current_actionNameKey = nil,
		current_actionLoop = nil,
	}
	
	function ret.lua_checkTouchWorldPoint(worldPoint)
		return cc.rectContainsPoint(cc.rect(0,0,touchSize.width,touchSize.height),cTools_worldToNodeSpace_position(ret, worldPoint))		
	end
	
	local setRotation = ret.setRotation
	ret.setRotation = nil
	local getPositionX = ret.getPositionX
	ret.getPositionX = nil
	local getPositionY = ret.getPositionY
	ret.getPositionY = nil
	local setOpacity = ret.setOpacity
	ret.setOpacity = nil
	local setPosition = ret.setPosition
	ret.setPosition = nil
	
	function ret.lua_setOpacity(v)
		setOpacity(ret, v)
	end
	
	function ret.lua_setPosition(pos)
		ret:stopActionByTag(c_tag_move_act)
		setPosition(ret, pos)
	end
	
	function ret.lua_getPosition()
		return cc.p(getPositionX(ret), getPositionY(ret))
	end

	function ret.lua_setDirection(direction)
		if status.current_direction ~= direction then
			status.current_direction = direction
			if direction == 0 then
				status.current_actionNames = c_actionName.ce
				mirrorNode:setScaleX(1.0)
			elseif direction == 1 then
				status.current_actionNames = c_actionName.bei45
				mirrorNode:setScaleX(1.0)
			elseif direction == 2 then
				status.current_actionNames = c_actionName.bei
				mirrorNode:setScaleX(1.0)
			elseif direction == 3 then
				status.current_actionNames = c_actionName.bei45
				mirrorNode:setScaleX(-1.0)
			elseif direction == 4 then
				status.current_actionNames = c_actionName.ce
				mirrorNode:setScaleX(-1.0)
			elseif direction == 5 then
				status.current_actionNames = c_actionName.zheng45
				mirrorNode:setScaleX(-1.0)
			elseif direction == 6 then
				status.current_actionNames = c_actionName.zheng
				mirrorNode:setScaleX(1.0)
			elseif direction == 7 then
				status.current_actionNames = c_actionName.zheng45
				mirrorNode:setScaleX(1.0)
			end
			if status.current_actionNameKey then
				skeletonNode:setAnimation(0, status.current_actionNames[status.current_actionNameKey], status.current_actionLoop)	
			end
		end
	end
	
	function ret.lua_getDirection()
		return status.current_direction and status.current_direction or 0
	end
	
	function ret.lua_setRotation(angle)
		status.current_angle = angle
		local v = (math.abs(angle) > 360) and math.mod(angle, 360) or angle
		v = ((v < 0) and (360 + v) or (v))
		v = math.floor(v + 22.5)
		v = math.mod(v, 360)
		local direction = math.floor((v) / 45)
		ret.lua_setDirection(direction)
	end
	
	function ret.lua_getRotation()
		return status.current_angle and status.current_angle or 0
	end
	
	function ret.lua_Play_Standby(angle)
		if angle then
			status.current_actionNameKey = nil
			ret.lua_setRotation(angle)
		end
		status.current_actionLoop = true
		status.current_actionNameKey = "standby"
		skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_END)
		skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
		skeletonNode:setAnimation(0, status.current_actionNames.standby, status.current_actionLoop)
	end
	
	function ret.lua_Play_Move(angle)
		if angle then
			status.current_actionNameKey = nil
			ret.lua_setRotation(angle)
		end
		status.current_actionLoop = true
		status.current_actionNameKey = "move"
		skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_END)
		skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
		skeletonNode:setAnimation(0, status.current_actionNames.move, status.current_actionLoop)
	end
	
	function ret.lua_Play_Attack(angle, attackFrameCallback, endCallback)
		if angle then
			status.current_actionNameKey = nil
			ret.lua_setRotation(angle)
		end
		status.current_actionLoop = false
		status.current_actionNameKey = "attack"
		local cbfunc = attackFrameCallback
		local endfunc = endCallback
		local operate_name = status.current_actionNames.attack
		local function registerSpineFunction_end(event)
			if event.animation == operate_name then
				g_autoCallback.addCocosList(function () ret.lua_Play_Standby() end, 0.0)
				if cbfunc then
					cbfunc = nil
					g_autoCallback.addCocosList(attackFrameCallback, 0.0)
				end
				if endfunc then
					endfunc = nil
					g_autoCallback.addCocosList(endCallback, 0.0)
				end
			end
		end
		local function registerSpineFunction_event(event)
			if event.animation == operate_name then
				if event.eventData.name == c_attack_frame_event then
					if cbfunc then
						cbfunc = nil
						g_autoCallback.addCocosList(attackFrameCallback, 0.0)
					end
				end
			end
		end
		skeletonNode:registerSpineEventHandler(registerSpineFunction_end, sp.EventType.ANIMATION_END)
		skeletonNode:registerSpineEventHandler(registerSpineFunction_event, sp.EventType.ANIMATION_EVENT)
		skeletonNode:setAnimation(0, status.current_actionNames.attack, status.current_actionLoop)	
	end
	
	function ret.lua_Play_Skill(angle, attackFrameCallback, endCallback)
		if angle then
			status.current_actionNameKey = nil
			ret.lua_setRotation(angle)
		end
		status.current_actionLoop = false
		status.current_actionNameKey = "skill"
		local cbfunc = attackFrameCallback
		local endfunc = endCallback
		local operate_name = status.current_actionNames.skill
		local function registerSpineFunction_end(event)
			if event.animation == operate_name then
				g_autoCallback.addCocosList(function () ret.lua_Play_Standby() end, 0.0)
				if cbfunc then
					cbfunc = nil
					g_autoCallback.addCocosList(attackFrameCallback, 0.0)
				end
				if endfunc then
					endfunc = nil
					g_autoCallback.addCocosList(endCallback, 0.0)
				end
			end
		end
		local function registerSpineFunction_event(event)
			if event.animation == operate_name then
				if event.eventData.name == c_attack_frame_event then
					if cbfunc then
						cbfunc = nil
						g_autoCallback.addCocosList(attackFrameCallback, 0.0)
					end
				end
			end
		end
		skeletonNode:registerSpineEventHandler(registerSpineFunction_end, sp.EventType.ANIMATION_END)
		skeletonNode:registerSpineEventHandler(registerSpineFunction_event, sp.EventType.ANIMATION_EVENT)
		skeletonNode:setAnimation(0, status.current_actionNames.skill, status.current_actionLoop)	
	end
	
	function ret.lua_Play_Blow(angle, blowEndCallback, isPlayDeath, deathEndCallback)
		if angle then
			status.current_actionNameKey = nil
			ret.lua_setRotation(angle)
		end
		status.current_actionLoop = false
		status.current_actionNameKey = "blow"
		local cbfunc = blowEndCallback
		local operate_name = status.current_actionNames.blow
		local function registerSpineFunction_end(event)
			if event.animation == operate_name then
				if isPlayDeath then
					if cbfunc then
						cbfunc = nil
						g_autoCallback.addCocosList(blowEndCallback, 0.0)
					end
					g_autoCallback.addCocosList(function() ret.lua_Play_Death(angle, deathEndCallback) end, 0.0)
				else
					g_autoCallback.addCocosList(function () ret.lua_Play_Standby(angle) end, 0.0)
					if cbfunc then
						cbfunc = nil
						g_autoCallback.addCocosList(blowEndCallback, 0.0)
					end
				end
			end
		end
		skeletonNode:registerSpineEventHandler(registerSpineFunction_end, sp.EventType.ANIMATION_END)
		skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
		skeletonNode:setAnimation(0, status.current_actionNames.blow, status.current_actionLoop)	
	end
	
	function ret.lua_Play_Death(angle, endCallback)
		if angle then
			status.current_actionNameKey = nil
			ret.lua_setRotation(angle)
		end
		status.current_actionLoop = false
		status.current_actionNameKey = "death"
		local cbfunc = endCallback
		local operate_name = status.current_actionNames.death
		local function registerSpineFunction_end(event)
			if event.animation == operate_name then
				if cbfunc then
					cbfunc = nil
					g_autoCallback.addCocosList(endCallback, 0.0)
				end
			end
		end
		skeletonNode:registerSpineEventHandler(registerSpineFunction_end, sp.EventType.ANIMATION_END)
		skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
		skeletonNode:setAnimation(0, status.current_actionNames.death, status.current_actionLoop)
	end
	
	function ret.lua_MoveTo(target_pos, endCallback)
		ret:stopActionByTag(c_tag_move_act)
		local origin_pos = cc.p(ret:getPositionX(), ret:getPositionY())
		local directionVec = cc.pSub(target_pos, origin_pos)
		local d = math.sqrt(directionVec.x * directionVec.x + directionVec.y * directionVec.y)
		if d >= 1 then
			ret.lua_Play_Move(cToolsForLua:calc2VecAngle(1.0, 0.0, directionVec.x, directionVec.y))
			local function onMoveEnd()
				ret.lua_Play_Standby()
				if endCallback then
					endCallback()
				end
			end
			local act = cc.Sequence:create(cc.MoveTo:create(d / c_move_speed, target_pos), cc.CallFunc:create(onMoveEnd))
			act:setTag(c_tag_move_act)
			ret:runAction(act)
		else
			local function onMoveEnd()
				ret.lua_Play_Standby()
				if endCallback then
					endCallback()
				end
			end
			local act = cc.Sequence:create(cc.Place:create(target_pos), cc.CallFunc:create(onMoveEnd))
			act:setTag(c_tag_move_act)
			ret:runAction(act)
		end
	end
	
	
	local update_time_inv = 0.5
	function ret.lua_UpdateZOrder(dt)
		update_time_inv = update_time_inv - dt
		if update_time_inv <= 0.0 then
			update_time_inv = 0.5
			local c_z = ret:getLocalZOrder()
			local c_y = getPositionY(ret)
			local n_z = math.ceil(helpModelMD.m_DesignSize.height - c_y)
			if c_z ~= n_z then
				ret:setLocalZOrder(n_z)
			end
		end
	end
	
	function ret.lua_AddBuffDisplay(buffId)
		local idString = tostring(buffId)
		if buffNode.lua_buffIds[idString] == nil then
			local configData = g_data.duel_buff[tonumber(idString)]
			local displayBuff = buffsModelMD.createBuff(configData)
			buffNode.lua_buffIds[idString] = true
			helpModelMD.playSound(configData.buff_ae)
			buffNode:addChild(displayBuff, 1, idString)
		end
	end
	
	function ret.lua_RemoveBuffDisplay(buffId)
		local idString = tostring(buffId)
		buffNode.lua_buffIds[idString] = nil
		buffNode:removeChildByName(idString)
	end
	
	function ret.lua_RemoveAllBuffDisplay()
		for k , v in pairs(buffNode.lua_buffIds) do
			buffNode:removeChildByName(tostring(k))
		end
		buffNode.lua_buffIds = {}
	end
	
	--检测，多了删掉，少了补上
	function ret.lua_CheckBuffDisplay(buffs)
		for k , v in pairs(buffs) do
			if buffNode.lua_buffIds[tostring(k)] == nil then
				ret.lua_AddBuffDisplay(k)
			end
		end
		local t = {}
		for k , v in pairs(buffNode.lua_buffIds) do
			if buffs[tostring(k)] == nil then
				t[k] = true
			end
		end
		for k , v in pairs(t) do
			ret.lua_RemoveBuffDisplay(k)
		end
	end
	
	--播放被击特效
	function ret.lua_PlayHurtEffect()
		local function onMovementEventCallFunc(armature, eventType, name)
			if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
				armature:removeFromParent()
			end
		end
		local armature , animation = g_gameTools.LoadCocosAni("anime/WD_Skill_TongYongShouJi_Dst/WD_Skill_TongYongShouJi_Dst.ExportJson", "WD_Skill_TongYongShouJi_Dst", onMovementEventCallFunc, nil)
		schedulerModelMD.resetNodeSchedulerAndActionManage(armature)
		effectNode:addChild(armature)
		local index = math.random(1, 4)
		animation:play("Animation"..tostring(index))
	end
	
	--播放BUFF开场飘字
	function ret.lua_PlayBuffWind()
		local t = 0.0
		for k , v in pairs(buffNode.lua_buffIds) do
			local configData = g_data.duel_buff[tonumber(k)]
			if configData and configData.debuff_tips and configData.debuff_tips ~= 0 then
				local displayWind = buffsModelMD.createWind(configData, t)
				if displayWind then
					t = t + 0.5
					effectNode:addChild(displayWind, 1)
				end
			end
		end
	end
	
	
	ret.lua_Play_Standby(0) --初始化播放0度待机
	
	
	return ret
end


return roleModel