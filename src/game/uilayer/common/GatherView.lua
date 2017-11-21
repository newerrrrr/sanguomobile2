local GatherView = class("GatherView", require("game.uilayer.base.BaseLayer"))

function GatherView:ctor()
	GatherView.super.ctor(self)

	self.mode = require("game.uilayer.battleHall.BattleHallMode").new()

    self.uilist = {}

    self:setData()
end

function GatherView:setData()
    local function getWar(value)
        self.data = value
        if self.data == nil then
            return
        end
        self:initUI()
    end
    
    self.mode:warArmyInfo(getWar)
end

function GatherView:initUI()

    self.layout = self:loadUI("alliance_WarRecord.csb")

    self.root = self.layout:getChildByName("scale_node")
    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_2 = self.root:getChildByName("Text_2")
    self.ListView_1 =self.root:getChildByName("ListView_1")
    self.Image_2 = self.root:getChildByName("Image_2")
    self.Image_2_0 = self.root:getChildByName("Image_2_0")

    self.Text_1:setString(g_tr("collectionBattle"))
    self.Text_2:setVisible(false)
    self.Image_2:setVisible(false)
    self.Image_2_0:setVisible(false)

    self:initFun()
    self:addEvent()
    self:updateData()
end

function GatherView:initFun()
    self.getData = function(value)
         self.data = value
         if self.data == nil  then
            self:close()
            return
        end
        self:updateData()
    end

    self.enterCallback = function(time, data, ArmyId,isUseMove)
        local function timeCallback(timeValue)
            local timeNum = timeValue.time[tostring(ArmyId)]
            if timeNum >time and isUseMove ~= 1 then
                local player = g_PlayerMode.GetData()

                local runLength = cc.pGetDistance(cc.p(player.x, player.y),cc.p(data[1].from_x,data[1].from_y))
                            --使用体力
                local needMove= math.max(math.floor(math.pow(runLength,0.911) * 0.45),5)

                g_msgBox.show(g_tr("collectMoreTime", {move=needMove}),nil,nil,
                    function ( eventtype )
                        if eventtype == 0 then

                            --获取当前体力
                            local playerMove = g_PlayerMode.getMove() or 0
                            --是否体力足够不够使用元宝购买
                            local useOverMove = playerMove - needMove

                            if useOverMove < 0 then
                                local needGem = math.abs(useOverMove) * 2
                                g_msgBox.showConsume(needGem, g_tr("RunQuickUseGemIsTrue"), nil, nil, function ()
                                    self.mode:gotoGather(data[1].from_x,data[1].from_y, data[1].id, ArmyId, self.getData, 1)
                                    if battleHallInfoView ~= nil then
                                        battleHallInfoView:close()
                                    end
                                end)
                            else
                                self.mode:gotoGather(data[1].from_x,data[1].from_y, data[1].id, ArmyId, self.getData, 1)
                                if battleHallInfoView ~= nil then
                                    battleHallInfoView:close()
                                end
                            end
                        end
                    end , 1)
            else
                self.mode:gotoGather(data[1].from_x,data[1].from_y, data[1].id, ArmyId, self.getData,isUseMove)
                if battleHallInfoView ~= nil then
                    battleHallInfoView:close()
                end
            end
        end
        self.mode:getGotoTime(data[1].from_x,data[1].from_y, 3, timeCallback)
    end

    self.cancelGather = function(qid)
        self.mode:cancelGather(qid, self.getData)
    end

    self.callbackStayQueue = function(qid)
        self.mode:callbackStayQueue(qid, self.getData)
    end

    self.showInfo = function(data)
        g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleHallInfoView").new(data, self.cancelGather,self.callbackStayQueue, self.enterCallback, self.updateList, self.gotoPos)) 
    end

    self.inviteInfo = function(data)
        g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleInviteView").new(data[1])) 
    end

    self.updateList = function()
        self.mode:warArmyInfo(self.getData)
    end

    self.gotoPos = function(x, y)
        local function callback()
                local BigMap = require("game.maplayer.worldMapLayer_bigMap")        
                BigMap.closeSmallMenu()
                BigMap.closeInputMenu()
                BigMap.changeBigTileIndex_Manual(cc.p(tonumber(x), tonumber(y)),true)
        end
        require("game.maplayer.changeMapScene").changeToWorld(false, callback)

        if g_AllianceMode.getMainView() then
            g_AllianceMode.getMainView() :removeFromParent()
        end

        self:close()
    end

    self.closeWin = function()
        self:close()
    end
end

function GatherView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
end

function GatherView:updateData()
    local len = #self.data.gatherArmy
    if len%2 ==1 then
        len = (len + 1)/2
    else
        len = len/2
    end

    if len == 0 then
        require("game.uilayer.mainSurface.mainSurfaceMenu").closeGatherIcon()
    end

    for i=1, len do
        local item = nil
        if self.uilist[i] == nil then
            item  = require("game.uilayer.battleHall.BattleHallItemView").new(self.showInfo, self.inviteInfo, self.gotoPos, self.enterCallback, nil, self.closeWin)
            self.uilist[i] = item
            self.ListView_1:pushBackCustomItem(item)
        else
            item = self.uilist[i]
        end
        item:show(self.data.gatherArmy[2*i-1], self.data.gatherArmy[i*2])
    end

    if len < #self.uilist then
        for i= len+1, #self.uilist do
            self.ListView_1:removeItem(self.ListView_1:getIndex(self.uilist[i]))
            self.uilist[i] = nil
        end
    end
end

return GatherView