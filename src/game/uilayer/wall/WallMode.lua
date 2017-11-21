--region WallMode.lua
--Author : luqingqing
--Date   : 2015/11/18
--此文件由[BabeLua]插件自动生成

local WallMode = class("WallMode")

function WallMode:ctor()

end

--修复城墙
function WallMode:restoreWallDurabilityAction(fun)
    local tbl = {}

    local function callback(result, data)
        if result == true then
            fun()
        end
    end

    g_netCommand.send("player/restoreWallDurability", tbl, callback)
end

--灭火
function WallMode:clearFireAction(fun)
    local tbl = {}

    local function callback(result, data)
        if result == true then
            fun()
        end
    end

    g_netCommand.send("player/clearFire", tbl, callback)
end

--请求数据
function WallMode:requestData(fun)
	local function onRecv(result, msgData)
		if(result==true) then
			fun(msgData.Player)
		end
	end
	g_netCommand.send("data/index",{name = {"Player",}},onRecv)
end

function WallMode:refreshWall(fun)

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("player/refreshWall", {}, callback)
end

return WallMode

--endregion
