local BattleDamageInfoItemView = class("BattleDamageInfoItemView", require("game.uilayer.base.BaseWidget"))

function BattleDamageInfoItemView:ctor(data, max)
	self.data = data
	self.max = max

	self.layer = self:LoadUI("mail_battle_content_damage_item.csb")
	self.root = self.layer:getChildByName("item")

	self.Image_t1 = self.root:getChildByName("Image_t1")
	self.label1 = self.root:getChildByName("label1")
	self.Image_t2 = self.root:getChildByName("Image_t2")
	self.label2 = self.root:getChildByName("label2")
	self.Text_4 = self.root:getChildByName("Text_4")
	self.LoadingBar_1 = self.root:getChildByName("LoadingBar_1")
	self.Text_5 = self.root:getChildByName("Text_5")
	self.LoadingBar_2 = self.root:getChildByName("LoadingBar_2")

	self:setData()
end

function BattleDamageInfoItemView:setData()
	self.Text_4:setString(self.data.doDamage.."")
	self.Text_5:setString(self.data.takeDamage.."")

	if self.data.general_id > 0 then
		local item = self:createHeroHead(self.data.general_id*100+1)
    	item:setPosition(self.Image_t1:getContentSize().width/2, self.Image_t1:getContentSize().height/2)
      --显示星级
      if self.data.general_star then  
        item:showGeneralServerStarLv(self.data.general_star)
      end 
    	self.Image_t1:addChild(item)
   		self.label1:setString(item:getName())
	else
		self.label1:setString("")
	end

   	local item = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.Soldier,tonumber(self.data.soldier_id),1)
   	item:setPosition(self.Image_t1:getContentSize().width/2, self.Image_t1:getContentSize().height/2)
    self.Image_t2:addChild(item)
   	self.label2:setString(item:getName())
   	item:setCountEnabled(false)

	if self.max == 0 then
		self.LoadingBar_1:setPercent(0)
		self.LoadingBar_2:setPercent(0)
	else
		local value = self.data.doDamage*100/self.max
		value = value - value%1
		self.LoadingBar_1:setPercent(value)

		value = self.data.takeDamage*100/self.max
		value = value - value%1
		self.LoadingBar_2:setPercent(value)
	end
end

function BattleDamageInfoItemView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

return BattleDamageInfoItemView