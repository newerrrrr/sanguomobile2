--region ItemPathItemView.lua
--Author : luqingqing
--Date   : 2016/3/9
--此文件由[BabeLua]插件自动生成

local ItemPathItemView = class("ItemPathItemView", require("game.uilayer.base.BaseWidget"))

function ItemPathItemView:ctor(fun, content, resId)
    self.fun = fun

    self.layer = self:LoadUI("Smithrecast_resources_list.csb")

    self.root = self.layer:getChildByName("scale_node")

    self.Image_4 = self.root:getChildByName("Image_4")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Button_1 = self.root:getChildByName("Button_1")
    self.Text_3 = self.root:getChildByName("Text_3")

    self.Text_1:setString(content)
    self.Text_3:setString(g_tr_original("gotoPathBtn"))
    self.Image_4:loadTexture(g_resManager.getResPath(resId))

    self:addEvent()
end

function ItemPathItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.fun ~= nil then
                    self.fun()
                end
            end
        end
    end

    self.Button_1:addTouchEventListener(proClick)
end

return ItemPathItemView
--endregion
