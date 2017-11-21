--region BagData.lua
--Author : luqingqing
--Date   : 2015/11/11
--此文件由[BabeLua]插件自动生成

local BagDataMode = {}
setmetatable(BagDataMode,{__index = _G})
setfenv(1, BagDataMode)

local baseData = nil

local refreshData = false

local bagView = nil

--更新显示
function NotificationUpdateShow()
	require("game.uilayer.bag.BagView"):updateItemView()
end


function SetData(data)
	baseData = data
end

function GetRefresh()
	return refreshData
end

function SetRefresh(value)
	refreshData = value
end

--请求数据
function RequestSycData()
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.PlayerItem)
			NotificationUpdateShow()
            refreshData = false
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerItem",}},onRecv, true)
end


--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerItem)
			NotificationUpdateShow()
            refreshData = false
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerItem",}},onRecv)
	return ret
end

function RequestFreshData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerItem)
			g_EquipmentlMode.SetData(msgData.PlayerEquipment)
			g_MasterEquipMode.SetData(msgData.PlayerEquipMaster)
			NotificationUpdateShow()
            refreshData = false
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerItem","PlayerEquipment","PlayerEquipMaster"}},onRecv)
	return ret
end

function RequestSycFreshData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerItem)
			g_EquipmentlMode.SetData(msgData.PlayerEquipment)
			g_MasterEquipMode.SetData(msgData.PlayerEquipMaster)
			NotificationUpdateShow()
            refreshData = false
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerItem","PlayerEquipment","PlayerEquipMaster"}},onRecv, true)
	return ret
end

--得到背包所有道具,只可使用不可修改
function GetData()
    if baseData == nil then
    	refreshData = false
        RequestData()
    elseif refreshData == true then
    	refreshData = false
    	RequestFreshData()
    end

	return baseData
end

--根据 数据ID 找到道具数据
function FindItemByID(id)
	local data = GetData()
	return data[tostring(id)]
end

--强制刷新背包数据
function Refresh()
    if refreshData == false then
        refreshData = true
    end
end

--找到道具数据
function findItemNumberById(id)
	local item = FindItemByID(id)
	if item then 
		return item.num
	end 

	local count = 0 
	
	return count 
end

--更新显示
function NotificationClose()
    if bagView ~= nil then
        bagView:close()
        setView(nil)
    end
end

function setView(view)
    bagView = view
end

return BagDataMode
--endregion
