

local sgHttpEx = {}
setmetatable(sgHttpEx,{__index = _G})
setfenv(1,sgHttpEx)

--[[ 
example:

    local tbl = {
        ["name"] = "tt",
        ["aa"] = {["cc"]="bb", ["kk"]=1}
      }
    local function test2(result, data)
      print("result:", result) 
      dump(data)     
    end 
    sgHttpEx.postData("/dev/testPost/", tbl, test2)
--]]

local _getUserCode = function()
    local userCode = g_Account.getLoginUserCode()
    local userCodeHash = PSDeviceInfo:getMD5String(userCode)
    return userCode,userCodeHash
end


function sgHttpEx.getUUID()
    sgHttpEx._UUID = g_Account.getUserPlatformUid().."_"..g_Account.getChannel()
    sgHttpEx._UUIDMd5 = PSDeviceInfo:getMD5String(sgHttpEx._UUID)
    return sgHttpEx._UUID, sgHttpEx._UUIDMd5
end 

local m_Post_Iterate = 0	--请求计数器

--参数说明
--method: url中的模块方法; 
--jsonTbl:发送给服务器的json数据(lua table 格式)
--callback: 用户回调, 返回json数据(lua table 格式)
--useAsync: 是否异步
function sgHttpEx.postData(method, jsonTbl, callback , useAsync)
	if g_msgBox.isShowOffLine() == true 
		or g_msgBox.isShowVersionOffLine() == true 
		or g_msgBox.isShowDisableUser() == true 
			then
		return
	end
    local host = g_Account.getServerHost()
    local url 
    if string.sub(method, 1, 1) ~= "/" then 
        url = host .. "/" .. method 
    else 
        url = host .. method 
    end 
  
    m_Post_Iterate = m_Post_Iterate + 1
    local current_post_count = m_Post_Iterate

    jsonTbl = jsonTbl or {}
    jsonTbl.uuid, jsonTbl.hashCode = sgHttpEx.getUUID() 
    jsonTbl.game_version = g_gameVersionServer
    jsonTbl.login_hashcode = g_Account.getLoginHashCode()
    jsonTbl.timestamp = g_clock.getCurServerTime() 
    jsonTbl.timeCollated = g_clock.isTimeCollated()
    
	--联盟号登陆模式，会无视uuid
	local userCode, userCodeHashCode = _getUserCode()
	if userCode and userCode ~= "" then
		jsonTbl.userCode  = userCode
		jsonTbl.userCodeHash = userCodeHashCode
	end
	
	local para = jsonTbl and "json="..cjson.encode(jsonTbl) or ""
    
    local function onMsgReq(result, data, performCode, responseCode)
        if result == false then
            --网络错误
			if g_isDebug then
				print(tostring(current_post_count).."-------begin-------recv")
				print(string.format("%s%s\"%s\"", (useAsync and "异步" or "同步"), "收到 URL = ", method))
				print("网络错误 curl_easy_perform = "..tostring(performCode))
				print("网络错误 CURLINFO_RESPONSE_CODE = "..tostring(responseCode))
				print("数据 = "..data)
				print(tostring(current_post_count).."-------end-------recv")
			end
            g_msgBox.showNetError(performCode, responseCode)
            if callback then
                callback(false, nil)
            end
		elseif data == nil or data == "" then
			--服务器数据错误
			if g_isDebug then
				print(tostring(current_post_count).."-------begin-------recv")
				print(string.format("%s%s\"%s\"", (useAsync and "异步" or "同步"), "收到 URL = ", method))
				print("服务器数据错误")
				print(tostring(current_post_count).."-------end-------recv")
			end
            g_msgBox.showNetDataError()
            if callback then
                callback(false, nil)
            end
        else
			-- if g_isDebug then
			-- 	print(tostring(current_post_count).."-------begin-------recv")
			-- 	print(string.format("%s%s\"%s\"", (useAsync and "异步" or "同步"), "收到 URL = ", method))
			-- 	print(data)
			-- 	print(tostring(current_post_count).."-------end-------recv")
			-- end
            local dataTable = cjson.decode( data )
            
            --测试代码以后删除
            if type(dataTable.code) == "string" then
                g_airBox.show(g_tr("msgBox_unknowError")..dataTable.code, 3)
                if callback then
                    callback(false, nil)
                end
                return
            end
            
            if dataTable.steps then
                g_guideData.setCurrentServerStepId(dataTable.steps.step)
                g_guideData.setSavedOutOfOrderStepIds(dataTable.steps.step_set)
            end
			
            if tonumber(dataTable.code) > 0 then		
                if tonumber(dataTable.code) == 9999 then
                    --被挤下线
                    g_msgBox.showOffLine()
                elseif tonumber(dataTable.code) == 9998 then
                    --版本不对应，强制退到更新
                    g_msgBox.showVersionOffLine()
                elseif tonumber(dataTable.code) == 9997 then
                    --被封号，强制退到更新
                    g_msgBox.showVersionOffLine()
                elseif tonumber(dataTable.code) == 9996 then
                    --服务器维护状态，非授权的ip登入游戏
                    if callback then
                        callback(false, nil)
                    end
                elseif tonumber(dataTable.code) == 9995 then
                    --时间未同步
                    g_clock.ntpServerTime()
                    if callback then
                        callback(false, nil)
                    end
                else
                    --基本逻辑错误
                    g_requestManager.onRequestAutoErrorCodeTips(tonumber(dataTable.code))
                    if callback then
                        callback(false, nil)
                    end
                end
            else
                --没有错误
                if dataTable.basic then
                    g_requestManager.onRequestAutoUpdate(dataTable.basic)
                end
                if dataTable.extra then --自动转换道具
                    g_requestManager.onItemAutoConverted(dataTable.extra)
                end 
                
                if callback then
                    callback( result , dataTable.data)
                end
            end
        end
    end

	if g_isDebug then
		print(tostring(current_post_count).."-------begin-------send")
		print(string.format("%s%s\"%s\"", (useAsync and "异步" or "同步") , "发送URL = ", method))
		print(para)
		print(tostring(current_post_count).."-------end-------send")
	end
    --对参数进行MD5,防止被恶意篡改
    para = para .. "@" .. PSDeviceInfo:getMD5String(para) 
    url = url .. "?uuid="..sgHttpEx.getUUID()
	httpNet:getInstance():Post2(url, para, string.len(para), onMsgReq, 12, 12, (useAsync and true or false), g_useMsgPack, nil, nil)
    
end 


return sgHttpEx 
