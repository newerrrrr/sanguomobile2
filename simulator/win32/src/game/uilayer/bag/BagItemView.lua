--region BagItemView.lua
--Author : luqingqing
--Date   : 2015/11/4
--此文件由[BabeLua]插件自动生成

local BagItemView = class("BagItemView", require("game.uilayer.base.BaseWidget"))

function BagItemView:ctor(status, fun)
    self.fun = fun
    self.showStar = status

    self.layout = self:LoadUI("Useprops_List.csb")
    self.root = self.layout:getChildByName("scale_node")
    
    for i=1, 7 do
        self["Panel_0"..i] = self.root:getChildByName("Panel_0"..i)
        self["Panel_0"..i.."Image_3"] = self["Panel_0"..i]:getChildByName("Image_3")
        self["Panel_0"..i.."_Image_1"] = self["Panel_0"..i]:getChildByName("Image_1")
        self["Panel_0"..i.."_star_box"] = self["Panel_0"..i]:getChildByName("star_box")
        self["Panel_0"..i.."_Image_4"] = self["Panel_0"..i]:getChildByName("Image_4")

        for j=1, 5 do
            self["Panel_0"..i.."_star_light_"..j] = self["Panel_0"..i.."_star_box"]:getChildByName("star_light_"..j)
            self["Panel_0"..i.."_star_light_"..j]:setVisible(false)
        end

        if self.showStar == 1 then
            self["Panel_0"..i.."_star_box"]:setVisible(false)
        elseif self.showStar == 2 then
            self["Panel_0"..i.."_star_box"]:setVisible(true)
        elseif self.showStar == 3 then
            self["Panel_0"..i.."_star_box"]:setVisible(false)
        end
    end

    self:addEvent()
end

function BagItemView:show(data)
    self.data = data
    for i=1, 7 do
        if self.data[i] == nil then
            self["Panel_0"..i]:setVisible(false)
        else
            self["Panel_0"..i]:setVisible(true)

            if self.data[i].is_new == 1 then
                self["Panel_0"..i.."_Image_4"]:setVisible(true)
            else
                self["Panel_0"..i.."_Image_4"]:setVisible(false)
            end

            if self.showStar == 1 then
                self["Panel_0"..i.."Image_3"]:removeAllChildren(true)

                self["item"..i] = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Resource, self.data[i].item_id,self.data[i].num)
                self["Panel_0"..i.."Image_3"]:addChild(self["item"..i])
                self["item"..i]:setPosition(self["Panel_0"..i.."Image_3"]:getContentSize().width/2, self["Panel_0"..i.."Image_3"]:getContentSize().height/2)

            elseif self.showStar == 2 then
                local star = g_data.equipment[self.data[i].item_id].star_level
                if self.data[i].item_id == 90100 or self.data[i].item_id == 90200 or self.data[i].item_id == 90300 
                or self.data[i].item_id == 90400 or self.data[i].item_id == 90500  then
                    self["Panel_0"..i.."_star_box"]:setVisible(false)
                else
                    for j=1, star do
                        self["Panel_0"..i.."_star_light_"..j]:setVisible(true)
                    end
                end
                
                self["Panel_0"..i.."Image_3"]:removeAllChildren(true)
                
                if g_data.equipment[self.data[i].item_id] and g_data.equipment[self.data[i].item_id].equip_type == 0 then --万能装备保持叠加
                    self["item"..i] = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Equipment, self.data[i].item_id, self.data[i].num)
                    self["item"..i]:setCountEnabled(true)
                else 
                    self["item"..i] = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Equipment, self.data[i].item_id, 1)
                    self["item"..i]:setCountEnabled(false)
                end 
                self["Panel_0"..i.."Image_3"]:addChild(self["item"..i])
                self["item"..i]:setPosition(self["Panel_0"..i.."Image_3"]:getContentSize().width/2, self["Panel_0"..i.."Image_3"]:getContentSize().height/2)

            elseif self.showStar == 3 then
                self["Panel_0"..i.."Image_3"]:removeAllChildren(true)
                self["item"..i] = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.MasterEquipment, self.data[i].equip_master_id, 1)
                self["Panel_0"..i.."Image_3"]:addChild(self["item"..i])
                self["item"..i]:setPosition(self["Panel_0"..i.."Image_3"]:getContentSize().width/2, self["Panel_0"..i.."Image_3"]:getContentSize().height/2)
                self["item"..i]:setCountEnabled(false)
            end
        end
    end
end

function BagItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if sender == self.Panel_01_Image_1 then
                self.fun(self.data[1], self["item1"])
            elseif sender == self.Panel_02_Image_1 then
                self.fun(self.data[2], self["item2"])
            elseif sender == self.Panel_03_Image_1 then
                self.fun(self.data[3], self["item3"])
            elseif sender == self.Panel_04_Image_1 then
                self.fun(self.data[4], self["item4"])
            elseif sender == self.Panel_05_Image_1 then
                self.fun(self.data[5], self["item5"])
            elseif sender == self.Panel_06_Image_1 then
                self.fun(self.data[6], self["item6"])
            elseif sender == self.Panel_07_Image_1 then
                self.fun(self.data[7], self["item7"])
            end
        end
    end

    self.Panel_01_Image_1:addTouchEventListener(proClick)
    self.Panel_02_Image_1:addTouchEventListener(proClick)
    self.Panel_03_Image_1:addTouchEventListener(proClick)
    self.Panel_04_Image_1:addTouchEventListener(proClick)
    self.Panel_05_Image_1:addTouchEventListener(proClick)
    self.Panel_06_Image_1:addTouchEventListener(proClick)
    self.Panel_07_Image_1:addTouchEventListener(proClick)
end

function BagItemView:getData()
    return self.data
end

function BagItemView:updateNum(index, num)
    self.data[index] = num
    self["Panel_0"..index.."_Text_1"]:setString(num)
end

function BagItemView:addItem(index)
    self["Panel_0"..index.."_Text_1"]:setString(self.data[i].num)
end

return BagItemView

--endregion
