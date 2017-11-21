
--每周城战任务
local TaskWeekBattle = class("TaskWeekBattle",require("game.uilayer.base.BaseLayer"))

local viewObj


function TaskWeekBattle:ctor()
  TaskWeekBattle.super.ctor(self)

  viewObj = self
  
  local layer = g_gameTools.LoadCocosUI("task_index_new1.csb", 5) 
  if layer then 
    self:addChild(layer) 
    self:initBinging(layer)

    self:onReqData()
  end 
end 

function TaskWeekBattle:onEnter()
  print("TaskWeekBattle:onEnter")
end 

function TaskWeekBattle:onExit() 
  print("TaskWeekBattle:onExit") 
  viewObj = nil 
end 


function TaskWeekBattle:initBinging(layer)

  self.scale_node = layer:getChildByName("scale_node")
  self.scale_node:getChildByName("Text_1"):setString(g_tr("weekBattleTaskTitle2"))
  self.scale_node:getChildByName("Text_title"):setString(g_tr("weekBattleTaskTitle"))

  local btnBack = self.scale_node:getChildByName("btn_back") 
  local btnHelp = self.scale_node:getChildByName("Button_wenh1") 

  local nodePic = self.scale_node:getChildByName("Panel_renw"):getChildByName("Image_16") 
  nodePic:loadTexture(g_data.sprite[1031092].path) 

  local Panel_5 = self.scale_node:getChildByName("Panel_5")
  Panel_5:getChildByName("Text_ms1"):setString(g_tr("weekBattleTaskDesc"))
  Panel_5:getChildByName("Text_rw1"):setString(g_tr("weekBattleTaskProgress"))
  Panel_5:getChildByName("Text_award"):setString(g_tr("taskAward"))

  local btnGoto = Panel_5:getChildByName("btn_goto") 
  btnGoto:getChildByName("Text_2"):setString(g_tr("weekBattleTaskGoto")) 
  self:regBtnCallback(btnGoto, handler(self, self.onGoto))
  self:regBtnCallback(btnHelp, handler(self, self.onHelp))
  self:regBtnCallback(btnBack, handler(self, self.close))

  btnGoto:setVisible(false) --暂时隐藏掉
  btnGoto:setEnabled(false)

  local lbTaskDesc = Panel_5:getChildByName("Text_desc")
  local lbProgress = Panel_5:getChildByName("Text_rw2")

  lbTaskDesc:setString("")
  lbProgress:setString("")

  local listView = self.scale_node:getChildByName("Panel_5"):getChildByName("ListView_1")
  listView:removeAllChildren()
end 


function TaskWeekBattle:updateUI(serverData)

  if nil == viewObj then return end 

  if nil == self.scale_node or nil == serverData then return end 

  local Panel_5 = self.scale_node:getChildByName("Panel_5")
  local btnGoto = Panel_5:getChildByName("btn_goto") 
  local lbTaskDesc = Panel_5:getChildByName("Text_desc")
  local lbProgress = Panel_5:getChildByName("Text_rw2")

  local dropId 
  local isValid = false  
  local taskItem = g_data.alliance_quest[serverData.missionId] 
  if taskItem then
    dropId = taskItem.alliance_quest_reward 
    lbTaskDesc:setString(g_tr(taskItem.name, {num = taskItem.num_value})) 
    if taskItem.alliance_quest_type == 3 then 
      local str = ""
      if serverData.missionStatus == 1 then --未完成
        str = g_tr("weekBattleTaskUnfinish")
        isValid = true 
      elseif serverData.missionStatus == 2 then --已完成
        str = g_tr("weekBattleTaskFinish")
      elseif serverData.missionStatus == 3 then --换了阵营后本周任务不可做,下周重新开始
        str = g_tr("weekBattleTaskCampChanged")
      end 
      lbProgress:setString(str)
    else 
      lbProgress:setString(string.format("%d/%d", serverData.count, taskItem.num_value)) 
      isValid = true 
    end 
  else 
    lbTaskDesc:setString("")
    lbProgress:setString("")
  end 

  btnGoto:setEnabled(isValid)

  self:showAwardList(dropId) 
end 

function TaskWeekBattle:showAwardList(dropId)
  if nil == self.scale_node or nil == dropId then 
    return 
  end 

  local listView = self.scale_node:getChildByName("Panel_5"):getChildByName("ListView_1")
  listView:removeAllChildren()

  listView:setItemsMargin(8)
  listView:setScrollBarEnabled(false)

  if nil == g_data.drop[dropId] then return end 
  
  local dropdata = g_data.drop[dropId].drop_data 
  for k, v in pairs(dropdata) do 
    local icon = require("game.uilayer.common.DropItemView").new(v[1], v[2], v[3])
    if icon then 
      icon:enableTip()
      listView:pushBackCustomItem(icon)
    end 
  end 
end 

function TaskWeekBattle:onReqData()
  local function onRecv(result, data)
    g_busyTip.hide_1()
    if result then 
      dump(data, "=====data")
      self:updateUI(data.guildMission)
    end 
  end 
  g_busyTip.show_1()
  g_sgHttp.postData("Guild_Mission/showGuildMission", {}, onRecv, true) 
end 

function TaskWeekBattle:onHelp()
  require("game.uilayer.common.HelpInfoBox"):show(55)
end 

function TaskWeekBattle:onGoto()
  print("onGoto") 
end 

return TaskWeekBattle 
