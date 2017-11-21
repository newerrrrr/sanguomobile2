local worldMapLayer_areaMap = {}
setmetatable(worldMapLayer_areaMap,{__index = _G})
setfenv(1,worldMapLayer_areaMap)

--一个区域

local MapArrayMD = require "game.maplayer.worldMapLayer_mapArray"
local HelperMD = require "game.maplayer.worldMapLayer_helper"

local m_Root = nil

local function clearGlobal()
	m_Root = nil
end


function create(areaIndex)
	
	clearGlobal()
	
	local tmxLayer = lhs.LHSTmxLayer:create(string.format("worldmap/mapRes/map_%d.tmx",MapArrayMD.map[areaIndex.y + 1][areaIndex.x + 1]))
	m_Root = tmxLayer
	tmxLayer:ignoreAnchorPointForPosition(false)
	tmxLayer:setAnchorPoint(cc.p(0.0,0.0))
	tmxLayer:setPosition(HelperMD.areaIndex_2_position(areaIndex))

	local function rootLayerEventHandler(eventType)
		if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(tmxLayer == m_Root)then
				clearGlobal()
			end
		end
	end
	tmxLayer:registerScriptHandler(rootLayerEventHandler)

	--测试代码
	if g_isDebug then
		if tmxLayer:getChildByName("layer_1") == nil 
			or tmxLayer:getChildByName("layer_top") == nil 
			or tmxLayer:getChildByName("layer_mid1") == nil
				then
			cToolsForLua:MessageBox("LiuYi quickly check map , layer type not complete ! map id : "..tostring(MapArrayMD.map[areaIndex.y + 1][areaIndex.x + 1]),"error")
		end
		local test_mid1 = tmxLayer:getChildByName("layer_mid1")
		if test_mid1 and test_mid1:getChildrenCount() > 0 then
			cToolsForLua:MessageBox("LiuYi quickly check map , \"layer_mid1\" ChildrenCount > 0 ! map id : "..tostring(MapArrayMD.map[areaIndex.y + 1][areaIndex.x + 1]),"error")
		end
		local test_top = tmxLayer:getChildByName("layer_top")
		if test_top and test_top:getChildrenCount() > 0 then
			cToolsForLua:MessageBox("LiuYi quickly check map , \"layer_top\" ChildrenCount > 0 ! map id : "..tostring(MapArrayMD.map[areaIndex.y + 1][areaIndex.x + 1]),"error")
		end
	end
	
	tmxLayer.lua_layer_mid1 = tmxLayer:getChildByName("layer_mid1")
	--tmxLayer.lua_layer_mid2 = tmxLayer:getChildByName("layer_mid2")
	--tmxLayer.lua_layer_mid3 = tmxLayer:getChildByName("layer_mid3")
	
	tmxLayer.lua_layer_mid1.lua_weight = 0
	--tmxLayer.lua_layer_mid2.lua_weight = 0
	--tmxLayer.lua_layer_mid3.lua_weight = 0

	tmxLayer.lua_layer_mid_idArray = {}	--{ [idString] = layer_mid }

	--找权重最低者
	function tmxLayer:lua_getWeightLowMid()
		return tmxLayer.lua_layer_mid1
		--local low_mid = ( (self.lua_layer_mid1.lua_weight < self.lua_layer_mid2.lua_weight) and (self.lua_layer_mid1) or (self.lua_layer_mid2) )
		--return ( (low_mid.lua_weight < self.lua_layer_mid3.lua_weight) and (low_mid) or (self.lua_layer_mid3) )
	end
	
	return tmxLayer
end




return worldMapLayer_areaMap