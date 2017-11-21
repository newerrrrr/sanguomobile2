local TopTitleRes = class("TopTitleRes")

function TopTitleRes:ctor(parent_ui_widget, res1)
	self.res = res1

	local scale_node = parent_ui_widget:getChildByName("scale_node")

	if scale_node then
		local size = scale_node:getContentSize()
		self.widget = cc.CSLoader:createNode("Resources_1.csb")
		self.widget:ignoreAnchorPointForPosition(false)
		self.widget:setAnchorPoint(cc.p(1.0,0.0))
		self.widget:setPosition(cc.p(size.width * 0.5 + 632, size.height * 0.5 + 302))
		scale_node:addChild(self.widget)

		self:update()

		local panel = self.widget:getChildByName("Panel_yuanbao")
		panel:setVisible(false)
	end
end

function TopTitleRes:update()
	if self.widget ~= nil then
		for i=1, 5 do
			local panel =  self.widget:getChildByName("Panel_m"..i)
			if i <= #self.res then
				local count, icon = g_gameTools.getPlayerCurrencyCount(self.res[i])
				if self.res[i] == g_Consts.AllCurrencyType.Gem then
					panel:getChildByName("Text_1"):setString(count.."")
				else
					panel:getChildByName("Text_1"):setString(string.formatnumberlogogram(tonumber(count)))
				end
				panel:getChildByName("Image_1"):loadTexture(icon)
			else
				panel:setVisible(false)
			end
		end
	end
end

function TopTitleRes:getTopRes()
	return self.widget 
end 

return TopTitleRes