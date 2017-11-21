--region GodGarrisonMainLayer
--Author : liuyi
--Date   : 2016/10/28
--此文件由[BabeLua]插件自动生成
local GodGeneralMainLayer = class("GodGeneralMainLayer",require("game.uilayer.base.BaseLayer"))

function GodGeneralMainLayer:ctor(selTab)
    GodGeneralMainLayer.super.ctor(self)
    self.selTabBtn = selTab
    self.tabBtnList = {}
    self:initUI()
end

function GodGeneralMainLayer:onEnter()
    
end

function GodGeneralMainLayer:initUI()
    self.layer = self:loadUI("GodGenerals_Panel.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("Button_6")
    self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    local selTab = nil

    local function touchBtn( sender,evenType )
        if evenType == ccui.TouchEventType.ended then
            self:setBtnTouch(sender)
        end
    end
    
    --zhcn
    self.root:getChildByName("Text_2"):setString(g_tr("godGarrisonTitle"))
    --化神
    self.godBtn = self.root:getChildByName("Button_01")
    self.godBtn:addTouchEventListener(touchBtn)
    self.godBtn.call = handler(self,self.createGod)
    self.godBtn:getChildByName("Text_1"):setString(g_tr("godGarrisonGod"))
    self.godBtn:setVisible(false)
    --强化
    self.plusBtn = self.root:getChildByName("Button_02")
    self.plusBtn:addTouchEventListener(touchBtn)
    self.plusBtn.call = handler(self,self.createPlus)
    self.plusBtn:getChildByName("Text_1"):setString(g_tr("godGarrisonPlus"))
    self.plusBtn:setVisible(false)
    --升星
    self.starBtn = self.root:getChildByName("Button_03")
    self.starBtn:addTouchEventListener(touchBtn)
    self.starBtn.call = handler(self,self.createStar)
    self.starBtn:getChildByName("Text_1"):setString(g_tr("godGarrisonStar"))
    self.starBtn:setVisible(false)

    self.tabBtnList = 
    {
        self.godBtn,
        self.plusBtn,
        self.starBtn,
    }

    selTab = self.tabBtnList[self.selTabBtn or 1]
    self:setBtnTouch(selTab)
end

function GodGeneralMainLayer:createGod()
    if self.godPanel == nil then
        self.godPanel = require("game.uilayer.godGeneral.GodGeneralGodLayer"):create()
        self:addChild(self.godPanel)
    end
    if self.godPanel then self.godPanel:setVisible(true) end
    if self.pluePanel then self.pluePanel:setVisible(false) end
    if self.starPanel then self.starPanel:setVisible(false) end
end

function GodGeneralMainLayer:createPlus()
    --[[if self.pluePanel == nil then
        self.pluePanel = require("game.uilayer.godGeneral.GodGeneralPlusLayer"):create()
        self:addChild(self.pluePanel)
    end
    if self.godPanel then self.godPanel:setVisible(false) end
    if self.pluePanel then self.pluePanel:setVisible(true) end
    if self.starPanel then self.starPanel:setVisible(false) end]]

    g_sceneManager.addNodeForUI(require("game.uilayer.godGeneral.GodGeneralPlusLayer"):create())
end

function GodGeneralMainLayer:createStar()
    if self.starPanel == nil then
        self.starPanel = require("game.uilayer.godGeneral.GodGeneralStarLayer"):create()
        self:addChild(self.starPanel)
    end
    if self.godPanel then self.godPanel:setVisible(false) end
    if self.pluePanel then self.pluePanel:setVisible(false) end
    if self.starPanel then self.starPanel:setVisible(true) end
end


function GodGeneralMainLayer:onExit()

end

function GodGeneralMainLayer:setBtnTouch(btn)
    
    for _, tabBtn in ipairs(self.tabBtnList) do
        tabBtn:setEnabled(true)
    end
    
    if btn then
        btn:setEnabled(false)
        if btn.call then
            btn.call()
        end
    end
end

return GodGeneralMainLayer

--endregion
