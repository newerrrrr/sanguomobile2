local Account = {}
setmetatable(Account,{__index = _G})
setfenv(1,Account)

local token = nil
local platformUid = nil
local userPlatformAccount = nil
local userConfig = nil
local loginLayer = nil
local accountManagerLayer = nil
local channelStr = g_sdkManager.SdkLoginChannel.dsuc
local downloadChannel = "googleplay"
local payChannel = "googleplay"
local loginHashCode = ""
local loginUserCode = "" --仅用于联盟号登陆模式的参数

local currentServerHost = nil --服务器地址
local currentNetHost = nil --长连接服务器地址
local accountHistoryServerList = nil
local currentAreaInfo = nil --服务器信息

local lastSendPasscodeTimeArr = {}

vcodeCaches = {}
isTestUser = 0

countryCodes = require("localization.langConfig").getCountryCodeList()

function getHistoryServerList()
	return accountHistoryServerList
end

function setHistoryServerList(his)
	accountHistoryServerList = his
end

function setLastPasscodeTime(phoneNum,time)
	lastSendPasscodeTimeArr[tostring(phoneNum)] = time
end

function getLastPasscodeTime(phoneNum)
	return lastSendPasscodeTimeArr[tostring(phoneNum)] or 0
end

function getNextPasscodeTime(phoneNum)
	local lastSendPasscodeTime = getLastPasscodeTime(phoneNum)
	return lastSendPasscodeTime + 60
end

function setLoginUserCode(userCode)
	loginUserCode = userCode
end

--只用于联盟号登陆模式（内部测试用）
function getLoginUserCode()
	return loginUserCode
end

--用于用户手动切换选区时，本地记录的key
function getTargetAreaTag()
	return "target_area_"..getUserPlatformUid().."_"..getChannel()
end

function setCurrentAreaInfo(info)
	currentAreaInfo = info
end

function getCurrentAreaInfo()
	return currentAreaInfo
end

function setServerHost(host)
	currentServerHost = host
end

function getServerHost()
	return currentServerHost
end

function setNetHost(host)
	currentNetHost = host
end

function getNetHost()
	return currentNetHost
end

local filePath = cc.FileUtils:getInstance():getWritablePath().."user_account"
--初始化 读取本地账号记录
function init()
  local configFile = require("game.gametools.saveTools").getStringFromFile(filePath)
  if configFile then
	  configFile = cTools_simple_decrypt(configFile)
	  userConfig = cjson.decode(configFile)
	  if userConfig.lastLoginAccount == nil then
		  userConfig.lastLoginAccount = {}
	  end
  else
	  userConfig = {}
	  
	  userConfig.accountList = {}
	  userConfig.lastLoginAccount = {}
	  
	  saveToFile()
  end
  
  setUserPlatformUid(userConfig.lastLoginAccount.uid)
  setUserPlatformAccount(userConfig.lastLoginAccount.user_account)
  
  --读取downloadChannel信息
  local client_params_path = "client_params.json"
  if cc.FileUtils:getInstance():isFileExist(client_params_path) then
	 local configFileStr = cc.FileUtils:getInstance():getStringFromFile(client_params_path)
	 local clientParamsConfig = cjson.decode(configFileStr)
	 if clientParamsConfig then
		if clientParamsConfig.download_channel then
			downloadChannel = clientParamsConfig.download_channel
			payChannel = downloadChannel
		end
		
		--已废弃
--		
--		if clientParamsConfig and clientParamsConfig.pay_channel then
--			payChannel = clientParamsConfig.pay_channel
--	 	end
	 
	 end
  end
  
end

function getUserConfig()
  return userConfig
end

function networkError(performCode, responseCode)
  g_msgBox.showNetError(performCode, responseCode)
end

function reset()
  setToken(nil)
  setUserPlatformUid(nil)
  setUserPlatformAccount(nil)
  userConfig.lastLoginAccount = {}
end

function saveToFile()

  local str = cjson.encode(userConfig)
  
  str = cTools_simple_encrypt(str)
  
  require("game.gametools.saveTools").saveStringToFile(filePath,str)
  
--  local configFile = assert( io.open( filePath.."account_config.json","w+" ) )

--  configFile:write(cjson.encode(userConfig))
--  configFile:close()
  
end

function updateLastUser(user_info)
  userConfig.lastLoginAccount = clone(user_info)
  local uid = nil
  local user_account = nil
  if user_info then
	  uid = user_info.uid
	  user_account = user_info.user_account
  end
  setUserPlatformUid(uid)
  setUserPlatformAccount(user_account)
end

function saveUserInfo(user_info)
--	local userTable
--	if userConfig.accountList[user_info.uid] == nil then
--		userConfig.accountList[user_info.uid] = {}
--	end
--	userTable = userConfig.accountList[user_info.uid]
--	userTable.uid = user_info.uid
--	userTable.user_account = user_info.user_account
--	userTable.password = user_info.password
	
	userConfig.accountList[user_info.uid] = clone(user_info)
end

function removeUserInfo(uid)
	userConfig.accountList[uid] = nil
end

function logout()
	 reset()
	 sdkLogout()
	 saveToFile()
end


function sdkLogout()
	loginUserCode = ""
	channelStr = g_sdkManager.SdkLoginChannel.dsuc
	setUserPlatformUid("")
	g_sdkManager.logout()
--	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
--		local luaj = require "cocos.cocos2d.luaj"
--		local className="com/m543/pay/FastSdk"
--		local params = {false}
--		luaj.callStaticMethod(className, "setLogin", params)
--	end
end

--获取当前账号每个服务器角色列表
--请求当前账号登陆过的服务器和角色信息
function requestPlayerServerList(gameServerUuid,callBack)
	local function onRecv(result, msgData)
		g_busyTip.hide_1()
		if result then
			print(msgData)
			accountHistoryServerList = cjson.decode(msgData)
		else
			--g_msgBox.show(g_tr("getServerListFail"), title, ctp, requestServerList, utp, {["0"] = g_tr("retryGetServerList")})
		end
		
		if callBack then
			callBack(result, msgData)
		end
		
	end
   
	local url = "/login_server/getPlayerServerList"
	local uuid = gameServerUuid
	local para = string.format('uuid=%s',uuid)
	if g_logicDebug then
		print("发送：",url,para)
	end
	g_busyTip.show_1()
	httpNet:getInstance():Post(g_configHost..url,para,string.len(para),onRecv,10,10,true,false)
end

function doVerfityUid(channel,callback)
	local resultHandler = function(result,dataTable)
		--{"status":"success","uid":1234,”message”:”获得用户信息成功”,"channel":"dsuc"}
		if result then
			if dataTable.status == "success" then
				 setUserPlatformUid(dataTable.uid)
				 setChannel(dataTable.channel)
			end
	   end
	   
	   if callback then
		   callback(result,dataTable)
	   end
	end

	print("channel:"..channel)
	
	g_sdkManager.login(channel,function(uid,token,channel)
		verifyUserUidByToken(uid,token,channel,resultHandler)
	end)
	
--	local luaj = require "cocos.cocos2d.luaj"
--	local className="com/m543/pay/FastSdk"
--	
--	local params = {channel}
--	local arg="(Ljava/lang/String;)V"
--	luaj.callStaticMethod(className, "setLoginChannel", params, arg)
--	
--	local loginResult = function(s)
--		--print("s~~~~~~~~~~~~~~~~:",s)
--		--g_airBox.show(s)
--		--dump(string.split(s, ","))
--		local params = string.split(s, ",")
--		--dump(params)
--		--g_msgBox.show(params[1]..","..params[2]..","..params[3])
--		verifyUserUidByToken(params[1],params[2],params[3],resultHandler)
--	end
--	
--	local params = {
--		loginResult
--	}
--	luaj.callStaticMethod(className, "login", params)
end

--登录channel
function setChannel(channelName)
	channelStr = channelName
end

function getChannel()
	return channelStr
end

function getDownloadChannel()
	return downloadChannel
end

--已废弃，请用downloadChannel
function getPayChannel()
  return payChannel
end

function setLoginHashCode(hashCode)
	loginHashCode = hashCode
end

function getLoginHashCode()
	return loginHashCode
end

function setToken(userToken)
	token = userToken
end

--获取最近一次登录的token
function getToken()
	return token
end

function setUserPlatformUid(uid)
	platformUid = uid
end

--获取账号的Uid
function getUserPlatformUid()
	return platformUid or ""
end

function setUserPlatformAccount(userAccount)
	userPlatformAccount = userAccount
end

function setLoginLayer(layer)
	loginLayer = layer
end

function getLoginLayer()
	return loginLayer
end

function setAccountManagerLayer(layer)
	accountManagerLayer = layer
end

function getAccountManagerLayer()
	return accountManagerLayer
end

--获取账号名称
function getUserPlatformAccount()
	return userPlatformAccount
end

--function isRightUserName(str)
--  local isRightUserName = false
--  if isRightEmail(str) == false then
--	return isRightTel(str)
--  else
--	return true
--  end
--end

--注册平台账号
function userPlatformRegist(userName,password,callback)
	
	userName = tostring(userName)
	userName = string.trim(userName)

	local function onResult(result, data, performCode, responseCode)
		g_busyTip.hide_1()
		if result == false or data == nil or data == "" then
		  print("network error")
		  networkError(performCode, responseCode)
		  if callback then
			callback(false, nil)
		  end
		else
		   print(data)
		   local dataTable = cjson.decode(data)
		   --{"status":"success","user_token":"cd67dfe35f0b9c7fa6c3f7d6f8bcd9bd9f252242","user_account":"testyyy11122233@126.com"}
		   if dataTable.status == "success" then
			  setUserPlatformAccount(dataTable.user_account)
			  setToken(dataTable.user_token)
			  userPlatformVerify(dataTable.user_token,password,callback)
		   else	 
			   if callback then
				  callback(true, dataTable)
			   end
		   end

		end
	end
	
	local user_account = tostring(userName)
	local encryptPassword = cToolsForLua:encode(tostring(password),g_userPlatformPasswordKey)
	local source = g_userPlatformSource
	local timestamp = tostring(g_clock.getCurServerTime())
	
	--Sha1(md5(username+password+source+timestamp+key))
	local skey = userName..encryptPassword..g_userPlatformSource..timestamp..g_userPlatformSignKey
	skey = cToolsForLua:sha1(skey)
	
	--http://[域名]/auth/register/?user_account=xxxxxx&password=111111&source=dhh&timestamp=xxxxxx&skey=fe4fe4a6f4a4f6e4fa64e6
	local url = "user_account="..user_account.."&password="..encryptPassword.."&source="..source.."&timestamp="..timestamp.."&skey="..skey
	local data = ""
	g_busyTip.show_1()
	httpNet:getInstance():Post(g_userPlatformHost.."/auth/register/?"..url,data,string.len(data),onResult,10,10,true,false)
   
end

--快速注册
function userPlatformRegisterQuick(callback)
	local function onResult(result, data, performCode, responseCode)
		g_busyTip.hide_1()
		if result == false or data == nil or data == "" then
		  print("network error")
		  networkError(performCode, responseCode)
		  if callback then
			callback(false, nil)
		  end
		else
		   print(data)
		   local dataTable = cjson.decode(data)
		   --{"status":"success","user_token":"cd67dfe35f0b9c7fa6c3f7d6f8bcd9bd9f252242","user_account":"testyyy11122233@126.com","password":"xxxxxxx"}
		   if dataTable.status == "success" then
			  setUserPlatformAccount(dataTable.user_account)
			  setToken(dataTable.user_token)
			  userPlatformVerify(dataTable.user_token,dataTable.password,callback)
		   else
			  if callback then
				  callback(true, dataTable)
			  end
		   end
		end
	end
	
	local source = g_userPlatformSource
	local timestamp = tostring(g_clock.getCurServerTime())
	
	--Sha1(md5(username+password+source+timestamp+key))
	local skey = g_userPlatformSource..timestamp..g_userPlatformSignKey
	skey = cToolsForLua:sha1(skey)
	
	--http://[域名]/auth/registerQuick/?source=dhh&timestamp=xxxxxx&skey=fe4fe4a6f4a4f6e4fa64e6
	local url = "source="..source.."&timestamp="..timestamp.."&skey="..skey
	local data = ""
	g_busyTip.show_1()
	httpNet:getInstance():Post(g_userPlatformHost.."/auth/registerQuick/?"..url,data,string.len(data),onResult,10,10,true,false)
end

--绑定平台账号
function userPlatformBind(userName,password,userNameNew,passwordNew,callback)
	 
	 print("bind:",userName,password,userNameNew,passwordNew)
	 
	 userName = tostring(userName)
	 userName = string.trim(userName)
	 
	 userNameNew = tostring(userNameNew)
	 userNameNew = string.trim(userNameNew)
	 
	 local function onResult(result, data, performCode, responseCode)
		 g_busyTip.hide_1()
		if result == false or data == nil or data == "" then
		  print("network error")
		  networkError(performCode, responseCode)
		  if callback then
			callback(false, nil)
		  end
		else
		   print(data)
		   local dataTable = cjson.decode(data)
		   if dataTable.status == "success" then
			  setUserPlatformAccount(dataTable.user_account)
			  
			  if userConfig.lastLoginAccount.user_account == userName then
				  userConfig.lastLoginAccount.user_account = userNameNew
				  userConfig.lastLoginAccount.password = passwordNew
			  end
			  
			  local userInfo = nil
			  for key, var in pairs(userConfig.accountList) do
				  if var.user_account == userName then
					  userInfo = var
					  break
				  end
			  end
			  
			  if userInfo then
				userInfo.user_account = userNameNew
				userInfo.password = passwordNew
				saveToFile()
			  end
	 
		   end
			   
		   if callback then
			  callback(true, dataTable)
		   end
		end
	end
	
	local user_account = tostring(userName)
	local encryptPassword = cToolsForLua:encode(tostring(password),g_userPlatformPasswordKey)
	
	local user_account_new = tostring(userNameNew)
	local encryptPasswordNew = cToolsForLua:encode(tostring(passwordNew),g_userPlatformPasswordKey)
	
	local source = g_userPlatformSource
	local timestamp = tostring(g_clock.getCurServerTime())
	
	--Sha1(md5(username+password+source+timestamp+key))
	local skey = userName..encryptPassword..user_account_new..encryptPasswordNew..g_userPlatformSource..timestamp..g_userPlatformSignKey
	skey = cToolsForLua:sha1(skey)
	
	 --http://[域名]/auth/bindEmail/?user_account=xxxxxx&password=111111& user_account_new=xxxxxx&password_new=222222&source=dhh&timestamp=xxxxxx&skey=fe4fe4a6f4a4f6e4fa64e6
	local url = "user_account="..user_account.."&password="..encryptPassword.."&user_account_new="..user_account_new.."&password_new="..encryptPasswordNew.."&source="..source.."&timestamp="..timestamp.."&skey="..skey
	local data = ""
	g_busyTip.show_1()
	httpNet:getInstance():Post(g_userPlatformHost.."/auth/bindEmail/?"..url,data,string.len(data),onResult,10,10,true,false)
end

--平台账号登录
function userPlatformLogin(userName,password,callback)
	--http://[域名]/auth/login/?user_account=xxxxxx&password=111111&source=dhh&timestamp=xxxxxx&skey=fe4fe4a6f4a4f6e4fa64e6
	
	userName = tostring(userName)
	userName = string.trim(userName)
	
	local user_account = tostring(userName)
	local encryptPassword = cToolsForLua:encode(tostring(password),g_userPlatformPasswordKey)
	local source = g_userPlatformSource
	local timestamp = tostring(g_clock.getCurServerTime())
	
	
	--Sha1(md5(username+password+source+timestamp+key))
	local skey = userName..encryptPassword..g_userPlatformSource..timestamp..g_userPlatformSignKey
	skey = cToolsForLua:sha1(skey)
	
	local function onResult(result, data, performCode, responseCode)
		g_busyTip.hide_1()
		if result == false or data == nil or data == "" then
		  print("network error")
		  networkError(performCode, responseCode)
		  if callback then
			callback(false, nil)
		  end
		else
		  print("userPlatformLogin:",result,data)
		  local dataTable = cjson.decode( data )
		  --{"status":"success","user_token":"cd67dfe35f0b9c7fa6c3f7d6f8bcd9bd9f252242","user_account":"testyyy11122233@126.com"}
		  if dataTable.status == "success" then
			  setToken(dataTable.user_token)
			  setUserPlatformAccount(dataTable.user_account)
			  userPlatformVerify(dataTable.user_token,password,callback)
		  else
			  if callback then
				 callback(true, dataTable)
			  end
		  end
		end
	end
	
	local url = "user_account="..user_account.."&password="..encryptPassword.."&source="..source.."&timestamp="..timestamp.."&skey="..skey
	local data = ""
	g_busyTip.show_1()
	httpNet:getInstance():Post(g_userPlatformHost.."/auth/login/?"..url,data,string.len(data),onResult,10,10,true,false)
end

--根据token获取uid(游戏服务器调用平台接口验证)
function verifyUserUidByToken(uid,userToken,channel,callback)
	local onResult = function(result, data, performCode, responseCode)
		--关掉菊花
	   g_busyTip.hide_1()
	   sdkLogout()
	   
	   if result == false or data == nil or data == "" then
		  print("network error")
		  
		  networkError(performCode, responseCode)
		  if callback then
			callback(false, nil)
		  end
		  
		else
		  print("verifyUserUidByToken:",result,data)
		  local resultTable = cjson.decode( data )
		  
		  --{returnMsg ={"status":"success","uid":1234,”message”:”获得用户信息成功”,"channel":"dsuc"},}
		  
		  
		  local dataTable = resultTable.returnMsg or {}
		  --{"status":"success","uid":1234,”message”:”获得用户信息成功”,"channel":"dsuc"}
		 
		  if dataTable.status == "success" then
			  setToken(dataTable.user_token)
			  
			  local loginLayer = getLoginLayer()
			  if loginLayer then
				  loginLayer.lua_playTitleAnimation()
				  local isLogin = true
				  loginLayer:changeBtnStatus(isLogin)
			  end

			  --登陆服务器验证成功后，获取历史登陆
--			  local gameUuid = dataTable.uid.."_"..dataTable.channel
--			  requestPlayerServerList(gameUuid,function(result,msgData)
--					if result then
--						if loginLayer then
--							loginLayer:useDefaultAreaId()
--							loginLayer:showMaintainNoticeAfterLogin()
--						end
--					end
--			  end)

			  --历史登陆信息
			  accountHistoryServerList = resultTable.PlayerServerList
			  if loginLayer then
				  loginLayer:useDefaultAreaId()
				  loginLayer:showMaintainNoticeAfterLogin()
			  end
			  
		  end
		  
		  if callback then
			  callback(true, dataTable)
		  end
		end
	end
	
	--打开菊花
	g_busyTip.show_1()

	local jsonTbl = {}
	--{"uid":"xxx","sessionId":"xxx","channel":"xxx"}
	jsonTbl.uid = uid
	jsonTbl.sessionId = userToken
	jsonTbl.channel = channel
	
	if channel == g_sdkManager.SdkLoginChannel.huawei then
		jsonTbl.channel_extern_data=7.2
	end
	
	local url = "/login_server/login"
	local data = jsonTbl and "json="..cjson.encode(jsonTbl) or ""
	if g_logicDebug then
		print("发送：",url,data)
	end
	httpNet:getInstance():Post(g_configHost..url,data,string.len(data),onResult,30,30,true,false)
end


--大事平台用户信息获取
function userPlatformVerify(userToken,password,callback)
	
	local resultHandler = function(result,dataTable)
		if not result then
			callback(false,"userPlatformVerifyError")
		else
			if dataTable.status == "success" then
				--大事验证成功
				
				 --更新默认账号
				 local userInfo = {}
				 userInfo.password = password
				 setUserPlatformUid(dataTable.uid)
				 setChannel(dataTable.channel)
				 userInfo.user_account = getUserPlatformAccount()
				 userInfo.uid = dataTable.uid
				 updateLastUser(userInfo)
				 saveUserInfo(userInfo)
				 saveToFile()

				--dump(dataTable)
				--dump(userConfig.accountList)
			   
			else
				  
			end
			
			callback(true,dataTable)
		end
	end
	
	verifyUserUidByToken(userToken,userToken,g_sdkManager.SdkLoginChannel.dsuc,resultHandler)
	
	--[[
	--http://[域名]/auth/verify/?user_token=18b7b25dddde7fd142f8c042ddd79c8c7f298095
	
	local function onResult(result, data, performCode, responseCode)
		if result == false or data == nil or data == "" then
		  print("network error")
		  networkError(performCode, responseCode)
		else
		  print("userPlatformVerify:",data)
		  local dataTable = cjson.decode( data )
		  --{"status":"success","user_info":{"uid":4,"user_account":"xxxxxx"}}
		  if dataTable.status == "success" then
			  dataTable.user_info.password = password
			  setUserPlatformUid(dataTable.user_info.uid)
			  setUserPlatformAccount(dataTable.user_info.user_account)
			  updateLastUser(dataTable.user_info)
			  saveUserInfo(dataTable.user_info)
			  saveToFile()
		  end
		end
	end
	
	local url = "user_token="..userToken
	local data = ""
	httpNet:getInstance():Post(g_userPlatformHost.."/auth/verify/?"..url,data,string.len(data),onResult,10,10,false,false)
	]]
end

--获取手机验证码
function userPlatformMobileGetVerification(mobileNumber,countryCode,callback)
	 
	 mobileNumber = tostring(mobileNumber)
	 mobileNumber = string.trim(mobileNumber)

	 local function onResult(result, data, performCode, responseCode)
		g_busyTip.hide_1()
		if result == false or data == nil or data == "" then
		  print("network error")
		  networkError(performCode, responseCode)
		  if callback then
			callback(false, nil)
		  end
		else
		   print(data)
		   local dataTable = cjson.decode(data)
		   if dataTable.status == "success" then
			  setLastPasscodeTime(mobileNumber,g_clock.getCurServerTime())
		   end
			   
		   if callback then
			  callback(true, dataTable)
		   end
		end
	end
	
	local user_account = tostring(mobileNumber)
	local source = g_userPlatformSource
	local timestamp = tostring(g_clock.getCurServerTime())
	--Sha1(md5(username+source+timestamp+key))
	local skey = user_account..countryCode..g_userPlatformSource..timestamp..g_userPlatformSignKey
	skey = cToolsForLua:sha1(skey)
	
	--http://[域名]/mobileauth/getVerification?user_account=xxxxxx& source=dhh&timestamp=xxxxxx&skey=fe4fe4a6f4a4f6e4fa64e6
	local url = "user_account="..user_account.."&country_code="..countryCode.."&source="..source.."&timestamp="..timestamp.."&skey="..skey
	print(url)
	local data = ""
	g_busyTip.show_1()
	httpNet:getInstance():Post(g_userPlatformHost.."/mobileauth/getVerification/?"..url,data,string.len(data),onResult,10,10,true,false)
	
end

--验证手机验证码
function userPlatformMobileVerify(mobileNumber,countryCode,passwordCode,callback)
	
	mobileNumber = tostring(mobileNumber)
	mobileNumber = string.trim(mobileNumber)
	
	passwordCode = tostring(passwordCode)
	passwordCode = string.trim(passwordCode)
	
	local function onResult(result, data, performCode, responseCode)
		g_busyTip.hide_1()
		if result == false or data == nil or data == "" then
		  print("network error")
		  networkError(performCode, responseCode)
		  if callback then
			callback(false, nil)
		  end
		else
		   print(data)
		   local dataTable = cjson.decode(data)
--		   if dataTable.status == "success" then
--	 
--		   end
			   
		   if callback then
			  callback(true, dataTable)
		   end
		end
	end
	
	local user_account = tostring(mobileNumber)
	local password_code = tostring(passwordCode)
	local source = g_userPlatformSource
	local timestamp = tostring(g_clock.getCurServerTime())
	--Sha1(md5(username+ password_code +source+timestamp+key))
	local skey = user_account..countryCode..password_code..g_userPlatformSource..timestamp..g_userPlatformSignKey
	skey = cToolsForLua:sha1(skey)
	
	--http://[域名]/mobileauth/verify?user_account=xxxxxx& password_code =xxxx&source=dhh&timestamp=xxxxxx&skey=fe4fe4a6f4a4f6e4fa64e6
	local url = "user_account="..user_account.."&country_code="..countryCode.."&password_code="..password_code.."&source="..source.."&timestamp="..timestamp.."&skey="..skey
	local data = ""
	g_busyTip.show_1()
	httpNet:getInstance():Post(g_userPlatformHost.."/mobileauth/verify/?"..url,data,string.len(data),onResult,10,10,true,false)

end

--绑定手机号
function userPlatformMobileBind(userName,password,countryCode,userNameNew,passwordNew,callback)
	 print("bindMobile:",userName,password,countryCode,userNameNew,passwordNew)
	 
	 userName = tostring(userName)
	 userName = string.trim(userName)
	
	 local function onResult(result, data, performCode, responseCode)
		g_busyTip.hide_1()
		if result == false or data == nil or data == "" then
		  print("network error")
		  networkError(performCode, responseCode)
		  if callback then
			  callback(false, nil)
		  end
		else
		   print(data)
		   local dataTable = cjson.decode(data)
		   if dataTable.status == "success" then
			  setUserPlatformAccount(userNameNew)
			  
			  if userConfig.lastLoginAccount.user_account == userName then
				  userConfig.lastLoginAccount.user_account = userNameNew
				  userConfig.lastLoginAccount.password = passwordNew
			  end
		
			  local userInfo = nil
			  for key, var in pairs(userConfig.accountList) do
				  if var.user_account == userName then
					  userInfo = var
					  break
				  end
			  end
			  
			  if userInfo then
				  userInfo.user_account = userNameNew
				  userInfo.password = passwordNew
				  saveToFile()
			  end
		   end
			   
		   if callback then
			  callback(true, dataTable)
		   end
		end
	end
	
	local user_account = tostring(userName)
	local encryptPassword = cToolsForLua:encode(tostring(password),g_userPlatformPasswordKey)
	
	local user_account_new = tostring(userNameNew)
	local encryptPasswordNew = cToolsForLua:encode(tostring(passwordNew),g_userPlatformPasswordKey)
	
	local source = g_userPlatformSource
	local timestamp = tostring(g_clock.getCurServerTime())
	
	--Sha1(md5(username+password+source+timestamp+key))
	local skey = userName..countryCode..encryptPassword..user_account_new..encryptPasswordNew..g_userPlatformSource..timestamp..g_userPlatformSignKey
	skey = cToolsForLua:sha1(skey)
	
	 --http://[域名]/auth/bindMobile/?user_account=xxxxxx&password=111111& user_account_new=xxxxxx&password_new=222222&source=dhh&timestamp=xxxxxx&skey=fe4fe4a6f4a4f6e4fa64e6
	local url = "user_account="..user_account.."&country_code="..countryCode.."&password="..encryptPassword.."&user_account_new="..user_account_new.."&password_new="..encryptPasswordNew.."&source="..source.."&timestamp="..timestamp.."&skey="..skey
	local data = ""
	g_busyTip.show_1()
	httpNet:getInstance():Post(g_userPlatformHost.."/mobileauth/bindMobile/?"..url,data,string.len(data),onResult,10,10,true,false)
end

function gameLogin(userName,password)
	--TODO:游戏登录
	
end

function isRightTel(str,countryCode)
  local numLong = 11
  if countryCode == 86 then
	  numLong = 11
  elseif countryCode == 886 then
	  numLong = 9
  elseif countryCode == 852 then
	  numLong = 8
  elseif countryCode == 853 then
	  numLong = 8
  end

  if string.len(str or "") ~= numLong then return false end
  local _,count = string.gsub(str, "%d", "")
  return count == numLong
end


function isRightPassword(str)
  local length = string.utf8len(str or "")
  return length >= 6 and length <= 15 
end

function isRightEmail(str)
	 if string.len(str or "") < 6 then return false end
	 local b,e = string.find(str or "", '@')
	 local bstr = ""
	 local estr = ""
	 if b then
		 bstr = string.sub(str, 1, b-1)
		 estr = string.sub(str, e+1, -1)
		 print("bstr:",bstr,"estr:",estr)
	 else
		 return false
	 end
 
	 -- check the string before '@'
	 if require("public.localization").language == "ja" then 
	   local p1,p2 = string.find(bstr, "[%S_]+")
	   print("p1:",p1,"p2:",p2,"bstrLength:",string.len(bstr))
	   if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
	 else
	   local p1,p2 = string.find(bstr, "[%w_]+")
	   local point,point1 = string.find(bstr, "%.")
		
	   if point == 1 then
		  if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
	   else
		  if (p1 ~= 1)  then return false end
		  local p_str,p_count = string.gsub(bstr, "%.", "")
		  local p_1,p_2 = string.find(p_str, "[%w_]+")
		  if (p_1 ~= 1) or (p_2 ~= string.len(p_str)) then return false end
	   end
	 end
	 -- check the string after '@'
	 if string.find(estr, "^[%.]+") then return false end
	 if string.find(estr, "%.[%.]+") then return false end
	 if string.find(estr, "@") then return false end
	 if string.find(estr, "[%.]+$") then return false end
 
	 local _,count = string.gsub(estr, "%.", "")
	 if (count < 1 ) or (count > 3) then
		 return false
	 end
 
	 return true
end 

init()

return Account