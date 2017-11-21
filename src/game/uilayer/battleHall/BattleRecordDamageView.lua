local BattleRecordDamageView = class("BattleRecordDamageView", require("game.uilayer.base.BaseWidget"))

function BattleRecordDamageView:ctor()
	
	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_12.csb")
	self.root = self.layer:getChildByName("Panel_1")

	for i=1, 2 do
		self["Panel_info"..i] = self.root:getChildByName("Panel_info"..i)
		self["Panel_info"..i.."_pic_general"] = self["Panel_info"..i]:getChildByName("pic_general")
		self["Panel_info"..i.."_Text_name"] = self["Panel_info"..i]:getChildByName("Text_name")
		self["Panel_info"..i.."_Text_4"] = self["Panel_info"..i]:getChildByName("Text_4")
		self["Panel_info"..i.."_LoadingBar_1"] = self["Panel_info"..i]:getChildByName("LoadingBar_1")
		self["Panel_info"..i.."_Text_5"] = self["Panel_info"..i]:getChildByName("Text_5")
		self["Panel_info"..i.."_LoadingBar_2"] = self["Panel_info"..i]:getChildByName("LoadingBar_2")
		self["Panel_info"..i.."_Button_1"] = self["Panel_info"..i]:getChildByName("Button_1")
		self["Panel_info"..i.."_Text_22"] = self["Panel_info"..i.."_Button_1"]:getChildByName("Text_22")
		self["Panel_info"..i.."_Text_22"]:setString(g_tr("seeDetail"))
	end

	self:addEvent()
end

function BattleRecordDamageView:show(p1, p2, data1, data2, max1, max2)
	self.player1 = p1
	self.player2 = p2
	self.data1 = data1
	self.data2 = data2
	self.max1 = max1
	self.max2 = max2

	self:setData("Panel_info1", self.player1, self.data1, max1)
	self:setData("Panel_info2", self.player2, self.data2, max2)
end

function BattleRecordDamageView:setData(ui, player, data, max)

	if data == nil or player == nil then
		self[ui]:setVisible(false)
		return
	end

	if player.key == "npc" then
		local tem = g_data.huangjin_attack_mob[tonumber(player.aList)]
        iconId = g_data.soldier[tem.type_and_count[1][1]].img_head
        self[ui.."_pic_general"]:loadTexture(g_resManager.getResPath(iconId))
	else
		local iconId = g_data.res_head[player.avatar].head_icon
		self[ui.."_pic_general"]:loadTexture(g_resManager.getResPath(iconId))
	end
	

	local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
	self[ui.."_pic_general"]:addChild(imgFrame)
	imgFrame:setPosition(cc.p(self[ui.."_pic_general"]:getContentSize().width/2, self[ui.."_pic_general"]:getContentSize().height/2))

	self[ui.."_Text_name"]:setString(player.nick)

	self[ui.."_Text_4"]:setString(data.doDamage.."")
	self[ui.."_Text_5"]:setString(data.takeDamage.."")

	if max == 0 then
		self[ui.."_LoadingBar_1"]:setPercent(0)
		self[ui.."_LoadingBar_2"]:setPercent(0)
	else
		local value = data.doDamage*100/max
		value = value - value%1
		self[ui.."_LoadingBar_1"]:setPercent(value)

		value = data.takeDamage*100/max
		value = value - value%1
		self[ui.."_LoadingBar_2"]:setPercent(value)
	end
end

function BattleRecordDamageView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self["Panel_info1_Button_1"] then
				g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleDamageInfoView").new(self.player1))
			elseif sender == self["Panel_info2_Button_1"] then
				g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleDamageInfoView").new(self.player2))
			end
		end
	end
	self["Panel_info1_Button_1"]:addTouchEventListener(proClick)
	self["Panel_info2_Button_1"]:addTouchEventListener(proClick)
end

return BattleRecordDamageView