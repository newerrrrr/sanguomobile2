local ActBannerItemView = class("ActBannerItemView", require("game.uilayer.base.BaseWidget"))

function ActBannerItemView:ctor()
	self.layer = self:LoadUI("MoonCake_list1.csb")

	self.Image_1 = self.layer:getChildByName("Image_1")

	self:addEvent()
end

function ActBannerItemView:show(data)
	self.data = data
	local aData = g_data.activity[self.data]
	self.Image_1:loadTexture(g_resManager.getResPath(aData.banner_show))
end

function ActBannerItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Image_1 then
				g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

				local aci = 0
				if self.data == 1006 or self.data == 1020 then
					for key, value in pairs(g_data.activity_commodity) do
						if value.activity_id == self.data then
							if self.data == 1006 then
								if value.id == 126 then
									aci = 126
								else
									aci = 125
								end
								break
							else
								aci = 125
								break
							end
						end
					end

					print(aci, "@@@@@@@@@@@@@@@@@@@@")
					local view  = require("game.uilayer.activity.activityMoney.ActivityMoneyView").new(nil, aci)
  					g_sceneManager.addNodeForUI(view)
				else
					  require("game.uilayer.activity.ActivityMainLayer").show(self.data, 2)
				end
			end
		end
	end

	self.Image_1:addTouchEventListener(proClick)
end

return ActBannerItemView