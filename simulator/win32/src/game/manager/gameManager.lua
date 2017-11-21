local gameManager = {}
setmetatable(gameManager,{__index = _G})
setfenv(1,gameManager)

PlayedTournament = false

local m_background_last = os.time()

--主循环 c++回调过来的
local function onMainLoop(delta)
	if g_clock then
		g_clock.updateForMainLoop(delta)
	end
	if g_autoCallback then
		g_autoCallback.updateForMainLoop(delta)
	end
	if g_timeManager then
		g_timeManager.updateForMainLoop(delta)
	end
	
	require("game.gametools.online").updateForMainLoop(delta)
end

--进入后台 c++回调过来的
local function onDidEnterBackground()
	g_sgNet.reqToPauseServerHearBeat(true) 

	local director = cc.Director:getInstance()
	director:pause()
	director:stopAnimation()
	local audioEngine = cc.SimpleAudioEngine:getInstance()
	if(g_musicManager)then
		g_musicManager.onDidEnterBackground()
	end
	if g_sceneManager and g_sceneManager.getCurrentSceneMode() == g_sceneManager.sceneMode.game then
		if g_appStatusManager then
			m_background_last = os.time()
			g_appStatusManager.onDidEnterBackground_inGame()
		end
	end
end

--后台返回 c++回调过来的
local function onWillEnterForeground()
	g_sgNet.reqToPauseServerHearBeat(false)

	local director = cc.Director:getInstance()
	director:resume()
	director:startAnimation()
	if(g_musicManager)then
		g_musicManager.onWillEnterForeground()
	end
	if g_sceneManager and g_sceneManager.getCurrentSceneMode() == g_sceneManager.sceneMode.game then
		if g_appStatusManager then
			local current = os.time()
			local dt = current - m_background_last
			m_background_last = current
			g_appStatusManager.onWillEnterForeground_inGame(dt < 0 and 0 or dt)
		end
		cToolsForLua:setBadge(0)
	end
end

--退出游戏 c++回调过来的
local function onExitGame()
	luaBindFunction:getInstance():removeAllLuaFunction()
	local director = cc.Director:getInstance()
	local runingScene = require("game.disableFunc").Director.getRunningScene(director)
	if(runingScene)then
		runingScene:removeAllChildren()
	end
	if package.loaded["game.maplayer.homeBlurLayer"] then
		require("game.maplayer.homeBlurLayer").releaseRenderTexture()
	end
end




local luaBind = luaBindFunction:getInstance()
--这名字的字符串别改,C++在使用
luaBind:binLuaFunction(onMainLoop,"onMainLoop")
luaBind:binLuaFunction(onDidEnterBackground,"onDidEnterBackground")
luaBind:binLuaFunction(onWillEnterForeground,"onWillEnterForeground")
luaBind:binLuaFunction(onExitGame,"onExitGame")



--public

--退出游戏 
function exitGame()
	local target = cc.Application:getInstance():getTargetPlatform()
	if target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
		os.exit(0)
	else
		cc.Director:getInstance():endToLua()
	end
end


--重启
function reStartGame()
	if PlayedTournament then
		exitGame()
		return
	end
	g_gameTools.removeAllCocosAniFileInfo()
	g_gameCommon.sgNetDeinit()
	require("game.uilayer.tournament.schedulerModel").release()
	require "game.disableFunc".restore()
	require"resUpdate.UpdateMgr".deinitSearchPath(true)
	cTools_remove_search_paths("src/","res/","res/cocos/")
	lhs.LHSTmxCache:getInstance():removeAllTmxFile()
	for path , tab in pairs(package.loaded) do
		local v1 , v2 = nil , nil
		v1 , v2 = string.find(path, "cocos%.")
		if v1 and v1 == 1 then
			package.loaded[path] = nil
		else
			v1 , v2 = string.find(path, "data%.")
			if v1 and v1 == 1 then
				package.loaded[path] = nil
			else
				v1 , v2 = string.find(path, "game%.")
				if v1 and v1 == 1 then
					package.loaded[path] = nil
				else
					v1 , v2 = string.find(path, "localization%.")
					if v1 and v1 == 1 then
						package.loaded[path] = nil
					else
						v1 , v2 = string.find(path, "public%.")
						if v1 and v1 == 1 then
							package.loaded[path] = nil
						else
							v1 , v2 = string.find(path, "resUpdate%.")
							if v1 and v1 == 1 then
								package.loaded[path] = nil
							else
								v1 , v2 = string.find(path, "src%.")
								if v1 and v1 == 1 then
									package.loaded[path] = nil
								end
							end
						end
					end
				end
			end
		end
	end
	cToolsForLua:reStartGame()
end


return gameManager