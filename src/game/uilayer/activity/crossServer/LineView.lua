local LineView = class("LineView", require("game.uilayer.base.BaseLayer"))

function LineView:ctor()
	LineView.super.ctor(self)

	self.layer = self:loadUI("guildwar_fuhuodian_xin02.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.close_btn = self.root:getChildByName("close_btn")
	self.root:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("battleDemo"))

	self.panel_1_button_1 = self.root:getChildByName("Panel_1"):getChildByName("Button_1")
	self.panel_1_button_2 = self.root:getChildByName("Panel_1"):getChildByName("Button_2")
	self.panel_1_button_1:getChildByName("Text_1"):setString(g_tr("lineVal", {val = g_tr("num1")}))
	self.panel_1_button_2:getChildByName("Text_1"):setString(g_tr("lineVal", {val = g_tr("num2")}))

	self.panel_2_button_1 = self.root:getChildByName("Panel_2"):getChildByName("Button_1")
	self.panel_2_button_2 = self.root:getChildByName("Panel_2"):getChildByName("Button_2")
	self.panel_2_button_1:getChildByName("Text_1"):setString(g_tr("lineVal", {val = g_tr("num1")}))
	self.panel_2_button_2:getChildByName("Text_1"):setString(g_tr("lineVal", {val = g_tr("num2")}))

	self:addEvent()
end

function LineView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.panel_1_button_1 then
				g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.AnimationView").new("JingGongA"))
			elseif sender == self.panel_1_button_2 then
				g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.AnimationView").new("JingGongB"))
			elseif sender == self.panel_2_button_1 then
				g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.AnimationView").new("FangShouA"))
			elseif sender == self.panel_2_button_2 then
				g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.AnimationView").new("FangShouB"))
			elseif sender == self.close_btn then
				self:close()
			end
		end
	end

	self.panel_1_button_1:addTouchEventListener(proClick)
	self.panel_1_button_2:addTouchEventListener(proClick)
	self.panel_2_button_1:addTouchEventListener(proClick)
	self.panel_2_button_2:addTouchEventListener(proClick)
	self.close_btn:addTouchEventListener(proClick)
end

return LineView