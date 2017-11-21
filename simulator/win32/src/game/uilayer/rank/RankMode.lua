--region RankMode.lua
--Author : luqingqing
--Date   : 2016/3/29
--此文件由[BabeLua]插件自动生成

local RankMode = class("RankMode")

function RankMode:ctor()

end

function RankMode:getRank(type, fun)
    local tbl = 
    {
        ["type"] = type,
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(data.Rank)
            end
        end
        g_busyTip.hide_1()
    end
    g_busyTip.show_1()
    g_netCommand.send("Player/getRank", tbl, callback, true)
end

function RankMode:rankList(fun)
    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(data)
            end
        end
        g_busyTip.hide_1()
    end
    g_busyTip.show_1()
    g_netCommand.send("cross/rankList", {}, callback, true)
end

function RankMode:resultList(fun)
    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(data)
            end
        end
        g_busyTip.hide_1()
    end
    g_busyTip.show_1()
    g_netCommand.send("cross/resultList", {}, callback, true)
end

return RankMode

--endregion
