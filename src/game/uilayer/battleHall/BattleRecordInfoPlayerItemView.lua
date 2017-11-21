local BattleRecordInfoPlayerItemView = class("BattleRecordInfoPlayerItemView", require("game.uilayer.base.BaseWidget"))

function BattleRecordInfoPlayerItemView:ctor()
	self.layer = self:LoadUI("HistoryReport_ReportDetails_content.csb")
	self.shuoming = self.layer:getChildByName("shuoming")
	self.player_left = self.layer:getChildByName("player_left")
	self.player_right = self.layer:getChildByName("player_right")

	self:setPlayerUI("player_left", self.player_left)
	self:setPlayerUI("player_right", self.player_right)

	self.pic_lose = self.layer:getChildByName("pic_lose")
	self.pic_win = self.layer:getChildByName("pic_win")

	self.statistics_left = self.layer:getChildByName("statistics_left")
	self.statistics_right = self.layer:getChildByName("statistics_right")

	self:setPlayerInfoUI("statistics_left", self.statistics_left)
	self:setPlayerInfoUI("statistics_right", self.statistics_right)
end

function BattleRecordInfoPlayerItemView:setPlayerUI(name, ui)
	self[name.."_pic"] = ui:getChildByName("pic")
	self[name.."_pic_0"] = ui:getChildByName("pic_0")
	self[name.."_name"] = ui:getChildByName("name")
	self[name.."_label_1"] = ui:getChildByName("label_1")
	self[name.."_label_2"] = ui:getChildByName("label_2")
	self[name.."_num_1"] = ui:getChildByName("num_1")
	self[name.."_num_2"] = ui:getChildByName("num_2")

	self[name.."_label_1"]:setString(g_tr("armyFightForce"))
	self[name.."_label_2"]:setString(g_tr("soldierCounts"))
end

function BattleRecordInfoPlayerItemView:setPlayerInfoUI(name, ui)
	for i=1, 5 do
		self[name.."label_"..i] = ui:getChildByName("label_"..i)
		self[name.."num_"..i] = ui:getChildByName("num_"..i)
	end

	self[name.."label_1"]:setString(g_tr("killEnemy"))
	self[name.."label_2"]:setString(g_tr("lostTroops"))
	self[name.."label_3"]:setString(g_tr("woundedTroops"))
	self[name.."label_4"]:setString(g_tr("surviveTroops"))
	self[name.."label_5"]:setString(g_tr("lostTraps"))
end

function BattleRecordInfoPlayerItemView:setData(player1, player2, isWin, type, aList)
	self.data1 = player1
	self.data2 = player2
	self.type = type
	self.aList = aList

	if isWin == "1" then
		self.pic_lose:setVisible(false)
	else
		self.pic_win:setVisible(false)
	end

	self:processPlayerData(self.data1, "player_left", 1)
	self:processPlayerData(self.data2, "player_right", 2)

	self:processArmyInfo(self.data1, "statistics_left")
	self:processArmyInfo(self.data2, "statistics_right")
end

function BattleRecordInfoPlayerItemView:processPlayerData(data, ui, side)
	if self.type == "3" and data.avatar == 101 then
		self[ui.."_pic_0"]:loadTexture( g_resManager.getResPath(1018001))
	else
		if self.type == "9" then
			self.shuoming:setString(g_tr("battleType9"))
		elseif self.type == "10" then
			self.shuoming:setString(g_tr("battleType10"))
		else
			self.shuoming:setString("")
		end

		local iconId = nil
		if self.type == "10" then
			if side == 1 then
				local tem = g_data.huangjin_attack_mob[tonumber(self.aList)]
				iconId = g_data.soldier[tem.type_and_count[1][1]].img_head
			else
				iconId = 1018001
			end
		else
			iconId = g_data.res_head[data.avatar].head_icon
		end
		self[ui.."_pic_0"]:loadTexture(g_resManager.getResPath(iconId))

		local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    	self[ui.."_pic_0"]:addChild(imgFrame)
    	imgFrame:setPosition(cc.p(self[ui.."_pic_0"]:getContentSize().width/2, self[ui.."_pic_0"]:getContentSize().height/2))
	end
	
	local power = math.ceil(data.power/10000)
	self[ui.."_name"]:setString(data.nick)
	self[ui.."_num_1"]:setString(power.."")
	self[ui.."_num_2"]:setString(data.soldier_num.."")
end

function BattleRecordInfoPlayerItemView:processArmyInfo(data, ui)
	self[ui.."num_1"]:setString(data.kill_num.."")
	self[ui.."num_2"]:setString(data.killed_num.."")
	self[ui.."num_3"]:setString(data.injure_num.."")
	self[ui.."num_4"]:setString(data.live_num.."")
	self[ui.."num_5"]:setString(data.trap_lost.."")
end

return BattleRecordInfoPlayerItemView