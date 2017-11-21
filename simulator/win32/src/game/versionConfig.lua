g_userPlatformPasswordKey = "4h3e4hz6"
g_userPlatformSource = "SANGUOMOBILETWO"
g_userPlatformSignKey = "SS96WX66MO86FABI7RK"


g_OutputLuaError = true		--是否打印lua报错

--前n个区允许fb登入
g_facebookAcountEnableMax = 6

local releasePackage = false	--发布包模式为true


local serverConfig = require("src.resUpdate.UpdateMgr").getServerCfg()
if false then
	if releasePackage then
        g_logicDebug = false	--逻辑是否debug(正式测试版本或正式发布版本改为false)
    else
        g_logicDebug = true		--逻辑是否debug(正式测试版本或正式发布版本改为false)
    end
    g_userPlatformHost = serverConfig.user_platform_host --登录平台
    g_paymentNotifiyHost = serverConfig.payment_notifiy_host --支付平台客户端主动通知(固定)，需跟创建订单接口域名保持一致  (适用：苹果，谷歌，智冠(MYCARD)支付)
    g_gameVersionServer = tonumber(serverConfig.game_version_server) --和服务器对应的版本号(每次更新和服务器一起 + 1)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        g_configHost = serverConfig.login_host_android --login server
        g_noticeURL = serverConfig.notice_host_android --公告url
    else
		g_configHost = serverConfig.login_host_ios --login server
		g_noticeURL = serverConfig.notice_host_ios --公告url
		if paymentForLua_IOS_setNotifyUrl then
			paymentForLua_IOS_setNotifyUrl(g_paymentNotifiyHost.."/payment/appleNotifyReceiver")
		end
    end
else
	if false then
		g_userPlatformHost = "http://u.m543.com" --正式平台（固定）
		g_paymentNotifiyHost = "http://pay.m543.com" --支付平台客户端主动通知(固定)，需跟创建订单接口域名保持一致  (适用：苹果，谷歌，智冠(MYCARD)支付)
		g_gameVersionServer = 2	--和服务器对应的版本号(每次更新和服务器一起 + 1)
		g_logicDebug = false	--逻辑是否debug(正式测试版本或正式发布版本改为false)
		if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
			g_configHost = "http://android.login.sanguomobile2.com" --login server
			g_noticeURL = "http://android.notice.sanguomobile2.com/notice/notice" --公告url
		else
			g_configHost = "http://ios.login.sanguomobile2.com" --login server
			g_noticeURL = "http://ios.notice.sanguomobile2.com/notice/notice" --公告url
			if paymentForLua_IOS_setNotifyUrl then
				paymentForLua_IOS_setNotifyUrl(g_paymentNotifiyHost.."/payment/appleNotifyReceiver")
			end
		end
  else
		--g_userPlatformHost = "27.115.98.171:522" --登录平台39（固定）
		g_userPlatformHost = "27.115.98.172:9999" --登录平台68（固定）
		g_paymentNotifiyHost = "http://27.115.98.172:9998" --支付平台客户端主动通知(固定)，需跟创建订单接口域名保持一致  (适用：苹果，谷歌，智冠(MYCARD)支付)
		-- g_configHost = "http://10.103.252.87" --开发87 login server（比如服务器列表，服务器端平台验证，固定）
		--g_configHost = "http://101.231.186.12:8083" --开发89 login server（比如服务器列表，服务器端平台验证，固定）
		g_configHost = "http://10.103.252.79:8881" --开发79 login server（比如服务器列表，服务器端平台验证，固定）
		--g_configHost = "http://staging.s1.sanguomobile2.com:84" --内测 login server（比如服务器列表，服务器端平台验证，固定）
		g_gameVersionServer = 1	--和服务器对应的版本号(每次更新和服务器一起 + 1)
		g_logicDebug = true	--逻辑是否debug(正式测试版本或正式发布版本改为false)
		g_noticeURL = "http://10.103.252.87/notice/notice" --公告url
		--g_noticeURL = "http://staging.s1.sanguomobile2.com:83/notice/notice" --内测 公告url
		if paymentForLua_IOS_setNotifyUrl then
			paymentForLua_IOS_setNotifyUrl(g_paymentNotifiyHost.."/payment/appleNotifyReceiver")
		end
  end
end