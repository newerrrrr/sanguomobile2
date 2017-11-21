local FaqView = class("FaqView", require("game.uilayer.base.BaseLayer"))

function FaqView:ctor()
	FaqView.super.ctor(self)

	self.titleList = {}

	self.layer = self:loadUI("power1.csb")
    self.root = self.layer:getChildByName("scale_node")

    self.close_btn = self.root:getChildByName("close_btn")
    self.ListView_left =self.root:getChildByName("ListView_left")
    self.Text_1 = self.root:getChildByName("Text_1")
    --self.Text_title = self.root:getChildByName("Text_title")
    self.ListView_1 = self.root:getChildByName("ListView_1")

    self.Text_1:setString(g_tr("tuoHelp"))

    self.data = g_data.faq_guide

    self.curData = self.data[1]

    -- self.content = require("game.uilayer.power.FaqItemView").new()
    -- self.ListView_1:pushBackCustomItem(self.content)
    -- self.content:show(self.curData.desc_id)
    self:showListContent(g_tr(self.curData.desc_id))

    self:addEvent()
    self:initFun()
    self:setData()
end

function FaqView:initFun()
    self.clickTitle = function(data)
        self.titleList[self.curData.id]:setState(false)
        self.curData = data
        self.titleList[self.curData.id]:setState(true)
        --self.Text_title:setString(g_tr(self.curData.name_id))
        --self.showtime_tx:setRichText(g_tr(data.desc_id))
        self:showListContent(g_tr(data.desc_id))
        --self.ListView_1:pushBackCustomItem(self.content)

    end
end

function FaqView:showListContent(str)
    self.ListView_1:removeAllChildren()
    local widthMax = self.ListView_1:getContentSize().width 
    local node = ccui.Widget:create() 
    local richText = g_gameTools.createNoModeRichText(str, {fontSize = 24, width = widthMax , height = 0})
    richText:setAnchorPoint(cc.p(0.5, 0.5)) 
    local size = richText:getRichSize()
    local newSize = cc.size(size.width, size.height+16)
    richText:setPosition(cc.p(newSize.width/2, newSize.height))                    
    node:setContentSize(newSize)
    node:addChild(richText)
    self.ListView_1:pushBackCustomItem(node) 
end 



function FaqView:setData()
	local title = nil
    for i=1, #self.data do
        title = require("game.uilayer.power.PowerTitleView").new(self.data[i], self.clickTitle)
        if i == self.curData.id then
            title:setState(true)
        else
            title:setState(false)
        end
        self.ListView_left:pushBackCustomItem(title)

        table.insert(self.titleList, title)
    end
end

function FaqView:addEvent()
	local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                self:close()
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
end

return FaqView