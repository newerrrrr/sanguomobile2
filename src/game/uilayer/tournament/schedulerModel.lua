local schedulerModel = {}
setmetatable(schedulerModel,{__index = _G})
setfenv(1,schedulerModel)

--独立的时间步以及动作管理

local m_SchedulerActionManager = nil

if lhs.LHSSchedulerActionManager then
	
	function isCanUseScale()
		return true
	end
	
	function ready()
		if m_SchedulerActionManager == nil then
			m_SchedulerActionManager = lhs.LHSSchedulerActionManager:newSchedulerActionManage()
		end
	end

	function release()
		if m_SchedulerActionManager then
			m_SchedulerActionManager:DeleteSchedulerActionManage()
			m_SchedulerActionManager = nil
		end
	end

	function resetNodeSchedulerAndActionManage(node)
		m_SchedulerActionManager:resetNodeSchedulerAndActionManage(node)
	end

	function scheduleScriptFunc(fun, t, p)
		return m_SchedulerActionManager:getScheduler():scheduleScriptFunc(fun, t, p)
	end

	function unscheduleScriptEntry(v)
		m_SchedulerActionManager:getScheduler():unscheduleScriptEntry(v)
	end

	function setScaleTime(s)
		m_SchedulerActionManager:setScaleTime(s)
	end
	
	function pause()
		m_SchedulerActionManager:pause()
	end
	
	function resume()
		m_SchedulerActionManager:resume()
	end	
	
else
	
	function isCanUseScale()
		return false
	end
	
	function ready()
		
	end

	function release()
		
	end

	function resetNodeSchedulerAndActionManage(node)
		
	end

	function scheduleScriptFunc(fun, t, p)
		return cc.Director:getInstance():getScheduler():scheduleScriptFunc(fun, t, p)
	end

	function unscheduleScriptEntry(v)
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
	end
	
	function setScaleTime(s)
		
	end
	
	function pause()
		
	end
	
	function resume()
		
	end
	
end


return schedulerModel