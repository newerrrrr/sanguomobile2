--region UseItemView.lua
--Author : luqingqing
--Date   : 2016/1/22
--此文件由[BabeLua]插件自动生成

local UseItemView = class("UseItemView", require("game.uilayer.base.BaseWidget"))

function UseItemView:ctor(useItem, buyItem)
    self.layer = self:LoadUI("Resources_list.csb")
    self.root = self.layer:getChildByName("scale_node")

    self.useItem = useItem
    self.buyItem = buyItem

    for i=1, 2 do
        self["Panel_"..i] = self.root:getChildByName("Panel_"..i)
        self["Panel_"..i.."_Image_3_0"] = self["Panel_"..i]:getChildByName("Image_3")
        self["Panel_"..i.."_Text_n1"] = self["Panel_"..i]:getChildByName("Text_n1")
        self["Panel_"..i.."_Text_n1_0"] = self["Panel_"..i]:getChildByName("Text_n1_0")
        self["Panel_"..i.."_Button_2"] = self["Panel_"..i]:getChildByName("Button_2")
        self["Panel_"..i.."Button_2_Text_5"] = self["Panel_"..i.."_Button_2"]:getChildByName("Text_5")
        self["Panel_"..i.."_Button_2_0"] = self["Panel_"..i]:getChildByName("Button_2_0")
        self["Panel_"..i.."Button_2_0_Text_5"] = self["Panel_"..i.."_Button_2_0"]:getChildByName("Text_5")
        self["Panel_"..i.."Button_2_0_Text_9"] = self["Panel_"..i.."_Button_2_0"]:getChildByName("Text_9")
        self["Panel_"..i.."Button_2_0_Image_9"] = self["Panel_"..i.."_Button_2_0"]:getChildByName("Image_9")
        self["Panel_"..i.."Button_2_0_Text_5"]:setString(g_tr_original("getAndBuy"))
    end

    self:addEvent()
end

function UseItemView:show(data1, data2)
    self.data1 = data1
    self.data2 = data2

    self["Panel_1_Image_3_0"]:removeAllChildren(true)
    self["Panel_2_Image_3_0"]:removeAllChildren(true)
    
    self.root:getChildByName("Panel_1"):getChildByName("Panel_yj"):setVisible(false)
    self.root:getChildByName("Panel_2"):getChildByName("Panel_yj"):setVisible(false)

    self:setData(self.data1, "Panel_1")
    self:setData(self.data2, "Panel_2")
end

--type,configId,count
function UseItemView:setData(shopId, ui)

    if shopId == nil then
        self[ui]:setVisible(false)
        return
    end

    --初始化整个UI
    self[ui.."_Button_2"]:setVisible(true)
    self[ui.."_Button_2_0"]:setVisible(true)

    --check start
    local dropId = g_data.shop[shopId].commodity_data
    local dropGroups = g_data.drop[dropId].drop_data
    if #dropGroups > 1 then
        g_airBox.show("商品drop里配置了多个符合条件的掉落物品，界面上只能显示一个！！")
    end
    local dropGroup = dropGroups[1]
    local type = dropGroup[1]
    local configId = dropGroup[2]
    local count = dropGroup[3]
    assert(type == g_Consts.DropType.Resource or type == g_Consts.DropType.Props,"Quick_bug只能配置资源和道具类型商品")
    --check end
    
    local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId)
    assert(shopItemData)
    
    local bagData = g_BagMode.FindItemByID(configId)

    local dropItem = nil
    if bagData == nil or bagData.num ==0 then
        self[ui.."_Button_2"]:setVisible(false)
        dropItem = require("game.uilayer.common.DropItemView").new(type, configId, 0)
        dropItem:setCountEnabled(false)
        
        self.root:getChildByName(ui):getChildByName("Panel_yj"):setVisible(shopItemData:getMaxPrice() and shopItemData:getPrice() < shopItemData:getMaxPrice())
        if shopItemData:getMaxPrice() then
            self.root:getChildByName(ui):getChildByName("Panel_yj"):getChildByName("Text_n1_1"):setString(g_tr("marketOriginalPrice",{price = shopItemData:getMaxPrice()}))
        end
    
--        --40231-40238
--        local key = 0
--        if shopId >= 2050 and shopId <= 5057 then
--            --勾玉
--            key = (g_data.shop[shopId].cost_id%1000) - 19
--            key = key+40200
--        else
--            --资源
--            key = g_data.shop[shopId].cost_id%1000
--            key = key+40100
--        end
--        
--        self[ui.."Button_2_0_Text_9"]:setString(g_data.cost[key].cost_num.."")
--        self[ui.."Button_2_0_Image_9"]:loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + g_data.cost[key].cost_type))
        
        local costNum = shopItemData:getPrice()
        self[ui.."Button_2_0_Text_9"]:setString(costNum.."")
        self[ui.."Button_2_0_Image_9"]:loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + shopItemData:getCostType()))
    else
        self[ui.."_Button_2_0"]:setVisible(false)
        dropItem = require("game.uilayer.common.DropItemView").new(type, configId, bagData.num)
    end
    dropItem:setPosition(dropItem:getContentSize().width/2, dropItem:getContentSize().height/2)
    self[ui.."_Image_3_0"]:addChild(dropItem)
    self[ui.."_Text_n1"]:setString(dropItem:getName())
    self[ui.."_Text_n1_0"]:setString(dropItem:getDesc())
end

function UseItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self["Panel_1_Button_2"] then
                if self.useItem ~= nil then
                    if self.useItem ~= nil then
                        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                        self.useItem(self.data1, self, "Panel_1")
                    end
                end
            elseif sender == self["Panel_1_Button_2_0"] then
                local function clickHandler()
                    if self.buyItem ~=nil then
                        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                        self.buyItem(self.data1)
                    end
                end

                --local key = g_data.shop[self.data1].cost_id%1000
                --key = key+40100
--                local data = self.data1
--                local key = 0
--                if data >= 2050 and data <= 5057 then
--                    --勾玉
--                    key = (g_data.shop[data].cost_id%1000) - 19
--                    key = key+40200
--                else
--                    --资源
--                    key = g_data.shop[data].cost_id%1000
--                    key = key+40100
--                end
                
                local shopId = self.data1
                local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId)
                g_msgBox.showConsume(shopItemData:getPrice(), g_tr("txtShopBuyTip"), "", g_tr("shopBuyAndUse"), clickHandler)
            elseif sender == self["Panel_2_Button_2"] then
                if self.useItem ~= nil then
                    if self.useItem ~= nil then
                        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                        self.useItem(self.data2, self, "Panel_2")
                    end
                end
            elseif sender == self["Panel_2_Button_2_0"] then
                local function clickHandler(event)
                    if self.buyItem ~=nil then
                        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                        self.buyItem(self.data2)
                    end
                end

--                --local key = g_data.shop[self.data2].cost_id%1000
--                --key = key+40100
--                local key = 0
--                local data = self.data2
--                if data >= 2050 and data <= 5057 then
--                    --勾玉
--                    key = (g_data.shop[data].cost_id%1000) - 19
--                    key = key+40200
--                else
--                    --资源
--                    key = g_data.shop[data].cost_id%1000
--                    key = key+40100
--                end
                local shopId = self.data2
                local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId)
                g_msgBox.showConsume(shopItemData:getPrice(), g_tr("txtShopBuyTip"), "", g_tr("shopBuyAndUse"), clickHandler)
            end
        end
    end

    self["Panel_1_Button_2"]:addTouchEventListener(proClick)
    self["Panel_1_Button_2_0"]:addTouchEventListener(proClick)
    self["Panel_2_Button_2"]:addTouchEventListener(proClick)
    self["Panel_2_Button_2_0"]:addTouchEventListener(proClick)
end

function UseItemView:updateNum(ui, selectData)
    self:setData(selectData, ui)
end

return UseItemView

--endregion
