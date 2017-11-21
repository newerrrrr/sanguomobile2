
local Mail = class("Mail")

function Mail:ctor(serverInfo)
  self._baseInfo = serverInfo 

  self:setReadFlag(serverInfo.read_flag)
  self:setStatus(serverInfo.status)
end 

function Mail:getBaseInfo()
  return self._baseInfo
end 

--0: 未读, 1:已读
function Mail:setReadFlag(flag)
  self._readFlag = flag 
end 

function Mail:getReadFlag()
  return self._readFlag
end 

--status:  0:普通, 1:锁定(收藏), -1:删除
function Mail:setStatus(status)
  self._status = status 
end 

function Mail:getStatus()
  return self._status 
end 



return Mail 
