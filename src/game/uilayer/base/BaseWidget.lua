--region BaseWidget.lua
--Author : luqingqing
--Date   : 2015/12/1
--此文件由[BabeLua]插件自动生成

local BaseWidget = class("BaseWidget", function() 
    return ccui.Widget:create()
end)

BaseWidget.__index = BaseWidget


function BaseWidget:ctor()

end 

function BaseWidget:LoadUI(path)
    self.layout = cc.CSLoader:createNode(path)
    self:addChild(self.layout)
    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))
    
    return self.layout
end

return BaseWidget

--endregion
