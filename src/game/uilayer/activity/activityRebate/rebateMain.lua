local rebateMain = class("rebateMain", require("game.uilayer.base.BaseLayer"))

function rebateMain:ctor()
   rebateMain.super.ctor(self)
end

function rebateMain:onEnter()
    self:_InitUI()
end

function rebateMain:_InitUI()
    self.layer = cc.CSLoader:createNode("activity4_mian7.csb")
    self:addChild(self.layer)

    self.layer:getChildByName("Panel_nr"):getChildByName("Text_n1"):setString(g_tr("rebateDesc"))
    self.layer:getChildByName("Panel_renw"):getChildByName("Image_13"):loadTexture(g_resManager.getResPath( g_data.general[2003001].general_big_icon ))
    
    --2003001
    local getDiamondBtn = self.layer:getChildByName("Button_qwcz")
    getDiamondBtn:getChildByName("Text_1"):setString(g_tr("first_pay_pay_now"))
    getDiamondBtn:addClickEventListener(function ()
        --print("充值")
        g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyView").new())
    end)

end



return rebateMain
