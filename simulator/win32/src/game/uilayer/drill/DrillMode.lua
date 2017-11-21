--region DrillMode.lua
--Author : luqingqing
--Date   : 2015/10/29
--此文件由[BabeLua]插件自动生成

local DrillMode = class("DrillMode")

function DrillMode:ctor()

end

function DrillMode:getData(fun)
    if fun ~= nil then
        fun(g_PlayerMode.GetData(), g_GeneralMode.GetData(), g_ArmyMode.GetData(), g_ArmyUnitMode.GetData(), g_SoldierMode.GetData())
    end        
end

function DrillMode:getCrossData(fun)
    if fun ~= nil then
        fun(g_guildWarPlayerData.GetData(),g_crossGeneral.GetData(),g_crossArmy.GetData(),g_crossArmyUnit.GetData(),g_crossSoldier.GetData())
    end
end

function DrillMode:getCityBattleData(fun)
    if fun ~= nil then
        fun(g_cityBattlePlayerData.GetData(),g_cityBattleGeneral.GetData(),g_cityBattleArmy.GetData(),g_cityBattleArmyUnit.GetData(),g_cityBattleSoldier.GetData())
    end
end

function DrillMode:setUnit(pid, generalList, fun)

    local tbl = {
        ["position"] = pid,
        ["unit"] = generalList,
    }

    local function callback(result, data)
        if result == true then
            self:getData(fun)
        end
    end

    g_netCommand.send("Army/setUnit", tbl, callback)
end

function DrillMode:fullfillSoldier(armyPosition, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
    }

    local function callback(result, data)
        if result == true then
            g_airBox.show(g_tr("fullSuc"))
            self:getData(fun)
        end
    end

    g_netCommand.send("Army/fullfillSoldier", tbl, callback)
end

function DrillMode:setSoldier(armyPosition, unitPosition, soldierId, soldierNum, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
        ["unitPosition"] = unitPosition,
        ["soldierId"] = soldierId,
        ["soldierNum"] = soldierNum,
    }
    
    tbl.steps = g_guideManager.getToSaveStepId()

    local function callback(result, data)
        if result == true then
            self:getData(fun)
        end
    end

    g_netCommand.send("Army/setSoldier", tbl, callback)
end

function DrillMode:setGeneral(armyPosition, unitPosition, generalId, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
        ["unitPosition"] = unitPosition,
        ["generalId"] = generalId,
    }
    
    tbl.steps = g_guideManager.getToSaveStepId()
    
    local function callback(result, data)
        if result == true then
            self:getData(fun)
            g_guideManager.execute()
        end
    end

    g_netCommand.send("Army/setGeneral", tbl, callback)
end

function DrillMode:setCrossGeneral(armyPosition, unitPosition, generalId, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
        ["unitPosition"] = unitPosition,
        ["generalId"] = generalId,
    }
    
    tbl.steps = g_guideManager.getToSaveStepId()
    
    local function callback(result, data)
        if result == true then
            self:getCrossData(fun)
            g_guideManager.execute()
        end
    end

    g_netCommand.send("Cross/setGeneral", tbl, callback)
end

function DrillMode:crossFullfillSoldier(armyPosition, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
    }

    local function callback(result, data)
        if result == true then
            g_airBox.show(g_tr("fullSuc"))
            self:getCrossData(fun)
        end
    end

    g_netCommand.send("Cross/fullfillSoldier", tbl, callback)
end

function DrillMode:setCrossUnit(pid, generalList, fun)

    local tbl = {
        ["position"] = pid,
        ["unit"] = generalList,
    }

    local function callback(result, data)
        if result == true then
            self:getCrossData(fun)
        end
    end

    g_netCommand.send("Cross/setUnit", tbl, callback)
end

function DrillMode:setCrossSoldier(armyPosition, unitPosition, soldierId, soldierNum, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
        ["unitPosition"] = unitPosition,
        ["soldierId"] = soldierId,
        ["soldierNum"] = soldierNum,
    }
    
    tbl.steps = g_guideManager.getToSaveStepId()

    local function callback(result, data)
        if result == true then
            self:getCrossData(fun)
        end
    end

    g_netCommand.send("Cross/setSoldier", tbl, callback)
end

function DrillMode:crossEnterBattlefield(fun)

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("Cross/enterBattlefield", {}, callback)
end

function DrillMode:buySoldier(type, fun)
    local tbl = {
        ["type"] = type,
        ["num"] = 1,
    }

    local function callback(result, data)
        if result == true then
            g_airBox.show(g_tr("buySuccess"))
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("Cross/buySoldier", tbl, callback)
end

--城战
function DrillMode:setCityBattleGeneral(armyPosition, unitPosition, generalId, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
        ["unitPosition"] = unitPosition,
        ["generalId"] = generalId,
    }
    
    tbl.steps = g_guideManager.getToSaveStepId()
    
    local function callback(result, data)
        if result == true then
            self:getCityBattleData(fun)
            g_guideManager.execute()
        end
    end

    g_netCommand.send("City_Battle/setGeneral", tbl, callback)
end

function DrillMode:cityBattleFullfillSoldier(armyPosition, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
    }

    local function callback(result, data)
        if result == true then
            g_airBox.show(g_tr("fullSuc"))
            self:getCityBattleData(fun)
        end
    end

    g_netCommand.send("City_Battle/fullfillSoldier", tbl, callback)
end

function DrillMode:setCityBattleUnit(pid, generalList, fun)

    local tbl = {
        ["position"] = pid,
        ["unit"] = generalList,
    }

    local function callback(result, data)
        if result == true then
            self:getCityBattleData(fun)
        end
    end

    g_netCommand.send("City_Battle/setUnit", tbl, callback)
end

function DrillMode:setCityBattleSoldier(armyPosition, unitPosition, soldierId, soldierNum, fun)
    local tbl = {
        ["armyPosition"] = armyPosition,
        ["unitPosition"] = unitPosition,
        ["soldierId"] = soldierId,
        --["soldierNum"] = soldierNum,
    }
    
    tbl.steps = g_guideManager.getToSaveStepId()

    local function callback(result, data)
        if result == true then
            self:getCityBattleData(fun)
        end
    end

    g_netCommand.send("City_Battle/setSoldier", tbl, callback)
end

function DrillMode:cityBattleEnterBattlefield(fun)

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("City_Battle/enterBattlefield", {}, callback)
end

function DrillMode:buyCityBattleSoldier(type, fun)
    local tbl = {
        ["type"] = type,
        ["num"] = 1,
    }

    local function callback(result, data)
        if result == true then
            g_airBox.show(g_tr("buySuccess"))
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("City_Battle/buySoldier", tbl, callback)
end


return DrillMode

--endregion
