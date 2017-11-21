--region BagView.lua
--Author : luqingqing
--Date   : 2015/11/3
--此文件由[BabeLua]插件自动生成

local BagView = class("BagView", require("game.uilayer.base.BaseLayer"))

local tab = {g_tr("myItem"), g_tr("myMaterial"), g_tr("myEquipment"), g_tr("myEquipmentMaster")}

function BagView:ctor()
    BagView.super.ctor(self)

    self:initUi()
    self:addEvent()

    --获取最新主公宝物信息
    --g_MasterEquipMode.RequestData()
    self.mode:setNew(nil,true)
end

function BagView:onEnter()
    g_BagMode.setView(self)
    
end

function BagView:onExit()
    g_BagMode.setView(nil)
end

--srcType:来源: 1:铁匠铺合成, 2:其他..
function BagView:show(index, callback, srcType)
    self.refreshMaterial = function()
        if self.content ~= nil then
            self.content:refresh()
        end
    end

    self.clickend = function(itemId)
        if callback ~= nil then
            callback(itemId)
            g_BagMode.setView(nil)
            self:close()
        else
            if itemId >= 51001 and itemId <= 51006 then
                g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(3))
                self:close()
            else
                local item = g_data.item[itemId]
                if item and item.item_type == 6 then --红装碎片不能合成
                    local itemData = {item_type = g_Consts.DropType.Props, item_id = item.id, num = 1}
                    local itemView = require("game.uilayer.bag.BagItemNoButtonView").new(itemData)
                    g_sceneManager.addNodeForUI(itemView)                    
                    return 
                end 
                local SmithyData = require("game.uilayer.smithy.SmithyData")
                local baseView = SmithyData:instance():getBaseView()
                if baseView then 
                    baseView:showView(SmithyData.viewType.Compose, self.item)
                else 
                    if self.clickCallback ~= nil then
                        self.clickCallback()
                    end
                    g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SMITHY, {type=SmithyData.viewType.Compose, val = {itemId=itemId, onPreExit = self.refreshMaterial}})
                end
            end
            
        end
    end

    self.toView = function()
        g_BagMode.setView(nil)
        self:close()
        local view = require("game.uilayer.office.OfficeLayer").new()
        g_sceneManager.addNodeForUI(view)
    end

    self.toMaster = function()
        g_BagMode.setView(nil)
        self:close()
        require("game.uilayer.master.MasterView"):createLayer()
    end

    self.callback = function()
        self:close()
    end

    if index == nil or index == 0 then
        self.curTab = 1
    else
        self.curTab = index
    end

    self.srcType = srcType 

    self:updateUi()
end

function BagView:initUi()
    self.layer = self:loadUI("Useprops_Panel.csb")
    self.root = self.layer:getChildByName("scale_node")

    for i=1,4 do
        self["Button_anniu0"..i] = self.root:getChildByName("Button_anniu0"..i)
        self["Button_anniu0"..i.."_Text_1"] = self["Button_anniu0"..i]:getChildByName("Text_1")
        self["Button_anniu0"..i.."_Text_1"]:setString(tab[i])
    end

    self.Button_1 = self.root:getChildByName("Button_1")
    self.container = self.root:getChildByName("container")
    self.Text_bt = self.root:getChildByName("Text_bt")
    self.Text_bt:setString(g_tr("bagTitle"))

    self.mode = require("game.uilayer.bag.BagMode").new()
end

function BagView:updateUi()
    if self.content ~= nil then
        self.container:removeChild(self.content)
    end

    if self.curTab == 1 then
        self.content = require("game.uilayer.bag.BagContentView").new(self.callback)
    elseif self.curTab == 2 then
        self.content = require("game.uilayer.bag.BagMaterialView").new(self.clickend, self.srcType)
    elseif self.curTab == 3 then
        self.content = require("game.uilayer.bag.BagEquipView").new(self.toView)
    elseif self.curTab == 4 then
        self.content = require("game.uilayer.bag.BagEquipMaskView").new(self.toMaster)
    end

    self:setTabHightlight(self.curTab)
    self.container:addChild(self.content)
end

function BagView:setTabHightlight(index)
    self.Button_anniu01:setBrightStyle(BRIGHT_NORMAL)
    self.Button_anniu02:setBrightStyle(BRIGHT_NORMAL)
    self.Button_anniu03:setBrightStyle(BRIGHT_NORMAL)
    self.Button_anniu04:setBrightStyle(BRIGHT_NORMAL)

    self["Button_anniu0"..index]:setBrightStyle(BRIGHT_HIGHLIGHT)
end

function BagView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_anniu01 then
                self:setTabHightlight(self.curTab)
                if self.curTab == 1 then
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 1
                self:updateUi()
            elseif sender == self.Button_anniu02 then
                self:setTabHightlight(self.curTab)
                if self.curTab == 2 then
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 2
                
                self:updateUi()
            elseif sender == self.Button_anniu03 then
                self:setTabHightlight(self.curTab)
                if self.curTab == 3 then
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 3
                
                self:updateUi()
            elseif sender == self.Button_anniu04 then
                self:setTabHightlight(self.curTab)
                if self.curTab == 4 then
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 4
                
                self:updateUi()
            elseif sender == self.Button_1 then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                g_BagMode.setView(nil)
                self:close()
            end
        end
    end
    
    self.Button_anniu01:addTouchEventListener(proClick)
    self.Button_anniu02:addTouchEventListener(proClick)
    self.Button_anniu03:addTouchEventListener(proClick)
    self.Button_anniu04:addTouchEventListener(proClick)
    self.Button_1:addTouchEventListener(proClick)
end

--更新道具界面
function BagView:updateItemView()
    if self.content ~= nil then
        self.content:refresh()
    end
end

return BagView
--endregion
