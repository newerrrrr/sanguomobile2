local autoCallback = {}
setmetatable(autoCallback,{__index = _G})
setfenv(1,autoCallback)

--回调

local m_CocosList = {}	--cocos time
local m_RealList = {}	--real time

local m_lastTime = os.time()



--加入以cocos时间步长为基准计算的队列
--callback 回调方法
--waitTime 等待时间 sec
function addCocosList( callback , waitTime )
	if callback and type(callback) == "function" then	
		local t = waitTime and waitTime or 0
		m_CocosList[(#m_CocosList) + 1] = { func = callback , time = waitTime }
	end
end

--移除指定回调对应的定时器
function removeCocosList(callback) 
	for k , v in ipairs(m_CocosList) do 
		if v.func == callback then 
			table.remove(m_CocosList, k) 
			break 
		end 
	end 
end 

--加入以真实系统时间为基准计算的队列
--callback 回调方法
--waitTime 等待时间 sec
function addRealList( callback , waitTime )
	if callback and type(callback) == "function" then	
		local t = waitTime and waitTime or 0
		m_RealList[(#m_RealList) + 1] = { func = callback , time = waitTime }
	end
end


function table.removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end


--在主循环更新
function updateForMainLoop( cocos_dt )

	local willCallList = {}
	
	do
		local removeCount = 0
		local totalCount = #m_CocosList
		for i = 1 , totalCount , 1 do
			local v = m_CocosList[i - removeCount]
			v.time = v.time - cocos_dt
			if v.time <= 0 then
				willCallList[(#willCallList) + 1] = v.func
				table.remove(m_CocosList, i - removeCount)
				removeCount = removeCount + 1
			end
		end
	end
	
	local currentTime = socket.gettime()
	local real_dt = math.max(0,currentTime - m_lastTime)
	m_lastTime = currentTime
	
	do
		local removeCount = 0
		local totalCount = #m_RealList
		for i = 1 , totalCount , 1 do
			local v = m_RealList[i - removeCount]
			v.time = v.time - real_dt
			if v.time <= 0 then
				willCallList[(#willCallList) + 1] = v.func
				table.remove(m_RealList, i - removeCount)
				removeCount = removeCount + 1
			end
		end
	end
	
	--触发
	for k , v in ipairs(willCallList) do
		v()
	end
	
end






return autoCallback