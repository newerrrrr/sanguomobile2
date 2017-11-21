--region NewFile_1.lua
--Author : luqingqing
--Date   : 2015/11/16
--此文件由[BabeLua]插件自动生成

--player/getTowerInfo
local TowerMode = class("TowerMode")

function TowerMode:ctor()

end

function TowerMode:getTowerInfo(fun)
    
    local tbl = {}

    local data1 = nil
    local data2 = nil

    local function callback(result, data)
        if result == true then
            data1 = clone(data)
            --if fun ~= nil then
                --dump(data)
                --fun(data)
            --end
        end
    end

    g_netCommand.send("Player/viewAttackArmy", tbl, callback)

    --706 524
    local function callback1(result, data)
        if result == true then
            data2 = clone(data)
        end
    end

    g_netCommand.send("player/viewSpyInfo",nil,callback1)

    if data1 and data2 then
        if table.nums(data2) > 0 then
            for key, var in ipairs(data2) do
                var.isZhenCha = true
                table.insert( data1,{ [1] = var } )
            end
        end
    end

    if fun then
        fun(data1)
    end
end

--[[
1 = {
[LUA-print] -         1 = {
[LUA-print] -             "army" = *MAX NESTING*
[LUA-print] -             "avatar_id"         = 18
[LUA-print] -             "buff" = *MAX NESTING*
[LUA-print] -             "end_time"          = 1467965426
[LUA-print] -             "level"             = 2
[LUA-print] -             "player_nick"       = "sg575632be85128"
[LUA-print] -             "ppq_id"            = 7131
[LUA-print] -             "total_power"       = 842
[LUA-print] -             "total_soldier_num" = 11
[LUA-print] -             "x"                 = 136
[LUA-print] -             "y"                 = 1086
[LUA-print] -         }
[LUA-print] -     }

2 = {
    1 = {}
}
3 = {
    1 = {}
}
]]

return TowerMode

--endregion
