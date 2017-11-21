local RankCrossItemView = class("RankCrossItemView", require("game.uilayer.base.BaseWidget"))

function RankCrossItemView:ctor(data)
	self.data = data

	self.layer = self:LoadUI("ranking_panel_check_list1.csb")

	self.root = self.layer:getChildByName("scale_node")
	self.Text_shuzi1 = self.root:getChildByName("Text_shuzi1")
	self.Image_shuz1 = self.root:getChildByName("Image_shuz1")
	self.Image_shuz2 = self.root:getChildByName("Image_shuz2")
	self.Image_shuz3 = self.root:getChildByName("Image_shuz3")
	self.Image_2 = self.root:getChildByName("Image_2")
	self.Text_3 = self.root:getChildByName("Text_3")
	self.Text_4 = self.root:getChildByName("Text_4")
	self.Text_4_0 = self.root:getChildByName("Text_4_0")

	self.Text_shuzi1:setString(self.data.rank.."")
	if self.data.rank == 1 then
		self.Image_shuz1:setVisible(true)
		self.Image_shuz2:setVisible(false)
		self.Image_shuz3:setVisible(false)
	elseif self.data.rank == 2 then
		self.Image_shuz1:setVisible(false)
		self.Image_shuz2:setVisible(true)
		self.Image_shuz3:setVisible(false)
	elseif self.data.rank == 3 then
		self.Image_shuz1:setVisible(false)
		self.Image_shuz2:setVisible(false)
		self.Image_shuz3:setVisible(true)
	else
		self.Image_shuz1:setVisible(false)
		self.Image_shuz2:setVisible(false)
		self.Image_shuz3:setVisible(false)
	end
	self.Text_3:setString(self.data.guild_name)
	self.Text_4:setString(self.data.nick)
	self.Text_4_0:setString(self.data.kill_soldier.."")

	local iconid = g_data.res_head[tonumber(self.data.avatar_id)].head_icon
    self.Image_2:loadTexture(g_resManager.getResPath(iconid))

    local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
	self.Image_2:addChild(imgFrame)
	imgFrame:setPosition(cc.p(self.Image_2:getContentSize().width/2, self.Image_2:getContentSize().height/2))
end

return RankCrossItemView