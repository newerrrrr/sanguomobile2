--region EquipmentlData.lua
--Author : luqingqing
--Date   : 2015/11/11
--此文件由[BabeLua]插件自动生成


--玩家所有空闲装备


local EquipmentlData = {}
setmetatable(EquipmentlData,{__index = _G})
setfenv(1, EquipmentlData)

local equipData
local refresh = false

--更新显示
function NotificationUpdateShow()

end

function SetData(data)
	equipData = data
end


--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerEquipment)
            refresh = false
		end
	end
	
	g_sgHttp.postData("data/index",{name = {"PlayerEquipment"}}, onRecv)
	
	return ret 
end

function RequestSycData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerEquipment)
            refresh = false
		end
	end
	
	g_sgHttp.postData("data/index",{name = {"PlayerEquipment"}}, onRecv, true)
	
	return ret 
end

--玩家所有空闲装备
function GetData() 
	if nil == equipData then 
		RequestData()
	elseif g_BagMode.GetRefresh() == true then
		g_BagMode.RequestFreshData()
		g_BagMode.SetRefresh(false)
	end

	return equipData 
end

function getSameEquips(equipId)
	local data = GetData()
	if data then 
		for k, v in pairs(data) do 
			if v.item_id == equipId then 
				return v 
			end 
		end 
	end 
end 

function getIdleEquipsByType(equType)
	local tbl = {}
	local data = GetData()
	if data then 
		for k, v in pairs(data) do 
			if g_data.equipment[v.item_id] and g_data.equipment[v.item_id].equip_type == equType then 
				table.insert(tbl, v)
			end 
		end 
	end 
	return tbl 
end 


return EquipmentlData
