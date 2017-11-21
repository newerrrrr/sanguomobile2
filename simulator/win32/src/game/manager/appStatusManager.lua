local appStatusManager = {}
setmetatable(appStatusManager,{__index = _G})
setfenv(1,appStatusManager)


function onDidEnterBackground_inGame()


end


function onWillEnterForeground_inGame(dt)
	if dt > 45 then
		g_clock.ntpServerTime_Async()
		--g_BagMode.RequestSycFreshData()
	end

	if dt > 20 then
		g_BagMode.RequestSycFreshData()
	end
	g_chatData.onWillEnterForeground()
	g_BuffMode.RequestDataAsync(dt)
end





return appStatusManager