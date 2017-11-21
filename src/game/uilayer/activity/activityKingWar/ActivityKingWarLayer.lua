--region ActivityKingWarLayer.lua
--Author : liuyi
--Date   : 2016/10/27
--此文件由[BabeLua]插件自动生成
local ActivityKingWarLayer = class("ActivityKingWarLayer", require("game.uilayer.base.BaseLayer"))

function ActivityKingWarLayer:ctor()
    ActivityKingWarLayer.super.ctor(self)
    self:initUI()
end

function ActivityKingWarLayer:initUI()
    self.layer = cc.CSLoader:createNode("TheWar_main1.csb")
    self:addChild(self.layer)
    local openTimeTx = self.layer:getChildByName("Text_2")

    local function timeFun()
        self.layer:getChildByName("Text_2_0"):setVisible(true)
        if g_kingInfo.isKingBattleStarted() then
            self.layer:getChildByName("Text_2_0"):setVisible(false)
            openTimeTx:setString(g_tr("kwar_Opening"))
            return
        end
        openTimeTx:setString(g_gameTools.convertSecondToString(g_kingInfo.kingBattleSoonTime()))    
    end

    self:schedule( timeFun,1 )

    timeFun()

    --zhcn
    self.layer:getChildByName("Text_mc"):setString(g_tr("kingGifts"))
    self.layer:getChildByName("Text_4"):setString(g_tr("successiveKings"))
    self.layer:getChildByName("Text_2_0"):setString(g_tr("kingStart"))

    self.layer:getChildByName("Panel_renwu"):loadTexture( g_resManager.getResPath(1030143) )

    local btn = self.layer:getChildByName("Button_1")
    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingInfoLayer"):create())
        end
    end)

    self.layer:getChildByName("Text_3"):setString(g_tr( 140024 ))
    local mode = self.layer:getChildByName("Text_3_0")
    local rich = g_gameTools.createRichText(mode,g_tr( 140025 ))

    
end

function ActivityKingWarLayer:onEnter()
   

end


return ActivityKingWarLayer


--endregion
