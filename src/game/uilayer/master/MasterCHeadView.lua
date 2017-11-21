local MasterCHeadView = class("MasterCHeadView", require("game.uilayer.base.BaseLayer"))
local MODE = nil
--local master_data = nil
local CELL = 4
local CHANGEHEAD_COST_ID_TYPE = 10900 --修改名字花费的ID
--10900

function MasterCHeadView:createLayer( fun )
     MODE = require("game.uilayer.master.MasterMode").new()
     self.master_data = MODE:getMasterInfo()
     if self.master_data then
        g_sceneManager.addNodeForUI( MasterCHeadView:create( fun ) )
        return true  
     end
     return false
end

function MasterCHeadView:ctor( callback )
    MasterCHeadView.super.ctor(self)
    self.callback = callback
    self:initUI()
end

function MasterCHeadView:initUI()
    self.layer = self:loadUI("zhugong_ModifyAvatar_popup.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("close_btn")
    self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    --筛选配置表数据 并且按ID 从小到大 排序
    local head = {}
    local cdt = g_data.res_head
    for key, var in pairs(cdt) do
        table.insert(head,var)
    end
    
    table.sort( head,function (a,b)
        return a.id < b.id
    end )

    --zhcn
    self.root:getChildByName("bg_title"):getChildByName("text"):setString( g_tr("MasterCHTitle") )

    local show_head_img = self.root:getChildByName("Image_2")
    local iconid = g_data.res_head[self.master_data.avatar_id].head_icon
    show_head_img:loadTexture( g_resManager.getResPath(iconid) )
    local gold_icon = self.root:getChildByName("ico_gold_1")
    local gemCount, gemIcon = g_gameTools.getPlayerCurrencyCount( g_Consts.AllCurrencyType.Gem )
    gold_icon:loadTexture(gemIcon)
    --gold_icon:setVisible(false)
    local cost_tx = self.root:getChildByName("Text_1")
    --cost_tx:setVisible(false)
    cost_tx:setString( tostring( g_data.cost[CHANGEHEAD_COST_ID_TYPE].cost_num ) )

    --显示所有头像列表
    local selhead = nil
    local list = self.root:getChildByName("ListView_1")
    list:setItemsMargin(10)
    local itemmode = cc.CSLoader:createNode("zhugong_ModifyAvatar_head.csb")
    itemmode:setAnchorPoint(cc.p(0,0.5))
    local layoutmode = ccui.Layout:create()
    local pos_x = list:getContentSize().width / 4
    layoutmode:setSize(cc.size( list:getContentSize().width,itemmode:getContentSize().height ))
    local row = math.ceil( #head / CELL )

    local function showCost(id)
        if tostring( self.master_data.avatar_id ) == tostring(id) then
            cost_tx:setString(tostring(0))
        else
            cost_tx:setString( tostring( g_data.cost[CHANGEHEAD_COST_ID_TYPE].cost_num ) )
        end
    end

    --选择头像touch时间
    local function itemTouchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            showCost(sender.data.id)
            if selhead ~= sender then
                selhead:getChildByName("Image_35"):setVisible(false)
                selhead = sender
                selhead:getChildByName("Image_35"):setVisible(true)
                local iconid = g_data.res_head[ sender.data.id].head_icon
                show_head_img:loadTexture( g_resManager.getResPath(iconid) )
            end
        end
    end
    
    for i = 1 , row do
	    local layout = layoutmode:clone()
        local si = (i - 1) * CELL + 1
        local ni = si + CELL - 1
        --print(" si,ni ",si,ni)
        for j = 1 , CELL do
            local index = j  + CELL * (i - 1)
            if head[index] then
                local item = itemmode:clone()
                item:setPosition(cc.p( 5 + (j - 1) * pos_x , layout:getContentSize().height/2 ))
                local itemroot = item:getChildByName("scale_node"):setTouchEnabled(true)
                local item_pic = item:getChildByName("scale_node"):getChildByName("Image_1")
                local item_high = item:getChildByName("scale_node"):getChildByName("Image_35")
                item_high:setVisible(false)
                itemroot.data = head[index]
                local iconid = g_data.res_head[ itemroot.data.id].head_icon
                item_pic:loadTexture( g_resManager.getResPath(iconid) )

                if itemroot.data.id == self.master_data.avatar_id then
                    selhead = itemroot
                    item_high:setVisible(true)
                    --self.jumpPosY = (i - 1) * layout:getContentSize().height + 2 * list:getItemsMargin()
                end

                --print("layout getPositionY",list:getItemsMargin() )

                itemroot:addTouchEventListener(itemTouchEvent)
                layout:addChild(item)
            end
        end
        list:pushBackCustomItem(layout)
        
	end

    showCost(selhead.data.id)
    
    local save_btn = self.root:getChildByName("btn_save")
    save_btn:getChildByName("Text_3"):setString( g_tr("CHead" ))
    local up_btn = self.root:getChildByName("btn_save_0")
    up_btn:getChildByName("Text_3"):setString( g_tr("UHead" ))
    self:regBtnCallback(save_btn,function ()
		print("head head",selhead.data.id)
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
        if tostring( self.master_data.avatar_id ) == tostring(selhead.data.id) then
            self:close()
            return
        end
        
        local cost = g_data.cost[CHANGEHEAD_COST_ID_TYPE].cost_num
        g_msgBox.showConsume(cost, g_tr("SureReHead"), nil, g_tr("save"), function ()
            if MODE:masterReheadAction( selhead.data.id ) then
                g_airBox.show( g_tr("changeSuccess") ,1)
                self.callback()
                self:close()
            end
        end)

        --[[if g_PlayerMode.getDiamonds() < g_data.cost[CHANGEHEAD_COST_ID_TYPE].cost_num then
           g_airBox.show( g_tr("no_enough_money") ,3)
        else
            g_msgBox.show( g_tr("SureReHead"),nil,2,
            function ( eventtype )
                --确定
                if eventtype == 0 then 
                    if MODE:masterReheadAction( selhead.data.id ) then
                        g_airBox.show( g_tr("changeSuccess") ,1)
                        self.callback()
                        self:close()
                    end
                end
            end , 1)
        end]]
	end)


    --[[print("self.jumpPosY",self.jumpPosY)

    --下一帧跳转
    if self.jumpPosY then
        local action = nil
        action = self:schedule( function ()
                local jump =  self.jumpPosY / list:getInnerContainerSize().height * 100
                list:jumpToPercentVertical( jump )
                self:unschedule(action)
        end, 0 )
    end]]
end

function MasterCHeadView:onEnter( )
	print("MasterCHeadView onEnter")
end

function MasterCHeadView:onExit( )
    MODE = nil
    --self.jumpPosY = nil
	print("MasterCHeadView onExit")
end

return MasterCHeadView
