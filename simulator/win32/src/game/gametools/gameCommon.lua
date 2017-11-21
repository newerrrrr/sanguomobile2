
local gameCommon = {}
setmetatable(gameCommon,{__index = _G})
setfenv(1,gameCommon)

local delayConnectTimer 

--1. 用户事件监听派发
local eventHandlers = {}
--注册事件回调
function addEventHandler(event, handler, target)
  print("event, handler", event, handler, target)
  if nil == eventHandlers[event] then 
    eventHandlers[event] = {}
  end 

  for k, v in pairs(eventHandlers[event]) do 
    if v.obj == target and v.func == handler then 
      return 
    end 
  end 

  table.insert(eventHandlers[event], {obj = target, func = handler})
end 

function dispatchEvent(event, data) 
  if nil == eventHandlers[event] then return end 

  for k, v in pairs(eventHandlers[event]) do 
    if v.func then 
      v.func(v.obj, data)
    end 
  end 
end 

function removeEventHandler(event, target) 
  if nil == eventHandlers[event] then return end 

  for k, v in pairs(eventHandlers[event]) do 
    if v.obj == target then 
      eventHandlers[event][k] = nil 
      break 
    end 
  end 
end 

--删除该目标所有监听器 
function removeAllEventHandlers(target) 
  for i, objFunc in pairs(eventHandlers) do 
    for k, v in pairs(objFunc) do 
      if v.obj == target then 
        eventHandlers[i][k] = nil 
      end
    end 
  end   
end 




--2. 建立与服务器的长连接通讯
function sgNetInit()

  local function onConnectedGameServer()
    print("=== start send login msg")
    local uuid, md5 = g_sgHttp.getUUID() 
    local player = g_PlayerMode.GetData()
    local id = player and player.id or nil 
    local campId = player and player.camp_id or nil 
    local md5 = id and PSDeviceInfo:getMD5String(id) or nil 
    g_sgNet.sendMessage(g_Consts.NetMsg.LoginReq, {uuid=uuid, player_id = id, hash_code = md5, camp_id = campId}) 
  end 

  local function onDisconnectedGameServer()
    print("onDisconnectedGameServer")
    g_sgNet.setConnectState(false) 

    --当前网络差, 通知用户
    dispatchEvent(g_Consts.CustomEvent.PoorNetWork, {is_poor = true}) 

    --断开自动重连
    local scheduler = cc.Director:getInstance():getScheduler()
    local function autoConnectServer()
      print("autoConnectServer")
      if delayConnectTimer then 
        scheduler:unscheduleScriptEntry(delayConnectTimer) 
        delayConnectTimer = nil 
      end     
      g_sgNet.connect() 
    end 
    
    if delayConnectTimer then 
      scheduler:unscheduleScriptEntry(delayConnectTimer) 
    end 
    delayConnectTimer = scheduler:scheduleScriptFunc(autoConnectServer, 5.0, false) 
  end 

  local function onLoginRsp(target, msgid, data)
    print("onLogin success ...")
    g_sgNet.setConnectState(true) 
    g_sgNet.startHeartBeat() 
    
    dispatchEvent(g_Consts.CustomEvent.PoorNetWork, {is_poor = false}) 

    --重连后更新邮件红点
    g_MailMode.updateNewMailTips()
  end 

  local function onRecvPushRsp(target, msgid, data)
    print("onRecvPushRsp: msgid", msgid)
    
    if nil == data then return end 
    
    dump(data)

    --派发事件
    if data.type == "mail" then 
      dispatchEvent(g_Consts.CustomEvent.NewMail, data)
    elseif g_chatData.isTypeOfChat(data.type) then 
      dispatchEvent(g_Consts.CustomEvent.Chat, data)
    elseif data.type == "guild_help" then 
      dispatchEvent(g_Consts.CustomEvent.Guild_Help, data)
    elseif data.type == "queue" then 
      dispatchEvent(g_Consts.CustomEvent.Queue, data)
    elseif data.type == "pay_callback" then 
      g_airBox.show(g_tr("priceSucess"))

      --appsflyer追踪支付事件
      local orderId = data.order_id
      local priceConfig = data.pricing
      local revenue = priceConfig.rmb_value
      local contentType = priceConfig.goods_type
      local contentId = priceConfig.id
      local currencyType = "CNY"
      local payWay = priceConfig.channel
      g_sdkManager.trackPurchaseEvent(revenue,contentType,contentId,currencyType,orderId,payWay)
      
      --任何充值类型都强制更新playerInfo
      g_playerInfoData.RequestData()
      
      
      if data.goods_type == "1" then
        --充值
        g_PlayerMode.RequestData()
        dispatchEvent(g_Consts.CustomEvent.Money, data)
        require("game.uilayer.mainSurface.mainSurfacePlayer").updateShowWithData_Res()
      elseif data.goods_type == "2" then
        dispatchEvent(g_Consts.CustomEvent.Money, data)
      elseif data.goods_type == "3" then
        dispatchEvent(g_Consts.CustomEvent.Money, data)
      elseif data.goods_type == "4" then
        --礼包
        g_moneyData.updateView()

        g_moneyData.NotificationUpdateShow()
        
        --同步一次装备数据
        g_EquipmentlMode.RequestSycData()

        g_BagMode.RequestSycData()

        g_MasterEquipMode.RequestSycData()
      end

      g_activityData.RequestNewbieActivityCharge()
      
      --更新充值活动和消耗活动的界面
      g_activityData.UpdateServerView()

      g_activityData.ShowEffect()
      
      dispatchEvent(g_Consts.CustomEvent.Pay, data)
    elseif data.type == "player_target" then
      dispatchEvent(g_Consts.CustomEvent.PlayerTarget, data)
    elseif data.type == "item" then
      dispatchEvent(g_Consts.CustomEvent.Item, data)
    elseif data.type == "attacked" then
      dispatchEvent(g_Consts.CustomEvent.Attacked, data)
    elseif data.type == "cancelattacked" or data.type == "finishattacked" then
      dispatchEvent(g_Consts.CustomEvent.CloseTower, data)
    elseif data.type == "kingpoint" then
      dispatchEvent(g_Consts.CustomEvent.KingPoint, data)
    elseif data.type == "round_message" then
      dispatchEvent(g_Consts.CustomEvent.MerryGoRound, data)
    elseif data.type == "invite_guild" then
      dispatchEvent(g_Consts.CustomEvent.GuildInvite, data)    
    elseif data.type == "guild_accept" then
      dispatchEvent(g_Consts.CustomEvent.GuildAccept, data)    
    elseif data.type == "guild_science" then
      dispatchEvent(g_Consts.CustomEvent.GuildScience, data)
    elseif data.type == "gather" then
      require("game.uilayer.mainSurface.mainSurfaceMenu").showGatherIcon(data)
      g_battleHallData.RequestData()
    elseif data.type == "appoint_king" then
        require("game.uilayer.kingWar.kingNoticeLayer").createLayer(data)

        --dispatchEvent(g_Consts.CustomEvent.KingAppoint, data)
        --print("aksdhjhahsdjkhasdjkhajkdhjkalsdhkjlashdljkashdjlkahsdjk")
        --dump(data)
    elseif data.type == "apply_guild" then
        dispatchEvent(g_Consts.CustomEvent.GuildApply, data)
    elseif data.type == "guild_help_add" then
      g_PlayerHelpMode.RequestSycData()
    elseif data.type == "send_army" then
      g_PlayerHelpMode.RequestHelpPlayerSycData()
    elseif data.type == "city_attacked" then
      g_SoldierMode.RequestSycData()
    elseif data.type == "cross_pk_result" then
      dispatchEvent(g_Consts.CustomEvent.PkRecive, data)
    elseif data.type == "cross" then
    	dispatchEvent(g_Consts.CustomEvent.GuildWarMapEvent, data)
    elseif data.type == "citybattle" then
    	dispatchEvent(g_Consts.CustomEvent.CityBattleMapEvent, data)
    end 
    
  end 

  --连接 net 服务器 
  if nil == gameCommon.isNetInited then 
    g_sgNet.loop()
  end 


  local addr = string.gsub(g_Account.getNetHost(), "http://", "") --去掉http://
  local pos = string.find(addr, ":", 6)
  if pos then 
    local host = string.sub(addr, 1, pos-1)
    local port = tonumber(string.sub(addr, pos+1))
    print("sgNetInit, host, port", host, port)

    g_sgNet.setGameServerAddr(host, port)
    g_sgNet.connect()
    g_sgNet.registNotifyHandler(g_sgNet.notifyConnectedGameServer, gameCommon, onConnectedGameServer)
    g_sgNet.registNotifyHandler(g_sgNet.notifyDisconnected, gameCommon, onDisconnectedGameServer)
    g_sgNet.registNotifyHandler(g_sgNet.notifyConnectingGameServerFail, gameCommon, onDisconnectedGameServer)

    g_sgNet.registMsgCallback(g_Consts.NetMsg.LoginRsp, gameCommon, onLoginRsp)
    g_sgNet.registMsgCallback(g_Consts.NetMsg.ServerPushRsp, gameCommon, onRecvPushRsp) 
  end 
end 

--断开长连接
function sgNetDeinit()
  g_sgNet.disConnect()
end 



return gameCommon 
