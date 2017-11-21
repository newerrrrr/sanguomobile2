--region activity_moneyView.lua
--Author : luqingqing
--Date   : 2016/4/21
--此文件由[BabeLua]插件自动生成

local activity_moneyView = class("activity_moneyView", function()
    return cc.Layer:create()
end)

function activity_moneyView:ctor(activityId)

    g_moneyData.setView(self)

    g_moneyData.resetTag()

    self.mode = require("game.uilayer.activity.ActivityMode").new()

    self.activityList = g_data.activity[1099].drop

    self:initFun()
    self:initUI()

    local function getData(data)
        self.data = data
        if self.data == nil or self.data.list == nil then
            return
        end
        
        self:initContent()
    end

    self.mode:getGiftList(g_channelManager.GetPayWayList()[1], getData)
end

function activity_moneyView:initFun()
    self.selectTitle = function(item)

        self.index = item:getData().activity_id

        self:initTitle()

        self:initContent()
    end

    self.showInfo = function(data)
        g_sceneManager.addNodeForUI(require("game.uilayer.activity.activityMoney.actMoneyInfoView").new(data))
    end
end

function activity_moneyView:initUI()
    self.layer = cc.CSLoader:createNode("activity2_main.csb")
    self:addChild(self.layer)

    self.root = self.layer:getChildByName("scale_node")

    self.close_btn = self.root:getChildByName("close_btn")
    self.ListView_1 = self.root:getChildByName("ListView_1")
end

function activity_moneyView:update()
    local function getData(data)
        self.data = data
        if self.data == nil or self.data.list == nil then
            return
        end
        
        self:initContent()
    end

    self.mode:getGiftList(g_channelManager.GetPayWayList()[1], getData)
end

function activity_moneyView:initContent()
    self.ListView_1:removeAllItems()
    for i=1, #self.data.list do
        local item = require("game.uilayer.activity.activityMoney.actMoneyItemView").new(self.showInfo)
        self.ListView_1:pushBackCustomItem(item)
        item:show(self.data.list[i])
    end
end

function activity_moneyView:update()
    local function getData(data)
        self.data = data
        if self.data == nil or self.data.list == nil then
            return
        end
        self:initContent()
    end

    self.mode:getGiftList(g_channelManager.GetPayWayList()[1], getData)
end

return activity_moneyView
--endregion
