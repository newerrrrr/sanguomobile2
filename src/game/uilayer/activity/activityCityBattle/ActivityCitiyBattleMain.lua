local ActivityCitiyBattleMain = class("ActivityCitiyBattleMain", require("game.uilayer.base.BaseLayer"))
local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode")

function ActivityCitiyBattleMain:ctor()
    ActivityCitiyBattleMain.super.ctor(self)
    self:_InitUI()
end

function ActivityCitiyBattleMain:_InitUI()
    self.layer = cc.CSLoader:createNode("CityBattle_main1.csb")
    self:addChild(self.layer)

    local gotoBtn = self.layer:getChildByName("Button_1")
    gotoBtn:addClickEventListener(function (sender)
        if self.openTime and (self.openTime - g_clock.getCurServerTime()) <= 0 then
            local view = require("game.uilayer.cityBattle.CityMap"):create()
            g_sceneManager.addNodeForUI(view)
            g_guideManager.removeGameFeature(g_guideManager.gameFeatures.ACTIVITY)
        else
            g_airBox.show( g_tr("city_battle_noopen_str") )
        end
    end)
    --city_battle_activity_gotobattle
    gotoBtn:getChildByName("Text_5"):setString(g_tr("city_battle_activity_gotobattle"))

    local descTx = self.layer:getChildByName("Text_1_0")
    descTx:setString(g_tr("city_battle_activity_desc"))

    local mapBtn = self.layer:getChildByName("Image_dt")
    mapBtn:getChildByName("Text_2"):setString(g_tr("city_battle_reference"))
    mapBtn:addClickEventListener(function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local view = require("game.uilayer.activity.activityCityBattle.ReferenceMap"):create()
        g_sceneManager.addNodeForUI(view)
    end)

    self.layer:getChildByName("Button_wenh"):addClickEventListener(function ()
        require("game.uilayer.common.HelpInfoBox"):show(53)
    end)

    self.timer = self:schedule( handler(self,self._UpdateTime),1 )
    self.descTx = self.layer:getChildByName("Text_djs1")
    self.descTx:setString(g_tr("backTime") .. ":" )
    self.descTx:setVisible(false)
    self.timeTx = self.layer:getChildByName("Text_djs1_0")
    self.timeTx:setString( g_gameTools.convertSecondToString(0) )
    self.timeTx:setVisible(false)
    self:_UpdateTime()
end

function ActivityCitiyBattleMain:_UpdateTime()
    
    if self.openTime == nil then
        self.openTime = CityBattleMode:GetOpenTime()
        return
    end 

    if self.openTime then
        local time = self.openTime - g_clock.getCurServerTime()
        if time <= 0 then
            self.descTx:setVisible(false)
            self.timeTx:setVisible(false)
        else
            self.descTx:setVisible(true)
            self.timeTx:setVisible(true)
            self.timeTx:setString( g_gameTools.convertSecondToString(time) )
        end
    end
end

return ActivityCitiyBattleMain
