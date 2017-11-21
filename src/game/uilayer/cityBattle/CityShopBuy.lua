local CityShopBuy = class("CityShopBuy",require("game.uilayer.base.BaseLayer"))


function CityShopBuy:ctor(drop,fun,count,cost)
    CityShopBuy.super.ctor(self)
    self.dropConfig = drop
    self.fun = fun
    self.count = tonumber(count) > 100 and 100 or tonumber(count)
    self.buyCount = 1
    self.cost = cost
end

function CityShopBuy:onEnter()
    self:initUI()
end

function CityShopBuy:initUI()
    self.layer = self:loadUI("alliance_store_check_popup.csb")
    self.root = self.layer:getChildByName("scale_node")
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:addClickEventListener( function ( sender )
        g_musicManager.playEffect( g_SOUNDS_CANCLE_PATH )
        self:close()
    end)

    self.root:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("bagItemDetail"))
    self.root:getChildByName("goods_cannot_buy"):setVisible(false)
    self.root:getChildByName("Text_shuzi"):setVisible(false)
    self.root:getChildByName("price"):setString( tostring(self.cost[1]) )
    self.root:getChildByName("ico_gold"):loadTexture(self.cost[2])
    self.root:getChildByName("Image_4"):loadTexture(self.cost[2])

    local t = self.dropConfig[1]
    local id = self.dropConfig[2]
    local num = self.dropConfig[3]
    local icon = require("game.uilayer.common.DropItemView").new(t,id,num)
    local image = self.root:getChildByName("goods_pic")
    icon:setPosition( cc.p( image:getContentSize().width/2,image:getContentSize().height/2 ) )
    image:addChild( icon )
    local name = self.root:getChildByName("Text_6")
    name:setString( icon:getName() )
    --getDesc
    local desc = self.root:getChildByName("goods_info")
    desc:setString( icon:getDesc() )
    
    local barPanel = self.root:getChildByName("Panel_1")
    local countEdit = g_gameTools.convertTextFieldToEditBox( barPanel:getChildByName("TextField_1") )
    local costNumTx = self.root:getChildByName("Text_num")
    local bar = barPanel:getChildByName("Slider_1")
    
    local function changeBar()
        countEdit:setString( tostring( self.buyCount ) )
        costNumTx:setString(  tostring( self.buyCount * self.cost[1] ) )
        bar:setPercent( self.buyCount / self.count * 100 )  
    end

    countEdit:registerScriptEditBoxHandler(function ( eventType )
        if eventType == "customEnd" then
             local count = tonumber( countEdit:getString() )
             if count == nil or count <= 0 then
                count = 1
             end

             if count >= self.count then
                count = self.count
             end

             self.buyCount = count
             changeBar()

        end
    end)


    local addBtn = barPanel:getChildByName("btn_add")
    addBtn:addClickEventListener( function ()
        self.buyCount = self.buyCount + 1
        if self.buyCount >= self.count then
            self.buyCount = self.count
        end
        changeBar()
    end )
    local lessBtn =  barPanel:getChildByName("btn_reduce")
    lessBtn:addClickEventListener( function ()
        self.buyCount = self.buyCount - 1
        if self.buyCount <= 1 then
            self.buyCount = 1
        end
        changeBar()
    end )
    changeBar()

    local buyBtn = self.root:getChildByName("btn_buy")
    buyBtn:getChildByName("Text_3"):setString(g_tr("makeSureBuy"))
    buyBtn:addClickEventListener( function ()
        if self.fun then
            self.fun(self.buyCount)
            self:close()
        end
    end )

    local function valueChange(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            self.buyCount = math.floor( bar:getPercent() * self.count /100)
            if self.buyCount <= 0 then
                self.buyCount = 1
            end
            changeBar()
        end
    end

    bar:addEventListener(valueChange)

end





return CityShopBuy