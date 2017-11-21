--region CollegeMode.lua
--Author : luqingqing
--Date   : 2015/11/5
--此文件由[BabeLua]插件自动生成

local CollegeMode = class("CollegeMode")

function CollegeMode:ctor()

end

function CollegeMode:getData(fun)
    local function callback()
        self:getBasicData(fun)
    end

    self:finish(callback)
end

--getBasicData--
function CollegeMode:getBasicData(fun)
    local tbl = 
    {
        ["name"] = {"PlayerBuild", "PlayerStudy"}
    }

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(g_PlayerMode.GetData(),  g_GeneralMode.GetData(), data.PlayerStudy, data.PlayerBuild)
            end
        end
    end

    g_netCommand.send("/data/index/", tbl, callback)
end

--学习结算
function CollegeMode:finish(fun)
    local tbl = {}

    local function callback(result, data)
        if result == true then
            self:getBasicData(fun)
        end
    end

    g_netCommand.send("Study/finish", tbl, callback)
end

--购买学习位
function CollegeMode:buyPosition(fun)
    local tbl = {}

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("Study/buyPosition", tbl, callback)
end

--开始学习
function CollegeMode:study(pos, studyType, fun)

    local tbl = 
    {
        ["position"] = pos,
        ["type"] = studyType
    }

    local function callback(result, data)
        if result == true then
            self:getBasicData(fun)
        end
    end

    print("!!!!!!!!!!!!!!!!!!!!!!!!!")

    g_netCommand.send("Study/begin", tbl, callback)

end

--加速学习
function CollegeMode:accelerate(pos, fun)
    local tbl = 
    {
        ["position"] = pos
    }

    local function callback(result, data)
        if result == true then
            self:getBasicData(fun)
        end
    end

    g_netCommand.send("Study/accelerate", tbl, callback)
end

--设置武将
function CollegeMode:setGeneral(pos, generalId, fun)
    local tbl = 
    {
        ["position"] = pos,
        ["generalId"] = generalId
    }

    local function callback(result, data)
        if result == true then
            self:getBasicData(fun)
        end
    end

    g_netCommand.send("Study/setGeneral", tbl, callback)
end

return CollegeMode

--endregion
