--region kingEnthroneLayer.lua 国王登基UI
--Author : liuyi
--Date   : 2016/3/1
local kingEnthroneLayer = class("kingEnthroneLayer", require("game.uilayer.base.BaseLayer"))

local m_Root = nil

local OfficeType = {
    ["officer"] = 1,
    ["slave"] = 2,
    ["gift"] = 3,
}

function kingEnthroneLayer:ctor()
    
    m_Root = nil

    kingEnthroneLayer.super.ctor(self)

    m_Root = self
    
end


function kingEnthroneLayer:onEnter()
    
    local function callback( result , data )
        g_busyTip.hide_1()
		if true == result then
			self.jobData = data
            self.layer = self:loadUI("KingOfWar_panel.csb")
            self:init()
        else
            self:close()
		end
	end
    g_busyTip.show_1()
    g_sgHttp.postData("King/getJob", {}, callback,true)
end

function kingEnthroneLayer:init()
    
    self.root = self.layer:getChildByName("scale_node")

    local close_btn = self.root:getChildByName("close_btn")

	self:regBtnCallback(close_btn,function ()
		self:close()
	end)

    self.list = self.root:getChildByName("ListView_1")

    self.kingWarData = g_kingInfo.GetData()
    
    self.root:getChildByName("Image_6"):setVisible( false )
    self.root:getChildByName("Text_3"):setVisible( false )
    self.root:getChildByName("Text_3_0"):setVisible( false )
    self.root:getChildByName("Button_hw"):setVisible( false )

    local showPanel = self.root:getChildByName("Panel_renwu")

    if self.kingIcon then
        self.kingIcon:removeFromParent()
        self.kingIcon = nil
    end
    
    if self.kingIcon == nil then
        self.kingIcon = ccui.ImageView:create()
        self.kingIcon:setTouchEnabled(true)
        self.kingIcon:setPosition( cc.p( showPanel:getContentSize().width/2,showPanel:getContentSize().height/2 ) )
        showPanel:addChild( self.kingIcon )
    end
    
    local iconID = g_data.king_appoint[1].img_normal

    --尚未委任
    if self.kingWarData.status == 3 then
        --找盟主信息
        local allianceData = g_AllianceMode.getBaseData()
        local myData = g_PlayerMode.GetData()

        dump(allianceData)


        print("leader_player_id,myid,kingguild_id,myguildid",allianceData.leader_player_id,myData.id,self.kingWarData.guild_id,allianceData.id)

        local isleader = ( tonumber(allianceData.leader_player_id) == tonumber(myData.id) and  tonumber(self.kingWarData.guild_id) == tonumber(allianceData.id) )

        self.root:getChildByName("Image_6"):setVisible( not isleader )
        self.root:getChildByName("Text_3"):setVisible( not isleader )
        self.root:getChildByName("Text_3"):setString( g_tr("kwar_selKingStr") )

        self.root:getChildByName("Text_3_0"):setVisible( not isleader )
        self.root:getChildByName("Text_3_0"):setString("")

        local selBtn = self.root:getChildByName("Button_hw")
        selBtn:setVisible( isleader )

        selBtn:getChildByName("Text_5"):setString(g_tr("kwar_selKingBtnStr"))

        self:regBtnCallback(selBtn,handler(self,self.selKing))
        iconID = g_data.king_appoint[1].img_normal
        
    end
    --已经选举了皇帝
    if self.kingWarData.status == 4 then
        local selBtn = self.root:getChildByName("Button_hw")
        selBtn:setVisible(false)
        self.root:getChildByName("Image_6"):setVisible( true )
        self.root:getChildByName("Text_3"):setVisible( true )
        self.root:getChildByName("Text_3_0"):setVisible( true )
        
        self.root:getChildByName("Text_3"):setString( self.kingWarData.nick )
        self.root:getChildByName("Text_3_0"):setString(  g_tr("kwar_kingGuild",{ guildname = self.kingWarData.guild_name } ) )

        self.kingIcon:setScale(0.8)
        iconID = g_data.res_head[self.kingWarData.avatar_id].bust_icon
        --找皇帝信息
    end

    if iconID then
        self.kingIcon:loadTexture(g_resManager.getResPath( tonumber(iconID) ))
        self.kingIcon:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self.cData = g_data.king_appoint[1]
                self.nData = self.jobData and self.jobData.Job[ tostring(self.cData.id) ] or nil
                g_sceneManager.addNodeForUI( require("game.uilayer.kingWar.kingAppointLayer"):create(self.cData,self.nData))
            end
        end)
    end

    self.panel_2 = self.root:getChildByName("Panel_2")

    --zhcn
    self.panel_2:getChildByName("Text_1"):setString( g_tr("kwar_officer") )
    self.panel_2:getChildByName("Text_2"):setString( g_tr("kwar_slave") )
    self.panel_2:getChildByName("Text_3"):setString( g_tr("kwar_gift") )

    local function touchListener(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self.panel_2:getChildByName("Button_1"):setEnabled(true)
            self.panel_2:getChildByName("Button_2"):setEnabled(true)
            self.panel_2:getChildByName("Button_3"):setEnabled(true)
            self.officeType = sender.OfficeType
            self:showList()
            sender:setEnabled(false)
        end
    end

    local officer_btn = self.panel_2:getChildByName("Button_1")
    officer_btn.OfficeType = OfficeType.officer
    officer_btn:addTouchEventListener(touchListener)
    officer_btn:setEnabled(false)

    local slave_btn = self.panel_2:getChildByName("Button_2")
    slave_btn.OfficeType = OfficeType.slave
    slave_btn:addTouchEventListener(touchListener)
    slave_btn:setEnabled(true)

    local gift_btn = self.panel_2:getChildByName("Button_3")
    gift_btn.OfficeType = OfficeType.gift
    gift_btn:addTouchEventListener(touchListener)
    gift_btn:setEnabled(true)

    --local isKing = g_PlayerMode.GetData().id == self.kingWarData.player_id
    --gift_btn:setVisible(isKing)
    --self.panel_2:getChildByName("Text_3"):setVisible(isKing)

    self.officeType = officer_btn.OfficeType
    
    local helpBtn = self.root:getChildByName("Button_wenhao")
    self:regBtnCallback(helpBtn,function ()
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.common.HelpInfoBox"):show(18)
	end)
    
    self:showList()
    
end

--筛选当前TAB的配置表数据
function kingEnthroneLayer:filterData()
    
    self.officeType = self.officeType or OfficeType.officer
    
    local dataConfig = g_data.king_appoint

    local data = {}
    
    for key, value in pairs(dataConfig) do
        if value.type == self.officeType then
            if value.id ~= 1 then
                table.insert(data,value)
            end
        end
    end
    
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    
    return data

end

--显示当前职位数据
function kingEnthroneLayer:showList()

    self.list:removeAllItems()

    --if self.kingWarData.player_id then

    if self.officeType == OfficeType.gift then
        if g_PlayerMode.GetData().id == self.kingWarData.player_id then
            g_busyTip.show_1()
            g_sgHttp.postData("king/getLeftGiftList",nil,function (result,data)
                g_busyTip.hide_1()
                if true == result then
                    self.giftData = data
                    self:showGiftList()
                end
            end,true)
        else
            self:showGiftList()
        end
        
        return
    end

    local typeDataConfig = self:filterData()
    local showCell = 4
    local showRow = math.ceil( #typeDataConfig / showCell )
    local itemMode = cc.CSLoader:createNode("KingOfWar_List1.csb")

    self.list:setItemsMargin(10)
    local index =  1
    
    local function itemTouch(sender,eventType)
        if eventType == ccui.TouchEventType.ended then

            local cData = sender.cData
            local nData = sender.nData

            self.cData = cData
            self.nData = nData

            g_sceneManager.addNodeForUI( require("game.uilayer.kingWar.kingAppointLayer"):create(cData,nData))
        end
    end
    
    for i = 1, showRow do
        local layout = ccui.Layout:create()
        local ly_width = self.list:getContentSize().width
        layout:setSize( cc.size( ly_width,itemMode:getContentSize().height ) )
        for j = 1, showCell do
            local cData = typeDataConfig[index]
            if cData then
                local item = itemMode:clone()
                item:setPositionX(  ( ly_width / showCell ) * (j - 1) )
                layout:addChild(item)

                local nData = self.jobData and self.jobData.Job[ tostring(cData.id) ] or nil

                item:getChildByName("Text_1"):setString(g_tr( cData.position_name ))
                item:getChildByName("pic"):loadTexture( g_resManager.getResPath(cData.img_head))
                item:getChildByName("Text_1_0"):setString( g_tr("kworld_empty"))

                if nData then
                    local icon = g_data.res_head[ tonumber(nData.avatar_id) ].head_icon
                    item:getChildByName("pic"):loadTexture( g_resManager.getResPath(icon) )
                    item:getChildByName("Text_1_0"):setString( nData.nick)
                end

                item.cData = cData
                item.nData = nData

                item:setTouchEnabled(true)
                item:addTouchEventListener(itemTouch)
                index = index + 1
            end
        end

        self.list:pushBackCustomItem(layout)
    end
    
end

function kingEnthroneLayer:showGiftList()
    
    local function itemTouch(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self.giftId = sender.giftId
            g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingSelPlayerLayer"):create(3))
        end
    end

    local gift_config = g_data.king_gift

    local itemMode = cc.CSLoader:createNode("KingOfWar_List2.csb")

    for _, var in ipairs(gift_config) do

        local item = itemMode:clone()

        local itemID = var.gift_id

        local dropConfig = g_data.drop[tonumber(itemID)]
        
        if dropConfig then

            local list = item:getChildByName("ListView_1")

            for index, drop in ipairs(dropConfig.drop_data) do
                local itemType = drop[1]
                local itemID = drop[2]
                local itemCount = drop[3]
                local item = require("game.uilayer.common.DropItemView").new(itemType, itemID,itemCount)
                item:enableTip()
                list:pushBackCustomItem(item)

                item:setScale(0.9)

            end
        end
        
        local btn = item:getChildByName("btn")

        local num = var.max_count

        if self.giftData then
            btn:setVisible(true)
            item:getChildByName("Text_btn"):setVisible(true)
            item:getChildByName("Text_18_0"):setVisible(true)
            num = self.giftData.leftGiftList[tostring(var.id)]
        else
            btn:setVisible(false)
            item:getChildByName("Text_btn"):setVisible(false)
            item:getChildByName("Text_18_0"):setVisible(false)
        end
        
        item:getChildByName("Text_18"):setString(g_tr(var.gift_name))

        item:getChildByName("Text_18_0"):setString( string.format("%s%d/%d",g_tr("kwar_giftnumstr"),num,var.max_count) )

        item:getChildByName("Text_btn"):setString(g_tr("kwar_giftgive"))

        btn.giftId = var.id

        btn:setEnabled( not (num == 0)  )

        btn:addTouchEventListener(itemTouch)

        self.list:pushBackCustomItem(item)
    end

end

--获取配置表与服务器数据
function kingEnthroneLayer.getCDataAndNData()
    if m_Root then
        return m_Root.cData,m_Root.nData,m_Root.officeType,m_Root.giftId
    end
end

--获取job信息
function kingEnthroneLayer.getJobData(args)
    if m_Root then
        return m_Root.jobData
    end
end 

--更新显示界面
function kingEnthroneLayer.updateList()
    if m_Root then
        if m_Root.officeType ~= OfficeType.gift then 
            m_Root.jobData = nil
            local function callback( result , data )
                g_busyTip.hide_1()
		        if true == result then
			        m_Root.jobData = data
                    if m_Root.jobData then
                        m_Root:showList()
                    end
		        end
	        end
            g_busyTip.show_1()
            g_sgHttp.postData("King/getJob", nil, callback,true)
        else
            m_Root:showList()
            --[[m_Root.giftData = nil
            g_busyTip.show_1()
            g_sgHttp.postData("king/getLeftGiftList",nil,function (result , data)
                g_busyTip.hide_1()
                if true == result then
                    m_Root.giftData = data
                    if m_Root.giftData then
                        m_Root:showList()
                    end
                end
            end)]]
        end
    end
end




function kingEnthroneLayer:selKing()
    if g_AllianceMode.reqAllAllianceData() then
        g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingSelKingLayer"):create( function ()
            self:init()
        end )
        )
    end
end


function kingEnthroneLayer:onExit()
    m_Root = nil
end

return kingEnthroneLayer

