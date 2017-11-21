--region kingSelPlayerLayer.lua  --查询聘用官员
--Author : liuyi
--Date   : 2016/3/17
local kingSelPlayerLayer = class("kingSelPlayerLayer", require("game.uilayer.base.BaseLayer"))
local SHOW_COUNT = 8
local m_Root = nil

function kingSelPlayerLayer:ctor(kingType)
    kingSelPlayerLayer.super.ctor(self)
    m_Root = nil
    m_Root = self
    self.kingType = kingType
    self:initUI()
end

function kingSelPlayerLayer:initUI()
    
    self.layer = self:loadUI("KingOfWar_bestowAReward_panel.csb")

    self.root = self.layer:getChildByName("scale_node")

    local close_btn = self.root:getChildByName("close_btn")
    self:regBtnCallback(close_btn,function ()
		self:close()
	end)
    
    local showStr = g_tr("kwar_appoint")

    if self.kingType == 2 then
        showStr = g_tr("kwar_appointDown")
    elseif self.kingType == 3 then
        showStr = g_tr("kwar_giftgive")
    end

    self.root:getChildByName("Text_1"):setString(showStr)
    self.root:getChildByName("Text_10"):setString(g_tr("kwar_findguild"))

    self.pageIndex = self.pageIndex or 0

    self.list = self.root:getChildByName("ListView_1")

    local inputMode = self.root:getChildByName("TextField_1")

    self.input = g_gameTools.convertTextFieldToEditBox(inputMode)

    self:searchResult()

    self:doSearchMore()


    self.findBtn = self.root:getChildByName("Button_5")
    
    self.findBtn:getChildByName("Text_11"):setString(g_tr("search"))


    self:regBtnCallback(self.findBtn,function ()
        if self.findStr ~= string.trim(self.input:getString()) then
            self:searchResult()
            self.findStr = string.trim(self.input:getString())
            self:doSearchMore()
        end
    end)

end

function kingSelPlayerLayer:doSearchMore()
    
    local res = false

    local findNameStr = string.trim( self.input:getString() )

    local function resultHandler( result , data )

        res = result
		if true == result then
            self.res = data
            if #self.res <= 0 then
                g_airBox.show(g_tr("searchResultMoreEmpty"))
            else
                self:pushBackResultItem()
                self.pageIndex = self.pageIndex + 1
            end
        else
            return
		end
	end
    
    local condition = g_AllianceMode.getSearchCondition()

    --print("findNameStr",findNameStr)
    
    g_sgHttp.postData("guild/searchGuild",
        {
            name = findNameStr or "",
            num = condition.max_num,
            condition_fuya_level = condition.condition_fuya_level,
            condition_player_power = condition.condition_player_power,
            need_check = condition.need_check,
            num_per_page = SHOW_COUNT,
            from_page = self.pageIndex,
        },
    resultHandler)

    return res

end

function kingSelPlayerLayer:searchResult()
    self.list:removeAllChildren()
    self.pageIndex = 0
    local PullToRefreshControl = require("game.uilayer.common.PullToRefreshControl").new()
    PullToRefreshControl:addListner(self.list,nil,handler(self, self.doSearchMore))
    self.list:addChild(PullToRefreshControl)
end

function kingSelPlayerLayer:pushBackResultItem()
    
    local resultList = self.res
    
    if #resultList <= 0 then
        return
    end
    
    local listItem = cc.CSLoader:createNode("KingOfWar_bestowAReward.csb")

    local row = math.ceil( #resultList / 2 )
    
    local index = 1

    local function itemTouch(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            --print("1111111111111111111111111111111",sender.guildId)

            local players = {}
            local guildId = sender.guildId
            local function callback(result,data)
                if true == result then

                    for key, var in pairs(data.PlayerGuild) do

                        table.insert(players,var)

                    end

                    g_sceneManager.addNodeForUI( require("game.uilayer.kingWar.kingChooseLayer"):create(players) )

                end
            end

            g_sgHttp.postData("Guild/viewAllMemberKing", { guild_id = guildId }, callback)

        end
    end
    
    for i = 1, row do
        
        local layout = ccui.Layout:create() 

        layout:setSize( cc.size( listItem:getContentSize().width * 2,listItem:getContentSize().height ))
         
        for j = 1, 2 do
         
            local guildData = resultList[index]

            if guildData then
                
                local item = listItem:clone()

                item:setPosition( cc.p( ( j - 1 ) * item:getContentSize().width + 30,0 ) )

                layout:addChild(item)

                local guildicon = item:getChildByName("equip"):getChildByName("pic")

                local currentIcon = g_AllianceMode.getAllianceIconId( guildData.icon_id )

                local iconInfo = g_data.alliance_flag[currentIcon]

                guildicon:loadTexture( g_resManager.getResPath(iconInfo.res_flag) )

                local powTx = item:getChildByName("Text_z")

                powTx:setString(  string.formatnumberthousands( guildData.guild_power ) )
                
                local guildTx = item:getChildByName("Text_19")

                guildTx:setString( guildData.name)

                local leaderTx = item:getChildByName("Text_18_0")

                leaderTx:setString( guildData.leader_player_nick )

                local guildPersonNumTx = item:getChildByName("Text_19_0")

                guildPersonNumTx:setString(  guildData.num .. "/" .. guildData.max_num )
                
                item:getChildByName("equip"):getChildByName("level_bg"):setVisible(false)

                item:getChildByName("equip"):getChildByName("Text_1"):setVisible(false)

                item.guildId = guildData.id

                item:setTouchEnabled(true)

                item:addTouchEventListener(itemTouch)

                index = index + 1
            end

         end

         self.list:pushBackCustomItem(layout)
    end
end

function kingSelPlayerLayer.removeLayer()
    if m_Root then
        m_Root:close()
    end
end


function kingSelPlayerLayer:onEnter()
    
end

function kingSelPlayerLayer:onExit()
    m_Root = nil
end

return kingSelPlayerLayer

--endregion
