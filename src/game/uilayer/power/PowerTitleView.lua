--region NewFile_1.lua
--Author : luqingqing
--Date   : 2016/3/31
--此文件由[BabeLua]插件自动生成

local PowerTitleView = class("PowerTitleView", require("game.uilayer.base.BaseWidget"))

function PowerTitleView:ctor(value, click)
    self.click = click
    self.data = value

    self.layer = self:LoadUI("power_left_menu.csb")
    self.Text = self.layer:getChildByName("Text")
    self.Text:setString("")
    self.Text:setString(g_tr(self.data.name_id))

    --按下状态
    self.Image_2 = self.layer:getChildByName("Image_2")
        
    self.Image_1 = self.layer:getChildByName("Image_1")

    self:addEvent()
end

function PowerTitleView:setState(value)
    if value == true then
        self.Image_1:setVisible(false)
        self.Image_2:setVisible(true)
    else
        self.Image_1:setVisible(true)
        self.Image_2:setVisible(false)
    end
end

function PowerTitleView:addEvent()
    local function proClick(sender , eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Image_1 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.click ~= nil then
                    self.click(self.data)
                end
            end
        end
    end

    self.Image_1:addTouchEventListener(proClick)
end

return PowerTitleView
--endregion
