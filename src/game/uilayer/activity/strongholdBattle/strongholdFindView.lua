--region strongholdFindView.lua
--Author : liuyi
--Date   : 2016/8/1
--此文件由[BabeLua]插件自动生成
local strongholdFindView = class("strongholdFindView",require("game.uilayer.base.BaseLayer"))
local BATTLE_TYPE = 9

function strongholdFindView:ctor()
    strongholdFindView.super.ctor(self)
    self:InitUI()
end

function strongholdFindView:InitUI()
    self.PlayerData = g_PlayerMode.GetData()
    self.layout = self:loadUI("Stronghold_main2.csb")
    self.root = self.layout:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
             g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:close()
        end
    end)
    self.root:getChildByName("Text_1"):setString(g_tr("sholdTitle"))
    self.root:getChildByName("Text_c2"):setString(g_tr("sholdList"))
    
    --选中的TAB标记
    --local juDianListBtn = self.root:getChildByName("Button_yq1")
    
    local zhanBaoBtn = self.root:getChildByName("Button_yq2")
    local commitBtn = self.root:getChildByName("Button_qd")
    local showListBtn = self.root:getChildByName("Button_ph")

    self.list = self.root:getChildByName("ListView_1_0")
    self:showList()
    --self:changeTab(selTab)
    zhanBaoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            --[[local function getData(data)
                dump(data)
            end
            require("game.uilayer.battleHall.BattleHallMode"):getBattleLog(getData)]]
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local function callback(result,data)
                if result == true then
                    g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleRecordView").new(data))
                end
            end

            g_sgHttp.postData("Army/getBattleLog", {type = BATTLE_TYPE}, callback)
            
        end
    end)

   
    showListBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            --1003
            local MissionMode = require("game.uilayer.activity.allianceMission.AllianceMissionMode") 
            local missionTypeEnum = MissionMode:getMissionTypeEnum()
            require("game.uilayer.activity.ActivityMainLayer").show(1003,missionTypeEnum.judian_fight)

            --local MissionMode = require("game.uilayer.activity.allianceMission.AllianceMissionMode") 
            --local missionTypeEnum = MissionMode:getMissionTypeEnum()
            --g_sceneManager.addNodeForUI(require("game.uilayer.activity.allianceMission.ActivityAllianceMission"):create(self, missionTypeEnum.judian_fight))
        end
    end)


    commitBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:showList()
        end
    end)

    --zhcn
    commitBtn:getChildByName("Text_2"):setString(g_tr("sholdChangeFind"))
    showListBtn:getChildByName("Text_2"):setString(g_tr("rankTitleStr"))
    zhanBaoBtn:getChildByName("Text_1"):setString(g_tr("attackDetails"))

end

function strongholdFindView:showList()
    self.list:removeAllChildren()
    local npcData = nil
    local function callback(result , data)
        if result == true then
            npcData = data.npc
            table.sort(npcData,function (a,b)
                local sPos = cc.p(self.PlayerData.x,self.PlayerData.y)
                local runLengthA = math.floor(cc.pGetDistance(sPos,cc.p( tonumber(a.x),tonumber(a.y) )))
                local runLengthB = math.floor(cc.pGetDistance(sPos,cc.p( tonumber(b.x),tonumber(b.y) )))
                return runLengthA < runLengthB
            end)
        end
    end

    local HelpMode = require("game.maplayer.worldMapLayer_helper")

    local block_Id = require("game.maplayer.worldMapLayer_bigMap").getCurrentShowCenterAreaID() or HelpMode.areaIndex_2_areaId(HelpMode.bigTileIndex_2_areaIndex(cc.p(self.PlayerData.x,self.PlayerData.y)))

    --HelpMode.areaIndex_2_areaId(HelpMode.bigTileIndex_2_areaIndex(cc.p(self.PlayerData.x,self.PlayerData.y)))

    g_sgHttp.postData("map/findItem",{ blockId = block_Id , elementId = g_Consts.MapFindPointElementId.JD }, callback)
    
    local nodeMode = cc.CSLoader:createNode("Stronghold_list2.csb")

    if npcData and #npcData > 0 then

        self.root:getChildByName("Text_3"):setVisible(false)

        for _, npc in ipairs(npcData) do
            
            local node = nodeMode:clone()

            local dataConfig = g_data.map_element[2001]
            --头像
            local iconBorder = node:getChildByName("Image_k1_0")

            local icon = ccui.ImageView:create(g_resManager.getResPath(dataConfig.img_mail))

            icon:setPosition(cc.p(iconBorder:getContentSize().width/2, iconBorder:getContentSize().height/2 ))

            iconBorder:addChild(icon)

            node:getChildByName("Text_1"):setString(g_tr(dataConfig.name))

            local posTxt = node:getChildByName("Text_2")

            posTxt:setString(string.format("X:%d Y:%d",tonumber(npc.x), tonumber(npc.y) ))
            
            --下划线
            local line = node:getChildByName("Panel_x1")

            line:setSize(cc.size( posTxt:getContentSize().width + 4,2))

            --据点状态
            local jdStatus = node:getChildByName("Text_3_0")

            --dump(npc)

            --无人占领的状态
            if (npc.guild_id == nil or npc.guild_id == "0") and (npc.player_nick == nil or npc.player_nick == "") then

                node:getChildByName("Text_3"):setVisible(false)

                jdStatus:setTextColor(cc.c3b( 127,127,127 ))

                jdStatus:setPositionX( jdStatus:getPositionX() - 47 )

                jdStatus:setString(g_tr("sholdNoBody"))
            --有联盟玩家占领
            elseif npc.guild_id and npc.guild_id ~= "0" then

                node:getChildByName("Text_3"):setString(g_tr("sholdGuild"))

                jdStatus:setString( tostring(npc.guild_name) )

            --无联盟玩家占领
            elseif npc.player_nick and npc.player_nick ~= "" then

                jdStatus:setTextColor(cc.c3b( 30,230,30 ))

                node:getChildByName("Text_3"):setString(g_tr("sholdPlayer"))

                jdStatus:setString( tostring(npc.player_nick) )
            end

            
            local sPos = cc.p(self.PlayerData.x,self.PlayerData.y)

            local ePos = cc.p( tonumber(npc.x),tonumber(npc.y))

            local runLength = math.floor(cc.pGetDistance(sPos,ePos))

            node:getChildByName("Text_2_0_0"):setString( g_tr("sholdLength") .. runLength )

            node:getChildByName("Text_2_0"):setString(g_tr("worldmap_KM"))

            local gotoBtn = node:getChildByName("Button_qw")
            
            gotoBtn:getChildByName("Text_1_0"):setString(g_tr("sholdGoTo"))
            gotoBtn:getChildByName("Text_1_0"):setPosition( cc.p( gotoBtn:getContentSize().width/2,gotoBtn:getContentSize().height/2 ) )

            gotoBtn:addTouchEventListener( function (sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    
                    --[[print("111111111111",npc.x,npc.y)

                    require("game.maplayer.worldMapLayer_bigMap").closeSmallMenu()
                    require("game.maplayer.worldMapLayer_bigMap").closeInputMenu()
                    require("game.maplayer.worldMapLayer_bigMap").changeBigTileIndex_Manual(cc.p( npc.x,npc.y ),true)]]

                    require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex(cc.p( tonumber(npc.x),tonumber(npc.y) ))
                    g_guideManager.removeGameFeature(g_guideManager.gameFeatures.ACTIVITY)
                    g_guideManager.removeGameFeature(g_guideManager.gameFeatures.ALLIANCE)

                    self:close()
                end
            end )

            self.list:pushBackCustomItem(node)

        end
    else
        self.root:getChildByName("Text_3"):setVisible(true)
        self.root:getChildByName("Text_3"):setString(g_tr("sholdTellMoveMap"))
    end
end


return strongholdFindView
--endregion
