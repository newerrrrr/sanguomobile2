--region UseTitleItem.lua
--Author : luqingqing
--Date   : 2016/1/22
--此文件由[BabeLua]插件自动生成

local UseTitleItem = class("UseTitleItem", require("game.uilayer.base.BaseWidget"))

function UseTitleItem:ctor(itemType, click, num)
    self.click = click
    self.type = itemType
    self.num = num
    
    self.layer = self:LoadUI("Resources_list_Button1.csb")

    self.root = self.layer:getChildByName("Panel_b1")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Button_1 = self.root:getChildByName("Button_1")

    self:addEvent()
end

function UseTitleItem:update(rtp)
    local count,iconPath = g_gameTools.getPlayerCurrencyCount(rtp)
    self.Text_1:setString(string.formatnumberlogogram( tonumber(count)))
    
    self.root:getChildByName("Image_3"):loadTexture(iconPath)
end

function UseTitleItem:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.root then
                if self.click ~= nil then
                    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                    self.click(self)
                end
            end
        end
    end

    self.root:addTouchEventListener(proClick)
end

function UseTitleItem:clear(value)
    if value == false then
        self.Button_1:setBrightStyle(BRIGHT_NORMAL)
    else
        self.Button_1:setBrightStyle(BRIGHT_HIGHLIGHT)
    end
end

function UseTitleItem:getItemType()
    return self.type
end

return UseTitleItem

--endregion
