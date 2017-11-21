
--每个系列科技 mode
local ScienceItem = class("ScienceItem")

function ScienceItem:ctor(typeId)
  self._TypeId = typeId

  self._status = -1 
  self._curLevel = 0 
  self._endTime = 0 

  self._baseInfo = g_data.science[100*typeId+1]
  self._maxLevel = self._baseInfo.max_level 
  self._nextInfo = self._baseInfo
end 

function ScienceItem:initServerInfo(info)
  self._serverInfo = info 

  self._status = info.status 
  self._endTime = info.end_time 

  if info.science_id > 0 then --当science_id == 0时代表刚开始学习第一项科技
    self._baseInfo = g_data.science[info.science_id]
    self._curLevel = self._baseInfo.level_id 
    self._nextInfo = g_data.science[self._baseInfo.next_science] 
  end 
end 


--数据表数据
function ScienceItem:getBaseInfo()
  return self._baseInfo
end 

function ScienceItem:getNextBaseInfo()
  return self._nextInfo 
end 

--是否在学习
function ScienceItem:isLearning()
  return self._status > 0 
end 

function ScienceItem:setLearningEnd()
  self._status = 0 
end 

--剩余学习时间是否为 0 
function ScienceItem:isLearningEnd()
  return self._status > 0 and self._endTime <= g_clock.getCurServerTime()
end 

--是否已达到最大科技
function ScienceItem:isFinishToTop()
  if self._status ~= 0 then return false end 

  return self._curLevel >= self._maxLevel 
end 

function ScienceItem:getTypeId()
  return self._TypeId
end 

function ScienceItem:getCurMaxLevel()
  return self._curLevel, self._maxLevel 
end 

function ScienceItem:getEndTime() 
  return self._endTime 
end 

--当前等级/下一等级对应buf
function ScienceItem:getCurNextBufVal()
  local curBuf = 0 
  local nextBuf = self._baseInfo.max_buff_num

  if self._serverInfo then 
    if self._serverInfo.science_id > 0 then 
      local item = g_data.science[self._serverInfo.science_id]
      curBuf = item.max_buff_num 
      if item.next_science > 0 then 
        nextBuf = g_data.science[item.next_science].max_buff_num 
      else 
        nextBuf = 0 
      end 
    end 
  end 

  if self._baseInfo.buff_num_type == 1 then --万分比
    curBuf = math.ceil(curBuf/100).."%%"
    nextBuf = math.ceil(nextBuf/100).."%%"
  end 

  return curBuf, nextBuf 
end 


return ScienceItem 
