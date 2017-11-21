--region PowerUpView.lua
--Author : luqingqing
--Date   : 2016/3/24
--此文件由[BabeLua]插件自动生成

local PowerUpView = class("PowerUpView", require("game.uilayer.base.BaseWidget"))

function PowerUpView:ctor(value, callback)
    self.back = callback

    self.layer = self:LoadUI("Fighting1.csb")

    self.Text_1 = self.layer:getChildByName("Text_1")

    self.Text_1:setString(g_tr("powerUp", {power = value}))

    self:closeWin()
end

function PowerUpView:closeWin()
    local function remove()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
        self:stopAllActions()
        
        if self.back ~= nil then
            self.back()
        end

        self:removeFromParent()
    end

    self.schedule =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(remove, 1.3, false)
end

return PowerUpView
--endregion
