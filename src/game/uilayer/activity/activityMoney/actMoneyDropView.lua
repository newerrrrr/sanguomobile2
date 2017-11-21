--region actMoneyDropView.lua
--Author : luqingqing
--Date   : 2016/4/21
--此文件由[BabeLua]插件自动生成

local actMoneyDropView = class("actMoneyDropView", require("game.uilayer.base.BaseWidget"))

function actMoneyDropView:ctor()
    self.layer = self:LoadUI("activity2_Package1.csb")

    for i=1, 2 do
        self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
        self["Panel_"..i.."_Image_13"] = self["Panel_"..i]:getChildByName("Image_12")
        self["Panel_"..i.."_Text_4"] = self["Panel_"..i]:getChildByName("Text_4")
        self["Panel_"..i.."_Text_5"] = self["Panel_"..i]:getChildByName("Text_5")
    end
end

function actMoneyDropView:show(data1, data2)
    self.data1 = data1
    self.data2 = data2

    self:processData("Panel_1", self.data1)
    self:processData("Panel_2", self.data2)
end

function actMoneyDropView:processData(ui, data)
    if data == nil then
        self[ui]:setVisible(false)
        return
    end

    local item = require("game.uilayer.common.DropItemView").new(data[1], data[2], data[3])
    self[ui.."_Image_13"]:addChild(item)
    item:setPosition(self[ui.."_Image_13"]:getContentSize().width/2, self[ui.."_Image_13"]:getContentSize().height/2)
    item:setCountEnabled(false)

    self[ui.."_Text_4"]:setString(item:getName())
    
    self[ui.."_Text_5"]:setString("x"..data[3].."")
end

return actMoneyDropView

--endregion
