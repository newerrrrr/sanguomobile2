

local ActivityLuckyDrawMode = class("ActivityLuckyDrawMode")


function ActivityLuckyDrawMode:ctor()

end

function ActivityLuckyDrawMode:instance()
  if nil == ActivityLuckyDrawMode._instance then 
    ActivityLuckyDrawMode._instance = ActivityLuckyDrawMode.new()
  end 

  return ActivityLuckyDrawMode._instance   
end 

function ActivityLuckyDrawMode:incressUsedCounts()
  local data = g_luckyDrawData.GetData() 
  if data then 
    data.times = data.times + 1 
    g_luckyDrawData.SetData(data)
  end 
end 

function ActivityLuckyDrawMode:canDrawMoney()
  local flag = false 
  if g_luckyDrawData.IsOpen() then --喜迎财神
    local data = g_luckyDrawData.GetData() 
    if data then 
      if data.times < 10 then 
        flag = true 
      end 
    end 
  end 
  
  return flag 
end 


--循环播放背景星星动画
function ActivityLuckyDrawMode:playStarAnim(target)
  if nil == target then return end 

  target:removeAllChildren()
  local size = target:getContentSize()

  local armature , animation = g_gameTools.LoadCocosAni(
    "anime/Effect_XiYingCaiShenBeiJing/Effect_XiYingCaiShenBeiJing.ExportJson"
    , "Effect_XiYingCaiShenBeiJing"
    -- , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )
  armature:setPosition(cc.p(size.width/2, size.height/2))
  target:addChild(armature)
  animation:play("Animation1") 
end 

function ActivityLuckyDrawMode:playScrollNumAnim(objArray)
  for k, obj in pairs(objArray) do 
    obj:removeAllChildren() 
    local size = obj:getContentSize()
    local armature , animation = g_gameTools.LoadCocosAni(
      "anime/Effect_XiYingCaiShenNum/Effect_XiYingCaiShenNum.ExportJson"
      , "Effect_XiYingCaiShenNum"
      -- , onMovementEventCallFunc
      --, onFrameEventCallFunc
      )
    armature:setPosition(cc.p(size.width/2, size.height/2))
    obj:addChild(armature)
    animation:play("XunHuan") 
  end 
end 


function ActivityLuckyDrawMode:playNumScrollEndAnim(obj, ineractionNode, callback, tag)
  obj:removeAllChildren()
  
  local function onMovementEventCallFunc(armature , eventType , name)
    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
      armature:removeFromParent()
      if callback then 
        callback(armature:getTag()) 
      end 
    end
  end 

  local size = obj:getContentSize()
  local armature , animation = g_gameTools.LoadCocosAni(
    "anime/Effect_XiYingCaiShenNum/Effect_XiYingCaiShenNum.ExportJson"
    , "Effect_XiYingCaiShenNum"
    , onMovementEventCallFunc
    --, onFrameEventCallFunc
    )
  armature:setPosition(cc.p(size.width/2, size.height/2))
  if tag then 
    armature:setTag(tag)
  end 
  obj:addChild(armature)
  animation:play("ChuXian") 

  if ineractionNode then 
    ineractionNode:setPosition(cc.p(0, 0))
    armature:getBone("Layer2"):addDisplay(ineractionNode, 0)
  end 
end 

function ActivityLuckyDrawMode:getCostByUsedCounts(costId, count)
  for k, v in pairs(g_data.cost) do 
    if v.cost_id == costId and count >= v.min_count and count <= v.max_count then 
      return v.cost_num 
    end 
  end 
end 

return ActivityLuckyDrawMode
