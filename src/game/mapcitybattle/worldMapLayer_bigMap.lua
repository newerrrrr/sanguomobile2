local worldMapLayer_bigMap = {}
setmetatable(worldMapLayer_bigMap,{__index = _G})
setfenv(1,worldMapLayer_bigMap)

local HelperMD = require "game.mapcitybattle.worldMapLayer_helper"
local AreaMapMD = require "game.mapcitybattle.worldMapLayer_areaMap"
local QueueHelperMD = require "game.mapcitybattle.worldMapLayer_queueHelper"
local LineMD = require "game.mapcitybattle.worldMapLayer_line"
local SmallMenuMD = require "game.mapcitybattle.worldMapLayer_smallMenu"
local TeamRuningMD = require "game.mapcitybattle.worldMapLayer_teamRuning"
local InputMenuMD = require "game.mapcitybattle.worldMapLayer_inputMenu"
local TouchMaskMD = require "game.mapcitybattle.worldMapLayer_touchMask"
local RequestTimeMD = require "game.mapcitybattle.worldMapLayer_requestTime"
local MainSurfacePositionMD = require "game.uilayer.mainSurface.mainSurfacePosition"
local MainSurfaceQueueWorldMD = require "game.uilayer.mainSurface.mainSurfaceQueueWorld"
local BuildTitleMD = require "game.mapcitybattle.worldMapLayer_buildTitle"
local BuildEffectMD = require "game.mapcitybattle.worldMapLayer_buildEffect"
local BuildDisplayMD = require "game.mapcitybattle.worldMapLayer_buildDisplay"


local c_min_scale = 0.55
local c_max_scale = 1.4

m_DefaultScale = 0.58

local c_CustomZOrderOffset = 100000


local c_tag_touchMask_build = 121510
local c_tag_touchMask_nullMap = 121511
local c_tag_touchMask_noSmallMenu = 121512

local c_tag_smallMenu_build = 121513
local c_tag_smallMenu_team = 121514
local c_tag_smallMenu_nullMap = 121515

local c_tag_inputMenu_input = 121516


local m_CurrentAreaIDs = {}	--{ [ 1~9 ] = areaId, }
local m_CurrentAreaDatas = {Map = {} , Player = {} , Camp = {} ,} --{ "Map" = { [id] = map },"Player" = { [player_id] = playerData }, "Camp" = { [camp_id] = guildData }}
local m_CurrentQueueDatas = {Queue = {} , Player = {} , Camp = {} , MapElement = {} ,} -- {"Queue" = { [id] = queueData },"Player" = { [player_id] = playerData }, "Guild" = { [guild_id] = guildData } , "MapElement" = { [id] = { map_element_id = 0 , player_id = 0 , guild_id = 0 }} }
local m_CurrentSpBuildDatas = {Maps = {}}

local m_CurrentRanges = {} -- { [id] = data }

local m_WillOpenSmallMenuData = nil --{ bigTileIndex , wantTryCount }

local m_selfGuildPlayers = {}

local lineNodes = {}
local teamNodes = {}

local m_playerSecitonCountList = {
		--[secion] = {[camp_id] = 0 ,[camp_id]= 1}, --key 为camp_id var 为数量
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
	}

local fogPosList = {
	cc.p(36,70),
	cc.p(60,57),
	cc.p(35,48),
	cc.p(27,25),
	cc.p(51,25),
}


local m_Root = nil
local m_EventDispatcher = nil
local m_ChangeScaleNode = nil
local m_MiddleNode = nil
local m_HomeArrow = nil
local m_LoadingImage = nil
local m_PerspectiveNode = nil
local m_MapScroll = nil
local m_Container = nil

local m_BuildNode = nil
local m_BuildEffectNode = nil
local m_BuildEffectMidNode = nil
local m_BuildTitleNode = nil
local m_QueueMoveNode = nil
local m_BuildEffectTopNode = nil
local m_AutoEffectNode = nil
local m_TouchMaskNode = nil
local m_MenuNode = nil
local m_InputNode = nil
local m_FogNode = nil

local m_ForceUpdateShowFlag = false

local m_currentMapType = 0

--for test
isMapTest = false --打开会忽略网络请求 只加载本地效果

local function clearGlobal()
	m_CurrentAreaIDs = {}
	m_CurrentAreaDatas = {Map = {} , Player = {} , Guild = {} ,}
	m_CurrentQueueDatas = {Queue = {} , Player = {} , Guild = {} , MapElement = {} ,}
	m_CurrentSpBuildDatas = {Map = {}}
	
	m_CurrentRanges = {}
	
	m_WillOpenSmallMenuData = nil
	
	m_Root = nil
	m_EventDispatcher = nil
	m_ChangeScaleNode = nil
	m_MiddleNode = nil
	m_HomeArrow = nil
	m_LoadingImage = nil
	m_PerspectiveNode = nil
	m_MapScroll = nil
	m_Container = nil
	
	m_BuildNode = nil
	m_BuildEffectNode = nil
	m_BuildEffectMidNode = nil
	m_BuildTitleNode = nil
	m_QueueMoveNode = nil
	m_BuildEffectTopNode = nil
	m_AutoEffectNode = nil
	m_TouchMaskNode = nil
	m_MenuNode = nil
	m_InputNode = nil
	m_FogNode = nil
	
	m_ForceUpdateShowFlag = false
	
	m_currentMapType = 0
	
	RequestTimeMD.Reset()
	
	m_selfGuildPlayers = {}
	
	lineNodes = {}
	teamNodes = {}
	
	m_playerSecitonCountList = {
		--[secion] = {[camp_id] = 0 ,[camp_id]= 1}, --key 为camp_id var 为数量
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
	}
end

function getCurrentMapType()
	return m_currentMapType
end

--map_type:不同的地图
function create( bigTileIndex ,map_type)
	
	clearGlobal()
	
	if map_type == nil then
		map_type = g_cityBattleInfoData.GetCurrentMapType()
	end 
	
	m_currentMapType = map_type
	
	do--load res
		local textureCache = cc.Director:getInstance():getTextureCache()
		local spriteFrameCache = cc.SpriteFrameCache:getInstance()
		for index = 1, 99, 1 do
			local textureName = string.format("worldmap/map_build_%d.png",index)
			if textureCache:addImage(textureName) then
				local plistName = string.format("worldmap/map_build_%d.plist",index)
				spriteFrameCache:addSpriteFrames(plistName,textureName)
			else
				break
			end
		end
		for index = 1, 99, 1 do
			local textureName = string.format("animeFps/battle/battle_%d.png",index)
			if textureCache:addImage(textureName) then
				local plistName = string.format("animeFps/battle/battle_%d.plist",index)
				spriteFrameCache:addSpriteFrames(plistName,textureName)
			else
				break
			end
		end
		spriteFrameCache:addSpriteFrames("worldmap/worldmap_image.plist","worldmap/worldmap_image.png")
	end
	
	m_DefaultScale = cc.clampf(m_DefaultScale, c_min_scale, c_max_scale)
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	rootLayer:ignoreAnchorPointForPosition(false)
	rootLayer:setAnchorPoint(cc.p(0.0,0.0))
	rootLayer:setPosition(cc.p(0.0,0.0))
	rootLayer:setContentSize(cc.size(0.0,0.0))
	
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
		if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_worldMap_1, 0.5 , false)
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_worldMap_2, 25 , false)
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_worldMap_3, 60 , false)
			if isMapTest == true then
				schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(require("game.mapcitybattle.worldMapLayer_uiLayer").onMapUpdate, 8 , false)
			end
			--schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_worldMap_4, 10 , false)
			g_gameStateManager.tryNoticeFirstInGame()
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
		end
	end
	rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	m_EventDispatcher = cc.Director:getInstance():getEventDispatcher()
	
	
	--加载圈
	m_LoadingImage = HelperMD.createLoadingImage()
	rootLayer:addChild(m_LoadingImage,2)
	m_LoadingImage:lua_Hide()
	
	
	--回城箭头
--	m_HomeArrow = HelperMD.createHomeDistanceArrow(g_display.center, g_display.visibleSize.height * 0.28, g_display.visibleSize.width * 0.35 )
--	rootLayer:addChild(m_HomeArrow,3)
	
	
	m_ChangeScaleNode = cc.Node:create()
	m_ChangeScaleNode:ignoreAnchorPointForPosition(false)
	m_ChangeScaleNode:setAnchorPoint(cc.p(0.5,0.5))
	m_ChangeScaleNode:setPosition(g_display.center)
	m_ChangeScaleNode:setContentSize(g_display.size)
	rootLayer:addChild(m_ChangeScaleNode,1)
	
	
	m_MiddleNode = cc.Node:create()
	m_MiddleNode:ignoreAnchorPointForPosition(false)
	m_MiddleNode:setAnchorPoint(cc.p(0.5,0.5))
	m_MiddleNode:setPosition(g_display.center)
	m_MiddleNode:setContentSize(g_display.size)
	m_ChangeScaleNode:addChild(m_MiddleNode,1)
	
	--m_MiddleNode:setScale(0.2)
	
	m_PerspectiveNode = cc.Node:create()
	m_PerspectiveNode:ignoreAnchorPointForPosition(false)
	m_PerspectiveNode:setAnchorPoint(cc.p(0.5,0.5))
	m_PerspectiveNode:setPosition(g_display.center)
	m_PerspectiveNode:setContentSize(g_display.size)
	m_PerspectiveNode:setRotation3D(cc.vec3(HelperMD.m_Angle,0.0,0.0))
	--m_PerspectiveNode:runAction(cc.RotateTo:create(1.5,cc.vec3(HelperMD.m_Angle,0.0,0.0)))
	m_MiddleNode:addChild(m_PerspectiveNode,1)
	
	
	--ScrollView的容器 
	m_Container = cc.Node:create()
	m_Container:setContentSize(HelperMD.m_MapContentSize)
	
	--地图底层
	local tmxLayer = ccexp.TMXTiledMap:create(string.format("worldmap/mapRes/map_city_battle_%d.tmx",map_type or 1))
	m_Container:addChild(tmxLayer,0)
	
	--建筑层
	m_BuildNode = HelperMD.createNodeInContainer()
	--m_BuildNode:setVisible(false)
	m_Container:addChild(m_BuildNode,1)
	
	
	--建筑特效层
	m_BuildEffectNode = HelperMD.createNodeInContainer()
	m_Container:addChild(m_BuildEffectNode,2)
	
	
	--建筑中级特效层
	m_BuildEffectMidNode = HelperMD.createNodeInContainer()
	m_Container:addChild(m_BuildEffectMidNode,3)
	
	
	--建筑标题层
	m_BuildTitleNode = HelperMD.createNodeInContainer(true)
	m_Container:addChild(m_BuildTitleNode,4)
	
	
	--行军层
	m_QueueMoveNode = HelperMD.createNodeInContainer()
	m_Container:addChild(m_QueueMoveNode,5)
	
	
	--建筑顶层特效层
	m_BuildEffectTopNode = HelperMD.createNodeInContainer()
	m_Container:addChild(m_BuildEffectTopNode,6)
	
	
	--攻击特效
	m_AutoEffectNode = HelperMD.createNodeInContainer()
	m_Container:addChild(m_AutoEffectNode,7)
	
	
	--touch_mask层
	m_TouchMaskNode = HelperMD.createNodeInContainer()
	m_Container:addChild(m_TouchMaskNode,8)
	
	
	--菜单层
	m_MenuNode = HelperMD.createNodeInContainer(true)
	m_Container:addChild(m_MenuNode,9)
	
	
	--放置层
	m_InputNode = HelperMD.createNodeInContainer()
	m_Container:addChild(m_InputNode,10)
	
	--迷雾层
	m_FogNode = HelperMD.createNodeInContainer()
	m_Container:addChild(m_FogNode,11)

	
	--ScrollView
	do
		m_MapScroll = lhs.MapScrollViewPerspective:create(cc.size(g_display.visibleSize.width + HelperMD.m_ViewOffset.x, g_display.visibleSize.height + HelperMD.m_ViewOffset.y),m_Container)
		m_MapScroll:setContentSize(HelperMD.m_MapContentSize)
		m_MapScroll:setBounceable(false)
		m_MapScroll:setClippingToBounds(false)
		m_MapScroll:setIsFullScreenTouch(true)
		m_MapScroll:setMinScale(c_min_scale)
		m_MapScroll:setMaxScale(c_max_scale)
		m_MapScroll:setZoomScale(m_DefaultScale)--default
		m_MapScroll:setPosition(cc.p(g_display.left_bottom.x - HelperMD.m_ViewOffset.x * 0.5, g_display.left_bottom.y - HelperMD.m_ViewOffset.y * 0.382))
		m_MapScroll:setDelegate()
		
		--边缘有一个区域是不可移动的 再算上1的误差 side
		m_MapScroll:openParallelogramClamp(
			cc.p(HelperMD.m_MpaParallelogram.posT.x , HelperMD.m_MpaParallelogram.posT.y - HelperMD.m_AreaContentSize.height - 1)
			, cc.p(HelperMD.m_MpaParallelogram.posL.x + HelperMD.m_AreaContentSize.width + 1 , HelperMD.m_MpaParallelogram.posL.y )
			, cc.p(HelperMD.m_MpaParallelogram.posB.x , HelperMD.m_MpaParallelogram.posB.y + HelperMD.m_AreaContentSize.height + 1)
			, cc.p(HelperMD.m_MpaParallelogram.posR.x - HelperMD.m_AreaContentSize.width - 1 , HelperMD.m_MpaParallelogram.posR.y ) )
		m_PerspectiveNode:addChild(m_MapScroll,1)
	end
	
	
	
	--ScrollView 的事件处理
	do
		local function onScrollViewDidScroll()
			if m_MenuNode:getChildByTag(c_tag_smallMenu_team) == nil then --队伍菜单出现的时候是特殊情况
				m_EventDispatcher:setDiscardAllTouchEndEventToCancelled(m_MapScroll)
			end
			local lookCenterPosition = getPosition_CurrentLookAt()
			local bigTileIndex = HelperMD.position_2_bigTileIndex(lookCenterPosition)
			checkAndChangeArea(bigTileIndex)
			--m_HomeArrow.lua_arrowUpdate(bigTileIndex , g_cityBattlePlayerData.GetPosition() , lookCenterPosition)
			require("game.mapcitybattle.worldMapLayer_uiLayer").updateShow_bigTileIndex(bigTileIndex)
			require("game.mapcitybattle.worldMapLayer_uiLayer").updateShow_arrow(bigTileIndex , g_cityBattlePlayerData.GetPosition() , lookCenterPosition)
		end
		
		local function onScrollViewDidZoom()
			m_DefaultScale = m_MapScroll:getZoomScale()
			if m_MenuNode:getChildByTag(c_tag_smallMenu_team) == nil then --队伍菜单出现的时候是特殊情况
				m_EventDispatcher:setDiscardAllTouchEndEventToCancelled(m_MapScroll)
			end
		end
		
		local boundaryTipsTime = os.time()
		local function onBoundary(boundaryType)
			local ct = os.time()
			if ct - boundaryTipsTime > 2 then
				boundaryTipsTime = ct
				g_airBox.show(g_tr("worldmap_Boundary_"..tostring(boundaryType)),2)
			end
		end
		
		m_MapScroll:registerScriptHandler(onScrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
		m_MapScroll:registerScriptHandler(onScrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
		m_MapScroll:registerScriptBoundaryHandler(cToolsForLua:pushHandlerForlua(onBoundary))
	end
	


	--m_BuildNode 的触摸 (目前空地的触摸也在这里)
	do
		local function onTouchBegan_BuildNode(touch, event)
			return true
		end

		local function onTouchMoved_BuildNode(touch, event)
		end

		local function onTouchEnded_BuildNode(touch, event)
			local position = worldPosition_2_position(touch:getLocation())
			if HelperMD.mapParallelogram_Contains_Position(position) then
				onClickBigTileIndex(HelperMD.position_2_bigTileIndex(position))
			end
		end

		local function onTouchCancelled_BuildNode(touch, event)
		end
		
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(true)
		touchListener:registerScriptHandler(onTouchBegan_BuildNode,cc.Handler.EVENT_TOUCH_BEGAN )
		touchListener:registerScriptHandler(onTouchMoved_BuildNode,cc.Handler.EVENT_TOUCH_MOVED )
		touchListener:registerScriptHandler(onTouchEnded_BuildNode,cc.Handler.EVENT_TOUCH_ENDED )
		touchListener:registerScriptHandler(onTouchCancelled_BuildNode,cc.Handler.EVENT_TOUCH_CANCELLED )
		m_EventDispatcher:addEventListenerWithSceneGraphPriority(touchListener,m_BuildNode)
	end
	
	
	
	--m_MenuNode 的触摸
	do
		local function onTouchBegan_MenuNode(touch, event)
			m_WillOpenSmallMenuData = nil
			return true
		end
		local function onTouchEnded_MenuNode(touch, event)
			closeSmallMenu()
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(false)
		touchListener:registerScriptHandler(onTouchBegan_MenuNode,cc.Handler.EVENT_TOUCH_BEGAN )
		touchListener:registerScriptHandler(onTouchEnded_MenuNode,cc.Handler.EVENT_TOUCH_ENDED )
		m_EventDispatcher:addEventListenerWithSceneGraphPriority(touchListener,m_MenuNode)
	end
	
	
	
	--m_InputNode 的触摸
	do
		local function onTouchBegan_MenuNode(touch, event)
			return true
		end
		local function onTouchEnded_MenuNode(touch, event)
			closeInputMenu()
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(false)
		touchListener:registerScriptHandler(onTouchBegan_MenuNode,cc.Handler.EVENT_TOUCH_BEGAN )
		touchListener:registerScriptHandler(onTouchEnded_MenuNode,cc.Handler.EVENT_TOUCH_ENDED )
		m_EventDispatcher:addEventListenerWithSceneGraphPriority(touchListener,m_InputNode)
	end
	
	
	--显示到指定大瓦片索引
	changeBigTileIndex_Manual( bigTileIndex )	--这里不能使用缓动
	
	local function onQueueTcp(obj, tcpData)
		if tcpData.msg == "backHome" then
			RequestTimeMD.RequestSecondsAfter(g_Consts.BattleScriptDelayTime, RequestTimeMD.m_Event_want.myQueueEnd)
		elseif tcpData.msg == "battleWin" then

		elseif tcpData.msg == "battleLose" then

		elseif tcpData.msg == "arriveDest" then
			
		end
	end
	g_gameCommon.removeAllEventHandlers(worldMapLayer_bigMap)
	g_gameCommon.addEventHandler(g_Consts.CustomEvent.Queue, onQueueTcp, worldMapLayer_bigMap)
	
	--第一次必须请求
	requestMapAllData_Manual()
	
	cc.Director:getInstance():setNextDeltaTimeZero(true)
	
--	--如果没有选择复活点，自动弹出选择界面
--	if tonumber(g_cityBattlePlayerData.GetData().is_in_map) == 0 and require("game.mapcitybattle.worldMapLayer_bigMap").isMapTest ~= true then
--		require("game.uilayer.citybattle_map_ui.GuildWarFuHuoDianLayer").show()
--	end
	
	if tonumber(g_cityBattlePlayerData.GetData().is_in_map) == 0 and require("game.mapcitybattle.worldMapLayer_bigMap").isMapTest ~= true then
		local layer = require("game.uilayer.citybattle_map_ui.GuildWarFuHuoDianLayer").show()
		if layer then --城内战攻击方
			if  g_cityBattleInfoData.GetCurrentMapType() == 1 then --城门站
				if g_cityBattleInfoData.IsAttacker() then 
					layer:onClickFuHuoDian(g_cityBattlePlayerData.GetData().camp_id,true)
				end
			else
				if g_cityBattleInfoData.IsAttacker() then --城内站
					layer:onClickFuHuoDian(6,true)
				else
					layer:onClickFuHuoDian(7,true)
				end
			end

		end
	end
	--如果沒有選擇過戰場
	--[[
	local p = g_cityBattlePlayerData.GetData()
	if p.status == 0 then
		g_sceneManager.addNodeForUI(require("game.uilayer.drill.PreCrossView").new())
	end
	]]
	return rootLayer
end


--请求地图所有数据
local function _requestMapAllData(isAsync)
		
		if isMapTest == true then
			return
		end
		
		if isAsync then
			local battleStatus = g_cityBattleInfoData.GetData().status
			if battleStatus == g_cityBattleInfoData.StatusType.STATUS_FINISH then
				return 
			end
		end

		m_LoadingImage:lua_show()
		RequestTimeMD.Reset()
		local centerAreaID = m_CurrentAreaIDs[5]
		local function onRecvShowBlockNQueue(mapResult, msgData)
			if m_Root == nil then
				return
			end
			m_LoadingImage:lua_Hide()
			if mapResult==true then
				onMsgMapAllData(msgData)
--				if g_cityBattleInfoData.IsAttacker() then
--					g_airBox.show("IsAttack")
--				else
--					g_airBox.show("IsDefense")
--				end
			end
		end
--		local requestBlocks = {}
--		for k , v in pairs(m_CurrentAreaIDs) do
--			if v and v ~= -1 then
--				requestBlocks[(#requestBlocks) + 1] = v
--			end
--		end


			--优化过这里不用发送area list
--		local areaList = g_cityBattleInfoData.GetCurrentArea()
--		--for test
--		areaList = {1,2,3,4,5}

		g_sgHttp.postData("City_Battle/showBlockNQueue", { queueList = {centerAreaID, } }, onRecvShowBlockNQueue, isAsync) --请求地图

end


--手动强制同步请求数据,并且强制刷新当前显示
function forceRequestMapAllDataAndUpdateShow_Manual()
	if m_Root == nil then
		return
	end
	m_ForceUpdateShowFlag = true
	_requestMapAllData(false)
	m_ForceUpdateShowFlag = false
end


--手动请求数据
function requestMapAllData_Manual(isAsync)
	if m_Root == nil then 
		return
	end
	if isAsync == nil then
		isAsync = false
	end
	_requestMapAllData(isAsync)
end

--判定占领某区域的camp（城内战）
--返回0 为中立 ,不为0 则为占领方的camp_id
function getOccupationCampBySecionId(secion)
	local sideList = {}
	local idx = 1
	local secionInfo = m_playerSecitonCountList[secion]
	if secionInfo then
		for camp_id, cnt in pairs(secionInfo) do
			if cnt > 0 then
				sideList[idx] = {camp_id = camp_id,count = cnt}
				idx = idx + 1
			end
		end
	end
	
	local campId = 0
	local campA = sideList[1]
	local campB = sideList[2]
	if campA and campB then
		if campA.count == campB.count then
			campId = 0
		elseif campA.count > campB.count then
			campId = campA.camp_id
		else
			campId = campB.camp_id
		end
	elseif campA then
		campId = campA.camp_id
	elseif campB then
		campId = campB.camp_id
	end
	return campId
end

--请求的块消息返回
function onMsgMapAllData(msgData)
	if m_Root == nil then 
		return
	end
	
	local mapMsgData = msgData.block
	local queueMsgData = msgData.queue
	local battleInfoMsgData = msgData.battleInfo
	local battleInfoTopPlayerData = msgData.topPlayer
	local spBuildMsgData = mapMsgData --msgData.SpBuild --接口有改动，block带回请求区域的信息之外，还会带回所有的特殊建筑信息
	local crossPlayerData = msgData.citybattlePlayer
	
	do --优先给spbuild缓存 因为建筑创建和更新可能需要依赖最新的spbuild
		if spBuildMsgData then
			m_CurrentSpBuildDatas = spBuildMsgData
		end
		g_cityBattleMapSpBuildData.setSpBuildData(m_CurrentSpBuildDatas)
	end
	
	
	m_playerSecitonCountList = {
		--[secion] = {[camp_id] = 0 ,[camp_id]= 1}, --key 为camp_id var 为数量
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
	}
	
	do--处理地图块消息
		if mapMsgData then
			--优先处理删除
			if m_ForceUpdateShowFlag == true then
				for k , v in pairs(m_CurrentAreaDatas.Map) do
					removeSingleBuild_msgData(v) --remove
					m_CurrentAreaDatas.Map[k] = nil
				end
			else
				for k , v in pairs(m_CurrentAreaDatas.Map) do
					if mapMsgData.Map[k] == nil then
						removeSingleBuild_msgData(v) --remove
						m_CurrentAreaDatas.Map[k] = nil
					end
				end
			end
			
			--给缓存
			m_CurrentAreaDatas.Player = mapMsgData.Player
			m_CurrentAreaDatas.Camp = mapMsgData.Camp
			
			m_selfGuildPlayers = {}
			--再处理增加,更新,检测
			for k , v in pairs(mapMsgData.Map) do
			
				if v.map_element_origin_id == HelperMD.m_MapOriginType.player_home then
					if m_playerSecitonCountList[v.section] then
						if m_playerSecitonCountList[v.section][v.camp_id] == nil then
							m_playerSecitonCountList[v.section][v.camp_id] = 0
						end
						m_playerSecitonCountList[v.section][v.camp_id] = m_playerSecitonCountList[v.section][v.camp_id] + 1
					end
				end
				
				if v.map_element_origin_id == HelperMD.m_MapOriginType.player_home
				and v.camp_id == g_cityBattlePlayerData.getCampId() then
					table.insert(m_selfGuildPlayers,v)
				end
			
			
				local originData = m_CurrentAreaDatas.Map[k]
				if originData == nil then
					addSingleBuild_msgData(v) --add
				elseif originData.rowversion < v.rowversion then
					updateSingleBuild_msgData(v) --update
				else
					checkSingleBuild_msgData(v) --check
				end
			end
			
			--给缓存
			m_CurrentAreaDatas.Map = mapMsgData.Map
		end
	end
	
	do--处理队列消息
	
		if queueMsgData then
			local notice = {}
			
			--优先处理删除
			if m_ForceUpdateShowFlag == true then
				for k , v in pairs(m_CurrentQueueDatas.Queue) do
					--remove
					notice[(#notice) + 1] = { [1] = 1 , [2] = v }
					removeSingleQueueDisplay(v)
					m_CurrentQueueDatas.Queue[k] = nil
				end
			else
				for k , v in pairs(m_CurrentQueueDatas.Queue) do
					if queueMsgData.Queue[k] == nil then
						--remove
						notice[(#notice) + 1] = { [1] = 1 , [2] = v }
						removeSingleQueueDisplay(v)
						m_CurrentQueueDatas.Queue[k] = nil
					end
				end
			end
			
			--给缓存
			m_CurrentQueueDatas.Player = queueMsgData.Player
			m_CurrentQueueDatas.Camp = queueMsgData.Camp
			m_CurrentQueueDatas.MapElement = queueMsgData.MapElement
			
			--再处理增加,更新,检测
			for k , v in pairs(queueMsgData.Queue) do
				local originData = m_CurrentQueueDatas.Queue[k]
				if originData == nil then
					notice[(#notice) + 1] = { [1] = 2 , [2] = v }
					addSingleQueueDisplay(v) --add
				elseif originData.rowversion < v.rowversion then
					notice[(#notice) + 1] = { [1] = 3 , [2] = v }
					updateSingleQueueDisplay(v) --update
				end
			end
			
			--给缓存
			m_CurrentQueueDatas.Queue = queueMsgData.Queue
			
			--通知
			for k , v in ipairs(notice) do
				local tp = v[1]
				local data = v[2]
				if tp == 1 then
					removeQueueNotice(data)
				elseif tp == 2 then
					addQueueNotice(data)
				elseif tp == 3 then
					changedQueueNotice(data)
				end
			end
			
		end
		
	end
	
	g_cityBattleInfoData.SetData(battleInfoMsgData)
	g_cityBattleInfoData.SetTopPlayerData(battleInfoTopPlayerData)
	g_cityBattleInfoData.NotificationUpdateShow()
	
	if crossPlayerData then
		g_cityBattlePlayerData.SetData(crossPlayerData)
		g_cityBattlePlayerData.NotificationUpdateShow()
	end
	
	--dump(m_playerSecitonCountList)
	
	
	require("game.mapcitybattle.worldMapLayer_uiLayer").onMapUpdate(msgData)
	
	--[[local hasSelectedOnMap = g_cityBattlePlayerData.hasSelectedOnMap()
	if not hasSelectedOnMap then
		require("game.uilayer.citybattle_map_ui.GuildWarFuHuoDianLayer").show()
	end]]
	
	--处理自动弹出菜单
	processAutoOpenInterface()
	
end


--得到当前地图数据
function getCurrentAreaDatas()
	return m_CurrentAreaDatas
end


--得到当前队列数据
function getCurrentQueueDatas()
	return m_CurrentQueueDatas
end


--得到自己当前队列在to_map_id上干queueType类型事件的队列数据
function getSelfQueueDoing_bigTileIndex_queueType(to_map_id, queueType)
	local myPlayerID = g_cityBattlePlayerData.GetData().player_id
	local currentQueueDatas = getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		if v.player_id == myPlayerID and v.to_map_id == to_map_id and v.type == queueType then
			return v
		end
	end
	return nil
end


--update1
function update_worldMap_1(dt)
	if m_Root == nil then 
		return
	end
	do --请求地图数据
		if RequestTimeMD.CheckNeedRequest() then
			_requestMapAllData(true)
		end
	end
--	do --国王战开始动画
--		local st = g_kingInfo.kingBattleSoonTime()
--		if st > 2 and st < 6 then
--			require("game.effectlayer.kingTime").show()
--		end
--	end
end


--update2
function update_worldMap_2(dt)
	if m_Root == nil then 
		return
	end
	--g_cityBattlePlayerData.RequestDataAsync()
end


--update3
function update_worldMap_3(dt)
	if m_Root == nil then 
		return
	end
	--g_kingInfo.RequestData_Async()
end

--update4
function update_worldMap_4(dt)
	if m_Root == nil or isMapTest then 
		return
	end
	
--	local battleStatus = g_cityBattleInfoData.GetData().status
--	if battleStatus ~= g_cityBattleInfoData.StatusType.STATUS_FINISH then
--		g_cityBattleCampPlayersData.RequestDataAsync()
--	end
end

function getSelfGuildPlayerBuilds()
	return m_selfGuildPlayers
end

--删除一个建筑（可能是无数个块,以及跨区域）
function removeSingleBuild_msgData(serverData)
	local idString = tostring(serverData.id)
	for k , v in pairs(m_CurrentAreaIDs) do
		local tmxMap = m_BuildNode:getChildByTag(v)
		if tmxMap then
			local tileLayer = tmxMap:getChildByName("layer_top")
			if tileLayer then
				tileLayer:removeTileWithCustomName(idString)
			end
		end
	end
	local configData = g_data.map_element[tonumber(serverData.map_element_id)]
	for k , v in ipairs(configData.x_y) do
		if v[1] == 0 and v[2] == 0 then
			local bigTileIndex = cc.p(serverData.x + v[1],serverData.y + v[2])
			removeSingleBuildTitle(serverData,configData,bigTileIndex)
			removeSingleBuildEffect(serverData,configData,bigTileIndex)
			if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort 
			--or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche
			then
				removeSingleBuildRange(serverData,configData,bigTileIndex)
			end
		end
	end
end


--增加一个建筑（可能是无数个块,以及跨区域）
function addSingleBuild_msgData(serverData)
	local idString = tostring(serverData.id)
	local configData = g_data.map_element[tonumber(serverData.map_element_id)]
	if configData == nil then
		g_airBox.show("can not found map_element_id : "..tostring(serverData.map_element_id), 3)
	end
	for k , v in ipairs(configData.x_y) do
		local bigTileIndex = cc.p(serverData.x + v[1], serverData.y + v[2])
		local areaIndex = HelperMD.bigTileIndex_2_areaIndex(bigTileIndex)
		local areaId = HelperMD.areaIndex_2_areaId(areaIndex)
		local tmxMap = m_BuildNode:getChildByTag(areaId)
		if tmxMap then
			if v[1] == 0 and v[2] == 0 then
				local ZOrder = HelperMD.bigTileIndex_2_tileZOrder(bigTileIndex)
				addSingleBuildTitle(serverData,configData,bigTileIndex,ZOrder)
				addSingleBuildEffect(serverData,configData,bigTileIndex,ZOrder)
				if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort
				--or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche
					then
					addSingleBuildRange(serverData,configData,bigTileIndex,ZOrder)
				end
			end
			local tileLayer = tmxMap:getChildByName("layer_top")
			if tileLayer then
				local areaTileIndex	= HelperMD.bigTileIndex_2_areaTileIndex(bigTileIndex)
				if configData.origin_id == HelperMD.m_MapOriginType.monster_small then
					--小怪类型的建筑
					assert((#configData.x_y) == 1)
					tileLayer:addCustomTile(BuildDisplayMD.create_smallMonster(configData, serverData), areaTileIndex.x, areaTileIndex.y, tileLayer:getZOrderWithIndex(areaTileIndex) + c_CustomZOrderOffset, idString)
				elseif configData.origin_id == HelperMD.m_MapOriginType.monster_boss then
					--BOSS怪类型的建筑
					assert((#configData.x_y) == 1)
					tileLayer:addCustomTile(BuildDisplayMD.create_bossMonster(configData, serverData), areaTileIndex.x, areaTileIndex.y, tileLayer:getZOrderWithIndex(areaTileIndex) + c_CustomZOrderOffset, idString)
				elseif configData.origin_id == HelperMD.m_MapOriginType.heshibi then
					--和氏璧
					assert((#configData.x_y) == 1)
					tileLayer:addCustomTile(BuildDisplayMD.create_heshibi(configData, serverData), areaTileIndex.x, areaTileIndex.y, tileLayer:getZOrderWithIndex(areaTileIndex) + c_CustomZOrderOffset, idString)
				else
					--图片建筑
					tileLayer:addCustomTile(BuildDisplayMD.create_static(k, configData, serverData), areaTileIndex.x, areaTileIndex.y, tileLayer:getZOrderWithIndex(areaTileIndex) + c_CustomZOrderOffset, idString)
				end
			end
		end
		
		
	end

end


--更新一个建筑（可能是无数个块,以及跨区域）
function updateSingleBuild_msgData(serverData)
	--目前更新的做法是先删除再创建
	removeSingleBuild_msgData(serverData)
	addSingleBuild_msgData(serverData)
end


--检测一个建筑（可能是无数个块,以及跨区域）
--目前只是检查是否有能显示却未显示的部分(快速移出去再移动进来,或者一半出去一半进来,都有可能)
function checkSingleBuild_msgData(serverData)
	local idString = tostring(serverData.id)
	local configData = g_data.map_element[serverData.map_element_id]
	for k , v in ipairs(configData.x_y) do
		local bigTileIndex = cc.p(serverData.x + v[1],serverData.y + v[2])
		local areaId = HelperMD.areaIndex_2_areaId( HelperMD.bigTileIndex_2_areaIndex( bigTileIndex ) )
		if areaId ~= -1 then
			local tmxMap = m_BuildNode:getChildByTag(areaId)
			if tmxMap then
				local tileLayer = tmxMap:getChildByName("layer_top")
				local tileData = tileLayer:getTileDataWithIndex( HelperMD.bigTileIndex_2_areaTileIndex(bigTileIndex) )
				if tileData == nil or tileData:getCustomName() ~= idString then
					--目前检测到需要补充显示的做法是先删除再创建
					removeSingleBuild_msgData(serverData)
					addSingleBuild_msgData(serverData)
					return	--直接返回不用再检测下面的范围块
				end
			end
		end
	end
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort then
		--联盟堡垒有地域效果,特别检测地域效果
		local range_data = m_CurrentRanges[idString]
		if range_data then
			local getNameFunc = ((serverData.camp_id ~= 0 and serverData.camp_id == g_cityBattlePlayerData.getCampId()) and HelperMD.getImageNmaeWithSideTypeSelf or HelperMD.getImageNmaeWithSideTypeOther)
			for k1 , v1 in pairs(range_data.areas) do
				local tmxMap = m_BuildNode:getChildByTag(k1)
				if tmxMap then
					local tileLayer = tmxMap.lua_layer_mid_idArray[idString]
					if tileLayer == nil then
						--只处理没有加入过的情况
						tileLayer = tmxMap:lua_getWeightLowMid()
						tmxMap.lua_layer_mid_idArray[idString] = tileLayer
						tileLayer.lua_weight = tileLayer.lua_weight + 1
						for k2 , v2 in ipairs(v1) do
							tileLayer:addCustomTile(cc.Sprite:createWithSpriteFrameName(getNameFunc(v2.tp)), v2.ati.x, v2.ati.y, 0, idString)
						end
					end
				end
			end
		end
	end
	
	
--	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then
--		--投石车有地域效果,特别检测地域效果
--		
--		local range_data = m_CurrentRanges[idString]
--		if range_data then
--			local getNameFunc = g_cityBattleInfoData.IsSelfOccupationArea(tonumber(serverData.area)) and HelperMD.getImageNmaeWithSideTypeSelf or HelperMD.getImageNmaeWithSideTypeOther
--			for k1 , v1 in pairs(range_data.areas) do
--				local tmxMap = m_BuildNode:getChildByTag(k1)
--				if tmxMap then
--					local tileLayer = tmxMap.lua_layer_mid_idArray[idString]
--					if tileLayer == nil then
--						--只处理没有加入过的情况
--						tileLayer = tmxMap:lua_getWeightLowMid()
--						tmxMap.lua_layer_mid_idArray[idString] = tileLayer
--						tileLayer.lua_weight = tileLayer.lua_weight + 1
--						for k2 , v2 in ipairs(v1) do
--							tileLayer:addCustomTile(cc.Sprite:createWithSpriteFrameName(getNameFunc(v2.tp)), v2.ati.x, v2.ati.y, 0, idString)
--						end
--					end
--				end
--			end
--		end
--	end
end


--增加一个建筑的标题
function addSingleBuildTitle(serverData,configData,originBigTileIndex,ZOrder)
	local idString = tostring(serverData.id)
	
	--聯盟戰地圖不顯示等級
--	local lv_panel , lv_lable = BuildTitleMD.createLV(serverData, configData, originBigTileIndex)
--	if lv_panel then
--		m_BuildTitleNode:addChild(lv_panel, 0, "lp_"..idString)
--		m_BuildTitleNode:addChild(lv_lable, 1, "ll_"..idString)
--	end
	
	local title_image , title_label_1 , title_label_2 = BuildTitleMD.createTitle(serverData, configData, originBigTileIndex)
	if title_image then
		m_BuildTitleNode:addChild(title_image, 2, "tb_"..idString)
		m_BuildTitleNode:addChild(title_label_1, 3, "tl1_"..idString)
		if title_label_2 then
			m_BuildTitleNode:addChild(title_label_2, 4, "tl2_"..idString)
		end
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.monster_boss then
		--boss
		m_BuildTitleNode:addChild(BuildTitleMD.createBossMatch(serverData, configData, originBigTileIndex), 5, "bs_"..idString)
	end
end


--删除一个建筑的标题
function removeSingleBuildTitle(serverData,configData,originBigTileIndex)
	local idString = tostring(serverData.id)
	
--聯盟戰地圖不顯示等級
--	m_BuildTitleNode:removeChildByName("lp_"..idString)
--	m_BuildTitleNode:removeChildByName("ll_"..idString)

	m_BuildTitleNode:removeChildByName("tb_"..idString)
	m_BuildTitleNode:removeChildByName("tl1_"..idString)
	m_BuildTitleNode:removeChildByName("tl2_"..idString)
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.monster_boss then
		--boss
		m_BuildTitleNode:removeChildByName("bs_"..idString)
	end
end


--增加一个建筑的特效
function addSingleBuildEffect(serverData,configData,originBigTileIndex,ZOrder)
	local idString = tostring(serverData.id)
	
	--联盟战建筑
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gongchengchui then
		local buildDisplayEffect = BuildEffectMD.create_gongchengchui(serverData, configData, originBigTileIndex)
		if buildDisplayEffect then
			m_BuildEffectNode:addChild(buildDisplayEffect, ZOrder, idString.."guild_war_gongchengchui")
		end
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_chuangnu then
		local buildDisplayEffect = BuildEffectMD.create_chuangnu(serverData, configData, originBigTileIndex)
		if buildDisplayEffect then
			m_BuildEffectNode:addChild(buildDisplayEffect, ZOrder, idString.."guild_war_chuangnu")
		end
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_yunti then
		local buildDisplayEffect = BuildEffectMD.create_yunti(serverData, configData, originBigTileIndex)
		if buildDisplayEffect then
			m_BuildEffectNode:addChild(buildDisplayEffect, ZOrder, idString.."guild_war_yunti")
		end
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then
		local buildDisplayEffect = BuildEffectMD.create_toushiche(serverData, configData, originBigTileIndex)
		if buildDisplayEffect then
			m_BuildEffectNode:addChild(buildDisplayEffect, ZOrder, idString.."guild_war_toushiche")
		end
	end
	
	local low_node = BuildEffectMD.create_low(serverData, configData, originBigTileIndex)
	if low_node then
		m_BuildEffectNode:addChild(low_node, ZOrder, idString)
	end
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort then
		--堡垒修理
		local low_fort_repair = BuildEffectMD.create_low_guild_fort_repair(serverData, configData, originBigTileIndex)
		if low_fort_repair then
			m_BuildEffectNode:addChild(low_fort_repair, ZOrder, idString.."gr")
		end
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gate then
		local mid_gate_fire = BuildEffectMD.create_mid_gate_fire(serverData, configData, originBigTileIndex)
		if mid_gate_fire then
			m_BuildEffectMidNode:addChild(mid_gate_fire, 1, idString.."hfg")
		end
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.player_home then
		--主城着火
		local mid_home_fire = BuildEffectMD.create_mid_player_home_fire(serverData, configData, originBigTileIndex)
		if mid_home_fire then
			m_BuildEffectMidNode:addChild(mid_home_fire, 1, idString.."hf")
		end
		--主城防护罩
		local mid_home_avoid = BuildEffectMD.create_mid_player_home_avoid(serverData, configData, originBigTileIndex)
		if mid_home_avoid then
			m_BuildEffectMidNode:addChild(mid_home_avoid, 2, idString.."ha")
		end
		--主城和氏璧
		local mid_home_hsb = BuildEffectMD.create_mid_player_home_hsb(serverData, configData, originBigTileIndex)
		if mid_home_hsb then
			m_BuildEffectMidNode:addChild(mid_home_hsb, 3, idString.."hh")
		end
		--主城皇城战job
		local mid_home_job = BuildEffectMD.create_mid_player_home_job(serverData, configData, originBigTileIndex)
		if mid_home_job then
			m_BuildEffectMidNode:addChild(mid_home_job, 3, idString.."hj")
		end
		
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.camp_middle 
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.camp_low then
		--营寨防护罩
		local mid_camp_avoid = BuildEffectMD.create_mid_camp_avoid(serverData, configData, originBigTileIndex)
		if mid_camp_avoid then
			m_BuildEffectMidNode:addChild(mid_camp_avoid, 2, idString.."ca")
		end
	end
	
	local top_node = BuildEffectMD.create_top(serverData, configData, originBigTileIndex)
	if top_node then
		m_BuildEffectTopNode:addChild(top_node, ZOrder, idString)
	end
end


--删除一个建筑的特效
function removeSingleBuildEffect(serverData,configData,originBigTileIndex)
	local idString = tostring(serverData.id)
	m_BuildEffectNode:removeChildByName(idString)
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort then
		--堡垒修理
		m_BuildEffectNode:removeChildByName(idString.."gr")
	end
	
		--联盟战建筑
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gongchengchui then
		m_BuildEffectNode:removeChildByName(idString.."guild_war_gongchengchui")
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_chuangnu then
		m_BuildEffectNode:removeChildByName(idString.."guild_war_chuangnu")
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_yunti then
		m_BuildEffectNode:removeChildByName(idString.."guild_war_yunti")
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then
		m_BuildEffectNode:removeChildByName(idString.."guild_war_toushiche")
	end

	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gate then
		m_BuildEffectMidNode:removeChildByName(idString.."hfg")
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.player_home then
		--主城着火
		m_BuildEffectMidNode:removeChildByName(idString.."hf")
		--主城防护罩
		m_BuildEffectMidNode:removeChildByName(idString.."ha")
		--主城和氏璧
		m_BuildEffectMidNode:removeChildByName(idString.."hh")
		--主城皇城战job
		m_BuildEffectMidNode:removeChildByName(idString.."hj")
	end
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.camp_middle 
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.camp_low then
		--营寨防护罩
		m_BuildEffectMidNode:removeChildByName(idString.."ca")
	end
	m_BuildEffectTopNode:removeChildByName(idString)
end


--增加一个建筑的区域地标
function addSingleBuildRange(serverData,configData,originBigTileIndex,ZOrder)
	local idString = tostring(serverData.id)
	local range_data = HelperMD.createRangeData(configData,originBigTileIndex)
	m_CurrentRanges[idString] = range_data
	local getNameFunc = ((serverData.getCampId ~= 0 and serverData.getCampId == g_cityBattlePlayerData.getCampId() ) and HelperMD.getImageNmaeWithSideTypeSelf or HelperMD.getImageNmaeWithSideTypeOther)
--	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then
--		getNameFunc = g_cityBattleInfoData.IsSelfOccupationArea(tonumber(serverData.area)) and HelperMD.getImageNmaeWithSideTypeSelf or HelperMD.getImageNmaeWithSideTypeOther
--	end
	
	for k1 , v1 in pairs(range_data.areas) do
		local tmxMap = m_BuildNode:getChildByTag(k1)
		if tmxMap then
			local tileLayer = tmxMap:lua_getWeightLowMid()
			tmxMap.lua_layer_mid_idArray[idString] = tileLayer
			tileLayer.lua_weight = tileLayer.lua_weight + 1
			for k2 , v2 in ipairs(v1) do
				tileLayer:addCustomTile(cc.Sprite:createWithSpriteFrameName(getNameFunc(v2.tp)), v2.ati.x, v2.ati.y, 0, idString)
			end
		end
	end
end


--删除一个建筑的区域地标
function removeSingleBuildRange(serverData,configData,originBigTileIndex)
	local idString = tostring(serverData.id)
	local range_data = m_CurrentRanges[idString]
	if range_data ~= nil then
		m_CurrentRanges[idString] = nil
		for k1 , v1 in pairs(range_data.areas) do
			local tmxMap = m_BuildNode:getChildByTag(k1)
			if tmxMap then
				local tileLayer = tmxMap.lua_layer_mid_idArray[idString]
				if tileLayer then
					tmxMap.lua_layer_mid_idArray[idString] = nil
					tileLayer.lua_weight = tileLayer.lua_weight - 1
					tileLayer:removeTileWithCustomName(idString)
				end
			end
		end
	end
end


--删除一个队列数据显示（极有可能会改变建筑显示状态）
function removeSingleQueueDisplay(serverData)
	if QueueHelperMD.isNeedLine( serverData ) == true then
		--line
		m_QueueMoveNode:removeChildByName("line"..tostring(serverData.id))
		--team
		m_QueueMoveNode:removeChildByName("team"..tostring(serverData.id))
		
		lineNodes["line"..tostring(serverData.id)] = nil
		teamNodes["line"..tostring(serverData.id)] = nil
	end
end


--增加一个队列数据显示（极有可能会改变建筑显示状态）
function addSingleQueueDisplay(serverData)
	if QueueHelperMD.isNeedLine( serverData ) == true then
		
		local positionData = {}
		local from_map_element_data = ( (serverData.from_map_id ~= 0) and (m_CurrentQueueDatas.MapElement[tostring(serverData.from_map_id)]) or nil )
		if from_map_element_data then
			dump(from_map_element_data)
			local fromConfigData = g_data.map_element[from_map_element_data.map_element_id]
			if fromConfigData.origin_id ~= HelperMD.m_MapOriginType.scenery then
				positionData.beginPosition = HelperMD.bigTileIndex_2_buildCenterPosition(cc.p(serverData.from_x,serverData.from_y), fromConfigData)
			else
				positionData.beginPosition = HelperMD.bigTileIndex_2_positionCenter(cc.p(serverData.from_x,serverData.from_y))
			end
		else
			positionData.beginPosition = HelperMD.bigTileIndex_2_positionCenter(cc.p(serverData.from_x,serverData.from_y))
		end
		local to_map_element_data = ( (serverData.to_map_id ~= 0) and (m_CurrentQueueDatas.MapElement[tostring(serverData.to_map_id)]) or nil )
		if to_map_element_data then
			local toConfigData = g_data.map_element[to_map_element_data.map_element_id]
			if toConfigData.origin_id ~= HelperMD.m_MapOriginType.scenery then
				positionData.endPosition = HelperMD.bigTileIndex_2_buildCenterPosition(cc.p(serverData.to_x,serverData.to_y), toConfigData)
			else
				positionData.endPosition = HelperMD.bigTileIndex_2_positionCenter(cc.p(serverData.to_x,serverData.to_y))
			end
		else
			positionData.endPosition = HelperMD.bigTileIndex_2_positionCenter(cc.p(serverData.to_x,serverData.to_y))
		end
		
		--line
		local lineNode = LineMD.create_with_queueServerData(serverData, positionData)
		m_QueueMoveNode:addChild(lineNode, 1, "line"..tostring(serverData.id))
		if not lineNode.isAboutSelfQueue then
			lineNodes["line"..tostring(serverData.id)] = lineNode
			local isNeedShow = require("game.mapcitybattle.worldMapLayer_uiLayer").isNeedShowOtherArmy()
			lineNode:setVisible(isNeedShow)
		end
		
		
		--team
		local teamNode = TeamRuningMD.create_with_queueServerData(serverData, positionData)
		m_QueueMoveNode:addChild(teamNode,2,"team"..tostring(serverData.id))
		if not teamNode.isAboutSelfQueue then
			teamNodes["line"..tostring(serverData.id)] = teamNode
			local isNeedShow = require("game.mapcitybattle.worldMapLayer_uiLayer").isNeedShowOtherArmy()
			teamNode:setVisible(isNeedShow)
		end
		
	end
end

--是否显示非自己相关的部队
function setOthersArmyShow(visible)
	for key, var in pairs(lineNodes) do
		var:setVisible(visible)
	end
	
	for key, var in pairs(teamNodes) do
		var:setVisible(visible)
	end
end


--更新一个队列数据显示（极有可能会改变建筑显示状态）
function updateSingleQueueDisplay(serverData)
	--目前更新的做法是先删除再创建
	removeSingleQueueDisplay(serverData)
	addSingleQueueDisplay(serverData)
end


--加队伍时的通知
function addQueueNotice(serverData)
	local myPlayerID = g_cityBattlePlayerData.GetData().player_id
	
	--队伍返回
	if serverData.player_id == myPlayerID
		and QueueHelperMD.isNeedBackNotice(serverData)
		and serverData.create_time >= g_clock.getCurServerTime() - 7
			then
		g_airBox.show(g_tr("queue_back_notice"))
	end
	
	--驻守
	if serverData.player_id == myPlayerID or ( serverData.camp_id ~= 0 and serverData.camp_id == g_cityBattlePlayerData.getCampId() ) then
		if QueueHelperMD.isCouldPossiblyChangeMap(serverData) then
			for k , v in pairs(m_CurrentAreaDatas.Map) do
				if serverData.from_x == v.x and serverData.from_y == v.y then
					removeSingleBuild_msgData(v)
					addSingleBuild_msgData(v)
					break
				end
			end
			if serverData.from_x ~= serverData.to_x or serverData.from_y ~= serverData.to_y then
				for k , v in pairs(m_CurrentAreaDatas.Map) do
					if serverData.to_x == v.x and serverData.to_y == v.y then
						removeSingleBuild_msgData(v)
						addSingleBuild_msgData(v)
						break
					end
				end
			end
		end
	end
end


--队伍产生变化时的通知
function changedQueueNotice(serverData)
	
end


--删除队伍的通知
function removeQueueNotice(serverData)
	
	local myPlayerID = g_cityBattlePlayerData.GetData().player_id
	
	if serverData.player_id == myPlayerID then
		if QueueHelperMD.isNeedBackRequestArmy(serverData) then
			--自己队伍返回后更新一下army数据
			g_groundData.RequestSycCityBattleData()
		end
	end
	
	--驻守
	if serverData.player_id == myPlayerID or ( serverData.camp_id ~= 0 and serverData.camp_id == g_cityBattlePlayerData.getCampId() ) then
		if QueueHelperMD.isCouldPossiblyChangeMap(serverData) then
			for k , v in pairs(m_CurrentAreaDatas.Map) do
				if serverData.from_x == v.x and serverData.from_y == v.y then
					removeSingleBuild_msgData(v)
					addSingleBuild_msgData(v)
					break
				end
			end
			if serverData.from_x ~= serverData.to_x or serverData.from_y ~= serverData.to_y then
				for k , v in pairs(m_CurrentAreaDatas.Map) do
					if serverData.to_x == v.x and serverData.to_y == v.y then
						removeSingleBuild_msgData(v)
						addSingleBuild_msgData(v)
						break
					end
				end
			end
		end
	end
end


--加入一个自动特效
function addAutoEffect(node, ZOrder)
	if m_Root == nil then
		return
	end
	m_AutoEffectNode:addChild(node, ZOrder)
end


--关闭小菜单
function closeSmallMenu()
	if m_Root == nil then 
		return
	end
	m_MenuNode:removeChildByTag(c_tag_smallMenu_build)
	m_MenuNode:removeChildByTag(c_tag_smallMenu_team)
	m_MenuNode:removeChildByTag(c_tag_smallMenu_nullMap)
	--mask
	m_TouchMaskNode:removeChildByTag(c_tag_touchMask_build)
	m_TouchMaskNode:removeChildByTag(c_tag_touchMask_nullMap)
end


--打开小菜单,点击建筑时
function openInputMenu_building(buildServerData)
	closeSmallMenu()
	closeInputMenu()
	m_MenuNode:addChild( SmallMenuMD.create_with_buildServerData(buildServerData), 1, c_tag_smallMenu_build)
	--mask
	m_TouchMaskNode:addChild(TouchMaskMD.create_building(buildServerData),1,c_tag_touchMask_build)
end


--打开小菜单,点击队伍时
function openInputMenu_team(queueServerData)
	closeSmallMenu()
	closeInputMenu()
	m_MenuNode:addChild(SmallMenuMD.create_with_queueServerData(queueServerData), 1, c_tag_smallMenu_team)
end


--打开小菜单,点击空地时
function openInputMenu_null(bigTileIndex)
	closeSmallMenu()
	closeInputMenu()
	
	local smallMeu = SmallMenuMD.create_with_bigTileIndex(bigTileIndex)
	if smallMeu then
		m_MenuNode:addChild(smallMeu, 1, c_tag_smallMenu_nullMap)
	end
	--mask
	m_TouchMaskNode:addChild(TouchMaskMD.create_null(bigTileIndex),1,c_tag_touchMask_nullMap)
end


--得到小菜单,当前显示的任何一个
function getSmallMenu()
	if(m_Root == nil)then
		return nil
	end
	local ret = m_MenuNode:getChildByTag(c_tag_smallMenu_build)
	if ret == nil then
		ret = m_MenuNode:getChildByTag(c_tag_smallMenu_team)
	end
	if ret == nil then
		ret = m_MenuNode:getChildByTag(c_tag_smallMenu_nullMap)
	end
	return ret
end


--关闭摆放菜单
function closeInputMenu()
	if m_Root == nil then 
		return
	end
	m_InputNode:removeChildByTag(c_tag_inputMenu_input)
end


--打开摆放菜单,迁城时
function openInputMenu_moveCity(bigTileIndex, callbackOK, callbackCancle)
	closeSmallMenu()
	closeInputMenu()
	m_InputNode:addChild(InputMenuMD.create_move_city(HelperMD.getMyHome_mapElementID(), bigTileIndex, callbackOK, callbackCancle), 1, c_tag_inputMenu_input)
end


--打开摆放菜单,建筑时
function openInputMenu_build(map_element_id, bigTileIndex, callbackOK, callbackCancle)
	closeSmallMenu()
	closeInputMenu()
	m_InputNode:addChild(InputMenuMD.create_build(map_element_id, bigTileIndex, callbackOK, callbackCancle), 1, c_tag_inputMenu_input)
end


--打开摆放菜单,邀请时
function openInputMenu_invite(map_element_id, bigTileIndex, callbackOK, callbackCancle)
	closeSmallMenu()
	closeInputMenu()
	m_InputNode:addChild(InputMenuMD.create_invite(map_element_id, bigTileIndex, callbackOK, callbackCancle), 1, c_tag_inputMenu_input)
end


--点击到某个大像素坐标
function onClickBigTileIndex(bigTileIndex)
	print(bigTileIndex.x,bigTileIndex.y)
	local tileData = getTileData_bigTileIndex(bigTileIndex)
	if tileData then
		local build_id = tileData:getCustomName()
		if build_id and build_id ~= "" then
			local serverData = m_CurrentAreaDatas.Map[build_id]
			if serverData then
				onClickBuild_buildServerData(serverData)
			else
				if g_isDebug then
					local idStrings = string.format("index(%d,%d) , id=%s ",bigTileIndex.x, bigTileIndex.y, build_id)
					idStrings = idStrings.." begin"
					for k , v in pairs(m_CurrentAreaDatas.Map) do
						idStrings = idStrings..k.." "
					end
					idStrings = idStrings.." end"
					local function showCurrentMapAllId(event)
						if event == 0 then
							g_msgBox.show(idStrings)
						end
					end
					g_msgBox.show("你触发了一个难以重现的BUG,点击确定之后会有错误窗口弹出,请截图报告给开发人员！", nil, 3, showCurrentMapAllId)
				end
			end
		else
			g_musicManager.playEffect(g_data.sounds[5000037].sounds_path)
			onClickScenery_bigTileIndex(bigTileIndex)
		end
	else
		g_musicManager.playEffect(g_data.sounds[5000037].sounds_path)
		onClickNullMap_bigTileIndex(bigTileIndex)
	end
end


--模拟点击到某个大像素坐标
function onClickBigTileIndex_Simulation(bigTileIndex)
	onClickBigTileIndex(bigTileIndex)	--暂时没区别,直接调用非模拟函数
end


--点击到某个建筑的处理回调
function onClickBuild_buildServerData(buildServerData)
	if buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.monster_small then
		g_musicManager.playEffect(g_data.sounds[5000038].sounds_path)
		--小怪没小菜单
		require("game.mapcitybattle.worldMapLayer_pecialClick").onClick_SmallMonster(g_data.map_element[tonumber(buildServerData.map_element_id)], buildServerData)
		--mask
		m_TouchMaskNode:addChild(TouchMaskMD.create_NoSmallMenu(buildServerData,nil),1,c_tag_touchMask_noSmallMenu)
		return
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.monster_boss then
		g_musicManager.playEffect(g_data.sounds[5000038].sounds_path)
		--BOSS怪没小菜单
		require("game.mapcitybattle.worldMapLayer_pecialClick").onClick_BossMonster(g_data.map_element[tonumber(buildServerData.map_element_id)], buildServerData)
		--mask
		m_TouchMaskNode:addChild(TouchMaskMD.create_NoSmallMenu(buildServerData,nil),1,c_tag_touchMask_noSmallMenu)
		return
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.heshibi then
		--和氏璧没小菜单
		require("game.mapcitybattle.worldMapLayer_pecialClick").onClick_Heshibi(g_data.map_element[tonumber(buildServerData.map_element_id)], buildServerData)
		--mask
		m_TouchMaskNode:addChild(TouchMaskMD.create_NoSmallMenu(buildServerData,nil),1,c_tag_touchMask_noSmallMenu)
		return
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.world_gold then
		if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.gold) == nil then
			g_airBox.show(g_tr("worldmap_not_gold"), 2)
			return
		end
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.world_food then
		if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.food) == nil then
			g_airBox.show(g_tr("worldmap_not_food"), 2)
			return
		end
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.world_wood then
		if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.wood) == nil then
			g_airBox.show(g_tr("worldmap_not_wood"), 2)
			return
		end
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.world_stone then
		if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.stone) == nil then
			g_airBox.show(g_tr("worldmap_not_stone"), 2)
			return
		end
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.world_iron then
		if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.iron) == nil then
			g_airBox.show(g_tr("worldmap_not_iron"), 2)
			return
		end
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.king_castle then
		--g_airBox.show(g_tr("worldmap_not_king_castle"), 2)
		--return
		--if g_cityBattlePlayerData.getCampId() == 0 then
		--	g_airBox.show(g_tr("worldmap_not_king_no_guild"), 2)
		--	return
		--end
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.camp_middle then
		--g_airBox.show(g_tr("worldmap_not_king_castle"), 2)
		--return
		--if g_cityBattlePlayerData.getCampId() == 0 then
		--	g_airBox.show(g_tr("worldmap_not_king_no_guild"), 2)
		--	return
		--end
	elseif buildServerData.map_element_origin_id == HelperMD.m_MapOriginType.camp_low then
		--g_airBox.show(g_tr("worldmap_not_king_castle"), 2)
		--return
		--if g_cityBattlePlayerData.getCampId() == 0 then
		--	g_airBox.show(g_tr("worldmap_not_king_no_guild"), 2)
		--	return
		--end
	end
	openInputMenu_building(buildServerData)
end


--点击到某个队列队伍的处理回调
function onClickTeam_queueServerData(queueServerData)
	local teamNode = getTeamInterface(queueServerData)
	if teamNode and teamNode.lua_TouchEnable then
		openInputMenu_team(queueServerData)
	end
end


--点击到某个队列队伍的处理回调(模拟专用)
function onClickTeam_queueServerData_Simulation(queueServerData)
	local teamNode = getTeamInterface(queueServerData)
	if teamNode and teamNode.lua_TouchEnable then
		openInputMenu_team(queueServerData)
	end
end


--移动视口到部队
function changePositionToQueue_Manual(queueServerData)
	local teamNode = getTeamInterface(queueServerData)
	if teamNode then
		local position = cc.p(teamNode:getPositionX(),teamNode:getPositionY())
		changePosition_Manual(position)
	end
end


--点击到某个空地的处理回调
function onClickNullMap_bigTileIndex(bigTileIndex)
	openInputMenu_null(bigTileIndex)
end


--点击到某个景物的处理回调
function onClickScenery_bigTileIndex(bigTileIndex)
	--mask
	m_TouchMaskNode:addChild(TouchMaskMD.create_NoSmallMenu(nil,bigTileIndex),1,c_tag_touchMask_noSmallMenu)
end


--得到这个队伍的显示（可能为空）
function getTeamInterface(queueServerData)
	if m_Root == nil then
		return
	end
	return m_QueueMoveNode:getChildByName("team"..tostring(queueServerData.id))
end


--获得建筑顶层特效
function getBuildTopEffectNode(serverData)
	if m_Root == nil then
		return
	end
	return m_BuildEffectTopNode:getChildByName(tostring(serverData.id))
end


--得到当前视口对准哪一个区域ID
function getCurrentShowCenterAreaID()
	return m_CurrentAreaIDs[5]
end


--根据armyID查找当前的队列
function getQueueServerData_armyId(armyId)
	local id = tonumber(armyId)
	local currentQueueDatas = getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		if v.army_id ~= 0 and v.army_id == id then
			return v
		end
	end
	return nil
end

--根据原点大瓦片坐标找到建筑的服务器数据(如果建筑占多格,必须传入原点位置)
function getBuildServerData_originBigTileIndex(originBigTileIndex)
	for k , v in pairs(m_CurrentAreaDatas.Map) do
		if v.x == originBigTileIndex.x and v.y == originBigTileIndex.y then
			return v
		end
	end
end


--根据大瓦片坐标找到格子数据(没有为空地)
function getTileData_bigTileIndex(bigTileIndex)
	return getTileData_areaId_areaTileIndex( HelperMD.areaIndex_2_areaId( HelperMD.bigTileIndex_2_areaIndex( bigTileIndex ) ) , HelperMD.bigTileIndex_2_areaTileIndex(bigTileIndex) )
end


--根据大瓦片坐标查询这里是否有map element
function hasMapElement_bigTileIndex(bigTileIndex)
	local tileData = getTileData_bigTileIndex(bigTileIndex)
	if tileData then
		local build_id = tileData:getCustomName()
		if build_id and build_id ~= "" then
			return true
		end
	end
	return false
end

--根据像素坐标找到格子数据(没有为空地)
function getTileData_Position(position)
	if position and HelperMD.mapParallelogram_Contains_Position(position) then
		return getTileData_bigTileIndex(HelperMD.position_2_bigTileIndex(position))
	end
end


--根据世界像素坐标找到格子数据(没有为空地)
function getTileData_WorldPosition(worldPosition)
	return getTileData_Position(worldPosition_2_position(worldPosition))
end


--世界像素坐标 转换到 地图像素坐标
function worldPosition_2_position(worldPosition)
	if m_Root == nil then
		return
	end
	return cTools_worldToNodeSpace_position(m_BuildNode,worldPosition)
end


--地图像素坐标 转换到 世界像素坐标
function position_2_worldPosition(position)
	if m_Root == nil then
		return
	end
	return cTools_NodeSpaceToWorld_position(m_BuildNode,position)
end

--根据大瓦片坐标查询这里所属的联盟战区域Id
function getGuildWarAreaId_bigTileIndex(bigTileIndex)
	local guildwarAreaId = -1
	local areaId = HelperMD.areaIndex_2_areaId( HelperMD.bigTileIndex_2_areaIndex( bigTileIndex ) )
	if areaId ~= -1 then
		local tmxMap = m_BuildNode:getChildByTag(areaId)
		if tmxMap then
			local tileLayer = tmxMap:getChildByName("layer_area")
			local tileData = tileLayer:getTileDataWithIndex( HelperMD.bigTileIndex_2_areaTileIndex(bigTileIndex) )
			if tileData then
				--区域5： 5
				--区域4： 58
				--区域3： 100
				--区域2： 13
				--区域1： 127
				local editGid = tileData:getEditGid()
				if tonumber(editGid) == 5 then
						guildwarAreaId = 5
				elseif tonumber(editGid) == 58 then
						guildwarAreaId = 4
				elseif tonumber(editGid) == 100 then
						guildwarAreaId = 3
				elseif tonumber(editGid) == 13 then
						guildwarAreaId = 2
				elseif tonumber(editGid) == 127 then
						guildwarAreaId = 1
				end
			end
		end
	end
	return guildwarAreaId
end

--根据区域ID以及所在区域里的瓦片索引找到格子数据(没有为空地)
function getTileData_areaId_areaTileIndex(areaId , areaTileIndex)
	local tileData = nil
	if areaId ~= -1 and areaTileIndex.x ~= -1 and areaTileIndex.y ~= -1 then
		local tmxMap = m_BuildNode:getChildByTag(areaId)
		if tmxMap then
			tileData = tmxMap:getChildByName("layer_top"):getTileDataWithIndex( areaTileIndex )
			if tileData == nil then
				tileData = tmxMap:getChildByName("layer_1"):getTileDataWithIndex( areaTileIndex )
			end
		end
	end
	return tileData
end



function getGuildWarAreaId_areaId_areaTileIndex(areaId , areaTileIndex)

	local guildwarAreaId = -1
	if areaId ~= -1 and areaTileIndex.x ~= -1 and areaTileIndex.y ~= -1 then
		local tmxMap = m_BuildNode:getChildByTag(areaId)
		if tmxMap then
			local tileData = tmxMap:getChildByName("layer_area"):getTileDataWithIndex( areaTileIndex ) 
			if tileData then
				--区域5： 5
				--区域4： 58
				--区域3： 100
				--区域2： 13
				--区域1： 127
				local editGid = tileData:getEditGid()
				if tonumber(editGid) == 5 then
						guildwarAreaId = 5
				elseif tonumber(editGid) == 58 then
						guildwarAreaId = 4
				elseif tonumber(editGid) == 100 then
						guildwarAreaId = 3
				elseif tonumber(editGid) == 13 then
						guildwarAreaId = 2
				elseif tonumber(editGid) == 127 then
						guildwarAreaId = 1
				end
			end
		end
	end
	return guildwarAreaId
end

--得到世界坐标点在scroll的viewSize中的位置,注意:不是Container
function getWorldPointInMapScrollView(world_pos)
	if m_Root == nil then
		return nil
	end
	return cTools_worldToNodeSpace_position(m_MapScroll,world_pos)
end


--得到scroll的viewSize
function getMapScrollViewSize()
	if m_Root == nil then
		return
	end
	return m_MapScroll:getViewSize()
end


--设置scroll的触摸
function setMapScrollViewTouchEnabled(var)
	if m_Root == nil then
		return
	end
	m_MapScroll:setTouchEnabled(var)
end


--得到当前地图显示视口中心对准哪一个像素坐标
function getPosition_CurrentLookAt()
	if m_Root == nil then 
		return
	end
	local viewSize = m_MapScroll:getViewSize()
	local zoomScale = m_MapScroll:getZoomScale()
	local offsetPos = m_MapScroll:getContentOffset()
	return cc.p(offsetPos.x / zoomScale * -1 +	viewSize.width / 2 / zoomScale, offsetPos.y / zoomScale * -1 +	viewSize.height / 2 / zoomScale)
end


--得到当前地图显示视口中心对准哪一个大瓦片索引
function getBigTileIndex_CurrentLookAt()
	if m_Root == nil then 
		return
	end
	return HelperMD.position_2_bigTileIndex(getPosition_CurrentLookAt())
end


--手动以叠加像素的方式偏移地图
function offsetAddPosition_Manual(addPosition)
	if m_Root == nil then 
		return
	end
	local position = getPosition_CurrentLookAt()
	changePosition_Manual(cc.p(position.x + addPosition.x ,position.y + addPosition.y ))
end


--手动以叠加大瓦片索引的方式偏移地图
function offsetAddBigTileIndex_Manual(addBigTileIndex)
	if m_Root == nil then 
		return
	end
	local bigTileIndex = getBigTileIndex_CurrentLookAt()
	changeBigTileIndex_Manual(cc.p(bigTileIndex.x + addBigTileIndex.x ,bigTileIndex.y + addBigTileIndex.y ))
end


--手动显示地图到某一个大像素坐标
function changePosition_Manual(position,isAnimation)
	if m_Root == nil then 
		return
	end
	local viewSize = m_MapScroll:getViewSize()
	local zoomScale = m_MapScroll:getZoomScale()
	local target = cc.p( (position.x - viewSize.width / 2 / zoomScale) * -1 * zoomScale , (position.y - viewSize.height / 2 / zoomScale) * -1 * zoomScale )
	if isAnimation == true then
		m_MapScroll:setContentOffsetInDuration_EaseExponentialOut( target , 0.618 )
	else
		m_MapScroll:setContentOffset(target)
	end
end


--手动显示地图到某一个大瓦片索引
function changeBigTileIndex_Manual(bigTileIndex,isAnimation)
	if m_Root == nil then 
		return
	end
	local bti = HelperMD.checkMove_bigTileIndex(bigTileIndex)
	local viewSize = m_MapScroll:getViewSize()
	local zoomScale = m_MapScroll:getZoomScale()
	local position = HelperMD.bigTileIndex_2_positionCenter(bti)
	local target = cc.p( (position.x - viewSize.width / 2 / zoomScale) * -1 * zoomScale , (position.y - viewSize.height / 2 / zoomScale) * -1 * zoomScale )
	if isAnimation == true then
		m_MapScroll:setContentOffsetInDuration_EaseExponentialOut( target , 0.618 )
	else
		m_MapScroll:setContentOffset(target)
	end
end


--处理自动弹出菜单
function processAutoOpenInterface()
	if m_Root == nil then 
		return
	end
	if m_WillOpenSmallMenuData then
		local succeed = false
		local tileData = getTileData_bigTileIndex(m_WillOpenSmallMenuData.bigTileIndex)
		if tileData then
			local build_id = tileData:getCustomName()
			if build_id and build_id ~= "" then
				local serverData = m_CurrentAreaDatas.Map[build_id]
				if serverData then
					succeed = true
					if serverData.map_element_origin_id ~= HelperMD.m_MapOriginType.monster_small 
						and serverData.map_element_origin_id ~= HelperMD.m_MapOriginType.monster_boss 
							then --怪没小菜单
						openInputMenu_building(serverData)
					end
				end
			end
		end
		if succeed then
			m_WillOpenSmallMenuData = nil
		else
			m_WillOpenSmallMenuData.wantTryCount = m_WillOpenSmallMenuData.wantTryCount - 1
			if m_WillOpenSmallMenuData.wantTryCount <= 0 then
				m_WillOpenSmallMenuData = nil
			end
		end
	end
end


--手动显示地图到某一个大瓦片索引,并且打开菜单
function changeBigTileIndexAndOpenInterface_Manual(bigTileIndex,isAnimation)
	if m_Root == nil then 
		return
	end
	changeBigTileIndex_Manual(bigTileIndex,isAnimation)
	m_WillOpenSmallMenuData = {
		["bigTileIndex"] = bigTileIndex,
		["wantTryCount"] = 3,	--尝试3次
	}
	--处理自动弹出菜单
	processAutoOpenInterface()
end


--手动显示地图到某一个区域索引
function changeAreaIndex_Manual(areaIndex,isAnimation)
	if m_Root == nil then
		return
	end
	local ai = HelperMD.checkMove_areaIndex(areaIndex)
	local viewSize = m_MapScroll:getViewSize()
	local zoomScale = m_MapScroll:getZoomScale()
	local position = HelperMD.areaIndex_2_positionCenter(ai)
	local target = cc.p( (position.x - viewSize.width / 2 / zoomScale) * -1 * zoomScale , (position.y - viewSize.height / 2 / zoomScale) * -1 * zoomScale )
	if isAnimation == true then
		m_MapScroll:setContentOffsetInDuration_EaseExponentialOut( target , 0.618 )
	else
		m_MapScroll:setContentOffset(target)
	end
end

--存储联盟战分区信息
--local m_allGuildWarAreaInfo = {}

--local _updateGuildWarAreaInfo = function(areaId)
--	if areaId then
--		if m_allGuildWarAreaInfo[tostring(areaId)] == nil then
--			m_allGuildWarAreaInfo[tostring(areaId)] = {}
--			--local getGuildWarAreaId_areaId_areaTileIndex()
--		end
--	end
--end

--检测与变化显示区域
function checkAndChangeArea(bigTileIndex)

	local areaIndex = HelperMD.bigTileIndex_2_areaIndex(bigTileIndex)
	
	local areaId = HelperMD.areaIndex_2_areaId(areaIndex)
	
	if areaId == -1 or m_CurrentAreaIDs[5] == areaId then
		return	--区域没东西 或者 区域位置没变化就不做处理
	end
	
	m_MapScroll:setCanZoomScale(areaIndex.x > 1 and areaIndex.x < HelperMD.m_AreaCount.width - 2 and areaIndex.y > 1 and areaIndex.y < HelperMD.m_AreaCount.height - 2)
	
	local newAreaIDs = {
		[1] = HelperMD.areaIndex_2_areaId( cc.p( areaIndex.x - 1 , areaIndex.y - 1 ) ),
		[2] = HelperMD.areaIndex_2_areaId( cc.p( areaIndex.x , areaIndex.y - 1 ) ),
		[3] = HelperMD.areaIndex_2_areaId( cc.p( areaIndex.x + 1 , areaIndex.y - 1 ) ),
		[4] = HelperMD.areaIndex_2_areaId( cc.p( areaIndex.x - 1 , areaIndex.y ) ),
		[5] = areaId,
		[6] = HelperMD.areaIndex_2_areaId( cc.p( areaIndex.x + 1 , areaIndex.y ) ),
		[7] = HelperMD.areaIndex_2_areaId( cc.p( areaIndex.x - 1 , areaIndex.y + 1 ) ),
		[8] = HelperMD.areaIndex_2_areaId( cc.p( areaIndex.x , areaIndex.y + 1 ) ),
		[9] = HelperMD.areaIndex_2_areaId( cc.p( areaIndex.x + 1 , areaIndex.y + 1 ) ),
	}
	
	local function isHaveFunc(tab,var)
		for k , v in pairs(tab) do
			if var == v then
				return true
			end
		end
		return false
	end
	
	for k , v in pairs(m_CurrentAreaIDs) do
		if v ~= -1 and isHaveFunc(newAreaIDs,v) == false then
			--删除离开屏幕的
			m_BuildNode:removeChildByTag(v)
			m_CurrentAreaIDs[k] = nil
		end
	end
	
	for k , v in pairs(newAreaIDs) do
		if v ~= -1 and isHaveFunc(m_CurrentAreaIDs,v) == false then
			--新加入显示屏幕的
			local ai = HelperMD.areaId_2_areaIndex( v )
			local areaTmxMap = AreaMapMD.create(ai)
			--areaTmxMap:setVisibleOperat(k == 5 and true or false)
			--areaTmxMap:setVisibleOperat(false)
			local z = HelperMD.areaIndex_2_areaZOrder(ai)
			m_BuildNode:addChild(areaTmxMap, z, v)
			
			--_updateGuildWarAreaInfo(v)
		end
	end

	m_CurrentAreaIDs = newAreaIDs

	RequestTimeMD.RequestSecondsAfter(0.3, RequestTimeMD.m_Event_want.moveView)--滑动结束后等一下再刷新

end


--去主城时的动作变化
function playGoHome()
	if(m_Root == nil)then
		return nil
	end
	m_ChangeScaleNode:setScale(1.0)
	m_ChangeScaleNode:runAction(cc.ScaleTo:create(0.5,0.7))
end


--从主城回来时的动作变化
function playFromHomeComeBack()
	if(m_Root == nil)then
		return nil
	end
	m_ChangeScaleNode:setScale(0.7)
	m_ChangeScaleNode:runAction(cc.ScaleTo:create(0.5,1.0))
end


--播放主城重建特效
function playRebuild()
	if(m_Root == nil)then
		return
	end
	local myHomeBuildServerData = getMyHomeBuildServerData()
	if myHomeBuildServerData then
		local function onMovementEventCallFunc(armature , eventType , name)
			if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
				armature:removeFromParent()
			end
		end
		local armature , animation = g_gameTools.LoadCocosAni(
				"anime/Effect_WorldMapBuildReborn/Effect_WorldMapBuildReborn.ExportJson"
				, "Effect_WorldMapBuildReborn"
				, onMovementEventCallFunc
				, nil
				)
		armature:setPosition(HelperMD.buildServerData_2_buildCenterPosition(myHomeBuildServerData))
		addAutoEffect(armature, 0)
		animation:play("Animation1")
	end
end


--得到自己主城服务器数据(如果屏幕上存在的话)
function getMyHomeBuildServerData()
	if(m_Root == nil)then
		return nil
	end
	local myPlayerID = g_cityBattlePlayerData.GetData().player_id
	for k , v in pairs(m_CurrentAreaDatas.Map) do
		if v.player_id == myPlayerID and v.map_element_origin_id == HelperMD.m_MapOriginType.player_home then
			return v
		end
	end
	return nil
end

function play_fire_attack_effect(num,configData, originBigTileIndex)
	if(m_Root == nil)then
		return
	end

	local effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.start == eventType then
		elseif ccs.MovementEventType.complete == eventType then
			effectNode:removeFromParent()
			play_reduce_effect(num,configData, originBigTileIndex)
		elseif ccs.MovementEventType.loopComplete == eventType then
		end
	end

	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuZhanChangHuoQiu/Effect_KuaFuZhanChangHuoQiu.ExportJson", "Effect_KuaFuZhanChangHuoQiu", onMovementEventCallFunc)
	effectNode:addChild(armature)
	animation:play("Animation1")
	
	m_AutoEffectNode:addChild(effectNode)
end

function play_reduce_effect(num,configData, originBigTileIndex,fromConfigData)
	if(m_Root == nil)then
		return
	end
	
	local playNumEffect = function()
		--play
		local text = "/"..num
		local label = cc.LabelAtlas:create(text, "tournament/num/num_reduce.png", 36, 50, 47)
		label:setScale(0.2)
		label:setAnchorPoint(cc.p(0.5, 0.5))
		local act_bi = cc.Spawn:create(
			cc.MoveBy:create(0.45, cc.p(math.random(60, 80), math.random(60, 80)))
			, cc.FadeTo:create(0.45, 0)
		)
		local act = cc.Sequence:create(
			cc.EaseBackOut:create(cc.ScaleTo:create(0.2, 1.0, 1.0, 1.0))
			, cc.DelayTime:create(0.1618)
			, act_bi
			, cc.RemoveSelf:create()
		)
		label:runAction(act)
		label:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
		m_AutoEffectNode:addChild(label)
	end
	
	if fromConfigData and fromConfigData.origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then
	
		print("~~~~~~~~~~~~~~~~~~~~~bbb")
		local effectNode = nil
	
		effectNode = cc.Node:create()
		effectNode:setContentSize(cc.size(1.0,1.0))
		effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
		
		local function onMovementEventCallFunc(armature , eventType , name)
			if ccs.MovementEventType.start == eventType then
				
			elseif ccs.MovementEventType.complete == eventType then
				print("~~~~~~~~~~~~~~~~~~~~~ccc")
				playNumEffect()
				effectNode:removeFromParent()
			elseif ccs.MovementEventType.loopComplete == eventType then
				
			end
		end
	
		local armature , animation = g_gameTools.LoadCocosAni("anime/ST/ST.ExportJson", "ST", onMovementEventCallFunc)
		effectNode:addChild(armature)
		animation:play("ST")
		
		m_AutoEffectNode:addChild(effectNode)
	else
		playNumEffect()
	end

end

function play_arrow(serverData, configData, originBigTileIndex)
	if(m_Root == nil)then
		return
	end
	
	local node = BuildEffectMD.create_arrow(serverData, configData, originBigTileIndex)
	m_BuildEffectTopNode:addChild(node)
end

function play_area_guide(serverData, configData, originBigTileIndex)
	if(m_Root == nil)then
		return
	end
	
	local node = BuildEffectMD.create_area_guide(serverData, configData, originBigTileIndex)
	m_BuildEffectTopNode:addChild(node)
end


return worldMapLayer_bigMap