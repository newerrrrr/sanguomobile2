local AllianceSearchLayer = class("AllianceSearchLayer",function()
    return cc.Layer:create()
end)

local actionTag = 456546
function AllianceSearchLayer:resetListView()
    if self._listView then
        self._listView:removeFromParent()
        self._listView = nil
    end
    
    if self._listViewToClone == nil then
         local listView = self._baseNode:getChildByName("ListView_1")
         listView:setVisible(false)
         self._listViewToClone = listView
    end
    
    local newList = self._listViewToClone:clone()
    self._listViewToClone:getParent():addChild(newList)
    newList:setVisible(true)
    self._listView = newList
    return newList
end

local num_per_page = 10 --每页显示的个数
function AllianceSearchLayer:ctor()
    local uiLayer = cc.CSLoader:createNode("alliance_content_search.csb")
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("content_0")
    self._baseNode = baseNode
    self:setContentSize(baseNode:getContentSize())

    self:resetListView()
    
    self._results = {}
    
    self._pageIdx = 0
    self._targetPageIdx = 0
    self._lastKeyWord = ""
    
    self._requestListDirty = true
    self._playerGuildRequest = {}
    
    local btnSearchClickHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("searchHandler")
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:onPullDownRefresh()
        end
    end
    
    local btnSearch = baseNode:getChildByName("btn_search")
    btnSearch:addTouchEventListener(btnSearchClickHandler)
    btnSearch:getChildByName("Text"):setString(g_tr("search"))--搜索
    btnSearch:getChildByName("Text"):setTouchEnabled(true)
    btnSearch:getChildByName("Text"):addTouchEventListener(btnSearchClickHandler)
    
    
    local btnSearchConditionClickHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local serchConditionLayer = require("game.uilayer.alliance.AllianceSearchConditionLayer"):create()
            g_sceneManager.addNodeForUI(serchConditionLayer)
        end
    end
    local btnSearchCondition = baseNode:getChildByName("btn_filter")
    btnSearchCondition:addTouchEventListener(btnSearchConditionClickHandler)
    btnSearchCondition:getChildByName("Text"):setString(g_tr("filtrate"))--筛选
    btnSearchCondition:getChildByName("Text"):setTouchEnabled(true)
    btnSearchCondition:getChildByName("Text"):addTouchEventListener(btnSearchConditionClickHandler)
    
    
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
    
    local btnNextPageClickHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:doSearchMore(true)
        end
    end
    
    local btnNextPage = baseNode:getChildByName("Button_2")
    btnNextPage:addTouchEventListener(btnNextPageClickHandler)
    btnNextPage:getChildByName("Text_2"):setString(g_tr("nextPage"))

    
    self._inputEditBox = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("TextField"))
    self:doSearch()
end

--local function scrollViewEvent(sender, evenType)
--    if evenType == ccui.ScrollviewEventType.scrollToBottom then
--        print("SCROLL_TO_BOTTOM")
--    elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then
--        print("SCROLL_TO_TOP")
--    end
--end

function AllianceSearchLayer:doSearch() --重新请求搜索信息（下拉刷新）reset
    local keyword = self._inputEditBox:getString()
    keyword = string.trim(keyword)
    
    self._lastKeyWord = keyword

    local btnPrePage = self._baseNode:getChildByName("Button_1")
    btnPrePage:setEnabled(false)

    local resultHandler = function(result, msgData)
        if result then
            self._results = msgData
            self:searchResult()
            if #self._results <= 0 then
               g_airBox.show(g_tr("searchResultEmpty"))
            else
               --self._pageIdx = self._pageIdx + 1
            end
        end
    end
    self:reqSearchHandler(resultHandler)
end

function AllianceSearchLayer:doSearchMore(isNext) --请求下一页搜索信息（上拉刷新）
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
               
               self:resetListView()
               
               self:pushBackResultItem()
            end
            
        end
    end
    self:reqSearchHandler(resultHandler)
end

function AllianceSearchLayer:reqSearchHandler(resultHandler)
    --postData: {"name":"aa","num":30,"condition_fuya_level":3,"condition_player_power":100,"need_check":-1}
    local condition = g_AllianceMode.getSearchCondition()
    print("pageIndex:",self._pageIdx)
    g_busyTip.show_1()
    g_sgHttp.postData(
        "guild/searchGuild",
        {
          name = self._lastKeyWord,
          num = condition.max_num,
          condition_fuya_level = condition.condition_fuya_level,
          condition_player_power = condition.condition_player_power,
          need_check = condition.need_check,
          from_page = self._targetPageIdx,num_per_page = num_per_page
        },
        function(result, msgData)
            g_busyTip.hide_1()
            if resultHandler then
                resultHandler(result, msgData)
            end
        end
        ,true)
end

--function AllianceSearchLayer:onPullUpRefresh()
--    print("onPullUpRefresh")
--    
--    local keyword = self._inputEditBox:getString()
--    keyword = string.trim(keyword)
--    
--    if self._lastKeyWord == keyword then
--        self:doSearchMore()
--    else
--        self:onPullDownRefresh()
--    end
--end

function AllianceSearchLayer:onPullDownRefresh()
    print("onPullDownRefresh")

    self._pageIdx = 0
    self._targetPageIdx = 0
    self:doSearch()
end


function AllianceSearchLayer:searchResult()
    self:resetListView()
    self._pageIdx = 0
    
--    local PullToRefreshControl = require("game.uilayer.common.PullToRefreshControl").new()
--    PullToRefreshControl:addListner(self._listView,nil,handler(self, self.onPullUpRefresh))
--    self._listView:addChild(PullToRefreshControl) 

    
    self:pushBackResultItem()

end

function AllianceSearchLayer:pushBackResultItem()
    
    --申请加入联盟
    local applyHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local resultHandler = function(result, msgData)
                if result then
                    --g_airBox.show("apply success")
                    sender:setEnabled(false)
                    sender:getChildByName("Text"):setString(g_tr("applyed"))
                    if sender.data.need_check == 0 then --直接加入成功
                        sender:getChildByName("Text"):setString(g_tr("joined"))
                        g_airBox.show(g_tr("allianceJoinSuccess"))
                        g_AllianceMode.reqAllAllianceData()
                        g_AllianceMode.getMainView():reload()
                        g_AllianceMode.updateWorldMap()
                    else --申请成功
                        self._requestListDirty = true
                    end
                end
            end
            --postData: {"guild_id":7}
            local guildId = sender.data.id
            assert(guildId > 0)
            g_sgHttp.postData("guild/applyForGuild",{guild_id = guildId},resultHandler)
        end
    end
    
    local resultList =  self._results
    if #resultList > 0 then
        local mailHandler = function(sender)
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local nickNamme = sender.data.leader_player_nick
            local pop = require("game.uilayer.mail.MailContentWritePop").new(false,nickNamme)
            g_sceneManager.addNodeForUI(pop)
        end
    
    
        
        
        local resultHandler = function(result, msgData)
            
            g_busyTip.hide_1()
            
            if result then
               self._requestListDirty = false
               self._playerGuildRequest = msgData.PlayerGuildRequest
            end
            
            local playerGuildRequest = self._playerGuildRequest
            
--            local listItem = cc.CSLoader:createNode("alliance_search_list.csb")
--            --listItem:getChildByName("scale_node"):getChildByName("bg_info"):getChildByName("lable_1"):getChildByName("Text"):setString("")
--            for key, result in pairs(resultList) do
--                local item = listItem:clone()
--                self:updateItem(item,result)
--                self._listView:pushBackCustomItem(item)
--                --dump(result)
--                local btnMail = item:getChildByName("scale_node"):getChildByName("bg_info"):getChildByName("btn_mail")
--                btnMail:getChildByName("Text"):setString(g_tr("btnMail"))
--                
--                btnMail.data = item.data
--                btnMail:addClickEventListener(mailHandler)
--                
--                local btnApply = item:getChildByName("scale_node"):getChildByName("bg_info"):getChildByName("btn_apply")
--                btnApply:getChildByName("Text"):setString(g_tr("applyJoinAlliance"))
--                btnApply.data = item.data
--                
--                if not g_AllianceMode.getSelfHaveAlliance() then
--                  btnApply:addTouchEventListener(applyHandler)
--                  for key, var in pairs(playerGuildRequest) do
--                    if result.id == var.guild_id then
--                       playerGuildRequest[key] = nil
--                       btnApply:setEnabled(false)
--                       btnApply:getChildByName("Text"):setString(g_tr("applyed"))
--                       break
--                    end
--                  end
--                  
--                  if g_AllianceMode.getBaseData().id == result.id then
--      --                btnApply:setTouchEnabled(false)
--      --                btnApply:getChildByName("Text"):setString(g_tr("joined"))
--                      btnApply:setVisible(false)
--                      btnMail:setVisible(false)
--                  end
--               else
--                  btnApply:setVisible(false)
--                  if g_AllianceMode.getBaseData().leader_player_id == result.leader_player_id then
--                      btnMail:setVisible(false)
--                  end
--               end
--            end
            
            
            local createItem = function(resultData)
                local item = cc.CSLoader:createNode("alliance_search_list.csb")
                self:updateItem(item,resultData)
                self._listView:pushBackCustomItem(item)
                --dump(result)
                local btnMail = item:getChildByName("scale_node"):getChildByName("bg_info"):getChildByName("btn_mail")
                btnMail:getChildByName("Text"):setString(g_tr("btnMail"))
                
                btnMail.data = item.data
                btnMail:addClickEventListener(mailHandler)
                
                local btnApply = item:getChildByName("scale_node"):getChildByName("bg_info"):getChildByName("btn_apply")
                btnApply:getChildByName("Text"):setString(g_tr("applyJoinAlliance"))
                btnApply.data = item.data
                
                if not g_AllianceMode.getSelfHaveAlliance() then
                  btnApply:addTouchEventListener(applyHandler)
                  for key, var in pairs(playerGuildRequest) do
                    if resultData.id == var.guild_id then
                       playerGuildRequest[key] = nil
                       btnApply:setEnabled(false)
                       btnApply:getChildByName("Text"):setString(g_tr("applyed"))
                       break
                    end
                  end
                  
                  if g_AllianceMode.getBaseData().id == resultData.id then
      --                btnApply:setTouchEnabled(false)
      --                btnApply:getChildByName("Text"):setString(g_tr("joined"))
                      btnApply:setVisible(false)
                      btnMail:setVisible(false)
                  end
                else
                  btnApply:setVisible(false)
                  if g_AllianceMode.getBaseData().leader_player_id == resultData.leader_player_id then
                      btnMail:setVisible(false)
                  end
                end
            end
            
            local startIdx = 2
            local idx = 1
            for key, resultData in ipairs(resultList) do
                if key > startIdx then
                    break
                else
                    createItem(resultData)
                    idx = idx + 1
                end
            end
            
            local callback = function()
                print("create item async")
                createItem(resultList[idx])
                idx = idx + 1
                if idx > #resultList then
                    self:stopActionByTag(actionTag)
                end
            end
            
            if #resultList > startIdx then
                local sequence = cc.Sequence:create(cc.DelayTime:create(0.001), cc.CallFunc:create(callback))
                local action = cc.RepeatForever:create(sequence)
                action:setTag(actionTag)
                self:runAction(action)
            end
        
        end
        
        self:stopActionByTag(actionTag)
        if self._requestListDirty then
            g_busyTip.show_1()
            g_sgHttp.postData("data/index",{name = {"PlayerGuildRequest",}},resultHandler,true)
        else
            resultHandler(false)
        end
     end
end

function AllianceSearchLayer:updateItem(listItem,data)
    listItem.data = data
    
    local shortName = ""
    
    if data.short_name ~= "" then
      shortName = "("..data.short_name..")"
    end
    
    local countryName = ""
    if data.camp_id and tonumber(data.camp_id) > 0 then
			countryName = "["..g_tr(g_data.country_camp_list[tonumber(data.camp_id)].short_name).."]"
		end

    local baseNode = listItem:getChildByName("scale_node")
    
    baseNode:getChildByName("bg_info"):getChildByName("lable_1"):getChildByName("Text"):setString(g_tr("allianceName"))
    baseNode:getChildByName("bg_info"):getChildByName("lable_2"):getChildByName("Text"):setString(g_tr("allianceHost"))
    baseNode:getChildByName("bg_info"):getChildByName("lable_3"):getChildByName("Text"):setString(g_tr("allianceMembersMax"))
    --baseNode:getChildByName("bg_info"):getChildByName("lable_4"):getChildByName("Text"):setString(g_tr("alliancePower"))
    baseNode:getChildByName("bg_info"):getChildByName("lable_4"):getChildByName("Text"):setString("")--不显示战力
    baseNode:getChildByName("bg_info"):getChildByName("lable_5"):getChildByName("Text"):setString(g_tr("allianceCondition"))
    baseNode:getChildByName("bg_info"):getChildByName("lable_6"):getChildByName("Text"):setString(g_tr("needMakeSure"))
    baseNode:getChildByName("bg_info"):getChildByName("lable_5_0"):getChildByName("Text"):setString(g_tr("allianceAds"))
    
    baseNode:getChildByName("bg_info"):getChildByName("text_1")
    :setString(shortName..data.name..countryName)
    
    baseNode:getChildByName("bg_info"):getChildByName("text_2")
    :setString(data.leader_player_nick)
    
    baseNode:getChildByName("bg_info"):getChildByName("text_3")
    :setString(data.num.."")
    
    baseNode:getChildByName("bg_info"):getChildByName("text_3_1")
    :setString("/"..data.max_num)
    
    baseNode:getChildByName("bg_info"):getChildByName("text_4")
    :setString(string.formatnumberthousands(data.guild_power))
    
    baseNode:getChildByName("bg_info"):getChildByName("text_4")
    :setString("") --不显示战力
    
    baseNode:getChildByName("bg_info"):getChildByName("text_5")
    :setString(g_tr("allianceConditionLevel",{level = data.condition_fuya_level}))
    
    baseNode:getChildByName("bg_info"):getChildByName("text_7")
    :setString(g_tr("allianceConditionPlayer",{power = string.formatnumberthousands(data.condition_player_power)}))
    
    baseNode:getChildByName("bg_info"):getChildByName("text_7_0")
    :setString(data.desc.."")

    local str = g_tr("noNeed")
    if data.need_check > 0 then
        str = g_tr("need")
    end
    baseNode:getChildByName("bg_info"):getChildByName("text_6")
    :setString(str)
    
    local currentIcon = data.icon_id
    if currentIcon < g_Consts.AllianceIconDefaultId then
        currentIcon = g_Consts.AllianceIconDefaultId
    end
    local iconInfo = g_data.alliance_flag[currentIcon]
    baseNode:getChildByName("pic"):loadTexture(g_resManager.getResPath(iconInfo.res_flag))
    
end

return AllianceSearchLayer