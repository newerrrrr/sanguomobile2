local CrossMapView = class("CrossMapView", require("game.uilayer.base.BaseLayer"))

function CrossMapView:ctor()
	CrossMapView.super.ctor(self)

	self.layer = self:loadUI("guildwar_fuhuodian_xin01.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.close_btn = self.root:getChildByName("close_btn")
	self.Text_2_0 = self.root:getChildByName("Text_2_0"):setString(g_tr("lookMap")) 
	--[[
		["guild_war_build_desc1"] = "复活点",
		["guild_war_build_desc2"] = "复活点",
		["guild_war_build_desc3"] = "投石车",
		["guild_war_build_desc4"] = "守方床弩",
		["guild_war_build_desc5"] = "攻方攻城锤",
		["guild_war_build_desc6"] = "攻方云梯",
		["guild_war_build_desc7"] = "城门",
	]]

	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			elseif sender == self.root:getChildByName("Panel_tis"):getChildByName("Panel_2") then
				require("game.uilayer.common.HelpInfoBox"):show(47)
			elseif sender == self.root:getChildByName("Panel_tis"):getChildByName("Panel_3") then
				require("game.uilayer.common.HelpInfoBox"):show(48)
			elseif sender == self.root:getChildByName("Panel_tis"):getChildByName("Panel_4") then
				require("game.uilayer.common.HelpInfoBox"):show(49)
			elseif sender == self.root:getChildByName("Panel_tis"):getChildByName("Panel_5") then
				require("game.uilayer.common.HelpInfoBox"):show(50)
			elseif sender == self.root:getChildByName("Panel_tis"):getChildByName("Panel_6") then
				require("game.uilayer.common.HelpInfoBox"):show(51)
			elseif sender == self.root:getChildByName("Panel_tis"):getChildByName("Panel_7") then
				require("game.uilayer.common.HelpInfoBox"):show(52)
			end
		end
	end

	for i=1, 7 do
		self.root:getChildByName("Panel_tis"):getChildByName("Panel_"..i):getChildByName("Text_2"):setString(g_tr("guild_war_build_desc"..i))
		self.root:getChildByName("Panel_tis"):getChildByName("Panel_"..i):addTouchEventListener(proClick)
	end

	for i=1, 5 do
		self.root:getChildByName("Panel_zu"):getChildByName("Panel_"..i):getChildByName("Text_1"):setString(g_tr("guild_war_area_name_"..i))
	end

	self.close_btn:addTouchEventListener(proClick)

end

return CrossMapView