
local MilitaryCampData = class("MilitaryCampData")
local SoldierTrap = require("game.uilayer.militaryCamp.SoldierTrap")

local SoldierType = {
  ["Infantry"] = 1,   --步兵
  ["Cavalry"] = 2,    --骑兵
  ["Archer"] = 3,     --弓兵
  ["Catapults"] = 4,  --投石车
  ["Trap"] = 99999,       --陷阱
}

--增加每次造兵上限buff
local AddBuildType = 
{
    [SoldierType.Infantry] = 0,--步兵
    [SoldierType.Cavalry] = 0,--骑兵
    [SoldierType.Archer] = 0,--弓兵
    [SoldierType.Catapults] = 0,--投石车
    [SoldierType.Trap] = 0,
}

local CampBuildType = {
  [SoldierType.Trap] = 3,       --陷阱
  [SoldierType.Infantry] = 4,   --步兵营
  [SoldierType.Archer] = 5,     --弓兵营
  [SoldierType.Cavalry] = 6,    --骑兵营
  [SoldierType.Catapults] = 7,  --车兵营
}

local CampBuildName = {
  [SoldierType.Infantry] = g_tr_original("camp_infantry"),    --步兵营
  [SoldierType.Archer] = g_tr_original("camp_archer"),        --弓兵营
  [SoldierType.Cavalry] = g_tr_original("camp_cavalry"),      --骑兵营
  [SoldierType.Catapults] = g_tr_original("camp_catapults"),  --车兵营  
  [SoldierType.Trap] = g_tr_original("warFactory"),           --战争工坊
}

local MusicType = 
{
    [SoldierType.Infantry] = 5000007,--步兵
    [SoldierType.Cavalry] = 5000008,--骑兵
    [SoldierType.Archer] = 5000009,--弓兵
    [SoldierType.Catapults] = 5000010,--投石车
    [SoldierType.Trap] = 5000011,
}

local getMusicType = 
{
    [SoldierType.Infantry] = 5000026,--步兵
    [SoldierType.Cavalry] = 5000027,--骑兵
    [SoldierType.Archer] = 5000026,--弓兵
    [SoldierType.Catapults] = 5000028,--投石车
    [SoldierType.Trap] = 5000029,
}

local saveCacheType =
{
    [SoldierType.Infantry] = function (soldier_id) g_saveCache["sloider_infantry"..g_PlayerMode.GetData().user_code ] = soldier_id end,       --步兵
    [SoldierType.Cavalry] = function (soldier_id) g_saveCache["sloider_cavalry"..g_PlayerMode.GetData().user_code ] = soldier_id  end,        --骑兵
    [SoldierType.Archer] = function (soldier_id) g_saveCache["sloider_archer"..g_PlayerMode.GetData().user_code ] = soldier_id end,           --弓兵
    [SoldierType.Catapults] = function (soldier_id) g_saveCache["sloider_catapults"..g_PlayerMode.GetData().user_code ] = soldier_id end,     --车兵
    [SoldierType.Trap] = function (soldier_id) g_saveCache["sloider_trap"..g_PlayerMode.GetData().user_code ] = soldier_id end,
}

local getCacheType = 
{
    [SoldierType.Infantry] =  function () return g_saveCache["sloider_infantry"..g_PlayerMode.GetData().user_code ] end ,       --步兵
    [SoldierType.Cavalry] = function () return g_saveCache["sloider_cavalry"..g_PlayerMode.GetData().user_code ] end ,        --骑兵
    [SoldierType.Archer] = function () return g_saveCache["sloider_archer"..g_PlayerMode.GetData().user_code] end ,           --弓兵
    [SoldierType.Catapults] = function () return g_saveCache["sloider_catapults"..g_PlayerMode.GetData().user_code] end ,     --车兵
    [SoldierType.Trap] = function () return g_saveCache["sloider_trap"..g_PlayerMode.GetData().user_code] end 
}

--驻守武将BUFF
--local allGeneralBuffs = nil
--local foodOutDebuff = nil

function MilitaryCampData:instance()
    if nil == MilitaryCampData._instance then 
        MilitaryCampData._instance = MilitaryCampData.new()
    end 

    return MilitaryCampData 
end 

--获取造兵增加上限BUFF
function MilitaryCampData:getNumPlusBuff(pos)

    self.position = pos

    --整数值
    AddBuildType[SoldierType.Infantry] = g_BuffMode.getFinalBuffValueByBuffKeyName("training_infantry_num_plus",pos)
    AddBuildType[SoldierType.Cavalry] = g_BuffMode.getFinalBuffValueByBuffKeyName("training_cavalry_num_plus",pos)
    AddBuildType[SoldierType.Archer] = g_BuffMode.getFinalBuffValueByBuffKeyName("training_archer_num_plus",pos)
    AddBuildType[SoldierType.Catapults] = g_BuffMode.getFinalBuffValueByBuffKeyName("training_siege_num_plus",pos)
    AddBuildType[SoldierType.Trap] = 0
    
    --获取减少粮食消耗的BUFF
    local food_out_debuff,food_out_debuffType = g_BuffMode.getFinalBuffValueByBuffKeyName("food_out_debuff")
    self.foodOutDebuff = (food_out_debuffType == 1 and food_out_debuff / 10000 or food_out_debuff)

end



function MilitaryCampData:getAllFarmlandsOutPut()
    --local foodOutByHour = g_resYieldMode.FindHourYieldAnd_OriginID(g_PlayerBuildMode.m_BuildOriginType.food)
    local foodOutByHour = require("game.uilayer.buildupgrade.BuildingUIHelper").getResourceBuildOutPut(g_PlayerBuildMode.m_BuildOriginType.food,false)
    return foodOutByHour
end

function MilitaryCampData:getAllSoldierAndTrap()
    if nil == self.allData then 
        self.allData = {}
        for k, v in pairs(g_data.trap) do 
            table.insert(self.allData, SoldierTrap.new(v, true))
        end 

        for k, v in pairs(g_data.soldier) do 
            table.insert(self.allData, SoldierTrap.new(v, false))
        end 
    end 

    return self.allData 
end 

function MilitaryCampData:getDataByType(soldierType)
    local data = {}
    local maxValidIndex = 1 

    for k, v in pairs(self:getAllSoldierAndTrap()) do 
        if v:getType() == soldierType then
            table.insert(data, v)
        end 
    end 

    if #data > 1 then 
        table.sort(data, function(a, b) return a:getId() < b:getId() end)

        --获取当前兵种中能建造的最高级兵 
        local buildId 
        local buildData = g_PlayerBuildMode.GetData()
        
        for k, v in pairs(buildData) do
            if g_data.build[v.build_id].origin_build_id == CampBuildType[soldierType] then 
                buildId = v.build_id 
                break 
            end 
        end 

        if buildId then 
            for k, v in pairs(data) do 
                if buildId >= v:getNeedBuildId() then 
                    maxValidIndex = k 
                end 
            end 
        end 
    end 

    --dump(data)

    return data, maxValidIndex
end 


--粮田
function MilitaryCampData:getLeftFarmOutput()
    --获取服务端粮食每小时剩余产量
    local output = self:getAllFarmlandsOutPut()
    --g_resYieldMode.FindHourYieldAnd_OriginID(g_PlayerBuildMode.m_BuildOriginType.food)
    --self:getAllFarmlandsOutPut()
    --print("output",output)

    --当前所有士兵粮食消耗
    --使用了减少消耗粮食BUFF
    local consume = 0 
    local data = g_SoldierMode:GetData() 
    for k, v in pairs(data) do
        if v.soldier_id and tonumber(v.soldier_id) ~= 0 then
            local configCost = ( g_data.soldier[v.soldier_id].consumption/10000 )
            local foodCost = configCost - configCost * self.foodOutDebuff
            consume = consume + v.num * foodCost
        end
    end

    --当前军团里士兵的
    local armyData = g_ArmyUnitMode.GetCurentData()
    for k, v in pairs(armyData) do
        if v.soldier_id and tonumber(v.soldier_id) ~= 0 then
            local configCost = ( g_data.soldier[v.soldier_id].consumption/10000 )
            local foodCost = configCost - configCost * self.foodOutDebuff
            consume = consume + v.soldier_num * foodCost
        end
    end

    --print("consume",consume)

    return math.max(0, output - consume )
end 


--造兵:根据粮田产量和兵营ouput, 计算每次可建造士兵数量的上限
--陷阱:10小时建造时限来计算每次课建造的陷阱数上限
function MilitaryCampData:getBuildCountMax(mode)

    if mode:getType() == SoldierType.Trap then
        
        local canBuildCount = 0
        local curNum, maxNum,upNum = self:getCurMaxCount(mode)

        if maxNum < upNum then
            --四小时可以创建的数量
            local tenMinCanBuildCount = math.floor( 4 * 3600 / mode:getTrainTime(self.position) )
            --上限值还余下多少
            canBuildCount = upNum - maxNum
            --余下的上限数量大于十分钟可建造的数量
            if canBuildCount > tenMinCanBuildCount then
                canBuildCount = tenMinCanBuildCount
            end
        end

        return canBuildCount
    else
        --剩余粮食供给上限
        local farmOutput = self:getLeftFarmOutput()
        --使用了减少消耗粮食BUFF
        local perConsume = (mode:getFoodCost()/10000) - (mode:getFoodCost()/10000) * self.foodOutDebuff
        local maxNum1 = math.floor(farmOutput/perConsume) 
        
        --兵营每次产出上限
        local maxNum2 = 0
        local buildType = CampBuildType[mode:getType()]
        --BUFF 与 驻守BUFF
        local buildBuffAddNum = AddBuildType[mode:getSoldierType()] or 0
        local buildData = g_PlayerBuildMode.GetData()
        for k, v in pairs(buildData) do 
            if buildType == v.origin_build_id then 
                maxNum2 = g_data.build[v.build_id].output[1][2] + buildBuffAddNum
                break 
            end
        end
        --print("maxNum1,maxNum2",farmOutput,perConsume,maxNum1,maxNum2)
        --兵营可产兵上限 粮食可产兵上限
        --maxNum1 = 0
        return math.min(maxNum1, maxNum2),maxNum1
    end 
end 

--兵营容纳人数上限
function MilitaryCampData:getCampOutputMax()
    local output = 0 
    local buildData = g_PlayerBuildMode.GetData()
    for k, v in pairs(buildData) do 
        if g_data.build[v.build_id].origin_build_id >= 4 and g_data.build[v.build_id].origin_build_id <= 7 then 
            output = output + g_data.build[v.build_id].output[1][2]
        end 
    end 

    return output 
end 

--返回指定类型士兵数和全部士兵数
--返回当前陷阱数/陷阱上限
function MilitaryCampData:getCurMaxCount(mode)
    local curNum = 0 --当前数量
    local maxNum = 0 --总数量
    local upNum = 0 --上限数量 只有陷阱有

    if mode:getType() == SoldierType.Trap then 
        local data = g_TrapMode.GetData()

        for k, v in pairs(data) do 
            --print(" v id,mode id " , v.trap_id,mode:getId() )
            maxNum = maxNum + v.num
            if v.trap_id == mode:getId() then
                curNum = curNum + v.num 
            end
        end
        
        --print("1111111111")
        --upNum为城墙对应的陷阱数量上限
        --[[local data = g_PlayerBuildMode.GetData()
        for k, v in pairs(data) do 
            if v.origin_build_id == 2 then 
                for key, val in pairs(g_data.build[v.build_id].output) do 
                    if val[1] == 7 then 
                    upNum = val[2]
                    end 
                end 
                break 
            end 
        end ]]

        upNum = g_TrapMode.GetTrapCount()
        --print("buff count",AddBuildType[SoldierType.Trap])
        --+ AddBuildType[SoldierType.Trap]

    else 
        local data = g_SoldierMode:GetData() 
        for k, v in pairs(data) do 
            maxNum = maxNum + v.num 
            if mode:getId() == v.soldier_id then 
                curNum = v.num 
            end 
        end 
    end
    return curNum, maxNum,upNum
end 

function MilitaryCampData:getCampBuildInfoByType(soldierType)
    local campType = CampBuildType[soldierType]
    local buildData = g_PlayerBuildMode.GetData()
    for k, v in pairs(buildData) do 
        if v.origin_build_id == campType then 
            return v 
        end 
    end 
end 

function MilitaryCampData:getSolierTypeByBuildId(buildId)
    if buildId and g_data.build[buildId] then 
        local buildType = g_data.build[buildId].origin_build_id 
        for k, v in pairs(CampBuildType) do 
            if v == buildType then 
                print("==================",k)
                return k 
            end 
        end 
    end
    return SoldierType.Infantry 
end 




function MilitaryCampData:getBuildName(soldierType)
    return CampBuildName[soldierType]
end 

function MilitaryCampData:getSoldierTypeEnum()
    return SoldierType
end
--造兵音效
function MilitaryCampData:getSoundType(soldierType)
    return MusicType[soldierType]
end
--训练完成
function MilitaryCampData:getCompleteSoundType(soldierType)
    return getMusicType[soldierType]
end
--获取武将驻守BUFF
function MilitaryCampData:getBuffValue(key,type)
    --return allGeneralBuffs
    if key == nil then
        return 0
    end

    type = type or 2

    local buffData = g_BuffMode.GetData()
    local gBuffData = self.allGeneralBuffs

    local buffNum = 0

    if buffData then
        --return 0
        buffNum = buffData[key] and buffData[key].v or 0
    end

    if gBuffData then
        buffNum = buffNum + (gBuffData[key] or 0)
    end

    if type == 1 then
        buffNum = buffNum / 10000
    end

    return buffNum
end



--兵营升级外部接口检测是否该士兵解锁
function MilitaryCampData:getUpSoldierIsLock(sid)
    
    if sid == nil then
        return false
    end
    
    local conifg = g_data.soldier[sid]

    if conifg == nil then
        return false
    end

    local upConfig = g_data.soldier[conifg.upgrade_id]
    
    if upConfig == nil then
        return false
    end

    local soldierType = conifg.soldier_type
    
    local buildData = self:getCampBuildInfoByType(soldierType)

    if buildData == nil then
        return false
    end

    local buildId = buildData.build_id

    --dump(buildData)

    --[[local buildData = g_PlayerBuildMode.GetData()
    
    if buildData == nil then
        return
    end

    for k, v in pairs(buildData) do
        if g_data.build[v.build_id].origin_build_id == CampBuildType[soldierType] then 
            buildId = v.build_id 
            break 
        end 
    end]]

    if buildId == nil then
        return false
    end

    if upConfig.need_build_id == 0 or upConfig.need_build_id == nil then
        return false
    end

    if buildId >= upConfig.need_build_id then
        return true
    end

    return false
end

--升级后 记录最新解锁兵种
function MilitaryCampData.saveUnlockSolider(build_id)
    
    if build_id == nil then
        return nil
    end
    
    local unlockConfig = nil
    for key, var in pairs(g_data.soldier) do
        if var.need_build_id == tonumber(build_id) then
            unlockConfig = var
            break
        end
    end

    for key, var in pairs(g_data.trap) do
        if var.need_build_id == tonumber(build_id) then
            unlockConfig = var
            break
        end
    end

    if unlockConfig then
        local sType = unlockConfig.soldier_type
        if sType == nil and unlockConfig.trap_type then
            sType = SoldierType.Trap
        end
        saveCacheType[sType](unlockConfig.id)
    end
end

function MilitaryCampData:setNewLockSoldierID( soldierType )
    if soldierType == nil then
        return 0
    end
    
    saveCacheType[soldierType](0)
    --return getCacheType[soldierType]
end


function MilitaryCampData:getNewLockSoldierID( soldierType )
    if soldierType == nil then
        return 0
    end
    return getCacheType[soldierType]()
end


return MilitaryCampData 