local smallBuildMenu = {}
setmetatable(smallBuildMenu,{__index = _G})
setfenv(1,smallBuildMenu)


local c_IndexArray = {
	[1] = {
		[1] = 6,
	},
	[2] = {
		[1] = 5,
		[2] = 7,
	},
	[3] = {
		[1] = 4,
		[2] = 6,
		[3] = 8,
	},
	[4] = {
		[1] = 3,
		[2] = 5,
		[3] = 7,
		[4] = 9,
	},
	[5] = {
		[1] = 2,
		[2] = 4,
		[3] = 6,
		[4] = 8,
		[5] = 10,
	},
	[6] = {
		[1] = 1,
		[2] = 3,
		[3] = 5,
		[4] = 7,
		[5] = 9,
		[6] = 11,
	},
}


local c_tip_effect_tag = 44144218


function _installTitle(button , serverData, menuType)
	local widget = nil
	if menuType == 127 then
		--闹钟
		widget = cc.CSLoader:createNode("number.csb")
		local textLabel = widget:getChildByName("Text_1")
		local iconImage = widget:getChildByName("Image_1")
		iconImage:setVisible(false)
		local last_time = 0
		local function update_addSpeed_time(dt)
			local current_time = g_clock.getCurServerTime()
			if current_time >= last_time + 1.0 then
				last_time = current_time
				textLabel:setString(g_gameTools.convertSecondToString(serverData.ex_addition_end_time - current_time))
			end
		end
		textLabel:scheduleUpdateWithPriorityLua(update_addSpeed_time, 0)
		update_addSpeed_time(0.01666)
	elseif menuType == 120 or menuType == 143 or menuType == 144 or menuType == 145 or menuType == 146 then
		--提速
		widget = cc.CSLoader:createNode("number.csb")
		local textLabel = widget:getChildByName("Text_1")
		local iconImage = widget:getChildByName("Image_1")
		iconImage:setVisible(false)
		textLabel:setString(g_tr("smallMenu_have",{count = g_BagMode.findItemNumberById(g_Consts.ResAddSpeedItemId[serverData.origin_build_id])}))
	elseif menuType == 121 then
		--元宝提速
		widget = cc.CSLoader:createNode("number.csb")
		local textLabel = widget:getChildByName("Text_1")
		local iconImage = widget:getChildByName("Image_1")
		local cnt , iconPath = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
		local count = g_data.item[g_Consts.ResAddSpeedItemId[serverData.origin_build_id]].direct_price
		textLabel:setString(tostring(count))
		textLabel:setTextColor( (count > cnt and cc.c3b(255, 0, 0) or cc.c3b(255, 252, 0)) )
		iconImage:loadTexture(iconPath)
	end
	if widget then
		widget:setAnchorPoint(cc.p(0.5, 0.5))
		local size = button:getContentSize()
		widget:setPosition(cc.p(size.width / 2, size.height))
		button:addChild(widget)
	end
end


local function _operateMenuStatus(serverData)
	local menu_status = tonumber(serverData.status)
	if( menu_status ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng and tonumber(serverData.ex_addition_end_time) ~= 0 and tonumber(serverData.ex_addition_end_time) > g_clock.getCurServerTime() )then
		menu_status = 101 --额外道具加成时
	end
	return menu_status
end


function create( place , tipMenuId )
	
	local serverData = g_PlayerBuildMode.FindBuild_Place(place)
	
	local configData = g_data.build[tonumber(serverData.build_id)]
	
	local buildingData = g_data.build_position[tonumber(place)]
	
	local buildButton = require("game.maplayer.homeMapLayer").getBuildButtonWithPlace(place)
	
	local widget = cc.CSLoader:createNode("jianzhuxinxi.csb")
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(buildButton:getPositionX(),buildButton:getPositionY()))
	
	--先隐藏所有
	for i = 1 , 11 ,1 do
		widget:getChildByName(string.format("Panel_anniu%02d",i)):setVisible(false)
	end
	
	local menu_status = _operateMenuStatus(serverData)
	
	local menuConfig_origin = configData[string.format("build_menu_%d",menu_status)]
	local menuConfig = {}
	
	--剔除掉当前状态不显示的
	for k,v in pairs(menuConfig_origin) do
		if(v==102)then --升级
			if(g_PlayerBuildMode.FindBuildConfig_lv_Next_ConfigID(serverData.build_id))then
				menuConfig[k] = v --有下一级才可升级
			end
		else
			menuConfig[k] = v
		end
	end
	
	
	--缓存
	local cache_data = {}
	widget.lua_cache_data = cache_data
	
	--cell缓存
	widget.lua_cache_data.cellArray = {}
	
	--按钮缓存
	widget.lua_cache_data.buttonArray = {}
	
	--所在位置
	widget.lua_cache_data.place = tonumber(place)
	
	--按钮状态
	widget.lua_cache_data.menu_status = menu_status
	
	--计算状态函数
	widget.lua_cache_data.operateMenuStatus = _operateMenuStatus
	
	
	--打开动画是否完成
	local open_animation_completed = false
	
	--点中
	local function onCellButton(sender, eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			if open_animation_completed then
				require("game.maplayer.homeMapLayer").closeSmallBuildMenu()
				require("game.maplayer.smallMenuClick").onClick(cache_data.buttonArray[sender],configData,buildingData,serverData)
			end
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	
	
	local count = table.total(menuConfig)
	local num = 0
	for k , v in pairs(menuConfig) do
		num = num + 1
		local cell = widget:getChildByName(string.format("Panel_anniu%02d",c_IndexArray[count][num]))
		table.insert(widget.lua_cache_data.cellArray, 1, cell)
		cell:setVisible(true)
		local cellConfig = g_data.build_menu[v]
		cell:getChildByName("Text_2"):setString(g_tr(cellConfig.name))
		local button = cell:getChildByName("Image_1_0")
		widget.lua_cache_data.buttonArray[button] = v
		button:loadTexture(g_data.sprite[cellConfig.img].path)
		_installTitle(button, serverData, v)
		if(v == 127)then
			--闹钟 只管显示
		else
			button:addTouchEventListener(onCellButton)
			if(v == 122 or v == 123 or v == 124 or v == 125 or v == 126)then
				--收获可能在冷却中 在这里加入其他处理
				
				--检测收获
				local function checkHarvestButton()
					local d = g_PlayerBuildMode.FindBuild_Place(place)
					if d then
						if (g_clock.getCurServerTime() - d.resource_start_time) * d.resource_in / 3600 > 1 then
							button:setTouchEnabled(true)
							button:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
						else
							button:setTouchEnabled(false)
							button:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
							widget:runAction(cc.Sequence:create( cc.DelayTime:create(10.0) , cc.CallFunc:create(checkHarvestButton) ) )
						end
					end
				end
				
				checkHarvestButton()
				
			elseif v == 120 or v == 143 or v == 144 or v == 145 or v == 146 then
				--资源建筑道具加速
				if g_BagMode.findItemNumberById(g_Consts.ResAddSpeedItemId[serverData.origin_build_id]) < 1 then
					button:setTouchEnabled(false)
					button:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
				end
			end
			
		end
		
		--注册新手引导nodeId
		g_guideManager.registComponent(6000000 + v,button)
	end
	
	--tip菜单
	do
		local function _setTipMenu(mid)
			local tipId = tonumber(mid)
			for k , v in pairs(widget.lua_cache_data.buttonArray) do
				k:removeChildByTag(c_tip_effect_tag)
				if v == tipId then
					local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_XinShouYuanKuangXunHuan/Effect_XinShouYuanKuangXunHuan.ExportJson", "Effect_XinShouYuanKuangXunHuan")
					k:addChild(armature, 0, c_tip_effect_tag)
					local size = k:getContentSize()
					armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
					animation:play("Animation1")
				end
			end
		end
		if tipMenuId then
			_setTipMenu(tipMenuId)
		else
			if (serverData.general_id_1 == nil or serverData.general_id_1 == 0) and g_GeneralMode.getIdleResidenceGenCount() > 0 then
				--没有驻守
				_setTipMenu(103)
			end
		end
	end
	
	--打开动画
	local function playOpenAnimation()
		local basic_panel = widget:getChildByName("Panel_SpecialEffects")
		--local basic_position = cc.p(basic_panel:getPositionX(), basic_panel:getPositionY())
		local iterate_delayTime = 0.0
		for k , v in ipairs(widget.lua_cache_data.cellArray) do
			local origin_position = cc.p(v:getPositionX(), v:getPositionY())
			--local vec = cc.pSub(origin_position, basic_position)
			--local offset = cc.pSetLength(vec, 100.0)
			local offset = cc.p(0.0, -100.0)
			v:setPosition(cc.pSub(origin_position, offset))
			v:setScale(0.1)
			v:setCascadeOpacityEnabled(true)
			v:setOpacity(0)
			local action = cc.Sequence:create(cc.DelayTime:create(iterate_delayTime), cc.Spawn:create(cc.MoveTo:create(0.25, origin_position), cc.ScaleTo:create(0.25, 1.0), cc.FadeTo:create(0.25, 255)))
			v:runAction(action)
			iterate_delayTime = iterate_delayTime + 0.03
		end
		local black_widget = widget:getChildByName("Image_diban")
		black_widget:setCascadeOpacityEnabled(true)
		black_widget:setOpacity(0)
		black_widget:runAction(cc.Sequence:create(cc.DelayTime:create(iterate_delayTime), cc.FadeTo:create(0.25, 255), cc.CallFunc:create(function() open_animation_completed = true end)))
	end
	playOpenAnimation()
	
	
	local function widgetEventHandler(eventType)
        if eventType == "enter" then
			require("game.maplayer.homeMapLayer").openBlurForSmallMenu()
			g_guideManager.execute()
		elseif eventType == "exit" then
			require("game.maplayer.homeMapLayer").closeBlurForSmallMenu()
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    widget:registerScriptHandler(widgetEventHandler)
	

	return widget
end


--设置提示点击的菜单ID
function setTipMenuID( tipMenuId )
	local widget = require("game.maplayer.homeMapLayer").getSmallBuildMenu()
	if widget then
		local tipId = tipMenuId and tonumber(tipMenuId) or -1
		for k , v in pairs(widget.lua_cache_data.buttonArray) do
			k:removeChildByTag(c_tip_effect_tag)
			if v == tipId then
				local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_XinShouYuanKuangXunHuan/Effect_XinShouYuanKuangXunHuan.ExportJson", "Effect_XinShouYuanKuangXunHuan")
				k:addChild(armature,0,c_tip_effect_tag)
				local size = k:getContentSize()
				armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
				animation:play("Animation1")
			end
		end
	end
end




return smallBuildMenu