
--喜迎财神

local LuckyDrawData = {}
setmetatable(LuckyDrawData,{__index = _G})
setfenv(1,LuckyDrawData)


local _luckyDrawData 
function SetData(data)
  _luckyDrawData = data
end

function RequestData()
  local ret = false

  local function onRecv(result, msgData)
    if result then
      ret = true
      SetData(msgData)
    end
  end

  g_sgHttp.postData("Lottery/checkQuickMoneyTimes", {}, onRecv) 
  return ret
end

function GetData() 
  if nil == _luckyDrawData then 
    RequestData() 
  end 

  return _luckyDrawData
end

function IsOpen()
  local data = GetData()
  if data then 
    if g_clock.getCurServerTime() < data.end_time then 
      return true 
    end 
  end 
  
  return false 
end 

return LuckyDrawData
