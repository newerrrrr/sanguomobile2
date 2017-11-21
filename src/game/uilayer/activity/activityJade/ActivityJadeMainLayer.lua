--region ActivityJadeMainLayer.lua.lua
--Author : liuyi
--Date   : 2016/5/5
--此文件由[BabeLua]插件自动生成
local ActivityJadeMainLayer = class("ActivityJadeMainLayer", require("game.uilayer.base.BaseLayer"))

function ActivityJadeMainLayer:ctor()
    ActivityJadeMainLayer.super.ctor(self)
    self:initUI()
end

function ActivityJadeMainLayer:initUI()
    self.layout = self:loadUI("ForTheJade_main.csb")
    self.root = self.layout:getChildByName("scale_node")
    local closeBtn = self.root:getChildByName("Button_x")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:close()
        end
    end)
    
    --zhcn
    self.root:getChildByName("Text_c2"):setString(g_tr("HSBTitle"))

    local configData = g_data.treasure_buff
    
    local list = self.root:getChildByName("ListView_1")
    local nodeMode = cc.CSLoader:createNode("ForTheJade_list.csb")
    local playerData = g_PlayerMode.GetData()
    local indexLv = 0
    
    self.root:getChildByName("Text_1_0"):setVisible(false)
    if playerData and playerData.hsb then
        self.root:getChildByName("Text_1_0"):setString(g_tr("HSBNum",{ num = playerData.hsb }))
    end

    for index, value in ipairs(configData) do
        local node = nodeMode:clone()
        list:pushBackCustomItem(node)
        node:getChildByName("Text_1"):setString( "×" .. value.count_min)
        node:getChildByName("Text_1"):setTextColor(cc.c3b( 255,255,255 ))
        node:getChildByName("Image_4"):loadTexture( g_resManager.getResPath(value.img) )
        node:getChildByName("Image_5"):setVisible(false)
        node:getChildByName("Text_2"):setString(g_tr(value.language_id))

        local buffValue = value.buff_value / 100

        node:getChildByName("Text_3"):setString("+" .. buffValue .. "%" )

        if playerData and playerData.hsb then
            if tonumber(playerData.hsb) < value.count_min then
                node:getChildByName("Image_4"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
                node:getChildByName("Text_3"):setTextColor(cc.c3b( 230,30,30 ))
            else
                indexLv = index
            end
        end
    end
    
    local nextLvData = configData[indexLv + 1]
    local noJoinStr = ""

    --没有加入联盟
    if not g_AllianceMode.getSelfHaveAlliance() then
        noJoinStr = g_tr("HSBJion")
    end

    if nextLvData then
        local hsb = 0 
        if playerData and playerData.hsb then
            hsb = playerData.hsb
        end
        self.root:getChildByName("Text_1"):setString( g_tr("HSBTips",{num1 = playerData.hsb ,num2 = ( nextLvData.count_min - hsb )}) )
        self.root:getChildByName("Text_1_1"):setString( noJoinStr )

    else
        self.root:getChildByName("Text_1"):setString( g_tr("HSBGetAllTips",{num = playerData.hsb}))
        self.root:getChildByName("Text_1_1"):setString( noJoinStr )
    end

    local getMoreBtn = self.root:getChildByName("Button_1")
    getMoreBtn:getChildByName("Text_2"):setString(g_tr("HSBMore"))
    getMoreBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

            if playerData == nil then
                return
            end

            require("game.uilayer.activity.activityJade.ActivityJadeMainLayer").gotoWorldToFindHSB(
            function ()
                self:close()
            end)

        end
    end)


    local showRankBtn = self.root:getChildByName("Button_2")
    
    if not g_AllianceMode.getSelfHaveAlliance() then
        showRankBtn:getChildByName("Text_2"):setString(g_tr("HSBJionStr"))
    else
        showRankBtn:getChildByName("Text_2"):setString(g_tr("HSBRank"))
    end
    
    showRankBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

            if g_AllianceMode.getSelfHaveAlliance() then 
                local isHSBOpen = require("game.uilayer.activity.allianceMission.AllianceMissionMode"):isTreasureFightValid()
                if isHSBOpen then
                    self:close()
                    require("game.uilayer.activity.ActivityMainLayer").show(1003, 2)
                else
                    g_airBox.show( g_tr("HSBModeOver"),3)
                end
            else
                self:close()
		        g_sceneManager.addNodeForUI(require("game.uilayer.alliance.AllianceMainLayer"):create())
            end
        end
    end)


end


function ActivityJadeMainLayer.gotoWorldToFindHSB(fun)
    
    --[[if true then
        g_msgBox.show( g_tr("HSBNoFind"))
        return
    end]]

    local _fun = fun

    local playerData = g_PlayerMode.GetData()
    if playerData == nil then
        return
    end

    local function callback(result , data)
        if result == true then
            if data.npc and #data.npc > 0 then
                local jumpData = data.npc[1]
                if _fun then
                    _fun()
                end
                require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex(cc.p( tonumber(jumpData.x),tonumber(jumpData.y) ))
            else
                g_msgBox.show( g_tr("HSBNoFind"),nil,2)
            end
        end
    end
    
    local HelpMode = require("game.maplayer.worldMapLayer_helper")
    local block_Id = HelpMode.areaIndex_2_areaId(HelpMode.bigTileIndex_2_areaIndex(cc.p( tonumber(playerData.x),tonumber(playerData.y) )))
    g_sgHttp.postData("map/findItem",{ blockId = block_Id , elementId = g_Consts.MapFindPointElementId.HSB }, callback)
end 

function ActivityJadeMainLayer:onEnter()
    
end

function ActivityJadeMainLayer:onExit()
   
end

return ActivityJadeMainLayer


--endregion
