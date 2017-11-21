local worldMapLayer_line = {}
setmetatable(worldMapLayer_line,{__index = _G})
setfenv(1,worldMapLayer_line)

local HelperMD = require "game.maplayer.worldMapLayer_helper"
local QueueHelperMD = require "game.maplayer.worldMapLayer_queueHelper"

local c_image_size = nil
local c_speed = 80 -- 1 sec

local c_line_res_path = {
	[1] = "worldmap/notPlist/line1.png",	--白
	[2] = "worldmap/notPlist/line2.png",	--绿
	[3] = "worldmap/notPlist/line3.png",	--蓝
	[4] = "worldmap/notPlist/line4.png",	--红
	[5] = "worldmap/notPlist/line5.png",	--黄
}


--得到线段应该有的颜色
local function _getLineColorType( serverData )
	
	local bigMap = require("game.maplayer.worldMapLayer_bigMap")
	
	local to_map_data = nil
	if serverData.to_map_id ~= 0 then
		to_map_data = bigMap.getCurrentQueueDatas().MapElement[tostring(serverData.to_map_id)]
	end
	
	local color = 1
	
	local playerData = g_PlayerMode.GetData()
	
	if serverData.player_id ~= 0 then
		
		if playerData.id == serverData.player_id then
			--我
			color = (QueueHelperMD.isGatherType(serverData) and not QueueHelperMD.isGatherReturnType(serverData)) and 5 or 2
		else
			--别人
			if serverData.guild_id ~= 0 then
				if g_AllianceMode.getGuildId() == serverData.guild_id then
					--自己公会（盟友）
					color = (QueueHelperMD.isGatherType(serverData) and not QueueHelperMD.isGatherReturnType(serverData)) and 5 or 3
				else
					--别人公会
					if to_map_data and ((to_map_data.guild_id ~= 0 and to_map_data.guild_id == g_AllianceMode.getGuildId()) or to_map_data.player_id == playerData.id) then
						color = 4
					elseif serverData.to_x == playerData.x and serverData.to_y == playerData.y then
						color = 4
					else
						color = (QueueHelperMD.isGatherType(serverData) and not QueueHelperMD.isGatherReturnType(serverData)) and 5 or 1
					end
				end
			else
				--没公会
				if to_map_data and ((to_map_data.guild_id ~= 0 and to_map_data.guild_id == g_AllianceMode.getGuildId()) or to_map_data.player_id == playerData.id) then
					color = 4
				elseif serverData.to_x == playerData.x and serverData.to_y == playerData.y then
					color = 4
				else
					color = (QueueHelperMD.isGatherType(serverData) and not QueueHelperMD.isGatherReturnType(serverData)) and 5 or 1
				end
			end
		end
	else
		--没玩家ID 可能是NPC
		if to_map_data and ((to_map_data.guild_id ~= 0 and to_map_data.guild_id == g_AllianceMode.getGuildId()) or to_map_data.player_id == playerData.id) then
			color = 4
		elseif serverData.to_x == playerData.x and serverData.to_y == playerData.y then
			color = 4
		else
			color = (QueueHelperMD.isGatherType(serverData) and not QueueHelperMD.isGatherReturnType(serverData)) and 5 or 1
		end
	end
	
	return color
end


--创建
function create_with_queueServerData( queueServerData , positionData )

	if c_image_size == nil then
		c_image_size = cc.Director:getInstance():getTextureCache():addImage(c_line_res_path[1]):getContentSize()
	end

	--先得到颜色类型
	local colorType = _getLineColorType(queueServerData)

	local resPath = c_line_res_path[(colorType and colorType or 1)]

	local clipNode = cc.ClippingNode:create()
	clipNode:ignoreAnchorPointForPosition(false)
	clipNode:setAnchorPoint(cc.p(0.0,0.0))
	clipNode:setPosition(cc.p(0.0,0.0))
	clipNode:setContentSize(cc.size(0.0,0.0))
	clipNode:setInverted(false)
	
	local stencil = cc.Node:create()
	stencil:ignoreAnchorPointForPosition(false)
	stencil:setAnchorPoint(cc.p(0.0,0.0))
	stencil:setPosition(cc.p(0.0,0.0))
	stencil:setContentSize(cc.size(0.0,0.0))
	clipNode:setStencil(stencil)
	
	local lineNode = cc.SpriteBatchNode:create(resPath)
	lineNode:ignoreAnchorPointForPosition(false)
	lineNode:setAnchorPoint(cc.p(0.0,0.0))
	lineNode:setPosition(cc.p(0.0,0.0))
	lineNode:setContentSize(cc.size(0.0,0.0))
	clipNode:addChild(lineNode,1)

	do
		local fill = cc.Sprite:create(resPath)
		fill:setAnchorPoint(cc.p(0.0,0.5))
		fill:setPosition(cc.p(c_image_size.width * -1.0,0.0))
		lineNode:addChild(fill)
	end
	
	local distanceVec = cc.p( positionData.endPosition.x - positionData.beginPosition.x, positionData.endPosition.y - positionData.beginPosition.y )
	
	local distance = math.floor( math.sqrt( distanceVec.x * distanceVec.x + distanceVec.y * distanceVec.y ) )
	
	local angle = cToolsForLua:calc2VecAngle(1,0,distanceVec.x,distanceVec.y)
	
	clipNode:setPosition( positionData.beginPosition )
	clipNode:setRotation( angle * -1 )
	
	local origin_position = cc.p(0.0, c_image_size.height * -0.5)
	local target_position = cc.p(c_image_size.width, c_image_size.height * 0.5)
	
	local offsetX = 0
	
	--整段
	local fullCount = math.floor (distance / c_image_size.width)
	
	for i = 1 , fullCount , 1 do
		local sp = cc.Sprite:create(resPath)
		sp:setAnchorPoint(cc.p(0.0,0.5))
		sp:setPosition(cc.p(offsetX,0.0))
		lineNode:addChild(sp)
		
		local drawStencil = cc.DrawNode:create()
		drawStencil:setPosition(cc.p(offsetX,0.0))
		drawStencil:drawSolidRect(origin_position, target_position, cc.c4f(0.0,0.0,0.0,1.0))
		stencil:addChild(drawStencil)
		
		offsetX = offsetX + c_image_size.width
	end
	
	--零头
	local modDistance = distance % c_image_size.width
	--modDistance = modDistance - modDistance % 一对脚印长
	
	local lastSprite = cc.Sprite:create(resPath)
	local textureRect = lastSprite:getTextureRect()
	textureRect.width = modDistance
	lastSprite:setTextureRect(textureRect)
	lastSprite:setAnchorPoint(cc.p(0.0,0.5))
	lastSprite:setPosition(cc.p(offsetX,0.0))
	lineNode:addChild(lastSprite)
	
	local lastDrawStencil = cc.DrawNode:create()
	lastDrawStencil:setPosition(cc.p(offsetX,0.0))
	lastDrawStencil:drawSolidRect(origin_position, cc.p(modDistance, target_position.y),cc.c4f(0.0,0.0,0.0,1.0))
	stencil:addChild(lastDrawStencil)
	
	--offsetX = offsetX + modDistance
	
	local action = cc.RepeatForever:create( cc.Sequence:create( cc.MoveTo:create(c_image_size.width / c_speed , cc.p(c_image_size.width,0) ) , cc.Place:create(cc.p(0,0)) ) )
	lineNode:runAction(action)
	
	return clipNode
end




return worldMapLayer_line