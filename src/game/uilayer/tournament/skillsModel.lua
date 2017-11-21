local skillsModel = {}
setmetatable(skillsModel,{__index = _G})
setfenv(1,skillsModel)

local helpModelMD = require("game.uilayer.tournament.helpModel")
local schedulerModelMD = require("game.uilayer.tournament.schedulerModel")

--武斗技能

local c_res_prefix = "tournament/skill/"

local c_res_suffix = ".ExportJson"

local c_attack_frame_event = "123"

local c_move_speed = 900.0

local c_actionName = {
	public = "Animation1",
	bei = "beimian",
	bei45 = "beiche",
	ce = "chemian",
	zheng45 = "zhengche",
	zheng = "zhengmian",
}

local c_actionDirection = {
	["0"] = { name = c_actionName.ce , s = 1.0 },
	["1"] = { name = c_actionName.bei45 , s = 1.0 },
	["2"] = { name = c_actionName.bei , s = 1.0 },
	["3"] = { name = c_actionName.bei45 , s = -1.0 },
	["4"] = { name = c_actionName.ce , s = -1.0 },
	["5"] = { name = c_actionName.zheng45 , s = -1.0 },
	["6"] = { name = c_actionName.zheng , s = 1.0 },
	["7"] = { name = c_actionName.zheng45 , s = 1.0 },
}

function createSkill(configID, startPos, targetPos, attackFrameCallback, hit, angle, minRange, maxRange)
	
	local configData = g_data.skillanims[configID]
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	ret:setContentSize(cc.size(1,1))
	schedulerModelMD.resetNodeSchedulerAndActionManage(ret)
	
	local mirrorNode = cc.Node:create()
	mirrorNode:ignoreAnchorPointForPosition(false)
	mirrorNode:setAnchorPoint(cc.p(0.5,0.5))
	mirrorNode:setContentSize(cc.size(1,1))
	mirrorNode:setPosition(cc.p(0.0,0.0))
	schedulerModelMD.resetNodeSchedulerAndActionManage(mirrorNode)
	ret:addChild(mirrorNode)
	
	local configInfo = {
		projName = configData.path, --"WD_Skill_FeiJian_Ballistic", "WD_Skill_QuanYiZhiJi_Dst",
		playMode = configData.play_type, 		-- 1：在启动位置播放，2：在目标位置播放，3：全屏中央播放，4：飞行特效
		actionMode = configData.anims_type, 	-- 1：不切面，2：切面
	}
	
	local target_pos = cc.p(targetPos.x, targetPos.y)
	if not hit then
		if configInfo.playMode == 2 
			or configInfo.playMode == 4 
			then
			local r = minRange + (maxRange - minRange) * 0.618
			target_pos.x = math.cos(angle * math.pi / 180) * r + startPos.x
			target_pos.y = math.sin(angle * math.pi / 180) * r + startPos.y
		end
	end
	
	local directionVec = cc.pSub(target_pos, startPos)
	local d = math.sqrt(directionVec.x * directionVec.x + directionVec.y * directionVec.y)
	
	local cbfunc = attackFrameCallback
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
			if configInfo.playMode ~= 4 then
				if cbfunc then
					if cToolsForLua:isDebugVersion() then
						g_airBox.show("警告：特效 "..configInfo.projName.." 没有攻击帧，默认将动画最后一帧作为攻击帧。", 2)
					end
					cbfunc = nil
					attackFrameCallback()
				end
				ret:removeFromParent()
			end
		elseif ccs.MovementEventType.start == eventType then
		end
	end
	local function onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
		if frameEventName == c_attack_frame_event then
			if configInfo.playMode ~= 4 then
				if cbfunc then
					cbfunc = nil
					attackFrameCallback()
				end
			end
		end
	end
	local armature , animation = g_gameTools.LoadCocosAni(c_res_prefix..configInfo.projName.."/"..configInfo.projName..c_res_suffix, configInfo.projName, onMovementEventCallFunc, onFrameEventCallFunc)
	schedulerModelMD.resetNodeSchedulerAndActionManage(armature)
	mirrorNode:addChild(armature)
	
	local loop = 0
	
	if configInfo.playMode == 1 then
		ret:setPosition(startPos)
	elseif configInfo.playMode == 2 then
		ret:setPosition(target_pos)
	elseif configInfo.playMode == 3 then
		ret:setPosition(helpModelMD.m_Center)
	elseif configInfo.playMode == 4 then
		loop = 1
		ret:setPosition(startPos)
		local function onMoveEnd()
			if cbfunc then
				cbfunc = nil
				attackFrameCallback()
			end
			ret:removeFromParent()
		end
		local d = math.sqrt(directionVec.x * directionVec.x + directionVec.y * directionVec.y)
		ret:runAction(cc.Sequence:create(cc.MoveTo:create(d / c_move_speed, target_pos), cc.CallFunc:create(onMoveEnd)))
	end
	
	if configInfo.actionMode == 1 then
		if animation:getAnimationData():getMovement(c_actionName.public) == nil then
			if cToolsForLua:isDebugVersion() then
				g_airBox.show("错误：特效 "..configInfo.projName.." 没有动作 "..c_actionName.public.." 默认将不播放。", 3)
			end
			if configInfo.playMode ~= 4 then
				local function onEnd()
					if cbfunc then
						cbfunc = nil
						attackFrameCallback()
					end
					ret:removeFromParent()
				end
				ret:runAction(cc.Sequence:create(cc.DelayTime:create(0.016), cc.CallFunc:create(onEnd)))
			end
		else
			animation:play(c_actionName.public, -1, loop)
		end
	elseif configInfo.actionMode == 2 then
		local angle = cToolsForLua:calc2VecAngle(1.0, 0.0, directionVec.x, directionVec.y)
		local v = (math.abs(angle) > 360) and math.mod(angle, 360) or angle
		v = ((v < 0) and (360 + v) or (v))
		v = math.floor(v + 22.5)
		v = math.mod(v, 360)
		local direction = math.floor((v) / 45)
		local action_name = c_actionDirection[tostring(direction)].name
		mirrorNode:setScaleX(c_actionDirection[tostring(direction)].s)
		if animation:getAnimationData():getMovement(action_name) == nil then
			if cToolsForLua:isDebugVersion() then
				g_airBox.show("错误：特效 "..configInfo.projName.." 没有动作 "..action_name.." 默认将不播放。", 3)
			end
			if configInfo.playMode ~= 4 then
				local function onEnd()
					if cbfunc then
						cbfunc = nil
						attackFrameCallback()
					end
					ret:removeFromParent()
				end
				ret:runAction(cc.Sequence:create(cc.DelayTime:create(0.016), cc.CallFunc:create(onEnd)))
			end
		else
			animation:play(action_name, -1, loop)
		end
	end
	
	
	return ret
end


function preSkill(configID)
	local configData = g_data.skillanims[configID]
	if configData then
		g_gameTools.preLoadCocosAni(c_res_prefix..configData.path.."/"..configData.path..c_res_suffix)
	end
end


return skillsModel