local worldMapLayer_inputMenu = {}
setmetatable(worldMapLayer_inputMenu,{__index = _G})
setfenv(1,worldMapLayer_inputMenu)

local HelperMD = require "game.mapguildwar.worldMapLayer_helper"

local c_move_city_item_id = 21300
local c_move_city_gem_count = 1000

local m_MenuMode = {
	move_city = 1,
	build = 2,
	invite = 3,
}

--创建迁城
function create_move_city(map_element_id, bigTileIndex, callbackOK, callbackCancle)
	return create(map_element_id, bigTileIndex, callbackOK, callbackCancle, m_MenuMode.move_city)
end


--创建建造
function create_build(map_element_id, bigTileIndex, callbackOK, callbackCancle)
	return create(map_element_id, bigTileIndex, callbackOK, callbackCancle, m_MenuMode.build)
end


--创建邀请
function create_invite(map_element_id, bigTileIndex, callbackOK, callbackCancle)
	return create(map_element_id, bigTileIndex, callbackOK, callbackCancle, m_MenuMode.invite)
end



--索引 转换到 坐标
function bti_2_pos(bti, contentSize, tileTotalCount)
	return cc.p( math.floor( bti.x * HelperMD.m_SingleSizeHalf.width + (tileTotalCount.height - (bti.y + 1)) * HelperMD.m_SingleSizeHalf.width )
		, math.floor( contentSize.height - (HelperMD.m_SingleSize.height + bti.y * HelperMD.m_SingleSizeHalf.height + bti.x * HelperMD.m_SingleSizeHalf.height) ) )	
end


--建造其他建筑(没有动画的建筑物)
function create(map_element_id, bigTileIndex, callbackOK, callbackCancle, tp)
	
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	local position = HelperMD.bigTileIndex_2_positionCenter(bigTileIndex)
	ret:setPosition(position)
	
	local configData = g_data.map_element[tonumber(map_element_id)]
	
	local count = #(configData.x_y) --此版本建筑物只有占1,4,9,16格的而已
	
	local contentSize = nil
	local anchorPoint = nil
	local originIndex = nil
	local tileTotalCount = nil

	if count == 4 then
		contentSize = cc.size(HelperMD.m_SingleSize.width * 2, HelperMD.m_SingleSize.height * 2)
		originIndex = cc.p(1, 1)
		tileTotalCount = cc.size(2, 2)
		anchorPoint = cc.p(0.5,0.25)
	elseif count == 9 then
		contentSize = cc.size(HelperMD.m_SingleSize.width * 3, HelperMD.m_SingleSize.height * 3)
		originIndex = cc.p(2, 2)
		tileTotalCount = cc.size(3, 3)
		anchorPoint = cc.p(0.5,0.125)
	elseif count == 16 then
		contentSize = cc.size(HelperMD.m_SingleSize.width * 4, HelperMD.m_SingleSize.height * 4)
		originIndex = cc.p(3, 3)
		tileTotalCount = cc.size(4, 4)
		anchorPoint = cc.p(0.5,0.125)
	else
		contentSize = cc.size(HelperMD.m_SingleSize.width, HelperMD.m_SingleSize.height)
		originIndex = cc.p(0, 0)
		tileTotalCount = cc.size(1, 1)
		anchorPoint = cc.p(0.5,0.5)
	end
	
	ret:setContentSize(contentSize)	--不能为0
	ret:setAnchorPoint(anchorPoint)
	
	local isCanBuild = true
	
	local widget_buttons = cc.CSLoader:createNode("worldMap_03.csb")
	
	local panel_3 = widget_buttons:getChildByName("Panel_3")
	
	widget_buttons:setRotation3D( cc.vec3(HelperMD.m_Angle * -1,0.0,0.0) )
	widget_buttons:setPosition(cc.p(contentSize.width / 2,0))
	ret:addChild(widget_buttons, 3)
	local function onBottonCancle(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			require "game.mapguildwar.worldMapLayer_bigMap".closeInputMenu()
			if callbackCancle and type(callbackCancle) == "function" then
				callbackCancle()
			end
		end
	end
	widget_buttons:getChildByName("Button_1"):addTouchEventListener(onBottonCancle)
	widget_buttons:getChildByName("Button_1"):getChildByName("Text_1"):setString(g_tr("worldmap_build_menu_button_Cancle"))
	local button_ok = widget_buttons:getChildByName("Button_2")
	local function onBottonOK(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if isCanBuild == true then
				local function onFinish()
					local position = cc.p(ret:getPositionX(), ret:getPositionY())
					require "game.mapguildwar.worldMapLayer_bigMap".closeInputMenu()
					if callbackOK and type(callbackOK) == "function" then
						callbackOK(HelperMD.position_2_bigTileIndex(position))
					end
				end
				if tp == m_MenuMode.move_city then
					if g_gameTools.canUseUnionMoveCity(HelperMD.position_2_bigTileIndex(cc.p(ret:getPositionX(), ret:getPositionY()))) then
						onFinish()
					else
						local count = g_BagMode.findItemNumberById(c_move_city_item_id)
						if count > 0 then
							onFinish()
						else
							local function onBuyMoveCity( c )
								onFinish()
							end
							g_msgBox.showConsume(c_move_city_gem_count, g_tr("worldmap_build_menu_move_consumption_tip",{cnt = c_move_city_gem_count}), nil, nil, onBuyMoveCity)
						end
					end
				elseif tp == m_MenuMode.build then
					onFinish()
				elseif tp == m_MenuMode.invite then
					onFinish()
				end
			else
				button_ok:setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
			end
		end
	end
	button_ok:addTouchEventListener(onBottonOK)
	if tp == m_MenuMode.move_city then
		panel_3:setVisible(false)
		button_ok:getChildByName("Text_1"):setVisible(false)
		panel_3:getChildByName("Text_1_0"):setString(g_tr("worldmap_build_menu_button_OK_MC"))
	elseif tp == m_MenuMode.build then
		panel_3:setVisible(false)
		button_ok:getChildByName("Text_1"):setVisible(true)
		button_ok:getChildByName("Text_1"):setString(g_tr("worldmap_build_menu_button_OK_BD"))
	elseif tp == m_MenuMode.invite then
		panel_3:setVisible(false)
		button_ok:getChildByName("Text_1"):setVisible(true)
		button_ok:getChildByName("Text_1"):setString(g_tr("worldmap_build_menu_button_OK_IV"))
	end

	local s_l = contentSize.width * anchorPoint.x
	local s_r = contentSize.width * (1.0 - anchorPoint.x)
	local s_d = contentSize.height * anchorPoint.y
	local s_t = contentSize.height * (1.0 - anchorPoint.y)
	
	local parallelogram = {
			posT = cc.p(contentSize.width / 2, contentSize.height),
			posL = cc.p(0, contentSize.height / 2),
			posB = cc.p(contentSize.width / 2, 0),
			posR = cc.p(contentSize.width, contentSize.height / 2),
		}
	
	local mask_array = {}
	
	local mask_single_size = nil
	
	for k , v in ipairs(configData.x_y) do
		local pos = bti_2_pos(cc.p(originIndex.x + v[1], originIndex.y + v[2]), contentSize, tileTotalCount)
		local input_mask = cc.Sprite:createWithSpriteFrameName("worldmap_image_input_mask.png")
		if mask_single_size == nil then
			mask_single_size = input_mask:getContentSize()
		end
		input_mask:setAnchorPoint(cc.p(0.0,0.0))
		input_mask:setPosition(pos)
		ret:addChild(input_mask,1)
		mask_array[(#(mask_array)) + 1] = input_mask
		
		local sprite = cc.Sprite:createWithSpriteFrameName(g_data.sprite[configData.img[k]].path)
		sprite:setAnchorPoint(cc.p(0.0,0.0))
		sprite:setPosition(pos)
		sprite:setOpacity(127)
		ret:addChild(sprite,2)
	end
	
	local function checkMask_color()
		if mask_single_size then
			isCanBuild = true
			local playerData = g_guildWarPlayerData.GetData()
			local bti = HelperMD.position_2_bigTileIndex(cc.p(ret:getPositionX(), ret:getPositionY()))
			local c_p = cc.p(mask_single_size.width / 2, mask_single_size.height / 2)
			for k , v in ipairs(mask_array) do
				local w_p = cTools_NodeSpaceToWorld_position(v, c_p)
				if w_p then
					local tileData = require("game.mapguildwar.worldMapLayer_bigMap").getTileData_WorldPosition(w_p)
					if tileData then
						if tp == m_MenuMode.move_city then
							--迁城时自己的主城忽略判定
							local build_id = tileData:getCustomName()
							if build_id and build_id ~= "" then
								local serverData = require("game.mapguildwar.worldMapLayer_bigMap").getCurrentAreaDatas().Map[build_id]
								if serverData == nil 
									or serverData.map_element_origin_id ~= HelperMD.m_MapOriginType.player_home 
									or tonumber(playerData.player_id) ~= tonumber(serverData.player_id) 
									or (bti.x == playerData.x and bti.y == playerData.y)
										then
									isCanBuild = false
									v:setColor(cc.c3b(255,0,0))
								else
									v:setColor(cc.c3b(0,255,0))
								end
							else
								isCanBuild = false
								v:setColor(cc.c3b(255,0,0))
							end
						else	
							isCanBuild = false
							v:setColor(cc.c3b(255,0,0))
						end
					else
						v:setColor(cc.c3b(0,255,0))
					end
				end
			end
			if isCanBuild == false then
				button_ok:setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
			else
				button_ok:setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
			end
		end
		if tp == m_MenuMode.move_city then
			panel_3:setVisible(true)
			if g_gameTools.canUseUnionMoveCity(HelperMD.position_2_bigTileIndex(cc.p(ret:getPositionX(), ret:getPositionY()))) then
				panel_3:getChildByName("Image_1"):loadTexture(g_data.sprite[g_data.item[21400].res_icon].path)
				panel_3:getChildByName("Text_2"):setString("1")
			else
				local count = g_BagMode.findItemNumberById(c_move_city_item_id)
				if count > 0 then
					panel_3:getChildByName("Image_1"):loadTexture(g_data.sprite[g_data.item[c_move_city_item_id].res_icon].path)
					panel_3:getChildByName("Text_2"):setString("1")
				else
					local cnt , iconPath = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
					panel_3:getChildByName("Image_1"):loadTexture(iconPath)
					panel_3:getChildByName("Text_2"):setString(tostring(c_move_city_gem_count))
				end
			end
		end
	end
	
	local origin_bigTileIndex = nil
	local auto_offset_index = cc.p(0,0)
	
	local function update_AutoMove(dt)
		if origin_bigTileIndex then
			local origin_center_Ingex = require("game.mapguildwar.worldMapLayer_bigMap").getBigTileIndex_CurrentLookAt()
			require("game.mapguildwar.worldMapLayer_bigMap").offsetAddBigTileIndex_Manual(auto_offset_index)
			local new_center_Ingex = require("game.mapguildwar.worldMapLayer_bigMap").getBigTileIndex_CurrentLookAt()
			local real_offset_index = cc.pSub(new_center_Ingex, origin_center_Ingex) --这才是视口真正偏移成功的偏移量
			local new_bigTileIndex = cc.pAdd(origin_bigTileIndex,real_offset_index)
			local offset_position = cc.pSub(HelperMD.bigTileIndex_2_position(new_bigTileIndex), HelperMD.bigTileIndex_2_position(origin_bigTileIndex))
			origin_bigTileIndex = new_bigTileIndex
			ret:setPosition(cc.p(ret:getPositionX() + offset_position.x, ret:getPositionY() + offset_position.y))
			checkMask_color()
		end
	end
	
	local scheduler_id = nil
	
	local touch_move_Location_Point = nil
	
	local offfset_box = {
		l = 230,
		r = 230,
		t = 190,
		b = 200,
	}
	
	local function checkOutViewPort()
		if touch_move_Location_Point == nil then
			return
		end
		local viewSize = require("game.mapguildwar.worldMapLayer_bigMap").getMapScrollViewSize()
		local viewPos = require("game.mapguildwar.worldMapLayer_bigMap").getWorldPointInMapScrollView(touch_move_Location_Point)
		local isOpen = false
		auto_offset_index.x = 0
		auto_offset_index.y = 0
		if viewPos.x < offfset_box.l then
			isOpen = true
			if viewPos.y < offfset_box.b then
				auto_offset_index.y = 1
			elseif viewPos.y > viewSize.height - offfset_box.t then
				auto_offset_index.x = -1
			else
				auto_offset_index.y = 1
				auto_offset_index.x = -1
			end
		elseif viewPos.x > viewSize.width - offfset_box.r then
			isOpen = true
			if viewPos.y < offfset_box.b then
				auto_offset_index.x = 1
			elseif viewPos.y > viewSize.height - offfset_box.t then
				auto_offset_index.y = -1
			else
				auto_offset_index.x = 1
				auto_offset_index.y = -1
			end
		else
			if viewPos.y < offfset_box.b then
				isOpen = true
				auto_offset_index.x = 1
				auto_offset_index.y = 1
			elseif viewPos.y > viewSize.height - offfset_box.t then
				isOpen = true
				auto_offset_index.x = -1
				auto_offset_index.y = -1
			end
		end
		if isOpen then
			if scheduler_id == nil then
				scheduler_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_AutoMove, 0.2, false)
			end
		elseif scheduler_id then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduler_id)
			scheduler_id = nil
		end
	end
	
	local function onTouchBegan(touch, event)
		local r = false
		if origin_bigTileIndex then
			return r
		end
		if ret:isVisible() then
			r = HelperMD.parallelogramContainsPoint(parallelogram.posT, parallelogram.posL, parallelogram.posB, parallelogram.posR, cTools_worldToNodeSpace_position(ret, touch:getLocation()))
			if r == true then
				origin_bigTileIndex = HelperMD.position_2_bigTileIndex(require("game.mapguildwar.worldMapLayer_bigMap").worldPosition_2_position(touch:getLocation()))
				require("game.mapguildwar.worldMapLayer_bigMap").setMapScrollViewTouchEnabled(false)
				widget_buttons:setVisible(false)
			end
		end
		return r
	end
	local function onTouchMoved(touch, event)
		if origin_bigTileIndex then
			touch_move_Location_Point = touch:getLocation()
			local new_bigTileIndex = HelperMD.position_2_bigTileIndex(require("game.mapguildwar.worldMapLayer_bigMap").worldPosition_2_position(touch_move_Location_Point))
			if new_bigTileIndex.x ~= origin_bigTileIndex.x or new_bigTileIndex.y ~= origin_bigTileIndex.y then
				local offset_index = cc.p(new_bigTileIndex.x - origin_bigTileIndex.x, new_bigTileIndex.y - origin_bigTileIndex.y)
				local offset_position = cc.pSub(HelperMD.bigTileIndex_2_position(new_bigTileIndex), HelperMD.bigTileIndex_2_position(origin_bigTileIndex))
				ret:setPosition(cc.p(ret:getPositionX() + offset_position.x, ret:getPositionY() + offset_position.y))
				origin_bigTileIndex = HelperMD.position_2_bigTileIndex(require("game.mapguildwar.worldMapLayer_bigMap").worldPosition_2_position(touch_move_Location_Point))
				checkMask_color()
			end
			checkOutViewPort()
		end
	end
	local function onTouchEnded(touch, event)
		origin_bigTileIndex = nil
		widget_buttons:setVisible(true)
		if scheduler_id then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduler_id)
			scheduler_id = nil
		end
		require("game.mapguildwar.worldMapLayer_bigMap").setMapScrollViewTouchEnabled(true)
	end
	local function onTouchCancelled(touch, event)
		origin_bigTileIndex = nil
		widget_buttons:setVisible(true)
		if scheduler_id then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduler_id)
			scheduler_id = nil
		end
		require("game.mapguildwar.worldMapLayer_bigMap").setMapScrollViewTouchEnabled(true)
	end
	local touchListener = cc.EventListenerTouchOneByOne:create()
	touchListener:setSwallowTouches(true)
	touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	touchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	touchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	touchListener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener,ret)
	
	
	local function layerEventHandler(eventType)
		if eventType == "enter" then
			checkMask_color()
		end
	end
	ret:registerScriptHandler(layerEventHandler)

	return ret
end



return worldMapLayer_inputMenu