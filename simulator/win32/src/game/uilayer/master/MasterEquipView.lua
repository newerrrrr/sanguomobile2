local MasterEquipView = class("MasterEquipView", require("game.uilayer.base.BaseLayer"))


function MasterEquipView:ctor(data,pos,callback)
    self.super.ctor(self)
    self.curEquipData = data
    self.curPos = pos
    self.callback = callback
    self.curAllEquipData = {}   --当前已经装备的所有宝物数据 用来不能装备同一种宝物判断
    self.master_equip_data = clone( g_MasterEquipMode.GetData() )

    table.sort( self.master_equip_data,function (a,b)
        local configA = g_data.equip_master[tonumber( a.equip_master_id )]
        local configB = g_data.equip_master[tonumber( b.equip_master_id )]
        local qzA = configA.quality_id * ( a.status == 1 and 10000000 or 1 ) + tonumber( a.equip_master_id )
        local qzB = configB.quality_id * ( b.status == 1 and 10000000 or 1 ) + tonumber( b.equip_master_id )

        return qzA > qzB
    end )

    
    self:initUI()
    g_guideManager.execute()
end

function MasterEquipView:initUI()
    
    self.layer = self:loadUI("zhugong_bg_zbsb.csb")
    
    self.root = self.layer:getChildByName("scale_node")
    
    local close_btn = self.root:getChildByName("close_btn")
	
    self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
    
    local getBtn = self.root:getChildByName("Button_zh")
    getBtn:getChildByName("Text_1"):setString(g_tr("MastergetEquip"))
    self:regBtnCallback(getBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

        local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.MasterEquipment,nil,nil)
        g_sceneManager.addNodeForUI(view)

		--g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SHOP,{tag = 6})
	end)
    --Button_zh


    self.selEquipData = nil

    --装备
    self.equipBtn = self.root:getChildByName("Button_md")
    g_guideManager.registComponent( (9999500 + 1) ,self.equipBtn)

    self.equipBtn:getChildByName("Text_15"):setString(g_tr("MasterEquip"))

    self:regBtnCallback(self.equipBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

		if self.selEquipData then
            --查找当前装备的宝物是否有相同的宝物
            for key, var in ipairs(self.curAllEquipData) do
                if tonumber(var.position) ~= self.curPos and  tonumber(var.equip_master_id) == tonumber(self.selEquipData.equip_master_id)  then
                    g_airBox.show(g_tr("MasterNotCanEquip"))
                    return
                end
            end
            
            local tb = { new_id = self.selEquipData.id,position = self.curPos }
            tb.old_id = self.curEquipData and self.curEquipData.id or 0 --判断是否是替换还是直接穿
            
            local function callback( result,data )
                if true == result then
                    if self.callback then
                        self.callback()
                    end                    
                    self:close()
                    g_guideManager.execute()
                end
            end

            g_sgHttp.postData("player/equipMasterOn",tb,callback)

        end
	end)


    --卸下
    self.equipOffBtn = self.root:getChildByName("Button_md_0")
    self.equipOffBtn:getChildByName("Text_15"):setString(g_tr("MasterEquip1"))
    if self.curEquipData == nil then
        self.equipOffBtn:setVisible(false)
        self.equipBtn:setPositionX( 366 )
    end
    
    self:regBtnCallback(self.equipOffBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

        if self.curEquipData then
            local function callback( result,data )
                if true == result then
                    if self.callback then
                        self.callback()
                    end
                    self:close()
                end
            end
            g_sgHttp.postData("player/equipMasterOff",{ id = self.curEquipData.id }, callback)
        end
    end)

    
    --zhcn
    self.root:getChildByName("Text_zg"):setString(g_tr("MasterEquipTitle"))
    self.root:getChildByName("Text_zb1"):setString(g_tr("MasterCurEquip"))
    self.root:getChildByName("Text_db1"):setString(g_tr("MasterChangeEquip"))
    self.root:getChildByName("Text_s1"):setString(g_tr("MasterNature"))
    self.root:getChildByName("Text_d1"):setString(g_tr("MasterNature"))

    self.list = self.root:getChildByName("ListView_1")
    self:showList()
    self:showAlreadyEquip()
    self:showSelEquip()

end


function MasterEquipView:showAlreadyEquip()
    
    local sx = {}

    for i = 1, 4 do
        local strTx = self.root:getChildByName( string.format( "Text_s1_%d",i) )
        strTx:setVisible(false)
        table.insert( sx, strTx)
    end

    self.root:getChildByName("Image_h1"):setVisible(false)
    self.root:getChildByName("Text_s1"):setString( g_tr("MasterNoEquip") )

    if self.curEquipData then
        self.root:getChildByName("Image_h1"):setVisible(true)
        self.root:getChildByName("Text_s1"):setString(g_tr("MasterNature"))

        local ePosNode = self.root:getChildByName("item_1")
        local equipType = g_Consts.DropType.MasterEquipment
        local equipID = tonumber(self.curEquipData.equip_master_id)
        local equipCount = 1
        local equip = require("game.uilayer.common.DropItemView").new(equipType, equipID,equipCount)
        equip:setPosition(cc.p( ePosNode:getContentSize().width/2,ePosNode:getContentSize().height/2 ))
        equip:setCountEnabled(false)
        equip:setNameVisible(true)
        ePosNode:addChild(equip)
        
        local buffStrList,numList =  g_MasterEquipMode.GetEquipSkillListById(self.curEquipData.id)

        for index, buff in ipairs(buffStrList) do
            sx[index]:setVisible(true)

            local txColor = {r = 255,g = 255 , b = 255}
            --cc.c3b(255,255,255)
            local value = numList[index].value
            local range = numList[index].range
            local min = numList[index].min
            local max = numList[index].max
            local buff_type = numList[index].buff_type

            local cValue = (value - min) < 0 and 0 or (value - min)
            cValue = cValue/(max - min) * 100
            
            if  cValue <= 20  then
                --txColor = cc.c3b(255,255,255)
                txColor.r = 255
                txColor.g = 255
                txColor.b = 255

                --白
            elseif cValue > 20 and  cValue <= 40 then
                --txColor = cc.c3b(14,246,91)
                txColor.r = 14
                txColor.g = 246
                txColor.b = 91
                --绿
            elseif cValue > 40 and  cValue <= 60 then
                --txColor = cc.c3b(12,198,244)
                txColor.r = 12
                txColor.g = 198
                txColor.b = 244
                --蓝
            elseif cValue > 60 and  cValue <= 80 then
                --txColor = cc.c3b(185,63,255)
                txColor.r = 185
                txColor.g = 63
                txColor.b = 255
                --紫
            elseif cValue > 80 then
                --txColor = cc.c3b(255,126,0)
                txColor.r = 255
                txColor.g = 126
                txColor.b = 0
                --橙
            end
            
            local _num = string.format( "|<#%d,%d,%d#>%.2f|", txColor.r, txColor.g,txColor.b,value)
            if buff_type == 1 then
                _num = string.format( "|<#%d,%d,%d#>%.2f%%%%|", txColor.r, txColor.g,txColor.b,value)
            end
            
            local showStr = g_tr( numList[index].str,{ num = _num })
            sx[index]:setTextColor(cc.c3b(255,255,255))
            local rich = g_gameTools.createRichText(sx[index],showStr ..range )
            
        end

    end
end

function MasterEquipView:showSelEquip()
    
    local data = self.selEquipData
    local sx = {}

    for i = 1, 4 do
        local strTx = self.root:getChildByName(string.format("Text_d1_%d",i))
        local upImg = self.root:getChildByName(string.format("Image_j%d",i))
        local downImg = self.root:getChildByName(string.format("Image_j%d_0",i))

        strTx:setVisible(false)
        upImg:setVisible(false)
        downImg:setVisible(false)

        if strTx.rich then
            strTx.rich:removeFromParent()
            strTx.rich = nil
        end

        table.insert( sx, { tx = strTx,up = upImg,down = downImg })
    end

    self.root:getChildByName("Image_h2"):setVisible(false)
    self.root:getChildByName("Text_d1"):setString( g_tr("MasterNoEquip") )
    
    if data then
        self.equipBtn:setEnabled(tonumber(data.status) ~= 1)
        self.root:getChildByName("Image_h2"):setVisible(true)
        self.root:getChildByName("Text_d1"):setString(g_tr("MasterNature"))
        local ePosNode = self.root:getChildByName("item_2")
        ePosNode:removeAllChildren()
        local equipType = g_Consts.DropType.MasterEquipment
        local equipID = tonumber(data.equip_master_id)
        local equipCount = 1
        local equip = require("game.uilayer.common.DropItemView").new(equipType, equipID,equipCount)
        equip:setPosition(cc.p( ePosNode:getContentSize().width/2,ePosNode:getContentSize().height/2 ))
        equip:setCountEnabled(false)
        equip:setNameVisible(true)
        ePosNode:addChild(equip)

        
        local buffStrList,numList = g_MasterEquipMode.GetEquipSkillListById(data.id)
        for index, buff in ipairs(buffStrList) do
            sx[index].tx:setVisible(true)

            local txColor = {r = 255,g = 255 , b = 255}
            local value = numList[index].value
            local range = numList[index].range
            local min = numList[index].min
            local max = numList[index].max
            local buff_type = numList[index].buff_type

            local cValue = (value - min) < 0 and 0 or (value - min)
            cValue = cValue / (max - min) * 100

            if  cValue <= 20  then
                --txColor = cc.c3b(255,255,255)
                txColor.r = 255
                txColor.g = 255
                txColor.b = 255

                --白
            elseif cValue > 20 and  cValue <= 40 then
                --txColor = cc.c3b(14,246,91)
                txColor.r = 14
                txColor.g = 246
                txColor.b = 91
                --绿
            elseif cValue > 40 and  cValue <= 60 then
                --txColor = cc.c3b(12,198,244)
                txColor.r = 12
                txColor.g = 198
                txColor.b = 244
                --蓝
            elseif cValue > 60 and  cValue <= 80 then
                --txColor = cc.c3b(185,63,255)
                txColor.r = 185
                txColor.g = 63
                txColor.b = 255
                --紫
            elseif cValue > 80 then
                --txColor = cc.c3b(255,126,0)
                txColor.r = 255
                txColor.g = 126
                txColor.b = 0
                --橙
            end

            local _num = string.format( "|<#%d,%d,%d#>%.2f|", txColor.r, txColor.g,txColor.b,value)
            if buff_type == 1 then
                _num = string.format( "|<#%d,%d,%d#>%.2f%%%%|", txColor.r, txColor.g,txColor.b,value)
            end
            local showStr = g_tr( numList[index].str,{ num = _num })  
            sx[index].tx:setTextColor(cc.c3b(255,255,255))
            sx[index].tx.rich = g_gameTools.createRichText( sx[index].tx, showStr ..range )
            
        end
    else
        self.equipBtn:setEnabled(false)
    end
end




function MasterEquipView:showList()
    
    local lie = 4
    local hang = math.ceil(#self.master_equip_data / lie)
    local index = 1
    local selEquip = nil

    local function equipTouch(sender,evenType)
        if evenType == ccui.TouchEventType.ended then
            self.selEquipData = sender.data
            self:showSelEquip()
            if selEquip then
                selEquip.high:setVisible(false)
            end
            selEquip = sender
            selEquip.high:setVisible(true)
        end
    end

    for i = 1, hang do
        local layout = ccui.Layout:create()
        layout:setSize( cc.size( self.list:getContentSize().width + 15,125 ) )
        for j = 1 , lie do
            local data = self.master_equip_data[index]
            if data then
                local equipType = g_Consts.DropType.MasterEquipment
                local equipID = tonumber(data.equip_master_id)
                local equipCount = 1
                local equip = require("game.uilayer.common.DropItemView").new(equipType, equipID,equipCount)
                equip:setSize( cc.size( equip:getContentSize().width + 10 , equip:getContentSize().height ) )
                equip:setAnchorPoint( cc.p(0,1) )
                equip:setPosition( (j - 1) * equip:getContentSize().width + 3 ,120 )
                equip:setCountEnabled(false)
                equip:setNameVisible(false)
                equip.data = data
                equip:setTouchEnabled(true)
                equip:addTouchEventListener( equipTouch )
                layout:addChild(equip)

                local high = cc.Sprite:create("freeImage/equip.png")
                high:setScale(1.2)
                high:setPosition( cc.p( equip:getContentSize().width/2 - 5,equip:getContentSize().height/2 ) )
                high:setVisible(false)
                equip:addChild(high)
                equip.high = high


                if tonumber(equip.data.status) == 1 then
                    local tx = ccui.Text:create()
                    tx:setFontName("cocostudio_res/simhei.ttf")
                    tx:setFontSize(22)
                    tx:setPosition( cc.p( equip:getContentSize().width/2 - 5 ,equip:getContentSize().height/2 + 38 ) )
                    tx:setString( g_tr("isWearing") )
                    equip:addChild(tx)
                    table.insert(self.curAllEquipData,equip.data)
                end

                if self.selEquipData == nil and tonumber(equip.data.status) ~= 1 then
                    self.selEquipData = equip.data
                    selEquip = equip
                    selEquip.high:setVisible(true)
                end
                

                index = index + 1
            end
        end
        self.list:pushBackCustomItem(layout)
    end
end




return MasterEquipView