local mainKingWarLayer = class("mainKingWarLayer", 
    function ()
        return g_gameTools.LoadCocosUI("KingOfWar.csb",3)
        --cc.CSLoader:createNode("KingOfWar.csb")
    end
)

local m_root = nil
local m_datalist = nil
local m_kingWarData = nil
local m_guildInfo = nil

--g_AllianceMode.getBaseData()

function mainKingWarLayer:ctor()
    
    self:clear()

    m_root = self
    
    local function handler(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        elseif event == "enterTransitionFinish" then
            --self:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" then
            --self:onExitTransitionStart()
        elseif event == "cleanup" then
            --self:onCleanup()
        end
    end
    
    self:registerScriptHandler(handler)
    self:getChildByName("scale_node"):getChildByName("Image_7"):addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingActivityLayer"):create())
        end
    end)

    g_gameCommon.addEventHandler(g_Consts.CustomEvent.KingPoint, mainKingWarLayer.update_getData, self)

    --self:init()
end

function mainKingWarLayer:init()
    
    self.root = self:getChildByName("scale_node")
    --[[[local showList_Btn = self.root:getChildByName("Image_7")
    showList_Btn:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:showList()
        end
    end)]]
    
    --zhcn 国王战
    self.root:getChildByName("Text_1"):setString(g_tr("kworld_title_1"))
    --zhcn 后结束
    self.root:getChildByName("Text_2"):setString(g_tr("kworld_title_2"))
    --zhcn 查看
    self.root:getChildByName("Text_8"):setString(g_tr("kworld_show"))

    self:upShowList()

end

--用于显示数据
function mainKingWarLayer:upShowList()
    
    local myPointData = m_datalist.GuildKingPoint[tostring(m_guildInfo.id)]
    --自己联盟数据
    if myPointData then
        --联盟名称
        self.root:getChildByName("Text_7"):setString(myPointData.guild_name or "")
        --积分
        self.root:getChildByName("Text_7_0"):setString( g_tr("kworld_point",{ num = myPointData.point or 0 }) )
    else
        local showStr = g_tr("noAllianceTip")
        if g_AllianceMode.getSelfHaveAlliance() then
            showStr = m_guildInfo.name or ""
        end
         --联盟名称
        self.root:getChildByName("Text_7"):setString(showStr)
        --积分
        self.root:getChildByName("Text_7_0"):setString( g_tr("kworld_point",{ num = 0 }) )
        
    end

    local guildPointSortData = self:guildPointSort()

    --第1名称
    local OnePointData = guildPointSortData[1]
    if OnePointData then
        self.root:getChildByName("Text_4_0"):setString(OnePointData.guild_name or "")
        self.root:getChildByName("Text_4_1"):setString( g_tr("kworld_point",{ num = OnePointData.point or 0 }) )
    else
        self.root:getChildByName("Text_4_0"):setString( g_tr("freeStatus") )
        self.root:getChildByName("Text_4_1"):setString( "" )
    end

    --第2名称
    local TwoPointData = guildPointSortData[2]
    if TwoPointData then
        self.root:getChildByName("Text_5_0"):setString(TwoPointData.guild_name or "")
        self.root:getChildByName("Text_5_1"):setString( g_tr("kworld_point",{ num = TwoPointData.point or 0 }) )
    else
        self.root:getChildByName("Text_5_0"):setString( g_tr("freeStatus") )
        self.root:getChildByName("Text_5_1"):setString( "" )
    end

    --第3名称
    local ThreePointData = guildPointSortData[3]
    if ThreePointData then
        self.root:getChildByName("Text_6_0"):setString(ThreePointData.guild_name or "")
        self.root:getChildByName("Text_6_1"):setString( g_tr("kworld_point",{ num = ThreePointData.point or 0 }) )
    else
        self.root:getChildByName("Text_6_0"):setString( g_tr("freeStatus") )
        self.root:getChildByName("Text_6_1"):setString( "" )
    end

     --self.timeScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update), 1 , false)

     self:scheduleUpdateWithPriorityLua( handler( self,self.update), 0)
end


--时间更新方法
function mainKingWarLayer:update()
    local end_time = m_kingWarData.end_time - g_clock.getCurServerTime()
    --print("end_time",end_time)
    local timetxt = self.root:getChildByName("Text_1_0")
    --timetxt:setString( string.format( "%02d:%02d:%02d",g_clock.formatTimeHMS( end_time )) )
    timetxt:setString( g_gameTools.convertSecondToString(end_time) )

    --关闭倒计时定时器
    if not g_kingInfo.isKingBattleStarted() then
        g_airBox.show(g_tr("kwar_close"))
        self:setVisible(false)
        self:unscheduleUpdate()
    end

end

function mainKingWarLayer:guildPointSort()
    local guildPointSortData = {}
    for _, var in pairs(m_datalist.GuildKingPoint) do
        table.insert( guildPointSortData,var )
    end

    table.sort( guildPointSortData,function (a,b)
        return a.point > b.point
    end )

    return guildPointSortData
end

function mainKingWarLayer:onEnter( )
	print("mainKingWarLayer onEnter")
    self.scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update_getData), 10 , false)
    
end

function mainKingWarLayer:onExit( )
    self:clear()
    print("mainKingWarLayer onExit")
end

function mainKingWarLayer:clear()
    m_root = nil
    m_datalist = nil
    m_kingWarData = nil
    m_guildInfo = nil

    if self.scheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
        self.scheduler = nil
    end

    self:unscheduleUpdate()

    g_gameCommon.removeAllEventHandlers(self)
end


--定时刷新数据更新界面
function mainKingWarLayer:update_getData()

    if m_root == nil then
        return
    end

    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()

    m_kingWarData = g_kingInfo.GetData()
    
    if not g_kingInfo.isKingBattleStarted() or m_kingWarData.status ~= g_Consts.KingWarStatusType.Fight then
        return
    end

    --公会信息
    m_guildInfo = g_AllianceMode.getBaseData()

    if m_guildInfo == nil then
        --print("m_guildInfo is nil")
        return
    end

    local function callback( result , data )
		if true == result then
            m_datalist = data
            --国王战开启，并且国王战数据存在
            if  m_kingWarData and m_datalist and m_guildInfo and mapStatus == changeMapScene.m_MapEnum.world then
                m_root:init()
                m_root:setVisible(true)
            end
		end
	end

    --异步获取数据
    if g_kingInfo.isKingBattleStarted() then
        g_sgHttp.postData("King/getScore", nil, callback,true)
    end
    
end

function mainKingWarLayer.viewChangeShow()
    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    if mapStatus == changeMapScene.m_MapEnum.home then
        if m_root then
            m_root:removeFromParent()
            m_root = nil
        end
    elseif mapStatus == changeMapScene.m_MapEnum.world then
        
        if m_root == nil then --确保国王战开始创建
            g_sceneManager.addNodeForUI( mainKingWarLayer:create() )
            m_root:setVisible(false)
        end

        if m_root then
            m_root:update_getData()
        end
    elseif mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then
         if m_root then
            m_root:removeFromParent()
            m_root = nil
        end
    end
end

return mainKingWarLayer