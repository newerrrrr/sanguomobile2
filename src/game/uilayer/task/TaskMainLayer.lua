local TaskMainLayer = class("TaskMainLayer",function()
    return cc.Layer:create()
end)

local function itemSelect(item,isSelect)
    item:getChildByName("pic_selected"):setVisible(not isSelect)
end

function TaskMainLayer:ctor()
  	local uiLayer =  g_gameTools.LoadCocosUI("task_index.csb",5)
    self:addChild(uiLayer)
    g_resourcesInterface.installResources(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent()
          end
    end)
    
    baseNode:getChildByName("Text_1"):setString(g_tr("taskTitle"))
    baseNode:getChildByName("Text_2"):setString(g_tr("taskMainTitle"))
    baseNode:getChildByName("Text_2_0"):setString(g_tr("taskDailyTitle"))
    
    --g_TaskMode.reqBaseData()
    
    local leftListView = self._baseNode:getChildByName("ListView_left")
    self._leftListView = leftListView
    
    local itemModel = cc.CSLoader:createNode("task_left_menu.csb")
    itemModel:setContentSize(itemModel:getChildByName("pic_select"):getContentSize())
    leftListView:setItemModel(itemModel)
    
    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("touched:",sender:getCurSelectedIndex())
            self:changePage(sender:getCurSelectedIndex() + 1)
        end
    end
    leftListView:addEventListener(listViewEvent)
    
    self._changePageIdx = 0
    
    self:buildLeftList()
    
    local detailPage = require("game.uilayer.task.TaskDetailComponent"):create()
    self._baseNode:getChildByName("ListView_1"):pushBackCustomItem(detailPage)
    detailPage:setDelegate(self)
    self._detailPage = detailPage
    
    --self:changePage(1,true)
    self:goToMainTask()
end

function TaskMainLayer:goToMainTask()
    local mainTaskData = g_TaskMode.getGuideMainTask()
    itemSelect(self._mainLeftItem,true)
    self._changePageIdx = 0
    if self._lastLeftItem then
      itemSelect(self._lastLeftItem,false)
    end
    
    if mainTaskData then
        self._detailPage:setData(mainTaskData)
    else
        self:changePage(1,true)
    end
end

function TaskMainLayer:buildLeftList()
    --main task
    local mainTaskData = g_TaskMode.getGuideMainTask()
    self._baseNode:getChildByName("Panel_1"):removeAllChildren()
    local itemModel = cc.CSLoader:createNode("task_left_menu.csb")
    self._mainLeftItem = itemModel
    itemModel.data = mainTaskData
    self:updateItem(itemModel)
    itemModel:getChildByName("pic_select"):addClickEventListener(function()
       g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
       if mainTaskData == nil then
          g_airBox.show(g_tr("taskAllMainTaskFinish"))
          return
       end
       self:goToMainTask()
    end)
    
    itemModel:getChildByName("pic_selected"):addClickEventListener(function()
       g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
       if mainTaskData == nil then
          g_airBox.show(g_tr("taskAllMainTaskFinish"))
          return
       end
       self:goToMainTask()
    end)
        
    if mainTaskData == nil then
        itemModel:getChildByName("Image_1"):setVisible(false)
        itemModel:getChildByName("text"):setString(g_tr("taskAllMainTaskFinishTitle"))
    end
    
    self._baseNode:getChildByName("Panel_1"):addChild(itemModel)
    
    --daily tasks
    self._leftListView:removeAllChildren()
    
    local tasks = g_TaskMode.getAllDailyTasks()
    self._tasks = tasks
    for i = 1, #tasks do
       self._leftListView:pushBackDefaultItem()
    end
    
    self._lastLeftItem = self._leftListView:getItem(self._changePageIdx - 1)
    
    local finishedCnt = 0
    local items = self._leftListView:getItems()
    for i =1, #items do
      local item = self._leftListView:getItem(i - 1)
      if item then
          local task = tasks[i]
          item.data = task
          self:updateItem(item)
          if task:getServerData().status == g_TaskMode.TaskStatusType.FINISH then
              finishedCnt = finishedCnt + 1
          end
      end
    end
    
    local cntStr = finishedCnt.."/"..#items
    self._baseNode:getChildByName("text_r1"):setString(g_tr("taskDailyCnt",{cnt = cntStr}))
end

function TaskMainLayer:changePage(idx,forceFefresh)
    if self._changePageIdx == idx and not forceFefresh then
        return 
    end
    self._changePageIdx = idx
    
    local currentTask = self._tasks[idx]
    if self._changePageIdx == 0 then
        currentTask = g_TaskMode.getGuideMainTask()
    end
    
    if currentTask then
      if self._lastLeftItem then
          itemSelect(self._lastLeftItem,false)
      end
      if self._mainLeftItem then
          itemSelect(self._mainLeftItem,false)
      end
      
      if self._changePageIdx ~= 0 then
          self._lastLeftItem = self._leftListView:getItem(idx - 1)
          itemSelect(self._lastLeftItem,true)
      end
      
      self._detailPage:setData(currentTask)
    end
end

function TaskMainLayer:updateView()
    self:buildLeftList()
    self:changePage(self._changePageIdx,true)
end

function TaskMainLayer:updateItem(item)
    if item == nil then
        return
    end
    
    local task = item.data
    if task == nil then
        return
    end
    
    local taskName = g_tr(task:getConfig().mission_name)
    item:getChildByName("text"):setString(taskName)
    itemSelect(item,false)
    item:getChildByName("Image_2"):setVisible(task:getServerData().status == g_TaskMode.TaskStatusType.FINISH)
    item:getChildByName("Image_1"):setVisible(task:getServerData().status == g_TaskMode.TaskStatusType.COMPLETE)
    
end


return TaskMainLayer