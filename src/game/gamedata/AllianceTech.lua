local AllianceTech = class("AllianceTech")

--创建时可以传入configId或者来自服务器的table信息
function AllianceTech:ctor(info)
    self:setIsCanLevelUp(false)
    self:setLevel(0)
    self:setServerConfigLevel(0)
    self:setStatus(0)
    self:setFinishTime(0)
    self:setExp(0)
    --configId
    if type(info) == "number" then
        self:initWithConfigId(info)
    else
        self:updateExtraInfo(info)
    end 
    
end

function AllianceTech:initWithConfigId(configId)
  if configId == nil then
      return
  end
  
  local config = g_data.alliance_science[configId]
  assert(config,"cannot found with id:"..configId)
  self:setConfig(clone(config))
end

--更新来着服务器的信息
function AllianceTech:updateExtraInfo(serverData)
  self:setServerData(serverData)
  if serverData == nil then
      return
  end
  --[[
    {
        "id": 73,
        "science_type": 12,
        "science_level": 0,
        "science_exp": 0,
        "science_level_type": 1,
        "finish_time": 0,
        "status": 0
    }
    ]]
    local configLevel = serverData.science_level
    if configLevel <= 0 then
       configLevel = 1
    end
    
    local configIdStr = string.format(serverData.science_level_type..serverData.science_type.."%02d",configLevel)
    local configId = tonumber(configIdStr)
    assert(g_data.alliance_science[configId],configId.."")
    self:setId(serverData.id)
    self:initWithConfigId(configId)
    self:setServerConfigLevel(serverData.science_level)
    local showLevel = self:getConfig().show_lv
    if serverData.science_level == 0 then
        showLevel = 0
        self:getConfig().star = 0
    else
        if serverData.status ~= 0 then
            showLevel = self:getConfig().show_lv - 1
        else
            if self:getConfig().star == self:getConfig().max_star then
                showLevel = self:getConfig().show_lv
            else
                showLevel = self:getConfig().show_lv - 1
            end
            
            if self:getConfig().level == self:getConfig().max_level then
               showLevel = self:getConfig().show_lv - 1
            end
            
        end
    end
   
    self:setIsCanLevelUp(serverData.status == 1)
    self:setStatus(serverData.status)
    self:setFinishTime(serverData.finish_time)
    self:setExp(serverData.science_exp)
    
    if serverData.status ~= 0 then
        self:getConfig().star = self:getConfig().max_star
    else
        if self:getConfig().star == self:getConfig().max_star then
            self:getConfig().star = 0
        end
        
        if self:getConfig().level == self:getConfig().max_level then
           self:getConfig().star = self:getConfig().max_star
        end
    end
    self:setLevel(showLevel)
end

------
--  Getter & Setter for
--      AllianceTech._Exp
-----
function AllianceTech:setExp(Exp)
		self._Exp = Exp
end

function AllianceTech:getExp()
		return self._Exp
end

------
--  Getter & Setter for
--      AllianceTech._FinishTime
-----
function AllianceTech:setFinishTime(FinishTime)
		self._FinishTime = FinishTime
end

function AllianceTech:getFinishTime()
		return self._FinishTime
end

------
--  Getter & Setter for
--      AllianceTech._Status
-----
function AllianceTech:setStatus(Status)
		self._Status = Status
end

function AllianceTech:getStatus()
		return self._Status
end

------
--  Getter & Setter for
--      AllianceTech._Id
-----
function AllianceTech:setId(Id)
		self._Id = Id
end

function AllianceTech:getId()
		return self._Id
end

------
--  Getter & Setter for
--      AllianceTech._ServerData
-----
function AllianceTech:setServerData(ServerData)
		self._ServerData = ServerData
end

function AllianceTech:getServerData()
		return self._ServerData
end


------
--  Getter & Setter for
--      AllianceTech._ServerConfigLevel
-----
function AllianceTech:setServerConfigLevel(ServerConfigLevel)
		self._ServerConfigLevel = ServerConfigLevel
end

function AllianceTech:getServerConfigLevel()
		return self._ServerConfigLevel
end
------
--  Getter & Setter for
--      AllianceTech._Level
-----
function AllianceTech:setLevel(Level)
		self._Level = Level
end

function AllianceTech:getLevel()
		return self._Level
end

------
--  Getter & Setter for
--      AllianceTech._Config
-----
function AllianceTech:setConfig(Config)
		self._Config = Config
end

function AllianceTech:getConfig()
		return self._Config
end

------
--  Getter & Setter for
--      AllianceTech._IsCanLevelUp
-----
function AllianceTech:setIsCanLevelUp(IsCanLevelUp)
		self._IsCanLevelUp = IsCanLevelUp
end

function AllianceTech:getIsCanLevelUp()
		return self._IsCanLevelUp
end

return AllianceTech