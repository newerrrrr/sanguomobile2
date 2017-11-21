local BattleRecordGeneralView = class("BattleRecordGeneralView", require("game.uilayer.base.BaseWidget"))

function BattleRecordGeneralView:ctor(data1, data2)
	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_4.csb")

	for i=1, 2 do
		self["army_"..i] = self.layer:getChildByName("army_"..i)
		self["army_"..i.."_pic_general"] = self["army_"..i]:getChildByName("pic_general")
		self["army_"..i.."_name_general"] = self["army_"..i]:getChildByName("name_general")
        self["army_"..i.."_img_tip"] = self["army_"..i]:getChildByName("img_tip")
		self["army_"..i.."_label_1"] = self["army_"..i]:getChildByName("label_1")
		self["army_"..i.."_label_2"] = self["army_"..i]:getChildByName("label_2")
		self["army_"..i.."_label_3"] = self["army_"..i]:getChildByName("label_3")
		self["army_"..i.."_label_4"] = self["army_"..i]:getChildByName("label_4")
        self["army_"..i.."_Button_1"] = self["army_"..i]:getChildByName("Button_1")
        self["army_"..i.."_Button_1_label_4_0"] = self["army_"..i.."_Button_1"]:getChildByName("label_4_0")
        self["army_"..i.."_Button_1_label_4_0"]:setString(g_tr("seeDetail"))
    end

	self.data1 = data1
	self.data2 = data2

    self:addEvent()

	self:process("army_1", self.data1)
	self:process("army_2", self.data2)
end

function BattleRecordGeneralView:process(ui, data)
	if data == nil then
		self[ui]:setVisible(false)
		return
	end

    if data.key == "tower" then
        self[ui.."_pic_general"]:loadTexture(g_resManager.getResPath(g_data.map_element[201].img_mail))
        local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
        self[ui.."_pic_general"]:addChild(imgFrame)
        imgFrame:setPosition(cc.p(self[ui.."_pic_general"]:getContentSize().width/2, self[ui.."_pic_general"]:getContentSize().height/2))
        self[ui.."_name_general"]:setString(g_tr(g_data.map_element[201].name))
        self[ui.."_Button_1"]:setVisible(false)
        self[ui.."_img_tip"]:setVisible(false)
    else
        if data.key == "npc" then
            local tem = g_data.huangjin_attack_mob[tonumber(data.aList)]
            iconId = g_data.soldier[tem.type_and_count[1][1]].img_head
            self[ui.."_pic_general"]:loadTexture(g_resManager.getResPath(iconId))
        else
            local iconId = g_data.res_head[data.avatar].head_icon
            self[ui.."_pic_general"]:loadTexture(g_resManager.getResPath(iconId))
        end

        local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
        self[ui.."_pic_general"]:addChild(imgFrame)
        imgFrame:setPosition(cc.p(self[ui.."_pic_general"]:getContentSize().width/2, self[ui.."_pic_general"]:getContentSize().height/2))
            
        self[ui.."_name_general"]:setString(data.nick)

        local live_num = 0
        local injure_num = 0
        local kill_num = 0
        local killed_num = 0

        for key, value in pairs(data.unit) do
            if key ~= "trap" then
                live_num = live_num + value.live_num
                injure_num = injure_num + value.injure_num
                kill_num = kill_num + value.kill_num
                killed_num = killed_num + value.killed_num
            else
                for i=1, #value do --陷阱只算击杀
                    --live_num = live_num + value[i].live_num
                    -- injure_num = injure_num + value[i].injure_num
                    kill_num = kill_num + value[i].kill_num
                    --killed_num = killed_num + value[i].killed_num
                end
            end
        end

        self[ui.."_label_1"]:setString(g_tr("survive%{val}", {val=live_num}))
        self[ui.."_label_2"]:setString(g_tr("damage%{val}", {val=injure_num}))
        self[ui.."_label_3"]:setString(g_tr("kill%{val}", {val=kill_num}))
        self[ui.."_label_4"]:setString(g_tr("killed%{val}", {val=killed_num}))
        self[ui.."_Button_1"]:setVisible(true)
    end
end

function BattleRecordGeneralView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self["army_1_Button_1"] then
                g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleHeroInfoView").new(self.data1))
            elseif sender == self["army_2_Button_1"] then
                g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleHeroInfoView").new(self.data2))
            end
        end
    end

    self["army_1_Button_1"]:addTouchEventListener(proClick)
    self["army_2_Button_1"]:addTouchEventListener(proClick)
end

return BattleRecordGeneralView