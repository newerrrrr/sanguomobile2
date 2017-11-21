local taxEffect = {}
setmetatable(taxEffect,{__index = _G})
setfenv(1,taxEffect)

local HomeMapLayerMD = require("game.maplayer.homeMapLayer")

function show(food, gold , iron , stone , wood)
	
	local foodVar = food and math.floor(food) or 0
	local goldVar = gold and math.floor(gold) or 0
	local ironVar = iron and math.floor(iron) or 0
	local stoneVar = stone and math.floor(stone) or 0
	local woodVar = wood and math.floor(wood) or 0
	
	local function playAction()
	
		if foodVar > 0 then
			local buildings = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.food)
			local count = #buildings
			local var = count > 0 and math.ceil(foodVar / count) or 0
			local strVar = "+"..tostring(var)
			for k , v in ipairs(buildings) do
				require("game.effectlayer.harvestEffect_Fly").play_Food(v.position, 10 --[[var / math.max(1,v.resource_in)--]] )
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.position, strVar)
			end
		end
		
		if goldVar > 0 then
			local buildings = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.gold)
			local count = #buildings
			local var = count > 0 and math.ceil(goldVar / count) or 0
			local strVar = "+"..tostring(var)
			for k , v in ipairs(buildings) do
				require("game.effectlayer.harvestEffect_Fly").play_Gold(v.position, 10 --[[var / math.max(1,v.resource_in)--]] )
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.position, strVar)
			end
		end
		
		if ironVar > 0 then
			local buildings = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.iron)
			local count = #buildings
			local var = count > 0 and math.ceil(ironVar / count) or 0
			local strVar = "+"..tostring(var)
			for k , v in ipairs(buildings) do
				require("game.effectlayer.harvestEffect_Fly").play_Iron(v.position, 10 --[[var / math.max(1,v.resource_in)--]] )
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.position, strVar)
			end
		end
		
		if stoneVar > 0 then
			local buildings = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.stone)
			local count = #buildings
			local var = count > 0 and math.ceil(stoneVar / count) or 0
			local strVar = "+"..tostring(var)
			for k , v in ipairs(buildings) do
				require("game.effectlayer.harvestEffect_Fly").play_Stone(v.position, 10 --[[var / math.max(1,v.resource_in)--]] )
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.position, strVar)
			end
		end
		
		if woodVar > 0 then
			local buildings = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.wood)
			local count = #buildings
			local var = count > 0 and math.ceil(woodVar / count) or 0
			local strVar = "+"..tostring(var)
			for k , v in ipairs(buildings) do
				require("game.effectlayer.harvestEffect_Fly").play_Wood(v.position, 10 --[[var / math.max(1,v.resource_in)--]] )
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.position, strVar)
			end
		end
		
		cc.Director:getInstance():setNextDeltaTimeZero(true)
	
	end
	
	local function onChangeEnd()
		g_autoCallback.addCocosList( playAction , 0.618 )
	end
	require("game.maplayer.changeMapScene").gotoHome_Place(5005, onChangeEnd)
	
	cc.Director:getInstance():setNextDeltaTimeZero(true)
	
end



return taxEffect