local RankGroupItemView = class("RankGroupItemView", require("game.uilayer.base.BaseWidget"))

function RankGroupItemView:ctor(data1, data2)
	self.data1 = data1
	self.data2 = data2

	self.layer = self:LoadUI("ranking_panel_check_list2.csb")

	for i=1, 2 do
		self["root_"..i] = self.layer:getChildByName("scale_node"..i)
		self["root_"..i.."_Image_lm1"] = self["root_"..i]:getChildByName("Image_lm1")
		self["root_"..i.."_Text_lm1"] = self["root_"..i]:getChildByName("Text_lm1")
		self["root_"..i.."_Image_s1"] = self["root_"..i]:getChildByName("Image_s1")
		self["root_"..i.."_Image_s2"] = self["root_"..i]:getChildByName("Image_s2")
		self["root_"..i.."_Image_lm2"] = self["root_"..i]:getChildByName("Image_lm2")
		self["root_"..i.."_Text_lm2"] = self["root_"..i]:getChildByName("Text_lm2")
		self["root_"..i.."_Image_s3"] = self["root_"..i]:getChildByName("Image_s3")
		self["root_"..i.."_Image_s4"] = self["root_"..i]:getChildByName("Image_s4")
	end

	self:setData("root_1", self.data1)
	self:setData("root_2", self.data2)
end

function RankGroupItemView:setData(ui, data)
	if data == nil then
		self[ui..""]:setVisible(false)
		return
	end

	self[ui.."_Image_lm1"]:setVisible(data.guild_1_icon_id > 0)
	self[ui.."_Text_lm1"]:setVisible(data.guild_1_icon_id > 0)
	if data.guild_1_icon_id > 0 then 
		self[ui.."_Image_lm1"]:loadTexture(g_data.sprite[g_data.alliance_flag[data.guild_1_icon_id].res_flag].path)
		self[ui.."_Text_lm1"]:setString(data.guild_1_name)
	end 

	self[ui.."_Image_lm2"]:setVisible(data.guild_2_icon_id > 0)
	self[ui.."_Text_lm2"]:setVisible(data.guild_2_icon_id > 0)
	if data.guild_2_icon_id > 0 then 
		self[ui.."_Image_lm2"]:loadTexture(g_data.sprite[g_data.alliance_flag[data.guild_2_icon_id].res_flag].path)
		self[ui.."_Text_lm2"]:setString(data.guild_2_name)
	end 

	if data.win == 1 then
		self[ui.."_Image_s1"]:setVisible(true)
		self[ui.."_Image_s2"]:setVisible(false)
		self[ui.."_Image_s3"]:setVisible(false)
		self[ui.."_Image_s4"]:setVisible(true)
	else
		self[ui.."_Image_s1"]:setVisible(false)
		self[ui.."_Image_s2"]:setVisible(true)
		self[ui.."_Image_s3"]:setVisible(true)
		self[ui.."_Image_s4"]:setVisible(false)
	end
end

return RankGroupItemView