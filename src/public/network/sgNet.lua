

--说明：
--[[
    registNotifyHandler() /unregistNotifyHandler()  ---针对服务器返回的 sgNet.notifyXXX通知
    registMsgCallback() / unregistMsgCallback()     ---消息注册与反注册
    unregistAllCallback(target)                     ---清楚指定对象所有注册的 notifyXXX 和 消息
    sendReq()       ---向服务器发送 sgNet.reqXXX 事件
    sendMessage()   ---向服务器发送消息
--]]


local sgNet = {}

--sgNetNotifyEnum of "NetCommon.h"
sgNet.notifyConnectingLoginServerFail = 200002
sgNet.notifyConnectedLoginServer      = 200003
sgNet.notifyConnectingGameServerFail  = 200004
sgNet.notifyConnectedGameServer       = 200005
sgNet.notifyDisconnected              = 200006
sgNet.notifyRecvMsg                   = 200007

--UserReqEnum of "NetCommon.h"
sgNet.reqConnectLoginServer           = 100002
sgNet.reqConnectGameServer            = 100003
sgNet.reqSendData                     = 100004
sgNet.reqDisconnect                   = 100005

sgNet.HeartBeatInterval               = 5.0
sgNet.MaxHeartBeatTimeoutCount        = 0
sgNet.MaxHeartBeatTimeout             = 10.0

sgNet.isConnected                     = false
sgNet.heartBeatTimeoutCount           = 0
sgNet.lastHeartBeatTime               = 0

sgNet.notifyHandler = {}
sgNet.msgCallback = {}

sgNet.isServerHeartBeatPause = false --记录服务器定时器检测是否暂停

function sgNet.setLoginServerAddr(ip,port)
  c_setup_login_server(ip, port)
end

function sgNet.setGameServerAddr(ip,port)
  c_setup_game_server(ip, port)
end

function sgNet.dumpCallback()
end 

function sgNet.onRecvMsgData(msgId, jsonData)
  if msgId then 
    local t = sgNet.msgCallback[msgId]
    if t then 
      for k, v in pairs(t) do 
        v.func(v.target, msgId, jsonData)
      end 
    end 
  end 
end 


--notify regist
function sgNet.registNotifyHandler(notify, target, handler)
  if sgNet.notifyHandler[notify] == nil then 
    sgNet.notifyHandler[notify] = {}
  end 

  table.insert(sgNet.notifyHandler[notify], {target = target, func = handler})
end

--msg regist
function sgNet.registMsgCallback(msgId,target,callback)
  if sgNet.msgCallback[msgId] == nil then 
    sgNet.msgCallback[msgId] = {}
  end 

  for k, v in pairs(sgNet.msgCallback[msgId]) do 
    if v.target == target and v.func == callback then 
      return 
    end 
  end 
  table.insert(sgNet.msgCallback[msgId], {target = target, func = callback})
end

function sgNet.unregistNotifyHandler(notify, target)
  local handler = sgNet.notifyHandler[notify]
  if handler then 
    for k, v in pairs(handler) do 
      if v.target == target then 
        handler[k] = nil 
      end
    end 
  end 
end 

function sgNet.unregistMsgCallback(msgId, target)
  local callback = sgNet.msgCallback[msgId]
  if callback then 
    for k, v in pairs(callback) do 
      if v.target == target then 
        callback[k] = nil 
      end
    end 
  end   
end 

function sgNet.unregistAllCallback(target)
  if target == nil then 
    print("unregistAllCallback Error : target is nill...")
    return 
  end 

  for i, hander in pairs(sgNet.notifyHandler) do 
    for k, v in pairs(hander) do 
      if v.target == target then 
        sgNet.notifyHandler[i][k] = nil 
      end
    end 
  end 

  for i, callback in pairs(sgNet.msgCallback) do 
    for k, v in pairs(callback) do 
      if v.target == target then 
        sgNet.msgCallback[i][k] = nil 
      end
    end 
  end 
end 

--default handlers
sgNet.registNotifyHandler(sgNet.notifyConnectingLoginServerFail, nil, sgNet.dumpCallback)
sgNet.registNotifyHandler(sgNet.notifyConnectedLoginServer, nil, sgNet.dumpCallback)
sgNet.registNotifyHandler(sgNet.notifyConnectingGameServerFail, nil, sgNet.dumpCallback)
sgNet.registNotifyHandler(sgNet.notifyConnectedGameServer, nil, sgNet.dumpCallback)
sgNet.registNotifyHandler(sgNet.notifyDisconnected, nil, sgNet.dumpCallback)
sgNet.registNotifyHandler(sgNet.notifyRecvMsg, nil, sgNet.onRecvMsgData)


function sgNet.pickNotify()
  if c_pick_notify ~= nil then
    local notify, msgId, jsonData = c_pick_notify()
    if notify ~= nil then

      if msgId ~= g_Consts.NetMsg.HeartBeatRsp then 
        print("pickNotify: notify, msgId", notify, msgId)
      end 

      --解析json数据
      -- dump(jsonData, "===jsonData")
      if jsonData and jsonData ~= "" then 
        jsonData = cjson.decode(jsonData)
      end 

      local handlers = sgNet.notifyHandler[notify]
      if handlers then 
        for k, v in pairs(handlers) do 
          if v.target then 
            v.func(v.target, msgId, jsonData)
          else 
            v.func(msgId, jsonData)
          end   
        end 
      end   
    end    
  else
    print("you should implement c function c_pick_notify()")
  end
end


function sgNet.sendReq(reqType, msgId, data)
  local jsonData
  if data then 
    jsonData = cjson.encode(data)
  end 
  c_send_req(reqType, msgId, jsonData)
end 

function sgNet.sendMessage(msgId,data)
  sgNet.sendReq(sgNet.reqSendData, msgId, data)
end


-----------------------------心跳包----------------------------
--超时无响应则断开连接
function sgNet.keepAlive()
  if sgNet.isConnected == true then 

    if sgNet.lastHeartBeatTime == 0 then
      sgNet.lastHeartBeatTime = os.time()
    end

    local isValid = true 
    local duration = os.time() - sgNet.lastHeartBeatTime
    if duration >= sgNet.MaxHeartBeatTimeout then -- timeout      
      sgNet.heartBeatTimeoutCount = sgNet.heartBeatTimeoutCount + 1

      if sgNet.heartBeatTimeoutCount > sgNet.MaxHeartBeatTimeoutCount then
        print("heart beat: send disconnect req")
        isValid = false 

        local scheduler = cc.Director:getInstance():getScheduler()
        if sgNet._heartBeatTimerId then 
          scheduler:unscheduleScriptEntry(sgNet._heartBeatTimerId) 
          sgNet._heartBeatTimerId = nil 
        end  

        sgNet.sendReq(sgNet.reqDisconnect) --sgNetManager will change to disconnecting state, then game server task break, and notify user
      end
    else
      sgNet.heartBeatTimeoutCount = 0
    end 

    --发送心跳包
    if isValid then 
      sgNet.sendHeartBeat() 
    end 
  end
end

--收到心跳包时的回调
function sgNet.onRecvHeartBeatRsp()
  -- print("onRecvHeartBeatRsp")
  --reset 
  sgNet.heartBeatTimeoutCount = 0
  sgNet.lastHeartBeatTime = 0
end


--发送心跳包消息, 可以在其他地方重载此方法.
function sgNet.sendHeartBeat()
  sgNet.sendMessage(g_Consts.NetMsg.HeartBeatReq, {id = g_PlayerMode.GetData().id })
end

--请求将服务端心跳包检测暂停
function sgNet.reqToPauseServerHearBeat(isReqToPause) 
  print("reqToPauseServerHearBeat: isConnected, isReqToPause", sgNet.isConnected, isReqToPause)
  if sgNet.isConnected then 
    local flag = isReqToPause and 1 or 0 
    sgNet.sendMessage(g_Consts.NetMsg.PauseServerHeartBeatReq, {is_pause = flag}) 
    sgNet.isServerHeartBeatPause = isReqToPause 
  end 
end 
---------------------------------------------------------------



function sgNet.loop()
  print("sgNet.loop")
  local scheduler = cc.Director:getInstance():getScheduler()
  if sgNet._loopTimerId then 
    scheduler:unscheduleScriptEntry(sgNet._loopTimerId) 
  end   
  sgNet._loopTimerId = scheduler:scheduleScriptFunc(sgNet.pickNotify, 0.5, false)
end 

function sgNet.connect()
  if sgNet.isConnected == false then
    -- sgNet.sendReq(sgNet.reqConnectLoginServer) 
    sgNet.sendReq(sgNet.reqConnectGameServer) 
  else
    print("already conected to game server.")
  end
end

function sgNet.disConnect()
  sgNet.pause()
  sgNet.sendReq(sgNet.reqDisconnect)
  sgNet.isConnected = false 
end 

function sgNet.startHeartBeat()
  print("startHeartBeat...")
  sgNet.heartBeatTimeoutCount = 0 
  sgNet.lastHeartBeatTime = 0

  local scheduler = cc.Director:getInstance():getScheduler()
  if sgNet._heartBeatTimerId then 
    scheduler:unscheduleScriptEntry(sgNet._heartBeatTimerId) 
  end 
  
  sgNet.keepAlive()
  sgNet._heartBeatTimerId = scheduler:scheduleScriptFunc(sgNet.keepAlive, sgNet.HeartBeatInterval, false)
  sgNet.registMsgCallback(g_Consts.NetMsg.HeartBeatRsp, sgNet, sgNet.onRecvHeartBeatRsp)
end 

function sgNet.pause()
  local scheduler = cc.Director:getInstance():getScheduler()
  if sgNet._loopTimerId then 
    scheduler:unscheduleScriptEntry(sgNet._loopTimerId) 
    sgNet._loopTimerId = nil 
  end 
  if sgNet._heartBeatTimerId then 
    scheduler:unscheduleScriptEntry(sgNet._heartBeatTimerId) 
    sgNet._heartBeatTimerId = nil 
  end  
end 

function sgNet.resume()
  sgNet.loop()
  sgNet.startHeartBeat()
end 

function sgNet.setConnectState(isConnected)
  sgNet.isConnected = isConnected 
end 

return sgNet
