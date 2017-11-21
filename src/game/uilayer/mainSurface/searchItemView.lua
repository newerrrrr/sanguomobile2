--region NewFile_1.lua
--Author : luqingqing
--Date   : 2016/3/19
--此文件由[BabeLua]插件自动生成

local searchItemView = class("searchItemView", require("game.uilayer.base.BaseWidget"))

function searchItemView:ctor(index)
    self.layer = self:LoadUI("monster_resources_list2.csb")

    self.Image_4 = self.layer:getChildByName("Image_4")
    self.Text_1 = self.layer:getChildByName("Text_1")
    self.Text_1_0 = self.layer:getChildByName("Text_1_0")
    self.Text_2 = self.layer:getChildByName("Text_2")
    self.Button_1 = self.layer:getChildByName("Button_1")
    self.Text_3 = self.layer:getChildByName("Text_3")

    g_guideManager.registComponent(9999700 + index, self.Button_1)
end

function searchItemView:show(data, clickCallback)
    self.data = data
    self.clickCallback = clickCallback

    self.player = g_PlayerMode.GetData()

    local gElement = g_data.map_element[tonumber(self.data.element_id)]
    local gNpc = g_data.npc[gElement.npc_id]

    self.Text_1:setString(g_tr(gNpc.monster_name))
    self.Text_1_0:setString("Lv"..g_tr(gNpc.monster_lv))
    local runLength = cc.pGetDistance(cc.p(self.player.x, self.player.y),cc.p(tonumber(self.data.x), tonumber(self.data.y)))
    runLength = runLength - runLength%1
    self.Text_2:setString(g_tr("menu_distance")..runLength..g_tr("worldmap_KM"))
    self.Image_4:loadTexture(g_resManager.getResPath(gNpc.img_mail))
    self.Text_3:setString(g_tr("gotoPathBtn"))

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                if self.clickCallback ~= nil then
                    
                    g_guideManager.registComponent(9999701,self.Button_1)

                    self.clickCallback(self.data)
                end
            end
        end
    end

    self.Button_1:addTouchEventListener(proClick)
end

return searchItemView

--endregion
