--region SelectArmyView.lua
--Author : luqingqing
--Date   : 2015/10/30
--此文件由[BabeLua]插件自动生成

local SelectArmyView = class("SelectArmyView", require("game.uilayer.base.BaseLayer"))

local property = {g_tr("allSoldier"),g_tr("infantry"),g_tr("cavalry"),g_tr("archer"),g_tr("vehicles")}

function SelectArmyView:ctor(data, cropData, clickCallback, closeWin, curTab)
    SelectArmyView.super.ctor(self)

    self.data = data
    self.cropData = cropData
    self.clickBack = clickCallback
    self.temTab = curTab
    self.curTab = 1

    self.closeWin = function()
        self:close()
        if closeWin ~= nil then
            closeWin()
        end
    end

    self.curItem = nil

    self.group0 = {}
    self.group1 = {}
    self.group2 = {}
    self.group3 = {}
    self.group4 = {}

    self.uiList = {}

    self.layer = self:loadUI("xuanzhebudui.csb")
    self.root = self.layer:getChildByName("scale_node")

    self.Button_xhao = self.root:getChildByName("Button_xhao")
    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.Text_24 = self.root:getChildByName("Text_24")
    self.Text_24:setString(g_tr("drill"))

    for i=1, 5 do
        self["Button_"..i] = self.root:getChildByName("Button_"..i)
        self["Button_"..i.."_Text1"] = self["Button_"..i]:getChildByName("Text_1")
        self["Button_"..i.."_Text1"]:setString(property[i])
    end

    self.cancel = self.root:getChildByName("btn_cancle")
    self.cancel_txt = self.root:getChildByName("Text_2")
    self.cancel_txt:setString(g_tr("confirm"))
    
    g_guideManager.registComponent(1000206,self.cancel)

    self:setTabBright(self.curTab)
    self:initFun()
    self:initData()
    self:updateUiList()
    self:addEvent()
end

function SelectArmyView:initFun()
    self.updateSelect = function()
        for i=1, #self.uiList do
            if self.uiList[i] ~= nil then
                self.uiList[i]:clearSelect()
            end
        end
    end

    self.selectArmy = function(selectArmyItemView)
        if selectArmyItemView == nil then
            return
        end

        if self.curItem == nil then
            self.curItem = selectArmyItemView
            return
        end

        for i=1, #self.uiList do
            if self.uiList[i] ~= nil and self.uiList[i]~=selectArmyItemView  then
                self.uiList[i]:clearSider()
            end
        end

        self.curItem = selectArmyItemView
    end
end

function SelectArmyView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_xhao then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            elseif sender == self.Button_1 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.curTab ~= 1 then
                    self.curTab = 1
                    self:setTabBright(self.curTab)
                    self.uiList = {}
                    self:updateUiList()
                    self.curItem = nil
                end
            elseif sender == self.Button_2 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                 if self.curTab ~= 2 then
                    self.curTab = 2
                    self:setTabBright(self.curTab)
                    self.uiList = {}
                    self:updateUiList()
                     self.curItem = nil
                end
            elseif sender == self.Button_3 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                 if self.curTab ~= 3 then
                    self.curTab = 3
                    self:setTabBright(self.curTab)
                    self.uiList = {}
                    self:updateUiList()
                     self.curItem = nil
                end
            elseif sender == self.Button_4 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                 if self.curTab ~= 4 then
                    self.curTab = 4
                    self:setTabBright(self.curTab)
                    self.uiList = {}
                    self:updateUiList()
                     self.curItem = nil
                end
            elseif sender == self.Button_5 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                 if self.curTab ~= 5 then
                    self.curTab = 5
                    self:setTabBright(self.curTab)
                    self.uiList = {}
                    self:updateUiList()
                    self.curItem = nil
                end
            elseif sender == self.cancel then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.curItem ~= nil then
                    self.clickBack(self.curItem)
                end
                self:close()
            end
        end
    end

    self.Button_xhao:addTouchEventListener(proClick)
    self.Button_1:addTouchEventListener(proClick)
    self.Button_2:addTouchEventListener(proClick)
    self.Button_3:addTouchEventListener(proClick)
    self.Button_4:addTouchEventListener(proClick)
    self.Button_5:addTouchEventListener(proClick)

    self.cancel:addTouchEventListener(proClick)
end

function SelectArmyView:initData()
    for key, value in pairs(self.data) do
        local sData = g_SoldierMode.GetBasicInfo(value.soldier_id)
        if value.num == 0 and self.cropData:getArmyUnitData() and self.cropData:getArmyUnitData().soldier_id ~= value.soldier_id then
        
        else
            if sData.soldier_type == 1 then
                table.insert(self.group1, value)
            elseif sData.soldier_type == 2 then
                table.insert(self.group2, value)
            elseif sData.soldier_type == 3 then
                table.insert(self.group3, value)
            elseif sData.soldier_type == 4 then
                table.insert(self.group4, value)
            end
            --table.insert(self.group0, value)
        end
    end
    
    local gData = g_GeneralMode.GetBasicInfo(self.cropData:getGeneralData().general_id, 1)
    local soldierType = g_data.equip_skill[g_data.equipment[gData.general_item_id*100].equip_skill_id[1]].equip_arm_type

    for key, value in pairs(self["group"..soldierType]) do
        table.insert(self.group0, value)
    end

    print(soldierType, "@@@@@@@@@")

    local tem = {}
    for i=1, 4 do
        if i ~= soldierType  then
            for key, value in pairs(self["group"..i]) do
                table.insert(tem, value)
            end
        end
    end

    table.sort(tem, function(a,b) 
            local ad = g_data.soldier[a.soldier_id]
            local bd = g_data.soldier[b.soldier_id]
            return ad.soldier_level > bd.soldier_level
    end)

    table.sort(self.group0, function(a,b) 
            local ad = g_data.soldier[a.soldier_id]
            local bd = g_data.soldier[b.soldier_id]
            return ad.soldier_level > bd.soldier_level
    end)

    for i=1, #tem do
        table.insert(self.group0, tem[i])
    end
end

function SelectArmyView:updateUiList()
    self.ListView_1:removeAllItems()
    local groupData = self:getGroupData()
    self:loadItemData(groupData)
end

function SelectArmyView:onEnter()
    SelectArmyView.super.onEnter(self)

end 


function SelectArmyView:getGroupData()
    if self.curTab == 1 then
        return self.group0
    elseif self.curTab == 2 then
        return self.group1
    elseif self.curTab == 3 then
        return self.group2
    elseif self.curTab == 4 then
        return self.group3
    elseif self.curTab == 5 then
        return  self.group4
    end
    return {}
end

function SelectArmyView:setTabBright(index)
    self["Button_1"]:setBrightStyle(BRIGHT_NORMAL)
    self["Button_2"]:setBrightStyle(BRIGHT_NORMAL)
    self["Button_3"]:setBrightStyle(BRIGHT_NORMAL)
    self["Button_4"]:setBrightStyle(BRIGHT_NORMAL)
    self["Button_5"]:setBrightStyle(BRIGHT_NORMAL)

    self["Button_"..index]:setBrightStyle(BRIGHT_HIGHLIGHT)
end

function SelectArmyView:loadItemData(data)
    local index = 0
    local idx_s = 1 
    local idx_e = #data
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
            item = require("game.uilayer.common.SelectArmyItemView").new(data[idx_s], self.cropData, self.selectArmy, self.updateSelect, self.closeWin, self.temTab)
            self.ListView_1:pushBackCustomItem(item)

            --注册新手引导NodeId
            if idx_s == 1 then
                g_guideManager.registComponent(1000205,item.layout:getChildByName("scale_node"):getChildByName("Slider_1"):getSlidBallTextureNormal())
                g_guideManager.execute()
            end
            idx_s = idx_s + 1 
            index = index + 1
            table.insert(self.uiList, item)
        else
            --加载完成
            if self.frameLoadTimer then 
                self:unschedule(self.frameLoadTimer) 
                self.frameLoadTimer = nil  
            end 
        end
    end

    --分侦加载
    if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
    end 
    self.frameLoadTimer = self:schedule(loadItem, 0) 
end

return SelectArmyView

--endregion