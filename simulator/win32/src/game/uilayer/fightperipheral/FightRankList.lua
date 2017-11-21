local FightRankList = class("FightRankList",function()
    return cc.Layer:create()
end)

local rankConfig = {}
for key, config in pairs(g_data.duel_rank) do
    rankConfig[config.rank] = config
end

table.sort(rankConfig,function(a,b)
    return a.rank > b.rank
end)


function FightRankList:ctor()
    local uiLayer =  g_gameTools.LoadCocosUI("ArenaRanking_popup.csb",5)
    self:addChild(uiLayer)
    --g_resourcesInterface.installResources(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
          end
    end)
    
    self._leftListView = baseNode:getChildByName("ListView_1")
    baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("peripheral_rank_title"))
    
    self._baseNode:getChildByName("Text_10"):setString("")

    self._leftMenus = {}
    for key, config in pairs(rankConfig) do
    	local menu = cc.CSLoader:createNode("ArenaRanking_list1.csb")
    	menu:getChildByName("Text_h2"):setString(g_tr(config.rank_name))
    	menu:getChildByName("Image_21"):loadTexture(g_resManager.getResPath(config.rank_pic))
    	
    	local tabHandler = function()
          self:changePage(key)
      end
    	menu:getChildByName("Button_h2"):addClickEventListener(tabHandler)
    	self._leftMenus[key] = menu
    	
    	self._leftListView:pushBackCustomItem(menu)
    end
    local function onRecv(result, msgData)
        g_busyTip.hide_1()
        if result == true then
            dump(msgData)
            self._rankListData = msgData
            local exditionData = g_expeditionData.GetData()
            local score = exditionData.score
            local rank = g_expeditionData.getRankByScore(score)
            local config = g_data.duel_rank[rank]
            local startIdx = config.rank
            
            local totalNum = table.nums(rankConfig)
            local leftIdx = 0
            for key, var in pairs(rankConfig) do
            	 leftIdx = leftIdx + 1
            	 if var.rank == startIdx then
            	     break
            	 end
            end

            if leftIdx > 6 then
                self._leftListView:refreshView() 
                self._leftListView:scrollToPercentVertical(leftIdx/totalNum*100,0.5,true)
            end
            
            self:changePage(leftIdx)
        else
            self:removeFromParent()
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("pk/pkRankList",{},onRecv,true)
end

function FightRankList:resetListView()
     if  self._listView then
          self._listView:removeFromParent()
     end
     
     local listViewOrginal =  self._baseNode:getChildByName("ListView_1_0")
     listViewOrginal:setVisible(false)
     self._listView = listViewOrginal:clone()
     self._listView:setVisible(true)
     listViewOrginal:getParent():addChild(self._listView)
     return self._listView
end

function FightRankList:changePage(idx)
   for key, menu in ipairs(self._leftMenus) do
   	   menu:getChildByName("Button_h2"):setEnabled(true)
   end
   
--    {
--        "id": 67,
--        "server_id": 1,
--        "player_id": 500152,
--        "nick": "qaz10",
--        "level": 31,
--        "avatar_id": 1,
--        "guild_name": "",
--        "guild_short_name": "",
--        "duel_rank": 5,
--        "score": 9753,
--        "general_data": [
--            {
--                "general_id": 20026,
--                "lv": 1,
--                "weapon_id": 1008800,
--                "armor_id": 0,
--                "horse_id": 3000200,
--                "zuoji_id": 0,
--                "hp": 99999,
--                "power": 88888
--            },
--            {
--                "general_id": 20008,
--                "lv": 1,
--                "weapon_id": 1007000,
--                "armor_id": 0,
--                "horse_id": 3000600,
--                "zuoji_id": 0,
--                "hp": 99999,
--                "power": 88888
--            },
--            {
--                "general_id": 20022,
--                "lv": 1,
--                "weapon_id": 1008400,
--                "armor_id": 2001000,
--                "horse_id": 3000100,
--                "zuoji_id": 0,
--                "hp": 99999,
--                "power": 88888
--            }
--        ],
--        "pos": 1,
--        "create_time": 1479687445
--    }

   self._listView = self:resetListView()
   self._leftMenus[idx]:getChildByName("Button_h2"):setEnabled(false)
   
   self._baseNode:getChildByName("Text_10"):setString("")
   
   local currentRankListData = self._rankListData[tostring(rankConfig[idx].rank)] or {}
   
   if table.nums(currentRankListData) == 0 then
      self._baseNode:getChildByName("Text_10"):setString(g_tr("peripheral_rank_empty"))
   end
   
   for key, var in pairs(currentRankListData) do
   	   local rankListItem = cc.CSLoader:createNode("ArenaRanking_list2.csb")
   	   rankListItem:getChildByName("Text_3"):setString("S"..var.server_id.." "..var.nick)
   	   
   	   for i=1, 3 do
   	   	  rankListItem:getChildByName("Image_shuz"..i):setVisible(false)
   	   end
   	   
   	   if rankListItem:getChildByName("Image_shuz"..key) then
   	      rankListItem:getChildByName("Image_shuz"..key):setVisible(true)
   	   end
   	   
   	   rankListItem:getChildByName("Text_shuzi1"):setString(key.."")
   	   
   	   local guildName = ""
   	   if var.guild_short_name and var.guild_short_name ~= "" then
   	      guildName = g_tr("peripheral_rank_txt1",{guild_name = var.guild_short_name})
   	   else
   	      local nickLabel = rankListItem:getChildByName("Text_3")
   	      nickLabel:setPositionY(nickLabel:getPositionY() - 20 )
   	   end
   	   rankListItem:getChildByName("Text_3_0"):setString(guildName)
   	   rankListItem:getChildByName("Text_4_0"):setString(string.formatnumberthousands(var.score))
   	   rankListItem:getChildByName("Text_4"):setString(g_tr("peripheral_rank_txt2"))
   	   
   	   local iconId = g_data.res_head[var.avatar_id].head_icon
       rankListItem:getChildByName("Image_2_0"):loadTexture(g_resManager.getResPath(iconId))
       rankListItem:getChildByName("Image_2"):loadTexture(g_resManager.getResPath(1010007)) --boader
       rankListItem:getChildByName("Text_dengji2"):setString("Lv"..var.level)
   	   
   	   for key, generalServerData in ipairs(var.general_data) do
   	      
   	      --武将头像
          local headContainer = rankListItem:getChildByName("Image_t"..key)
          headContainer:removeAllChildren()
          local size = headContainer:getContentSize()

          local generalConfigId = generalServerData.general_id*100 + 1
          local generalConfig = g_data.general[generalConfigId]
--          if generalConfig.general_quality == g_GeneralMode.godQuality then
--              item:getChildByName("Text_2"):enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,1),2)
--              item:getChildByName("Text_2"):setString("Lv"..generalServerData.lv)
--          end
          
          local headView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.General,generalConfigId,generalServerData.lv)
          headContainer:addChild(headView)
          --headView:setNameVisible(true)
          headView:setNameColor(cc.c3b(0, 0, 0))
          headView:setPosition(cc.p(size.width/2,size.height/2))
          local scale = size.width/headView:getContentSize().width
          headView:setScale(scale)
   	   end
   	   
   	   self._listView:pushBackCustomItem(rankListItem)
   end
   
end

return FightRankList