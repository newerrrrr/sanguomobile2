--region BattleHallData.lua
--Author : luqingqing
--Date   : 2016/4/26
--此文件由[BabeLua]插件自动生成

local BattleHallData = {}
setmetatable(BattleHallData,{__index = _G})
setfenv(1, BattleHallData)

local baseData = nil

local tag = false

local first = false

local num = nil

local baseView = nil

--更新显示
function NotificationUpdateShow()
	if baseView ~= nil  then
		baseView:show(baseData)
	end
end


function SetData(data)
	baseData = data
end

function setNum(data)
    num = data
end

function SetView(view)
	baseView = view
end

--请求数据
function RequestSycData(callback)
	if g_AllianceMode.getBaseData().id == 0 then
		return
	end
	
	local ret = false
    local tbl = {
        ["justCounter"] = 1
    }

	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			setNum(msgData)
			if callback then
			    callback()
			end
		end
	end
	g_netCommand.send("Army/warArmyInfo", tbl, onRecv, true)
	return ret
end

function RequestData(callback)
	local ret = false
	local tbl = {
        ["justCounter"] = 0
    }

    local function onRecv(result, data)
        if result == true then
            ret = true
            SetData(data)
            NotificationUpdateShow()
        else
            if baseView ~= nil then
                baseView:close()
            end
        end
        
        if callback ~= nil then
            callback()
        end
    end
    g_netCommand.send("Army/warArmyInfo", tbl, onRecv, true)
	return ret
end

function GetData()
    if baseData == nil then
        RequestData()
    end
    return baseData
end

function showTip()
    if  num == nil or g_AllianceMode.getBaseData().id == 0 then
        return false
    end
    
    if num.num > 0 then
        return true
    else
        return false
    end
end

return BattleHallData

--endregion
