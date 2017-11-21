--region ArmyHelpItemView.lua
--Author : luqingqing
--Date   : 2015/11/19
--此文件由[BabeLua]插件自动生成

local ArmyHelpItemView = class("ArmyHelpItemView", require("game.uilayer.base.BaseWidget"))

function ArmyHelpItemView:ctor()
    self.layout = self:LoadUI("tunsuo_reinf_item_1.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.player = g_PlayerMode.GetData()

    for i=1, 2 do
        self["Panel_0"..i] = self.root:getChildByName("Panel_0"..i)

        for j=2, 4 do
            self["p"..i.."_prop_"..j] = self["Panel_0"..i]:getChildByName("panel_prop_"..j)
            self["p"..i.."_prop_"..j.."Text_prop"] =  self["p"..i.."_prop_"..j]:getChildByName("Text_prop")
            self["p"..i.."_prop_"..j.."Text_prop_0"] =  self["p"..i.."_prop_"..j]:getChildByName("Text_prop_0")
        end

        self["Panel_0"..i.."_pic_2"] = self["Panel_0"..i]:getChildByName("pic_2")
        self["Panel_0"..i.."_Text_1"] = self["Panel_0"..i]:getChildByName("Text_1")
        self["Panel_0"..i.."_Image_6"] = self["Panel_0"..i]:getChildByName("Image_6")
        self["Panel_0"..i.."_Button_1"] = self["Panel_0"..i]:getChildByName("Button_1")
        self["Panel_0"..i.."_Button_1_Text_39"] = self["Panel_0"..i.."_Button_1"]:getChildByName("Text_39")
    end

    self["p1_prop_2Text_prop"]:setString(g_tr("armyEnter"))
    self["p2_prop_2Text_prop"]:setString(g_tr("armyEnter"))
    self["p1_prop_3Text_prop"]:setString(g_tr("armyFightForce"))
    self["p2_prop_3Text_prop"]:setString(g_tr("armyFightForce"))
    self["p1_prop_4Text_prop"]:setString(g_tr("armyNumber"))
    self["p2_prop_4Text_prop"]:setString(g_tr("armyNumber"))
    self["Panel_01_Button_1_Text_39"]:setString(g_tr("tuoCheck"))
    self["Panel_02_Button_1_Text_39"]:setString(g_tr("tuoCheck"))

    self:addEvent()
end

function ArmyHelpItemView:show(data1, data2, fun)
    self.data1 = data1
    self.data2 = data2
    self.fun = fun

    if self.data1 ~= nil then
        self:initLeft()
    else
        self.Panel_01:setVisible(false)
    end

    if self.data2 ~= nil then
        self:initRight()
    else
        self.Panel_02:setVisible(false)
    end
end

function ArmyHelpItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended  then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if sender == self.Panel_01_Image_6 then
                if self.data1 ~= nil then
                    self.fun(self.data1)
                end
            elseif sender == self.Panel_02_Image_6 then
                if self.data2 ~= nil then
                    self.fun(self.data2)
                end
            elseif sender == self.Panel_01_Button_1 then
                local item = require("game.uilayer.tun.ArmyInfoView").new(self.data1)
                g_sceneManager.addNodeForUI(item)
            elseif sender == self.Panel_02_Button_1 then
                local item = require("game.uilayer.tun.ArmyInfoView").new(self.data2)
                g_sceneManager.addNodeForUI(item)
            end
        end
    end

    self["Panel_01_Image_6"]:addTouchEventListener(proClick)
    self["Panel_02_Image_6"]:addTouchEventListener(proClick)
    self["Panel_01_Button_1"]:addTouchEventListener(proClick)
    self["Panel_02_Button_1"]:addTouchEventListener(proClick)
end

function ArmyHelpItemView:initLeft()
    self["Panel_01_Text_1"]:setString(self.data1.player_nick)
    self["p1_prop_2Text_prop_0"]:setString(""..(#self.data1.army))
    self["p1_prop_3Text_prop_0"]:setString(self.data1.total_power.."")
    self["p1_prop_4Text_prop_0"]:setString(self.data1.total_soldier_num.."")
    local iconid = g_data.res_head[self.data1.player_avatar_id].head_icon
    self["Panel_01_pic_2"]:loadTexture( g_resManager.getResPath(iconid))

    local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    self["Panel_01_pic_2"]:addChild(imgFrame)
    imgFrame:setPosition(cc.p(self["Panel_01_pic_2"]:getContentSize().width/2, self["Panel_01_pic_2"]:getContentSize().height/2))
end

function ArmyHelpItemView:initRight()
    self["Panel_02_Text_1"]:setString(self.data2.player_nick)
    self["p2_prop_2Text_prop_0"]:setString(""..(#self.data2.army))
    self["p2_prop_3Text_prop_0"]:setString(self.data2.total_power.."")
    self["p2_prop_4Text_prop_0"]:setString(self.data2.total_soldier_num.."")
    local iconid = g_data.res_head[self.data2.player_avatar_id].head_icon
    self["Panel_02_pic_2"]:loadTexture( g_resManager.getResPath(iconid))

    local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    self["Panel_02_pic_2"]:addChild(imgFrame)
    imgFrame:setPosition(cc.p(self["Panel_02_pic_2"]:getContentSize().width/2, self["Panel_02_pic_2"]:getContentSize().height/2))
end

return ArmyHelpItemView

--endregion
