
--region DrillView.lua
--Author : luqingqing
--Date   : 2015/10/20
--此文件由[BabeLua]插件自动生成
local DrillView = class("DrillView",require("game.uilayer.base.BaseLayer"))

--默认显示--
local defaultShow = "-"

--文字显示的顺序--
local property = {g_tr("attack"), g_tr("defend"),g_tr("life"),g_tr("atkRange"), g_tr("speed"), g_tr("carry")}

function DrillView:onEnter()
    g_groundData.SetView(self)
end 

function DrillView:onExit()
    g_groundData.SetView(nil)
end 

function DrillView:ctor(callback, curTab)

    DrillView.super.ctor(self)

    self.callback = callback

     --当前的tab页--
    self.curTab = curTab or 1

    if self.curTab == 0 then
        self.curTab = 1
    end

    --初始化数据 
    self:init()

    self:initData()

    --初始化UI
    self:initUi()

    --添加事件
    self:addEvent()

    self:initFun()

    local function callback()
        g_busyTip.hide_1()
    end

    g_busyTip.show_1()


    g_groundData.RequestSycData(callback)
end

function DrillView:executeCallback()
    if self.callback ~= nil then
        self.callback()
    end
    self:close()
end

function DrillView:show()
    self.generalData = g_GeneralMode.GetData()
    self.armyData = g_ArmyMode.GetData()
    dump(self.armyData)
    self.armyUnitData = g_ArmyUnitMode.GetData()
    self.soldierData = g_SoldierMode.GetData()

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

function DrillView:init()
    self.num = 6

    self.mode = require("game.uilayer.drill.DrillMode").new()

    self.playerData = g_PlayerMode.GetData()

    self.buff = g_BuffMode.GetData()

    g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.DRILL_GROUND)
end

function DrillView:initData()
    --UI列表--
    self.uiList = {}

    local tem = 0
    for key, value in pairs(g_data.vip_privilege) do
        if tonumber(value.vip_lv) == tonumber(self.playerData.vip_level) then
            if value.privilege_type == 11 then
                tem = tonumber(value.buff_num)
                break
            end
        end
    end
    
    local buildData = g_PlayerBuildMode.FindBuild_high_OriginID(g_PlayerBuildMode.m_BuildOriginType.spectacular)
    
    do
        local maxNum = tonumber(g_data.starting[19].data)
        local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName("deputy_per_corp",buildData.position)

        if buffType == 1 then --万分比
            maxNum = math.ceil(maxNum * (10000 + buffValue)/10000)
        elseif buffType == 2 then --固定值
            maxNum = maxNum + buffValue
        end
        self.maxArmyNum = maxNum

    end
    
    do
        local playerArmyNumber = self.playerData.army_num

        local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName("corps_in_control",buildData.position)

        if buffType == 1 then --万分比
            playerArmyNumber = math.ceil(playerArmyNumber * (10000 + buffValue)/10000)
        elseif buffType == 2 then --固定值
            playerArmyNumber = playerArmyNumber + buffValue
        end
        self.allTab = playerArmyNumber + tem
    end
    
end

--不变的数据--
function DrillView:initUi()
    self.layout = self:loadUI("xiaochang.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.closeBtn = self.root:getChildByName("Button_1")
    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.Text_jc1 = self.root:getChildByName("Text_jc1")
    self.Text_jc1:setString(g_tr("drill"))


    for i=1, self.num do
        self["Button_juntuan0"..i] = self.root:getChildByName("Button_juntuan0"..i)
        self["Button_juntuan0"..i.."_Text_1"] = self["Button_juntuan0"..i]:getChildByName("Text_1")
        self["Button_juntuan0"..i.."_Image_s1"] = self["Button_juntuan0"..i]:getChildByName("Image_s1")
        self["Button_juntuan0"..i.."_Text_1"]:setString(g_tr("corp")..g_tr("num"..i))

        if i > self.allTab then
            self["Button_juntuan0"..i.."_Image_s1"]:setVisible(true)
        else
            self["Button_juntuan0"..i.."_Image_s1"]:setVisible(false)
        end
        if i  > (self.allTab + 1) and i <= self.num then
            self["Button_juntuan0"..i]:setVisible(false)
        end
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
    self.Panel_renwu_Text9 = self.Panel_renwu:getChildByName("Text_9")
    self.Panel_renwu_Text10 = self.Panel_renwu:getChildByName("Text_10")
    self.Panel_renwu_Text1:setString(g_tr("armyHead"))
    self.Panel_renwu_Text3:setString(g_tr("armyEnter"))
    self.Panel_renwu_Text5:setString(g_tr("corp")..g_tr("buildDetailTitlePower"))
    self.Panel_renwu_Text7:setString(g_tr("carry"))
    self.Panel_renwu_Text9:setString(g_tr("armyAllNumber"))
    self.Panel_renwu_Text2:setString(defaultShow)
    self.Panel_renwu_Text4:setString(defaultShow)
    self.Panel_renwu_Text6:setString(defaultShow)
    self.Panel_renwu_Text8:setString(defaultShow)
    self.Panel_renwu_Text10:setString(defaultShow)

    self.Button_kuaisu = self.root:getChildByName("Button_kuaisu")
    self.Button_kuaisu_Text_42 = self.Button_kuaisu:getChildByName("Text_42")
    self.Button_kuaisu_Text_42:setString(g_tr("quickAdd"))
    self.Button_ckyby = self.root:getChildByName("Button_ckyby")
    self.Button_ckyby_Text_42 = self.Button_ckyby:getChildByName("Text_42")
    self.Button_ckyby_Text_42:setString(g_tr("seePrepareArmy"))

    self.Text_y1 = self.root:getChildByName("Text_y1")
    self.Text_y2 = self.root:getChildByName("Text_y2")
    self.Text_y1:setString(g_tr("armyLeft"))
    self.Text_y2:setString(defaultShow)
end

function DrillView:setUiList()
    local item = nil
    for i=1, 3 do
        item = require("game.uilayer.drill.DrillItemView").new(self.selectGeneral, self.selectArmy, i*2-1, self.maxArmyNum)
        self.ListView_1:pushBackCustomItem(item)
        table.insert(self.uiList, item)
    end
    
    --必须写在所有DrillItemView创建之后
    g_guideManager.execute()
end

function DrillView:addEvent()
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
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
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
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan03 or sender ==  self.Button_juntuan03_Text_1  then
                if self.allTab < 3 then
                    self:tipInfo()
                    return
                end
                self.orginPower = nil
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 3
                self:setTabHightlight(self.curTab)
                self:updatePropertyData()
                self:updateUiList()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan04 or sender ==  self.Button_juntuan04_Text_1  then
                if self.allTab < 4 then
                    self:tipInfo()
                    return
                end
                self.orginPower = nil
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 4
                self:setTabHightlight(self.curTab)
                self:updatePropertyData()
                self:updateUiList()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan05 or sender ==  self.Button_juntuan05_Text_1  then
                if self.allTab < 5 then
                    self:tipInfo()
                    return
                end
                self.orginPower = nil
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 5
                self:setTabHightlight(self.curTab)
                self:updatePropertyData()
                self:updateUiList()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan06 or sender ==  self.Button_juntuan06_Text_1  then
                if self.allTab < 6 then
                    self:tipInfo()
                    return
                end
                self.orginPower = nil
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 6
                self:setTabHightlight(self.curTab)
                self:updatePropertyData()
                self:updateUiList()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.closeBtn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                if self.callback ~= nil then
                    self.callback()
                end
                defaultShow = nil
                self:close()
            elseif sender == self.Button_kuaisu then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                local tag = false
                local groudData, value = self:getGroupDataByTab(self.curTab)

                for key, value in pairs(groudData) do
                    if value[1].soldier_id ~= 0 then
                        tag = true
                        break
                    end
                 end
                
                if tag == false then
                    g_airBox.show(g_tr("errorNoSoldier"))
                    return
                end
                self.mode:fullfillSoldier(self.curTab, self.getData)
            elseif sender == self.Button_ckyby then
                g_sceneManager.addNodeForUI(require("game.uilayer.drill.PrepareArmyView").new())
            end
        end
    end

    for i=1, self.num do
        self["Button_juntuan0"..i]:addTouchEventListener(proClick)
        self["Button_juntuan0"..i.."_Text_1"]:addTouchEventListener(proClick)
    end

    self.Button_kuaisu:addTouchEventListener(proClick)
    self.closeBtn:addTouchEventListener(proClick)
    self.Button_ckyby:addTouchEventListener(proClick)
end

function DrillView:initFun()
    self.getData = function(playerData, playerGeneralData, playerArmyData, playerArmyUnitData, playerSoldierData)
        self.playerData = playerData
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
            self.mode:setGeneral(self.curTab, self.curPos, general.general_id, self.getData)
        else
            self.mode:setGeneral(self.curTab, self.curPos, 0, self.getData)
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

    self.postArmy = function(selectArmyItemView)
        if selectArmyItemView:getNum() == nil or selectArmyItemView:getNum() == 0 then
            self.mode:setSoldier(self.curTab, self.curPos, 0, 0, self.getData)
        else
            self.mode:setSoldier(self.curTab, self.curPos, selectArmyItemView:getSoliderData().soldier_id, selectArmyItemView:getNum(), self.getData)
        end
        
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

function DrillView:updateData()

    self.group1 = {}
    self.group2 = {}
    self.group3 = {}
    self.group4 = {}
    self.group5 = {}
    self.group6 = {}

    if self.armyUnitData == nil then
        self.armyUnitData = {}
    end

    for key, value in pairs(self.armyUnitData) do
        local generalData = self:getGeneralDataByGeneralId(value.general_id)
        if self.armyData[tostring(value.army_id)] and self.armyData[tostring(value.army_id)].position == 1 then
            table.insert(self.group1, {value, generalData})
        elseif self.armyData[tostring(value.army_id)] and self.armyData[tostring(value.army_id)].position == 2 then
            table.insert(self.group2, {value, generalData})
        elseif self.armyData[tostring(value.army_id)] and self.armyData[tostring(value.army_id)].position == 3 then
            table.insert(self.group3, {value, generalData})
        elseif self.armyData[tostring(value.army_id)] and self.armyData[tostring(value.army_id)].position == 4 then
            table.insert(self.group4, {value, generalData})
        elseif self.armyData[tostring(value.army_id)] and self.armyData[tostring(value.army_id)].position == 5 then
            table.insert(self.group5, {value, generalData})
        elseif self.armyData[tostring(value.army_id)] and self.armyData[tostring(value.army_id)].position == 6 then
            table.insert(self.group6, {value, generalData})
        end
    end
end

 --更新军团信息-- 
 function DrillView:updatePropertyData()
    local groupData, armyData = self:getGroupDataByTab(self.curTab)

    self.curArmyData = armyData
    if armyData == nil or armyData.leader_general_id == 0 then
        self.Panel_renwu_Text2:setString(defaultShow)
        self.Panel_renwu_Text4:setString(defaultShow)
        self.Panel_renwu_Text6:setString(defaultShow)
        self.orginPower = 0
        self.Panel_renwu_Text8:setString(defaultShow)
        self.Panel_renwu_Text10:setString(defaultShow)
    else
        local generalData = self:getGeneralDataByGeneralId(armyData.leader_general_id)
        local gData = g_GeneralMode.GetBasicInfo(generalData.general_id, 1)
        self.Panel_renwu_Text2:setString(g_tr(gData.general_name))
        self.Panel_renwu_Text8:setString(armyData.weight.."")
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

        self.Panel_renwu_Text10:setString((t1+t2+t3+t4).."")
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

    self.Text_y2:setString(g_SoldierMode.GetAllSoldierNumber().."")
    self.Panel_renwu_Text4:setString(table.getn(groupData).."/"..self.maxArmyNum)
 end

 function DrillView:updateUiList()
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

 function DrillView:showGeneralView(cropData)
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

    g_sceneManager.addNodeForUI(require("game.uilayer.common.SelectGeneralView").new(result, cropData:getGeneralData(), self.postSetGeneral, self.gotoView))
end

function DrillView:showArmyView(data)
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

    g_sceneManager.addNodeForUI(require("game.uilayer.common.SelectArmyView").new(self.soldierData, data, self.postArmy, self.closeWin, self.curTab))
end

--------------

----------------------------------------------------

--工具方法--

function DrillView:setTabHightlight(index)
    for i=1, self.num do
        self["Button_juntuan0"..i]:setBrightStyle(BRIGHT_NORMAL)
    end

    print(index, "11111111111111111111111")
    self["Button_juntuan0"..index]:setBrightStyle(BRIGHT_HIGHLIGHT)
end

function DrillView:getGeneralDataByGeneralId(gid)
    for i=1, table.getn(self.generalData) do
        if tonumber(self.generalData[i].general_id) == tonumber(gid) then
            return self.generalData[i]
        end
    end
end

function DrillView:getArmyUnitDataByGeneralId(gid)
    for i=1, table.getn(_playerArmyUnitData) do
        if self.armyUnitData[i].general_id == gid then
            return self.armyUnitData[i]
        end
    end
end

function DrillView:getGroupDataByTab()
    for key, value in pairs(self.armyData) do
        if value.position == self.curTab then
            if self.curTab == 1 then
                return self.group1, value
            elseif self.curTab == 2 then
                return self.group2, value
            elseif self.curTab == 3 then
                return self.group3, value
            elseif self.curTab == 4 then
                return self.group4, value
            elseif self.curTab == 5 then
                return self.group5, value
            elseif self.curTab == 6 then
                return self.group6, value
            end
            break
        end
    end

    return {}, nil
end

function DrillView:tipInfo()
    require("game.uilayer.battleSet.battleSettingView").noArmyConfirm(self.closeWin, self.closeWin)
end

return DrillView

--endregion