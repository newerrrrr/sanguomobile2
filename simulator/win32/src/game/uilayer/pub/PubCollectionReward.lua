local PubCollectionReward = class("PubCollectionReward",function()
	return cc.Layer:create()
end)

local maxNums = table.nums(g_data.general_total_stars)
function PubCollectionReward:ctor()
  local uiLayer =  g_gameTools.LoadCocosUI("Pub_new_Panel_popup.csb",5)
	self:addChild(uiLayer)
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	
	self._inited = false
	
	local closeBtn = baseNode:getChildByName("close_btn")
	closeBtn:setTouchEnabled(true)
	closeBtn:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if self._inited then
				g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
				self:removeFromParent()
			end
		end
	end)
	
	self._baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("generalStarRewardTitle"))
	local getedAwardList = {}
	for key, var in pairs(g_playerInfoData.GetData().general_star_reward) do
		getedAwardList[tonumber(var)] = var
	end

	local listView = self._baseNode:getChildByName("ListView_1")
	
	local indexJump = 0
	
	
	local currentStar = 0
	
	local keyOwnGenerals = g_GeneralMode.getOwnedGenerals()
	for key, var in pairs(keyOwnGenerals) do
		currentStar = currentStar + math.floor(tonumber(var.star_lv)/5) + 1
	end
	
	local idx = 0
	local posed = false
	for key, var in pairs(g_data.general_total_stars) do
		idx = idx + 1
		local item = cc.CSLoader:createNode("Pub_new_Panel_list1.csb")
		item:getChildByName("Text_lj1"):setString(g_tr("generalStarReward"))
		item:getChildByName("Text_lj2"):setString(var.total_stars.."")
		item:getChildByName("Image_lq1"):setVisible(false)
		item:getChildByName("Image_lq2"):setVisible(false)
		
		local color = g_Consts.ColorType.Red
		if currentStar >= var.total_stars then
			color = g_Consts.ColorType.Green
		end
		item:getChildByName("Text_lj3"):setTextColor(color)
		item:getChildByName("Text_lj3"):setString(math.min(currentStar,var.total_stars).."/"..var.total_stars.."")
		
		local dropGroups = g_gameTools.getDropGroupByDropIdArray({var.drop_id})
		local awardlistView = item:getChildByName("ListView_1")
		local touchEnable = #dropGroups > 6
		awardlistView:setTouchEnabled(touchEnable)
		item:getChildByName("Image_j1"):setVisible(touchEnable)
		item:getChildByName("Image_j2"):setVisible(touchEnable)
	  for key, dropgroup in ipairs(dropGroups) do
      local itemView = require("game.uilayer.common.DropItemView"):create(dropgroup[1],dropgroup[2],dropgroup[3])
      itemView:enableTip()
      itemView:setScale(0.8)
      awardlistView:pushBackCustomItem(itemView)
	  end
	  
	  if getedAwardList[var.id] then --已经领取
	  	item:getChildByName("Button_1"):setEnabled(false)
	  	item:getChildByName("Button_1"):getChildByName("Text_6"):setString(g_tr("commonAwardGeted"))
	  else
	  	if posed == false then
	  		indexJump = idx
	  	end
	  	posed = true
	  	
	  	item:getChildByName("Button_1"):getChildByName("Text_6"):setString(g_tr("commonAwardGet"))
	  	if currentStar >= var.total_stars then
	  		item:getChildByName("Button_1"):setEnabled(true)
	  		item:getChildByName("Button_1"):addClickEventListener(function()
	  		 local function onRecv(result, msgData)
            g_busyTip.hide_1()
            if result == true then 
              item:getChildByName("Button_1"):setEnabled(false)
              item:getChildByName("Button_1"):getChildByName("Text_6"):setString(g_tr("commonAwardGeted"))
              require("game.uilayer.task.AwardsToast").show(dropGroups)
            end
          end
          g_busyTip.show_1()
          g_sgHttp.postData("Pub/starReward",{id = var.id},onRecv,true)
	  		end)
	  	else
	  		item:getChildByName("Button_1"):setEnabled(false)
	  	end
	  end
		listView:pushBackCustomItem(item)
	end
	
	if indexJump > 4 then
		g_autoCallback.addCocosList( function ()
			listView:scrollToPercentVertical(indexJump/maxNums*100,0.5,true)
			self._inited = true
		end,0.1)
	else
		self._inited = true
	end
	
end

return PubCollectionReward