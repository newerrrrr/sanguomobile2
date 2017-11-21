
local LogToFile = {}
setmetatable(LogToFile,{__index = _G})
setfenv(1, LogToFile)

local logFile
local logBuf = ""
local count = 0 

function print(...)
  local arr = {}
  for i, a in ipairs({...}) do
    arr[#arr + 1] = tostring(a)
  end
  -- CCLuaLog(table.concat(arr, "\t"))


  if nil == logFile then 
    logFile = io.open(cc.FileUtils:getInstance():getWritablePath().."hlb_log.txt", "w+")
  end 

  logBuf = logBuf .. table.concat(arr, "\t").."\n"
  count = count + 1 
  if count > 0 then 
      logFile:write(logBuf)
      -- logFile:flush()
      -- logFile:close()
      logBuf = ""
      count = 0 
  end 
end 

return LogToFile 
