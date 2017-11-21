--region BattleRecordView.lua
--Author : luqingqing
--Date   : 2015/12/4
--此文件由[BabeLua]插件自动生成

local BattleRecordView = class("BattleRecordView", require("game.uilayer.base.BaseLayer"))

function BattleRecordView:ctor(data, gotoPos)
    BattleRecordView.super.ctor(self)

    self.data = data
    self.gotoPos = gotoPos
    self:initUI()
end

function BattleRecordView:initUI()
    self.layout = self:loadUI("HistoryReport_01.csb")                               
    self.root = self.layout:getChildByName("scale_node")

    self.Text_1 = self.root:getChildByName("Text_1")
    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_c2 = self.root:getChildByName("Text_c2")
    self.ListView_1 = self.root:getChildByName("ListView_1")

    self.Text_1:setString(g_tr("collectRecord"))
    self.Text_c2:setString(g_tr("allianceBattleReport"))

    self:setData()
    self:addEvent()
end

function BattleRecordView:setData()
    self:loadItem(self.data.log)
end

function BattleRecordView:loadItem(data)
    local index = 0
    local idx_s = 1 
    local idx_e = #data
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
            item = require("game.uilayer.battleHall.BattleRecordItemView").new(data[idx_s], self.gotoPos)
            
            self.ListView_1:pushBackCustomItem(item)
            idx_s = idx_s + 1 
            index = index + 1
        else
            --加载完成
            if self.frameLoadTimer then 
                self:unschedule(self.frameLoadTimer) 
                self.frameLoadTimer = nil  
            end 
        end
    end

    --分侦加载
    if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
    end 
    self.frameLoadTimer = self:schedule(loadItem, 0) 
end

function BattleRecordView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
end

return BattleRecordView

--endregion
