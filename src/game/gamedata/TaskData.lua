local TaskModel = class("TaskModel")
--创建时可以传入configId或者来自服务器的table信息

function TaskModel:ctor(info)
    if type(info) == "number" then
        self:initWithConfigId(info)
    else
        self:updateExtraInfo(info)
    end 
end

--更新来着服务器的信息
function TaskModel:updateExtraInfo(serverData)
  if serverData == nil then
      return
  end
  
  local configId = serverData.mission_id
  self:initWithConfigId(configId)
  self:setServerData(serverData)
end

------
--  Getter & Setter for
--      TaskModel._ServerData
-----
function TaskModel:setServerData(ServerData)
    self._ServerData = ServerData
end

function TaskModel:getServerData()
   --[[{"id":268,"player_id":100029,"mission_type":1,
    "mission_id":1,"current_mission_number":0,
    "max_mission_number":0,"date_limit":"2016-01-05",
    "status":0,"reward":"","memo":""}]]
    
  
    return self._ServerData
end

function TaskModel:initWithConfigId(configId)
    local config = g_data.mission[configId]
    assert(config,"cannot found with task id:"..configId)
    self:setConfig(config)
end

------
--  Getter & Setter for
--      TaskModel._Config
-----
function TaskModel:setConfig(Config)
    self._Config = Config
end

function TaskModel:getConfig()
    return self._Config
end

--g_TaskMode
local TaskData = {}
local baseData = nil
local allTasks = {}
TaskData.TaskStatusType = 
{
  START = 0,   --已接受
  COMPLETE = 1,--完成，未领奖
  FINISH = 2,  --完成，已领奖励，结束
  TOTAL_FINISH = 3 --所有主线任务已完成，只有主线任务才有这个状态
}

function TaskData.isMainTaskType(mission_type)
    local isMainTask = false
    if mission_type == 1 
    or (mission_type >= 21 and mission_type <= 28) 
    then
        isMainTask = true
    end
    return isMainTask
end

function TaskData.NotificationUpdateShow()
    require("game.uilayer.mainSurface.mainSurfaceChat").taskUpdate()
end

function TaskData.reqBaseData()
   local ret = false
    local function onRecv(result, msgData)
      if result == true then
        ret = true
        TaskData.setBaseData(msgData.PlayerMission)
      end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerMission",}},onRecv)
    return ret
end

function TaskData.requestDataAsync()
    local function onRecv(result, msgData)
      if result == true then
        TaskData.setBaseData(msgData.PlayerMission)
        require("game.uilayer.mainSurface.mainSurfaceChat").taskUpdate()
      end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerMission",}},onRecv,true)
end

function TaskData.setBaseData(data)
    baseData = data
    
--    local function sortFunction(a,b)
--       if a.mission_type == b.mission_type then
--          if a.mission_type == 1 then
--             return a.mission_id < b.mission_id
--          end
--       end
--       return a.mission_type < b.mission_type
--    end
--    table.sort(baseData,sortFunction)
    
    local maxCnt = math.max(#allTasks,#data)
    for i = 1, maxCnt do
    	if i <= #data then
    	   TaskData.updateTaskModelByServerData(i, data[i])
    	else
    	   allTasks[i] = nil
    	end
    end
    
--    for key, var in ipairs(data) do
--    	TaskData.updateTaskModelByServerData(key, var)
--    end
end

--TaskModel 实例信息
function TaskData.updateTaskModelByServerData(idx,serverData)
    local taskModel = allTasks[idx]
    if taskModel == nil then
        taskModel = TaskModel.new()
        allTasks[idx] = taskModel
    end
    taskModel:updateExtraInfo(serverData)
end

function TaskData.getBaseData()
    if baseData == nil then
      TaskData.reqBaseData()
    end
    return baseData
end

function TaskData.getAllTasks()
    local tasks = {}
    local haveMainTask = false
    for key, task in ipairs(allTasks) do
      if TaskData.isMainTaskType(task:getServerData().mission_type)
      and task:getServerData().status == TaskData.TaskStatusType.TOTAL_FINISH then --是主线任务的mission_type=1,
      else --主线任务接完后，不显示主线任务
          if TaskData.isMainTaskType(task:getServerData().mission_type) then
            if  task:getServerData().status == TaskData.TaskStatusType.COMPLETE 
            or task:getServerData().status == TaskData.TaskStatusType.START
            then --是主线任务的mission_type=1,
                if haveMainTask == false then
                    haveMainTask = true
                    table.insert(tasks,task)
                end
            end
          else
              table.insert(tasks,task)
          end
      end
    end
    return tasks
end

function TaskData.getAllDailyTasks()
    local tasks = {}
    local haveMainTask = false
    for key, task in ipairs(allTasks) do
      if not TaskData.isMainTaskType(task:getServerData().mission_type) then
          table.insert(tasks,task)
      end
    end
    return tasks
end

function TaskData.getTargetCreateBuildId()
    local taskData = TaskData.getGuideMainTask()
    local targetBuildId = nil
    if taskData and taskData:getServerData().status == TaskData.TaskStatusType.START then
        local build_id = taskData:getConfig().mission_target
        local buildInfo = g_data.build[build_id]
        if buildInfo and buildInfo.build_level == 1 then
            targetBuildId = build_id
        end
    end 
    return targetBuildId
end

function TaskData.guideToBuildMainTask()
    local taskData = TaskData.getGuideMainTask()
    if not taskData then
        return
    end
    
    print("taskData",taskData:getServerData().status)
    
    if taskData:getConfig().mission_type ~= 1
    or taskData:getServerData().status ~= TaskData.TaskStatusType.START 
    then
        return
    end
    
    TaskData.guideToMainTask(taskData)
end

--如果task_data不传，则引导到最新第一个未完成的主线任务
--如果task_data参数传入，则会根据task_data的状态来做操作：如果task_data已完成未领奖，就直接领奖；如果未完成则引导过去
function TaskData.guideToMainTask(task_data) --界面引导到未完成的主线任务
    print("showTask")
   
    local taskData = task_data or TaskData.getMainTask()
    if not taskData then
        return
    end
    
    if taskData:getServerData().status == TaskData.TaskStatusType.START then
        
        local build_id = taskData:getConfig().mission_target
        local extraActionId = taskData:getConfig().mission_target2
        print(build_id)
        if build_id > 0 and extraActionId == 0 then
            local v = g_PlayerBuildMode.FindBuild_lv_less_ConfigID(build_id)
            if(v)then
              --require("game.maplayer.homeMapLayer").moveToCenterForGuide(v.position)
              local function gotoSuccessHandler()
                  local playerData = g_PlayerMode.GetData()

                  local plevel = playerData.level
                  local showendlevel = tonumber(g_data.starting[49].data or 0) --显示结束等级
                  if plevel >= showendlevel then
                      return
                  end
              
                  local tipMenuId = 102 --建筑升级
                  if v.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then --升级中
                      tipMenuId = 104 --升级加速
                  end
                  require("game.maplayer.smallBuildMenu").setTipMenuID(tipMenuId)
              end
              
              require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(v.position,gotoSuccessHandler)
            else
              local needBuildID = g_PlayerBuildMode.FindBuildConfig_firstBuilding_ConfigID(build_id)
              local canBuildPlace = require("game.maplayer.homeMapLayer").getClearingWithBuildID(needBuildID.id)
              if(canBuildPlace)then
                --require("game.maplayer.homeMapLayer").moveToCenterForGuide(canBuildPlace)
                require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(canBuildPlace) --打开空地位置
                require("game.uilayer.buildSelect.buildSelect").setWantConfigID(needBuildID.id) --定位到指定的建筑
              end
            end
        end
        
        if extraActionId > 0 then
           
--            作者:
--            900001=训练步兵
--            900002=训练骑兵
--            900003=野外打怪
--            900004=研究科技
            if extraActionId == 900001 or extraActionId == 900002 then
            
                local v = g_PlayerBuildMode.FindBuild_origin_ConfigID(build_id)
                if (v) then
                    if v.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng --升级中
                    or v.status == g_PlayerBuildMode.m_BuildStatus.working then --造兵中
                        
                        local function gotoSuccessHandler()
                              local playerData = g_PlayerMode.GetData()
            
                              local plevel = playerData.level
                              local showendlevel = tonumber(g_data.starting[49].data or 0) --显示结束等级
                              if plevel >= showendlevel then
                                  return
                              end
                          
                              --高亮建造士兵加速按钮
                              if g_data.build[build_id] then
                                
                                  local tipMenuId = 0
                                  if v.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then --升级中
                                      tipMenuId = 104 --升级加速
                                  else
                                      if g_data.build[build_id].origin_build_id == 4 then --步兵营
                                          tipMenuId = 129
                                      elseif g_data.build[build_id].origin_build_id == 5 then --弓兵营
                                          tipMenuId = 133
                                      elseif g_data.build[build_id].origin_build_id == 6 then --骑兵营
                                          tipMenuId = 131
                                      elseif g_data.build[build_id].origin_build_id == 7 then --车兵营
                                          tipMenuId = 135
                                      end
                                  end
                  
                                  if tipMenuId > 0 then
                                      require("game.maplayer.smallBuildMenu").setTipMenuID(tipMenuId)
                                  end
                              end
                        end
                          
                        require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(v.position,gotoSuccessHandler)
              
                    else 
                        require("game.maplayer.changeMapScene").gotoHome_Place(v.position)
                        
                        --打开兵营页面
                        local count = taskData:getConfig().mission_number
                        local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
                        if not SoldierTraningLayer:createLayer(v.build_id,count) then
                            print("net error")
                        end
                    end
                end
            elseif extraActionId == 900003 then
                require("game.maplayer.changeMapScene").changeToWorld()
                require("game.uilayer.mainSurface.mainSurfaceChat").createFindMosterHand()
            elseif extraActionId == 900004 then
                g_sceneManager.addNodeForUI(require("game.uilayer.science.ScienceLayer").new(2,taskData:getConfig().mission_number))
            end
            
        end
    elseif taskData:getServerData().status == TaskData.TaskStatusType.COMPLETE then
        TaskData.getAward(taskData,true)
    end
end

--领取奖励
function TaskData.getAward(taskData,isAsync)
    print("getAwardHandler")
    local ret = false
    if isAsync == nil then
        isAsync = false
    end
    local dropGroups = g_gameTools.getDropGroupByDropIdArray(taskData:getConfig().drop)
    local function onRecv(result, msgData)
      if isAsync then
         g_busyTip.hide_1()
      end
      if result == true then
         ret = true
         require("game.uilayer.task.AwardsToast").show(dropGroups)
      end
    end
    
    if isAsync then
        g_busyTip.show_1()
    end
    g_sgHttp.postData("mission/getMissionReward",{current_id = taskData:getServerData().id},onRecv,isAsync)
    return ret
end

--获取未完成的主线任务最新的一个
function TaskData.getMainTask()
    local mainTask = nil
    for key, task in ipairs(allTasks) do
      if TaskData.isMainTaskType(task:getServerData().mission_type)
      and task:getServerData().status == TaskData.TaskStatusType.START
      then
         mainTask = task
         break
      end
    end
    return mainTask
end

--获取可操作的主线任务中的最前面一个（完成但未领奖或者是未完成的）
function TaskData.getGuideMainTask()
    local mainTask = nil
    for key, task in ipairs(allTasks) do
      if TaskData.isMainTaskType(task:getServerData().mission_type) then
          if task:getServerData().status == TaskData.TaskStatusType.START
          or task:getServerData().status == TaskData.TaskStatusType.COMPLETE
          then
             mainTask = task
             break
          end
      end
    end
    return mainTask
end

return TaskData