local PrepareItemView = class("PrepareItemView", require("game.uilayer.base.BaseWidget"))

function PrepareItemView:ctor()
	self.layer = self:LoadUI("yby02.csb")

	for i=1, 2 do
		self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Image_1"] = self["Panel_"..i]:getChildByName("Image_1")
		self["Panel_"..i.."_Image_3"] = self["Panel_"..i]:getChildByName("Image_3")
		self["Panel_"..i.."_Text_1"] = self["Panel_"..i]:getChildByName("Text_1")
		self["Panel_"..i.."_Text_2"] = self["Panel_"..i]:getChildByName("Text_2")
	end
end

function PrepareItemView:show(data1, data2)
	self.data1 = data1
	self.data2 = data2

	self:processData("Panel_1", self.data1)
	self:processData("Panel_2", self.data2)
end

function PrepareItemView:processData(ui, data)
	if data == nil then
		self[ui]:setVisible(false)
		return
	end

	local sData = g_data.soldier[data.soldier_id]
	self[ui.."_Image_1"]:loadTexture(g_resManager.getResPath(sData.img_portrait))
	self[ui.."_Image_3"]:loadTexture(g_resManager.getResPath(sData.img_type))
	self[ui.."_Text_1"]:setString(g_tr(sData.soldier_name))
	self[ui.."_Text_2"]:setString(data.num.."")
end

return PrepareItemView