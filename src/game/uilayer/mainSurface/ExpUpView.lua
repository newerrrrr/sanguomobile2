--region ExpUpView.lua
--Author : luqingqing
--Date   : 2016/3/24
--此文件由[BabeLua]插件自动生成

local ExpUpView = class("ExpUpView", require("game.uilayer.base.BaseWidget"))

function ExpUpView:ctor(value, callback)
    self.callback = callback

    self.layer = self:LoadUI("Fighting2.csb")

    self.Text_1 = self.layer:getChildByName("Text_1")

    self.Text_1:setString(g_tr("expUp", {exp = value}))

    self:closeWin()
end

function ExpUpView:closeWin()
    local function remove()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
        self:stopAllActions()
        if self.callback ~= nil then
            self.callback()
        end
        self:removeFromParent()
    end

   self.schedule =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(remove, 1.3, false)
end

return ExpUpView

--endregion
