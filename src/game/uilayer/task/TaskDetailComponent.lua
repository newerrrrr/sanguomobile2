local TaskDetailComponent = class("TaskDetailComponent",function()
    return ccui.Widget:create()
end)

local orginalDescY = 0
local orginalBtnAwardX = 0
function TaskDetailComponent:ctor()
    local uiLayer = cc.CSLoader:createNode("task_right_content.csb")
    self:addChild(uiLayer)
    self._uiLayer = uiLayer
    uiLayer:setPositionY(-uiLayer:getContentSize().height)
    self._listView = uiLayer:getChildByName("ListView_1")
    self._listView:setItemsMargin(20)
    local costNum = 0
    local costType = 0
    local costId = 110
    for key, var in pairs(g_data.cost) do
      if costId == var.cost_id then
         costNum = var.cost_num
         costType = var.cost_type
         break
      end
    end
    assert(costType > 0)
    uiLayer:getChildByName("btn_refresh"):getChildByName("Panel_1"):getChildByName("Text_1"):setString(string.formatnumberthousands(costNum))--price
    uiLayer:getChildByName("btn_refresh"):getChildByName("Panel_1"):getChildByName("Image_3"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
    
    --orginalDescY = self._uiLayer:getChildByName("Panel_2"):getPositionY()
    orginalBtnAwardX = self._uiLayer:getChildByName("btn_donate"):getPositionX()
    
    local getAwardHandler = function()
        g_musicManager.playEffect(g_data.sounds[5000036].sounds_path)
        if g_TaskMode.getAward(self:getData()) then
            self:getDelegate():updateView()
        end
    end
    self._uiLayer:getChildByName("btn_donate"):addClickEventListener(getAwardHandler)
    
    local refreshHandler = function()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local doHandler = function()
            local function onRecv(result, msgData)
              if result == true then
                  self:getDelegate():updateView()
              end
            end
            g_sgHttp.postData("mission/refreshDailyMission",{current_id = self:getData():getServerData().id},onRecv)
        end
        g_msgBox.showConsume(costNum, g_tr("taskRefreshTip"), nil, g_tr("taskRefresh"), doHandler)
       
    end
    
    self._uiLayer:getChildByName("btn_refresh"):addClickEventListener(refreshHandler)
    
    local goToHandler = function()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local taskData = self:getData()
        g_TaskMode.guideToMainTask(taskData)
        self:getDelegate():removeFromParent()
    end
    
    self._uiLayer:getChildByName("Panel_2"):getChildByName("btn_go"):addClickEventListener(goToHandler)
    
end

------
--  Getter & Setter for
--      TaskDetailComponent._Data
-----
function TaskDetailComponent:setData(Data)
    self._Data = Data
    self:updateView()
end

function TaskDetailComponent:getData()
    return self._Data
end

------
--  Getter & Setter for
--      TaskDetailComponent._Delegate
-----
function TaskDetailComponent:setDelegate(Delegate)
    self._Delegate = Delegate
end

function TaskDetailComponent:getDelegate()
    return self._Delegate
end

function TaskDetailComponent:updateView()
    self._listView:removeAllChildren()
    for i = 1, 5 do
    	self._uiLayer:getChildByName("Image_stars"..i):setVisible(false)
    end
    
    
    local taskData = self:getData()

    self._uiLayer:getChildByName("Text_title"):setString(g_tr("taskProgress"))
    self._uiLayer:getChildByName("Text_title_0"):setString(g_tr(taskData:getConfig().mission_objectives))
    
    self._uiLayer:getChildByName("Text_1"):setString(g_tr("taskLevel"))
    
    
    self._uiLayer:getChildByName("Panel_2"):getChildByName("Text_des_0"):setString(g_tr("taskDesc"))
    self._uiLayer:getChildByName("Panel_2"):getChildByName("Text_des"):setString(g_tr(taskData:getConfig().description))
    self._uiLayer:getChildByName("Text_rewards"):setString(g_tr("taskAward"))

    self._uiLayer:getChildByName("Text_1"):setVisible(taskData:getConfig().star_level > 0)
    
    for i = 1, taskData:getConfig().star_level do
        self._uiLayer:getChildByName("Image_stars"..i):setVisible(true)
    end
    
    local dropIdArray = taskData:getConfig().drop
    local dropGroup = g_gameTools.getDropGroupByDropIdArray(dropIdArray)
    --货币奖励显示
    for i = 1, 5 do
        self._uiLayer:getChildByName("resource_"..i):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + i))
        self._uiLayer:getChildByName("num_"..i):setString("+ 0")
        for key, var in pairs(dropGroup) do
            local type = var[1]
            local id = var[2]
            local count = var[3]
            if type == g_Consts.DropType.Resource then
               local itemInfo = g_data.item[id]
               if itemInfo.item_original_id == (100 + i) then
                  self._uiLayer:getChildByName("num_"..i):setString("+ "..string.formatnumberlogogram(count))
               end
            end
        end
    end
    
    local itemAwards = {}
    for key, var in pairs(dropGroup) do
        local type = var[1]
        local id = var[2]
        local count = var[3]
        if (type == g_Consts.DropType.Resource) and (id == 10100 or
        id == 10200 or 
        id == 10300 or
        id == 10400 or
        id == 10500)
        then
            
        else
             table.insert(itemAwards,var)
        end
    end
    
    --道具奖励显示
    local updateItemView = function(itemView,itemId)
        local itemInfo = g_data.item[itemId]
        if itemInfo then
            itemView:getChildByName("pic_rewards_1"):loadTexture(g_resManager.getResPath(itemInfo.res_icon))
            itemView:getChildByName("name_rewards_1"):setString(g_tr(itemInfo.item_name))
        end
    end
    self._listView:setTouchEnabled(#itemAwards > 3)
    if #itemAwards > 0 then
        for key, var in pairs(itemAwards) do
            local type = var[1]
            local id = var[2]
            local count = var[3]
            local item = require("game.uilayer.common.DropItemView"):create(type,id,count)
            --item:setNameVisible(true)
            g_itemTips.tip(item,type,id)
            
            --item:setPosition(item:getContentSize().width/2,-item:getContentSize().height/2)
            self._listView:pushBackCustomItem(item)
        end
    end
    
    --显示进度
    local currentNum = taskData:getServerData().current_mission_number
    local maxNum = taskData:getServerData().max_mission_number
    if maxNum > 0 then
      local progressLabel = self._uiLayer:getChildByName("Text_title_0")
      if currentNum < maxNum then
          progressLabel:setTextColor(g_Consts.ColorType.Red)
      else
          progressLabel:setTextColor(g_Consts.ColorType.Green)
      end
      progressLabel:setString(currentNum.."/"..maxNum)
      self._uiLayer:getChildByName("Text_title"):setVisible(true)
    else
      self._uiLayer:getChildByName("Text_title"):setVisible(false)
      self._uiLayer:getChildByName("Text_title_0"):setString("")
    end
    
    local finished = taskData:getServerData().status == g_TaskMode.TaskStatusType.FINISH
    self._uiLayer:getChildByName("btn_donate"):setEnabled(taskData:getServerData().status == g_TaskMode.TaskStatusType.COMPLETE)
    if finished then
        self._uiLayer:getChildByName("btn_donate"):getChildByName("Text"):setString(g_tr("taskGetAwarded"))
    else
        self._uiLayer:getChildByName("btn_donate"):getChildByName("Text"):setString(g_tr("taskGetAward"))
    end
    
    local isMainTask = g_TaskMode.isMainTaskType(taskData:getServerData().mission_type)

    --self._uiLayer:getChildByName("Panel_2"):setVisible(isMainTask)
    self._uiLayer:getChildByName("btn_refresh"):setVisible(not isMainTask)
    
    self._uiLayer:getChildByName("btn_donate"):setVisible(true)
    --self._uiLayer:getChildByName("Panel_2"):setPositionY(orginalDescY)
    self._uiLayer:getChildByName("btn_donate"):setPositionX(orginalBtnAwardX)
    if isMainTask then
        --self._uiLayer:getChildByName("Panel_2"):setPositionY(orginalDescY + 65)
        self._uiLayer:getChildByName("btn_donate"):setPositionX(self._uiLayer:getChildByName("Panel_2"):getChildByName("btn_go"):getPositionX())
        self._uiLayer:getChildByName("btn_donate"):setVisible(taskData:getServerData().status ~= g_TaskMode.TaskStatusType.START)
    else
        local currentTime = g_clock.getCurServerTime()
        local currentDate = os.date("*t", currentTime)
        local timeStr = string.format("%d-%02d-%02d",currentDate.year,currentDate.month,currentDate.day)
        if finished or taskData:getServerData().date_limit ~= timeStr then
            self._uiLayer:getChildByName("btn_donate"):setPositionX(self._uiLayer:getChildByName("Panel_2"):getChildByName("btn_go"):getPositionX())
            self._uiLayer:getChildByName("btn_refresh"):setVisible(false)
        end
    end
    
    self._uiLayer:getChildByName("Panel_2"):getChildByName("btn_go"):setVisible(isMainTask)
    
    local build_id = taskData:getConfig().mission_number
    local needShowButton = true
    if g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(build_id) > 0 then --存在>=该建筑等级的建筑
        needShowButton = false
    end
    self._uiLayer:getChildByName("Panel_2"):getChildByName("btn_go"):setVisible(needShowButton and isMainTask and taskData:getServerData().status == g_TaskMode.TaskStatusType.START)
    
end

return TaskDetailComponent