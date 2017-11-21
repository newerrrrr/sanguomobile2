local worldMapLayer_touchMask = {}
setmetatable(worldMapLayer_touchMask,{__index = _G})
setfenv(1,worldMapLayer_touchMask)

local HelperMD = require "game.mapguildwar.worldMapLayer_helper"


local function _createMaskAction()
	return cc.RepeatForever:create( cc.Sequence:create(cc.FadeTo:create(0.5,127), cc.FadeTo:create(0.5,255)) )
end

local function _createRemoveAction()
	return cc.Sequence:create(cc.DelayTime:create(1.5), cc.RemoveSelf:create())
end



--建筑
function create_building(buildServerData)
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setPosition(HelperMD.bigTileIndex_2_position(cc.p(buildServerData.x,buildServerData.y)))
	ret:setContentSize(cc.size(0,0))
	
	local configData = g_data.map_element[tonumber(buildServerData.map_element_id)]
	for k , v in ipairs(configData.x_y) do
		local touch_mask = cc.Sprite:createWithSpriteFrameName("worldmap_image_touch_mask.png")
		touch_mask:setAnchorPoint(cc.p(0,0))
		touch_mask:setPosition(HelperMD.oPosition_offsetBigTileIndex_2_nPosition(cc.p(0,0), cc.p(v[1], v[2])))
		touch_mask:runAction(_createMaskAction())
		ret:addChild(touch_mask)
	end
	
	return ret
end




--空地
function create_null(bigTileIndex)
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0,0))
	ret:setPosition(HelperMD.bigTileIndex_2_position(bigTileIndex))
	ret:setContentSize(cc.size(0,0))
	
	local touch_mask = cc.Sprite:createWithSpriteFrameName("worldmap_image_touch_mask.png")
	touch_mask:setAnchorPoint(cc.p(0,0))
	touch_mask:setPosition(cc.p(0,0))
	touch_mask:runAction(_createMaskAction())
	ret:addChild(touch_mask)
	
	return ret
end




--没菜单的部分(小怪,山水)参数二选一
function create_NoSmallMenu(buildServerData, bigTileIndex)
	local ret = cc.Node:create()
	if buildServerData then
		ret:ignoreAnchorPointForPosition(false)
		ret:setAnchorPoint(cc.p(0,0))
		ret:setPosition(HelperMD.bigTileIndex_2_position(cc.p(buildServerData.x,buildServerData.y)))
		ret:setContentSize(cc.size(0,0))
		local configData = g_data.map_element[tonumber(buildServerData.map_element_id)]
		for k , v in ipairs(configData.x_y) do
			local touch_mask = cc.Sprite:createWithSpriteFrameName("worldmap_image_touch_mask.png")
			touch_mask:setAnchorPoint(cc.p(0,0))
			touch_mask:setPosition(HelperMD.oPosition_offsetBigTileIndex_2_nPosition(cc.p(0,0), cc.p(v[1], v[2])))
			touch_mask:runAction(_createMaskAction())
			ret:addChild(touch_mask)
		end
	elseif bigTileIndex then
		ret:ignoreAnchorPointForPosition(false)
		ret:setAnchorPoint(cc.p(0,0))
		ret:setPosition(HelperMD.bigTileIndex_2_position(bigTileIndex))
		ret:setContentSize(cc.size(0,0))
		local touch_mask = cc.Sprite:createWithSpriteFrameName("worldmap_image_touch_mask.png")
		touch_mask:setAnchorPoint(cc.p(0,0))
		touch_mask:setPosition(cc.p(0,0))
		touch_mask:runAction(_createMaskAction())
		ret:addChild(touch_mask)
		touch_mask:setColor(cc.c3b(255, 0, 0))
	end
	ret:runAction(_createRemoveAction())
	return ret
end





return worldMapLayer_touchMask