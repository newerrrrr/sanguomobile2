--region BabItemInfoView.lua
--Author : luqingqing
--Date   : 2015/12/28
--此文件由[BabeLua]插件自动生成

local BabItemInfoView = class("BabItemInfoView", require("game.uilayer.base.BaseLayer"))

function BabItemInfoView:ctor(item, useItem)
    self.data = item
    self.useItem = useItem

    BabItemInfoView.super.ctor(self)

    self.max = 99

    self.layout = self:loadUI("Useprops_Panel02.csb")
    self.root = self.layout:getChildByName("scale_node")
    self.close_btn = self.root:getChildByName("close_btn")
    self.title = self.root:getChildByName("bg_goods_name"):getChildByName("text")
    self.Image_1 = self.root:getChildByName("Image_1")
    self.Text_6 = self.root:getChildByName("Text_6")
    self.goods_info = self.root:getChildByName("goods_info")

    self.Panel_1 = self.root:getChildByName("Panel_1")
    self.btn_reduce = self.Panel_1:getChildByName("btn_reduce")
    self.btn_add = self.Panel_1:getChildByName("btn_add")
    self.Slider_1 = self.Panel_1:getChildByName("Slider_1")
    self.Text_4 = self.Panel_1:getChildByName("Text_4")

    self.btn_buy = self.root:getChildByName("btn_buy")
    self.Text_3 = self.root:getChildByName("Text_3")

    self.title:setString(g_tr("bagItemDetail"))

    self:initData()
    self:addEvent()
end

function BabItemInfoView:initData()
    
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Resource, self.data.item_id,self.data.num)
    self.Image_1:addChild(item)
    item:setPosition(self.Image_1:getContentSize().width/2, self.Image_1:getContentSize().height/2)
    item:setCountEnabled(false)

    --随机迁城特殊处理
    --VIP道具特殊处理(不需要滚动条选择数量)
    local iData = g_data.item[tonumber(self.data.item_id)]
    if iData.item_use_num == 1 then
        self.Panel_1:setVisible(false)
        self.count = 1
    else
        self.Panel_1:setVisible(true)
        if self.data.num > self.max then
            self.count = self.max
        else
            self.count = self.data.num
        end
        
    end

    if self.data.num > self.max then
        self.data.num = self.max
    end

    self.Text_6:setString(item:getName())
    self.goods_info:setString(item:getDesc())
    
    self.Text_4:setString(self.count.."/"..self.data.num)

    if self.data.num == 1 then
        self.Slider_1:setPercent(100)
    else
        self.Slider_1:setPercent(self.count/self.data.num*100)
    end
end

function BabItemInfoView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            elseif sender == self.btn_reduce then
                if self.count >1 then
                    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                    self.count = self.count - 1
                    self.Slider_1:setPercent((self.count)*100/(self.data.num))
                    self.Text_4:setString(self.count.."/"..self.data.num)
                end
            elseif sender == self.btn_add then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.count < self.data.num then
                    self.count = self.count + 1
                    self.Slider_1:setPercent((self.count)*100/(self.data.num))
                    self.Text_4:setString(self.count.."/"..self.data.num)
                end
            elseif sender == self.btn_buy then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                
                local doUseHandler = function()
                     if self.useItem ~= nil then
                        self.useItem(self.data.item_id, self.count)
                     end
                     self:close()
                end
               
                local itemInfo = g_data.item[self.data.item_id]
                if itemInfo then  --新手保护期间，不能使用战胜保护道具
                   if itemInfo.item_original_id == 218 then 
                       if g_PlayerMode.hasNewPlayerAvoid() then
                           g_airBox.show(g_tr("battleAvoidUseCondition"))
                           return
                       end
                   end
                end
            
                if itemInfo.item_original_id == 218 then 
                    if g_PlayerMode.hasAvoid() then
                        g_msgBox.show(g_tr("protectedUsed"), nil, nil, 
                        function(event)
                            if event == 0 then
                                doUseHandler()
                            end
                        end, 1)
                        return   
                    else
                        doUseHandler()
                    end
                else
                    doUseHandler()
                end
            end
        end
    end

    local function valueChange(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            self.count = math.floor(self.Slider_1:getPercent() * (self.data.num )/100)
            if self.count < 1 then
                self.count = 1
                self.Slider_1:setPercent(self.count/self.data.num*100)
            end
            self.Text_4:setString(self.count.."/"..self.data.num)
        end
    end

    self.close_btn:addTouchEventListener(proClick)
    self.btn_reduce:addTouchEventListener(proClick)
    self.btn_add:addTouchEventListener(proClick)
    self.btn_buy:addTouchEventListener(proClick)

    self.Slider_1:addEventListener(valueChange)

    if self.data.num == 1 then
         self.Slider_1:setEnabled(false)
    end
end

return BabItemInfoView

--endregion
