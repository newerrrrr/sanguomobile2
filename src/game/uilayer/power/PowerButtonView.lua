--region PowerButtonView.lua
--Author : luqingqing
--Date   : 2016/3/31
--此文件由[BabeLua]插件自动生成

local PowerButtonView = class("PowerButtonView", require("game.uilayer.base.BaseWidget"))

function PowerButtonView:ctor(value, id, click)
    self.id = id
    self.click = click

    self.layer = self:LoadUI("power_anniu.csb")

    self.Button_gn1 = self.layer:getChildByName("Button_gn1")
    self.Text_gn1 = self.layer:getChildByName("Text_gn1")
    self.Text_gn1:setString("")
    self.Text_gn1:setString(value)

    self:addEvent()
end

function PowerButtonView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_gn1 then
                --findbuild_orignid
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.click ~= nil then
                    self.click(self.id)
                end
            end
        end
    end

    self.Button_gn1:addTouchEventListener(proClick)
end

return PowerButtonView

--endregion
