local RoundChangeItemView = class("RoundChangeItemView", require("game.uilayer.base.BaseWidget"))

function RoundChangeItemView:ctor(data1, data2, rank)
	self.layer = self:LoadUI("guildwar_main1_list1.csb")

	self.Text_1 = self.layer:getChildByName("Text_1")

	self.Text_1:setString("")

	for i=1, 2 do
		self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Text_sz"] = self["Panel_"..i]:getChildByName("Text_sz")
		self["Panel_"..i.."_Text_3"] = self["Panel_"..i]:getChildByName("Text_3")
		self["Panel_"..i.."_Text_name"] = self["Panel_"..i]:getChildByName("Text_name")
		self["Panel_"..i.."_Image_5"] = self["Panel_"..i]:getChildByName("Image_5")
		self["Panel_"..i.."_Image_5_0"] = self["Panel_"..i]:getChildByName("Image_5_0")
		self["Panel_"..i.."_Text_sz"]:setString(rank.."")
	end

	self:setData(data1, "Panel_1")
	self:setData(data2, "Panel_2")
end

function RoundChangeItemView:setData(data, ui)
	if data == nil then
		self[ui]:setVisible(false)
		return
	end

	self[ui.."_Text_3"]:setString(data.kill_soldier)
	self[ui.."_Text_name"]:setString(data.nick)
	local iconid = g_data.res_head[tonumber(data.avatar_id)].head_icon
    self[ui.."_Image_5_0"]:loadTexture(g_resManager.getResPath(iconid))

    local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
	self[ui.."_Image_5_0"]:addChild(imgFrame)
	imgFrame:setPosition(cc.p(self[ui.."_Image_5_0"]:getContentSize().width/2, self[ui.."_Image_5_0"]:getContentSize().height/2))
end

return RoundChangeItemView