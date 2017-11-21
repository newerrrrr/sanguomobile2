
--邀请入盟

local mainSurfaceAllianceInvite = {}
setmetatable(mainSurfaceAllianceInvite,{__index = _G})
setfenv(1,mainSurfaceAllianceInvite)


local m_Root = nil
local m_Widget = nil
local m_inviteData = nil 

local function clearGlobal()
    m_Root = nil
    m_Widget = nil
end

function create()
    
    clearGlobal()
    
    local rootLayer = cc.Layer:create()
    m_Root = rootLayer
    local schedulers = {}
    local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
            schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_visible, 0 , false)
        elseif eventType == "exit" then
            for k , v in ipairs(schedulers) do
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
            end
        elseif eventType == "enterTransitionFinish" then
        elseif eventType == "exitTransitionStart" then
        elseif eventType == "cleanup" then
            if(rootLayer == m_Root)then
                clearGlobal()
                g_gameCommon.removeAllEventHandlers(mainSurfaceAllianceInvite)
            end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)


    m_Widget = g_gameTools.LoadCocosUI("ItemName_union3.csb",9)
    m_Widget:setPositionY(m_Widget:getPositionY() + 120)    
    rootLayer:addChild(m_Widget)
    local nodeTips = m_Widget:getChildByName("scale_node"):getChildByName("Panel_1")
    local btnDetail = nodeTips:getChildByName("Button_1")
    btnDetail:getChildByName("Text_1"):setString(g_tr("allianceDetail"))
    btnDetail:addClickEventListener(function()
            nodeTips:setVisible(false)
            updateInviteList(m_inviteData)
        end)
    nodeTips:setVisible(false)
    nodeTips:getChildByName("Text_1"):setString(g_tr("allianceInviteTips"))  

    --注册联盟邀请消息推送
    local function inviteJoinAlliance(obj, tcpData)
        dump(tcpData, "==tcpData")
        if nil == m_inviteData then 
            m_inviteData = {}
        end 
        table.insert(m_inviteData, tcpData)

        --显示tips或者邀请列表
        local nodeTips = m_Widget:getChildByName("scale_node"):getChildByName("Panel_1")
        local listView = m_Widget:getChildByName("scale_node"):getChildByName("ListView_1")
        local items = listView:getItems()
        if g_guideManager.getLastShowStep() then 
            nodeTips:setVisible(false) 
            listView:removeAllChildren() 
        else 
            if #items == 0 then --如果列表为空则显示tips,否则在列表后面追加新的邀请数据
                nodeTips:setVisible(true) 
            else 
                updateInviteList({tcpData})
            end 
        end 
        require("game.uilayer.mainSurface.mainSurfaceMenu").hideJoinGuildTip() 
    end
    g_gameCommon.addEventHandler(g_Consts.CustomEvent.GuildInvite, inviteJoinAlliance, mainSurfaceAllianceInvite)

    return rootLayer
end


function update_visible(dt)
    if m_Root == nil then
        return
    end
    if g_resourcesInterface.getResInterfaceShowCount() > 0 then
        m_Root:setVisible(false)
    else
        m_Root:setVisible(true)
    end
end


function updateInviteList(arrayData) 
    if nil == arrayData then return end 

    if m_Root and m_Widget then 
        local listView = m_Widget:getChildByName("scale_node"):getChildByName("ListView_1")
        
        local function removeListItem(item)
            local guild_id = item:getChildByName("Button_1"):getTag()
            for k, v in pairs(m_inviteData) do 
                if v.guild.id == guild_id then 
                    table.remove(m_inviteData, k)
                    break 
                end 
            end 
            local idx = listView:getIndex(item) 
            listView:removeItem(idx)
        end 

        local function onRefuse(sender)
            local item = sender:getParent()
            local itemSize = item:getContentSize() 
            removeListItem(item)

            --自适应大小
            local allItems = listView:getItems()
            local h = math.min(3, #allItems) * itemSize.height  
            listView:setContentSize(cc.size(itemSize.width, h))            
            listView:jumpToBottom()
        end 
        local function onAccept(sender)
            local function onResult(result, data) 
                if result then 
                    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.AllianceMainLayer"):create())
                    clearAllInvites()
                else 
                    removeListItem(sender:getParent())
                end 
            end 
            local guildId = sender:getTag()
            g_sgHttp.postData("guild/agreeRandInvite", {guild_id = guildId}, onResult, false) 
        end 

        listView:setScrollBarEnabled(false)
        local item_new 
        local item = cc.CSLoader:createNode("ItemName_union2.csb") 
        item:getChildByName("Text_1"):setString(g_tr("allianceTitle")..":")
        item:getChildByName("Text_3"):setString(g_tr("allianceInviteToYou"))
        item:getChildByName("Button_2"):getChildByName("Text_1"):setString(g_tr("refuse"))
        item:getChildByName("Button_1"):getChildByName("Text_1"):setString(g_tr("accept"))   
        for k, v in pairs(arrayData) do 
            item_new = item:clone()
            local btnRefuse = item_new:getChildByName("Button_2")
            local btnAccept = item_new:getChildByName("Button_1")
            local panel_tip = item_new:getChildByName("Panel_2")
            btnAccept:setTag(tonumber(v.guild.id))
            btnAccept:addClickEventListener(onAccept)
            btnRefuse:addClickEventListener(onRefuse)
            local lbname = item_new:getChildByName("Text_2")
            local line = item_new:getChildByName("Panel_1")
            local campName = ""
            if v.camp_id and tonumber(v.camp_id) > 0 then 
                campName = g_tr("city_battle_short_camp"..v.camp_id) 
            end 
            lbname:setString(v.guild.name .. campName)  
            line:setContentSize(cc.size(lbname:getContentSize().width, 1)) 
            listView:pushBackCustomItem(item_new) 

            local title = v.guild.name .. campName 
            local desc = g_tr("allianceLeader").."|<#253, 208,110#>"..v.guild.leader_player_nick.."|".."|<#\n#>|" 
            desc = desc .. g_tr("allianceMenberCount") .. "|<#253, 208,110#>"..string.format("%d/%d", v.guild.num, v.guild.max_num).."|".."|<#\n#>|" 
            desc = desc .. g_tr("alliancePower") .. "|<#253, 208,110#>"..v.guild.guild_power.."|"              
            g_itemTips.tipStr(panel_tip, title, desc) 
        end 

        local allItems = listView:getItems()
        if #allItems > 0 then
            --自适应大小 
            local itemSize = item:getContentSize() 
            local h = math.min(3, #allItems) * itemSize.height  
            listView:setContentSize(cc.size(itemSize.width, h))
            listView:doLayout()
            listView:jumpToBottom() 
        end 
    end 
end 

function clearAllInvites()
    m_inviteData = nil 
    if m_Root and m_Widget then 
        local nodeTips = m_Widget:getChildByName("scale_node"):getChildByName("Panel_1")
        local listView = m_Widget:getChildByName("scale_node"):getChildByName("ListView_1")
        nodeTips:setVisible(false)
        listView:removeAllChildren()
    end     
end 

--城内外切换UI变更
function viewChangeShow()
    -- if m_Root and m_Widget then 
    --     local changeMapScene = require("game.maplayer.changeMapScene")
    --     local mapStatus = changeMapScene.getCurrentMapStatus()
    --     if mapStatus == changeMapScene.m_MapEnum.home then--城内
    --         m_Widget:setVisible(true) 
    --     elseif mapStatus == changeMapScene.m_MapEnum.world then--城外
    --         m_Widget:setVisible(false) 
    --     end 
    -- end 
end 

function isViewShowing()
    local isVisible = false 
    if m_Root and m_Widget then 
        if m_Widget:isVisible() then 
            local nodeTips = m_Widget:getChildByName("scale_node"):getChildByName("Panel_1")
            local listView = m_Widget:getChildByName("scale_node"):getChildByName("ListView_1")  
            local items = listView:getItems()
            if nodeTips:isVisible() or (listView:isVisible() and #items > 0 ) then 
                isVisible = true 
            end 
        end 
    end 

    return isVisible 
end 


return mainSurfaceAllianceInvite
