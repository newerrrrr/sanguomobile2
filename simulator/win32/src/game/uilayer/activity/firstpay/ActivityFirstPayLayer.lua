local ActivityFirstPayLayer = class("ActivityFirstPayLayer",function()
	return cc.Layer:create()
end)

function ActivityFirstPayLayer.isOpen()
	local isOpen = false
	
	local serverIdCondition = tonumber(g_data.starting[108].data)
	if g_Account.getCurrentAreaInfo().id < serverIdCondition then
		return isOpen
	end

	if tonumber(g_playerInfoData.GetData().newbie_pay) == 2 then --已完成
		return isOpen
	end

	local dayCnt =  tonumber(g_data.starting[101].data)
	local endTime = g_PlayerMode.GetData().create_time + 60*60*24*dayCnt
	local currentTime = g_clock.getCurServerTime()
	if currentTime < endTime then
		isOpen = true
	end

	return isOpen
end

function ActivityFirstPayLayer:ctor()
	local uilayer = cc.CSLoader:createNode("activity4_mian4.csb")
	self:addChild(uilayer)
	self._uilayer = uilayer
	uilayer:getChildByName("Text_1"):setString(g_tr("first_pay_endtime"))
	uilayer:getChildByName("Text_1_0"):setString("00:00:00")
	
    
	uilayer:getChildByName("Text_3"):setString("")
	
	local dropGroups = g_gameTools.getDropGroupByDropIdArray(g_data.activity[2004].drop)
	local firstDropCon = uilayer:getChildByName("Panel_dw")
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
		
		local dropListView = uilayer:getChildByName("ListView_1")
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
	local btnGotoPay = uilayer:getChildByName("Button_1")
	btnGotoPay:getChildByName("Text_1"):setString(g_tr("first_pay_pay_now"))
	btnGotoPay:addClickEventListener(function()
		g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyView").new())
	end)
	
	--领取按钮
	local btnGetReward = uilayer:getChildByName("Button_2")
	btnGetReward:getChildByName("Text_1"):setString(g_tr("commonAwardGet"))
	btnGetReward:addClickEventListener(function()
		local function onRecv(result, msgData)
			g_busyTip.hide_1()
			if result == true then
				 require("game.uilayer.task.AwardsToast").show(dropGroups)
				 self:updateView()
			end
		end
		g_busyTip.show_1()
		g_sgHttp.postData("activity/newbiePayReward",{},onRecv,true)
	end)
	
	self:registerScriptHandler(function(eventType)
			if eventType == "enter" then
				g_gameCommon.addEventHandler(g_Consts.CustomEvent.Pay, function()
					self:updateView()
				end, self)
				self:updateView()
			elseif eventType == "exit" then
				g_gameCommon.removeEventHandler(g_Consts.CustomEvent.Pay,self)
			end 
	end )
	
	local dayCnt =  tonumber(g_data.starting[101].data)
	local endTime = g_PlayerMode.GetData().create_time + 60*60*24*dayCnt
	
	local labelDesc = uilayer:getChildByName("Text_3")
	local timeLabel = uilayer:getChildByName("Text_1_0")
  local updateTimeStr = function()
      local currentTime = g_clock.getCurServerTime()
      local secondsLeft = endTime - currentTime + 1
      if secondsLeft < 0 then
          secondsLeft = 0
          self:stopAllActions()
          timeLabel:setString("00:00:00")
         	btnGotoPay:setVisible(false)
					btnGetReward:setVisible(false)
					labelDesc:setString(g_tr("first_pay_closed"))
      else
          timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft))
      end
  end
  
  local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
  local action = cc.RepeatForever:create(seq)
  self:runAction(action)
  updateTimeStr()
	
end		 

function ActivityFirstPayLayer:updateView()
	local status = tonumber(g_playerInfoData.GetData().newbie_pay)
	
	local uilayer = self._uilayer
	local btnGotoPay = uilayer:getChildByName("Button_1")
	local btnGetReward = uilayer:getChildByName("Button_2")
	local labelDesc = uilayer:getChildByName("Text_3")
	btnGotoPay:setVisible(false)
	btnGetReward:setVisible(false)
	labelDesc:setString("")
	
	print("~~~~~~~~~~~~~~~~~~~~~~~~~status:",status)
	if status == 0 then --未充值
		btnGotoPay:setVisible(true)
	elseif status == 1 then --已充值
		btnGetReward:setVisible(true)
	elseif status == 2 then --已领奖
		labelDesc:setString(g_tr("first_pay_completed"))
	end
end

return ActivityFirstPayLayer