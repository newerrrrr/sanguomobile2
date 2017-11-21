--region CollegeTypeView.lua
--Author : luqingqing
--Date   : 2015/11/7
--此文件由[BabeLua]插件自动生成

local CollegeTypeView = class("CollegeTypeView", require("game.uilayer.base.BaseLayer"))

function CollegeTypeView:ctor(selectType, clickBack)
    CollegeTypeView.super.ctor(self)

    self.selectTypeData = selectType
    self.clickBack = clickBack

    self.layout = self:loadUI("college_List_Time.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.Image_2 = self.root:getChildByName("Image_2")
    self.Text_dianji_0 = self.Image_2:getChildByName("Text_dianji_0")
    self.Text_dianji_0:setString(g_tr_original("studySelectTime"))

    self.Button_1 = self.root:getChildByName("Button_1")
    self.Button_1_Text_4 = self.Button_1:getChildByName("Text_4")
    self.Button_1_Text_4:setString(g_tr_original("studyUser"))

    self.Button_2 = self.root:getChildByName("Button_2")

    self.ListView_1 = self.root:getChildByName("ListView_1")

    self:initFun()
    self:setData()
    self:addEvent()
end

function CollegeTypeView:initFun()
    self.selectType = function(data, panel)
        self.data = data

        for key, value in pairs(self.uiList) do
            value:clearSelect()
        end

        panel:setVisible(true)
    end
end

function CollegeTypeView:setData()
    self.data = {}
    self.uiList = {}

    for i=1, #g_data.library do
        table.insert(self.data, g_data.library[i])
    end

    for i=1, (#self.data)/2 do
        local item = require("game.uilayer.college.CollegeTypeItemView").new(self.data[i], self.data[i+(#self.data)/2], self.selectType)
        self.ListView_1:pushBackCustomItem(item)
        table.insert(self.uiList, item)
        
        if self.selectTypeData ~= nil then
            if self.selectTypeData.id == self.data[i].id then
                item:selectType(true, false)
            elseif self.selectTypeData.id == self.data[i+(#self.data)/2].id then
                item:selectType(false, true)
            end
        end
    end
end

function CollegeTypeView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                if self.clickBack ~= nil then
                    self.clickBack(self.data)
                    self:close()
                end
            elseif sender == self.Button_2 then
                self:close()
            end
        end
    end

    self.Button_1:addTouchEventListener(proClick)
    self.Button_2:addTouchEventListener(proClick)
end

return CollegeTypeView
--endregion
