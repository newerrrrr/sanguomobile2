local buffsModel = {}
setmetatable(buffsModel,{__index = _G})
setfenv(1,buffsModel)

local schedulerModelMD = require("game.uilayer.tournament.schedulerModel")

--武斗buff

m_BuffType = {
	attackAdd = 1,		--攻击增加百分比
    fixed = 5,          --定身
    confusion = 6,      --混乱
    silence = 7,        --沉默
    dizzy = 8,			--眩晕
    diaoXue = 9,        --流血
	hurtSub = 10,		--承受伤害降低百分比
	wuliSub = 12,		--降低武力百分比
	reflectHurt = 15,	--反弹伤害百分比
    skillLess = 16,     --降低技能伤害百分比
    reduceHurt = 17,    --百分比掉血
    backFullSp = 18,    --恢复满技能点
    suckBlood = 20,     --吸血
    doubleHurt = 21,    --受到双倍伤害
    addMoveRange = 22,  --增加移动范围
    addAtkRange = 23,   --增加攻击范围
    mianSi = 24,        --免死
}


local c_res_prefix = "tournament/buff/"

local c_res_suffix = ".ExportJson"

local c_actionName = {
	public = "Animation1",
}

function createBuff(configData)
	
	local buffDisplayConfigData = g_data.buffanims[configData.buff_res]
	
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
		projName = buffDisplayConfigData.path,
	}
	
	local armature , animation = g_gameTools.LoadCocosAni(c_res_prefix..configInfo.projName.."/"..configInfo.projName..c_res_suffix, configInfo.projName, nil, nil)
	schedulerModelMD.resetNodeSchedulerAndActionManage(armature)
	mirrorNode:addChild(armature)
	
	if cToolsForLua:isDebugVersion() then
		if animation:getAnimationData():getMovement(c_actionName.public) == nil then
			g_airBox.show("错误：BUFF "..configInfo.projName.." 没有动作 "..c_actionName.public.." 默认将不播放。", 3)
		end
	end
	animation:play(c_actionName.public, -1, 1)
	
	return ret
end

function createWind(configData, waitTime)
	if configData.debuff_tips == 0 then
		return nil
	end
	
	local buffDisplayConfigData = g_data.buffanims[configData.debuff_tips]
	
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
		projName = buffDisplayConfigData.path,
	}
	
	local function onMovementEventCallFunc(armature, eventType, name)
		if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
			ret:removeFromParent()
		end
	end
	local armature , animation = g_gameTools.LoadCocosAni(c_res_prefix..configInfo.projName.."/"..configInfo.projName..c_res_suffix, configInfo.projName, onMovementEventCallFunc, nil)
	schedulerModelMD.resetNodeSchedulerAndActionManage(armature)
	mirrorNode:addChild(armature)
	
	if cToolsForLua:isDebugVersion() then
		if animation:getAnimationData():getMovement(c_actionName.public) == nil then
			g_airBox.show("错误：BUFF "..configInfo.projName.." 没有动作 "..c_actionName.public.." 默认将不播放。", 3)
		end
	end
	
	local function start()
		ret:setVisible(true)
		animation:play(c_actionName.public, -1, 1)
	end
	ret:setVisible(false)
	ret:runAction(cc.Sequence:create(cc.DelayTime:create(waitTime), cc.CallFunc:create(start)))
	
	return ret
end


return buffsModel