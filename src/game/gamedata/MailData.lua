

local MailData = {}
setmetatable(MailData,{__index = _G})
setfenv(1, MailData)


local mailDataChat = {} --存放聊天邮件
local mailDataOther = {}  --存放除了聊天之外的邮件 
local mailView 
local mailNewCountInfo
--邮件数据里的 type 字段含义见 MailHelper里的 MailType


--更新显示
function NotificationUpdateShow()
end

--获取组群聊天的所有成员信息
--isAsync:是否异步请求
function getGroupMembersForChat(connectId, isAsync) 
	local function onRecvMembers(result, msgData)
		print("on async Recv Members")
		if(result==true)then
			mailDataChat[1][msgData.groupId].groupMembers = msgData.groupMember 
		end 
	end 

	g_sgHttp.postData("Mail/getGroupMember",{groupId=connectId}, onRecvMembers, isAsync)
end 

--保存一封邮件数据
--dataType ：  1,聊天  2,联盟  3,侦查  4,战斗  5,系统  6,采集  7,打怪
--mail: 一封邮件数据
function setMailData(dataType, mail, groupMembers)
	--可以是新邮件, 状态更新邮件, 相同旧邮件 
	if nil == mailDataChat[dataType] then 
		mailDataChat[dataType] = {}
	end 
	if nil == mailDataOther[dataType] then 
		mailDataOther[dataType] = {}
	end 

	if mail.type == 2 or mail.type == 3 then --聊天
		if nil == mailDataChat[dataType][mail.connect_id] then 
			mailDataChat[dataType][mail.connect_id] = {mail = nil, chatLog = {}} 
		end 

		mailDataChat[dataType][mail.connect_id].mail = mail --组群列表总使用最新的一封做列表项
		mailDataChat[dataType][mail.connect_id].chatLog[mail.id] = mail --聊天记录里最少有一封
		print("====dataType, connectid", dataType, mail.connect_id)

		if mail.type == 3 then 
			mailDataChat[dataType][mail.connect_id].groupMembers = groupMembers 
			if nil == mailDataChat[dataType][mail.connect_id].groupMembers then --多人聊天时获取群组成员列表
				getGroupMembersForChat(mail.connect_id, true)
			end 
		end 
	else 
		mailDataOther[dataType][mail.id] = {mail = mail, chatLog = {}} --为了格式统一, 采用相同的存储格式
	end 
end 

--获取一封邮件数据
--dataType ：  1,聊天  2,联盟  3,侦查  4,战斗  5,系统  6,采集  7,打怪
--mailId, mailType, connectId: 邮件数据里的 id, type, connect_id字段
function getMailData(dataType, mailId, mailType, connectId)
	local data 

	if mailDataChat[dataType] then 
		if mailType == 2 or mailType == 3 then --聊天 
			if mailDataChat[dataType] and mailDataChat[dataType][connectId] then 
				data = mailDataChat[dataType][connectId] 
			end 
		else 
			data = mailDataOther[dataType][mailId]
		end 
	end 

	return data 
end 

--删除邮件数据
function deleteMailData(dataType, mail)
	if mail.type == 2 or mail.type == 3 then --聊天 
		if mailDataChat[dataType] and mailDataChat[dataType][mail.connect_id] then 
			mailDataChat[dataType][mail.connect_id] = nil 
		end 

	else 
		if mailDataOther[dataType][mail.id] then 
			mailDataOther[dataType][mail.id] = nil 
		end 
	end 
end 

function SetData(msgData, dataType)
	if nil == msgData or nil == msgData.mail then 
		return 0
	end 

	for k, v in pairs(msgData.mail) do 
		setMailData(dataType, v)
	end 
	return #msgData.mail
end 

--邮件数据
--参数 
--dataType ：  1,聊天  2,联盟  3,侦查  4,战斗  5,系统  6,采集  7,打怪
--direction: 0:旧邮件  1:新邮件
--mailId: 最大邮件id (默认是0)
--基于mailId 请求所有新邮件,或请求20封旧邮件 
function RequestData(dataType, direction, mailId, isAsync, usrCallback)
	local ret = false
	local dataLen = 0 

	direction = direction or 1 

	local function onRecv(result, msgData)
		print("RequestData: result=", result)
		if result then
			ret = true
			dataLen = SetData(msgData, dataType)
			-- dataLen = #msgData.mail 
			-- for k, v in pairs(msgData.mail) do 
			-- 	setMailData(dataType, v)
			-- end 
		end 

		if usrCallback then 
			usrCallback(result, dataType, dataLen)
		end 
	end 
	
	g_sgHttp.postData("Mail/getList",{type=dataType, direction=direction, id=mailId}, onRecv, isAsync)
	
	return ret, dataLen 
end 

--联网请求一封邮件数据
function RequestOneMailData(mailId, callback)
	local function onRecv(result, msgData)
		print("RequestOneMailData: result=", result, mailId)
		if result then
				if msgData and msgData.mail and msgData.mail.id and callback then 
					callback(msgData.mail)
				end 
		end 
	end 
	g_sgHttp.postData("Mail/getSharedMail",{id=mailId}, onRecv, false)
end 


--聊天记录(每条记录其实也是一封邮件)
--mailType: 邮件数据里面的type字段:  3:多人聊天, 其他：单条邮件
--connectId: playerId或组群id
--direction: 0:旧记录  1:新记录
--mailId：起始邮件id (默认是0)
function requestChatLog(mailType, connectId, direction, mailId)
	local ret = false
	local dataLen = 0 
	local dataType = 1 --聊天邮件类型
	direction = direction or 1 

	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			dataLen = #msgData.mail 

			--将记录放到上面的邮件数组里
			if mailType == 2 or mailType == 3 then --聊天
				if nil == mailDataChat[dataType][connectId] then 
					print("no mail for chat log !!!!")
					return 
				end 

				for k, v in pairs(msgData.mail) do 
					mailDataChat[dataType][connectId].chatLog[v.id] = v 

					--如果最新内容比邮件列表索引邮件新,则同步到索引邮件 
					if v.id > mailDataChat[dataType][connectId].mail.id then 
						mailDataChat[dataType][connectId].mail = v 
					end 
				end 
			end 
		end 
	end 
	
	g_sgHttp.postData("Mail/getChat",{type=mailType, connectId=connectId, direction=direction, id=mailId}, onRecv)

	print("ret, dataLen", ret, dataLen) 
	return ret, dataLen 
end 

--获取邮件列表数据,当空数据时这里不默认请求.
function getListData(dataType) 
	local tbl = {}

	if mailDataChat[dataType] then 
		for k, v in pairs(mailDataChat[dataType]) do 
			table.insert(tbl, v)
		end 
	end 

	if mailDataOther[dataType] then 
		for k, v in pairs(mailDataOther[dataType]) do 
			table.insert(tbl, v)
		end 
	end 

	return tbl 
end 

--现有数据包含的新邮件个数
function getDataCount(dataType)
	local newCount = 0 
	local total = 0 

	if mailDataChat[dataType] then 
		for k, v in pairs(mailDataChat[dataType]) do
			total = total + 1 
			if v.mail.read_flag == 0 then --新邮件
				newCount = newCount + 1 
			end 
		end 
	end 

	if mailDataOther[dataType] then 
		for k, v in pairs(mailDataOther[dataType]) do
			total = total + 1 
			if v.mail.read_flag == 0 then --新邮件
				newCount = newCount + 1 
			end 
		end 		
	end 

	return total, newCount 
end 

--现有数据最大、最小的邮件id
function getDataMaxMinId(dataType)
	local maxId = 0 
	local minId = 0xffffffff

	if mailDataChat[dataType] then 
		for k, v in pairs(mailDataChat[dataType]) do
			if v.mail.id > maxId then 
				maxId = v.mail.id 
			end 
			if v.mail.id < minId then 
				minId = v.mail.id 
			end 
		end 
	end 

	if mailDataOther[dataType] then 
		for k, v in pairs(mailDataOther[dataType]) do 
			if v.mail.id > maxId then 
				maxId = v.mail.id 
			end 
			if v.mail.id < minId then 
				minId = v.mail.id 
			end 
		end 	
	end 

	return maxId, minId  
end 

--获取聊天记录列表(只针对聊天邮件)
--connectId: playerId或组群id
function getChatLogData(connectId) 
	local tbl = {}
	local dataType = 1 

	if mailDataChat[dataType] and mailDataChat[dataType][connectId] then 
		for k, v in pairs(mailDataChat[dataType][connectId].chatLog) do 
			table.insert(tbl, v)
		end 
	end 
	
	if #tbl > 0 then 
		table.sort(tbl, function(a, b) return a.id > b.id end )
	end 

	return tbl 
end 

function setMailView(viewObj)
	mailView = viewObj 
end 

function getMailView()
	return mailView 
end 

function setUnreadInfo(info) 
	mailNewCountInfo = info 
end 

function getUnreadInfo() 
	return mailNewCountInfo 
end 

function requestMailUnreadCount(isAsync, callback)
	local ret = true 
	local function onRecvUnreadCount(result, data)
		-- dump(data, "onRecvUnreadCount")
		ret = result 
		if result then 
			setUnreadInfo(data.mailCount)
			if callback then 
				callback(data.mailCount)
			end 			
		end 
	end 
	g_sgHttp.postData("Mail/getUnread",{}, onRecvUnreadCount, isAsync) 

	return ret 
end 

--异步更新新邮件个数tips
function updateNewMailTips()
	requestMailUnreadCount(true, updateUnreadUITips)
end 

function updateUnreadUITips(info, notRequest)
	if nil == info then 
		info = getUnreadInfo()
	end 

	local totalNewMails = 0 
	for k, v in pairs(info) do 
		totalNewMails = totalNewMails + v.count  
	end 
	require("game.uilayer.mainSurface.mainSurfaceMenu").updateMailTips(totalNewMails) 
	require("game.mapguildwar.worldMapLayer_uiLayer").updateMailTips(totalNewMails) 
	require("game.mapcitybattle.worldMapLayer_uiLayer").updateMailTips(totalNewMails) 
	
	if mailView then 
		mailView:updateUnreadTips(info)

		--检查已有数据是否最新,如果不是,则后台异步请求
		for k, v in pairs(info) do 
			if v.count > 0 then 
				local dataType = tonumber(k)
				local total, newCount = getDataCount(dataType) 
				print("getDataCount", dataType, total, newCount, v.count)
				if v.count > newCount and not notRequest then 
					local maxId, _ = getDataMaxMinId(dataType)
					local direction = maxId > 0 and 1 or 0
					g_MailMode.RequestData(dataType, direction, maxId, true, function(result, dType, len)
							if result and len > 0 and mailView then 
								mailView:reloadMailList(dType)
							end 
						end)
				end 
			end 
		end 
	end 
end 

--新邮件个数增加
function incressUnreadCount(index, count)
	if mailNewCountInfo and mailNewCountInfo[index] then 
		mailNewCountInfo[index].count = mailNewCountInfo[index].count + count 
	end 
end 

--新邮件个数减少 
function reduceUnreadCount(index, count)
	if mailNewCountInfo and mailNewCountInfo[index] then 
		mailNewCountInfo[index].count = mailNewCountInfo[index].count - count 
		if mailNewCountInfo[index].count < 0 then 
			mailNewCountInfo[index].count = 0 
		end 
	end 
end 

function getPreReqMailTypeWhenEnter()
	return 4 
end 

--登录游戏时下载必要的邮件数据
function preLoadMailDataWhenEnter()
	local _type = getPreReqMailTypeWhenEnter()
	RequestData(_type, 0, 0, false) --用户判读下线时是否被攻击
	requestMailUnreadCount(false)
	return true 
end 

--更新新邮件数据
local function updateNewMails(obj, data)
	print("updateNewMails")
	if nil == data then return end 

	if mailView then --只有在邮件界面时才同步新邮件数据

		RequestData(data.cata_type, 1, math.max(0, data.mail_id-1), true, function(result)
				if result and mailView then 
					mailView:insertNewMail(data) 
				end 
			end)

	else --在后台时只更新最新的邮件		
		local maxId = 0 
		local mails = getListData(data.cata_type) 
		for k, v in pairs(mails) do 
			if v.mail.id > maxId then 
				maxId = v.mail.id 
			end 
		end 
		print("updateNewMails: type, maxId", data.cata_type, maxId)
		RequestData(data.cata_type, 1, maxId, true)

		updateNewMailTips()
	end 

	if data.cata_type == 4 then 
		g_PlayerMode.RequestData_Async()
	end 
end 
g_gameCommon.addEventHandler(g_Consts.CustomEvent.NewMail, updateNewMails, MailData)


return MailData 
