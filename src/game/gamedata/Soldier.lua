local Soldier = class("Soldier")

--创建时可以传入configId或者来自服务器的table信息
function Soldier:ctor(info)
    
    --self:setIsHurted(false)
    self:setCount(0)
    self:setHurtedCount(0)
    --configId
    if type(info) == "number" then
        self:initWithConfigId(info)
    else
        self:updateExtraInfo(info)
    end	
end

function Soldier:initWithConfigId(configId)
  if configId == nil then
      return
  end
  
  local soldierConfig = g_data.soldier[configId]
  assert(soldierConfig,"cannot found soldier with id:"..configId)
  self:setConfig(soldierConfig)
end

--更新来着服务器的信息
function Soldier:updateExtraInfo(info)
  if info == nil then
      return
  end
  
  --{"id":2,"player_id":100017,"soldier_id":1002,"num":27,"create_time":0,"update_time":0}
  --TODO:初始化受伤士兵信息
  self:setId(info.id)
  self:initWithConfigId(info.soldier_id)
  self:setHurtedCount(info.num)
end

------
--  Getter & Setter for
--      Soldier._Id
-----
function Soldier:setId(Id)
		self._Id = Id
end

function Soldier:getId()
		return self._Id
end

------
--  Getter & Setter for
--      Soldier._Config
-----
function Soldier:setConfig(Config)
		self._Config = Config
end

function Soldier:getConfig()
		return self._Config
end

------
--  Getter & Setter for
--      Soldier._Count
-----
function Soldier:setCount(Count)
		self._Count = Count
end

function Soldier:getCount()
		return self._Count
end

------
--  Getter & Setter for
--      Soldier._HurtedCount
-----
function Soldier:setHurtedCount(HurtedCount)
		self._HurtedCount = HurtedCount
end

function Soldier:getHurtedCount()
		return self._HurtedCount
end


function Soldier:getCureTime(cureCount)
    local cureCount = cureCount or 1
    local config = self:getConfig()
    local cost = config.rescue_time * cureCount
    return cost
end

function Soldier:getFastCureCost(cureCount)
    local cureCount = cureCount or 1
    local config = self:getConfig()
    local cost = (config.rescue_gem_cost/10000) * cureCount
    return math.ceil(cost)
end

function Soldier:getCureCosts(cureCount)
    local config = self:getConfig()
    local costGroup = config.rescue_cost
    
    local cureCount = cureCount or 1
    
    local costs = {}
    for key, type in pairs(g_Consts.AllCurrencyType) do
        costs[type] = 0
    end
    
    for key, groupElement in pairs(costGroup) do
    	 local costType = groupElement[1]
    	 local costValue = groupElement[2]
    	 if costs[costType] == nil then
    	    costs[costType] = 0
    	 end
    	 costs[costType] = costs[costType] + costValue
    end
    
    for costType, costValue in pairs(costs) do
        costs[costType] = costValue * cureCount
    end
    
    return costs
end

function Soldier:getMaxCureCount(cureCount)
    local cnt = cureCount or self._HurtedCount
    local costs = self:getCureCosts(1)
    for costType, costValue in pairs(costs) do
        if costValue > 0 then
        	local nowHave = g_gameTools.getPlayerCurrencyCount(costType)
        	local canCureCnt = math.floor(nowHave/costValue)
        	cnt = math.min(cnt,canCureCnt)
    	end
    end
    return cnt
end


--[[
------
--  Getter & Setter for
--      Soldier._IsHurted
-----
function Soldier:setIsHurted(IsHurted)
		self._IsHurted = IsHurted
end

function Soldier:getIsHurted()
		return self._IsHurted
end
]]

return Soldier