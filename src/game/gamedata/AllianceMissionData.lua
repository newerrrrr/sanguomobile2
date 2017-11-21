
--联盟任务数据

local AllianceMissionData = {}
setmetatable(AllianceMissionData,{__index = _G})
setfenv(1,AllianceMissionData)


local missionData 
function SetData(data)
  missionData = data
end

function RequestData()
  local ret = false

  local function onRecv(result, msgData)
    if result then
      ret = true
      SetData(msgData)
    end
  end

  g_sgHttp.postData("Guild/getMissionRank", {}, onRecv)
  return ret
end

function GetData() 
  if nil == missionData then 
    RequestData() 
  end 

  return missionData
end


return AllianceMissionData
