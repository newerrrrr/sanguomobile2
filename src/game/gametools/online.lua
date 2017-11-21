local online = {}
setmetatable(online,{__index = _G})
setfenv(1,online)

local c_ReqInterval = 40	--sec

local c_OnlineInterval = c_ReqInterval + 20	--sec

local m_lastTime = 0


--循环异步请求,表明我在线
function updateForMainLoop(cocos_dt)
	if g_sceneManager.getCurrentSceneMode() == g_sceneManager.sceneMode.game then
		local current = g_clock.getCurServerTime()
		if current >= m_lastTime + c_ReqInterval then
			m_lastTime = current
			g_sgHttp.postData("common/setOnlineTimestamp", {}, nil, true)
		end
	end
end


--public
--参数current：当前服务器时间g_clock.getCurServerTime()
--参数last：playerData中的玩家上次请求时间
function operateIsOnline(current, last)
	return current < last + c_OnlineInterval
end


return online