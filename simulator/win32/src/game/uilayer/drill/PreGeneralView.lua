local PreGeneralView = class("PreGeneralView", require("game.uilayer.base.BaseWidget"))

function PreGeneralView:ctor(general)
	self.layer = self:LoadUI("guildwar_junt1_list1.csb")

	local data = g_GeneralMode.GetBasicInfo(general, 1)

	self.Image_1 = self.layer:getChildByName("Image_1")
	self.Image_2 = self.layer:getChildByName("Image_2")
	self.Text_1 =self.layer:getChildByName("Text_1")

	self.Text_1:setString(g_tr(data.general_name))

	local item = self:createHeroHead(general*100+1)
    item:setPosition(self.Image_2:getContentSize().width/2, self.Image_2:getContentSize().height/2)
    self.Image_2:addChild(item)

    if data.general_quality == 6 then
    	self.Image_1:setVisible(false)
    end
end

function PreGeneralView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

return PreGeneralView