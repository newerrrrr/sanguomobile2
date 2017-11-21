local homeMapLayer = {}
setmetatable(homeMapLayer,{__index = _G})
setfenv(1,homeMapLayer)

local HomeMapHelperMD = require("game.maplayer.homeMapHelper")

local HomeAirMD = require "game.maplayer.homeAir"

local HomeScreenEffectMD = require "game.maplayer.homeScreenEffect"


local m_Root = nil
local m_AirTouchNode = nil
local m_EventDispatcher = nil
local m_ChangeScaleNode = nil
local m_BuildSelectScaleNode = nil
local m_MapNodeSet = nil
local m_MapWidgetManualVisitNode = nil
local m_MapWidget = nil
local m_MapNormalizationPanel = nil
local m_WaveDisplay = nil
local m_Ship_Armature = nil
local m_Ship_Armature2 = nil
local ship_Animation2 = nil
local m_Waterfall = nil
local m_TispSoldier = nil
local m_MapScroll = nil
local m_ArmyShowNode = nil
local m_MapEffectNode = nil
local m_ScreenGaussianBlur = nil
local m_ProgressNode = nil
local m_MenuNode = nil
local m_CityTipsNode = nil
local m_lastActionTime_for_buildSelect = nil
local m_originOffsetPos_for_buildSelect = nil
local m_buildArray = {}
local m_AirJumpTime = false
local m_backgroundImageId_1 = nil
local m_backgroundImageId_2 = nil
local m_update1LevelUpPostTable = {}
local m_MarketTipsTime = math.random(3, 30)

local function clearGlobal()
	m_Root = nil
	m_AirTouchNode = nil
	m_EventDispatcher = nil
	m_ChangeScaleNode = nil
	m_BuildSelectScaleNode = nil
	m_MapNodeSet = nil
	m_MapWidgetManualVisitNode = nil
	m_MapWidget = nil
	m_MapNormalizationPanel = nil
	m_WaveDisplay = nil
	m_Ship_Armature = nil
	m_Waterfall = nil
	m_TispSoldier = nil
	m_MapScroll = nil
	m_ArmyShowNode = nil
	m_MapEffectNode = nil
	m_ScreenGaussianBlur = nil
	m_ProgressNode = nil
	m_MenuNode = nil
	m_CityTipsNode = nil
	m_lastActionTime_for_buildSelect = nil
	m_originOffsetPos_for_buildSelect = nil
	m_buildArray = {}
	m_AirJumpTime = false
	m_backgroundImageId_1 = nil
	m_backgroundImageId_2 = nil
	m_update1LevelUpPostTable = {}
	m_MarketTipsTime = math.random(3, 30)
	
	--g_gameCommon.removeAllEventHandlers(homeMapLayer)
	
end

local c_MapContentSize = cc.CSLoader:createNode("map_1.csb"):getContentSize()

local c_build_interface = 1.2
local c_build_view_offset_y = 95.0

local c_tag_smallBuildMenu = 1901
local c_tag_hand = 1902
local c_tag_scrollScaleAction = 1903
local c_tag_openNameAction_t = 1904
local c_tag_openNameAction_s = 1905
local c_tag_mapEffect_fire = 1906
local c_tag_mapEffect_guide_1 = 1907
local c_tag_background_change_1 = 1908
local c_tag_background_change_2 = 1909

function create()
	
	clearGlobal()
	
	cc.SpriteFrameCache:getInstance():addSpriteFrames("homeImage/homeImage.plist","homeImage/homeImage.png")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("animeFps/city/city.plist","animeFps/city/city.png")
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
		 if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_homeMap_1, 2.0 , false)
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_homeMap_2, 3.25 , false)
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_homeMap_3, 12 , false)
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_homeMap_4, 27 , false)
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_homeMap_5, 38 , false)
			update_homeMap_1(0.01666)
			update_homeMap_2(0.01666)
			update_homeMap_3(0.01666)
			update_homeMap_4(0.01666)
			update_homeMap_5(0.01666)
			do -- for guide
				for key, var in pairs(g_data.build_position) do
					g_guideManager.registComponent(var.id,getBuildButtonWithPlace(var.id))
				end
				if not g_guideManager.getLastShowStep() then
						g_guideManager.execute()
				end
			end
			g_gameStateManager.tryNoticeFirstInGame()
			require("game.uilayer.mainSurface.mainSurfaceMenu").showJoinGuildTip()
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
			do --for guide
				for key, var in pairs(g_data.build_position) do
					g_guideManager.unregistComponent(var.id)
				end
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
	
	m_ChangeScaleNode = cc.Node:create()
	m_ChangeScaleNode:ignoreAnchorPointForPosition(false)
	m_ChangeScaleNode:setAnchorPoint(cc.p(0.5,0.5))
	m_ChangeScaleNode:setPosition(g_display.center)
	m_ChangeScaleNode:setContentSize(g_display.size)
	rootLayer:addChild(m_ChangeScaleNode,1)
	
	rootLayer:addChild(HomeScreenEffectMD.create(),2)
	
	m_BuildSelectScaleNode = cc.Node:create()
	m_BuildSelectScaleNode:ignoreAnchorPointForPosition(false)
	m_BuildSelectScaleNode:setAnchorPoint(cc.p(0.5,0.5))
	m_BuildSelectScaleNode:setPosition(g_display.center)
	m_BuildSelectScaleNode:setContentSize(g_display.size)
	m_ChangeScaleNode:addChild(m_BuildSelectScaleNode,1)

	m_MapScroll = lhs.MapScrollView:create(g_display.size)
	m_MapScroll:setContentSize(c_MapContentSize)
	m_MapScroll:setBounceable(false)
	m_MapScroll:setClippingToBounds(false)
	m_MapScroll:setMinScale(math.max(0.75,math.max(g_display.size.width / c_MapContentSize.width , g_display.size.height / c_MapContentSize.height)))
	m_MapScroll:setMaxScale(1.6)
	m_MapScroll:setViewSize(g_display.visibleSize)
	m_MapScroll:setPosition(g_display.left_bottom)
	m_MapScroll:setDelegate()
	m_BuildSelectScaleNode:addChild(m_MapScroll,1)
	
	local function scrollViewDidScroll()
		m_EventDispatcher:setDiscardAllTouchEndEventToCancelled(m_MapScroll)
		updateShowScreenGaussianBlur()
		HomeScreenEffectMD.updateForScrollViewTrans(m_MapScroll:getViewSize(), m_MapScroll:getContentSize(), m_MapScroll:getContentOffset())
	end
	local function scrollViewDidZoom()
		m_EventDispatcher:setDiscardAllTouchEndEventToCancelled(m_MapScroll)
		updateShowScreenGaussianBlur()
		HomeScreenEffectMD.updateForScrollViewTrans(m_MapScroll:getViewSize(), m_MapScroll:getContentSize(), m_MapScroll:getContentOffset())
	end
	m_MapScroll:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
	m_MapScroll:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
	
	
	initWithMsgData()

	--初始位置
	jumpToCenterWithPositionForGuide(cc.p(1100,900))
	
	
	cc.Director:getInstance():setNextDeltaTimeZero(true)

	local function updateGuildHlep(obj, tcpData)
		g_PlayerBuildMode.RequestData_Async()
		if tcpData.position then
			local sd = g_PlayerBuildMode.FindBuild_Place(tcpData.position)
			if sd then
				if sd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.institute then
					g_ScienceMode.RequestData(true)
				end
			end
		end
	end
	g_gameCommon.addEventHandler(g_Consts.CustomEvent.Guild_Help, updateGuildHlep, homeMapLayer)
	
	return rootLayer
end


--更新小菜单时候的模糊位置
function updateShowScreenGaussianBlur()
	if(m_Root == nil)then
		return
	end
	m_ScreenGaussianBlur:lua_update_blur_position(m_MenuNode:getChildByTag(c_tag_smallBuildMenu), m_MapScroll:getZoomScale() * m_BuildSelectScaleNode:getScale())
end


--开启模糊 菜单
function openBlurForSmallMenu()
	if(m_Root == nil)then
		return
	end
	m_ScreenGaussianBlur:lua_open_blur_for_smallMenu()
	updateShowScreenGaussianBlur()
end


--关闭模糊 菜单
function closeBlurForSmallMenu()
	if(m_Root == nil)then
		return
	end
	m_ScreenGaussianBlur:lua_close_blur_for_smallMenu()
end


--开启模糊 建造界面
function openBlurForBuildInterface(direct_f_dt)
	if(m_Root == nil)then
		return
	end
	local dt = direct_f_dt and 0 or ( m_lastActionTime_for_buildSelect and m_lastActionTime_for_buildSelect or 0 )
	m_ScreenGaussianBlur:lua_open_blur_for_buildInterface( dt , c_build_view_offset_y , c_build_interface)
end


--关闭模糊 建造界面
function closeBlurForBuildInterface(direct_f_dt)
	if(m_Root == nil)then
		return
	end
	local dt = direct_f_dt and 0 or ( m_lastActionTime_for_buildSelect and m_lastActionTime_for_buildSelect or 0 )
	m_ScreenGaussianBlur:lua_close_blur_for_buildInterface( dt )
end


--根据缓存消息初始化
function initWithMsgData()
	if(m_Root == nil)then
		return
	end
	
	m_MapScroll:getContainer():removeAllChildren()
	
	
	--地图节点集合
	m_MapNodeSet = cc.Node:create()
	m_MapNodeSet:ignoreAnchorPointForPosition(false)
	m_MapNodeSet:setAnchorPoint(cc.p(0.0,0.0))
	m_MapNodeSet:setPosition(cc.p(0.0,0.0))
	m_MapNodeSet:setContentSize(c_MapContentSize)
	m_MapScroll:addChild(m_MapNodeSet,1)
	
	
	--地图
	m_MapWidgetManualVisitNode = lhs.LHSManualVisitNode:create()
	m_MapWidgetManualVisitNode:ignoreAnchorPointForPosition(false)
	m_MapWidgetManualVisitNode:setAnchorPoint(cc.p(0.0,0.0))
	m_MapWidgetManualVisitNode:setPosition(cc.p(0.0,0.0))
	m_MapWidgetManualVisitNode:setContentSize(c_MapContentSize)
	m_MapWidget = cc.CSLoader:createNode("map_1.csb")
	m_MapWidget:setPosition(cc.p(0.0,0.0))
	m_MapWidgetManualVisitNode:addChild(m_MapWidget)
	m_MapNodeSet:addChild(m_MapWidgetManualVisitNode,1)
	
	
	--整合panel
	m_MapNormalizationPanel = m_MapWidget:getChildByName("Panel_dw")
	
	--可建造字样设置
	for k , v in pairs(g_data.build_position) do
		if v.build_type == g_PlayerBuildMode.m_BuildType.cityOut then
			m_MapNormalizationPanel:getChildByName(tostring(k).."_can_build"):setString(g_tr("homemap_canbuild"))
		end
	end
	
	do --水
		m_WaveDisplay = require("game.gametools.spriteWave").create()
		m_WaveDisplay:setPosition(cc.p(3134.0, 468.0))
		m_MapWidget:getChildByName("Panel_1"):addChild(m_WaveDisplay,1)
		m_WaveDisplay:setVisible(g_saveCache.power_save == 0 and true or false)
	end
	
	do	--船
		m_Ship_Armature , ship_Animation = g_gameTools.LoadCocosAni("anime/Effect_Ship/Effect_Ship.ExportJson", "Effect_Ship")
		m_Ship_Armature:setPosition(cc.p(3185, 685))
		m_MapWidget:getChildByName("Panel_1"):addChild(m_Ship_Armature,2)
		ship_Animation:play("Animation1")
		--m_Ship_Armature:setVisible(g_saveCache.power_save == 0 and true or false)
	end

	do --瀑布
		m_Waterfall , animation = g_gameTools.LoadCocosAni("anime/Effect_ZhuChengPuBu/Effect_ZhuChengPuBu.ExportJson", "Effect_ZhuChengPuBu")
		m_Waterfall:setPosition(cc.p(2580, 715))
		animation:play("Animation1")
		m_MapWidget:getChildByName("Panel_1"):addChild(m_Waterfall,3)
		m_Waterfall:setVisible(g_saveCache.power_save == 0 and true or false)
	end
	
	do --TIPS兵
		m_TispSoldier = require("game.maplayer.homeMapTispSoldier").create()
		m_MapWidget:getChildByName("Panel_1"):addChild(m_TispSoldier,4)
	end
	

	--军队展示
	m_ArmyShowNode = require("game.maplayer.homeMapArmyShow").create()
	m_MapNodeSet:addChild(m_ArmyShowNode,2)
	
	
	--地图特效节点
	m_MapEffectNode = lhs.LHSManualVisitNode:create()
	m_MapEffectNode:ignoreAnchorPointForPosition(false)
	m_MapEffectNode:setAnchorPoint(cc.p(0.0,0.0))
	m_MapEffectNode:setPosition(cc.p(0.0,0.0))
	m_MapEffectNode:setContentSize(c_MapContentSize)
	m_MapNodeSet:addChild(m_MapEffectNode,3)
	
	
	--进度节点
	m_ProgressNode = lhs.LHSManualVisitNode:create()
	m_ProgressNode:ignoreAnchorPointForPosition(false)
	m_ProgressNode:setAnchorPoint(cc.p(0.0,0.0))
	m_ProgressNode:setPosition(cc.p(0.0,0.0))
	m_ProgressNode:setContentSize(c_MapContentSize)
	m_MapNodeSet:addChild(m_ProgressNode,4)
	
	
	--模糊
	local function renderFunc(sender)
		local mapWidgetManualVisible = m_MapWidgetManualVisitNode:isManualVisible()
		m_MapWidgetManualVisitNode:setManualVisible(true)
		
		local armyShowManualVisible = m_ArmyShowNode:isManualVisible()
		m_ArmyShowNode:setManualVisible(true)
		
		local mapEffectManualVisible = m_MapEffectNode:isManualVisible()
		m_MapEffectNode:setManualVisible(true)
		
		local progressManualVisible = m_ProgressNode:isManualVisible()
		m_ProgressNode:setManualVisible(true)
		
		local menuVisible = m_MenuNode:isVisible()
		m_MenuNode:setVisible(false)
		
		local cityTipsVisible = m_CityTipsNode:isVisible()
		m_CityTipsNode:setVisible(false)
		
		sender:setVisible(false)
		m_BuildSelectScaleNode:visit()
		sender:setVisible(true)
		
		m_MapWidgetManualVisitNode:setManualVisible(mapWidgetManualVisible)
		
		m_ArmyShowNode:setManualVisible(armyShowManualVisible)
		
		m_MapEffectNode:setManualVisible(mapEffectManualVisible)
		
		m_ProgressNode:setManualVisible(progressManualVisible)
		
		m_MenuNode:setVisible(menuVisible)
		
		m_CityTipsNode:setVisible(cityTipsVisible)
	end
	local function onOpenBlur()
		m_MapWidgetManualVisitNode:setManualVisible(false)
		m_ArmyShowNode:setManualVisible(false)
		m_MapEffectNode:setManualVisible(false)
		m_ProgressNode:setManualVisible(false)
	end
	local function onCloseBlur()
		m_MapWidgetManualVisitNode:setManualVisible(true)
		m_ArmyShowNode:setManualVisible(true)
		m_MapEffectNode:setManualVisible(true)
		m_ProgressNode:setManualVisible(true)
	end
	m_ScreenGaussianBlur = require("game.maplayer.homeBlurLayer").create( renderFunc , onOpenBlur , onCloseBlur )
	m_MapNodeSet:addChild(m_ScreenGaussianBlur,5)
	
	
	--气泡触摸判定节点
	m_AirTouchNode = cc.Node:create()
	m_AirTouchNode:ignoreAnchorPointForPosition(false)
	m_AirTouchNode:setAnchorPoint(cc.p(0.0,0.0))
	m_AirTouchNode:setPosition(cc.p(0.0,0.0))
	m_AirTouchNode:setContentSize(c_MapContentSize)
	m_MapNodeSet:addChild(m_AirTouchNode,6)
	do--m_AirTouchNode touch
		
		--检测点中 air
		local function checkClickAir(touch)
			for k1 , v1 in pairs(m_buildArray) do
				local airs = HomeMapHelperMD.getAirs(k1)
				for k2 , v2 in pairs(airs) do
					if v2 and v2:isCanClick() and lhs.LHSTools:checkTouchInSelf(v2, touch) then
						--触发
						m_AirJumpTime = true
						v2:lua_playClickHide()
						if v2.lua_OnClick then
							v2.lua_OnClick(v1.configData, v1.buildingData, v1.serverData)
						end
						return true
					end
				end
			end
			return false
		end
	
		local function onTouchBegan_AirTouchNode(touch, event)
			local ret = checkClickAir(touch)
			if ret then
				closeSmallBuildMenu()
				m_MapScroll:setTouchEnabled(false)
			end
			return ret
		end
		local function onTouchMoved_AirTouchNode(touch, event)
			checkClickAir(touch)
		end
		local function onTouchEnded_AirTouchNode(touch, event)
			m_MapScroll:setTouchEnabled(true)
		end
		local function onTouchCancelled_AirTouchNode(touch, event)
			m_MapScroll:setTouchEnabled(true)
		end
		local touchListener = cc.EventListenerTouchOneByOne:create()
		touchListener:setSwallowTouches(true)
		touchListener:registerScriptHandler(onTouchBegan_AirTouchNode,cc.Handler.EVENT_TOUCH_BEGAN )
		touchListener:registerScriptHandler(onTouchMoved_AirTouchNode,cc.Handler.EVENT_TOUCH_MOVED )
		touchListener:registerScriptHandler(onTouchEnded_AirTouchNode,cc.Handler.EVENT_TOUCH_ENDED )
		touchListener:registerScriptHandler(onTouchCancelled_AirTouchNode,cc.Handler.EVENT_TOUCH_CANCELLED )
		m_EventDispatcher:addEventListenerWithSceneGraphPriority(touchListener,m_AirTouchNode)
	end
	
	
	--城市tips节点
	m_CityTipsNode = cc.Node:create()
	m_CityTipsNode:ignoreAnchorPointForPosition(false)
	m_CityTipsNode:setAnchorPoint(cc.p(0.0,0.0))
	m_CityTipsNode:setPosition(cc.p(0.0,0.0))
	m_CityTipsNode:setContentSize(c_MapContentSize)
	m_MapNodeSet:addChild(m_CityTipsNode,7)
	
	
	--菜单节点
	m_MenuNode = cc.Node:create()
	m_MenuNode:ignoreAnchorPointForPosition(false)
	m_MenuNode:setAnchorPoint(cc.p(0.0,0.0))
	m_MenuNode:setPosition(cc.p(0.0,0.0))
	m_MenuNode:setContentSize(c_MapContentSize)
	m_MapNodeSet:addChild(m_MenuNode,8)

	
	--背景按下
	local function onBackgroundButton(sender, eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			m_EventDispatcher:setDiscardAllTouchEndEventToCancelled(m_MapScroll)
			closeSmallBuildMenu()
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	m_MapWidget:getChildByName("Panel_1"):addTouchEventListener(onBackgroundButton)
	
	
	--地基或建筑按下
	local function onBuildButton(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			sender:getChildByName("Image_diji"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_OverlayBlack ) )
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			sender:getChildByName("Image_diji"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
			m_EventDispatcher:setDiscardAllTouchEndEventToCancelled(m_MapScroll)
			onClickPlace(sender:getName())
		elseif eventType == ccui.TouchEventType.canceled then
			sender:getChildByName("Image_diji"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
		end
	end
	
	
	--初始化建筑
	m_buildArray = {}
	for key , var in pairs(g_data.build_position) do
		local place = tostring(key)
		local button = m_MapWidget:getChildByName(place)
		button:addTouchEventListener(onBuildButton)
		local sd = g_PlayerBuildMode.FindBuild_Place(place)
		updateBuildingWithMsgDataAndPlace(sd,place)
	end
	
	--地图变化
	backgroundCheckChange()
end


--关闭小小建筑物菜单
function closeSmallBuildMenu()
	if(m_Root == nil)then
		return
	end
	m_MenuNode:removeChildByTag(c_tag_smallBuildMenu)
	--打开其他建筑名字显示(还有对应一处关闭代码段)
	for k , v in pairs(m_buildArray) do
		local visible = (v.configData.build_type == g_PlayerBuildMode.m_BuildType.cityIn and true or false)
		m_MapNormalizationPanel:getChildByName(k.."_Image_15"):setVisible(visible)
		m_MapNormalizationPanel:getChildByName(k.."_Text_6"):setVisible(visible)
	end
end


--得到小小建筑物菜单
function getSmallBuildMenu()
	if(m_Root == nil)then
		return nil
	end
	return m_MenuNode:getChildByTag(c_tag_smallBuildMenu)
end


--update 1
function update_homeMap_1(dt)
	if(m_Root == nil)then
		return
	end
	
	updateMarketTips(dt)
	
	do --国王战开始动画
		local st = g_kingInfo.kingBattleSoonTime()
		if st > 1 and st < 6 then
			require("game.effectlayer.kingTime").show()
		end
	end
	
	local needUpdateBuild_eWriteBuildInfo = {} --需要更新的建筑物
	for key , var in pairs(m_buildArray) do
		if(tonumber(var.serverData.status) == g_PlayerBuildMode.m_BuildStatus.levelUpIng)then--升级
			if var.serverData.build_finish_time < g_clock.getCurServerTime() then--可能已经升级结束
				needUpdateBuild_eWriteBuildInfo[key] = var.serverData.position
			end
		end
	end
	--更新
	for k , v in pairs(needUpdateBuild_eWriteBuildInfo) do
		if m_update1LevelUpPostTable[v] == nil then
			local function onRecv(result, msgData)
				m_update1LevelUpPostTable[v] = nil
				if(result==true)then
					g_PlayerBuildMode.updateSingleBuildData(msgData, msgData.position)
					updateBuildingWithMsgDataAndPlace(msgData, msgData.position)
				end
			end
			m_update1LevelUpPostTable[v] = true
			g_sgHttp.postData("build/reWriteBuildInfo",{ position = v }, onRecv, true)
		end
	end
	
	--检测可建造字样是否能够开启
	if m_MapNormalizationPanel then
		for k1 , v1 in pairs(g_data.build_position) do
			if v1.build_type == g_PlayerBuildMode.m_BuildType.cityOut and g_PlayerBuildMode.FindBuild_Place(k1) == nil then
				local canBuild = false
				for k2 , v2 in pairs(v1.build_id) do
					canBuild = true
					local configData = g_data.build[v2]
					local preBuild = configData.pre_build_id[1]
					if preBuild and preBuild ~= 0 then
						if g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(preBuild) < 1 then
							canBuild = false
							break
						end
					end
				end
				m_MapNormalizationPanel:getChildByName(tostring(k1).."_can_build"):setVisible(canBuild)
			end
		end
	end
end


--update 2
function update_homeMap_2(dt)
	if(m_Root == nil)then
		return
	end
	if m_AirJumpTime then
		m_AirJumpTime = false
		return
	end
	
	for key , var in pairs(m_buildArray) do
		--更新本地显示
		HomeMapHelperMD.updateShowForLocalData(var.configData, var.buildingData, var.serverData)
	end
	if g_clock.getCurServerTime() < g_PlayerMode.GetData().fire_end_time then
		--城内着火
		if m_MapEffectNode:getChildByTag(c_tag_mapEffect_fire) == nil then
			m_MapEffectNode:addChild(require("game.maplayer.homeMapFire").create(), 0, c_tag_mapEffect_fire)
		end
	else
		--没着火
		m_MapEffectNode:removeChildByTag(c_tag_mapEffect_fire)
	end
	
	--require("game.uilayer.mainSurface.mainSurfaceQuickLink").checkQuickLink() --时间条代替了
	
	require("game.uilayer.science.Science"):instance():checkSciIsFinishAsync()
end


--update 3
function update_homeMap_3(dt)
	require("game.uilayer.mainSurface.mainSurfaceMenu").onGuildTipUpdate()
	require("game.uilayer.mainSurface.mainSurfaceChat").checkTaskGuideHandShow()
	local haveTip = require("game.uilayer.activity.ActivityMainLayer").checkIsHaveTip(g_activityData.ActivityType.Normal)
	require("game.uilayer.mainSurface.mainSurfacePlayer").showActivityBtnEffect(haveTip)
	
	local temp = os.date("*t", os.time())
	if temp.hour == 20 then
		g_activityData.RequestSycCrossBasicInfo()
		local changeMapScene = require("game.maplayer.changeMapScene")
		local mapStatus = changeMapScene.getCurrentMapStatus()

		if mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then
			return
		end

		if dt > 5 and g_activityData.IsInBattle() == true and mapStatus ~= changeMapScene.m_MapEnum.guildwar then
			if g_guideManager.getLastShowStep() == nil then
				g_msgBox.show( g_tr("enterBattleImme"),nil,nil,
							function ( eventtype )
					 				if eventtype == 0 then
					 					g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
									require("game.uilayer.activity.ActivityMainLayer").show(1025)
									end
							end 
						, 1)
			end
		end
	end
end


--update 4
function update_homeMap_4(dt)
	g_PlayerMode.RequestData_Async()
	g_PlayerHelpMode.RequestSycDataHome()
	g_activityData.RequestDataAsync(function()
		local data = g_PlayerBuildMode.FindBuild_Place(1023)
		updateBuildingWithMsgDataAndPlace(data, 1023)
	end)
	require("game.mapguildwar.changeMapScene").autoGotoWorld()
end


--update 5
function update_homeMap_5(dt)
	g_PlayerSoldierInjuredMode.requestDataAsync()
	g_TaskMode.requestDataAsync()

	require("game.uilayer.mainSurface.mainSurfacePlayer").updateCrossIcon()
	--g_PlayerHelpMode.RequestSycData() --事件条代替了
end


--根据消息自动更新(比对差距,效率低下)
function updateWithAutoMsg()
	if(m_Root == nil)then
		return
	end
	for k , v in pairs(g_data.build_position) do
		local origin_sd = m_buildArray[tostring(k)]
		if origin_sd then
			origin_sd = origin_sd.serverData
		end
		local sd = g_PlayerBuildMode.FindBuild_Place(k)
		
		if origin_sd and sd then
			if origin_sd.build_level and origin_sd.build_level ~= sd.build_level then
				g_BuffMode.RequestGeneralBuffAsync(k)
			end
		end
		
		if g_gameTools.compareTableForMsgData(origin_sd,sd) == true then
			--g_airBox.show( "注意：地图被动更新了位置 "..tostring(k).." 上的建筑信息" , 2 )
			updateBuildingWithMsgDataAndPlace(sd,k)
		end
	end
end


--更新建筑物
function updateBuildingWithMsgDataAndPlace( msgData , place )
	if(m_Root == nil)then
		return
	end
	local button = getBuildButtonWithPlace(place)
	if(button == nil)then
		return
	end
	
	local strPlace = tostring(place)
	local numPlace = tonumber(place)
	
	local general_Icon = m_MapNormalizationPanel:getChildByName(strPlace.."_Image_4")
	
	local effect_Top = m_MapNormalizationPanel:getChildByName(strPlace.."_Effect")
	
	local effect_Air = m_MapNormalizationPanel:getChildByName(strPlace.."_top_efc")
	
	local effect_Bottom = button:getChildByName("Effect_1")
	
	local name_back = m_MapNormalizationPanel:getChildByName(strPlace.."_Image_15")
	local name_label = m_MapNormalizationPanel:getChildByName(strPlace.."_Text_6")
	
	local lv_back = m_MapNormalizationPanel:getChildByName(strPlace.."_Image_dengj")
	local lv_label = m_MapNormalizationPanel:getChildByName(strPlace.."_Text_1")
	
	button:setVisible(true)

	if(msgData==nil or msgData.id==nil)then
		--没有建筑
		m_buildArray[strPlace] = nil

		--恢复地基样子
		button:getChildByName("Image_diji"):loadTexture(g_gameTools.getFoundationImagePathWithPlace(numPlace))

		if numPlace == 1023 then
			button:setVisible(false)
			name_back:setVisible(false)
			name_label:setVisible(false)
		end
		
		--丢弃所有特效
		effect_Top:removeAllChildren()
		effect_Bottom:removeAllChildren()
		
		--丢弃所有气泡
		effect_Air:removeAllChildren()
		
		--关闭名字显示
		name_back:setVisible(false)
		name_label:setVisible(false)
		
		--关闭等级显示
		lv_back:setVisible(false)
		lv_label:setVisible(false)
		
		--关闭头像
		general_Icon:setVisible(false)
		
		--删除进度
		removeProgress_BuildingData(g_data.build_position[numPlace])
		
		--如果有弹出小菜单就关闭
		local smallBuildMenu = getSmallBuildMenu()
		if smallBuildMenu and smallBuildMenu.lua_cache_data.place == numPlace then
			closeSmallBuildMenu()
		end
		
	else
		--有建筑
		local cd = g_data.build[tonumber(msgData.build_id)]
		local cpd = g_data.build_position[numPlace]
		
		--记录数据
		m_buildArray[strPlace] = {
			serverData = msgData,
			configData = cd,
			buildingData = cpd,
		}
		
		--关闭可建造字样
		if cpd.build_type == g_PlayerBuildMode.m_BuildType.cityOut then
			m_MapNormalizationPanel:getChildByName(strPlace.."_can_build"):setVisible(false)
		end
		
		do	--检测是否应该强制关闭菜单
			local smallBuildMenu = getSmallBuildMenu()
			if smallBuildMenu and smallBuildMenu.lua_cache_data.place == numPlace then
				if smallBuildMenu.lua_cache_data.menu_status ~= smallBuildMenu.lua_cache_data.operateMenuStatus(msgData) then
					closeSmallBuildMenu()
				end
			end
		end
		
		if cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.rampart then
			--城墙资源特殊加载
			button:getChildByName("Image_diji_1"):loadTexture(g_data.sprite[cd.img_1].path)
			button:getChildByName("Image_diji"):loadTexture(g_data.sprite[cd.img].path)
			button:getChildByName("Image_diji_2"):loadTexture(g_data.sprite[cd.img_2].path)
		else
			button:getChildByName("Image_diji"):loadTexture(g_data.sprite[cd.img].path)
		end
		
		if cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.mainCity then
			g_autoCallback.addCocosList( backgroundCheckChange, 0.5 )
		end
		
		--丢弃所有特效
		effect_Top:removeAllChildren()
		effect_Bottom:removeAllChildren()
		
		--丢弃所有气泡
		effect_Air:removeAllChildren()
		
		--开启名字显示
		do
			local smallBuildMenu = getSmallBuildMenu()
			if smallBuildMenu then
				local visible = (smallBuildMenu.lua_cache_data.place == numPlace and true or false)
				name_back:setVisible(visible)
				name_label:setVisible(visible)
			else
				local visible = (cd.build_type == g_PlayerBuildMode.m_BuildType.cityIn and true or false)
				name_back:setVisible(visible)
				name_label:setVisible(visible)
			end
			name_label:setString(g_tr(cd.build_name))
		end
		
		
		if cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.market
			or cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.grindery
			or cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.tournament
			or cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.god
			or cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.stars
			or cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.activity
				then
			--一些固定建筑不需要等级显示
			lv_back:setVisible(false)
			lv_label:setVisible(false)
		else
			--开启等级显示
			lv_back:setVisible(true)
			lv_back:loadTexture(g_data.sprite[cd.build_lv_show].path, ccui.TextureResType.plistType)
			lv_label:setVisible(true)
			lv_label:setString(tostring(cd.build_level))
		end
		
		--驻守武将
		if msgData.general_id_1 ~= 0 then
			general_Icon:setVisible(true)
			for k , v in pairs(g_data.general) do
				if v.general_original_id == msgData.general_id_1 then
					general_Icon:loadTexture(g_data.sprite[v.general_icon_min].path)
					break
				end
			end
		else
			general_Icon:setVisible(false)
		end

		if cd.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.activity then
			local list = require("game.uilayer.activity.ActivityMainLayer").getOpenListByActivityType(g_activityData.ActivityType.Operation)
			if #list  > 0 then
					m_Ship_Armature2 , ship_Animation2 = g_gameTools.LoadCocosAni("anime/Effect_Ship/Effect_Ship.ExportJson", "Effect_Ship")
					m_Ship_Armature2:setPosition(cc.p(m_Ship_Armature2:getContentSize().width + 58, m_Ship_Armature2:getContentSize().height-61))
					effect_Top:addChild(m_Ship_Armature2)
					ship_Animation2:play("Animation2")
			else
				updateBuildingWithMsgDataAndPlace(nil, 1023)
			end
		end
		
		--更新本地显示(特效,气泡,进度 等等)
		HomeMapHelperMD.updateShowForLocalData(cd, cpd, msgData)
		
	end
end


--加入或显示进度
function addOrEnableProgress(basic_position_node, configData, buildingData, serverData, grinderyInfo)
	if(m_Root == nil)then
		return
	end
	local name = tostring(buildingData.id).."progress"
	local originProgress = m_ProgressNode:getChildByName(name)
	if originProgress then
		originProgress:setVisible(true)
		originProgress:lua_update_serverData(basic_position_node , configData , buildingData , serverData , grinderyInfo)
	else
		local progress = require "game.maplayer.homeProgress".create(basic_position_node , configData , buildingData , serverData , grinderyInfo)
		m_ProgressNode:addChild(progress, 0, name)
	end
end


--根据位置配置数据删除进度
function removeProgress_BuildingData(buildingData)
	if(m_Root == nil)then
		return
	end
	m_ProgressNode:removeChildByName(tostring(buildingData.id).."progress")
end


--世界坐标转换到进度节点
function convertToProgressNodeSpace(worldPosition)
	if(m_Root == nil)then
		return cc.p(0.0, 0.0)
	end
	return m_ProgressNode:convertToNodeSpace(worldPosition)
end


--打开小小建筑物菜单
local function _onOpenSmallBuildMenu(place)
	local button = m_MapWidget:getChildByName(tostring(place))
	local data = m_buildArray[tostring(place)]
	if(button and data)then
		m_MenuNode:addChild(require("game.maplayer.smallBuildMenu").create(place),1,c_tag_smallBuildMenu)
	end
	--关闭其他建筑名字显示(还有对应一处开启代码段)
	local p = tostring(place)
	for k , v in pairs(m_buildArray) do
		local visible = (p == k and true or false)
		if k == 1023 then
			local list = {}--require("game.uilayer.activity.ActivityMainLayer").getOpenListByActivityType(g_activityData.ActivityType.Operation)
			if #list  > 0 then
				m_MapNormalizationPanel:getChildByName(k.."_Image_15"):setVisible(true)
				m_MapNormalizationPanel:getChildByName(k.."_Text_6"):setVisible(true)
			else
				m_MapNormalizationPanel:getChildByName(k.."_Image_15"):setVisible(false)
				m_MapNormalizationPanel:getChildByName(k.."_Text_6"):setVisible(false)
			end
		else
			m_MapNormalizationPanel:getChildByName(k.."_Image_15"):setVisible(visible)
			m_MapNormalizationPanel:getChildByName(k.."_Text_6"):setVisible(visible)
		end
	end
end


--打开建造界面
local function _onOpenBuild(place)
	g_sceneManager.addNodeForUI(require("game.uilayer.buildSelect.buildSelect").create(place))
	moveToCenterForBuildSelect(place)
	cc.Director:getInstance():setNextDeltaTimeZero(true)
end


local function _playClickBuildingSound(tp)
	local soundID = nil
	if tp == g_PlayerBuildMode.m_BuildOriginType.mainCity then
		soundID = 5000006
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.infantry then
		soundID = 5000007
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.cavalry then
		soundID = 5000008
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.archers then
		soundID = 5000009
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.car then
		soundID = 5000010
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.workshop then
		soundID = 5000011
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.cache then
		soundID = 5000012
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.smithy then
		soundID = 5000013
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.institute then
		soundID = 5000014
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.thePlace then
		soundID = 5000015
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.tower then
		soundID = 5000016
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.bar then
		soundID = 5000017
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.rampart then
		soundID = 5000018
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.spectacular then
		soundID = 5000019
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.hospital then
		soundID = 5000020	
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.battleHall then
		soundID = 5000021
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.food then
		soundID = 5000023
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.wood then
		soundID = 5000024
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.iron then
		soundID = 5000025
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.gold then
		soundID = 5000025
	elseif tp == g_PlayerBuildMode.m_BuildOriginType.stone then
		soundID = 5000025
	end
	if soundID then
		g_musicManager.playEffect(g_data.sounds[soundID].sounds_path)
	end
end

--点击到某个位置的处理
function onClickPlace(place)
	if(m_Root == nil)then
		return
	end
	removeHand()
	local bd = m_buildArray[tostring(place)]
	if bd then
		do --检测强制 air
			local airs = HomeMapHelperMD.getAirs(place)
			for k , v in pairs(airs) do
				if v and v.lua_clickMode == HomeAirMD.m_AirClickMode.buildingFull and v:isCanClick() then
					--触发
					m_AirJumpTime = true
					v:lua_playClickHide()
					if v.lua_OnClick then
						v.lua_OnClick(bd.configData, bd.buildingData, bd.serverData)
					end
					closeSmallBuildMenu()
					return --发现强制 air 直接触发
				end
			end
		end
		_playClickBuildingSound(bd.configData.origin_build_id)
		moveToCenterAndScaleToConstForGuide(place)
		if bd.configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.market then
			--集市没有菜单
			require("game.maplayer.smallMenuClick").onClick_Market(bd.configData, bd.buildingData, bd.serverData)
		elseif bd.configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.grindery then
			--磨坊没有菜单
			require("game.maplayer.smallMenuClick").onClick_Grindery(bd.configData, bd.buildingData, bd.serverData)
		elseif bd.configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.tournament then
			--武斗没有菜单
			require("game.maplayer.smallMenuClick").onClick_Tournament(bd.configData, bd.buildingData, bd.serverData)
		elseif bd.configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.god then
			--神龛没有菜单
			require("game.maplayer.smallMenuClick").onClick_God(bd.configData, bd.buildingData, bd.serverData)
		elseif bd.configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.stars then
			--观星台没有菜单
			require("game.maplayer.smallMenuClick").onClick_Stars(bd.configData, bd.buildingData, bd.serverData)
		elseif bd.configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.activity then
			require("game.maplayer.smallMenuClick").onClick_Activity(bd.configData, bd.buildingData, bd.serverData)
		else
			_onOpenSmallBuildMenu(place)
		end
	else
		closeSmallBuildMenu()
		_onOpenBuild(place)
	end
end



--打开建筑界面时的移动
function moveToCenterForBuildSelect(place)
	if(m_Root == nil)then
		return
	end
	local button = m_MapWidget:getChildByName(tostring(place))
	if(button == nil)then
		return
	end
	m_MapScroll:stopActionByTag(c_tag_scrollScaleAction)
	local viewSize = m_MapScroll:getViewSize()
	local originScale = m_MapScroll:getZoomScale()
	m_originOffsetPos_for_buildSelect = m_MapScroll:getContentOffset()
	local placePos = cc.p(button:getPositionX(),button:getPositionY())
	local scaleVar = 1 / originScale * c_build_interface
	local movePos = cc.p( (placePos.x - viewSize.width * 0.5 / originScale) * -1.0 * originScale , (placePos.y - (viewSize.height * 0.5 + c_build_view_offset_y * g_display.scale / scaleVar) / originScale) * -1.0 * originScale )
	m_lastActionTime_for_buildSelect = math.clampf(cc.pGetDistance(movePos,m_originOffsetPos_for_buildSelect) * 0.0018, 0.5, 0.9)
	m_MapScroll:setContentOffsetInDuration_EaseExponentialOut(movePos,m_lastActionTime_for_buildSelect)
	m_BuildSelectScaleNode:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(m_lastActionTime_for_buildSelect,scaleVar)))
end


--关闭建筑界面时的恢复移动
function moveToOriginForBuildSelect()
	if(m_Root == nil)then
		return
	end
	if(m_lastActionTime_for_buildSelect == nil or m_originOffsetPos_for_buildSelect==nil)then
		return
	end
	m_MapScroll:stopActionByTag(c_tag_scrollScaleAction)
	m_MapScroll:setContentOffsetInDuration_EaseExponentialOut(m_originOffsetPos_for_buildSelect,m_lastActionTime_for_buildSelect)
	m_BuildSelectScaleNode:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(m_lastActionTime_for_buildSelect,1.0)))
	m_lastActionTime_for_buildSelect = nil
	m_originOffsetPos_for_buildSelect = nil
end


--跳转视口到某一个像素位置
function jumpToCenterWithPositionForGuide(position)
	if(m_Root == nil)then
		return
	end
	removeHand()
	closeSmallBuildMenu()
	m_MapScroll:stopActionByTag(c_tag_scrollScaleAction)
	local viewSize = m_MapScroll:getViewSize()
	local originScale = m_MapScroll:getZoomScale()
	local originOffsetPos = m_MapScroll:getContentOffset()
	local contentSize = m_MapScroll:getContentSize()
	local movePos = cc.p( (position.x - viewSize.width * 0.5 / originScale) * -1.0 * originScale , (position.y - (viewSize.height * 0.5 + c_build_view_offset_y * g_display.scale) / originScale) * -1.0 * originScale )
	movePos.x = math.clampf(movePos.x , (contentSize.width * originScale - viewSize.width) * -1.0 , 0.0 )
	movePos.y = math.clampf(movePos.y , (contentSize.height * originScale - viewSize.height) * -1.0 , 0.0 )
	m_MapScroll:setContentOffset(movePos)
	m_BuildSelectScaleNode:setScale(1.0)
	m_lastActionTime_for_buildSelect = nil
	m_originOffsetPos_for_buildSelect = nil
end


--移动视口移动到某一个像素位置
function moveToCenterWithPositionForGuide(position)
	if(m_Root == nil)then
		return
	end
	removeHand()
	closeSmallBuildMenu()
	m_MapScroll:stopActionByTag(c_tag_scrollScaleAction)
	local viewSize = m_MapScroll:getViewSize()
	local originScale = m_MapScroll:getZoomScale()
	local originOffsetPos = m_MapScroll:getContentOffset()
	local contentSize = m_MapScroll:getContentSize()
	local movePos = cc.p( (position.x - viewSize.width * 0.5 / originScale) * -1.0 * originScale , (position.y - (viewSize.height * 0.5 + c_build_view_offset_y * g_display.scale) / originScale) * -1.0 * originScale )
	movePos.x = math.clampf(movePos.x , (contentSize.width * originScale - viewSize.width) * -1.0 , 0.0 )
	movePos.y = math.clampf(movePos.y , (contentSize.height * originScale - viewSize.height) * -1.0 , 0.0 )
	local actionTime = math.clampf(cc.pGetDistance(movePos,originOffsetPos) * 0.0018, 0.5, 0.85)
	m_MapScroll:setContentOffsetInDuration_EaseExponentialOut(movePos,actionTime)
	m_BuildSelectScaleNode:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(actionTime,1.0)))
	m_lastActionTime_for_buildSelect = nil
	m_originOffsetPos_for_buildSelect = nil
end


--引导视口移动到某一个位置ID
function moveToCenterForGuide(place)
	if(m_Root == nil)then
		return
	end
	removeHand()
	closeSmallBuildMenu()
	local button = m_MapWidget:getChildByName(tostring(place))
	if(button == nil)then
		return
	end
	m_MapScroll:stopActionByTag(c_tag_scrollScaleAction)
	local viewSize = m_MapScroll:getViewSize()
	local originScale = m_MapScroll:getZoomScale()
	local originOffsetPos = m_MapScroll:getContentOffset()
	local contentSize = m_MapScroll:getContentSize()
	local placePos = cc.p(button:getPositionX(),button:getPositionY())
	local movePos = cc.p( (placePos.x - viewSize.width * 0.5 / originScale) * -1.0 * originScale , (placePos.y - (viewSize.height * 0.5 + c_build_view_offset_y * g_display.scale) / originScale) * -1.0 * originScale )
	movePos.x = math.clampf(movePos.x , (contentSize.width * originScale - viewSize.width) * -1.0 , 0.0 )
	movePos.y = math.clampf(movePos.y , (contentSize.height * originScale - viewSize.height) * -1.0 , 0.0 )
	local actionTime = math.clampf(cc.pGetDistance(movePos,originOffsetPos) * 0.0018, 0.5, 0.85)
	m_MapScroll:setContentOffsetInDuration_EaseExponentialOut(movePos,actionTime)
	m_BuildSelectScaleNode:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(actionTime,1.0)))
	m_lastActionTime_for_buildSelect = nil
	m_originOffsetPos_for_buildSelect = nil
end


--引导视口移动到某一个位置ID,并且将视口放大到一个常量值
function moveToCenterAndScaleToConstForGuide(place)
	if(m_Root == nil)then
		return
	end
	removeHand()
	closeSmallBuildMenu()
	local button = m_MapWidget:getChildByName(tostring(place))
	if(button == nil)then
		return
	end
	m_MapScroll:stopActionByTag(c_tag_scrollScaleAction)
	local viewSize = m_MapScroll:getViewSize()
	local originScale = m_MapScroll:getZoomScale()
	local originOffsetPos = m_MapScroll:getContentOffset()
	local contentSize = m_MapScroll:getContentSize()
	local placePos = cc.p(button:getPositionX(),button:getPositionY())
	local movePos = cc.p( (placePos.x - viewSize.width * 0.5 / originScale) * -1.0 * originScale , (placePos.y - (viewSize.height * 0.5 + c_build_view_offset_y * g_display.scale) / originScale) * -1.0 * originScale )
	movePos.x = math.clampf(movePos.x , (contentSize.width * originScale - viewSize.width) * -1.0 , 0.0 )
	movePos.y = math.clampf(movePos.y , (contentSize.height * originScale - viewSize.height) * -1.0 , 0.0 )
	local const_ScaleVar = 1.0
	if originScale < const_ScaleVar then
		local actionTime = math.clampf(cc.pGetDistance(movePos,originOffsetPos) * 0.0008, 0.14, 0.34)
		m_MapScroll:setContentOffsetInDuration(movePos,actionTime)
		m_BuildSelectScaleNode:runAction(cc.ScaleTo:create(actionTime,1.0))
		do
			local function onScaleToConst()
				m_MapScroll:setZoomScaleInDuration(const_ScaleVar, (const_ScaleVar - originScale) * 0.9)
			end
			local act = cc.Sequence:create(cc.DelayTime:create(actionTime), cc.CallFunc:create(onScaleToConst))
			act:setTag(c_tag_scrollScaleAction)
			m_MapScroll:runAction(act)
		end
	else
		local actionTime = math.clampf(cc.pGetDistance(movePos,originOffsetPos) * 0.0018, 0.5, 0.85)
		m_MapScroll:setContentOffsetInDuration_EaseExponentialOut(movePos,actionTime)
		m_BuildSelectScaleNode:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(actionTime,1.0)))
	end
	m_lastActionTime_for_buildSelect = nil
	m_originOffsetPos_for_buildSelect = nil
end


--引导视口移动到某一个位置ID,并且打开小菜单,如果小菜单无法弹出或者是空地就放根手指
function moveToCenterAndOpenInterfaceForGuide(place)
	if(m_Root == nil)then
		return
	end
	local bd = m_buildArray[tostring(place)]
	if bd then
		do --检测强制 air
			local airs = HomeMapHelperMD.getAirs(place)
			for k , v in pairs(airs) do
				if v and v.lua_clickMode == HomeAirMD.m_AirClickMode.buildingFull and v:isCanClick() then
					moveToCenterAndScaleToConstForGuide(place)
					createHand(place)
					return --发现强制 air 只移动到对应位置并不弹出小菜单
				end
			end
		end
		moveToCenterAndScaleToConstForGuide(place)
		_onOpenSmallBuildMenu(place)
	else
		moveToCenterForGuide(place)
		createHand(place)
	end
end


--创建手指到某一个位置ID(手指在菜单节点上)
function createHand(place)
	if(m_Root == nil)then
		return
	end
	removeHand()
	local button = m_MapWidget:getChildByName(tostring(place))
	if button then
		local position = cc.p(button:getPositionX(), button:getPositionY())
		local handImage = cc.Sprite:createWithSpriteFrameName("homeImage_guide_finger.png")
		handImage:setPosition(position)
		local act_up = cc.Spawn:create(cc.MoveBy:create(0.6, cc.p(30.0,-25.0)), cc.ScaleTo:create(0.6,1.15))
		local act_down = cc.Spawn:create(cc.MoveBy:create(0.6, cc.p(-30.0,25.0)), cc.ScaleTo:create(0.6,0.95))
		local action = cc.RepeatForever:create(cc.Sequence:create( act_up , act_down ))
		handImage:runAction(action)
		m_MenuNode:addChild(handImage, 1, c_tag_hand)
	end
end


--删除手指
function removeHand()
	if(m_Root == nil)then
		return
	end
	m_MenuNode:removeChildByTag(c_tag_hand)
end


--去野外时的动作变化
function playGoWorld()
	if(m_Root == nil)then
		return
	end
	--m_ChangeScaleNode:setScale(1.0)
	--m_ChangeScaleNode:runAction(cc.ScaleTo:create(0.5,0.7))
end


--从野外回来时的动作变化
function playFromWorldComeBack()
	if(m_Root == nil)then
		return
	end
	m_ChangeScaleNode:setScale(0.7)
	m_ChangeScaleNode:runAction(cc.ScaleTo:create(0.5,1.0))
end


--播放引导剧情动画1
function playGuide_1(endCallback)
	if(m_Root == nil)then
		if endCallback and type(endCallback) == "function" then
			endCallback()
		end
		return
	end
	local rampartData = g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.rampart)
	if rampartData then
		moveToCenterForGuide(rampartData.position)
		local function onMovementEventCallFunc(armature , eventType , name)
			if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
				armature:removeFromParent()
				g_autoCallback.addCocosList( function () ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("anime/anim_cg_WJXL/anim_cg_WJXL.ExportJson") end , 0.05 )
				if endCallback and type(endCallback) == "function" then
					endCallback()
				end
			end
		end
		local armature , animation = g_gameTools.LoadCocosAni(
				"anime/anim_cg_WJXL/anim_cg_WJXL.ExportJson"
				, "anim_cg_WJXL"
				, onMovementEventCallFunc
				, nil
				)
		m_MapEffectNode:addChild(armature, 0, c_tag_mapEffect_guide_1)
		armature:setPosition(cc.p(2050, 405))
		animation:play("dz", -1, 0)
	else
		if endCallback and type(endCallback) == "function" then
			endCallback()
		end
	end
end


--根据位置返回建筑button
function getBuildButtonWithPlace(place)
	if(m_Root == nil)then
		return nil
	end
	return m_MapWidget:getChildByName(tostring(place))
end


--根据位置返回地基层或建筑层的ImageView
function getBuildImageViewWithPlace(place)
	if(m_Root == nil)then
		return nil
	end
	local button = getBuildButtonWithPlace(place)
	if(button == nil)then
		return nil
	end
	return button:getChildByName("Image_diji")
end


--根据配置ID返回一个可以建造的位置ID,没有返回nil
function getClearingWithBuildID(buildID)
	local id = tonumber(buildID)
	for key , var in pairs(g_data.build_position) do
		if(g_PlayerBuildMode.FindBuild_Place(key) == nil)then
			for k , v in pairs(var.build_id) do
				if(id == v)then	--后期加上地块是否解锁判断
					return tostring(key)
				end
			end
		end
	end
	return nil
end


--得到排兵根节点
function getShowArmyRootNode()
	if m_Root == nil then
		return nil
	end
	return m_MapWidget:getChildByName("Panel_2")
end


--得到整理出来的地图层
function getMapNormalizationPanel()
	if m_Root == nil then
		return nil
	end
	return m_MapNormalizationPanel
end


--将自动特效加入到某一个位置的上面
function addAutoEffectTop(place, node)
	if(m_Root == nil)then
		return
	end
	local button = getBuildButtonWithPlace(place)
	if(button == nil)then
		return
	end
	button:getChildByName("autoEffect"):addChild(node)
end


--将自动特效加入到某一个位置的下面
function addAutoEffectBottom(place, node)
	if(m_Root == nil)then
		return
	end
	local button = getBuildButtonWithPlace(place)
	if(button == nil)then
		return
	end
	button:getChildByName("autoEffect_1"):addChild(node)
end

--城市士兵Tips
function showCitySoldierTips(pos, id, dt)
	if(m_Root == nil)then
		return
	end
	local textLabel = cc.Label:createWithTTF(g_tr(g_data.city_tips[id].description), "cocostudio_res/simhei.ttf", 20, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	textLabel:disableEffect()
	textLabel:setAnchorPoint(cc.p(0.5, 0.5))
	textLabel:setTextColor(cc.c4b(255, 255, 255, 255))
	local text_size = textLabel:getContentSize()
	if text_size.width > 260 then
		textLabel:setDimensions(260, 0)
				textLabel:setString(g_tr(g_data.city_tips[id].description))
		text_size = textLabel:getContentSize()
	end
	local sp = ccui.Scale9Sprite:create("freeImage/city_tips.png")
	local texture_size = sp:getContentSize()
	local sp_size = cc.size(text_size.width > texture_size.width - 30 and text_size.width + 30 or texture_size.width, text_size.height > texture_size.height - 30 and text_size.height + 30 or texture_size.height)
	sp:setContentSize(sp_size)
	textLabel:setPosition(cc.p(sp_size.width * 0.5, sp_size.height * 0.5 + 6))
	sp:setAnchorPoint(cc.p(0.5, 0.0))
	sp:setPosition(pos)
	sp:addChild(textLabel)
	sp:runAction(cc.Sequence:create(cc.DelayTime:create(dt),cc.RemoveSelf:create()))
	m_CityTipsNode:addChild(sp)
end

--集市Tips
function updateMarketTips(dt)
	if m_Root == nil then
		return
	end
	m_MarketTipsTime = m_MarketTipsTime - dt
	if m_MarketTipsTime > 0 then
		return
	end
	m_MarketTipsTime = 30
	local data = g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.market)	
	if data == nil then
		return
	end
	local button = getBuildButtonWithPlace(data.position)
	if button == nil then
		return
	end
	local effect_Bottom = button:getChildByName("Effect_1")
	local textLabel = cc.Label:createWithTTF(g_tr("homemap_marketTips"), "cocostudio_res/simhei.ttf", 20, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	textLabel:disableEffect()
	textLabel:setAnchorPoint(cc.p(0.5, 0.5))
	textLabel:setTextColor(cc.c4b(255, 255, 255, 255))
	local text_size = textLabel:getContentSize()
	if text_size.width > 260 then
		textLabel:setDimensions(260, 0)
				textLabel:setString(g_tr("homemap_marketTips"))
		text_size = textLabel:getContentSize()
	end
	local sp = ccui.Scale9Sprite:create("freeImage/city_tips.png")
	local texture_size = sp:getContentSize()
	local sp_size = cc.size(text_size.width > texture_size.width - 30 and text_size.width + 30 or texture_size.width, text_size.height > texture_size.height - 30 and text_size.height + 30 or texture_size.height)
	sp:setContentSize(sp_size)
	textLabel:setPosition(cc.p(sp_size.width * 0.5, sp_size.height * 0.5 + 6))
	sp:setAnchorPoint(cc.p(0.5, 0.0))
	sp:setPosition(cc.p(button:getPositionX(), button:getPositionY()))
	sp:addChild(textLabel)
	sp:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.RemoveSelf:create()))
	m_CityTipsNode:addChild(sp)
end


--省电开启
function onPowerSaveOpen()
	if m_Root == nil then
		return
	end
	m_WaveDisplay:setVisible(false)
	--m_Ship_Armature:setVisible(false)
	m_Waterfall:setVisible(false)
end


--省电关闭
function onPowerSaveClose()
	if m_Root == nil then
		return
	end
	m_WaveDisplay:setVisible(true)
	--m_Ship_Armature:setVisible(true)
	m_Waterfall:setVisible(true)
end


--背景变化
function backgroundCheckChange()
	if m_Root == nil then
		return
	end
	local imgId_1 , imgId_2 = nil , nil
	do
		local lv = g_PlayerBuildMode.getMainCityBuilding_lv()
		local lvTab = string.split(g_data.starting[66].data, ",")
		local count = (#lvTab) / 4
		for i = 1 , count , 1 do
			local index = (i - 1) * 4 + 1
			local min = lvTab[index]
			local max = lvTab[index + 1]
			imgId_1 = lvTab[index + 2]
			imgId_2 = lvTab[index + 3]
			if tonumber(min) <= lv and lv <= tonumber(max) then
				imgId_1 = tonumber(imgId_1)
				imgId_2 = tonumber(imgId_2)
				break
			end
		end
	end
	if imgId_1 and imgId_2 and ( imgId_1 ~= m_backgroundImageId_1 or imgId_2 ~= m_backgroundImageId_2 ) then
		local imageView_1 = m_MapWidget:getChildByName("Image_1")
		local imageView_2 = m_MapWidget:getChildByName("Image_2")
		local isDirect = (m_backgroundImageId_1 == nil)
		m_backgroundImageId_1 = imgId_1
		m_backgroundImageId_2 = imgId_2
		local path_1 = g_data.sprite[m_backgroundImageId_1].path
		local path_2 = g_data.sprite[m_backgroundImageId_2].path
		if isDirect then
			imageView_1:removeChildByTag(c_tag_background_change_1)
			imageView_2:removeChildByTag(c_tag_background_change_2)
			imageView_1:loadTexture(path_1)
			imageView_2:loadTexture(path_2)
			local function freeTexture()
				cc.Director:getInstance():getTextureCache():removeUnusedTextures()
			end
			g_autoCallback.addCocosList( freeTexture, 0.25 )
		else
			local sprite_1 = cc.Sprite:create(path_1)
			local sprite_2 = cc.Sprite:create(path_2)
			local size_1 = imageView_1:getContentSize()
			local size_2 = imageView_2:getContentSize()
			sprite_1:setContentSize(size_1)
			sprite_2:setContentSize(size_2)
			sprite_1:setPosition(cc.p(0,0))
			sprite_2:setPosition(cc.p(0,0))
			sprite_1:setAnchorPoint(cc.p(0,0))
			sprite_2:setAnchorPoint(cc.p(0,0))
			imageView_1:removeChildByTag(c_tag_background_change_1)
			imageView_2:removeChildByTag(c_tag_background_change_2)
			imageView_1:addChild(sprite_1, 0, c_tag_background_change_1)
			imageView_2:addChild(sprite_2, 0, c_tag_background_change_2)
			sprite_1:setOpacity(0)
			sprite_2:setOpacity(0)
			sprite_1:runAction(cc.FadeTo:create(1.5, 255))
			local function onTransitionEnd()
				imageView_1:loadTexture(path_1)
				imageView_2:loadTexture(path_2)
				imageView_1:removeChildByTag(c_tag_background_change_1)
				imageView_2:removeChildByTag(c_tag_background_change_2)
				local function freeTexture()
					cc.Director:getInstance():getTextureCache():removeUnusedTextures()
				end
				g_autoCallback.addCocosList( freeTexture, 0.25 )
			end
			sprite_2:runAction(cc.Sequence:create(cc.FadeTo:create(1.5, 255), cc.CallFunc:create(onTransitionEnd)))
			moveToCenterWithPositionForGuide(cc.p(1100,900))
			require("game.effectlayer.fireworks").show()
		end
	end
end


return homeMapLayer