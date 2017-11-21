local ActivityFirstPayBannerLayer = class("ActivityFirstPayBannerLayer",function()
	return cc.Layer:create()
end)

function ActivityFirstPayBannerLayer:ctor()
	local uilayer =  g_gameTools.LoadCocosUI("activity4_mian5.csb",5)
	self:addChild(uilayer)
	local baseNode = uilayer:getChildByName("scale_node")
	self._baseNode = baseNode
	
	local closeBtn = baseNode:getChildByName("Button_x")
	closeBtn:setTouchEnabled(true)
	closeBtn:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			self:removeFromParent()
		end
	end)
	
	self._baseNode:getChildByName("Text_1"):setString(g_tr("first_pay_endtime"))
	self._baseNode:getChildByName("Text_1_0"):setString("00:00:00")
	
	local dropGroups = g_gameTools.getDropGroupByDropIdArray(g_data.activity[2004].drop)
	local firstDropCon = self._baseNode:getChildByName("Panel_dw")
	print("dropGroups~~~~~~~~~~~~",#dropGroups)
	if #dropGroups > 0 then
		local firstDropItem = require("game.uilayer.common.DropItemView"):create(dropGroups[1][1],dropGroups[1][2],dropGroups[1][3])
		firstDropItem:enableTip()
		firstDropCon:addChild(firstDropItem)
		firstDropItem:setPosition(cc.p(firstDropCon:getContentSize().width/2,firstDropCon:getContentSize().height/2))
		
		local animPath = "anime/Effect_ShenJiangXiaFanUiXunHuan/Effect_ShenJiangXiaFanUiXunHuan.ExportJson"
		local armature , animation = nil,nil
		local function onMovementEventCallFunc(armature , eventType , name)
			if ccs.MovementEventType.complete == eventType then
			end
		end
	
		armature , animation = g_gameTools.LoadCocosAni(
		animPath
		, "Effect_ShenJiangXiaFanUiXunHuan"
		, onMovementEventCallFunc
		--, onFrameEventCallFunc
		)
		firstDropCon:addChild(armature)
		armature:setPosition(cc.p(firstDropCon:getContentSize().width/2,firstDropCon:getContentSize().height/2))
		animation:play("Animation1")
		
		local dropListView = self._baseNode:getChildByName("ListView_1")
		local step = 0
		local itemCon = nil
		for key, dropGroup in pairs(dropGroups) do
			if key > 1 then
				local isTop = step%2 == 0
				if isTop then
					itemCon = ccui.Widget:create()
					itemCon:setContentSize(cc.size(dropListView:getContentSize().height/2,dropListView:getContentSize().height))
					dropListView:pushBackCustomItem(itemCon)
				end
				local dropItem = require("game.uilayer.common.DropItemView"):create(dropGroup[1],dropGroup[2],dropGroup[3])
				dropItem:enableTip()
				itemCon:addChild(dropItem)
				dropItem:setScale(0.6)
				dropItem:setPositionX(itemCon:getContentSize().width/2)
				if isTop then
					dropItem:setPositionY(itemCon:getContentSize().height/2 + itemCon:getContentSize().height/2/2)
				else
					dropItem:setPositionY(itemCon:getContentSize().height/2/2)
				end
				step = step + 1
			end
		end
	end
	
	--前往充值按钮
	local btnGotoPay = self._baseNode:getChildByName("Button_1")
	btnGotoPay:getChildByName("Text_1"):setString(g_tr("first_pay_view"))
	btnGotoPay:addClickEventListener(function()
		require("game.uilayer.activity.ActivityMainLayer").show(2004)
		self:removeFromParent()
	end)
	
	local dayCnt =  tonumber(g_data.starting[101].data)
	local endTime = g_PlayerMode.GetData().create_time + 60*60*24*dayCnt
	
	local timeLabel = self._baseNode:getChildByName("Text_1_0")
  local updateTimeStr = function()
      local currentTime = g_clock.getCurServerTime()
      local secondsLeft = endTime - currentTime + 1
      if secondsLeft < 0 then
          secondsLeft = 0
          self:stopAllActions()
          timeLabel:setString("00:00:00")
          self:removeFromParent()
      else
          timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft))
      end
  end
  
  local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
  local action = cc.RepeatForever:create(seq)
  self:runAction(action)
  updateTimeStr()
	
end

return ActivityFirstPayBannerLayer