local closeFunc = {}
setmetatable(closeFunc,{__index = _G})
setfenv(1,closeFunc)

--屏蔽函数

function disable()
	if cc then
		if cc.Director then
			if closeFunc.Director == nil then
				closeFunc.Director = {}
			end
			
			closeFunc.Director.getRunningScene = cc.Director.getRunningScene
			cc.Director.getRunningScene = nil
			
		end
		
		if cc.EventDispatcher then
			if closeFunc.EventDispatcher == nil then
				closeFunc.EventDispatcher = {}
			end
			
			closeFunc.EventDispatcher.addEventListenerWithFixedPriority = cc.EventDispatcher.addEventListenerWithFixedPriority
			cc.EventDispatcher.addEventListenerWithFixedPriority = nil
			
		end
		
		if cc.FileUtils then
			if closeFunc.FileUtils == nil then
				closeFunc.FileUtils = {}
			end
			
			closeFunc.FileUtils.addSearchPath = cc.FileUtils.addSearchPath
			cc.FileUtils.addSearchPath = nil
			
		end
		
	end
end


--还原函数
function restore()
	if cc then
		if cc.Director then
			if closeFunc.Director == nil then
				closeFunc.Director = {}
			end
			
			if closeFunc.Director.getRunningScene and cc.Director.getRunningScene == nil then
				cc.Director.getRunningScene = closeFunc.Director.getRunningScene
			end
		end
		
		if cc.EventDispatcher then
			if closeFunc.EventDispatcher == nil then
				closeFunc.EventDispatcher = {}
			end
			
			if closeFunc.EventDispatcher.addEventListenerWithFixedPriority and cc.EventDispatcher.addEventListenerWithFixedPriority == nil then
				cc.EventDispatcher.addEventListenerWithFixedPriority = closeFunc.EventDispatcher.addEventListenerWithFixedPriority
			end
			
		end
		
		if cc.FileUtils then
			if closeFunc.FileUtils == nil then
				closeFunc.FileUtils = {}
			end
			
			if closeFunc.FileUtils.addSearchPath and cc.FileUtils.addSearchPath == nil then
				cc.FileUtils.addSearchPath = closeFunc.FileUtils.addSearchPath
			end
		end
		
	end
end


--屏蔽
disable()

return closeFunc