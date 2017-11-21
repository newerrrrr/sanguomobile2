
--联盟任务活动

local ActivityAllianceMission = class("ActivityAllianceMission", require("game.uilayer.base.BaseLayer"))
local MissionMode = require("game.uilayer.activity.allianceMission.AllianceMissionMode") 

local missionTypeEnum = MissionMode:getMissionTypeEnum()
local missionStateEnum = MissionMode:getMissionStateEnum()

function ActivityAllianceMission:ctor(delegate, missionType) 
  self.delegate = delegate 
  self.entryType = missionType 
  ActivityAllianceMission.super.ctor(self) 

  if g_AllianceMode.getSelfHaveAlliance() and MissionMode:isYellowTurbansValid() then 
    require("game.uilayer.activity.huangjinqiyi.huangjinNpcData").RequestDataAsync() 
  end 
end

function ActivityAllianceMission:onEnter()
  print("ActivityAllianceMission:onEnter")
  self:initUI()
  self:showValidMission()
end 

function ActivityAllianceMission:onExit() 
  print("ActivityAllianceMission:onExit") 
end 

function ActivityAllianceMission:initUI() 
  local layer = cc.CSLoader:createNode("AllianceMission_main1.csb") 
  if layer then 
    self.root = layer 
    self:addChild(layer) 

    --tab菜单及其对应的任务类型
    local tabTreasure = layer:getChildByName("Button_1") 
    local tabDevote = layer:getChildByName("Button_2")
    local tabJuDian = layer:getChildByName("Button_3") 
    local tabHuangJin = layer:getChildByName("Button_4")          
    self.tabBtnInfo = {{type = missionTypeEnum.alliance_devote, btn = tabDevote}, 
                       {type = missionTypeEnum.yellow_turbans, btn = tabHuangJin},
                       {type = missionTypeEnum.judian_fight, btn = tabJuDian},
                       {type = missionTypeEnum.treasure_fight, btn = tabTreasure}
                      }
    for k, v in pairs(self.tabBtnInfo) do 
      v.btn:setTag(200 + v.type) 
      v.btn:setEnabled(true)
      self:regBtnCallback(v.btn, handler(self, self.onTabMenu)) 
    end 
    layer:getChildByName("Text_pm"):setString(g_tr("allianceRank"))
    layer:getChildByName("Text_pm_0"):setString(g_tr("allianceMine"))
    layer:getChildByName("Text_29"):setString(g_tr("allianceRank"))
    layer:getChildByName("Text_32"):setString(g_tr("actLeftTime"))    
    layer:getChildByName("Text_33"):setString(g_tr("alliancePoint"))

    --详情/宝箱按钮注册(只注册一次)
    for i = 1, 3 do 
      layer:getChildByName("Panel_"..i):getChildByName("Text_1"):setString(""..i)

      local btnDetail = layer:getChildByName("Panel_"..i):getChildByName("Button_5")
      btnDetail:getChildByName("Text_4"):setString(g_tr("allianceRankDetail"))
      btnDetail:setTag(i)
      self:regBtnCallback(btnDetail, handler(self, self.onDetail))

      local btnBox = layer:getChildByName("Image_baoxiang"..i)
      btnBox:setTag(300 + i)
      self:regBtnCallback(btnBox, handler(self, self.onBox))
    end 

    --按钮: 捐献/收集/占领/迎战
    for i = 1, 5 do 
      self:regBtnCallback(layer:getChildByName("Button_1"..i-1), handler(self, self.onDoMission))
    end 

    local btnHelp = layer:getChildByName("Button_20")
    self:regBtnCallback(btnHelp, handler(self, self.onHelp))
  end 
end 

--显示当前开启的任务
function ActivityAllianceMission:showValidMission()
  if self.entryType then --第一次指定显示某个界面
    self.curType = self.entryType 
    self.curData = MissionMode:getMissionData(self.curType)
    self.entryType = nil 
  else 
    self.curType, self.curData = MissionMode:getValidMission(true)
  end 
  print("showValidMission", self.curType)

  self:updateMissionInfo(self.curType, self.curData) 
end 

function ActivityAllianceMission:updateMissionInfo(_type, dataItem)
  if nil == self.root then return end 

  --高亮tab菜单,高亮项100%大小,其他80%
  local pos_x = self.tabBtnInfo[1].btn:getPositionX()
  for k, v in pairs(self.tabBtnInfo) do 
    v.btn:setBright(v.type == _type) 
    v.btn:setScale(v.btn:isBright() and 1.0 or 0.8)
    v.btn:setPositionX(pos_x)
    pos_x = pos_x + v.btn:getContentSize().width * v.btn:getScale()
  end 

  local state = MissionMode:getMissionState(dataItem)
  if state == missionStateEnum.opening then 
    MissionMode:saveValidCacheType(_type)
  end 


  --按钮: 捐献/收集/占领/迎战
  local btnDevote = self.root:getChildByName("Button_10")
  local btnCollect = self.root:getChildByName("Button_11")
  local btnJuDian = self.root:getChildByName("Button_12")
  local btnHuangJin = self.root:getChildByName("Button_13")
  local btnReport = self.root:getChildByName("Button_14") 
  btnDevote:setVisible(state == missionStateEnum.opening and _type == missionTypeEnum.alliance_devote)
  btnCollect:setVisible(state == missionStateEnum.opening and _type == missionTypeEnum.treasure_fight)

  btnJuDian:setVisible(false)
  btnHuangJin:setVisible(false)
  btnReport:setVisible(false)

  local yellow_status = 0 --status：0.未开始，1.进行中，2.完成 

  if _type == missionTypeEnum.judian_fight then 
    btnJuDian:setVisible(state == missionStateEnum.opening)
    btnReport:setVisible(state ~= missionStateEnum.opening)

  elseif _type == missionTypeEnum.yellow_turbans then 
    --活动可进行时,显示迎战,其他显示战报 
    if g_AllianceMode.getSelfHaveAlliance() and MissionMode:isYellowTurbansValid() then 
      local npcData = require("game.uilayer.activity.huangjinqiyi.huangjinNpcData").GetData()
      if npcData and npcData.guildHuangjin then 
        yellow_status = npcData.guildHuangjin.status
      end 
      if state == missionStateEnum.opening and yellow_status ~= 2 then 
        btnHuangJin:setVisible(true)
      else 
        btnReport:setVisible(true)
      end  
    else 
      btnReport:setVisible(true) 
    end 
  end 


  self.pointDrop = MissionMode:getMissionPointDrop(_type) 
  self.rankDrop = MissionMode:getMissionRankDrop(_type) 

  --联盟排名信息(全部为空时特殊处理)
  local allEmpty = false 
  if nil == dataItem or nil == dataItem.rank[1] then
    allEmpty = true 
  end 

  for i = 1, 3 do 
    --玩家信息
    local node = self.root:getChildByName("Panel_"..i)
    if (dataItem and dataItem.rank[i]) or allEmpty then 
      node:setVisible(true)
      if allEmpty then 
        node:getChildByName("Text_2"):setString("--")
        node:getChildByName("Text_3"):setString("--")
      else 
        node:getChildByName("Text_2"):setString(dataItem.rank[i].name)
        node:getChildByName("Text_3"):setString(""..dataItem.rank[i].score)
      end 
      --奖品信息
      local item = self.rankDrop[i]
      if item and g_data.drop[item.drop] then 
        local dropData = g_data.drop[item.drop].drop_data 
        for j = 1, 2 do 
          local val = dropData[j]
          if val then 
            local tmp = require("game.uilayer.common.DropItemView"):create(val[1], val[2], val[3])
            local pic = self.root:getChildByName("Panel_"..i):getChildByName("Image_"..(4+j))           
            pic:loadTexture(tmp:getIconPath())
          end 
        end 
      end 
    else 
      node:setVisible(false)
    end 
  end 

  --我的排名信息
  local lbRank = self.root:getChildByName("Text_30")
  local lbScore = self.root:getChildByName("Text_34")
  local lbPreTime = self.root:getChildByName("Text_32")
  local lbTime = self.root:getChildByName("Text_32_0")
  local lbCloseTips = self.root:getChildByName("Text_32_1") 

  lbPreTime:setString("") 
  lbRank:setString("--") 
  lbScore:setString("--") 
  lbTime:setString("") 
  lbCloseTips:setString("") 

  --活动时间信息
  if self.timer then 
    self:unschedule(self.timer)
    self.timer = nil 
  end       
  if dataItem then 
    if state == missionStateEnum.opening then 
      if _type == missionTypeEnum.yellow_turbans then 
        if yellow_status == 1 then --黄巾进行中
          lbPreTime:setString(g_tr("huangjinIsFighting"))
        elseif yellow_status == 2 then --黄巾结束
          lbPreTime:setString(g_tr("actIsClosed"))
          lbCloseTips:setString(g_tr("actIsClosedTips"))
        else 
          lbPreTime:setString(g_tr("activityWillOpenAt8"))
        end 
      else 
        lbPreTime:setString(g_tr("actLeftTime")) 
        self:showLeftTime(lbTime, dataItem.activityEndTime)
      end 

    elseif state == missionStateEnum.waitToOpen then 
      lbPreTime:setString(g_tr("actOpenTime")) 
      self:showLeftTime(lbTime, dataItem.activityStartTime)

    else 
      lbPreTime:setString(g_tr("actIsClosed")) 
      lbCloseTips:setString(g_tr("actIsClosedTips"))
      self:showLeftTime(lbTime, dataItem.activityEndTime)
    end 

    if g_AllianceMode.getSelfHaveAlliance() then --是否已加入公会
      lbRank:setString("" .. dataItem.myRank) 
      lbScore:setString("" .. dataItem.myScore) 
    end 
  else 
    lbPreTime:setString(g_tr("actIsClosed")) 
    lbCloseTips:setString(g_tr("actIsClosedTips")) 
  end 

  lbTime:setPositionX(lbPreTime:getPositionX()+lbPreTime:getContentSize().width) 


  --宝箱积分
  local loadingBar = self.root:getChildByName("LoadingBar_1")
  loadingBar:setPercent(0)
  for i = 1, 3 do 
    local item = self.pointDrop[i]
    local lbPoint = self.root:getChildByName("Image_baoxiang"..i):getChildByName("Text_25")
    if item then 
      lbPoint:setString("" .. item.min_point)
      if dataItem and i == 3 then 
        loadingBar:setPercent(math.min(100, 100*dataItem.myScore/item.min_point))
      end 
    else 
      lbPoint:setString("") 
    end 
  end 
end 

function ActivityAllianceMission:showLeftTime(label, targetTime)
  local function updateTime()
    local dt = targetTime - g_clock.getCurServerTime()
    if dt <= 0 then      
      dt = 0 
      self:unschedule(self.timer)
      self.timer = nil 

      self:showValidMission()
    end 
    label:setString(g_gameTools.convertSecondToString(dt))
  end 

  if self.timer then 
    self:unschedule(self.timer)
    self.timer = nil 
  end 

  label:setString("")
  local leftTime = targetTime - g_clock.getCurServerTime() 
  if leftTime > 0 then 
    label:setString(g_gameTools.convertSecondToString(leftTime)) 
    self.timer = self:schedule(updateTime, 1.0) 
  end
end 

function ActivityAllianceMission:showDropItems(dropId, rank)
  if nil == dropId then return end 

  local dropItem = g_data.drop[dropId]
  if nil == dropItem then return end 
  --掉落箱子里指向另一个掉落包
  local dropBox = dropItem.drop_data[1]
  local item = g_data.item[dropBox[2]]
  if nil == item then return end 
  dropItem = g_data.drop[item.drop[1]]
  if nil == dropItem then return end 

  local layer = g_gameTools.LoadCocosUI("turntable_resources_main.csb",5)
  g_sceneManager.addNodeForUI(layer)

  local mask = layer:getChildByName("mask")
  mask:setTouchEnabled(true)
  self:regBtnCallback(mask, function() layer:removeFromParent() end) 
  local root = layer:getChildByName("scale_node")
  root:getChildByName("Text_c2"):setString(g_tr("alliancePointAward"))
  root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
  local listView = root:getChildByName("ListView_1")
  local listItem = cc.CSLoader:createNode("activity_integral_list1.csb") 
  listView:removeAllChildren() 


  local function getListItem(_type, configId, num)
    local itemData = require("game.uilayer.common.DropItemView"):create(_type, configId, num)
    if itemData then 
      local itemNew = listItem:clone()
      itemData:setCountEnabled(false)
      itemNew:getChildByName("Image_4"):addChild(itemData)
      local size = itemNew:getChildByName("Image_4"):getContentSize()
      itemData:setPosition(cc.p(size.width*0.5,size.height*0.5))
      local scale = size.width/itemData:getContentSize().width
      itemData:setScale(scale)
    
      itemNew:getChildByName("Text_2"):setString(itemData:getName())
      itemNew:getChildByName("Text_5_0"):setString(string.formatnumberthousands(num))

      return itemNew 
    end 
  end 

  --盟主发放奖励
  if rank then 
    local listTitle_1 = cc.CSLoader:createNode("activity_integral_list2.csb") 
    listTitle_1:getChildByName("Text_2"):setString(g_tr("allianceLeaderAwards"))
    listView:pushBackCustomItem(listTitle_1)
    for k, v in pairs(g_data.alliance_match_chest_drop) do 
      if rank == v.rank then 
        local itemNew = getListItem(g_Consts.DropType.Props, v.item_id, v.max_count)
        if itemNew then 
          listView:pushBackCustomItem(itemNew) 
        end 
      end 
    end 
  end 

  --普通掉落奖励
  local listTitle_2 = cc.CSLoader:createNode("activity_integral_list2.csb") 
  listTitle_2:getChildByName("Text_2"):setString(g_tr("allianceMenberAwards"))
  listView:pushBackCustomItem(listTitle_2) 
  for k, v in pairs(dropItem.drop_data) do 
    local itemNew = getListItem(v[1], v[2], v[3])
    if itemNew then 
      listView:pushBackCustomItem(itemNew) 
    end 
  end 
end 

function ActivityAllianceMission:onTabMenu(sender)
  local _type = sender:getTag() - 200 
  print("onTabMenu:", _type)

  self.curType = _type 
  self.curData = MissionMode:getMissionData(_type)

  self:updateMissionInfo(self.curType, self.curData)
end 

function ActivityAllianceMission:onDetail(sender)
  local idx = sender:getTag() 
  print("onDetail:", idx) 

  local item = self.rankDrop[idx]
  if nil == item then return end 

  self:showDropItems(item.drop, idx)
end 

function ActivityAllianceMission:onBox(sender)
  local idx = sender:getTag() - 300 
  print("onBox:", idx)

  local item = self.pointDrop[idx]
  if nil == item then return end 

  self:showDropItems(item.drop)
end 

function ActivityAllianceMission:onDoMission()
  print("onDoMission")

  if not g_AllianceMode.getSelfHaveAlliance() then
    g_airBox.show(g_tr("battleHallNoAlliance"))
    return
  end 

  local function updateCallback() 
    print("update to newest info...") 
    local data = MissionMode:getMissionData(self.curType) 
    if data then 
      self.curData = data 
      self:updateMissionInfo(self.curType, self.curData) 
    end 
  end 

  local btnJuDian = self.root:getChildByName("Button_12")
  local btnHuangJin = self.root:getChildByName("Button_13")
  local btnReport = self.root:getChildByName("Button_14") 

  if self.curType == missionTypeEnum.alliance_devote then --联盟捐献
    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.tech.AllianceTechMainLayer"):create(updateCallback))

  elseif self.curType == missionTypeEnum.treasure_fight then --和氏璧
    require("game.uilayer.activity.activityJade.ActivityJadeMainLayer").gotoWorldToFindHSB()
    if self.delegate then 
      self.delegate:close()
    end 

  elseif self.curType == missionTypeEnum.judian_fight then --据点战 
    if btnJuDian:isVisible() then 
      local strongholdFindLayer = require("game.uilayer.activity.strongholdBattle.strongholdFindView"):create()
      g_sceneManager.addNodeForUI(strongholdFindLayer)
      if self.delegate then 
        self.delegate:close()
      end       
    elseif btnReport:isVisible() then 
      local function callback(result,data) 
        if result == true then 
          g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleRecordView").new(data))
        end
      end
      g_sgHttp.postData("Army/getBattleLog", {type = 9}, callback)
    end 

  elseif self.curType == missionTypeEnum.yellow_turbans then --黄巾起义
    if btnHuangJin:isVisible() then 
      --如果无联盟堡垒, 提示用户
      local npcData = require("game.uilayer.activity.huangjinqiyi.huangjinNpcData").GetData()
      if npcData and not npcData.hasBase then  
        g_airBox.show(g_tr("activityNoAllianceBase"))
        return 
      end 

      require("game.uilayer.activity.huangjinqiyi.ActivityHuangJinQiYi").show() --迎战
      if self.delegate then 
        self.delegate:close()
      end 

    elseif btnReport:isVisible() then 
      local function callback(result,data)
        if result == true then 
          g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleRecordView").new(data))
        end 
      end 
      g_sgHttp.postData("Army/getBattleLog", {type = 10}, callback) 
    end      
  end  
end 

function ActivityAllianceMission:onHelp()
  local helpId 
  if self.curType == missionTypeEnum.alliance_devote then 
    helpId = 2
  elseif self.curType == missionTypeEnum.treasure_fight then
    helpId = 1
  elseif self.curType == missionTypeEnum.judian_fight then
    helpId = 14 
  elseif self.curType == missionTypeEnum.yellow_turbans then 
    helpId = 15
  end 

  if helpId then 
    require("game.uilayer.common.HelpInfoBox"):show(helpId) 
  end 
end 

return ActivityAllianceMission 
