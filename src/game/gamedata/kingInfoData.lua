local kingInfoData = {}
setmetatable(kingInfoData,{__index = _G})
setfenv(1,kingInfoData)


local baseData = nil

function SetData(data)
	baseData = data.King
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData)
		end
	end
	g_sgHttp.postData("King/getInfo",{},onRecv)
	return ret
end


--异步请求数据
function RequestData_Async(callbcak)
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData)
		end

        if callbcak then
            callbcak(result, msgData)
        end
	end
	g_sgHttp.postData("King/getInfo",{},onRecv,true)
end


--得到基本信息,只可使用不可修改
function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end


--国王战是否进行中
function isKingBattleStarted()
	local data = GetData()
	if data then
		local cur = g_clock.getCurServerTime()
		return data.start_time < cur and cur < data.end_time
	end
	return false
end

--国王战还有多久开始,已经开始返回0
function kingBattleSoonTime()
	
    local data = GetData()

	if isKingBattleStarted() then
        return 0
    end

    if data then
        
        local cur = g_clock.getCurServerTime()
        
        local startTime = data.start_time
        
        local endTime = data.end_time

		local t = startTime  + ( endTime < cur and g_data.starting[52].data or 0 ) - cur

		return t
	end

	return 0
end

function isKingBtnShow()
    local data =  GetData()
    if data then



        return g_clock.isSameDay(tonumber(data.end_time),tonumber(g_clock.getCurServerTime()))
        
        --(showTime.year == nowTime.year) and (showTime.month == nowTime.month) and (showTime.day == nowTime.day)

        --return showTime.

    end

end


return kingInfoData