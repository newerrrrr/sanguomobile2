local ReferenceMap = class("ReferenceMap", require("game.uilayer.base.BaseLayer"))


function ReferenceMap:ctor()
    ReferenceMap.super.ctor(self)
    self:_InitUI()
end

function ReferenceMap:_InitUI()
    self.layer = self:loadUI("CityBattle_main1_xin01.csb")
    self.root = self.layer:getChildByName("scale_node")
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:addClickEventListener(function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
    end)

    local cn = self.root:getChildByName("Panel_cn")
    local panel = cn:getChildByName("Panel_tis")
    panel:getChildByName("Panel_2"):getChildByName("Text_2"):setString(g_tr("city_battle_fightpoint"))
    panel:getChildByName("Panel_3"):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc3"))
    
    local cw = self.root:getChildByName("Panel_cwai")
    local panel = cw:getChildByName("Panel_tis")
    panel:getChildByName("Panel_2"):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc1"))
    panel:getChildByName("Panel_3"):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc3"))
    panel:getChildByName("Panel_5"):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc5"))
    panel:getChildByName("Panel_4"):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc4"))
    panel:getChildByName("Panel_6"):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc6"))
    panel:getChildByName("Panel_7"):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc7"))
    
    cn:setVisible(false)
    local btn1 = self.root:getChildByName("Button_1")
    btn1:getChildByName("Text_4"):setString(g_tr("menu_outcity"))
    local btn2 = self.root:getChildByName("Button_2")
    btn2:getChildByName("Text_4"):setString(g_tr("menu_incity"))
    btn1:setEnabled(false)
    btn1:addClickEventListener(function ()
        btn1:setEnabled(false)
        cn:setVisible(false)
        btn2:setEnabled(true)
        cw:setVisible(true)
    end)
    
    btn2:addClickEventListener(function ()
        btn1:setEnabled(true)
        cn:setVisible(true)
        btn2:setEnabled(false)
        cw:setVisible(false)
    end)
    
end



return ReferenceMap