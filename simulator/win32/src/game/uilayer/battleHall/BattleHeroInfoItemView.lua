local BattleHeroInfoItemView = class("BattleHeroInfoItemView", require("game.uilayer.base.BaseWidget"))

function BattleHeroInfoItemView:ctor(data, type)
	print("@@@BattleHeroInfoItemView")
	self.data = data

	self.type = type

	self.layer = self:LoadUI("HistoryReport_ReportDetails_battle_content_1.csb")
	self.root = self.layer:getChildByName("Panel_1")
	self.pic_general = self.root:getChildByName("pic_general")
	self.name_general = self.root:getChildByName("name_general")
	self.pic_general_0 = self.root:getChildByName("pic_general_0")
	self.name_general_0 = self.root:getChildByName("name_general_0")
	self.name_wenb = self.root:getChildByName("name_wenb")

	for i=1, 4 do
		self["label_"..i] = self.root:getChildByName("label_"..i)
	end

	if self.data.revive_num then
		self.name_wenb:setString(g_tr("getOtherArmy", {num = self.data.revive_num}))
	else
		self.name_wenb:setString(g_tr("getOtherArmy", {num = 0}))
	end
	

	self:setData()
end

function BattleHeroInfoItemView:setData()
	if self.type == "trap" then
		local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Trap, self.data.soldier_id, 1)
        self.pic_general:addChild(item)
        item:setPosition(self.pic_general:getContentSize().width/2, self.pic_general:getContentSize().height/2)
        item:setCountEnabled(false)
        
        local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
        self.pic_general:addChild(imgFrame)
        imgFrame:setPosition(cc.p(self.pic_general:getContentSize().width/2, self.pic_general:getContentSize().height/2))
        self.name_general:setString(g_tr(g_data.trap[self.data.soldier_id].trap_name))
        self.pic_general_0:setVisible(false)
        self.name_general_0:setString("")
	else
		if self.type == "npc" then
			self.name_general:setString("")
		else
			dump(self.data)
			if self.data.general_id == 0 then
				self.pic_general:removeAllChildren()
				self.name_general:setString("")
			else
				local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, self.data.general_id*100+1, 1)
				item:setPosition(self.pic_general:getContentSize().width/2, self.pic_general:getContentSize().height/2)
				item:setCountEnabled(false)

				--显示星级
				if self.data.general_star then  
					item:showGeneralServerStarLv(self.data.general_star)
				end  				
				self.pic_general:addChild(item)
				self.name_general:setString(item:getName())
			end
			
		end

		local item1 = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Soldier, tonumber(self.data.soldier_id), 1)
	    item1:setPosition(self.pic_general_0:getContentSize().width/2, self.pic_general_0:getContentSize().height/2)
	   	self.pic_general_0:addChild(item1)
		self.name_general_0:setString(item1:getName())
		item1:setCountEnabled(false)
	end

	self["label_1"]:setString(g_tr("survive%{val}", {val=self.data.live_num}))
	self["label_2"]:setString(g_tr("damage%{val}", {val=self.data.injure_num}))
	self["label_3"]:setString(g_tr("kill%{val}", {val=self.data.kill_num}))
	self["label_4"]:setString(g_tr("killed%{val}", {val=self.data.killed_num}))
end

return BattleHeroInfoItemView