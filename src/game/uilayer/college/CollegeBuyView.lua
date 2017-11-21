--region CollegeBuyView.lua
--Author : luqingqing
--Date   : 2015/11/5
--此文件由[BabeLua]插件自动生成

local CollegeBuyView = class("CollegeBuyView", function() 
    return ccui.Widget:create()
end)

function CollegeBuyView:ctor(data)
    self.data = data

    self.layout = cc.CSLoader:createNode("college_List_buy.csb")
    self:addChild(self.layout)

    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))

    self.root = self.layout:getChildByName("scale_node")

    self.Panel_8 = self.root:getChildByName("Panel_8")
    self.Panel_8_Text_8 = self.Panel_8:getChildByName("Text_8")
    self.Panel_8_Text_8:setString(g_tr_original("studyBuy"))

    self.Text_4 = self.root:getChildByName("Text_4")
    self.Text_4:setString(self.data.cost_num.."")

    self.Button_1 = self.root:getChildByName("Button_1")
    self.Button_1_Text_2 = self.Button_1:getChildByName("Text_2")
    self.Button_1_Text_2:setString(g_tr_original("buy"))
end

function CollegeBuyView:show(fun)
    self.fun = fun

    self:addEvent()
end

function CollegeBuyView:updateData(data)
    self.data = data
    self.Text_4:setString(self.data.cost_num.."")
end

function CollegeBuyView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                if self.fun ~= nil then
                    self.fun(self)
                end
            end
        end
    end

    self.Button_1:addTouchEventListener(proClick)
end

function CollegeBuyView:getData()
    return self.data
end

return CollegeBuyView

--endregion
