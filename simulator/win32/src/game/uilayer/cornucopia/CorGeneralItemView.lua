local CorGeneralItemView = class("CorGeneralItemView", require("game.uilayer.base.BaseWidget"))

function CorGeneralItemView:ctor()
	self.layer = self:LoadUI("jitian_Panel_0.csb")
	self.root = self.layer:getChildByName("scale_node")

	for i=1, 8 do
		self["Panel_"..i] = self.root:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Image_1"] = self["Panel_"..i]:getChildByName("Image_1")
		self["Panel_"..i.."_Text_1"] = self["Panel_"..i]:getChildByName("Text_1")
	end
end

function CorGeneralItemView:show(data, idx)
	local len = 0
	for i=idx, (idx+7) do
		self:setData(data[i], "Panel_"..((i%8) + 1))
		if data[i] ~= nil then
			len = len + 1
		end
	end
end

function CorGeneralItemView:setData(data, ui)
	if data == nil then
		self[ui]:setVisible(false)
		return
	end
	local item = require("game.uilayer.common.DropItemView").new(data[1], data[2], data[3])
	self[ui.."_Image_1"]:addChild(item)
	item:setPosition(self[ui.."_Image_1"]:getContentSize().width/2, self[ui.."_Image_1"]:getContentSize().height/2)
	self[ui.."_Text_1"]:setString(item:getName())
	item:enableTip()
end

return CorGeneralItemView