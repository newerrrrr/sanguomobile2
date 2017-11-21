--region 神武将升级
--Author : liuyi
--Date   : 2016/10/31

local GodGeneralLvUp = class("GodGeneralLvUp",require("game.uilayer.base.BaseLayer"))

function GodGeneralLvUp:ctor(generalData)
    GodGeneralLvUp.super.ctor(self)

    self.generalConfig = clone(generalData.cdata)
    self.generalServer = clone(generalData.ndata)
    self.isNeedUpdate = false

    self.exp = {
        [51021] = 0,
        [51022] = 0,
        [51023] = 0,
        [51024] = 0,
        [51025] = 0,
    }

    self.filterData = {}

    for _,config in pairs(g_data.item) do
        if tonumber(config.item_original_id) == tonumber(g_Consts.UseItemType.GodGenerralExp) then
            table.insert( self.filterData ,config )
            local dropId = g_data.item[tonumber( config.id )].drop[1]
            local dropConfig = g_data.drop[ tonumber(dropId) ].drop_data[1]
            self.exp[config.id] = dropConfig[3]
        end 
    end
    
    table.sort(self.filterData,function (a,b)
        return  a.priority <  b.priority
    end)
    
    self:initUI()
end

function GodGeneralLvUp:initUI()

    self.layer = self:loadUI("general_01.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("Button_2")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        if self._callback then
            self._callback(self.isNeedUpdate)
        end
		self:close()
	end)
    
    self.root:getChildByName("Image_2"):getChildByName("Text_dianji_0"):setString(g_tr("ItemModeTitle"))
    self.root:getChildByName("Text_dianji"):setString(g_tr("ItemModeUse"))

    self.list = self.root:getChildByName("ListView_1") 
    --self.desc = self.root:getChildByName("Text_4_0_1")
    self.lvTxMode = self.root:getChildByName("Text_degjibh")
    self.expTxMode = self.root:getChildByName("Text_8")
    self.expBar = self.root:getChildByName("LoadingBar_1")
    self.expBar1 = self.root:getChildByName("LoadingBar_2")
    self.lessBtn = self.root:getChildByName("Panel_2"):getChildByName("Image_97")
    self.plusBtn = self.root:getChildByName("Panel_2"):getChildByName("Image_97_0")

    self.lessBtn:addTouchEventListener( handler(self,self.TouchLess))
    self.plusBtn:addTouchEventListener( handler(self,self.TouchPlus))

    self.upBtn = self.root:getChildByName("Button_1")
    self.upBtn:getChildByName("Text_4"):setString( g_tr("bagUse") )

    self:regBtnCallback(self.upBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        if self.itemCount > 0 then
            local function callback(result,msgData)
                if true == result then
                    g_airBox.show(g_tr("godGeneralItemUseOk"))
                    self:updateUI()
                    self.isNeedUpdate = true
                end
            end
            g_sgHttp.postData("Pub/generalAddExp", { generalId = self.generalConfig.general_original_id,itemId = self.selItemId,num = self.itemCount }, callback)
        else
            
        end
    end)

    local editmode = self.root:getChildByName("Panel_2"):getChildByName("TextField_1")
    editmode:setVisible(false)
    self.edit = g_gameTools.convertTextFieldToEditBox(editmode)
    self.edit:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.slider = self.root:getChildByName("Panel_2"):getChildByName("Slider_1")
    
    --富文本框节点
    --self.expTx = g_gameTools.createRichText(self.expTxMode,nil)
    self.lvTx = g_gameTools.createRichText(self.lvTxMode,nil)

    self:showExpAndLv()
    self:loadList()
    
    self.slider:addEventListenerSlider( function ( sender,eventType )
        if eventType == ccui.SliderEventType.percentChanged then
            self:setSlider()
        end
    end )

    self.edit:registerScriptEditBoxHandler( function (eventType)
        if eventType == "customEnd" then
            self:setEdit()
        end
    end )
    
end

function GodGeneralLvUp:loadList()
     
    local itemmode = cc.CSLoader:createNode("Time.csb")

    self.selNode = nil

    local function touchItemListener(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.selNode ~= sender then
                self.selNode.high:setVisible(false)
                self.selNode = sender
                self.selNode.high:setVisible(true)
                self.selItemId = self.selNode.cdata.id
                self:addGeneralExp()
            end
        end
    end

    local update = function (node,count)
        if count == nil then
            count = g_BagMode.findItemNumberById( self.selItemId )
        end
        node.item:setCount( count )
    end


    for i,data in pairs(self.filterData) do
        
        local item_panel = itemmode:clone()

        local item_type = g_Consts.DropType.Props

        local item_id = data.id

        local item_num = g_BagMode.findItemNumberById(data.id)

        local item = require("game.uilayer.common.DropItemView").new(item_type, item_id,item_num)

        local item_root = item_panel:getChildByName("scale_node")

        local item_border = item_root:getChildByName("Image_1_0")

        item:setPosition(  cc.p( item_border:getContentSize().width/2 ,item_border:getContentSize().height/2 ) )

        item:setNameVisible(true)
        
        item_panel:setSize( cc.size(  item:getContentSize().width + 35,item_panel:getContentSize().height ) )

        item_border:addChild(item)

        item_root:setTouchEnabled(true)

        item_root:addTouchEventListener(touchItemListener)

        local high = item_root:getChildByName("Image_2")
        
        high:setVisible(false)

        item_root.item = item

        item_root.high = high

        item_root.cdata = data
        
        item_root.update = update

        if self.selNode == nil then
            self.selNode = item_root
            self.selNode.high:setVisible(true)
        end

        self.list:pushBackCustomItem(item_panel)
    end

    if self.selNode then
        self.selItemId = self.selNode.cdata.id
        self:addGeneralExp()
    end
    
end

function GodGeneralLvUp:showExpAndLv()
    
    self.lvTx:setRichText( "Lv."..tostring( self.generalServer.lv ) )
    local nowLvConfig  = g_data.general_exp[ self.generalServer.lv ]
    local nextLvConfig = g_data.general_exp[ self.generalServer.lv + 1 ]


    --当前神武将经验
    --local nowExp = 0
    --下一等级需要的经验
    --local nextLvExp = 0
    
    if nextLvConfig then
        self.nextLvExp = nextLvConfig.general_exp - nowLvConfig.general_exp
        self.nowExp = self.generalServer.exp - nowLvConfig.general_exp
        self.expTxMode:setString( string.format( "%d/%d", self.nowExp,self.nextLvExp))
        --self.expTx:setRichText( string.format( "%d/%d", self.nowExp,self.nextLvExp))
        self.expBar:setPercent( (self.nowExp/self.nextLvExp) * 100 )
    end
end

function GodGeneralLvUp:addGeneralExp(count)
    
    local cData = g_data.item[self.selItemId]
    
    --总经验
    local totleExp = g_data.general_exp[table.nums(g_data.general_exp)].general_exp
    --到达总经验的剩余经验
    local needExpToMaxNum = totleExp - self.generalServer.exp
    --计算需要使用当前道具的总数
    local needExpItemCount = math.ceil( needExpToMaxNum / self.exp[self.selItemId] )
    
    self.itemMaxCount = math.min( needExpItemCount,g_BagMode.findItemNumberById(self.selItemId) )

    self.itemCount = count or self.itemMaxCount

    self.addExpValue = self.itemCount * self.exp[self.selItemId]
    
    self.edit:setString( tostring(self.itemCount) )

    self.slider:setPercent( ( self.itemCount / self.itemMaxCount ) * 100 )
    
    self.expBar1:setPercent( (self.nowExp + self.addExpValue) /self.nextLvExp * 100 )

    --local expStr = (self.addExpValue > 0) and string.format( "%d+ |<#0,255,0#>%d|/%d",self.nowExp,self.addExpValue,self.nextLvExp ) or string.format( "%d/%d",self.nowExp,self.nextLvExp )
    --godGeneralGetExpStr
    local expStr = g_tr( "godGeneralGetExpStr",{ exp = self.addExpValue } )

    self.expTxMode:setString(expStr)
    self.expTxMode:setVisible( self.addExpValue > 0 )
    --self.expTx:setRichText(expStr)
    
    local toLevel = 0
    local nowLevel = self.generalServer.lv
    if nowLevel + 1 < #g_data.general_exp then
        for i = nowLevel + 1,#g_data.general_exp do
            if self.generalServer.exp + self.addExpValue >= g_data.general_exp[i].general_exp then
                toLevel = i
            else
                break
            end
        end
    end

    --self.desc:setString( g_tr(cData.item_introduction) .. string.formatnumberlogogram(self.addExpValue) )

    local addStr = (toLevel > 0) and string.format( "Lv.%d  |<#0,255,0#>→ Lv.%d|",nowLevel,toLevel) or "Lv." .. tostring(nowLevel)
    --self.expBar1:setPercent(  (self.nowExp + self.addExpValue) /self.nextLvExp * 100 )
    self.lvTxMode:setString( addStr )
    self.lvTx:setRichText( addStr )

end




function GodGeneralLvUp:setSlider()
    
    local icount = math.floor( ( self.slider:getPercent() / 100 ) * self.itemMaxCount )

    if icount <= 0 then
        icount = 0
        if self.itemMaxCount > 0 then
            icount = 1
        end
    end

    self:addGeneralExp(icount)
end

function GodGeneralLvUp:setEdit()
    
    local icount = tonumber( self.edit:getString() ) or 0
    
    icount = math.floor(icount)

    if icount > self.itemMaxCount then
        icount = self.itemMaxCount
    end

    if icount <= 0 then
        icount = 0
        if self.itemMaxCount > 0 then
            icount = 1
        end
    end

    self:addGeneralExp(icount)
end

function GodGeneralLvUp:TouchPlus(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        --print("TouchPlus")
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local icount = tonumber( self.edit:getString() ) or 0
        icount = math.floor(icount) + 1
        
        if icount > self.itemMaxCount then
            icount = self.itemMaxCount
        end

        self:addGeneralExp(icount)
    end
end


function GodGeneralLvUp:TouchLess(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
         --print("TouchLess")
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local icount = tonumber( self.edit:getString() ) or 0
        icount = math.floor(icount) - 1

        if icount <= 0 then
            icount = 0
            if self.itemMaxCount > 0 then
                icount = 1
            end
        end

        self:addGeneralExp(icount)
    end
end



function GodGeneralLvUp:addCallBack(fun)
    self._callback = fun
end


function GodGeneralLvUp:updateUI()
    local count = g_BagMode.findItemNumberById( self.selItemId )
    self.selNode:update(count)
    self.generalServer = clone(g_GeneralMode.getOwnedGeneralByOriginalId(self.generalConfig.general_original_id))
    self:showExpAndLv()
    self:addGeneralExp( math.min(count,self.itemCount) )
end

return GodGeneralLvUp