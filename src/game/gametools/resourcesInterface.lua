local resourcesInterface = {}
setmetatable(resourcesInterface,{__index = _G})
setfenv(1,resourcesInterface)

--通用资源显示

local c_count_show_place = {
	[1] = {
		[1] = 5,
	},
	[2] = {
		[1] = 4,
		[2] = 5,
	},
	[3] = {
		[1] = 3,
		[2] = 4,
		[3] = 5,
	},
	[4] = {
		[1] = 2,
		[2] = 3,
		[3] = 4,
		[4] = 5,
	},
	[5] = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
		[5] = 5,
	},
}

local c_tag_icon_play_harvest_action = 19201417

local m_ResInterfaceTab = {}	--显示缓存

local function _push(node)
	m_ResInterfaceTab[node] = true
	node:retain()
end

local function _pop(node)
	m_ResInterfaceTab[node] = nil
	node:release()
end

function getResInterfaceShowCount()
	return table.total(m_ResInterfaceTab)
end

function updateAllResShow()
	for k , v in pairs(m_ResInterfaceTab) do
		k:lua_updateShow()
	end
end

--计算资源显示位置编号
local function _getResourcesPlace(btp)
	local s = string.split(g_data.starting[37].name, ",")
	for k , v in ipairs(s) do
		if tonumber(v) == btp then
			return k
		end
	end
	assert(false,"error : resources place")
end


--根据资源位置编号找到对应节点
local function _getResourcesNodeWithPlace(widget, place)
	return widget:getChildByName(string.format("Panel_m%d",place))
end


--安装
function installResources( parent_ui_widget )
	local scale_node = parent_ui_widget:getChildByName("scale_node")
	if scale_node then
		local size = scale_node:getContentSize()
		local widget = cc.CSLoader:createNode("Resources_1.csb")
		widget:ignoreAnchorPointForPosition(false)
		widget:setAnchorPoint(cc.p(1.0,0.0))
		widget:setPosition(cc.p(size.width * 0.5 + 632, size.height * 0.5 + 302))
		local function nodeEventHandler(eventType)
			if eventType == "enter" then
				_push(widget)
			elseif eventType == "exit" then
				_pop(widget)
			elseif eventType == "enterTransitionFinish" then
			elseif eventType == "exitTransitionStart" then
			elseif eventType == "cleanup" then
			end
		end
		widget:registerScriptHandler(nodeEventHandler)
		
		widget:getChildByName("Panel_yuanbao"):getChildByName("Image_4"):addTouchEventListener(onButtonCharge)
		
		widget.lua_cache_panel = {}
		
		function widget:lua_updateShow()
			do--隐藏所有
				for i = 1 , 5 , 1 do
					self:getChildByName(string.format("Panel_m%d",i)):setVisible(false)
				end
			end
			self.lua_cache_panel = {}
			local resTab = {}
			if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.food) then
				resTab[_getResourcesPlace(g_Consts.AllCurrencyType.Food)] = g_Consts.AllCurrencyType.Food
			end
			if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.wood) then
				resTab[_getResourcesPlace(g_Consts.AllCurrencyType.Wood)] = g_Consts.AllCurrencyType.Wood
			end
			if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.stone) then
				resTab[_getResourcesPlace(g_Consts.AllCurrencyType.Stone)] = g_Consts.AllCurrencyType.Stone
			end
			if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.iron) then
				resTab[_getResourcesPlace(g_Consts.AllCurrencyType.Iron)] = g_Consts.AllCurrencyType.Iron
			end
			if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.gold) then
				resTab[_getResourcesPlace(g_Consts.AllCurrencyType.Gold)] = g_Consts.AllCurrencyType.Gold
			end
			local show_count = table.total(resTab)
			if show_count > 0 then
				local num = 0
				for k , v in lhs_pairs(resTab, false) do
					num = num + 1
					local panel = self:getChildByName(string.format("Panel_m%d", c_count_show_place[show_count][num]))
					self.lua_cache_panel[v] = panel
					panel:setVisible(true)
					local count , icon = g_gameTools.getPlayerCurrencyCount( v )
					panel:getChildByName("Text_1"):setString(string.formatnumberlogogram( tonumber(count) ))
					panel:getChildByName("Image_1"):loadTexture(icon)
				end
			end
			do
				local panel_yuanbao = self:getChildByName("Panel_yuanbao")
				local count , icon = g_gameTools.getPlayerCurrencyCount( g_Consts.AllCurrencyType.Gem )
				panel_yuanbao:getChildByName("Text_1"):setString(string.formatnumberthousands( tonumber(count) ))
				panel_yuanbao:getChildByName("Image_1"):loadTexture(icon)
			end
		end
		widget:lua_updateShow()
		scale_node:addChild(widget, g_Consts.resourcesInterfaceZOrder)

		return widget 
	end
end


function lhs_pairs(tab , tp)
	local func = (tp and (function (a , b) return tonumber(a) > tonumber(b) end) or (function (a , b) return tonumber(a) < tonumber(b) end) )
	local keyTab = {}
	for k , v in pairs(tab) do
		table.insert(keyTab, k) 
	end
	table.sort(keyTab, func)
	local index = 0
	local function iter()
		index = index + 1
		if keyTab[index] == nil then return nil
		else return keyTab[index], tab[keyTab[index]]
		end
	end
	return iter
end


function getPositionWorldSpace_Food()
	local ret = cc.p(g_display.top_center.x, g_display.top_center.y)
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Food]
		if panel then
			local node = panel:getChildByName("Image_1")
			local size = node:getContentSize()
			ret = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
		end
		break
	end
	return ret
end


function getPositionWorldSpace_Wood()
	local ret = cc.p(g_display.top_center.x, g_display.top_center.y)
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Wood]
		if panel then
			local node = panel:getChildByName("Image_1")
			local size = node:getContentSize()
			ret = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
		end
		break
	end
	return ret
end


function getPositionWorldSpace_Stone()
	local ret = cc.p(g_display.top_center.x, g_display.top_center.y)
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Stone]
		if panel then
			local node = panel:getChildByName("Image_1")
			local size = node:getContentSize()
			ret = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
		end
		break
	end
	return ret
end


function getPositionWorldSpace_Iron()
	local ret = cc.p(g_display.top_center.x, g_display.top_center.y)
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Iron]
		if panel then
			local node = panel:getChildByName("Image_1")
			local size = node:getContentSize()
			ret = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
		end
		break
	end
	return ret
end


function getPositionWorldSpace_Gold()
	local ret = cc.p(g_display.top_center.x, g_display.top_center.y)
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Gold]
		if panel then
			local node = panel:getChildByName("Image_1")
			local size = node:getContentSize()
			ret = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
		end
		break
	end
	return ret
end


local function _createHarvestAction()
	return cc.Sequence:create(
			cc.ScaleTo:create(0.1,1.2)
			,cc.ScaleTo:create(0.2,0.8)
			,cc.ScaleTo:create(0.2,1.2)
			,cc.ScaleTo:create(0.2,0.8)
			,cc.ScaleTo:create(0.2,1.2)
			,cc.ScaleTo:create(0.15,0.9)
			,cc.ScaleTo:create(0.1,1.0)
			)
end


function playHarvest_Food()
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Food]
		if panel then
			local node = panel:getChildByName("Image_1")
			if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
				local action = _createHarvestAction()
				action:setTag(c_tag_icon_play_harvest_action)
				node:runAction(action)
			end
		end
	end
end


function playHarvest_Wood()
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Wood]
		if panel then
			local node = panel:getChildByName("Image_1")
			if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
				local action = _createHarvestAction()
				action:setTag(c_tag_icon_play_harvest_action)
				node:runAction(action)
			end
		end
	end
end


function playHarvest_Stone()
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Stone]
		if panel then
			local node = panel:getChildByName("Image_1")
			if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
				local action = _createHarvestAction()
				action:setTag(c_tag_icon_play_harvest_action)
				node:runAction(action)
			end
		end
	end
end


function playHarvest_Iron()
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Iron]
		if panel then
			local node = panel:getChildByName("Image_1")
			if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
				local action = _createHarvestAction()
				action:setTag(c_tag_icon_play_harvest_action)
				node:runAction(action)
			end
		end
	end
end


function playHarvest_Gold()
	for key , var in pairs(m_ResInterfaceTab) do
		local panel = key.lua_cache_panel[g_Consts.AllCurrencyType.Gold]
		if panel then
			local node = panel:getChildByName("Image_1")
			if node:getActionByTag(c_tag_icon_play_harvest_action) == nil then
				local action = _createHarvestAction()
				action:setTag(c_tag_icon_play_harvest_action)
				node:runAction(action)
			end
		end
	end
end


function onButtonCharge(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		
		--这里打开充值
		
	end
end


return resourcesInterface