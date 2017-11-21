local mainSurfaceQuickLink = {}
setmetatable(mainSurfaceQuickLink,{__index = _G})
setfenv(1,mainSurfaceQuickLink)

local m_Root = nil
local m_Widget = nil
local m_Scale_node = nil

local function clearGlobal()
    m_Root = nil
    m_Widget = nil
    m_Scale_node = nil
end


function create()
    
    clearGlobal()
    
    local rootLayer = cc.Layer:create()
    m_Root = rootLayer

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
    rootLayer:registerScriptHandler(rootLayerEventHandler)
    
    m_Widget = g_gameTools.LoadCocosUI("anniuluko.csb",6)
    rootLayer:addChild(m_Widget)
    
    m_Scale_node = m_Widget:getChildByName("scale_node")
    

    local hospitalBtn = m_Scale_node:getChildByName("Image_2")
    m_Scale_node:getChildByName("Image_2"):getChildByName("Text_1"):setString(g_tr("mainsurfaceCure"))
    hospitalBtn:setVisible(false)
    hospitalBtn:setTouchEnabled(true)
    hospitalBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local serverData =  g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.hospital)
            if serverData then
                require("game.maplayer.changeMapScene").gotoHome_Place(serverData.position)
                
                if require("game.gamedata.InjuredSoldierData").requestData() then
                    g_sceneManager.addNodeForUI(require("game.uilayer.hospital.HospitalLayer"):create(serverData.build_id,serverData))
                end
            end
            
        end
    end)
        
        
    local helpBtn =  m_Scale_node:getChildByName("Image_1")
    helpBtn:setVisible(false)

    helpBtn:setTouchEnabled(true)
    helpBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            helpBtn:setVisible(false)
            
            --local mode = require("game.uilayer.tun.TunMode").new()
            --mode:helpAll() --帮助所有
            g_PlayerHelpMode.HelpAll_Async() --帮助所有
        end
    end)
    
    return rootLayer
end

function checkAllianceHelp()
    if m_Root then
        local helpBtn =  m_Scale_node:getChildByName("Image_1")
        helpBtn:setVisible(g_PlayerHelpMode.GetHelpNum() > 0)
        m_Scale_node:getChildByName("Image_1"):getChildByName("Text_sz"):setString(g_PlayerHelpMode.GetHelpNum().."")
        m_Scale_node:getChildByName("Image_1"):getChildByName("Text_1"):setString(g_tr("mainsurfaceHelpAllianceMember"))
    end
end

function checkHospital()
    if m_Root then
        
        local serverData =  g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.hospital)
        
        local hospitalBtn =  m_Scale_node:getChildByName("Image_2")
        hospitalBtn:setVisible(false)
        if serverData then
            local buildStatus = tonumber(serverData.status)
            --医馆
            if g_PlayerBuildMode.FindBuildIsWorkFinish_ID(serverData.id) then
                --可回收
            else
                if buildStatus ~= g_PlayerBuildMode.m_BuildStatus.working and (buildStatus ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng and table.total(g_PlayerSoldierInjuredMode.getData()) > 0) then
                   hospitalBtn:setVisible(true)
                end
            end
        end
        
    end
end

function checkQuickLink()
    checkAllianceHelp()
    checkHospital()
end

function viewChangeShow()
     if m_Root then
        local changeMapScene = require("game.maplayer.changeMapScene")
        local mapStatus = changeMapScene.getCurrentMapStatus()
        if mapStatus == changeMapScene.m_MapEnum.home then
           m_Root:setVisible(true)
        elseif mapStatus == changeMapScene.m_MapEnum.world then
          m_Root:setVisible(false)
        end
     end
end

return mainSurfaceQuickLink