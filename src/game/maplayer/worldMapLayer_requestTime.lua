local worldMapLayer_requestTime = {}
setmetatable(worldMapLayer_requestTime,{__index = _G})
setfenv(1,worldMapLayer_requestTime)


m_Lvs = {
	one = 1,
	tow = 2,
	three = 3,
	four = 4,
	five = 5,
}

m_Event_want = {
	moveView = m_Lvs.tow,
	myQueueEnd = m_Lvs.three,
}

m_Event_not = {
	aboutMyPlayAttack = m_Lvs.tow,
}

local c_Polling_lv = m_Lvs.three --轮询的默认优先级

local c_PollingInterval = 8	--轮询间隔时间sec

local c_Polling_lv_Max = m_Lvs.one --最大轮询的默认优先级

local c_PollingInterval_Max = 17	--最大轮询间隔时间sec

local m_RealLastRequestTime = os.time()

local m_RequestSecondsAfter = {}

local m_CanNotRequestSecondsWithin = {}


local function _check_lv(t, lv)
	for k , v in pairs(m_CanNotRequestSecondsWithin) do
		if lv > k and t <= v.sec_up then
			return false
		elseif lv == k and t <= v.sec_same then
			return false
		end
	end
	return true
end


--检测是否该请求
function CheckNeedRequest()
	local cur = g_clock.getCurServerTimeMsecs()
	--最大轮询
	if cur - c_PollingInterval_Max >= m_RealLastRequestTime then
		if _check_lv(cur, c_Polling_lv_Max) then
			return true
		end
	end
	--轮询
	if cur - c_PollingInterval >= m_RealLastRequestTime then
		if _check_lv(cur, c_Polling_lv) then
			return true
		end
	end
	--队列
	for k , v in pairs(m_RequestSecondsAfter) do
		if cur >= v then
			if _check_lv(cur, k) then
				return true
			end
		end
	end
end


--多少秒以后请求
function RequestSecondsAfter( sec, lv )
	m_RequestSecondsAfter[lv] = g_clock.getCurServerTimeMsecs() + sec
end


--多少秒以内不允许请求(lv > lv_up都不可请求, lv == lv_up同级之间乘以权值得出阻止时间, 权值默认0.618)
function CanNotRequestSecondsWithin( sec, lv_up, weight)
	local w = weight and weight or 0.618
	local t = g_clock.getCurServerTimeMsecs()
	m_CanNotRequestSecondsWithin[lv_up] = {
		sec_up = t + sec,
		sec_same = t + sec * w,
		}
end


--重置上一次真实请求时间到当前时间,并且清理队列
function Reset()
	m_RealLastRequestTime = g_clock.getCurServerTimeMsecs()
	m_RequestSecondsAfter = {}
	m_CanNotRequestSecondsWithin = {}
end


return worldMapLayer_requestTime