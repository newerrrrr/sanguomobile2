--region CollegeTypeItemView.lua
--Author : luqingqing
--Date   : 2015/11/9
--此文件由[BabeLua]插件自动生成

local CollegeTypeItemView = class("CollegeTypeItemView", function() 
    return ccui.Widget:create()
end)

function CollegeTypeItemView:ctor(data1, data2, clickBack)
    self.data1 = data1
    self.data2 = data2

    self.clickBack = clickBack

    self.layout = cc.CSLoader:createNode("college_List_Time01.csb")
    self:addChild(self.layout)

    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))

    self.root = self.layout:getChildByName("scale_node")

    for i=1, 2 do
        self["Panel_0"..i] = self.root:getChildByName("Panel_0"..i)
        self["Panel_0"..i.."_Text_1"] = self["Panel_0"..i]:getChildByName("Text_1")
        self["Panel_0"..i.."_Panel_xuanzhe"] = self["Panel_0"..i]:getChildByName("Panel_xuanzhe")
        self["Panel_0"..i.."_Image_13"] = self["Panel_0"..i.."_Panel_xuanzhe"]:getChildByName("Image_13")

        self["Panel_0"..i.."_Image_13"]:setVisible(false)
    end

    self.Text_2 = self.Panel_02:getChildByName("Text_2")

    self.Panel_01_Text_1:setString(data1.time..g_tr_original("hour"))
    self.Panel_02_Text_1:setString(data2.time..g_tr_original("hour"))
    self.Text_2:setString(data2.cost.."")

    self:addEevnt()
end

function CollegeTypeItemView:addEevnt()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Panel_01_Panel_xuanzhe then
                if self.clickBack ~= nil then
                    self.clickBack(self.data1, self.Panel_01_Image_13)
                end
            elseif sender == self.Panel_02_Panel_xuanzhe then
                if self.clickBack ~= nil then
                    self.clickBack(self.data2, self.Panel_02_Image_13)
                end
            end
        end
    end

    self.Panel_01_Panel_xuanzhe:addTouchEventListener(proClick)
    self.Panel_02_Panel_xuanzhe:addTouchEventListener(proClick)
end

function CollegeTypeItemView:selectType(leftSelect, rightSelect)
    self.Panel_01_Image_13:setVisible(leftSelect)
    self.Panel_02_Image_13:setVisible(rightSelect)
end

function CollegeTypeItemView:clearSelect()
    self.Panel_01_Image_13:setVisible(false)
    self.Panel_02_Image_13:setVisible(false)
end

return CollegeTypeItemView

--endregion
