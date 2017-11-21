--地图点收藏界面
local collectLayer = class("collectLayer", require("game.uilayer.base.BaseLayer"))
--local collect_list_data = nil --收藏资源列表
local COLLECT_SAVE = 1
local COLLECT_SHARE = 2



function collectLayer:createLayer( pos,mapConfigData,buildServerData )
    --显示收藏坐标列表
    
    --self.allianceData = g_AllianceMode.getBaseData()
    

    --print("allianceData",self.allianceData)

    --dump("allianceDataallianceDataallianceData",g_AllianceMode.getSelfHaveAlliance())
    --编辑
    if pos == nil then
        local ret = false
        self.collect_list_data = g_MapCollectMode.GetData()
        if self.collect_list_data then
            g_sceneManager.addNodeForUI( collectLayer:create() )
            ret = true
        else
            ret = false
        end
        return ret
    else
        g_sceneManager.addNodeForUI( collectLayer:create( pos,mapConfigData,buildServerData ) )
        return true
    end
    
    return false
end


function collectLayer:ctor( pos,mapConfigData,buildServerData )
    collectLayer.super.ctor(self)
    self.mapConfigData = mapConfigData
    self.buildServerData = buildServerData
    self:InitUI(pos)
end

function collectLayer:InitUI(pos)
    if pos then
        self:AddPos(pos)
    else
        self:ShowList()
    end
end

function collectLayer:ShowList()
    local layout = self:loadUI("favorites_main.csb")
    local root = layout:getChildByName("scale_node")
    local close_btn = root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
    
    --zhcn
    root:getChildByName("Text_1"):setString(g_tr("MapPosSaveListTitle"))
    root:getChildByName("Text_2"):setString(g_tr("MapPosSaveEdit"))
    root:getChildByName("Text_2_0"):setString(g_tr("MapPosSaveRemove"))
    
    local list = root:getChildByName("ListView_1")
    local selitem = nil --选中坐标节点
    local selType = g_Consts.SaveMarkType.mark

    local function showList(showData)

        if showData == nil then
            return
        end

        list:removeAllChildren()
        selitem = nil
        local _showData = showData
        local modItem = cc.CSLoader:createNode("favorites_1.csb")
        local itemCount = math.ceil(#_showData / 2)
        
        local index = 1
    
        for i = 1, itemCount do
            local lyout = ccui.Layout:create()
            lyout:setContentSize( cc.size( list:getContentSize().width,modItem:getContentSize().height ))
            for j = 1, 2 do
                local data = _showData[index]
                if data then
                    local item = modItem:clone()

                    --关闭高亮
                    local itemroot = item:getChildByName("scale_node")
                    
                    itemroot:getChildByName("Image_5"):setVisible( selType == g_Consts.SaveMarkType.mark )
                    itemroot:getChildByName("Image_4"):setVisible( selType == g_Consts.SaveMarkType.friend )
                    itemroot:getChildByName("Image_3"):setVisible( selType == g_Consts.SaveMarkType.enemy )
                    
                    itemroot.data = data
                    itemroot:getChildByName("Text_1"):setString( itemroot.data.name or "")
                    itemroot:getChildByName("Text_2"):setString( g_tr("MapPosFormat",{x = itemroot.data.x or -1 ,y = itemroot.data.y or -1 }) )
                
                    if selitem == nil then
                        selitem = itemroot
                        itemroot:getChildByName("Image_2"):setVisible(true)
                    else
                        itemroot:getChildByName("Image_2"):setVisible(false)
                    end
                
                    itemroot:setTouchEnabled(true)
                    item:setPosition( cc.p( (j - 1) * item:getContentSize().width,0 ) )
                    lyout:addChild( item )
                
                    self:regBtnCallback(itemroot,function ()
                        if selitem ~= nil and selitem ~= itemroot then
                            selitem:getChildByName("Image_2"):setVisible(false)
                            itemroot:getChildByName("Image_2"):setVisible(true)
                            selitem = itemroot
                        end
                        print("selitem.data.x,selitem.data.y",selitem.data.x,selitem.data.y)
                    end)

                    --地图跳转
                    local jump_btn = itemroot:getChildByName("Image_goto")
                    self:regBtnCallback(jump_btn,function ()
                        selitem:getChildByName("Image_2"):setVisible(false)
                        itemroot:getChildByName("Image_2"):setVisible(true)
                        selitem = itemroot
                        --解除当前锁定
                        require("game.maplayer.worldMapLayer_bigMap").closeSmallMenu()
                        require("game.maplayer.worldMapLayer_bigMap").closeInputMenu()

                        require("game.maplayer.worldMapLayer_bigMap").changeBigTileIndex_Manual(cc.p( data.x,data.y ),true)
                        self:close()
                    end)
                end
                index = index + 1
            end
            list:pushBackCustomItem(lyout)
        end
    end

    local filterData = 
    {
        [g_Consts.SaveMarkType.mark] = {},
        [g_Consts.SaveMarkType.friend] = {},
        [g_Consts.SaveMarkType.enemy] = {},
    }
    
    local function filterShowData()
        self.collect_list_data = g_MapCollectMode.GetData()
        filterData[g_Consts.SaveMarkType.mark] = {}
        filterData[g_Consts.SaveMarkType.friend] = {}
        filterData[g_Consts.SaveMarkType.enemy] = {}

        for key, data in ipairs(self.collect_list_data) do
            table.insert(filterData[data.type],data)
        end
    end

    filterShowData()


    local edit_btn = root:getChildByName("Image_2")
    self:regBtnCallback(edit_btn,function ()
        
        if not selitem then
            return
        end
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        --更新
        local function updateItem()
            filterShowData()
            showList(filterData[selType])
        end
        
        self:AddPos(cc.p(selitem.data.x,selitem.data.y),updateItem,false,true,selType,selitem.data.name)

    end)


    local rmove_btn = root:getChildByName("Image_2_0")
    self:regBtnCallback(rmove_btn,function ()
        
        if not selitem then
            return
        end
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local function touchEvent(event)
            if event == 0 then
                
                local function onRecv(result, msgData)
			        if(result==true)then
                        g_airBox.show(g_tr("MapPosRemoveOK"),1)
                        filterShowData()
                        showList(filterData[selType])
			        end
		        end
		        g_sgHttp.postData("map/dropCoordinate",{ x = selitem.data.x , y = selitem.data.y},onRecv)
            end
        end
        g_msgBox.show(g_tr("MapPosRemove"),nil,3,touchEvent,1)
    end)
    
    local function touchTab(sender,eventype)
        if eventype == ccui.TouchEventType.ended then
            self.markBtn:setEnabled(true)
            self.friendBtn:setEnabled(true)
            self.enemyBtn:setEnabled(true)
            sender:setEnabled(false)
            selType = sender.type
            showList(filterData[sender.type])
        end
    end

    self.markBtn = root:getChildByName("Button_y1")
    self.markBtn.type = g_Consts.SaveMarkType.mark
    self.markBtn:addTouchEventListener(touchTab)
    self.markBtn:getChildByName("Text_1"):setString(g_tr("MapMark"))

    self.friendBtn = root:getChildByName("Button_y2")
    self.friendBtn.type = g_Consts.SaveMarkType.friend
    self.friendBtn:addTouchEventListener(touchTab)
    self.friendBtn:getChildByName("Text_1"):setString(g_tr("MapFriend"))

    self.enemyBtn = root:getChildByName("Button_y2_0")
    self.enemyBtn.type = g_Consts.SaveMarkType.enemy
    self.enemyBtn:addTouchEventListener(touchTab)
    self.enemyBtn:getChildByName("Text_1"):setString(g_tr("MapEnemy"))

    self.markBtn:setEnabled(false)
    showList(filterData[self.markBtn.type])

    
end

--是否关闭整个layer 默认true 
--因为这个UI 可能是联动打开也可能是独立的
function collectLayer:AddPos(pos,callback,isRemoveAll,isParentJump,markType,name)
    
    local layout = self:loadUI("favorites_popup.csb")
    local root = layout:getChildByName("scale_node")
    local close_btn = root:getChildByName("Panel_1")
    local mark = layout:getChildByName("mark")

    if isRemoveAll == nil then
        isRemoveAll = true
    end

    if isParentJump == nil then
        isParentJump = false
    end

    if markType == nil then
        markType = g_Consts.SaveMarkType.mark
    end

    --isRemoveAll = isRemoveAll or true
    --isParentJump = isParentJump or false
    
    local function back()
        if callback then
            callback()
        end
        
        if isRemoveAll then
            print("close")
		    self:close()
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        else
            print("removeFromParent")
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            layout:removeFromParent()
        end
    end

    self:regBtnCallback(close_btn,back)
    self:regBtnCallback(mark,back)

    --zhcn
    root:getChildByName("bg_title"):getChildByName("Text_2"):setString(g_tr("MapPosEditTitle"))
    root:getChildByName("Text_5"):setString(g_tr("MapPosName"))
    root:getChildByName("Text_1"):setString(g_tr("MapPosSave"))
    root:getChildByName("Text_7"):setString( string.format("X : %d  Y : %d",pos.x,pos.y) )
    

    local selBtn = nil

    local markBtn = root:getChildByName("Image_x1")
    local friendBtn = root:getChildByName("Image_x2")
    local enemyBtn = root:getChildByName("Image_x2")

    local function touchSel(sender,eventype)
        if eventype == ccui.TouchEventType.ended then
            --[[markBtn.high:setVisible(false)
            friendBtn.high:setVisible(false)
            enemyBtn.high:setVisible(false)
            sender.high:setVisible(true)
            selBtn = sender]]
            if selBtn ~= sender then
                selBtn.high:setVisible(false)
                sender.high:setVisible(true)
                selBtn = sender
            end

        end
    end
    
    local btnList = {}

    markBtn = root:getChildByName("Image_x1")
    markBtn.high = root:getChildByName("Image_x1_0")
    markBtn.high:setVisible(false)
    markBtn.type = g_Consts.SaveMarkType.mark
    markBtn:addTouchEventListener(touchSel)

    friendBtn = root:getChildByName("Image_x2")
    friendBtn.high = root:getChildByName("Image_x2_0")
    friendBtn.high:setVisible(false)
    friendBtn.type = g_Consts.SaveMarkType.friend
    friendBtn:addTouchEventListener(touchSel)

    enemyBtn = root:getChildByName("Image_x3")
    enemyBtn.high = root:getChildByName("Image_x3_0")
    enemyBtn.high:setVisible(false)
    enemyBtn.type = g_Consts.SaveMarkType.enemy
    enemyBtn:addTouchEventListener(touchSel)

    local btnList = 
    {
        markBtn,
        friendBtn,
        enemyBtn,
    }

    for key, btn in ipairs(btnList) do
        if btn.type == markType then
            selBtn = btn
            selBtn.high:setVisible(true)
            break
        end
    end
    
    root:getChildByName("Text_x1"):setString(g_tr("MapMark"))
    root:getChildByName("Text_x2"):setString(g_tr("MapFriend"))
    root:getChildByName("Text_x3"):setString(g_tr("MapEnemy"))

    local editmode = root:getChildByName("TextField_1")
    local edit = g_gameTools.convertTextFieldToEditBox(editmode)
    edit:setFontColor(cc.c3b(255,255,255))
    edit:setMaxLength(25)


    local function savePos(saveType)

        local posName = string.trim(edit:getString())

        if posName == nil or posName == "" then
            g_airBox.show(g_tr("MapPosNoName"),3)
            return
        end

        if pos and posName and posName ~= "" then
            local function onRecv(result, msgData)
			    if(result==true)then
                    
                    if saveType == COLLECT_SAVE then
                        g_airBox.show(g_tr("MapPosSaveOK"),1) 
                    else
                        g_airBox.show(g_tr("MapPosShareOK"),1)
                    end

                    back()

			    end
		    end
		    g_sgHttp.postData("map/addCoordinate",{ x = pos.x , y = pos.y , type = selBtn.type, name = posName },onRecv)
        end
    end

    local btn = root:getChildByName("btn_1")
    self:regBtnCallback(btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        savePos(COLLECT_SAVE)
    end)

    root:getChildByName("Text_2"):setString(g_tr("MapPosShare"))
    local shareBtn = root:getChildByName("btn_2")

    if not g_AllianceMode.getSelfHaveAlliance() then
        shareBtn:setVisible(false)
        root:getChildByName("Text_2"):setVisible(false)
        local bg = root:getChildByName("Image_1")
        btn:setPositionX( root:getContentSize().width/2 )
        root:getChildByName("Text_1"):setPositionX( root:getContentSize().width/2 )
    end
    
    self:regBtnCallback(shareBtn,function ()
        --print("share")
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local posName = string.trim(edit:getString())
        --去掉保存
        --savePos(COLLECT_SHARE)
        require("game.uilayer.chat.ChatLayer"):shareToGuild(posName, pos.x, pos.y)
        g_airBox.show(g_tr("MapPosShareOK"),1)
        back()
                
    end)


    print("callback,isRemoveAll",callback,isRemoveAll)
    --不是从收藏夹跳转
    if not isParentJump then
        --dump(self.mapConfigData)
        --dump(self.buildServerData)
        --空地
        if self.mapConfigData == nil and self.buildServerData == nil then
            edit:setString(  g_tr("MapEmpty").. string.format("(%d,%d)",pos.x,pos.y))
        end

        local help = require "game.maplayer.worldMapLayer_helper"
        if self.mapConfigData then
            --dump(self.mapConfigData)
            --城外资源
            if self.mapConfigData.origin_id == help.m_MapOriginType.world_gold --黄金
            or self.mapConfigData.origin_id == help.m_MapOriginType.world_food --粮食
            or self.mapConfigData.origin_id == help.m_MapOriginType.world_wood --木头
            or self.mapConfigData.origin_id == help.m_MapOriginType.world_stone --石头
            or self.mapConfigData.origin_id == help.m_MapOriginType.world_iron --铁矿
            or self.mapConfigData.origin_id == help.m_MapOriginType.stronghold --据点
            then
                edit:setString( string.format("%s(%d,%d)",g_tr(self.mapConfigData.name),pos.x,pos.y))
            end
            --城外城池
            if self.mapConfigData.origin_id == help.m_MapOriginType.player_home then
                if self.buildServerData then

                    dump(self.buildServerData)

                    local playerId = self.buildServerData.player_id
                    if playerId == nil or playerId == 0 then
                        return
                    end
                    local function onRecv( result, msgData )
                        g_busyTip.hide_1()
                        if result == true then
                            edit:setString( string.format("【%s】%s(%d,%d)",g_tr("MapIsPlayer"),g_tr(msgData.Player.nick),pos.x,pos.y))
                        end
                    end
                    g_busyTip.show_1()
                    g_sgHttp.postData("player/viewTargetPlayerInfo",{ target_player_id = playerId },onRecv,true)
                end
            end
            
            --联盟建筑
            if self.mapConfigData.origin_id  == help.m_MapOriginType.guild_fort 
            or self.mapConfigData.origin_id  == help.m_MapOriginType.guild_tower
            or self.mapConfigData.origin_id  == help.m_MapOriginType.guild_gold
            or self.mapConfigData.origin_id  == help.m_MapOriginType.guild_food
            or self.mapConfigData.origin_id  == help.m_MapOriginType.guild_wood
            or self.mapConfigData.origin_id  == help.m_MapOriginType.guild_stone
            or self.mapConfigData.origin_id  == help.m_MapOriginType.guild_iron
            or self.mapConfigData.origin_id  == help.m_MapOriginType.guild_cache
            then
                --dump(self.buildServerData)
                local guildName = g_tr(self.mapConfigData.name)
                
                if self.buildServerData and self.buildServerData.guild_id and self.buildServerData.guild_id ~= 0 then
                    --local guildInfo = nil
                    local function onRecv(result, msgData)
                        g_busyTip.hide_1()
                        if result == true then
                            --guildInfo = msgData
                            --dump(guildInfo)
                            guildName = "(".. msgData.short_name ..")"..guildName
                        end
                    end
                    g_busyTip.show_1()
                    g_sgHttp.postData("guild/viewGuildInfo",{guild_id = self.buildServerData.guild_id},onRecv,true)    
                end

                edit:setString( string.format("【%s】%s(%d,%d)",g_tr("MapIsGuild"),guildName,pos.x,pos.y))
            end

            if self.mapConfigData.origin_id  == help.m_MapOriginType.monster_small --小怪
            or self.mapConfigData.origin_id  == help.m_MapOriginType.monster_boss  --BOSS
            or self.mapConfigData.origin_id == help.m_MapOriginType.camp_middle    --中级营寨
            or self.mapConfigData.origin_id == help.m_MapOriginType.camp_low       --低级营寨
            or self.mapConfigData.origin_id == help.m_MapOriginType.king_castle    --皇城
            then
                --dump(self.buildServerData)
                --dump(self.mapConfigData)

                edit:setString( string.format("%s(%d,%d)",g_tr(self.mapConfigData.name),pos.x,pos.y))

            end
        end
    else
        if name then
            edit:setString(name)
        end
    end


end

function collectLayer:onEnter()
    print("collectLayer onEnter")
end

function collectLayer:onExit()
    --collect_list_data = nil
    print("collectLayer onExit")
end 


return collectLayer