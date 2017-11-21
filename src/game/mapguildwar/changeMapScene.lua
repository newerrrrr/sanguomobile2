local changeMapScene = {}
setmetatable(changeMapScene,{__index = _G})
setfenv(1,changeMapScene)

--变换地图

local nameList = nil

local CloudEffectMD = require("game.effectlayer.changeCloudEffect")
local ChangeMapScene = require("game.maplayer.changeMapScene")
local GuildWarEnterEffect = require("game.mapguildwar.guildWarEnterEffect")

m_MapEnum = ChangeMapScene.m_MapEnum
local m_MapStatus = ChangeMapScene.getCurrentMapStatus()

local m_isChanging = false	--初始化为没在变化中


local function _goHome(place, gotoSucceedCallback)
	local function onChangeEvent(event)
		if event == CloudEffectMD.m_EnevtEnum.close_start then
			m_isChanging = true
			require("game.mapguildwar.worldMapLayer_bigMap").playGoHome()
		elseif event == CloudEffectMD.m_EnevtEnum.close_complete then
			g_sceneManager.clearAllNodeForMap()
			g_sceneManager.addNodeForMap(require("game.maplayer.homeMapLayer").create())
			require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
		elseif event == CloudEffectMD.m_EnevtEnum.open_start then
			require("game.maplayer.homeMapLayer").playFromWorldComeBack()
		elseif event == CloudEffectMD.m_EnevtEnum.open_complete then
			if place then
				require("game.maplayer.homeMapLayer").moveToCenterForGuide(place)
			end
			m_isChanging = false
			g_musicManager.playMusic(g_data.sounds[5000002].sounds_path,true)
			if gotoSucceedCallback then
				gotoSucceedCallback()
			end
		end
	end
	g_sceneManager.addNodeForTopEffect(CloudEffectMD.create(onChangeEvent))
end

local function _goHomeDirect(place, gotoSucceedCallback) --只在初始化会调用
	g_sceneManager.clearAllNodeForMap()
	g_sceneManager.addNodeForMap(require("game.maplayer.homeMapLayer").create())
	require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
	if place then
		require("game.maplayer.homeMapLayer").moveToCenterForGuide(place)
	end
	m_isChanging = false
	g_musicManager.playMusic(g_data.sounds[5000002].sounds_path,true)
	if gotoSucceedCallback then
		gotoSucceedCallback()
	end
end

local function _goHomeAndOpenInterface(place, gotoSucceedCallback)
	local function onChangeEvent(event)
		if event == CloudEffectMD.m_EnevtEnum.close_start then
			m_isChanging = true
			require("game.maplayer.worldMapLayer_bigMap").playGoHome()
		elseif event == CloudEffectMD.m_EnevtEnum.close_complete then
			g_sceneManager.clearAllNodeForMap()
			g_sceneManager.addNodeForMap(require("game.maplayer.homeMapLayer").create())
			require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
		elseif event == CloudEffectMD.m_EnevtEnum.open_start then
			require("game.maplayer.homeMapLayer").playFromWorldComeBack()
		elseif event == CloudEffectMD.m_EnevtEnum.open_complete then
			if place then
				require("game.maplayer.homeMapLayer").moveToCenterAndOpenInterfaceForGuide(place)
			end
			m_isChanging = false
			g_musicManager.playMusic(g_data.sounds[5000002].sounds_path,true)
			if gotoSucceedCallback then
				gotoSucceedCallback()
			end
		end
	end
	g_sceneManager.addNodeForTopEffect(CloudEffectMD.create(onChangeEvent))
end

local function _goWorld(bigTileIndex, gotoSucceedCallback)

--	local function onChangeEvent(event)
--		if event == CloudEffectMD.m_EnevtEnum.close_start then
--			m_isChanging = true
--			require("game.maplayer.homeMapLayer").playGoWorld()
--		elseif event == CloudEffectMD.m_EnevtEnum.close_complete then
--			g_sceneManager.clearAllNodeForMap()
--			g_sceneManager.addNodeForMap(require("game.mapguildwar.worldMapLayer_bigMap").create(bigTileIndex))
--			require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
--		elseif event == CloudEffectMD.m_EnevtEnum.open_start then
--			require("game.mapguildwar.worldMapLayer_bigMap").playFromHomeComeBack()
--		elseif event == CloudEffectMD.m_EnevtEnum.open_complete then
--			m_isChanging = false
--			g_musicManager.playMusic(g_data.sounds[5000003].sounds_path,true)
--			if gotoSucceedCallback then
--				gotoSucceedCallback()
--			end
--		end
--	end
--	g_sceneManager.addNodeForTopEffect(CloudEffectMD.create(onChangeEvent))

	
	local function onChangeEvent(ret,armature)
		g_sceneManager.clearAllNodeForMap()
		g_sceneManager.addNodeForMap(require("game.mapguildwar.worldMapLayer_bigMap").create(bigTileIndex))
						
		require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
		require("game.mapguildwar.worldMapLayer_bigMap").playFromHomeComeBack()
		
		m_isChanging = false
		g_musicManager.playMusic(g_data.sounds[5000003].sounds_path,true)
		if gotoSucceedCallback then
			gotoSucceedCallback()
		end
	end
	m_isChanging = true
	g_sceneManager.clearInterfaceForGuide() --清除所有打开的界面
	g_sceneManager.addNodeForTopEffect(GuildWarEnterEffect.create(onChangeEvent))
	
end

local function _goWorldDirect(bigTileIndex, gotoSucceedCallback) --只在初始化会调用,但实际上初始化不可能为野外,所以不会调用此函数
	g_sceneManager.clearAllNodeForMap()
	g_sceneManager.addNodeForMap(require("game.mapguildwar.worldMapLayer_bigMap").create(bigTileIndex))
	require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
	m_isChanging = false
	g_musicManager.playMusic(g_data.sounds[5000003].sounds_path,true)
	if gotoSucceedCallback then
		gotoSucceedCallback()
	end
end

local function _goWorldAndOpenInterface(bigTileIndex, gotoSucceedCallback)
	local function onChangeEvent(event)
		if event == CloudEffectMD.m_EnevtEnum.close_start then
			m_isChanging = true
			require("game.maplayer.homeMapLayer").playGoWorld()
			g_kingInfo.RequestData_Async() --请求
		elseif event == CloudEffectMD.m_EnevtEnum.close_complete then
			g_sceneManager.clearAllNodeForMap()
			g_sceneManager.addNodeForMap(require("game.mapguildwar.worldMapLayer_bigMap").create(bigTileIndex))
			require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
		elseif event == CloudEffectMD.m_EnevtEnum.open_start then
			require("game.mapguildwar.worldMapLayer_bigMap").playFromHomeComeBack()
		elseif event == CloudEffectMD.m_EnevtEnum.open_complete then
			require("game.mapguildwar.worldMapLayer_bigMap").changeBigTileIndexAndOpenInterface_Manual(bigTileIndex,true)
			m_isChanging = false
			g_musicManager.playMusic(g_data.sounds[5000003].sounds_path,true)
			if gotoSucceedCallback then
				gotoSucceedCallback()
			end
		end
	end
	g_sceneManager.addNodeForTopEffect(CloudEffectMD.create(onChangeEvent))
end



--得到当前地图类型
function getCurrentMapStatus()
	return m_MapStatus
end


--是否正在变化过度
function isChanging()
	return m_isChanging
end


function changeToHome(isInit, gotoSucceedCallback)
	if isInit == true then
		m_MapStatus = m_MapEnum.home
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		_goHomeDirect(nil, gotoSucceedCallback)
		
	else
		if ChangeMapScene.getCurrentMapStatus() == m_MapEnum.home then
			if gotoSucceedCallback then
				gotoSucceedCallback()
			end
			return
		end
		m_MapStatus = m_MapEnum.home
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		_goHome(nil, gotoSucceedCallback)
		
	end
end


function changeToWorld( isInit, gotoSucceedCallback )
	
	if isInit == true then
		m_MapStatus = m_MapEnum.guildwar
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		local data = g_guildWarPlayerData.GetData()
		_goWorldDirect(g_guildWarPlayerData.GetPosition(), gotoSucceedCallback)
		
	else
		if ChangeMapScene.getCurrentMapStatus() == m_MapEnum.guildwar then
			if gotoSucceedCallback then
				gotoSucceedCallback()
			end
			return
		end
		m_MapStatus = m_MapEnum.guildwar
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)

		_goWorld(g_guildWarPlayerData.GetPosition(), gotoSucceedCallback)

	end
	
end


function changeToChange( gotoSucceedCallback )
	if ChangeMapScene.getCurrentMapStatus() == m_MapEnum.home then
		m_MapStatus = m_MapEnum.guildwar
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		_goWorld(g_guildWarPlayerData.GetPosition(), gotoSucceedCallback)
		
	else
		m_MapStatus = m_MapEnum.home
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		_goHome(nil, gotoSucceedCallback)
		
	end
end


--去野外某一个坐标
function gotoWorld_BigTileIndex( bigTileIndex , gotoSucceedCallback )
	if ChangeMapScene.getCurrentMapStatus() ~= m_MapEnum.guildwar then
		m_MapStatus = m_MapEnum.guildwar
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		_goWorld(bigTileIndex, gotoSucceedCallback)
		
	else
		local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
		bigMap.closeSmallMenu()
		bigMap.closeInputMenu()
		bigMap.changeBigTileIndex_Manual(bigTileIndex,true)
		if gotoSucceedCallback then
			gotoSucceedCallback()
		end
	end
end


--去野外某一个坐标,并且打开菜单
function gotoWorldAndOpenInterface_BigTileIndex( bigTileIndex , gotoSucceedCallback )
	if ChangeMapScene.getCurrentMapStatus() ~= m_MapEnum.guildwar then
		m_MapStatus = m_MapEnum.guildwar
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		_goWorldAndOpenInterface(bigTileIndex, gotoSucceedCallback)
		
	else
		local bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
		bigMap.closeSmallMenu()
		bigMap.closeInputMenu()
		bigMap.changeBigTileIndexAndOpenInterface_Manual(bigTileIndex,true)
		if gotoSucceedCallback then
			gotoSucceedCallback()
		end
	end
end


--去城内某一个位置
function gotoHome_Place( place , gotoSucceedCallback )
	if ChangeMapScene.getCurrentMapStatus() ~= m_MapEnum.home then
		m_MapStatus = m_MapEnum.home
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		_goHome(place, gotoSucceedCallback)
		
	else
		require("game.maplayer.homeMapLayer").moveToCenterForGuide(place)
		if gotoSucceedCallback then
			gotoSucceedCallback()
		end
	end
end


--去城内某一个位置,并且打开小菜单,如果是空地就放根手指
function gotoHomeAndOpenInterface_Place( place , gotoSucceedCallback )
	if ChangeMapScene.getCurrentMapStatus() ~= m_MapEnum.home then
		m_MapStatus = m_MapEnum.home
		ChangeMapScene.setCurrentMapStatus(m_MapStatus)
		
		_goHomeAndOpenInterface(place, gotoSucceedCallback)
		
	else
		require("game.maplayer.homeMapLayer").moveToCenterAndOpenInterfaceForGuide(place)
		if gotoSucceedCallback then
			gotoSucceedCallback()
		end
	end
end

function autoGotoWorld()
--	local changeMapScene = require("game.maplayer.changeMapScene")
--	local mapStatus = changeMapScene.getCurrentMapStatus()
--	if mapStatus == changeMapScene.m_MapEnum.guildwar or m_isChanging == true then
--	else
--		if g_activityData.GetCrossState() then
--			g_sceneManager.clearInterfaceForGuide() --清除所有打开的界面
--			require("game.mapguildwar.changeMapScene").changeToWorld()
--		end
--	end
end


return changeMapScene