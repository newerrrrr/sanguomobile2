
--道具自动转换为将印弹框

local ItemAutoConvertPop = class("ItemAutoConvertPop",require("game.uilayer.base.BaseLayer"))

--items = {{type, id, num},...}
function ItemAutoConvertPop:ctor(items)
    ItemAutoConvertPop.super.ctor(self)

    print("ItemAutoConvertPop") 

    local uiLayer =  g_gameTools.LoadCocosUI("task_rewards.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")

    uiLayer:getChildByName("mask"):addClickEventListener(function()
        self:removeFromParent()
    end)
    
    local closeBtn = baseNode:getChildByName("content_popup"):getChildByName("btn_off")
    closeBtn:getChildByName("Text"):setString(g_tr("confirm"))
    self:regBtnCallback(closeBtn, handler(self, self.close))

    baseNode:getChildByName("content_popup"):getChildByName("bg_title"):getChildByName("Text"):setString(g_tr("itemAutoConvertTitle"))
    
        
    local updateItemView = function(itemView, info)
        if nil == info then return end 

        local item_source = require("game.uilayer.common.DropItemView"):create(info[1], info[2], info[3]) 
        local src_name = item_source and item_source:getName() or ""

        local dropView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.Props, 12200, info[3]) 
        if dropView then
            dropView:enableTip()
            dropView:setCountEnabled(false)
            local size = itemView:getChildByName("bg_rewards"):getContentSize()
            local scale = size.width/dropView:getContentSize().width
            local lbName = itemView:getChildByName("text") 
            local lbNum = itemView:getChildByName("Text_3") 
            dropView:setScaleX(scale)
            dropView:setScaleY(scale)
            itemView:getChildByName("bg_rewards"):addChild(dropView)
            dropView:setPositionX(size.width/2)
            dropView:setPositionY(size.height/2)
            lbName:setString(dropView:getName() .. g_tr("itemAutoConvertDesc", {name = src_name}))
            lbNum:setString("+"..string.formatnumberlogogram(dropView:getCount())) 

            local posx = math.max(lbNum:getPositionX(), 
                    lbName:getPositionX()+lbName:getContentSize().width+lbNum:getAnchorPoint().x*lbNum:getContentSize().width)
            lbNum:setPositionX(posx) 
        end
    end
    
    local listView = baseNode:getChildByName("content_popup"):getChildByName("ListView_1")
    if items then
        local iconItem = cc.CSLoader:createNode("task_rewards_item.csb")
        iconItem:getChildByName("text"):setString("")
        iconItem:getChildByName("Text_3"):setString("")
        iconItem:getChildByName("pic_rewards"):setVisible(false)

        for k, v in pairs(items) do 
            local iconItem_new = iconItem:clone()
            updateItemView(iconItem_new, v)
            listView:pushBackCustomItem(iconItem_new)
        end 
    end
end

return ItemAutoConvertPop

