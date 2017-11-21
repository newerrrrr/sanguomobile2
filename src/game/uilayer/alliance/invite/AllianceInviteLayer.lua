local AllianceInviteLayer = class("AllianceInviteLayer",function()
    return ccui.Widget:create()
end)

local num_per_page = 6

function AllianceInviteLayer:resetListView()
    if self._listView then
        self._listView:removeFromParent()
        self._listView = nil
    end
    
    if self._listViewToClone == nil then
         local listView = self._baseNode:getChildByName("content"):getChildByName("ListView_1")
         listView:setVisible(false)
         self._listViewToClone = listView
    end
    
    local newList = self._listViewToClone:clone()
    self._listViewToClone:getParent():addChild(newList)
    newList:setVisible(true)
    self._listView = newList
    return newList
end

function AllianceInviteLayer:ctor()
    local node = g_gameTools.LoadCocosUI("alliance_invite_player.csb",5)
    self:addChild(node)
    g_resourcesInterface.installResources(node)
    local baseNode = node:getChildByName("scale_node")
    self._baseNode = baseNode
    
    --关闭本页
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent(true)
        end
    end)
    
    self._baseNode:getChildByName("content"):getChildByName("btn_filter"):setVisible(false)
    baseNode:getChildByName("Text_1"):setString(g_tr("allianceTitle"))
    
    self._results = {}
    self:resetListView()
    self._searchInput = self._baseNode:getChildByName("content"):getChildByName("TextField")
    self._searchInput = g_gameTools.convertTextFieldToEditBox(self._searchInput)
    self._pageIdx = 0
    self._targetPageIdx = 0
    self._lastKeyWord = ""
    
    local searchBtnClickHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("search handler")
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    
            self:doSearch()
        end
    end
    
    local searchBtn = self._baseNode:getChildByName("content"):getChildByName("btn_search")
    searchBtn:addTouchEventListener(searchBtnClickHandler)
    searchBtn:getChildByName("Text"):setString(g_tr("search"))--搜索
    searchBtn:getChildByName("Text"):setTouchEnabled(true)
    searchBtn:getChildByName("Text"):addTouchEventListener(searchBtnClickHandler)
    
    local btnPrePageClickHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:doSearchMore(false)
        end
    end
    
    local btnPrePage = baseNode:getChildByName("Button_1")
    btnPrePage:addTouchEventListener(btnPrePageClickHandler)
    btnPrePage:getChildByName("Text_2"):setString(g_tr("prePage"))
    btnPrePage:setEnabled(false)
    btnPrePage:setVisible(false)
    
    local btnNextPageClickHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:doSearchMore(true)
        end
    end
    
    local btnNextPage = baseNode:getChildByName("Button_2")
    btnNextPage:addTouchEventListener(btnNextPageClickHandler)
    btnNextPage:getChildByName("Text_2"):setString(g_tr("nextPage"))
    btnNextPage:setVisible(false)
    
end

function AllianceInviteLayer:reqSearchHandler(callback)
    local resultHandler = function(result, msgData)
        g_busyTip.hide_1()
        if callback then
            callback(result, msgData)
        end
    end
    --postData: {"type":1,"nick":"zhangsan","from_page":1,"num_per_page":10}
    g_busyTip.show_1()
    g_sgHttp.postData("player/searchPlayer",{type = 1,nick = self._lastKeyWord,num_per_page = num_per_page,from_page = self._targetPageIdx},resultHandler,true)
end

function AllianceInviteLayer:doSearch()
    self._pageIdx = 0
    self._targetPageIdx = 0
    local keyword = self._searchInput:getString()
    keyword = string.trim(keyword)
    if keyword == "" then
        g_airBox.show(g_tr("searchKeywordEmptyTip"))
        return
    end
    self._lastKeyWord = keyword
    
    local resultHandler = function(result, msgData)
        if result then
            print("player/searchPlayer success")
            self._results = msgData
            if table.nums(msgData) == 0 then
                g_airBox.show(g_tr("palyerSearchResultIsEmpty"))
            else
               local btnPrePage = self._baseNode:getChildByName("Button_1")
               local btnNextPage = self._baseNode:getChildByName("Button_2")
               btnPrePage:setVisible(true)
               btnNextPage:setVisible(true)
            end
            self:searchResultHandler()
        end
    end
    
    self:reqSearchHandler(resultHandler)
end

function AllianceInviteLayer:doSearchMore(isNext)
    if isNext then
       self._targetPageIdx = self._pageIdx + 1
    else
       self._targetPageIdx = self._pageIdx - 1
       if self._targetPageIdx < 0 then
           self._targetPageIdx = 0
       end
    end
    
    local resultHandler = function(result, msgData)
        if result then
            self._results = msgData
            if #self._results <= 0 then
               g_airBox.show(g_tr("searchResultMoreEmpty"))
            else
               if isNext then
                   self._pageIdx = self._pageIdx + 1
               else
                   self._pageIdx = self._pageIdx - 1
                   if self._pageIdx < 0 then
                       self._pageIdx = 0
                   end
               end
               
               local btnPrePage = self._baseNode:getChildByName("Button_1")
               if self._pageIdx <= 0 then
                  btnPrePage:setEnabled(false)
               else
                  btnPrePage:setEnabled(true)
               end
               
               self:searchResultHandler()
            end
            
        end
    end
    self:reqSearchHandler(resultHandler)
end


function AllianceInviteLayer:searchResultHandler()
    
    self:resetListView()
    
    local listItem = cc.CSLoader:createNode("alliance_invite_list.csb")
    local listSize = listItem:getChildByName("player_item"):getContentSize()
    local row = 0
    local maxRow = math.ceil(#self._results/2)
    local heightDistance = 0
    local widthDistance = 30
    
    local currentIdx = 1
    for r = 1, maxRow do
        local container = ccui.Widget:create()
        container:setAnchorPoint(cc.p(0,0))
        container:setContentSize(cc.size((listSize.width + widthDistance)*2,listSize.height))
        for i = 1, 2 do
        local playerInfo = self._results[currentIdx]
        if playerInfo then
        
              local item = listItem:clone()
              item:setContentSize(listSize)
              if currentIdx%2 == 0 then
                item:setPositionX(listSize.width + widthDistance)
              else
                item:setPositionX(0)
              end
              --item:setPositionY(-listSize.height)
              container:addChild(item)
              self:updateListItem(item,playerInfo)
              
              local bg = item:getChildByName("player_item")
              bg:setTouchEnabled(true)
              bg:addTouchEventListener(function(sender,eventType)
                  if eventType == ccui.TouchEventType.ended then
                      print(item.data.id)
                      g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                      g_msgBox.show(g_tr("makeSureInvite"),nil,nil,
                            function(event)
                              if event == 0 then
                                  local resultHandler = function(result, msgData)
                                    if result then
                                       print("invited")
                                       g_airBox.show(g_tr("invitedPlayer"))
                                    end
                                  end
                                  --"invite_player_id":100017, "guild_id":7
                                  g_sgHttp.postData("guild/inviteGuild",{invite_player_id = item.data.id,guild_id = g_AllianceMode.getBaseData().id},resultHandler)
                              end
                            end,1)
                  end
              end)
          end
          currentIdx = currentIdx + 1
          
        end
        self._listView:pushBackCustomItem(container)
    end
    
end

function AllianceInviteLayer:updateListItem(item,data)
    item.data = data

    item:getChildByName("player_item"):getChildByName("bg_info"):getChildByName("label_1"):getChildByName("Text")
    :setString(g_tr("prePlayerName"))
    item:getChildByName("player_item"):getChildByName("bg_info"):getChildByName("label_2"):getChildByName("Text")
    :setString(g_tr("prePlayerPower"))

    local countryName = ""
    if data.camp_id and tonumber(data.camp_id) > 0 then
			countryName = "["..g_tr(g_data.country_camp_list[tonumber(data.camp_id)].short_name).."]"
		end
    
    item:getChildByName("player_item"):getChildByName("bg_info"):getChildByName("text_name_1")
    :setString(countryName..data.nick.."")
    
    item:getChildByName("player_item"):getChildByName("bg_info"):getChildByName("text_name_2")
    :setString(string.formatnumberthousands(data.power))
    
    local iconId = g_data.res_head[data.avatar_id].head_icon
    item:getChildByName("player_item"):getChildByName("pic_0"):loadTexture(g_resManager.getResPath(iconId))
    item:getChildByName("player_item"):getChildByName("pic"):loadTexture(g_resManager.getResPath(1010007)) --boader
end

return AllianceInviteLayer