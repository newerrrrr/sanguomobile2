--region ArmyHelpView.lua
--Author : luqingqing
--Date   : 2015/11/19
--此文件由[BabeLua]插件自动生成

local ArmyHelpView = class("ArmyHelpView", require("game.uilayer.base.BaseLayer"))

function ArmyHelpView:ctor()
    ArmyHelpView.super.ctor(self)

    self.uiList = {}
    self:setData()
end

function ArmyHelpView:setData()
    self.mode = require("game.uilayer.tun.TunMode").new()

    self.layout = self:loadUI("tunsuo_reinforcements.csb")
    self.root = self.layout:getChildByName("scale_node")
    
    self.close_btn = self.root:getChildByName("close_btn")
    self.Image_8 = self.root:getChildByName("Image_8")

    self.content = self.root:getChildByName("content")
    self.ListView_left = self.content:getChildByName("ListView_left")
    self.label_text = self.content:getChildByName("label_text")
    self.Text_num_cur = self.content:getChildByName("Text_num_cur")
    self.Text_num_total = self.content:getChildByName("Text_num_total")

    self.label_text:setString(g_tr("tuoAss"))

    local function getData(data)
        if data == nil then
            self:close()
            return
        end

        dump(data)
        self:initUI(data)
    end

    self:initFun()

    self:addEvent()

    self.mode:helpArmy(getData)
end

function ArmyHelpView:initFun()
    local function setData(data)
        self.data = data
        if self.data == nil then
            self:close()
            return
        end

        self:initUI(data)
    end

    self.armyLeft = function(data)
        self.mode:armyLeft(data.ppq_id, setData)
    end
end

function ArmyHelpView:initUI(data)
    self.data = data

    self.Text_num_cur:setString(self.data.current_help_num.."/")
    self.Text_num_total:setString(self.data.max_help_num.."")

    local len = self.data.current_help_num
    if len%2 == 1 then
        len = len + 1
    end
    len = len/2

    if len == 0 then
        local mes = require("game.uilayer.common.MessageLayer").new(g_tr("tunNoHelpArmy"))
        mes:setPosition(self.root:getContentSize().width/2, self.root:getContentSize().height/2)
        self.root:addChild(mes)
        self.ListView_left:removeAllItems()
        return
    end
    
    for i=1, len do
        local item = nil
        if self.uiList[i] == nil then
            item = require("game.uilayer.tun.ArmyHelpItemView").new()
            self.uiList[i] = item
            self.ListView_left:pushBackCustomItem(item)
        else
            item = self.uiList[i]
        end
        local index = (i-1)*2
        print(index, "!!!!!!!!!!!!!!!!!!!!!")
        item:show(self.data[index..""], self.data[(index+1)..""], self.armyLeft)
    end

    if len < #self.uiList then
        for i=len+1, #self.uiList do
            self.ListView_left:removeItem(i)
        end
    end
end

function ArmyHelpView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            if sender == self.close_btn  then
                self:close()
            elseif sender == self.Image_8 then
                local view = require("game.uilayer.common.HelpInfoBox").new()
                view:show(11)
                g_sceneManager.addNodeForUI(view)
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
    self.Image_8:addTouchEventListener(proClick)
end

return ArmyHelpView

--endregion
