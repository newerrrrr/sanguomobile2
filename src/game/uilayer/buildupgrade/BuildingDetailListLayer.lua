local BuildingDetailListLayer = class("BuildingDetailListLayer",function()
    return cc.Layer:create()
end)

function BuildingDetailListLayer:ctor(buildingId)
    local node = g_gameTools.LoadCocosUI("build_details_panel.csb",5)
    self:addChild(node)
    local baseNode = node:getChildByName("scale_node")
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    self._listView = baseNode:getChildByName("ListView_1")
    local m_buildInfo = g_data.build[buildingId]
    assert(m_buildInfo,"cannot found build with id:"..buildingId)
    
    baseNode:getChildByName("text"):setString(g_tr("buildDetailLevel",{build_name = g_tr_original(m_buildInfo.build_name),build_level = m_buildInfo.build_level}))
    baseNode:getChildByName("text_1"):setString(g_tr(m_buildInfo.description))

    --存放解锁信息
    local m_unlockBuildIds = {}
    
    local m_townerUnlocks = {}
    
    --获取解锁信息
    local function unlockInfo(type,value)
        local img = nil
        local str = ""
        if type == 1 then
            img = g_data.soldier[value].img_head
            str = g_tr(g_data.soldier[value].soldier_name)
        elseif type == 2 then
            img = g_data.trap[value].img_head
            str = g_tr(g_data.trap[value].trap_name)
        elseif type == 3 then
            img = g_data.science[value].img
            str = g_tr(g_data.science[value].name)
        elseif type == 4 then
            --学习栏位 学院取消了，所以这个忽略
        end
        return img,str
    end
    
    local allBuilds = {}
    for key, var in pairs(g_data.build) do
        if var.origin_build_id == m_buildInfo.origin_build_id then
            table.insert(allBuilds,var)
        end
    end
    
    table.sort(allBuilds,function(a,b)
        return a.build_level < b.build_level
    end)
    
    for key, var in ipairs(allBuilds) do
        if #var.unlock > 0 then
            for key, unlockGroup in pairs(var.unlock) do
                local type = unlockGroup[1]
                local showType = unlockGroup[2]
                local value = unlockGroup[3]
                if showType == 1 then
                    local level = 0
                    local buindConfigId = 0
                    if type == 1 then
                        buindConfigId = g_data.soldier[value].need_build_id
                    elseif type == 2 then
                        buindConfigId = g_data.trap[value].need_build_id
                    elseif type == 3 then
                        buindConfigId = g_data.science[value].need_build_id
                    elseif type == 4 then
                        --学习栏位 学院取消了，所以这个忽略
                    elseif type == 5 then
                        
                    end
                    if buindConfigId > 0 then
                        local img,name = unlockInfo(type,value)
                        m_unlockBuildIds[buindConfigId] = g_tr("buildDetailUnlock",{ build_name = name }) --解锁xxx
                    end
                elseif showType == 0 then
                    if type == 5 then
                        --公用升级/建造界面的描述，这里只有哨塔读用
                        if var.origin_build_id == 12 then --哨塔
                            if m_townerUnlocks[var.origin_build_id..""..value] == nil then
                                m_townerUnlocks[var.origin_build_id..""..value] = "tmp_emety"
                                    m_unlockBuildIds[var.id] = g_tr(value)
                                end
                            end
                         end
                    end
                end
  
            end
    end
    
    local titleContainer = baseNode:getChildByName("Panel_1")
    local eachMaxWidth = titleContainer:getContentSize().width/2
    
    --标题初始化
    do
        local titleStrs = {}
        
        table.insert(titleStrs,g_tr("buildDetailTitleLevel")) --等级
       --属性
        for key, output in pairs(m_buildInfo.output) do
            local type = output[1]
            local value = g_tr(g_data.output_type[type].desc)
            table.insert(titleStrs,value)
        end
        
        --最大容量信息
        if m_buildInfo.storage_max > 0 then
            table.insert(titleStrs,g_tr("recourseBuildMaxStore")) --最大存储容量
        end
        
        --解锁信息
        if table.nums(m_unlockBuildIds) > 0 then
            table.insert(titleStrs,g_tr("buildDetailTitleEffect")) --建筑效果
        end
        
        table.insert(titleStrs,g_tr("buildDetailTitlePower")) --战力

        
        local listSize = titleContainer:getContentSize()
        local eachWidth = math.min(listSize.width/#titleStrs,eachMaxWidth)
        for i = 1, #titleStrs do
            local text = ccui.Text:create(titleStrs[i], "cocos/cocostudio_res/simhei.TTF", 22)
            text:setTextAreaSize(cc.size(eachWidth - 10, 0))
            text:ignoreContentAdaptWithSize(false)
            text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            text:setPositionX(eachWidth * i - eachWidth/2)
            text:setPositionY(listSize.height * 0.5)
            titleContainer:addChild(text)
        end
    end
    
    --显示表格数据
    do
        local percent = 0
        local currentIdx = 1
        local itemModle =  cc.CSLoader:createNode("build_details_list1.csb")
        local createItem = function(buildInfo)
            local values = {} 
            table.insert(values,string.formatnumberthousands(buildInfo.build_level))--等级
            
            --属性
            for key, output in pairs(buildInfo.output) do
            	local type = output[1]
                local value = output[2]
                
                if type == 12 then --屯所要加上初始援军数量
                    value = value + tonumber(g_data.starting[57].data) 
                end
                
                local valStr = ""
                --local buffId = g_data.output_type[type].buff_id
                local buffId = 99999
                if buffId > 0 then
                    --local numType = g_data.buff[buffId].buff_type
                    local numType = g_data.output_type[type].num_type
                    if numType == 1 then
                        valStr = (value / 10000 * 100).."%"
                    else
                        valStr = string.formatnumberthousands(value)
                    end
                end
            	table.insert(values,valStr)
            end
            
            --最大容量信息
            if buildInfo.storage_max > 0 then
                table.insert(values,string.formatnumberthousands(buildInfo.storage_max))
            end
            
            --解锁信息
            if table.nums(m_unlockBuildIds) > 0 then
                if m_unlockBuildIds[buildInfo.id] then
                    table.insert(values,m_unlockBuildIds[buildInfo.id])
                else
                    table.insert(values," ")
                end
            end
            
            table.insert(values,string.formatnumberthousands(buildInfo.power)) --战力
            
            local item = itemModle:clone()
            local listSize = item:getContentSize()
            item:getChildByName("Panel_1"):getChildByName("Image_1_1"):setVisible(buildInfo.build_level == buildInfo.build_level)
            local eachWidth = math.min(listSize.width/#values,eachMaxWidth)
            for i = 1, #values do
            	local text = ccui.Text:create(values[i], "cocos/cocostudio_res/simhei.TTF", 24)
            	text:setTextAreaSize(cc.size(eachWidth - 10, 0))
                text:ignoreContentAdaptWithSize(false)
                text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                text:setPositionX(eachWidth * i - eachWidth/2)
                text:setPositionY(listSize.height * 0.5)
                item:addChild(text)
                
                --分割线
                if i < #values then
                    local size = cc.size(eachWidth,listSize.height)
                    local drawNode = cc.DrawNode:create()
                    drawNode:setAnchorPoint(cc.p(0, 0))
                    item:addChild(drawNode)
                    drawNode:drawSegment(
                        cc.p(0, size.height),
                        cc.p(0, 0), 1, cc.c4f(0, 0, 0, 0.5))
                    drawNode:setPositionX(eachWidth * i)
                end
                    
            end
            return item
        end
        for i = 1, #allBuilds do
        	local item = createItem(allBuilds[i])
        	self._listView:pushBackCustomItem(item)
        	item:getChildByName("Panel_1"):getChildByName("Image_1_0"):setVisible(i%2 == 0)
        	item:getChildByName("Panel_1"):getChildByName("Image_1_1"):setVisible(allBuilds[i].build_level == m_buildInfo.build_level)
        	if allBuilds[i].build_level == m_buildInfo.build_level then
        	   percent = (i-1)/#allBuilds*100
        	   currentIdx = i
        	end
        end
        
        if currentIdx >= 6 then
            self._listView:forceDoLayout() 
        end
        self._listView:jumpToPercentVertical(percent)
        
    end
    
end

return BuildingDetailListLayer