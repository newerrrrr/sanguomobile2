--region MessageLayer.lua
--Author : luqingqing
--Date   : 2016/2/27
--此文件由[BabeLua]插件自动生成

local MessageLayer = class("MessageLayer", function()
    return cc.Layer:create()
end)

function MessageLayer:ctor(value)

    self.callback = callback

    self.layer = cc.CSLoader:createNode("text.csb")
    self.layer:setAnchorPoint(cc.p(0.5,0.5))

    self.Text_1 = self.layer:getChildByName("Text_1")
    self:addChild(self.layer)

    self.Text_1:setString(value.."")
end

return MessageLayer
--endregion
