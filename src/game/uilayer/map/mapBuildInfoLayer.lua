local mapBuildInfoLayer = {}
setmetatable(mapBuildInfoLayer,{__index = _G})
setfenv(1,mapBuildInfoLayer)


local m_Root = nil
local m_JGCallBack = nil --进攻只有小怪有
local m_JJCallBack = nil --集结只有BOSS有
local m_allianceType = nil
local m_BuildSeverData = nil
local GO_NPC = 6
local GO_BOSS = 12
local GO_HSB = 13

function clearGlobal()
    m_Root = nil
    m_JGCallBack = nil
    m_JJCallBack = nil
    m_allianceType = nil
    m_BuildSeverData = nil
end



function create( buildServerData,jg_callback,jj_callback )
    
    --print("callback",callback)

    dump(buildServerData)
    clearGlobal()

    m_BuildSeverData = buildServerData

    local buildId = m_BuildSeverData.map_element_id

    local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end

    local rootLayer = cc.Layer:create()
	m_Root = rootLayer

    rootLayer:registerScriptHandler(rootLayerEventHandler)


    local Alliance_Type = 
    {
        [1] = nil,--联盟堡垒
        [2] = nil,--联盟超级矿
        [3] = nil,--联盟矿场
        [4] = nil,--联盟仓库
        [5] = nil,--资源建筑
        [6] = showInfoView2NPC, --NPC
        [7] = nil,--玩家城堡
        [8] = nil,--王城
        [12] = showInfoView2NPC, --BOSS
        [13] = showInfoView2NPC,
    }
    
    m_JGCallBack = jg_callback
    m_JJCallBack = jj_callback

    local builddata = g_data.map_element[ tonumber( buildId ) ]
    m_allianceType = tonumber(builddata.alliance_type)

    print("buildId,m_allianceType",buildId,m_allianceType)

    local widget = Alliance_Type[ m_allianceType ]( builddata)
    rootLayer:addChild(widget)
    return rootLayer

end


--怪物信息界面
function showInfoView2NPC(data)
    --print( "i am buildId ",buildId )
    local monster_id = data.npc_id
    local monster_data = g_data.npc[ monster_id ]
    --print( "怪物ID ",monster_id, g_tr( monster_data.monster_name ))
    local widget = g_gameTools.LoadCocosUI("monster.csb",5)
    local root = widget:getChildByName("scale_node")

    local name = root:getChildByName( "Text_1" )
    name:setString( g_tr( monster_data.monster_name ) )

    local lv = root:getChildByName("Text_1_0")
    lv:setString( string.format("lv.%s",tostring(monster_data.monster_lv) ) )

    local picPanel = root:getChildByName("Panel_picture")
    --dump(monster_data)
    local pic = ccui.ImageView:create( g_resManager.getResPath(monster_data.img) )  --root:getChildByName( "Image_show" )
    pic:setPosition( cc.p( picPanel:getContentSize().width/2,picPanel:getContentSize().height/2 ) )
    --pic:setScale(0.8)
    --pic:setPosition(cc.p( 280,388 ))
    picPanel:addChild( pic)
    
    local desc = root:getChildByName("Text_2")
    desc:setString(  string.format("x:%d y:%d",m_BuildSeverData.x,m_BuildSeverData.y)  )
    --desc:setVisible(false)

    local function colFun(sender,eventType)
        if eventType == ccui.TouchEventType.ended then 
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            
            local mapConfigData = g_data.map_element[m_BuildSeverData.map_element_id]
            --if mapConfigData then 
                local collectLayer = require("game.uilayer.map.collectLayer")
                collectLayer:createLayer({x = m_BuildSeverData.x, y = m_BuildSeverData.y},mapConfigData,m_BuildSeverData)
            --end
        end
    end

    --收藏按钮
    local colBtn =  root:getChildByName("Image_4")
    colBtn:addTouchEventListener(colFun)


    local lv_desc = root:getChildByName("Text_4")
    local needFMLv = monster_data.monster_lv - 1
    --BOSS需要
    if m_allianceType == GO_BOSS then
        needFMLv = monster_data.monster_lv
    end
    lv_desc:setString(g_tr("MapBuildLevel",{lv = ( needFMLv ) }))


    local function close(sender,eventType)
        if eventType == ccui.TouchEventType.ended then 
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            m_Root:removeFromParent()
        end
    end
    
    local close_panel = widget:getChildByName( "mask" )
    close_panel:addTouchEventListener( close )
    root:addTouchEventListener( close )
    
    local droptitile = root:getChildByName("Text_3")
    droptitile:setString( g_tr( "MapBuildDrop" ) )

    local list = root:getChildByName( "ListView_1" )
    list:setItemsMargin(20)
    local dorp_id = monster_data.drop_show
    local list = root:getChildByName("ListView_1")
    local itemMode = cc.CSLoader:createNode("monster01.csb")

    --掉落道具显示
    if dorp_id then
        for _, value in ipairs(dorp_id) do
            --[[dump(value)
            local itemPanel = itemMode:clone()
            list:pushBackCustomItem(itemPanel)
            local pic = itemPanel:getChildByName("scale_node"):getChildByName("pic")
            pic:setVisible(false)
            itemPanel:getChildByName("scale_node"):getChildByName("Text_1"):setVisible(false)
            ]]
            --道具ID
            local item_type = value[1]
            local item_id = value[2]
            local item_num = 1
            --道具配置数据
            local item_data = g_data.item[ tonumber( item_id ) ]

            local item = require("game.uilayer.common.DropItemView").new(item_type, item_id,item_num)
            g_itemTips.tip(item,item_type,item_id)
            item:setCountEnabled(false)
            item:setNameVisible(false)
            item:setPosition(pic:getPosition())
            --itemPanel:getChildByName("scale_node"):addChild(item)
            list:pushBackCustomItem(item)
        end
    end

    root:getChildByName("Text_7"):setString(g_tr("MapBuildFight"))
    root:getChildByName("Text_jj"):setString( g_tr("collectionBattle") )
    local gj_btn = root:getChildByName("Image_6")
    local jj_btn = root:getChildByName("Button_jj")

    local can_level = 0

    local player_data = g_PlayerMode.GetData()
    
    if player_data then
        can_level = player_data.monster_lv + 1

        --BOSS只能打当前等级的小怪才能打这个BOSS
        if m_allianceType == GO_BOSS then
            can_level = player_data.monster_lv
        end
    end
    
    --BOSS
    if m_allianceType == GO_BOSS then
        gj_btn:setVisible(false)
        root:getChildByName("Text_7"):setVisible(false)
        jj_btn:setPositionX(gj_btn:getPositionX())
        root:getChildByName("Text_jj"):setPositionX(root:getChildByName("Text_7"):getPositionX())
    else
        --获取和氏璧
        if m_allianceType == GO_HSB then
            droptitile:setString( g_tr( "MapBuildGetHSBTitle" ) )
            root:getChildByName("Text_7"):setString(g_tr("MapBuildGetHSB"))
        end

        jj_btn:setVisible(false)
        root:getChildByName("Text_jj"):setVisible(false)
    end
    
    --lv_desc:setVisible(false)
    --lv_desc:setScale(5)

    if can_level < monster_data.monster_lv then
        gj_btn:setVisible(false)
        root:getChildByName("Text_7"):setVisible(false)
        root:getChildByName("Text_jj"):setVisible(false)
        lv_desc:setVisible(true)
        jj_btn:setVisible(false)
    else
        if m_allianceType == GO_BOSS then
            lv_desc:setTextColor(cc.c3b( 230,30,30 ))
            lv_desc:setString(g_tr("MapCanFBossDesc"))
        elseif m_allianceType == GO_NPC then
            lv_desc:setTextColor(cc.c3b( 30,230,30 ))
            lv_desc:setString(g_tr("MapCanFNpcDesc"))
        else
            lv_desc:setVisible(false)
        end
    end

    root:getChildByName("Text_zltj"):setString( g_tr("MapCanGoPowerStr") .. monster_data.recommand_power )


    --引导
    g_guideManager.registComponent(9999988,gj_btn)
    
    --进攻
    gj_btn:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then 
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            --引导
            g_guideManager.execute()
            if m_JGCallBack then
                --print("进攻")
                m_JGCallBack()
            end

            m_Root:removeFromParent()
        end
    end)

    jj_btn:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

            --判断是否建造战争大厅
            if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.battleHall) == nil then
                g_airBox.show(g_tr("MapJJError"),3)
                return
            end

            if not g_AllianceMode.getSelfHaveAlliance() then
                g_airBox.show(g_tr("battleHallNoAlliance"),3)
                return
            end

            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if m_JJCallBack then
                m_JJCallBack()
            end
            m_Root:removeFromParent()
        end
    end)
    
    g_guideManager.execute()
    
    return widget
end

return mapBuildInfoLayer