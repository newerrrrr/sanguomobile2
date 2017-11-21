
--充值达到5000 tips提示一次

local ChargeTipOnce = class("ChargeTipOnce",require("game.uilayer.base.BaseLayer"))


function ChargeTipOnce:ctor()
    ChargeTipOnce.super.ctor(self)

    print("ChargeTipOnce") 

    local uiLayer =  g_gameTools.LoadCocosUI("CityBattle_panel_zhugong1.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")

    baseNode:getChildByName("Text_nr"):setString(g_tr("rmbChargeTips"))

    local btnClose = baseNode:getChildByName("Button_jr")
    btnClose:getChildByName("Text_2"):setString(g_tr("confirm"))
    self:regBtnCallback(btnClose, handler(self, self.close)) 
end





function ChargeTipOnce:check()
    local data = g_PlayerMode.GetData() 
    if nil == data then return end 

    if g_guideManager.getLastShowStep() then return end --有新手引导时不显示

    local key = "rmb_charge_tip_once_"..data.id 
    if nil == g_saveCache[key] then 
        g_saveCache[key] = 0 
    end 
    
    if data.total_rmb >= 5000 and g_saveCache[key] == 0 then 
        g_saveCache[key] = 1 
        g_sceneManager.addNodeForUI(ChargeTipOnce:create())  
    end 
end 



return ChargeTipOnce

