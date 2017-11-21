--region BattleHallMode.lua
--Author : luqingqing
--Date   : 2015/12/31
--此文件由[BabeLua]插件自动生成

local BattleHallMode = class("BattleHallMode")

function BattleHallMode:ctor()

end

function BattleHallMode:warArmyInfo(fun)
    local tbl = {
        ["justCounter"] = 0
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("Army/warArmyInfo", tbl, callback)
end

function BattleHallMode:cancelGather(id, fun)
    local tbl = 
    {
        ["queueId"]= id,
    }

    local function callback(result, data)
        if result == true then
            self:warArmyInfo(fun)
        end
    end

    g_netCommand.send("Map/cancelGather", tbl, callback)
end

function BattleHallMode:callbackStayQueue(id, fun)
    local tbl = 
    {
        ["queueId"]= id,
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                self:warArmyInfo(fun)
            end
        end
    end

    g_netCommand.send("Map/callbackStayQueue", tbl, callback)
end

function BattleHallMode:gotoGather(x, y, qid, armyId, fun,isUseMove)
    
    local tbl = 
    {
        ["x"]= x,
        ["y"]= y,
        ["queueId"]= qid,
        ["armyId"]= armyId,
        ["useMove"] = isUseMove,
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                self:warArmyInfo(fun)
            end
        end
    end

    g_netCommand.send("Map/gotoGather", tbl, callback)
end

function BattleHallMode:getBattleLog(fun)
    local tbl = {}

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("Army/getBattleLog", tbl, callback)

end

function BattleHallMode:sendGatherMail(plist, queueId, fun)
    local tbl = 
    {
        ["toPlayer"] = plist,
        ["queueId"] = queueId
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("Mail/sendGatherMail", tbl, callback)
end

function BattleHallMode:kickGather(targetId, parentQueueId, fun)
    local tbl = 
    {
        ["targetPlayerId"] = targetId,
        ["parentQueueId"] = parentQueueId,
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("Map/kickGather", tbl, callback)
end

function BattleHallMode:getBattleLogDetail(id, fun)
    local tbl = 
    {
        ["battleLogId"] = id,
    }

    local function callback(result, data)
        if fun ~= nil then
            fun(result, data)
        end

        g_busyTip.hide_1()
    end

    g_busyTip.show_1()
    g_netCommand.send("Army/getBattleLogDetail", tbl, callback, true)
end

function BattleHallMode:getGotoTime(x, y, type, fun)
    
    local tbl = 
    {
        ["x"]= x,
        ["y"]= y,
        ["type"]= type,
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("Map/getGotoTime", tbl, callback)
end

return BattleHallMode

--endregion
