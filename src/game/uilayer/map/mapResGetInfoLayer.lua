--region mapResGetInfoLayer.lua   --资源采集界面
--Author : liuyi
--Date   : 2016/3/23

local mapResGetInfoLayer = class("mapResGetInfoLayer", require("game.uilayer.base.BaseLayer"))
local QueueHelperMD = require ("game.maplayer.worldMapLayer_queueHelper")

local m_BuildServerData = nil --不能修改
local m_QData = nil
local m_ArmyUnitData = nil
local m_BuildBiffData = nil
local m_buildBuffConfig = nil
local m_IsJuDianZhan = nil

local function isHaveQueueDoing(buildServerData,queueType)
	local bigMap = require("game.maplayer.worldMapLayer_bigMap")
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
		if buildServerData.id == v.to_map_id then
			if v.type == queueType then
				return v
			end
		end
	end
	return nil
end


function mapResGetInfoLayer:getAllData(buildServerDataId)
    
    m_BuildServerData = require("game.maplayer.worldMapLayer_bigMap").getCurrentAreaDatas().Map[tostring(buildServerDataId)]

    if m_BuildServerData == nil then
        return
    end

    --require("game.maplayer.worldMapLayer_bigMap").getCurrentAreaDatas().Map[tostring(buildServerData.id)]

    m_QData = isHaveQueueDoing(m_BuildServerData, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING)

    dump(m_QData)

    if m_QData == nil then
        return
    end
    
    if m_QData.end_time - g_clock.getCurServerTime() <= 0 then
        return    
    end

    local armyUnitData = g_ArmyUnitMode.GetData()

    if armyUnitData == nil then
        return
    end
    
    local army_id = m_QData.army_id
    m_ArmyUnitData = {}

    for key, var in ipairs(armyUnitData) do
        if var.army_id == army_id then
            table.insert( m_ArmyUnitData,var )
        end
    end
    
    if m_ArmyUnitData == nil or table.nums(m_ArmyUnitData) <= 0 then
       return  
    end

    return true

end

function mapResGetInfoLayer:createLayer(buildServerDataId,isJD)
    self:clear()
    if self:getAllData(buildServerDataId) then
        m_IsJuDianZhan = isJD or false
        g_sceneManager.addNodeForUI( mapResGetInfoLayer:create())
    end
    
end

function mapResGetInfoLayer:ctor()
    mapResGetInfoLayer.super.ctor(self)
end

function mapResGetInfoLayer:onEnter()
    m_buildBuffConfig = g_data.build_buff_type[6]
    g_busyTip.show_1()
    require("game.uilayer.map.cityBufferLayer").getSeverBuffInfoAsync(m_buildBuffConfig,function (result,data)
         g_busyTip.hide_1()
        if result == true then
            m_BuildBiffData = data
            self:initUI()
            self.scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update_time), 1 , false)
        end
    end)
end


function mapResGetInfoLayer:initUI()
    
    if self.layout == nil then
        self.layout = self:loadUI("Iron_collection_main.csb")
    end

    self.root = self.layout:getChildByName("scale_node")

    local close_btn = self.layout:getChildByName("mask")
    --关闭按钮
	self:regBtnCallback(close_btn,function ()
        --g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
	end)


    --zhcn

    self.root:getChildByName("Text_3"):setString(g_tr("MapResCountStr"))
    self.root:getChildByName("Text_5"):setString(g_tr("MapResAlreadyCountStr"))
    
    --采集加成时间 据点战 隐藏
    self.root:getChildByName("Text_6"):setString(g_tr("MapResAddBuffStr"))

    self.root:getChildByName("Text_4"):setString(g_tr("MapResGetSpeedStr"))

    self.root:getChildByName("Text_7"):setString(g_tr("MapResGetAddStr"))
    
    self.root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))

    local resConfig = g_data.map_element[tonumber(m_BuildServerData.map_element_id)]
    local nowRes = m_BuildServerData.resource
    
    self.root:getChildByName("Text_b1"):setString( g_tr(resConfig.name) )
    self.root:getChildByName("Text_b2"):setString( string.format("(X:%d Y:%d)",m_BuildServerData.x,m_BuildServerData.y) )
    self.root:getChildByName("Text_3_0"):setString( tostring(nowRes))
    self.root:getChildByName("Text_4_0"):setString("0/h")
    self.root:getChildByName("Text_5_0"):setString("0")

	if m_QData then
        --self.root:getChildByName("Text_4_0"):setString( math.floor(m_QData.target_info.speed * 60) .. "/h" )

        local timeStep = 60
        
        if m_IsJuDianZhan then
            timeStep = 1
        end

        self.root:getChildByName("Text_4_0"):setString( math.floor(m_QData.target_info.speed * timeStep ) .. "/h" )

        self:update_time()
		--resource_num = resource_num - qd.target_info.speed / 60 *  math.max(0, g_clock.getCurServerTime() - qd.create_time)
	end

    local index = 1
    local showArmyNodes = {}

    while index do
        local node = self.root:getChildByName( string.format("Panel_%d",index) )
        if node then
            table.insert(showArmyNodes,node)
            index = index + 1
        else
            break
        end
    end

    for i, node in ipairs(showArmyNodes) do
        local armyData = m_ArmyUnitData[i]
        if armyData --[[and armyData.soldier_id ~= 0]] then
            local generalConfig = g_GeneralMode.GetBasicInfo( armyData.general_id, 1 )
            
            local name = node:getChildByName("Text_mz1")
            name:setString(g_tr(generalConfig.general_name))
            
            local pic = node:getChildByName("Image_bc1")
            node:getChildByName("Image_bc2"):setVisible(false)
            --pic:loadTexture( g_resManager.getResPath(generalConfig.general_icon) )
            local generalServerData = g_GeneralMode.getOwnedGeneralByOriginalId(generalConfig.general_original_id)
            local general = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General,generalConfig.id,1)
            general:setCountEnabled(false)
            general:setPosition( cc.p(pic:getContentSize().width/2,pic:getContentSize().height/2) )
            general:showGeneralServerStarLv(generalServerData.star_lv)
            pic:addChild(general)

            local s_num = node:getChildByName("Text_mz2")
            local soldierConfig = g_data.soldier[ armyData.soldier_id ]
            local sTypeIcon = node:getChildByName("Image_tb1")
            if soldierConfig == nil then
                sTypeIcon:setVisible(false)
                s_num:setVisible(false)
            else
                s_num:setString( tostring(armyData.soldier_num) )
                sTypeIcon:loadTexture(g_resManager.getResPath( soldierConfig.img_type ))
            end
            
            --dump(generalConfig)
        else
            node:setVisible(false)
        end
    end
    


    --使用道具增益的道具
    local useBuffItemBtn = self.root:getChildByName("Image_3")
    self:regBtnCallback(useBuffItemBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local function callback()
            require ("game.maplayer.worldMapLayer_bigMap").requestMapAllData_Manual()
            
            if self:getAllData(m_BuildServerData.id) then
                self:initUI()
            else
                self:close()
                return
            end
        end
        
        local cityGainAlertLayer = require("game.uilayer.map.cityGainLayer"):create(m_buildBuffConfig,m_BuildBiffData,callback)
        g_sceneManager.addNodeForUI(cityGainAlertLayer)
	end)

    if m_IsJuDianZhan then
        self.root:getChildByName("Text_3"):setString(g_tr("MapJuDianOverTime"))
        self.root:getChildByName("Text_4"):setString(g_tr("MapJuDianGetSpeedStr"))
        self.root:getChildByName("Text_5"):setString(g_tr("MapJuDianGetCountStr"))

        useBuffItemBtn:setVisible(false)
        self.root:getChildByName("Text_6"):setVisible(false)
        self.root:getChildByName("Text_7"):setVisible(false)
        self.root:getChildByName("Text_6_0"):setVisible(false)
    end

    -- Image_3


end

function mapResGetInfoLayer:update_time()
    
    if m_QData == nil then
        if self.scheduler ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
            self.scheduler = nil
        end

        self:close()
        return
    end
    
    local timeStep = m_IsJuDianZhan and 3600 or 60

    local getRes = m_QData.target_info.speed / timeStep * math.max(0, g_clock.getCurServerTime() - m_QData.create_time)
    local endTime = m_QData.end_time - g_clock.getCurServerTime()

    local nowRes = m_BuildServerData.resource - getRes

    self.root:getChildByName("Text_3_0"):setString( m_IsJuDianZhan and g_gameTools.convertSecondToString(endTime) or tostring(math.ceil(nowRes)) )

    self.root:getChildByName("Text_5_0"):setString( tostring( math.floor(getRes)) )

    local buffOverTimeTx =  self.root:getChildByName("Text_6_0")

    if m_BuildBiffData then
        local buffEndTime = m_BuildBiffData.expire_time - g_clock.getCurServerTime()
        buffEndTime = buffEndTime > 0 and buffEndTime or 0
        buffOverTimeTx:setString( g_gameTools.convertSecondToString( buffEndTime) )
        if buffEndTime > 0 then
            self.root:getChildByName("Text_4_0"):setColor(cc.c3b( 0,255,0 ))
        else
            self.root:getChildByName("Text_4_0"):setColor(cc.c3b( 255,255,255 ))
        end
    else
        buffOverTimeTx:setString("0")
    end

    if endTime <= -1 then
        if self.scheduler ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
            self.scheduler = nil    
        end

        self:close()
        return
    end

end

function mapResGetInfoLayer:onExit()
    if self.scheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end
    self:clear()
    print("mapResGetInfoLayer onExit")
end 

function mapResGetInfoLayer:clear()
    m_BuildServerData = nil --不能修改
    m_QData = nil
    m_ArmyUnitData = nil
    m_BuildBiffData = nil
    m_buildBuffConfig = nil
    m_IsJuDianZhan = false
end



return mapResGetInfoLayer
