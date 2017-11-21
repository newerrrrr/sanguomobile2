--region TunMode.lua
--Author : luqingqing
--Date   : 2015/11/16
--此文件由[BabeLua]插件自动生成

local TunMode = class("TunMode")

function TunMode:ctor()
--PlayerHelp
end

function TunMode:getAlienceId()
    return g_AllianceMode.getGuildId()
end

function TunMode:helpAll(fun)
    local tbl = {}

    local function callback(result, data)
         if result == true then
            if fun~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("player_help/helpAll", tbl, callback)
end

function TunMode:helpAll_Async(fun)
    local tbl = {}

    local function callback(result, data)
         if result == true then
            if fun~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("player_help/helpAll", tbl, callback, true)
end

function TunMode:helpArmy(fun)
    local tbl = {}

    local function callback(result, data)
        if result == true then
            if fun~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("player_help/viewHelpArmy", tbl, callback)
end

function TunMode:armyLeft(ppid, fun)
    local tbl = {
        ["ppq_id"]=ppid
    }

    local function callback(result, data)
        if result == true then
            if fun~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("player_help/letHelpArmyBackHome", tbl, callback)
end

return TunMode

--endregion
