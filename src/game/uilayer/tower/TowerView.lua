--region TowerView.lua
--Author : luqingqing
--Date   : 2015/11/12
--此文件由[BabeLua]插件自动生成

local TowerView = class("TowerView", require("game.uilayer.base.BaseLayer"))

function TowerView:ctor()
    TowerView.super.ctor(self)

    require("game.effectlayer.screenFire").hide()

    self.mode = require("game.uilayer.tower.TowerMode").new()

    self.layer = self:loadUI("tower_popup.csb")
    self.root = self.layer:getChildByName("scale_node")

    self.bg_content = self.root:getChildByName("bg_content")
    self.ListView_1 = self.bg_content:getChildByName("ListView_1")
    self.ListView_1_0 = self.bg_content:getChildByName("ListView_1_0")

    self.bg_content1 = self.root:getChildByName("bg_content1")

    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_9 = self.root:getChildByName("Text_9")

    self.Panel_1 = self.root:getChildByName("Panel_1")
    self.Panel_1_Text_1 = self.Panel_1:getChildByName("Text_1")
    self.Panel_1_Text_z1 = self.Panel_1:getChildByName("Text_z1")
    self.Panel_1_Text_z2 = self.Panel_1:getChildByName("Text_z2")
    self.Panel_1_Image_10 = self.Panel_1:getChildByName("Image_10")
    self.Panel_1_Image_10_0 = self.Panel_1:getChildByName("Image_10_0")

    self.Panel_1_Text_1:setString(g_tr("towerItemTitle"))
    self.Panel_1_Text_z1:setString(g_tr("towerWarProdect"))
    self.Panel_1_Text_z2:setString(g_tr("towerMove"))

    self.uiList = {}

    self:initFun()
    self:initData()
    self:addEvent()
end

function TowerView:initFun()
    self.showInfo = function(towerItemView)
        
        if self.selectItem and self.selectItem == towerItemView then
            return
        end
        

        for k, v in pairs (self.uiList) do
            v:clearSelect()
        end

        self.selectItem = towerItemView

        self.selectData = self.data[self.ListView_1_0:getIndex(self.selectItem) + 1]

        self.selectItem:updateSelect()
        self:updateContent()

    end
end

function TowerView:initData()
    self.mode:getTowerInfo(function(data) 
        self.data = data
        if self.data == nil then
            
            return
        end
        self:initUi()
    end)
end

function TowerView:initUi()
    if #self.data == 0 then
        local mes = require("game.uilayer.common.MessageLayer").new(g_tr("towerNoEnemy"))
        mes:setPosition(self.root:getContentSize().width/2, self.root:getContentSize().height/2)
        self.root:addChild(mes)
        self.bg_content1:setVisible(false)
        self.Panel_1:setVisible(false)
        return
    end
    
    for i=1, #self.data do
        local item = require("game.uilayer.tower.TowerItemView").new(self.data[i], self.showInfo, tem)

        if i == 1 then
            self.selectItem = item
            self.selectData = self.data[1]
        end

        table.insert(self.uiList, item)
        self.ListView_1_0:pushBackCustomItem(item)
    end

    if self.selectItem ~= nil then
        self.selectItem:updateSelect()
    end

    self:updateContent()
end

function TowerView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn  then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                if self.buildTimer then       
                    self:unschedule(self.buildTimer)
                    self.buildTimer = nil 
                end
                self:close()
            elseif sender == self.Panel_1_Image_10 then
                --战争保护
                if g_BagMode.findItemNumberById(21802) ~= 0 or g_BagMode.findItemNumberById(21803) ~= 0 or g_BagMode.findItemNumberById(21804) ~= 0 then
                    local value = nil
                    if g_BagMode.findItemNumberById(21802) ~= 0 then
                        value = g_data.item[21802].item_name
                    elseif g_BagMode.findItemNumberById(21803) ~= 0 then
                        value = g_data.item[21803].item_name
                    elseif g_BagMode.findItemNumberById(21804) ~= 0  then
                        value = g_data.item[21804].item_name
                    end
                    g_msgBox.show(g_tr("useItemConfirm",{item = g_tr(value)}),nil,nil,function(event)
                        if event == 0 then
                            local mode = require("game.uilayer.bag.BagMode").new()
                            local id = 0
                            if g_BagMode.findItemNumberById(21802) ~= 0 then
                                id = 21802
                            elseif g_BagMode.findItemNumberById(21803) ~= 0 then
                                id = 21803
                            elseif g_BagMode.findItemNumberById(21804) ~= 0 then
                                id = 21804
                            end
                            mode:itemUse(id, 1, function()
                                g_airBox.show(g_tr("bagUseItemSuc"))
                            end)
                        end
                    end,1)
                else
                    local shopLayer = require("game.uilayer.shop.ShopLayer"):create(g_Consts.ShopType.NORMAL)
                    g_sceneManager.addNodeForUI(shopLayer)
                    shopLayer:tabTags(3)
                end
            elseif sender == self.Panel_1_Image_10_0 then
                --随机迁城
                if g_BagMode.findItemNumberById(21200) ~= 0 then
                    g_msgBox.show(g_tr("useItemConfirm",{item = g_tr("towerMove")}),nil,nil,function(event)
                        if event == 0 then
                            local mode = require("game.uilayer.bag.BagMode").new()
                            mode:changePosition(function() 
                                g_airBox.show(g_tr("bagUseItemSuc"))
                            end)
                        end
                    end,1)
                else
                    local shopLayer = require("game.uilayer.shop.ShopLayer"):create(g_Consts.ShopType.NORMAL)
                    g_sceneManager.addNodeForUI(shopLayer)
                    shopLayer:tabTags(2)
                    
                end
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
    self.Panel_1_Image_10:addTouchEventListener(proClick)
    self.Panel_1_Image_10_0:addTouchEventListener(proClick)
end

function TowerView:updateContent()

    self.ListView_1:removeAllItems()

    local player = require("game.uilayer.tower.TowerPlayerView").new(self.selectData[1])
    self.ListView_1:pushBackCustomItem(player)

    local time = require("game.uilayer.tower.TowerTimeView").new(self.selectData[1])
    self.ListView_1:pushBackCustomItem(time)

    for i=1, #self.selectData do
        local title = require("game.uilayer.tower.TowerTitleView").new(g_tr("towerArmyNum"), self.selectData[i].total_soldier_num, true)
        self.ListView_1:pushBackCustomItem(title)

        if self.selectData[i].army then
            for j=1, #self.selectData[i].army[1] do
                local item = nil
                if j == 1 then
                    item = require("game.uilayer.tower.TowerArmyView").new(self.selectData[i].army[1][j], self.selectData[i].player_nick)
                else
                    item = require("game.uilayer.tower.TowerArmyView").new(self.selectData[i].army[1][j], "")
                end
                self.ListView_1:pushBackCustomItem(item)
            end
        end
    end

    local title = require("game.uilayer.tower.TowerTitleView").new(g_tr("towerArmyPro"), 0, true)
    self.ListView_1:pushBackCustomItem(title)

    if self.selectData[1].buff then
        for i=1, #self.selectData[1].buff do
            if g_data.buff[self.selectData[1].buff[i].id] ~= nil then
                local buffData = g_data.buff[self.selectData[1].buff[i].id]
                local title = nil
                if buffData.buff_type == 1 then
                    title = require("game.uilayer.tower.TowerTitleView").new(g_tr(buffData.description), "+ "..(self.selectData[1].buff[i].value*100).."%", false)
                else
                    title = require("game.uilayer.tower.TowerTitleView").new(g_tr(buffData.description), "+ "..self.selectData[1].buff[i].value, false)
                end
            
                self.ListView_1:pushBackCustomItem(title)
            end
        end
    end

    --[[
    if self.selectData[1].total_soldier_num then 
        local title = require("game.uilayer.tower.TowerTitleView").new(g_tr("towerArmyNum"), self.selectData[1].total_soldier_num, true)
        self.ListView_1:pushBackCustomItem(title)
    end
    
    if self.selectData.army then
        for j=1, #self.selectData.army[1] do
            item = require("game.uilayer.tower.TowerArmyView").new(self.selectData.army[1][j], "")
            self.ListView_1:pushBackCustomItem(item)
        end
    end

    local title = require("game.uilayer.tower.TowerTitleView").new(g_tr("towerArmyPro"), 0, true)
    self.ListView_1:pushBackCustomItem(title)
    

    if self.selectData.buff then
        for i=1, #self.selectData.buff do
            if g_data.buff[self.selectData.buff[i].id] ~= nil then
                local buffData = g_data.buff[self.selectData.buff[i].id]
                local title = nil
                if buffData.buff_type == 1 then
                    title = require("game.uilayer.tower.TowerTitleView").new(g_tr(buffData.description), "+ "..(self.selectData.buff[i].value*100).."%", false)
                else
                    title = require("game.uilayer.tower.TowerTitleView").new(g_tr(buffData.description), "+ "..self.selectData.buff[i].value, false)
                end
            
                self.ListView_1:pushBackCustomItem(title)
            end
        end
    end
    ]]
end

return TowerView

--endregion
