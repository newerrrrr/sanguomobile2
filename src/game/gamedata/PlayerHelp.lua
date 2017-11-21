--region PlayerHelp.lua
--Author : luqingqing
--Date   : 2015/11/16
--此文件由[BabeLua]插件自动生成

local PlayerHelpMode = {}
setmetatable(PlayerHelpMode,{__index = _G})
setfenv(1, PlayerHelpMode)

local baseData = nil

local baseView = nil

local updateTime = 0

local baseArmyHelpData = nil

--更新显示
function NotificationUpdateShow()
	
    require("game.uilayer.mainSurface.mainSurfaceEventBar").updateEventBarStatus(false)

    if baseView ~= nil then
        baseView:show()
    end
end


function SetData(data)
	baseData = data
end

function SetView(data)
    baseView = data
end


--同步请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
            updateTime = g_clock.getCurServerTime()
			ret = true
			SetData(msgData.PlayerHelp)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerHelp",}},onRecv, false)
	return ret
end

--异步请求数据
function RequestSycDataHome()
    if g_clock.getCurServerTime() - updateTime  < 20 then
        return
    end

    local function onRecv(result, msgData)
        if(result==true)then
            updateTime = g_clock.getCurServerTime()
            SetData(msgData.PlayerHelp)
            GetHelpNum()
        end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerHelp",}},onRecv, true)
end

--异步请求数据
function RequestSycData(callback)
    local ret = false
	local function onRecv(result, msgData) 
		if(result==true)then
            updateTime = g_clock.getCurServerTime()
			ret = true
			SetData(msgData.PlayerHelp)
            GetHelpNum()
			NotificationUpdateShow()
		else
            if baseView ~= nil then
                baseView:close()
            end
        end

        if callback ~= nil then
            callback(result)
        end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerHelp",}},onRecv, true)
	return ret
end

function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

function canHelp()
    if baseData == nil then
        return false
    end

    local curAlience = g_AllianceMode.getBaseData().id

    local tag = false
    for i=1, #baseData do
        if baseData[i].guild_id == curAlience and (baseData[i].player_id.."") ~= (g_PlayerMode.GetData().id.."") and baseData[i].help_num ~= baseData[i].help_num_max then
            for key, value in pairs(baseData[i].helper_ids) do
                if value.."" == g_PlayerMode.GetData().id.."" then
                        tag = false
                        break
                else
                    tag = true
                end
            end

            if tag == true then
                break
            end
        end
    end

    return tag
end


function SendHelpAction(pos, fun)
    local tbl = {
        ['position'] = pos,
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("player_help/sendHelp", tbl, callback,true)
end

function HelpAll_Async()
    g_netCommand.send("player_help/helpAll", {}, nil, true)
end

function SendHelpAction_Async(pos)
    local tbl = {
        ['position'] = pos,
    }
    g_netCommand.send("player_help/sendHelp", tbl, nil, true)
end

function GetHelpNum()
    local data = GetData()
    local result = {}
    
    if data == nil then
        return 0
    end

    for i=1, #data do
        if data[i].player_id == g_PlayerMode.GetData().id then

        elseif data[i].guild_id == g_AllianceMode.getGuildId() then
            if data[i].help_num ~= data[i].help_num_max then
                 local tag = false
                 for key, value in pairs(data[i].helper_ids) do
                    if value == g_PlayerMode.GetData().id then
                        tag = true
                        break
                    end
                end

                if tag == false then
                    table.insert(result, data[i])
                end
            end
        end
    end

    return (#result)
end

function RequestHelpPlayerSycData()
    local function callback(result, data)
        if result == true then
            baseArmyHelpData = data
        end
    end

    g_netCommand.send("player_help/viewHelpArmy", {}, callback, true)
end


function GetHelpArmyNum()
    if baseArmyHelpData == nil then
        return 0
    end

    if baseArmyHelpData.current_help_num == nil then
        return 0
    end

    return (baseArmyHelpData.current_help_num)
end


return PlayerHelpMode

--endregion
