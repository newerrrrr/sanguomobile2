local saveTools = {}
setmetatable(saveTools,{__index = _G})
setfenv(1,saveTools)

local fileEndStr = "__FILE_SAVED__"

function saveStringToFile(filePath,str)

  assert(not string.find(str,fileEndStr))

  --local filePath = cc.FileUtils:getInstance():getWritablePath()
  local configFile = assert( io.open(filePath,"w+" ) )

  configFile:write(str)
  configFile:close()
  
  configFile = assert( io.open(filePath,"a" ) )
  configFile:write(fileEndStr)
  configFile:close()
  
end

function getStringFromFile(filePath)
     local str = nil
     if cc.FileUtils:getInstance():isFileExist(filePath) then
         local configFile = cc.FileUtils:getInstance():getStringFromFile(filePath)
         if string.find(configFile,fileEndStr) then
            str = string.gsub(configFile,fileEndStr,"")
         end
     end
     return str
end


return saveTools