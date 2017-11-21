
local SoldierTrap = class("SoldierTrap")

function SoldierTrap:ctor(baseInfo, isTrap)
    self.isTrap = isTrap
    if isTrap then 
        self._id = baseInfo.id 
        self._type = 99999
        self._name = baseInfo.trap_name
        self._needBuildId = baseInfo.need_build_id
        self._iconId = baseInfo.img_head
        self._matCost = baseInfo.cost
        self._trainTime = baseInfo.train_time
        self._foodCost = 0 
        self._portrait = baseInfo.img_portrait
        self._gemCost = baseInfo.cost_gem
        self._trapType = baseInfo.trap_type
        self._iconLv = baseInfo.img_level
        --self._intro = baseInfo.soldier_intro
        --self._speedBuff = handler(self,self.getTrapSpeedBuff)
    else 
        self._id = baseInfo.id 
        self._type = baseInfo.soldier_type 
        self._name = baseInfo.soldier_name
        self._needBuildId = baseInfo.need_build_id
        self._iconId = baseInfo.img_head
        self._matCost = baseInfo.cost
        self._trainTime = baseInfo.train_time
        self._foodCost = baseInfo.consumption
        self._portrait = baseInfo.img_portrait
        self._gemCost = baseInfo.gem_cost
        self._soldierType = baseInfo.soldier_type
        self._upgradeId = baseInfo.upgrade_id
        self._iconLv = baseInfo.img_level
        self._intro = baseInfo.soldier_intro
        self._arm_type = baseInfo.arm_type
        --缩减造兵速度buff
        --self._speedBuff = handler(self,self.getSoldierSpeedBuff)
    end
    --dump(SoldierType[self:getSoldierType()])
end 

function SoldierTrap:getArmyType()
    return self._arm_type
end


function SoldierTrap:getId()
    return self._id 
end 

function SoldierTrap:getName()
    return self._name 
end 

function SoldierTrap:getType()
    return self._type 
end 

--建造该士兵/陷阱需要满足的建筑物id
function SoldierTrap:getNeedBuildId()
    return self._needBuildId 
end 

function SoldierTrap:getIconId()
    return self._iconId 
end 

function SoldierTrap:getPortrait()
    return self._portrait  
end 

function SoldierTrap:getMatCost()
    return self._matCost 
end 

function SoldierTrap:getTrainTime( pos )
    if pos == nil then
        return 0
    end
    local buffSpeed = self._trainTime 
    if self.isTrap then
        local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName("pitfall_train_speed",pos)
        local buildBuff = self:getTrapBuildAddBuff(pos)

        print("buildBuff",buildBuff,buffValue)

        if buffType == 1 then --万分比
           buffSpeed = buffSpeed / (1 + buffValue/10000 + buildBuff)
        elseif buffType == 2 then --固定值
           buffSpeed = buffSpeed - buffValue
        end
    else
        local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName("train_troops_speed",pos)
        if buffType == 1 then --万分比
           buffSpeed = buffSpeed / (1 + buffValue/10000)
        elseif buffType == 2 then --固定值
           buffSpeed = buffSpeed - buffValue
        end
    end
    return buffSpeed

end 

function SoldierTrap:getLvIconId()
    return self._iconLv 
end

--每小时消耗粮食(万分比)
function SoldierTrap:getFoodCost()
    return self._foodCost 
end

--快速建造所需要元宝数
function SoldierTrap:getCostGem()
    return self._gemCost 
end

--获取陷阱类型的TYPE，兵没有这个字段，用于更新陷阱展示图的特效
function SoldierTrap:getTrapType()
    return self._trapType
end

function SoldierTrap:getSoldierType()
    return self._soldierType
end

function SoldierTrap:getSoldierUpgradeId()
    return self._upgradeId
end

function SoldierTrap:getSoldierIntro()
    return self._intro
end

function SoldierTrap:getTrapBuildAddBuff(pos)
    
    if self.trapBuildAddBuffValue == nil then
        --获取
        local buildInfo = g_PlayerBuildMode.FindBuild_Place(pos)
        if buildInfo then
            local buildConfig = g_data.build[buildInfo.build_id]
            local output = 0
            for key, var in ipairs(buildConfig.output) do
                if tonumber(var[1]) == 32 then
                    output = var
                    break
                end
            end
            if output then self.trapBuildAddBuffValue = (output[2] / 10000) end
        end
    end
    
    return self.trapBuildAddBuffValue or 0

end


return SoldierTrap 
