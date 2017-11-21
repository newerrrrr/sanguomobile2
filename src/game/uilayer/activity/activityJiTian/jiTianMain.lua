local jiTianMain = class("jiTianMain", require("game.uilayer.base.BaseLayer"))
local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()

function jiTianMain:ctor()
    jiTianMain.super.ctor(self)
end

function jiTianMain:onEnter()
    self.nData = nil
    local function callback(res,msgData)
        if true == res then
            self.nData = msgData
            dump(self.nData)
        end
    end
    g_sgHttp.postData("player/getSacrificeGM",{},callback)

    if self.nData == nil then
        self:close()
        return
    end
    
    self:_InitUI()
    if self.nData.end_time and self.nData.end_time > 0 then
        self.timer = self:schedule( handler(self,self.updateTime) ,1)
        self:updateTime()
    end
end

function jiTianMain:_InitUI()
    self.layer = cc.CSLoader:createNode("activity4_mian6.csb")
    self:addChild(self.layer)
    local showPanel = self.layer:getChildByName("Panel_wpp")
    self.list = showPanel:getChildByName("ListView_1")
    self.show = self.layer:getChildByName("Panel_rere")
    
    local function setGetOneShow()
        local itemId = self.nData.itemId
        if itemId then
            local num = g_BagMode.findItemNumberById(itemId)
            if num > 0 then
                self.layer:getChildByName("Panel_wpp"):getChildByName("Image_yb1"):loadTexture( g_resManager.getResPath(g_data.item[itemId].res_icon))
                self.layer:getChildByName("Panel_wpp"):getChildByName("Text_xh2"):setString("1" .. "(" ..num..")"  )
            else
                self.layer:getChildByName("Panel_wpp"):getChildByName("Image_yb1"):loadTexture( g_resManager.getResPath(1999007) )
                self.layer:getChildByName("Panel_wpp"):getChildByName("Text_xh2"):setString( tostring(self.nData.gem) )
            end
        else
            self.layer:getChildByName("Panel_wpp"):getChildByName("Image_yb1"):loadTexture( g_resManager.getResPath(1999007) )
            self.layer:getChildByName("Panel_wpp"):getChildByName("Text_xh2"):setString( tostring(self.nData.gem) )
        end
    end

    setGetOneShow()

    local getOneBtn = showPanel:getChildByName("Button_1")
    getOneBtn:addClickEventListener(function (args)
        local function getOneFun(args)
            local function callback(result,msgData)
                if true == result then
                    setGetOneShow()
                    g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CorReward").new(msgData, 1, nil, nil, nil, getOneFun, nil, self.nData.gem,self.nData.itemId,1))
                end
            end
            
            local itemId = self.nData.itemId
            if itemId and g_BagMode.findItemNumberById(itemId) > 0 then
                g_sgHttp.postData("Player/sacrificeToHeaven",{ camp_id = 0,multi_flag = 0,free_flag = 0,use_item_flag = 1 },callback)
            else
                g_sgHttp.postData("Player/sacrificeToHeaven",{ camp_id = 0,multi_flag = 0,free_flag = 0,use_item_flag = 0 },callback)
            end
        end
        getOneFun()
    end)
    getOneBtn:getChildByName("Text_4"):setString(g_tr("oneTimeToGod"))
    
    --十连抽
    local getTenBtn = showPanel:getChildByName("Button_2")
    getTenBtn:addClickEventListener(function ()
        local function getTenFun(args)
            local function callback(result,msgData)
                if true == result then
                    setGetOneShow()
                    g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CorReward").new(msgData, 10, nil, nil, getTenFun, nil, nil, self.nData.gemMulti))
                end
            end
            g_sgHttp.postData("Player/sacrificeToHeaven",{ camp_id = 0,multi_flag = 1,free_flag = 0,use_item_flag = 0 },callback)
        end
        getTenFun()
    end)
    getTenBtn:getChildByName("Text_4"):setString(g_tr("tenTimeToGod"))
    showPanel:getChildByName("Text_xh4"):setString( tostring(self.nData.gemMulti))
    self.layer:getChildByName("Panel_djs"):getChildByName("Text_8"):setString(g_tr("actEnd"))
    self.layer:getChildByName("Panel_wpp"):getChildByName("Text_1"):setString(g_tr("giftShowStrTitle"))
    local res = self:_LoadList()

    local helpBtn = self.layer:getChildByName("Button_wenh")
    helpBtn:addClickEventListener(function ()
        if self.nData.memo then
            --g_msgBox.show( self.nData.memo)
            require("game.uilayer.common.HelpInfoBox"):showForStr(self.nData.memo)
        end
    end)

end

function jiTianMain:_LoadList()
    local col = 3
    local row = math.ceil(#self.nData.wheel/col)
    local mode = cc.CSLoader:createNode("activity4_mian6_list.csb") 
    local index = 1
    local showWjData = nil
    for i = 1, row do
        local item = mode:clone()
        for j = 1, col do
            local data = self.nData.wheel[j]
            if data then
                local drop = data.drop
                local panel = item:getChildByName("Panel_"..j)
                if drop then
                    --local g_item
                    local iType = tonumber(drop[1][1])
                    local iId = tonumber(drop[1][2])
                    local iNum = 0
                    local icon = require("game.uilayer.common.DropItemView").new(iType,iId,iNum)
                    icon:enableTip()
                    icon:setScale(0.8)
                    icon:setCountEnabled(false)
                    icon:setPosition( cc.p( icon:getContentSize().width/2,icon:getContentSize().height/2 ) )
                    panel:addChild(icon)
                    --将魂
                    if g_data.item[iId].item_type == 5 and showWjData == nil then
                        showWjData = g_data.item[iId]
                    end
                else
                    panel:setVisible(false)
                end
                index = index + 1
            end
        end
        self.list:pushBackCustomItem(item)
    end
    
    if showWjData then
        local showGeneral = nil
        local godGeneralConfig = GodGeneralMode:getGodGeneralConfig()
        for _, godGeneral in pairs(godGeneralConfig) do
            if tonumber(godGeneral.general_item_soul) == tonumber(showWjData.id) then
                showGeneral = godGeneral
                break
            end
        end

        if showGeneral then
            local sp = g_resManager.getRes(showGeneral.general_big_icon)
            sp:setPosition(cc.p( self.show:getContentSize().width/2,self.show:getContentSize().height/2 ))
            self.show:addChild(sp )
        end
    end
end

function jiTianMain:updateTime()
    local timeTx = self.layer:getChildByName("Panel_djs"):getChildByName("Text_8_0")
    local time = self.nData.end_time - g_clock.getCurServerTime()
    if time > 0 then
        timeTx:setString(g_gameTools.convertSecondToString(time))
    else
        if self.timer then
            self:unschedule(self.timer)
            self.timer = nil
        end
    end
end

return jiTianMain