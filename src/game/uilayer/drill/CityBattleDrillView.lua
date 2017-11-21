local CityBattleDrillView = class("CityBattleDrillView", require("game.uilayer.base.BaseLayer"))

--默认显示--
local defaultShow = "-"

--文字显示的顺序--
local property = {g_tr("attack"), g_tr("defend"),g_tr("life"),g_tr("atkRange"), g_tr("speed"), g_tr("carry")}

function CityBattleDrillView:onEnter()
	g_groundData.SetView(self)
end

function CityBattleDrillView:onExit()
	g_groundData.SetView(nil)
end

function CityBattleDrillView:ctor(callback, curTab)

    CityBattleDrillView.super.ctor(self)

    self.callback = callback

     --当前的tab页--
    self.curTab = curTab or 1

    if self.curTab == 0 then
        self.curTab = 1
    end


	self.num = 2

	self.allTab = 2

    self.mode = require("game.uilayer.drill.DrillMode").new()

    --UI列表--
    self.uiList = {}

    self.maxArmyNum = 6

    --初始化UI
    self:initUi()

    --添加事件
    self:addEvent()

    self:initFun()

    g_groundData.RequestSycCityBattleData()
    
    self.generalData = g_cityBattleGeneral.GetData()
    self.armyData = g_cityBattleArmy.GetData()
    self.armyUnitData = g_cityBattleArmyUnit.GetData()
    self.soldierData = g_cityBattleSoldier.GetData()
    
    
    self.Text_y1:setString(g_tr("city_battle_full_soldier_cd"))
    local timeLabel = self.Text_y2
    self._fill_soldier_time = 0
		
		local playerData = g_cityBattlePlayerData.GetData()
		local cdSecondsReduce = playerData.buff.country_battle_soldier_revive_time_reduce or 0
    do
    	local updateCd = function()
    		local cdTime = tonumber(g_data.country_basic_setting[53].data) - tonumber(cdSecondsReduce)
    		
    		local currentTime = g_clock.getCurServerTime()
    	  local groupData, armyData = self:getGroupDataByTab(self.curTab)
		    if armyData then
		        self._fill_soldier_time = armyData.fill_soldier_time
		    end
    
    		local finishTime = self._fill_soldier_time + cdTime
				local endTime = finishTime
				local secondsLeft = endTime - currentTime

				local updateTimeStr = function()
					currentTime = g_clock.getCurServerTime()
					secondsLeft = endTime - currentTime
					if secondsLeft < 0 then
						secondsLeft = 0
						timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft,g_gameTools.ClockType.MINSSCONDS))
					else
						timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft,g_gameTools.ClockType.MINSSCONDS))
					end
				end
				updateTimeStr()
			  
--			  if finishTime - g_clock.getCurServerTime() > 0 then
--				  updateTimeStr()
--				else
--					timerFinishHandler()
--			  end
			  
    	end
    	
			local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateCd))
		  local action = cc.RepeatForever:create(seq)
		  self:runAction(action)
			updateCd()
		end

    --self:show()
end

function CityBattleDrillView:executeCallback()
    if self.callback ~= nil then
        self.callback()
    end
    self:close()
end

function CityBattleDrillView:show()

    self.generalData = g_cityBattleGeneral.GetData()
    self.armyData = g_cityBattleArmy.GetData()
    self.armyUnitData = g_cityBattleArmyUnit.GetData()
    self.soldierData = g_cityBattleSoldier.GetData()

    if self.generalData == nil or self.soldierData == nil then
        if self.callback ~= nil then
            self.callback()
        end
        defaultShow = nil
        self:close()
        return
    end

    if self.armyData == nil or self.armyUnitData == nil then
        if self.callback ~= nil then
            self.callback()
        end
        defaultShow = nil
        self:close()
        return
    end
        
    self:setUiList()

    self:updateData()
    self:updatePropertyData()
    self:updateUiList()
end

--不变的数据--
function CityBattleDrillView:initUi()
    self.layout = self:loadUI("crossXiaochang_01.csb")
    self.root = self.layout:getChildByName("scale_node")

    --self.topRes = require("game.gametools.TopTitleRes").new(self.layout, {g_Consts.AllCurrencyType.Gem, g_Consts.AllCurrencyType.PlayerHonor})

    self.closeBtn = self.root:getChildByName("Button_1")
    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.Text_jc1 = self.root:getChildByName("Text_jc1")
    self.Text_jc1:setString(g_tr("drill"))
    self.Text_9 = self.root:getChildByName("Text_9")
    --self.Text_9:setString(g_tr("buyPrepare"))
		self.Text_9:setString("")
		
    for i=1, self.num do
        self["Button_juntuan0"..i] = self.root:getChildByName("Button_juntuan0"..i)
        self["Button_juntuan0"..i.."_Text_1"] = self["Button_juntuan0"..i]:getChildByName("Text_1")
        self["Button_juntuan0"..i.."_Image_s1"] = self["Button_juntuan0"..i]:getChildByName("Image_s1")
        self["Button_juntuan0"..i.."_Text_1"]:setString(g_tr("corp")..g_tr("num"..i))

        self["Button_juntuan0"..i.."_Image_s1"]:setVisible(false)
    end

    self:setTabHightlight(self.curTab)

    self.Panel_renwu = self.root:getChildByName("Panel_renwu")
    self.Panel_renwu_Text1 = self.Panel_renwu:getChildByName("Text_1")
    self.Panel_renwu_Text2 = self.Panel_renwu:getChildByName("Text_2")
    self.Panel_renwu_Text3 = self.Panel_renwu:getChildByName("Text_3")
    self.Panel_renwu_Text4 = self.Panel_renwu:getChildByName("Text_4")
    self.Panel_renwu_Text5 = self.Panel_renwu:getChildByName("Text_5")
    self.Panel_renwu_Text6 = self.Panel_renwu:getChildByName("Text_6")
    self.Panel_renwu_Text7 = self.Panel_renwu:getChildByName("Text_7")
    self.Panel_renwu_Text8 = self.Panel_renwu:getChildByName("Text_8")

    self.Panel_renwu_Text1:setString(g_tr("armyHead"))
    self.Panel_renwu_Text3:setString(g_tr("armyEnter"))
    self.Panel_renwu_Text5:setString(g_tr("corp")..g_tr("buildDetailTitlePower"))
    self.Panel_renwu_Text7:setString(g_tr("armyAllNumber"))
    self.Panel_renwu_Text2:setString(defaultShow)
    self.Panel_renwu_Text4:setString(defaultShow)
    self.Panel_renwu_Text6:setString(defaultShow)
    self.Panel_renwu_Text8:setString(defaultShow)

    self.Button_kuaisu = self.root:getChildByName("Button_kuaisu")
    self.Button_kuaisu_Text_42 = self.Button_kuaisu:getChildByName("Text_42")
    self.Button_kuaisu_Text_42:setString(g_tr("quickAdd"))

    self.Button_yb = self.root:getChildByName("Button_yb")
    self.Button_yb_Text_42 = self.Button_yb:getChildByName("Text_42")
    self.Button_yb_Text_42_0 = self.Button_yb:getChildByName("Text_42_0")
    self.Button_yb_Image_6 = self.Button_yb:getChildByName("Image_6")
    
    self.Button_yb:setVisible(false)

    local cost = g_data.cost[tonumber(g_data.country_basic_setting[62].data) + 10000].cost_num
    self.Button_yb_Text_42:setString(g_tr("buySoldier"))
    self.Button_yb_Text_42_0:setString(cost.."")

    self.Button_yb_0 = self.root:getChildByName("Button_yb_0")
    self.Button_yb_0_Text_42 = self.Button_yb_0:getChildByName("Text_42")
    self.Button_yb_0_Text_42_0 = self.Button_yb_0:getChildByName("Text_42_0")
    self.Button_yb_0_Image_6 = self.Button_yb_0:getChildByName("Image_6")

    cost = g_data.cost[tonumber(g_data.warfare_service_config[29].data) + 10000].cost_num
    self.Button_yb_0_Text_42:setString(g_tr("buySoldier"))
    self.Button_yb_0_Text_42_0:setString(cost.."")
    self.Button_yb_0_Image_6:loadTexture(g_data.sprite[1999008].path)

    self.Text_y1 = self.root:getChildByName("Text_y1")
    self.Text_y2 = self.root:getChildByName("Text_y2")
    self.Text_y1:setString(g_tr("armyLeft"))
    self.Text_y2:setString(defaultShow)
    
    self.Button_yb_0:setVisible(false)
end

function CityBattleDrillView:setUiList()
    self.ListView_1:removeAllItems()
    self.uiList = {}

    local item = nil
    for i=1, 3 do
        item = require("game.uilayer.drill.DrillItemView").new(self.selectGeneral, self.selectArmy, i*2-1, self.maxArmyNum, true)
        self.ListView_1:pushBackCustomItem(item)
        table.insert(self.uiList, item)
    end
    
    --必须写在所有DrillItemView创建之后
    g_guideManager.execute()
end

function CityBattleDrillView:addEvent()
    local function buyCallback()
        self.mode:getCityBattleData(self.getData)
        self.mode:cityBattleFullfillSoldier(self.curTab, self.getData)
    end
    
    local function proClick(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_juntuan01 or sender ==  self.Button_juntuan01_Text_1 then
                if self.allTab < 1 then
                    self:tipInfo()
                    return
                end
                self.orginPower = nil
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 1
                self:setTabHightlight(self.curTab)
                self:updatePropertyData()
                self:updateUiList()
            elseif sender == self.Button_juntuan02 or sender ==  self.Button_juntuan02_Text_1  then
                if self.allTab < 2 then
                    self:tipInfo()
                    return
                end
                self.orginPower = nil
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 2
                self:setTabHightlight(self.curTab)
                self:updatePropertyData()
                self:updateUiList()
            elseif sender == self.closeBtn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                if self.callback ~= nil then
                    self.callback()
                end
                defaultShow = nil
                self:close()
            elseif sender == self.Button_kuaisu then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

                local groupData, armyData = self:getGroupDataByTab(self.curTab)

                if armyData and armyData.leader_general_id > 0 then
                    self.mode:cityBattleFullfillSoldier(self.curTab, self.getData)
                else
                    g_airBox.show(g_tr("errorNoSoldier"))
                end
                
            elseif sender == self.Button_yb then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.mode:buySoldier(1, buyCallback)
            elseif sender == self.Button_yb_0 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.mode:buySoldier(2, buyCallback)
            end
        end
    end

    for i=1, self.num do
        self["Button_juntuan0"..i]:addTouchEventListener(proClick)
        self["Button_juntuan0"..i.."_Text_1"]:addTouchEventListener(proClick)
    end

    self.Button_kuaisu:addTouchEventListener(proClick)
    self.closeBtn:addTouchEventListener(proClick)
    self.Button_yb:addTouchEventListener(proClick)
    self.Button_yb_0:addTouchEventListener(proClick)
end

function CityBattleDrillView:initFun()
    self.getData = function(playerData, playerGeneralData, playerArmyData, playerArmyUnitData, playerSoldierData)
        --self.playerData = playerData
        self.generalData = playerGeneralData
        self.armyData = playerArmyData
        self.armyUnitData = playerArmyUnitData
        self.soldierData = playerSoldierData

        --筛选数据--
        self:updateData()

        --更新军团信息-- 
        self:updatePropertyData()

        --更新UI数据--
        self:updateUiList()
    end

    self.selectGeneral = function(data, pos)
        if pos > self.maxArmyNum then
            --self:tipInfo()
            return
        end

        self.curPos = pos

        self:showGeneralView(data)
    end

    self.postSetGeneral = function(general)
        if self.curCropData:getGeneralData() == nil or self.curCropData:getGeneralData().general_id ~= general.general_id then
            self.mode:setCityBattleGeneral(self.curTab, self.curPos, general.general_id, self.getData)
        else
            self.mode:setCityBattleGeneral(self.curTab, self.curPos, 0, self.getData)
        end
    end

    self.selectArmy = function(data, pos)
        if pos > self.maxArmyNum then
            --self:tipInfo()
            return
        end

        self.curPos = pos
        self:showArmyView(data)
    end

    self.postArmy = function(num, sid)
--        if num == nil or num == 0 then
--            self.mode:setCityBattleSoldier(self.curTab, self.curPos, 0, 0, self.getData)
--        else
--            self.mode:setCityBattleSoldier(self.curTab, self.curPos, sid, num, self.getData)
--        end
        self.mode:setCityBattleSoldier(self.curTab, self.curPos, sid, num, self.getData)
        if g_guideManager.execute() then
            defaultShow = nil
            self:close()
        end
    end

    self.closeWin = function()
        if self.callback ~= nil then
            self.callback()
        end
        defaultShow = nil
        self:close()
    end

    self.gotoView = function()
        g_sceneManager.addNodeForUI(require("game.uilayer.pub.PubLayer"):create())
        defaultShow = nil
        self:close()
    end
end

function CityBattleDrillView:updateData()

    self.group1 = {}
    self.group2 = {}

    if self.armyUnitData == nil then
        self.armyUnitData = {}
    end

    for key, value in pairs(self.armyUnitData) do
        local generalData = self:getGeneralDataByGeneralId(value.general_id)
        if self.armyData[tostring(value.army_id)] and self.armyData[tostring(value.army_id)].position == 1 then
            table.insert(self.group1, {value, generalData})
        elseif self.armyData[tostring(value.army_id)] and self.armyData[tostring(value.army_id)].position == 2 then
            table.insert(self.group2, {value, generalData})
        end
    end
end

 --更新军团信息-- 
 function CityBattleDrillView:updatePropertyData()
    
    --g_topTipRes.update()
    --self.topRes:update()

    self.soldierData = g_cityBattleSoldier.GetData()

    local groupData, armyData = self:getGroupDataByTab(self.curTab)

    self.curArmyData = armyData
    if armyData == nil or armyData.leader_general_id == 0 then
        self.Panel_renwu_Text2:setString(defaultShow)
        self.Panel_renwu_Text4:setString(defaultShow)
        self.Panel_renwu_Text6:setString(defaultShow)
        self.orginPower = 0
        self.Panel_renwu_Text8:setString(defaultShow)
    else
        local generalData = self:getGeneralDataByGeneralId(armyData.leader_general_id)
        local gData = g_GeneralMode.GetBasicInfo(generalData.general_id, 1)
        self.Panel_renwu_Text2:setString(g_tr(gData.general_name))

        --兵种数量
        local t1=0
        local t2=0
        local t3=0
        local t4=0

        local power = 0
        
        for i=1, #self.armyUnitData do
            if self.armyUnitData[i].army_id == armyData.id then
                power = power + self.armyUnitData[i].power
            end
            
            if self.armyUnitData[i].soldier_id ~= 0 and self.armyData[tostring(self.armyUnitData[i].army_id)].position == self.curTab then
                local info = g_SoldierMode.GetBasicInfo(self.armyUnitData[i].soldier_id)
                if info.soldier_type == 1 then
                    t1 = t1 + self.armyUnitData[i].soldier_num
                elseif info.soldier_type == 2 then
                    t2 = t2 + self.armyUnitData[i].soldier_num
                 elseif info.soldier_type == 3 then
                    t3 = t3 + self.armyUnitData[i].soldier_num
                 elseif info.soldier_type == 4 then
                    t4 = t4 + self.armyUnitData[i].soldier_num
                 end
            end
        end

        self.Panel_renwu_Text8:setString((t1+t2+t3+t4).."")
        self.Panel_renwu_Text6:setString(power.."")
        if self.orginPower == nil then

        else
            if self.orginPower < power then
                self.powerUp = require("game.uilayer.drill.DrillPowerUpView").new(power - self.orginPower)
                g_sceneManager.addNodeForUI(self.powerUp)
            end
        end
        self.orginPower = power
    end

    
    --self.Text_y2:setString(g_cityBattleSoldier.GetAllSoldierNumber().."")
    self.Panel_renwu_Text4:setString(table.getn(groupData).."/"..self.maxArmyNum)
 end

 function CityBattleDrillView:updateUiList()
    for i=1, #self.uiList do
        local item = self.uiList[i]
        item:setLeftCropData(nil, nil)
        item:setRightCropData(nil, nil)
        item:show()
    end
    
    local groupData, armyData = self:getGroupDataByTab(self.curTab)
    for i=1, #groupData do
        local item = self.uiList[math.ceil(groupData[i][1].unit/2)]
        if groupData[i][1].unit%2 == 1 then
            item:setLeftCropData(groupData[i][1], groupData[i][2])
        else
            item:setRightCropData(groupData[i][1], groupData[i][2])
        end
        item:show()
    end
    
 end

 function CityBattleDrillView:showGeneralView(cropData)
 
 		do --城战不能换武将
 			return 
 		end
 
    self.curCropData = cropData

    if self.curArmyData ~= nil and self.curArmyData.status ~= 0 then
        g_msgBox.show(g_tr("errorEditDrill"))
        return
    end

    --筛选数据--
    local result = {}
    --[[
    if cropData:getGeneralData() ~= nil then
        table.insert(result, cropData:getGeneralData())
    end
    ]]
    for i=1, #self.generalData do
        if self.generalData[i].status == 0 and self.generalData[i].army_id == 0 then
            if cropData:getGeneralData() ~= nil then
                if self.generalData[i].general_id ~= cropData:getGeneralData().general_id then
                    table.insert(result, self.generalData[i])
                end
            else
                table.insert(result, self.generalData[i])
            end
        end
    end

    table.sort(result, function (a, b) 
        local gData1 = g_GeneralMode.GetBasicInfo(a.general_id,  1)
        local gData2 = g_GeneralMode.GetBasicInfo(b.general_id,  1)
        return gData1.general_quality > gData2.general_quality
    end)

    if cropData:getGeneralData() ~= nil then
        table.insert(result, 1, cropData:getGeneralData())
    end

    g_sceneManager.addNodeForUI(require("game.uilayer.common.SelectGeneralView").new(result, cropData:getGeneralData(), self.postSetGeneral, self.gotoView, true))
end

function CityBattleDrillView:showArmyView(data)
    local function showGeneralData()
        local data = require("game.gamedata.CropData").new()
        self:showGeneralView(data)
    end

    if data:getGeneralData() == nil then
        g_msgBox.show(g_tr("errorSelectGeneral"), "", nil, showGeneralData)
        return
    end

    if self.curArmyData.status ~= 0 then
        g_msgBox.show(g_tr("errorEditDrill"))
        return
    end

    self.soldierData = g_cityBattleSoldier.GetData()

    g_sceneManager.addNodeForUI(require("game.uilayer.drill.CityBattleSelectArmy").new(self.soldierData, data:getArmyUnitData(), self.postArmy))
end

--工具方法--

function CityBattleDrillView:setTabHightlight(index)
    for i=1, self.num do
        self["Button_juntuan0"..i]:setBrightStyle(BRIGHT_NORMAL)
    end

    self["Button_juntuan0"..index]:setBrightStyle(BRIGHT_HIGHLIGHT)
end

function CityBattleDrillView:getGeneralDataByGeneralId(gid)
    for i=1, table.getn(self.generalData) do
        if tonumber(self.generalData[i].general_id) == tonumber(gid) then
            return self.generalData[i]
        end
    end
end

function CityBattleDrillView:getArmyUnitDataByGeneralId(gid)
    for i=1, table.getn(_playerArmyUnitData) do
        if self.armyUnitData[i].general_id == gid then
            return self.armyUnitData[i]
        end
    end
end

function CityBattleDrillView:getGroupDataByTab()
    self.armyData = g_cityBattleArmy.GetData()
    for key, value in pairs(self.armyData) do
        if value.position == self.curTab then
            if self.curTab == 1 then
                return self.group1, value
            elseif self.curTab == 2 then
                return self.group2, value
            end
            break
        end
    end

    return {}, nil
end

function CityBattleDrillView:tipInfo()
    require("game.uilayer.battleSet.battleSettingView").noArmyConfirm(self.closeWin, self.closeWin)
end

return CityBattleDrillView