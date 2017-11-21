local changeMapScene = {}
setmetatable(changeMapScene,{__index = _G})
setfenv(1,changeMapScene)

--变换地图


local CloudEffectMD = require("game.effectlayer.changeCloudEffect")


m_MapEnum = {
	home = 1,
	world = 2,
	guildwar = 3,
	citybattle = 4,
}

local m_MapStatus = m_MapEnum.home --初始化为主城

local m_isChanging = false	--初始化为没在变化中


local function _goHome(place, gotoSucceedCallback)
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
	local function onChangeEvent(event)
		if event == CloudEffectMD.m_EnevtEnum.close_start then
			m_isChanging = true
			require("game.maplayer.homeMapLayer").playGoWorld()
			g_kingInfo.RequestData_Async() --请求
			--g_activityData.RequestSycCrossBasicInfo()
		elseif event == CloudEffectMD.m_EnevtEnum.close_complete then
			g_sceneManager.clearAllNodeForMap()
			g_sceneManager.addNodeForMap(require("game.maplayer.worldMapLayer_bigMap").create(bigTileIndex))
			require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
		elseif event == CloudEffectMD.m_EnevtEnum.open_start then
			require("game.maplayer.worldMapLayer_bigMap").playFromHomeComeBack()
		elseif event == CloudEffectMD.m_EnevtEnum.open_complete then
			m_isChanging = false
			g_musicManager.playMusic(g_data.sounds[5000003].sounds_path,true)
			if gotoSucceedCallback then
				gotoSucceedCallback()
			end
		end
	end
	g_sceneManager.addNodeForTopEffect(CloudEffectMD.create(onChangeEvent))
end

local function _goWorldDirect(bigTileIndex, gotoSucceedCallback) --只在初始化会调用,但实际上初始化不可能为野外,所以不会调用此函数
	g_sceneManager.clearAllNodeForMap()
	g_sceneManager.addNodeForMap(require("game.maplayer.worldMapLayer_bigMap").create(bigTileIndex))
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
			g_sceneManager.addNodeForMap(require("game.maplayer.worldMapLayer_bigMap").create(bigTileIndex))
			require("game.uilayer.mainSurface.mainSurfaceModeShow").mainScrfaceChangeView()
		elseif event == CloudEffectMD.m_EnevtEnum.open_start then
			require("game.maplayer.worldMapLayer_bigMap").playFromHomeComeBack()
		elseif event == CloudEffectMD.m_EnevtEnum.open_complete then
			require("game.maplayer.worldMapLayer_bigMap").changeBigTileIndexAndOpenInterface_Manual(bigTileIndex,true)
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

function setCurrentMapStatus(status)
  m_MapStatus = status
end

--是否正在变化过度
function isChanging()
	return m_isChanging
end


function changeToHome(isInit, gotoSucceedCallback)
	if isInit == true then
		m_MapStatus = m_MapEnum.home
		
		_goHomeDirect(nil, gotoSucceedCallback)
		
	else
		if m_MapStatus == m_MapEnum.home then
			if gotoSucceedCallback then
				gotoSucceedCallback()
			end
			return
		end
		m_MapStatus = m_MapEnum.home
		
		_goHome(nil, gotoSucceedCallback)
		
	end
end


function changeToWorld( isInit, gotoSucceedCallback )
	
	if isInit == true then
		m_MapStatus = m_MapEnum.world
		
		local data = g_PlayerMode.GetData()
		_goWorldDirect(cc.p(data.x,data.y), gotoSucceedCallback)
		
	else
		if m_MapStatus == m_MapEnum.world then
			if gotoSucceedCallback then
				gotoSucceedCallback()
			end
			return
		end
		m_MapStatus = m_MapEnum.world
	
		local data = g_PlayerMode.GetData()
		_goWorld(cc.p(data.x,data.y), gotoSucceedCallback)
	
	end
	
end


function changeToChange( gotoSucceedCallback )
	if m_MapStatus == m_MapEnum.home then
		m_MapStatus = m_MapEnum.world
		
		local data = g_PlayerMode.GetData()
		_goWorld(cc.p(data.x,data.y), gotoSucceedCallback)
		
	else
		m_MapStatus = m_MapEnum.home
		
		_goHome(nil, gotoSucceedCallback)
		
	end
end


--去野外某一个坐标
function gotoWorld_BigTileIndex( bigTileIndex , gotoSucceedCallback )
	if m_MapStatus ~= m_MapEnum.world then
		m_MapStatus = m_MapEnum.world
		
		_goWorld(bigTileIndex, gotoSucceedCallback)
		
	else
		local bigMap = require("game.maplayer.worldMapLayer_bigMap")
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
	if m_MapStatus ~= m_MapEnum.world then
		m_MapStatus = m_MapEnum.world
		
		_goWorldAndOpenInterface(bigTileIndex, gotoSucceedCallback)
		
	else
		local bigMap = require("game.maplayer.worldMapLayer_bigMap")
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
	if m_MapStatus ~= m_MapEnum.home then
		m_MapStatus = m_MapEnum.home
		
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
	if m_MapStatus ~= m_MapEnum.home then
		m_MapStatus = m_MapEnum.home
		
		_goHomeAndOpenInterface(place, gotoSucceedCallback)
		
	else
		require("game.maplayer.homeMapLayer").moveToCenterAndOpenInterfaceForGuide(place)
		if gotoSucceedCallback then
			gotoSucceedCallback()
		end
	end
end



return changeMapScene