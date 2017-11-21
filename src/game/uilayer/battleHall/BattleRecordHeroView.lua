local BattleRecordHeroView = class("BattleRecordHeroView", require("game.uilayer.base.BaseWidget"))

function BattleRecordHeroView:ctor(data1, data2)
	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_4.csb")
	
	for i=1, 2 do
		self["army_"..i] = self.layer:getChildByName("army_"..i)
		self["army_"..i.."_pic_general"] = self["army_"..i]:getChildByName("pic_general")
		self["army_"..i.."_name_general"] = self["army_"..i]:getChildByName("name_general")
		self["army_"..i.."_label_1"] = self["army_"..i]:getChildByName("label_1")
		self["army_"..i.."_label_2"] = self["army_"..i]:getChildByName("label_2")
		self["army_"..i.."_label_3"] = self["army_"..i]:getChildByName("label_3")
		self["army_"..i.."_label_4"] = self["army_"..i]:getChildByName("label_4")
	end

	if data1 == nil then
		self.army_1:setVisible(false)
	else
		self:setData("army_1", data1)
	end

	if data2 == nil then
		self.army_2:setVisible(false)
	else
		self:setData("army_2", data2)
	end
end

function BattleRecordHeroView:setData(ui, data)
	local iconId = g_data.res_head[data.avatar].head_icon
	self[ui.."_pic_general"]:loadTexture(g_resManager.getResPath(iconId))

	local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    self[ui.."_pic_general"]:addChild(imgFrame)
    imgFrame:setPosition(cc.p(self[ui.."_pic_general"]:getContentSize().width/2, self[ui.."_pic_general"]:getContentSize().height/2))

    self[ui.."_name_general"]:setString(data.nick)
    
    local tem = {0,0,0,0}
    for i=1, #data.unit do
    	tem[1] = tem[1] + data.unit[i].live_num
    	tem[2] = tem[2] + data.unit[i].injure_num
    	tem[3] = tem[3] + data.unit[i].kill_num
    	tem[4] = tem[4] + data.unit[i].killed_num
    end
    self[ui.."_label_1"]:setString(g_tr("survive%{val}", {val=tem[1]}))
    self[ui.."_label_2"]:setString(g_tr("damage%{val}", {val=tem[2]}))
    self[ui.."_label_3"]:setString(g_tr("kill%{val}", {val=tem[3]}))
    self[ui.."_label_4"]:setString(g_tr("killed%{val}", {val=tem[4]}))
end

return BattleRecordHeroView