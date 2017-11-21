local guideNodes = {}
setmetatable(guideNodes,{__index = _G})
setfenv(1,guideNodes)

local GuideDrawMaskMD = require("game.guidelayer.guideDrawMask")
local GuideEventMaskMD = require("game.guidelayer.guideEventMask")
local GuideBasicEffectMD = require("game.guidelayer.guideBasicEffect")
local HelperMD = require "game.maplayer.worldMapLayer_helper"


--mask类型
m_MaskType = {
	circle = 1,		--圆形
	rect = 2,		--矩形
}

local c_offset_draw_rect = 24	--矩形渲染范围偏移量

local c_offset_logic = 2		--逻辑范围偏移量

local function _getNodeInWorldRect(node)
	local ret =  cc.rect(0,0,0,0)
	local size = node:getContentSize()
	local l_t = cTools_NodeSpaceToWorld_position( node, cc.p(0, size.height) )
	local l_b = cTools_NodeSpaceToWorld_position( node, cc.p(0, 0) )
	local r_b = cTools_NodeSpaceToWorld_position( node, cc.p(size.width, 0) )
	local r_t = cTools_NodeSpaceToWorld_position( node, cc.p(size.width, size.height))
	ret.x = math.min(l_t.x, l_b.x, r_b.x, r_t.x)
	ret.y = math.min(l_t.y, l_b.y, r_b.y, r_t.y)
	ret.width = math.max(l_t.x, l_b.x, r_b.x, r_t.x) - ret.x
	ret.height = math.max(l_t.y, l_b.y, r_b.y, r_t.y) - ret.y
	if ret.width >= c_offset_logic + 1 then
		ret.x = ret.x + c_offset_logic / 2
		ret.width = ret.width - c_offset_logic
	end
	if ret.height >= c_offset_logic + 1 then
		ret.y = ret.y + c_offset_logic / 2
		ret.height = ret.height - c_offset_logic
	end
	return ret
end

local function _getBigTileIndexInWorldRect(bigTileIndex)
	local bigMap = require("game.maplayer.worldMapLayer_bigMap")
	local positionCenter = nil
	local buildServerData = bigMap.getBuildServerData_originBigTileIndex(bigTileIndex)
	if buildServerData then
		positionCenter = HelperMD.buildServerData_2_buildCenterPosition(buildServerData)
	else
		positionCenter = HelperMD.bigTileIndex_2_positionCenter(bigTileIndex)
	end
	local worldPosition = bigMap.position_2_worldPosition(positionCenter)
	return cc.rect(worldPosition.x - HelperMD.m_SingleSizeHalf.width, worldPosition.y - HelperMD.m_SingleSizeHalf.height, HelperMD.m_SingleSize.width, HelperMD.m_SingleSize.height)
end

local function _closeTouchMoveEventdispatch()
	cc.Director:getInstance():getEventDispatcher():closeTouchMoveEventdispatch()
end

local function _openTouchMoveEventdispatch()
	cc.Director:getInstance():getEventDispatcher():openTouchMoveEventdispatch()
end



--public


--删除当前存在的引导节点
function guideNodes_clear()
	_openTouchMoveEventdispatch()
	g_sceneManager.clearAllNodeForGuideMask()
end


--创建点击某个节点的事件
--needClickNode 	需要点击的节点
--maskType			m_MaskType中的任意类型,不传默认为圆形
--clickCallback 	点击回调函数,可以不传.如果不传此参数就以节点实际的点击回调为准,如果传了此参数将不再向下分发事件,以点击位置响应此函数参数
--madCallback 		抓狂回调函数,可以不传.连续多次点击到无效区域时(全屏遮挡时任何地方都是无效区域),此函数将被调用(用以让玩家控制跳过引导之类的操作)
--haveTips 			当点错位置时,是否会出现提示,可以不传.默认是会出现
--isCloseTouchMove	是否关闭触摸移动事件,可以不传.默认是不关闭
--hideMask			是否隐藏mask,默认是false
--hideBasicEffect	是否隐藏basicEffect,默认是false
--basicEffectCircleRadius	基本圆形特效半径,默认随着点击区域变化
--handAngle			手指的角度,默认0
function guideNodes_create_with_needClickNode( needClickNode , maskType , clickCallback , madCallback , haveTips , isCloseTouchMove , hideMask , hideBasicEffect , basicEffectCircleRadius , handAngle)
	
	guideNodes_clear()
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	ret:setPosition(g_display.center)
	ret:setContentSize(g_display.size)
	
	ret:setUserObject(needClickNode) --save
	
	
	local drawMask = nil
	local basicEffect = nil
	if maskType == m_MaskType.circle then
		drawMask = GuideDrawMaskMD.createDrawMask_circle()
		basicEffect = GuideBasicEffectMD.createBasicEffect_circle()
	elseif maskType == m_MaskType.rect then
		drawMask = GuideDrawMaskMD.createDrawMask_rect()
		basicEffect = GuideBasicEffectMD.createBasicEffect_circle()
	else
		drawMask = GuideDrawMaskMD.createDrawMask_circle()
		basicEffect = GuideBasicEffectMD.createBasicEffect_circle()
	end
	ret:addChild(drawMask)
	ret:addChild(basicEffect)
	
	local enevtMask = GuideEventMaskMD.guideEventMask_create()
	ret:addChild(enevtMask)
	
	local handEffect = GuideBasicEffectMD.createGuideHandEffect()
	ret:addChild(handEffect)
	
	drawMask:lua_setHide(hideMask == true and true or false)
	
	basicEffect:setVisible((not hideBasicEffect) and true or false)
	
	if clickCallback then
		enevtMask:lua_setClickCallback( clickCallback )
	end
	
	if madCallback then
		enevtMask:lua_setMadCallback( madCallback )
	end
	
	if haveTips ~= false then
		local function onFailed()
			drawMask:lua_palyTips()
		end
		enevtMask:lua_setFailedCallback(onFailed)
	end
	
	local function update(dt)
		local drawRect = _getNodeInWorldRect(needClickNode)
		
		if maskType == m_MaskType.circle then
			drawMask:lua_update_show( cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), (drawRect.width + drawRect.height) * 0.55 )
			basicEffect:lua_update_show( cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), (basicEffectCircleRadius and basicEffectCircleRadius or ((drawRect.width + drawRect.height) * 0.55)) )
			handEffect:lua_update_show(cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), handAngle)
		elseif maskType == m_MaskType.rect then
			drawMask:lua_update_show( cc.rect(drawRect.x - c_offset_draw_rect / 2, drawRect.y - c_offset_draw_rect / 2, drawRect.width + c_offset_draw_rect, drawRect.height + c_offset_draw_rect) )
			basicEffect:lua_update_show(cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), (basicEffectCircleRadius and basicEffectCircleRadius or ((drawRect.width + drawRect.height) * 0.55)) )
			handEffect:lua_update_show(cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), handAngle)
		else
			drawMask:lua_update_show( cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), (drawRect.width + drawRect.height) * 0.55 )
			basicEffect:lua_update_show( cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2),  (basicEffectCircleRadius and basicEffectCircleRadius or ((drawRect.width + drawRect.height) * 0.55)) )
			handEffect:lua_update_show(cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), handAngle)
		end
		
		enevtMask:lua_setPassRect(drawRect)
	end
	ret:scheduleUpdateWithPriorityLua(update, 0)
	update(0.01666)
	
	g_sceneManager.addNodeForGuideMask(ret)
	
	if isCloseTouchMove == true then
		_closeTouchMoveEventdispatch()
	end
	
end


--创建点击某个野外大瓦片索引坐标的事件
--needBigTileIndex 	需要点击的大瓦片索引坐标
--clickCallback 	点击回调函数,可以不传.如果传了也只是在点击成功时调用,点中之后对地图状态的改变由本模块自动触发
--madCallback 		抓狂回调函数,可以不传.连续多次点击到无效区域时(全屏遮挡时任何地方都是无效区域),此函数将被调用(用以让玩家控制跳过引导之类的操作)
--haveTips 			当点错位置时,是否会出现提示,可以不传.默认是会出现
--hideMask			是否隐藏mask,默认是false
--hideBasicEffect	是否隐藏basicEffect,默认是false
--basicEffectCircleRadius	基本圆形特效半径,默认随着点击区域变化
--handAngle			手指的角度,默认0
function guideNodes_create_with_bigTileIndex( needBigTileIndex , clickCallback , madCallback , haveTips , hideMask , hideBasicEffect , basicEffectCircleRadius , handAngle)
	
	guideNodes_clear()
	
	local bigTileIndex = cc.p(needBigTileIndex.x, needBigTileIndex.y)
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	ret:setPosition(g_display.center)
	ret:setContentSize(g_display.size)
	
	local drawMask = GuideDrawMaskMD.createDrawMask_circle()
	ret:addChild(drawMask)
	
	local basicEffect = GuideBasicEffectMD.createBasicEffect_circle()
	ret:addChild(basicEffect)
	
	local enevtMask = GuideEventMaskMD.guideEventMask_create()
	ret:addChild(enevtMask)
	
	local handEffect = GuideBasicEffectMD.createGuideHandEffect()
	ret:addChild(handEffect)
	
	drawMask:lua_setHide(hideMask == true and true or false)
	
	basicEffect:setVisible((not hideBasicEffect) and true or false)
	
	local function onClick()
		require("game.maplayer.worldMapLayer_bigMap").onClickBigTileIndex_Simulation(bigTileIndex)
		if clickCallback then
			clickCallback()
		end
	end
	enevtMask:lua_setClickCallback( onClick )
	
	if madCallback then
		enevtMask:lua_setMadCallback( madCallback )
	end
	
	if haveTips ~= false then
		local function onFailed()
			drawMask:lua_palyTips()
		end
		enevtMask:lua_setFailedCallback(onFailed)
	end
	
	local isFirst = true
	
	local function update(dt)
		local changeMapScene = require("game.maplayer.changeMapScene")
		if changeMapScene.getCurrentMapStatus() ~= changeMapScene.m_MapEnum.world then
			changeMapScene.gotoWorld_BigTileIndex(bigTileIndex)
		elseif changeMapScene.isChanging() == false then
			if isFirst then
				isFirst = false
				require("game.maplayer.worldMapLayer_bigMap").changeBigTileIndex_Manual(bigTileIndex,true)
			else
				local drawRect = _getBigTileIndexInWorldRect(bigTileIndex)
				drawMask:lua_update_show( cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), (drawRect.width + drawRect.height) * 0.5 )
				basicEffect:lua_update_show( cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), (basicEffectCircleRadius and basicEffectCircleRadius or ((drawRect.width + drawRect.height) * 0.5)) )
				handEffect:lua_update_show(cc.p(drawRect.x + drawRect.width / 2, drawRect.y + drawRect.height / 2), handAngle)
				enevtMask:lua_setPassRect(drawRect)
			end
			return --这里返回
		end
		drawMask:lua_update_show(cc.p(0.0,0.0), 0.0)
		basicEffect:lua_update_show(cc.p(0.0,0.0), 0.0)
		handEffect:lua_update_show(cc.p(-999.0,-999.0), handAngle)
		enevtMask:lua_setPassNever()
	end
	ret:scheduleUpdateWithPriorityLua(update, 0)
	update(0.01666)
	
	g_sceneManager.addNodeForGuideMask(ret)
	
	_closeTouchMoveEventdispatch() --此引导必然阻止滑动
	
end


return guideNodes