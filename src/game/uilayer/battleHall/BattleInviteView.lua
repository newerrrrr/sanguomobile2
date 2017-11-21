--region BattleInviteView.lua
--Author : luqingqing
--Date   : 2015/12/4
--此文件由[BabeLua]插件自动生成

local BattleInviteView = class("BattleInviteView", require("game.uilayer.base.BaseLayer"))

function BattleInviteView:ctor(data)
    BattleInviteView.super.ctor(self)

    self.mode = require("game.uilayer.battleHall.BattleHallMode").new()

    self.data = data

    self.uilist = {}

    self:initUI()
end

function BattleInviteView:initUI()
    self.layout = self:loadUI("alliance_Members01_01.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1:setString(g_tr("collectMember"))
    self.Text_2 = self.root:getChildByName("Text_2")
    self.Text_2:setString(g_tr("selectAll"))

    self.Button_1 = self.root:getChildByName("Button_1")
    self.Text_12 = self.Button_1:getChildByName("Text_12")
    self.Text_12:setString(g_tr("collectSend"))

    self.ListView_1 = self.root:getChildByName("ListView_1")

    self.Image_5 = self.root:getChildByName("Image_5")
    self.Image_6 = self.root:getChildByName("Image_6")

    self.Image_6:setVisible(false)

    self:initFun()
    self:setData()
    self:addEvent()
end

function BattleInviteView:initFun()
    self.cancelSelect = function()
        self.Image_6:setVisible(false)
    end
end

function BattleInviteView:setData()
    local len = #self.data.invite
    if len%2 == 1 then
        len = len + 1
    end
    len = len/2

    for i=1, len do
        local item = require("game.uilayer.battleHall.BattleMemberView").new(self.cancelSelect)
        self.ListView_1:pushBackCustomItem(item)

        item:show(self.data.invite[i*2-1], self.data.invite[2*i])

        self.uilist[i] = item
    end
end

function BattleInviteView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            elseif sender == self.Image_5 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.Image_6:setVisible(true)
                for key, value in pairs(self.uilist) do
                    value:setSel1(true)
                    value:setSel2(true)
                end
            elseif sender == self.Image_6 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.Image_6:setVisible(false)
                for key, value in pairs(self.uilist) do
                    value:setSel1(false)
                    value:setSel2(false)
                end
            elseif sender == self.Button_1 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                local result = {}
                for key, value in pairs(self.uilist) do
                    if value ~=nil and value:getSel1() == true and value:getSel1()~=nil then
                        table.insert(result, value:getData1().player_id)
                    end

                    if value~=nil and  value:getSel2() == true and value:getData2() ~= nil then
                        table.insert(result, value:getData2().player_id)
                    end
                end

                if #result == 0 then
                    g_airBox.show(g_tr_original("collectInviteErro"))
                    return
                else
                    local function callback()
                        g_airBox.show(g_tr_original("collectInviteSuc"))
                        self:close()
                    end
                    self.mode:sendGatherMail(result, self.data.id, callback)
                end
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
    self.Image_5:addTouchEventListener(proClick)
    self.Image_6:addTouchEventListener(proClick)
    self.Button_1:addTouchEventListener(proClick)
end

return BattleInviteView

--endregion
