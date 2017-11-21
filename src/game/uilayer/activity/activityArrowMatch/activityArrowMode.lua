local ActivityArrowMode = {}
setmetatable(ActivityArrowMode,{__index = _G})
setfenv(1, ActivityArrowMode)

local arrowInfo = {}

--请求射箭前需要扣除箭矢数量
function reqpreArchery(genIds, arrowCount, callback)

  local function onRecv(result, data) --扣完箭才能进入比赛
    g_busyTip.hide_1()
    if result then 
      dump(data, "====data")      
      g_gameCommon.dispatchEvent("UpdateArrowMatchInfo", {arrowNum = data.arrow})
      if callback then 
        callback(data.arrow, data.wind)
      end 
    end 
  end 

  local para = {}
  para.general_1 = genIds[1] 
  para.general_2 = genIds[2] 
  para.general_3 = genIds[3] 
  para.arrow_count = arrowCount
  g_sgHttp.postData("Arrow/preArchery", para, onRecv, true) 
  g_busyTip.show_1() 
end 

--备份最佳成绩，奖牌数，剩余箭矢
function setArrowInfo(info)
  if nil == info then return end 

  if info.score then 
    if arrowInfo.score and arrowInfo.score < info.score then 
      arrowInfo.score = info.score 
    end 
  end 

  if info.medals then 
    arrowInfo.medals = info.medals 
  end 

  if info.addMedals then --增加奖牌
    arrowInfo.medals = arrowInfo.medals + info.addMedals 
  end 

  if info.arrowNum then 
    arrowInfo.arrowNum = info.arrowNum 
  end 
end 

function getArrowInfo()
  return arrowInfo 
end 

return ActivityArrowMode 

