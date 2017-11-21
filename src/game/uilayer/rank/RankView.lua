--region RankView.lua
--Author : luqingqing
--Date   : 2016/3/29
--此文件由[BabeLua]插件自动生成

local RankView = class("RankView", require("game.uilayer.base.BaseLayer"))

local property = {g_tr("rankAlliencePower"),g_tr("rankAllienceEnemy"),g_tr("rankPlayerPower"),g_tr("rankPlayerEnemy"),g_tr("rankPlayerHouse"),g_tr("rankPlayerLevel")}

function RankView:ctor()
    RankView.super.ctor(self)

    self:initUI()
    self:initFun()

    self:addEvent()

    self.uiList = {}

    --默认选中第一种
    self.curTab = g_Consts.RankType.alliencePower

    self:setTabHightlight(self.curTab)

    self.mode = require("game.uilayer.rank.RankMode").new()

    self.mode:getRank(5, self.getData)
end

function RankView:initFun()
    self.getData = function(data)
         self.data = data
         dump(self.data)
         self:setData()
    end

    self.showPlayerInfo = function(data)
        if self.curTab ~= g_Consts.RankType.alliencePower and self.curTab ~= g_Consts.RankType.allienceEnemyDie then
            g_sceneManager.addNodeForUI(require("game.uilayer.map.mapPlayerInfoView"):create( tonumber(data.gpd) ))
        else
            require("game.uilayer.alliance.manor.AllianceInfoLayer").show(data.gpd)
        end
    end
end

function RankView:initUI()
    self.layer = self:loadUI("ranking_panel.csb")

    self.root = self.layer:getChildByName("scale_node")
    self.Button_x = self.root:getChildByName("Button_x")

    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1_0 = self.root:getChildByName("Text_1_0")

    self.Text_1:setString(g_tr("rankAllience"))
    self.Text_1_0:setString(g_tr("rankPlayer"))

    for i=1, 6 do
        self["Button_h"..i] = self.root:getChildByName("Button_h"..i)
        self["Text_h"..i] = self.root:getChildByName("Text_h"..i)
        self["Text_h"..i]:setString(property[i])
    end

    self.Text_sx1 = self.root:getChildByName("Text_sx1")
    self.Text_sx2 = self.root:getChildByName("Text_sx2")
    self.Text_sx2_0 = self.root:getChildByName("Text_sx2_0")

    self.Text_sx2_0:setString(g_tr("armyFightForce"))
    self.Text_sx1:setString(g_tr("rank"))
    self.Text_sx2:setString(g_tr("rankName"))

    self.ListView_1 = self.root:getChildByName("ListView_1")
end

function RankView:addEvent()
    local function proClick(sender , eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_h1 then
                if self.curTab ~= g_Consts.RankType.alliencePower then
                    self.curTab = g_Consts.RankType.alliencePower
                    self:setTabHightlight(self.curTab)
                    self.mode:getRank(5, self.getData)
                    self.Text_sx2_0:setString(g_tr("armyFightForce"))
                end
            elseif sender == self.Button_h2 then
                if self.curTab ~= g_Consts.RankType.allienceEnemyDie then
                    self.curTab = g_Consts.RankType.allienceEnemyDie
                    self:setTabHightlight(self.curTab)
                    self.mode:getRank(6, self.getData)
                    self.Text_sx2_0:setString(g_tr("killNum"))
                end
            elseif sender == self.Button_h3 then
                if self.curTab ~= g_Consts.RankType.power then
                    self.curTab = g_Consts.RankType.power
                    self:setTabHightlight(self.curTab)
                    self.mode:getRank(1, self.getData)
                     self.Text_sx2_0:setString(g_tr("armyFightForce"))
                end
            elseif sender == self.Button_h4 then
                if self.curTab ~= g_Consts.RankType.enemyDie then
                    self.curTab = g_Consts.RankType.enemyDie
                    self:setTabHightlight(self.curTab)
                    self.mode:getRank(3, self.getData)
                    self.Text_sx2_0:setString(g_tr("killNum"))
                end
            elseif sender == self.Button_h5 then
                if self.curTab ~= g_Consts.RankType.house then
                    self.curTab = g_Consts.RankType.house
                    self:setTabHightlight(self.curTab)
                    self.mode:getRank(4, self.getData)
                    self.Text_sx2_0:setString(g_tr("houseLevel"))
                end
            elseif sender == self.Button_h6 then
                if self.curTab ~= g_Consts.RankType.level then
                    self.curTab = g_Consts.RankType.level
                    self:setTabHightlight(self.curTab)
                    self.mode:getRank(2, self.getData)
                    self.Text_sx2_0:setString(g_tr("playerLevel"))
                end
            elseif sender == self.Button_x then
                self:close()
            end
        end
    end 

    for i=1, 6 do
        self["Button_h"..i]:addTouchEventListener(proClick)
    end
    self.Button_x:addTouchEventListener(proClick)
end

function RankView:setData()
    self.ListView_1:removeAllItems()
    
    for i=1, #self.data do
        self.uiList[i] = require("game.uilayer.rank.RankItemView").new()
        self.ListView_1:pushBackCustomItem(self.uiList[i])

        self.uiList[i]:show(self.data[i], self.curTab, self.showPlayerInfo)
    end

    self.ListView_1:jumpToTop()
end

function RankView:setTabHightlight(index)
    for i=1, 6 do
        self["Button_h"..i]:setBrightStyle(BRIGHT_NORMAL)
    end

    self["Button_h"..index]:setBrightStyle(BRIGHT_HIGHLIGHT)
end

return RankView

--endregion
