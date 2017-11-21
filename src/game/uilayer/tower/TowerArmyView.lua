--region TowerArmyView.lua
--Author : luqingqing
--Date   : 2015/12/31
--此文件由[BabeLua]插件自动生成

local TowerArmyView = class("TowerArmyView", require("game.uilayer.base.BaseWidget"))

function TowerArmyView:ctor(data, playerName)
    self.data = data
    self.layout = self:LoadUI("tower_popup_army_row.csb")

    self.root = self.layout:getChildByName("scale_node")
    self.soldier_1 = self.root:getChildByName("soldier_1")
    self.num1 = self.soldier_1:getChildByName("num")
    self.soldier_name_1 = self.root:getChildByName("soldier_name_1")
    self.num1:setVisible(false)
    self.zijimingzi = self.root:getChildByName("zijimingzi")

    self.Image_6 = self.root:getChildByName("Image_6")
    self.Image_6:setVisible(false)

    self.soldier_2 = self.root:getChildByName("soldier_2")
    self.num2 = self.soldier_2:getChildByName("num")
    self.soldier_name_2 = self.root:getChildByName("soldier_name_2")

    self.soldier_1:removeAllChildren()
    local item = self:createHeroHead(self.data.general_id*100+1)
    item:setPosition(self.soldier_1:getContentSize().width/2, self.soldier_1:getContentSize().height/2)
    self.soldier_1:addChild(item)
    self.soldier_name_1:setString(item:getName())

    if playerName == "" then
        self.zijimingzi:setString("")
    else
        self.zijimingzi:setString(g_tr("towerArmyPlayer", {player = playerName}))
    end
    
    if self.data.soldier_id ~= 0 then
        local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Soldier, self.data.soldier_id, 1)
        self.soldier_2:addChild(item)
        item:setPosition(self.soldier_2:getContentSize().width/2, self.soldier_2:getContentSize().height/2)
        item:setCountEnabled(false)
        self.num2:setString(self.data.soldier_num.."")
        self.soldier_name_2:setString(item:getName())
    else
        self.num2:setString("")
        self.soldier_name_2:setString("")
    end
end

function TowerArmyView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

return TowerArmyView

--endregion
