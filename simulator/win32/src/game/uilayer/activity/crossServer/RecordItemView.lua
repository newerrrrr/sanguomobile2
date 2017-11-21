local RecordItemView = class("RecordItemView", require("game.uilayer.base.BaseWidget"))

function RecordItemView:ctor(data)
	self.layer = self:LoadUI("activity3_popup2_list1.csb")

	self.Image_1 = self.layer:getChildByName("Image_1")

	for i=1, 5 do
		self["Text_"..i] = self.layer:getChildByName("Text_"..i)
	end

	self.Image_2 = self.layer:getChildByName("Image_2")
	self.Image_2_0 = self.layer:getChildByName("Image_2_0")

	self.Text_1:setString(g_tr("round1"))
	self.Text_2:setString(data.joined_round_id.."")
	self.Text_3:setString(g_tr("round2"))

	if data.target_guild_id == 0 then
		self.Image_1:setVisible(false)
		self.Image_2_0:setVisible(false)
		self.Text_4:setString("")
		self.Text_5:setString(g_tr("noEnemyFight"))
	else
		self.Image_1:loadTexture(g_data.sprite[g_data.alliance_flag[data.target_guild_icon_id].res_flag].path)
		self.Text_4:setString("("..self:getServicId(data.target_guild_id)..")")
		self.Text_5:setString(data.target_guild_name)

		if data.is_win == 1 then
			self.Image_2_0:setVisible(false)
		else
			self.Image_2:setVisible(false)
		end
	end
end

function RecordItemView:getServicId(guidId)
	return "S"..string.sub(guidId,1,string.len(guidId)-6)..""
end

return RecordItemView