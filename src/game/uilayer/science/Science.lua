
local ScienceItem = require("game.uilayer.science.ScienceItem")

local Science = class("Science")
local animTag = {
  hightlight = 100,
  learning = 101,

}

function Science:ctor()
  self.modeData = {}
  for i=1, 143 do 
    self.modeData[i] = ScienceItem.new(i)
  end 
end 

function Science:instance()
  if nil == Science._instance then 
    Science._instance = Science.new()
  end 

  return Science._instance 
end 

--更新服务器数据时同步mode实例数据
function Science:updateModeData(PlayerScience)
  print("updateModeData")
  local id, typeId 
  for k, info in pairs(PlayerScience) do 

    id = info.science_id > 0 and info.science_id or info.next_id 

    typeId = g_data.science[id].science_type_id 
    self.modeData[typeId]:initServerInfo(info)
  end 
end 

--所有mode实例
function Science:getModeData()
  return self.modeData 
end 

function Science:isLearned(id)
  local typeId = g_data.science[id].science_type_id 
  local curLevel = self.modeData[typeId]:getCurMaxLevel() 
  if curLevel > 0 and curLevel >= g_data.science[id].level_id then 
    return true 
  end 

  return false 
end 

--获取当前状态: 1:可学习 2：科技已满 3：正在学习 4: 条件开启 5:建筑等级不足
function Science:getStateByType(typeId)
  local state = 4 
  local mode = self.modeData[typeId]
  local baseInfo = mode:getBaseInfo()

  if mode:isLearning() then 
    state = 3 
  elseif mode:isFinishToTop() then --科技已满
    state = 2 
  elseif self:getScienceBuildLevel() < baseInfo.build_level then --建筑等级不足  
    state = 5 
  else 
    --查看条件开启是否满足，如果满足则为可学习

    local isCondOk = false    
    for k, id in pairs(baseInfo.condition_science) do 
      if id == 0 then --不需要条件
        isCondOk = true 
        break 
      end 

      if id > 0 then 
        if self:isLearned(id) then 
          isCondOk = true 
          break           
        end 
      end 
    end 

    state = isCondOk and 1 or 4 
  end 

  return state 
end 


function Science:getScienceBuildLevel()
  local buildData = g_PlayerBuildMode.GetData() 
  for k, v in pairs(buildData) do 
    if v.origin_build_id == 10 then 
      return v.build_level, v.build_id  
    end 
  end 

  return 0 
end 

--获取当前剩余时间
function Science:getNeedTimeMoney(itemMode)
  local needTime, needMoney 
  local baseInfo = itemMode:getBaseInfo()
  if itemMode:isLearning() then --正在学习时
    needTime = math.max(0, itemMode:getEndTime() - g_clock.getCurServerTime())
    needMoney = math.ceil( math.pow( needTime,0.911) * 0.085) 
  else 
    local nextInfo = itemMode:getNextBaseInfo()
    needTime = nextInfo and nextInfo.need_time or baseInfo.need_time 
    needMoney = nextInfo and nextInfo.gem_cost or baseInfo.gem_cost

    --buff效果
    local allbuffs = g_BuffMode.GetData()
    if allbuffs and allbuffs["science_research_speed"] then
      local val = tonumber(allbuffs["science_research_speed"].v)/10000
      needTime = math.ceil(needTime/(1 + val))
    end
  end

  return needTime, needMoney 
end 

function Science:getCurNextBufStr(baseInfo)
  local str1 = ""
  local str2 = ""

  if baseInfo.buff_num_type == 1 then --万分比
    str1 = string.format("%d%%", baseInfo.buff_num/100)
    str2 = string.format("%d%%", baseInfo.max_buff_num/100)  
  elseif baseInfo.buff_num_type == 2 then --数值
    str1 = string.format("%d", baseInfo.buff_num)
    str2 = string.format("%d", baseInfo.max_buff_num) 
  end 

  return str1, str2  
end 

function Science:playHighlightAnim(target)
  if nil == target then return end 
  
  local size = target:getContentSize()
  local armature, animation = g_gameTools.LoadCocosAni(
    "anime/Effect_XinShouYuanKuangXunHuan/Effect_XinShouYuanKuangXunHuan.ExportJson"
    , "Effect_XinShouYuanKuangXunHuan"
    -- , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )

  armature:setPosition(cc.p(size.width/2, size.height/2))
  armature:setTag(animTag.hightlight)
  target:addChild(armature)
  animation:play("Animation1") 
end 

function Science:playLearnBeginAnim(target)
  if nil == target then return end 
  
  local size = target:getContentSize()

  local armature , animation
  local function onMovementEventCallFunc(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()
    end
  end 
  
  armature , animation = g_gameTools.LoadCocosAni(
    "anime/YanJiouSuo_KeJiKaiQi/YanJiouSuo_KeJiKaiQi.ExportJson"
    , "YanJiouSuo_KeJiKaiQi"
    , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )

  armature:setPosition(cc.p(size.width/2, size.height/2))
  target:addChild(armature)
  animation:play("Animation1") 
end 

--循环播放正在研究的动画
function Science:playLearningAnim(target)
  if nil == target then return end 

  target:removeChildByTag(animTag.learning)

  local size = target:getContentSize()

  local armature , animation = g_gameTools.LoadCocosAni(
    "anime/YanJiouSuo_KeJiShengJiZhong/YanJiouSuo_KeJiShengJiZhong.ExportJson"
    , "YanJiouSuo_KeJiShengJiZhong"
    -- , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )
  armature:setPosition(cc.p(size.width/2, size.height/2))
  armature:setTag(animTag.learning)
  target:addChild(armature)
  animation:play("Animation1") 
 
end 

function Science:stopLearningAnim(target)
  if nil == target then return end 

  target:removeChildByTag(animTag.learning)
end 

function Science:playLearnCompleteAnim(target)
  if nil == target then return end 
  local size = target:getContentSize()

  local armature , animation
  local function onMovementEventCallFunc(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()
    end
  end 
  
  armature , animation = g_gameTools.LoadCocosAni(
    "anime/YanJiouSuo_KeJiKaiQi/YanJiouSuo_KeJiKaiQi.ExportJson"
    , "YanJiouSuo_KeJiKaiQi"
    , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )

  armature:setPosition(cc.p(size.width/2, size.height/2))
  target:addChild(armature)
  animation:play("Animation1") 
end 

function Science:getLearningScience()
  local data = g_ScienceMode.GetData()
  for k, v in pairs(self.modeData) do 
    if v:isLearning() then 
      return g_tr(v:getBaseInfo().name), v 
    end 
  end 

  return ""
end 

function Science:getAnimTagEnum()
  return animTag
end 

--将学习结束的通知服务器
function Science:checkSciIsFinishAsync()
  local function checkResult(result, data)
    print("checkIsFinish result:", result)
  end 

  local data = g_ScienceMode.GetData()
  for k, v in pairs(self.modeData) do 
    if v:isLearning() and v:getEndTime() <= g_clock.getCurServerTime() then 
      g_sgHttp.postData("Science/finish", {}, checkResult, true) 
    end 
  end 
end 

return Science 
