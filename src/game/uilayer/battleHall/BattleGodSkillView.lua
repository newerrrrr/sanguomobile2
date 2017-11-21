local BattleGodSkillView = class("BattleGodSkillView", require("game.uilayer.base.BaseWidget"))

local MailHelper = require("game.uilayer.mail.MailHelper"):instance()

function BattleGodSkillView:ctor(skill1, skill2, player1, player2)

	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_13.csb")

    self.skill1 = skill1

    self.skill2 = skill2

	self.player1 = player1

	self.player2 = player2

	for i=1, 2 do
		self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Text_title"] = self["Panel_"..i]:getChildByName("Panel_title"):getChildByName("Text_title")
		self["Panel_"..i.."_pic_general"] = self["Panel_"..i]:getChildByName("Panel_info"):getChildByName("pic_general")
		self["Panel_"..i.."_Text_name"] = self["Panel_"..i]:getChildByName("Panel_info"):getChildByName("Text_name")
		self["Panel_"..i.."_Text_descl"] = self["Panel_"..i]:getChildByName("Panel_info"):getChildByName("Text_desc")
		self["Panel_"..i.."_Button_1"] = self["Panel_"..i]:getChildByName("Panel_info"):getChildByName("Button_1")
		self["Panel_"..i.."_Text_22"] = self["Panel_"..i.."_Button_1"]:getChildByName("Text_22")
        self["Panel_"..i.."_img_tip"] = self["Panel_"..i]:getChildByName("Panel_info"):getChildByName("img_tip")
		self["Panel_"..i.."_Text_22"]:setString(g_tr("seeDetail"))
        self["Panel_"..i.."_img_tip"]:setVisible(false)
	end

	self["Panel_1_Text_title"]:setString(g_tr("attack"))
	self["Panel_2_Text_title"]:setString(g_tr("defend"))

    self:addEvent()

    self.curPlayer1 = nil
    self.curPlayer2 = nil

	self.curPlayer1 = self:show("Panel_1", self.skill1, self.player1)
	self.curPlayer2 = self:show("Panel_2", self.skill2, self.player2)
end 

function BattleGodSkillView:show(ui, data, player)
	if data == nil then
		self[ui]:setVisible(false)
		return nil
	end

    local curPlayer = nil
    local len = 0

    for i=1, #player.players do
        if player.players[i].player_id == data[1].pid then
            local iconId = g_data.res_head[player.players[i].avatar].head_icon
            self[ui.."_pic_general"]:loadTexture(g_resManager.getResPath(iconId))

            local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
            self[ui.."_pic_general"]:addChild(imgFrame)
            imgFrame:setPosition(cc.p(self[ui.."_pic_general"]:getContentSize().width/2, self[ui.."_pic_general"]:getContentSize().height/2))
            
            self[ui.."_Text_name"]:setString(player.players[i].nick)

            curPlayer = player.players[i]

            local playerData = g_PlayerMode.GetData()
            if playerData.id == player.players[i].player_id then
                self[ui.."_img_tip"]:setVisible(true)
            end
            break
        end
    end
    
    local str = ""
    local len = 0
    if #data > 8 then
        len = 8
    else
        len = #data
    end
    for i=1, len do
        str = str..g_tr(g_data.general[data[i].gid * 100 + 1].general_name)
        if i < len then
            str = str.."、"
        end
    end

    local richTex = g_gameTools.createRichText(self[ui.."_Text_descl"], "")
    richTex:setRichText(g_tr("skillDesc", {player=str}))

    return curPlayer
end

function BattleGodSkillView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self["Panel_1_Button_1"] then
                g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleGodInfoView").new(self.skill1, self.curPlayer1, self.curPlayer2))
            elseif sender == self["Panel_2_Button_1"] then
                g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleGodInfoView").new(self.skill2, self.curPlayer2, self.curPlayer1))
            end
        end
    end

    self["Panel_1_Button_1"]:addTouchEventListener(proClick)
    self["Panel_2_Button_1"]:addTouchEventListener(proClick)
end

return BattleGodSkillView