--region SelectGeneralView.lua
--Author : luqingqing
--Date   : 2015/10/28
--此文件由[BabeLua]插件自动生成

local SelectGeneralView = class("SelectGeneralView", require("game.uilayer.base.BaseLayer"))

local offset = 10

function SelectGeneralView:ctor(data, general, callback, gotoView, isCross)
    SelectGeneralView.super.ctor(self)
    
    self.data = data
    self.general = general
    self.click = callback
    self.gotoView = gotoView
    self.isCross = isCross or false
    self.uilist = {}

    self.layout = self:loadUI("xuanzewujiang.csb")
    self.root = self.layout:getChildByName("scale_node")
    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.Button_1 = self.root:getChildByName("Button_1")
    self.Button_2 = self.root:getChildByName("Button_2")
    self.Text_23 = self.Button_2:getChildByName("Text_23")
    self.Text_22 = self.root:getChildByName("Text_22")
    self.Text_22_0 = self.root:getChildByName("Text_22_0")
    self.Text_bti = self.root:getChildByName("Text_bti")
    self.Text_bti:setString(g_tr("drill"))
    self.Text_22:setString(g_tr("selectGeneralTitle"))
    self.Text_22_0:setString(g_tr("moreGeneral"))
    
    g_guideManager.registComponent(1000203,self.Button_2)

    self:addEvent()
    self:initUi()
end

function SelectGeneralView:initUi()
    if self.data ~= nil then
        if #self.data == 0 then
            self.Text_22_0:setVisible(true)
            return
        end

        self.Text_22_0:setVisible(false)

        local len = 0
        local curLen = 0

        local function clickCallback(item)
            if self.selectItem ~= nil then
                self.selectItem:setSelect(false)
                self.selectItem = item
                self.selectItem:setSelect(true)
            else
                self.selectItem = item
                self.selectItem:setSelect(true)
            end
            
            --self:processCallback()

            if self.general ~= nil and item:getData().general_id == self.general.general_id then
                self.Text_23:setString(g_tr_original("removeFight"))
            else
                self.Text_23:setString(g_tr_original("enterFight"))
            end
            g_guideManager.execute()
        end

        self:loadItemData(self.data, clickCallback)
    end
end

function SelectGeneralView:onEnter()
    SelectGeneralView.super.onEnter(self)
end 


function SelectGeneralView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            elseif sender == self.Button_2 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.selectItem == nil then
                else
                    self.click(self.selectItem:getData())
                end
                self:close()
            end
        end
    end

    self.Button_1:addTouchEventListener(proClick)
    self.Button_2:addTouchEventListener(proClick)
end

function SelectGeneralView:processCallback()

    for key, value in pairs(self.uilist) do
        value:setSelect(false)
    end

    self.selectItem:setSelect(true)
end

function SelectGeneralView:loadItemData(data, clickCallback)
    local index = 0
    local idx_s = 1 
    local idx_e = #data
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
            local item = require("game.uilayer.common.SelGeneralItemView").new()
            self.ListView_1:pushBackCustomItem(item)
            item:show(data[idx_s], clickCallback, self.isCross)


            --注册新手引导NodeId
            if idx_s == 1 then
                g_guideManager.registComponent(1000202,item)
                g_guideManager.execute()
            end

            if self.general ~= nil and data[idx_s].general_id == self.general.general_id then
                item:setSelect(true)
                self.selectItem = item
                self.Text_23:setString(g_tr("removeFight"))
            end

            idx_s = idx_s + 1 
            index = index + 1
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

return SelectGeneralView

--endregion
