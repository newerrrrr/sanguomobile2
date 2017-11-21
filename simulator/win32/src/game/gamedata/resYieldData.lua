local resYieldData = {}
setmetatable(resYieldData,{__index = _G})
setfenv(1,resYieldData)

local baseData = nil

--更新显示
function NotificationUpdateShow()
	
end

function SetData(data)
	baseData = data
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if result==true then
			ret = true
			SetData(msgData)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("build/getResourceBuildInfo", {}, onRecv)
	return ret
end

--请求数据异步
function RequestData_Async()
	local function onRecv(result, msgData)
		if result==true then
			SetData(msgData)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("build/getResourceBuildInfo", {}, onRecv, true)
end


--public

--得到产量信息,只可使用不可修改
function GetData()
	if baseData == nil then
		RequestData()
	end
	return baseData
end


--手动清空某个位置上的当前产量为0 (只在收获消息成功返回时使用)
function ClearCurrentYield_Place_Manual(place)
	local data = GetData()
	if data then
		local v = data[tostring(place)]
		if v then
			v.cur = 0
		end
	end
end


--查询某个位置上的建筑当前产量
function FindCurrentYield_Place(place)
	local ret = 0
	local data = GetData()
	if data then
		local v = data[tostring(place)]
		if v then
			ret = v.cur
		end
	end
	return ret
end


--查询某个位置上的建筑时产
function FindHourYield_Place(place)
	local ret = 0
	local data = GetData()
	if data then
		local v = data[tostring(place)]
		if v then
			ret = v.hour
		end
	end
	return ret
end


--查询某个类型建筑的时产和 农田产量翻倍无效
function FindHourYieldAnd_OriginID(originID)
	local ret = 0
	local data = GetData()
	if data then
		for k , v in pairs(data) do
			if tonumber(v.origin_build_id) == originID then
				ret = ret + v.net_hour --v.hour
			end
		end
	end
	return ret
end


return resYieldData