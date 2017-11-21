local harvestEffect_Fly = {}
setmetatable(harvestEffect_Fly,{__index = _G})
setfenv(1,harvestEffect_Fly)

local HomeMapLayerMD = require("game.maplayer.homeMapLayer")
local MainSurfacePlayerMD = require("game.uilayer.mainSurface.mainSurfacePlayer")


local c_fly_speed = 1.0 / 600.0


function playAirText(place, str)
	local button = HomeMapLayerMD.getBuildButtonWithPlace(place)
	if button then
		local size = button:getContentSize()
		local origin_position = cc.p(size.width / 2, size.height / 2)
		local textLabel = cc.Label:createWithTTF(str, "cocostudio_res/simhei.ttf", 30, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
		textLabel:disableEffect()
		textLabel:setAnchorPoint(cc.p(0.5, 0.5))
		textLabel:setPosition(origin_position)
		textLabel:setTextColor(cc.c4b(0,255,0,255))
		textLabel:enableOutline(cc.c4b(0, 0, 0,255), 1)
		textLabel:setScale(0.2)
		textLabel:runAction(cc.Sequence:create(
		cc.EaseBackOut:create(cc.ScaleTo:create(0.25, 1.0))
		, cc.DelayTime:create(0.25)
		, cc.Spawn:create(cc.MoveBy:create(1.0,cc.p(0.0, 50.0)), cc.FadeTo:create(1.0,0))
		, cc.RemoveSelf:create()
		))
		button:addChild(textLabel)
	end
end

--收获飞行特效

function create_basic(filename , beginPosition , endPosition , weight , playIconFunc)
	local node = cc.Node:create()
	node:setPosition(cc.p(0.0,0.0))
	node:setContentSize(cc.size(0,0))
	
	local function onPlayIcon()
		playIconFunc()
	end
	
	local f = math.floor(math.clampf(weight,3,10))
	
	local distanceVec = cc.p(endPosition.x - beginPosition.x , endPosition.y - beginPosition.y)
	
	local length = math.sqrt(distanceVec.x * distanceVec.x + distanceVec.y * distanceVec.y)

	local time = math.clampf(c_fly_speed * length, 0.3, 1.2)
	
	for i = 1 , f , 1 do
		local sp = cc.Sprite:createWithSpriteFrameName(filename)
		sp:setPosition(cc.p( beginPosition.x + math.random(-35,35), beginPosition.y + math.random(-35,35) ))
		sp:setVisible(false)
		sp:setRotation(math.random(0,359))
		sp:setScale(math.random(8,12) * 0.1)
		local am = cc.Spawn:create(
			cc.MoveTo:create(time,endPosition)
			,cc.RotateBy:create(time,math.random(-900, 900))
		)
		sp:runAction( cc.Sequence:create( cc.DelayTime:create(i / 8.0) , cc.Show:create() , am , cc.Hide:create() , cc.CallFunc:create(onPlayIcon) ) )
		node:addChild(sp)
	end
	
	node:runAction(cc.Sequence:create(cc.DelayTime:create(6.0),cc.RemoveSelf:create()))
	return node
end


--食物
function play_Food(place , weight)
	local button = HomeMapLayerMD.getBuildButtonWithPlace(place)
	if button then
		local size = button:getContentSize()
		play_Food_forBeginPosition(button:convertToWorldSpace(cc.p(size.width / 2, size.height / 2)), weight)
	end
end


--金
function play_Gold(place , weight)
	local button = HomeMapLayerMD.getBuildButtonWithPlace(place)
	if button then
		local size = button:getContentSize()
		play_Gold_forBeginPosition(button:convertToWorldSpace(cc.p(size.width / 2, size.height / 2)), weight)
	end
end


--铁
function play_Iron(place , weight)
	local button = HomeMapLayerMD.getBuildButtonWithPlace(place)
	if button then
		local size = button:getContentSize()
		play_Iron_forBeginPosition(button:convertToWorldSpace(cc.p(size.width / 2, size.height / 2)), weight)
	end
end


--木头
function play_Wood(place , weight)
	local button = HomeMapLayerMD.getBuildButtonWithPlace(place)
	if button then
		local size = button:getContentSize()
		play_Wood_forBeginPosition(button:convertToWorldSpace(cc.p(size.width / 2, size.height / 2)), weight)
	end
end


--石头
function play_Stone(place , weight)
	local button = HomeMapLayerMD.getBuildButtonWithPlace(place)
	if button then
		local size = button:getContentSize()
		play_Stone_forBeginPosition(button:convertToWorldSpace(cc.p(size.width / 2, size.height / 2)), weight)
	end
end


---------------------------------------------------------------------------


--食物
function play_Food_forBeginPosition(beginPosition , weight)
	local endPosition = nil
	local playHarvest = nil
	if g_resourcesInterface.getResInterfaceShowCount() > 0 then
		endPosition = g_resourcesInterface.getPositionWorldSpace_Food()
		playHarvest = g_resourcesInterface.playHarvest_Food
	else
		endPosition = MainSurfacePlayerMD.getPositionWorldSpace_Food()
		playHarvest = MainSurfacePlayerMD.playHarvest_Food
	end
	if endPosition then
		local effect = create_basic("homeImage_harvest_Food.png", beginPosition , endPosition , weight , playHarvest)
		g_sceneManager.addNodeForSceneEffect(effect)
	end
end


--金
function play_Gold_forBeginPosition(beginPosition , weight)
	local endPosition = nil
	local playHarvest = nil
	if g_resourcesInterface.getResInterfaceShowCount() > 0 then
		endPosition = g_resourcesInterface.getPositionWorldSpace_Gold()
		playHarvest = g_resourcesInterface.playHarvest_Gold
	else
		endPosition = MainSurfacePlayerMD.getPositionWorldSpace_Gold()
		playHarvest = MainSurfacePlayerMD.playHarvest_Gold
	end
	if endPosition then
		local effect = create_basic("homeImage_harvest_Gold.png", beginPosition , endPosition , weight , playHarvest)
		g_sceneManager.addNodeForSceneEffect(effect)
	end
end


--铁
function play_Iron_forBeginPosition(beginPosition , weight)
	local endPosition = nil
	local playHarvest = nil
	if g_resourcesInterface.getResInterfaceShowCount() > 0 then
		endPosition = g_resourcesInterface.getPositionWorldSpace_Iron()
		playHarvest = g_resourcesInterface.playHarvest_Iron
	else
		endPosition = MainSurfacePlayerMD.getPositionWorldSpace_Iron()
		playHarvest = MainSurfacePlayerMD.playHarvest_Iron
	end
	if endPosition then
		local effect = create_basic("homeImage_harvest_Iron.png", beginPosition , endPosition , weight , playHarvest)
		g_sceneManager.addNodeForSceneEffect(effect)
	end
end


--木头
function play_Wood_forBeginPosition(beginPosition , weight)
	local endPosition = nil
	local playHarvest = nil
	if g_resourcesInterface.getResInterfaceShowCount() > 0 then
		endPosition = g_resourcesInterface.getPositionWorldSpace_Wood()
		playHarvest = g_resourcesInterface.playHarvest_Wood
	else
		endPosition = MainSurfacePlayerMD.getPositionWorldSpace_Wood()
		playHarvest = MainSurfacePlayerMD.playHarvest_Wood
	end
	if endPosition then
		local effect = create_basic("homeImage_harvest_Wood.png", beginPosition , endPosition , weight , playHarvest)
		g_sceneManager.addNodeForSceneEffect(effect)
	end
end


--石头
function play_Stone_forBeginPosition(beginPosition , weight)
	local endPosition = nil
	local playHarvest = nil
	if g_resourcesInterface.getResInterfaceShowCount() > 0 then
		endPosition = g_resourcesInterface.getPositionWorldSpace_Stone()
		playHarvest = g_resourcesInterface.playHarvest_Stone
	else
		endPosition = MainSurfacePlayerMD.getPositionWorldSpace_Stone()
		playHarvest = MainSurfacePlayerMD.playHarvest_Stone
	end
	if endPosition then
		local effect = create_basic("homeImage_harvest_Stone.png", beginPosition , endPosition , weight , playHarvest)
		g_sceneManager.addNodeForSceneEffect(effect)
	end
end






return harvestEffect_Fly