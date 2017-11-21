local timeManager = {}
setmetatable(timeManager,{__index = _G})
setfenv(1,timeManager)

local c_opteate_interval = 5
local m_last_operate_time = 0

local m_last_time = nil
local m_last_date = nil

local function _operatTime(current_time)
	if m_last_time == nil then
		--first time
		m_last_time = current_time
		m_last_date = os.date("*t", m_last_time)
	elseif current_time > m_last_time then
		local current_date = os.date("*t", current_time)
		if m_last_date.day ~= current_date.day then
			g_autoCallback.addCocosList( onChangeDay , 1.0 )
		end
		m_last_time = current_time
		m_last_date = current_date
	end
end

function updateForMainLoop(dt)
	if g_sceneManager.getCurrentSceneMode() == g_sceneManager.sceneMode.game then
		local current_time = g_clock.getCurServerTime()
		if m_last_operate_time < current_time - c_opteate_interval then
			m_last_operate_time = current_time
			_operatTime(current_time)
		end
	end
end





--public

--跨天时调用的回调
function onChangeDay()
    --更新在线奖励活动的数据
    g_limitRewardData.RequestData()

end




return timeManager