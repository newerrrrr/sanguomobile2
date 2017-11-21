local smallMapLayer = {}
setmetatable(smallMapLayer,{__index = _G})
setfenv(1,smallMapLayer)
local MapHelper = require "game.maplayer.worldMapLayer_helper"
local m_Root = nil
local m_Map = nil
local m_KingInfoView = nil
local m_BackView = nil
local m_DescView = nil
local m_InfoOnOffView = nil
local m_GuildPlayers = {}

--获取纹理节点
local Image_2 --我的城堡
local Image_3 --盟主
local Image_4 --联盟成员
local Image_5 --联盟堡垒

local MY_POS_TYPE = 1
local LEADER_POS_TYPE = 2
local FRIEND_POS_TYPE = 3
local TOWER_POS_TYPE = 4

local KING_POS = cc.p(619,619)

function create()
    
    clear()

    local rootLayer = cc.Layer:create()

	m_Root = rootLayer

    rootLayer:setScale(2)

    local action = cc.ScaleTo:create(0.5,1,1)

    rootLayer:runAction(action)

    local function rootLayerEventHandler(eventType)
		if eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clear()
			end
        end

        if eventType == "enterTransitionFinish" then
            --小地图居中
            m_Map:getChildByName("ScrollView"):jumpToPercentHorizontal(50)
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)

    m_Map = g_gameTools.LoadCocosUI("worldmap_02.csb",5)
    rootLayer:addChild(m_Map)
    MapInit()
    
    --国王城归属的基本信息
    m_KingInfoView = g_gameTools.LoadCocosUI("worldMap_02_1.csb",1)
    rootLayer:addChild(m_KingInfoView)
    KingInfo()
    
    --返回按钮
    m_BackView = g_gameTools.LoadCocosUI("worldMap_02_2.csb",7)
    rootLayer:addChild(m_BackView)
    Back()

    --基本说明
    m_DescView = g_gameTools.LoadCocosUI("worldMap_02_3.csb",8)
    rootLayer:addChild(m_DescView)
    Desc()


    --关于玩家的基本信息开关
    m_InfoOnOffView = g_gameTools.LoadCocosUI("worldMap_02_4.csb",9)
    rootLayer:addChild(m_InfoOnOffView)

    --当前停留的位置
    local map = m_Map:getChildByName("ScrollView"):getChildByName("Panel_1"):getChildByName("Image_3")
    local stopPos = require "game.maplayer.worldMapLayer_bigMap".getBigTileIndex_CurrentLookAt()
    local size = map:getContentSize()

    local m_pos = MapHelper.out_bigTileIndex_2_position(stopPos,size)
    local sp = cc.Sprite:create("freeImage/stoppos.png")
    sp:setAnchorPoint(cc.p(0.5,0.5))
    sp:setPosition( m_pos )
    map:addChild(sp,10000)
    sp:setScale(1)
    sp:runAction( cc.RepeatForever:create(  cc.Sequence:create(cc.ScaleTo:create(0.6,0.5),cc.ScaleTo:create(0.6,1) )))


    local king_pos = MapHelper.out_bigTileIndex_2_position(KING_POS,size)
    local kingSp = ccui.ImageView:create("freeImage/Imperialpalace.png")
    kingSp:setTouchEnabled(true)
    kingSp:setAnchorPoint(cc.p(0.5,0.5))
    kingSp:setPosition( king_pos )
    map:addChild(kingSp)
    kingSp:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            --跳转
            require("game.maplayer.worldMapLayer_bigMap").closeSmallMenu()
            require("game.maplayer.worldMapLayer_bigMap").closeInputMenu()
            require("game.maplayer.worldMapLayer_bigMap").changeBigTileIndex_Manual(KING_POS,true)
            m_Root:removeFromParent()
        end
    end)


    local openTimeTx = ccui.Text:create()
    openTimeTx:setFontName("cocostudio_res/simhei.ttf")
    openTimeTx:setFontSize(18)
    openTimeTx:setAnchorPoint(0.5,0.5)
    openTimeTx:setPosition( king_pos ) 
    map:addChild(openTimeTx,1000)
    openTimeTx:enableOutline(cc.c4b(0, 0, 0,255), 1)
    
    local function openTimeUpdate()
        if g_kingInfo.isKingBattleStarted() then
            openTimeTx:setString(g_tr("kwar_Opening"))
            openTimeTx:setTextColor( cc.c3b(30,230,30) )
            return
        end

        openTimeTx:setString(g_gameTools.convertSecondToString(g_kingInfo.kingBattleSoonTime()))
    end

    openTimeUpdate()

    local delay = cc.DelayTime:create(1)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(openTimeUpdate))
    local action = cc.RepeatForever:create(sequence)
    openTimeTx:runAction(action)

    --local openTimeTx = ccui.Text:create()



    --Imperialpalace.png

    InfoOnOff()
    createMapBuild()

    return rootLayer
end


function createMapBuild()
    
    local mydata = g_PlayerMode.GetData()
    
    if mydata then
        
        --设置自己的位置
        local mydatapos = cc.p(mydata.x,mydata.y)
    
        local map = m_Map:getChildByName("ScrollView"):getChildByName("Panel_1"):getChildByName("Image_3")
        local size = map:getContentSize()

        local function createPosBuild(pos,Type)
 
            local m_pos =  MapHelper.out_bigTileIndex_2_position(pos,size)

            local showType = 
            {
                Image_2,
                Image_3,
                Image_4,
                Image_5,
            }

            Type = Type or MY_POS_TYPE
            local sp
            if m_pos.x ~= -1 and m_pos.y ~= -1 then
                sp = showType[Type]:clone()
                sp:setAnchorPoint(cc.p(0.5,0))
                sp:setPosition( m_pos )
                sp:setTouchEnabled(true)
                sp:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        print("send pos",Type,pos.x,pos.y,m_pos.x,m_pos.y)
                        --跳转
                        require("game.maplayer.worldMapLayer_bigMap").closeSmallMenu()
                        require("game.maplayer.worldMapLayer_bigMap").closeInputMenu()
                        require("game.maplayer.worldMapLayer_bigMap").changeBigTileIndex_Manual(pos,true)
                        m_Root:removeFromParent()
                    end
                end)
            end

            return sp
        end
        --玩家自己的位置
        local mySp = createPosBuild( mydatapos,MY_POS_TYPE )
        if mySp then
            map:addChild(mySp)
        end
        
        --获取联盟信息
        local GuildInfo = g_AllianceMode.getBaseData()

        --获取联盟成员列表
        local GuildPlayers = g_AllianceMode.getSelfHaveAlliance() and  g_AllianceMode.getGuildPlayers() or {}

        local GuildLeaderID = 0
        --leader_player_id
        if GuildInfo and GuildInfo.leader_player_id and  GuildInfo.id > 0  then
            GuildLeaderID = tonumber(GuildInfo.leader_player_id)
        end

        if GuildPlayers then
            for key, var in ipairs(GuildPlayers) do
                if mydata.id ~= var.player_id then
                    --同盟位置（包括盟主）
                    local fpos = cc.p( var.Player.x,var.Player.y )

                    --print("Player.x,Player.y",var.player_id,var.Player.x,var.Player.y)

                    local fSp = (GuildLeaderID ~= var.player_id) and createPosBuild( fpos,FRIEND_POS_TYPE ) or createPosBuild( fpos,LEADER_POS_TYPE )
                    if fSp then
                        table.insert( m_GuildPlayers ,fSp)
                        map:addChild(fSp)
                    end
                end
            end
        end
        
        --联盟堡垒位置
        if GuildInfo and GuildInfo.id and  GuildInfo.id > 0  then
            local function callbcak(result, msgData)
                if result then
                    for key, data in pairs(msgData) do
                        local towerpos = cc.p(data.x,data.y)
                        local towerSp = createPosBuild( towerpos,TOWER_POS_TYPE )
                        if towerSp then
                            table.insert( m_GuildPlayers ,towerSp)
                            map:addChild(towerSp)
                        end
                    end
                end
            end
            g_sgHttp.postData("guild/viewGuildBuild",{type = 1},callbcak,true)
        end

        ShowGuildPlayers(true)

    end
end

function ShowGuildPlayers(isShow)
    if isShow == nil then
        return
    end

    if m_GuildPlayers then
        for i, Player in ipairs(m_GuildPlayers) do
            Player:setVisible(isShow)
        end
    end
end

function MapInit()
    
    local sview = m_Map:getChildByName("ScrollView")
    sview:setContentSize( cc.size(g_display.visibleSize.width,g_display.visibleSize.height))
    sview:setInnerContainerSize(m_Map:getContentSize())
    --sview:jumpToPercentHorizontal(50)

    sview:getChildByName("Image_4"):setVisible(false)
    local map = sview:getChildByName("Panel_1"):getChildByName("Image_3")

    local restab = {}
    local index = 1
    while index do
        local tab = sview:getChildByName("Image_4"):getChildByName(string.format("tishi%d",index))
        if tab then
            table.insert( restab,tab )
            index = index + 1
        else
            break
        end
    end
    
    local lvtb = {
        "1-3",
        "2-4",
        "3-5",
        "4-6",
        "5-7",
        "6-8",
    }

    for i, tab in ipairs(restab) do
        tab:getChildByName("Text_1"):setString( g_tr("SmallMapResLevel") .. (lvtb[i] or "0"))
    end


    local size = map:getContentSize()

    local posT = cc.p( size.width/2, size.height )
    local posL = cc.p( 0, size.height/2 )
    local posB = cc.p( size.width/2, 0 )
    local posR = cc.p( size.width, size.height/2 )
    
    map:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local touchPos =  map:convertToNodeSpace( sender:getTouchEndPosition())
            local isInMap = MapHelper.parallelogramContainsPoint(
            posT,
            posL,
            posB,
            posR,
            touchPos)

            if isInMap then
                
                local pos = MapHelper.out_position_2_bigTileIndex( touchPos,size )
                print("touch other",MapHelper.out_position_2_bigTileIndex( touchPos,size ).x,MapHelper.out_position_2_bigTileIndex( touchPos,size ).y)
                --解除当前锁定
                require("game.maplayer.worldMapLayer_bigMap").closeSmallMenu()
                require("game.maplayer.worldMapLayer_bigMap").closeInputMenu()
                
                require("game.maplayer.worldMapLayer_bigMap").changeBigTileIndex_Manual(pos,true)
                m_Root:removeFromParent()

                --print("在小地图上面")
                --local sp = cc.Sprite:create( Image_2:getTexture() )
                --local test =  Image_2:clone()
                --test:setPosition( touchPos )
                --map:addChild(test)、

                --local pos = MapHelper.out_position_2_bigTileIndex( touchPos,size )
                --print("pospospospospospospospospospos",pos.x,pos.y)
            end

        end
    end)

    local master_data = g_PlayerMode.GetData()
    --print("我的世界地图坐标",master_data.x,master_data.y,MapHelper.m_MapContentSize.width,MapHelper.m_MapContentSize.height,MapHelper.m_TileTotalCount)
    --print("我的世界地图坐标",MapHelper.m_MapContentSize.width/size.width ,MapHelper.m_MapContentSize.height/size.height)




end

--说明
function Desc()

    if m_DescView == nil then
        return
    end

    local root = m_DescView:getChildByName("scale_node")

    Image_2 = root:getChildByName("Image_2") --我的城堡
    Image_3 = root:getChildByName("Image_3")--盟主
    Image_4 = root:getChildByName("Image_4")--联盟成员
    Image_5 = root:getChildByName("Image_5")--联盟堡垒
    
    --zhcn
    
    root:getChildByName("Text_1"):setString( g_tr("SmallMapMyTower") )
    root:getChildByName("Text_2"):setString( g_tr("SmallMapTowerKing") )
    root:getChildByName("Text_3"):setString( g_tr("SmallMapAlliancePlayer") )
    root:getChildByName("Text_4"):setString( g_tr("SmallMapAllianceTower") )

end
--返回
function Back()

    if m_BackView == nil then
        return
    end

    local root = m_BackView:getChildByName("scale_node")
    local back_btn = root:getChildByName("Button_1")
    back_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            m_Root:removeFromParent()
        end
    end)

    local back_btn = root:getChildByName("Button_2")
    back_btn:setVisible(false)


    --zhcn
    back_btn:getChildByName("Text_9"):setString( g_tr("Back") )
end

--信息开关
function InfoOnOff()
    if m_InfoOnOffView == nil  then
        return
    end
    local root = m_InfoOnOffView:getChildByName("scale_node")
    local onoff_btn = root:getChildByName("Button_3")
    local btn_panel = root:getChildByName("Panel_2_0"):getChildByName("Panel_2")
    btn_panel:setPositionY( -btn_panel:getContentSize().height )

    local isShow = true
    btn_panel:setPositionY(0)

    local function touchListener( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            isShow = not isShow
            if isShow then
                btn_panel:setPositionY(0)
            else
                btn_panel:setPositionY( -btn_panel:getContentSize().height )
            end
        end
    end

    onoff_btn:addTouchEventListener(touchListener)
    local res_btn = btn_panel:getChildByName("Button_1")
    res_btn:getChildByName("Text_1"):setString(g_tr("SmallMapRes"))
    

    res_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local pic = sender:getChildByName("Image_1")
            pic:setVisible( not pic:isVisible() )
            local sview = m_Map:getChildByName("ScrollView")
            sview:getChildByName("Image_4"):setVisible(not pic:isVisible())
        end
    end)


    local res_btn = btn_panel:getChildByName("Button_2")
    res_btn:getChildByName("Text_1"):setString(g_tr("SmallMapAlliance"))

    res_btn:getChildByName("Image_1"):setVisible(false)
    res_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local pic = sender:getChildByName("Image_1")
            pic:setVisible( not pic:isVisible() )
            ShowGuildPlayers( not pic:isVisible() )
        end
    end)
end
--国王归属信息
function KingInfo()
    --m_KingInfoView
    if m_KingInfoView then
        m_KingInfoView:setVisible(false)
        local kingWarData = g_kingInfo.GetData()
    
        local root = m_KingInfoView:getChildByName("scale_node")
        root:getChildByName("Text_1"):setVisible(false)

        if kingWarData then
            dump(kingWarData)
        end
    end

end

function clear()
    m_Root = nil
    m_Map = nil
    m_KingInfoView = nil
    m_BackView = nil
    m_DescView = nil
    m_InfoOnOffView = nil
    Image_2 = nil
    Image_3 = nil
    Image_4 = nil
    Image_5 = nil
    m_GuildPlayers = {}
end


return smallMapLayer