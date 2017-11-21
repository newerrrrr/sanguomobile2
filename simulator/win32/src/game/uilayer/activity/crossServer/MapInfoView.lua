local MapInfoView = class("MapInfoView", require("game.uilayer.base.BaseLayer"))

local wordSize = 24
local offSet = 180

function MapInfoView:ctor()
	MapInfoView.super.ctor(self)

	self.layer = self:loadUI("guildwar_fuhuodian_xin01.csb")
	self.root = self.layer:getChildByName("scale_node")
    self.Button_ys = self.root:getChildByName("Button_ys")
    self.Button_ys:getChildByName("Text_3"):setString(g_tr("battleDemo"))
    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_2_0 = self.root:getChildByName("Text_2_0")
    self.Text_2_0:setString("")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1:setString(g_tr("MasterInfo"))

    for i=1, 5 do
        self.root:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Text_1"):setString(g_tr("guild_war_area_name_"..i))
    end

    for i=1, 7 do
        self.root:getChildByName("Panel_tis"):getChildByName("Panel_"..i):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc"..i))
    end

    self:addEvent()
end

function MapInfoView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_ys then
                g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.LineView").new())
            elseif sender == self.close_btn then
                self:close()
            end
        end
    end
    self.Button_ys:addTouchEventListener(proClick)
    self.close_btn:addTouchEventListener(proClick)
end

return MapInfoView