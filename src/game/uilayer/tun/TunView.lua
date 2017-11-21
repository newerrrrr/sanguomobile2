--region TunView.lua
--Author : luqingqing
--Date   : 2015/11/14
--此文件由[BabeLua]插件自动生成

local TunView = class("TunView", require("game.uilayer.base.BaseLayer"))

function TunView:onEnter()
    g_PlayerHelpMode.SetView(self)
end

function TunView:onExit()
    g_PlayerHelpMode.SetView(nil)
end

function TunView:ctor()
    TunView.super.ctor(self)

    self.layout = self:loadUI("tunsuo.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_0 = self.root:getChildByName("Text_0")
    self.Text_0:setString(g_tr("tuoFriendHelp"))
    
    self.content = self.root:getChildByName("content")
    self.ListView_left = self.content:getChildByName("ListView_left")
    self.ListView_right = self.content:getChildByName("ListView_right")

    self.btn_help = self.content:getChildByName("btn_help")
    self.btn_help_Text_6 = self.btn_help:getChildByName("Text_6")
    self.btn_help_Text_6:setString(g_tr("tunHelpAll"))

    self.title_left = self.content:getChildByName("title_left")
    self.title_left_Text = self.title_left:getChildByName("Text")
    self.title_left_Text:setString(g_tr_original("tuoMyHelp"))

    self.title_right = self.content:getChildByName("title_right")
    self.title_right_Text = self.title_right:getChildByName("Text")
    self.title_right_Text:setString(g_tr("tuoFriendHelp"))

    self.myHelpList = {}
    self.alienctList = {}

    self:addEvent()
    self:initData() 
end

function TunView:removeHelpList()
    self.ListView_right:removeAllItems()
end

function TunView:initData()
    local function callback(result)
        g_busyTip.hide_1()
    end

    self.mode = require("game.uilayer.tun.TunMode").new()
    g_busyTip.show_1()
    g_PlayerHelpMode.RequestSycData(callback)
end

function TunView:show()
    self.data = g_PlayerHelpMode.GetData()
    if self.data == nil then
        self:close()
        return
    end

    if #self.data == 0 then
        local mes = require("game.uilayer.common.MessageLayer").new(g_tr("tunNoHelpInfo"))
        self.root:addChild(mes)
        mes:setPosition(self.root:getContentSize().width/2, self.root:getContentSize().height/2)
        self.content:setVisible(false)
        return
    end

    self.content:setVisible(true)
    self.curAlience = self.mode:getAlienceId()

    self.myHelpList = {}
    self.alienctList = {}

    for i=1, #self.data do
        --当前自己的请求
        if self.data[i].player_id == g_PlayerMode.GetData().id then
            table.insert(self.myHelpList, self.data[i])
        --联盟的请求
        elseif self.data[i].guild_id == self.curAlience then
            if self.data[i].help_num ~= self.data[i].help_num_max then
                 local tag = false
                 for key, value in pairs(self.data[i].helper_ids) do
                    if value == g_PlayerMode.GetData().id then
                        tag = true
                        break
                    end
                end

                if tag == false then
                    table.insert(self.alienctList, self.data[i])
                end
            end
        end
    end

    self:initUi()
end

function TunView:initUi()
    self.ListView_left:removeAllItems()

    for i=1, #self.myHelpList do
        local item = self:createItem(self.myHelpList[i])

        self.ListView_left:pushBackCustomItem(item)
    end

    self.ListView_right:removeAllItems()
    
    for i=1, #self.alienctList do
        local item = self:createItem(self.alienctList[i])

        self.ListView_right:pushBackCustomItem(item)
    end
end

function TunView:createItem(data)
    local item = require("game.uilayer.tun.TunItemView").new(data)

    return item
end

function TunView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.btn_help then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if #self.alienctList > 0 then
                    self.mode:helpAll()
                    self:removeHelpList()
                end
            elseif sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            end
        end
    end

    self.btn_help:addTouchEventListener(proClick)
    self.close_btn:addTouchEventListener(proClick)
end

return TunView

--endregion
