local BannerItemView = class("BannerItemView", require("game.uilayer.base.BaseWidget"))

function BannerItemView:ctor(len)
	

	if len == nil then
		self.lenth = 5
		self.layer = self:LoadUI("AdvertisingGifts_list2.csb")
	else
		self.lenth = len
		self.layer = self:LoadUI("AdvertisingGifts_list4.csb")
	end

	for i=1, self.lenth do
		self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Image_2_1"] = self["Panel_"..i]:getChildByName("Image_2_1")
		self["Panel_"..i.."_Image_2_0"] = self["Panel_"..i]:getChildByName("Image_2_0")
		self["Panel_"..i.."_Image_2"] = self["Panel_"..i]:getChildByName("Image_2")
		self["Panel_"..i.."_Image_bq"] = self["Panel_"..i]:getChildByName("Image_bq")
		self["Panel_"..i.."_Text_2"] = self["Panel_"..i.."_Image_bq"]:getChildByName("Text_2")
		self["Panel_"..i.."_Text_1"] = self["Panel_"..i]:getChildByName("Text_1")
	end
end

function  BannerItemView:show(data1, data2, data3, data4, data5, data6)
	-- body
	self.data1 = data1
	self.data2 = data2
	self.data3 = data3
	self.data4 = data4
	self.data5 = data5
	self.data6 = data6

	for i=1, self.lenth do
		self:processData("Panel_"..i, self["data"..i])
	end
end

function BannerItemView:processData(ui, data)
	if data == nil then
		self[ui]:setVisible(false)
		return
	end

	local icon = require("game.uilayer.common.DropItemView").new(data[1], data[2], data[3])
	if tonumber(data[2]) == 10700 then
		icon:setCountEnabled(true)
	else
		icon:setCountEnabled(false)
	end
	if data[1] == 1 or data[3] == 1 then
		self[ui.."_Image_bq"]:setVisible(false)
		self[ui.."_Image_2_1"]:setVisible(false)
		self[ui.."_Image_2"]:setVisible(false)
		self[ui.."_Image_2_0"]:addChild(icon)
		icon:setPosition(self[ui.."_Image_2_0"]:getContentSize().width/2, self[ui.."_Image_2_0"]:getContentSize().height/2)
	else
		self[ui.."_Image_bq"]:setVisible(true)
		self[ui.."_Image_2_1"]:setVisible(true)
		self[ui.."_Image_2"]:setVisible(true)
		self[ui.."_Image_2"]:addChild(icon)
		icon:setPosition(self[ui.."_Image_2"]:getContentSize().width/2, self[ui.."_Image_2"]:getContentSize().height/2)
		self[ui.."_Text_2"]:setString(data[3].."")
	end
	self[ui.."_Text_1"]:setString(icon:getName())
end

return BannerItemView