--region BattleHallAtkItemView.lua
--Author : luqingqing
--Date   : 2016/4/12
--此文件由[BabeLua]插件自动生成

local BattleHallAtkItemView = class("BattleHallAtkItemView", require("game.uilayer.base.BaseWidget"))

function BattleHallAtkItemView:ctor(callback)
    self.callback = callback

    self.layer = self:LoadUI("alliance_atk.csb")

    self.root = self.layer:getChildByName("scale_bj")
    self.scale_1 = self.root:getChildByName("scale_1")
    self.scale_2 = self.root:getChildByName("scale_2")
end

function BattleHallAtkItemView:show(data1, data2)
    self.data1 = data1
    self.data2 = data2

    if self.data1 ~= nil then
        local item = require("game.uilayer.battleHall.BattlePlayerItemVIew").new(self.data1, self.callback)
        self.scale_1:addChild(item)
        item:setPosition(item:getSize().width/2, item:getSize().height/2)
    end

    if self.data2 ~= nil then
        local item = require("game.uilayer.battleHall.BattlePlayerItemVIew").new(self.data2, self.callback)
        self.scale_2:addChild(item)
        item:setPosition(item:getSize().width/2, item:getSize().height/2)
    end 
end

return BattleHallAtkItemView
--endregion
