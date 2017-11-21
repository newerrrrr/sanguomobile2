

local ChatData = {}
setmetatable(ChatData,{__index = _G})
setfenv(1, ChatData)

local chatData = {}
local preChatDataTime = {} --记录上次最后一项数据的时间戳, 方便比较
local chatType 
local chatView 
local newChatCount = 0 
local RecorderHelper = require("game.audiorecord.audioRecorderHelper")
local ChatMode = require("game.uilayer.chat.ChatMode")
local ChatTypeEnum = ChatMode.getChatTypeEnum()
local SendFlag = ChatMode.getSendFlagEnum()
local lastWorldChatItem 

function NotificationUpdateShow()
end


--请求数据
function RequestChatDataByType(chatType, isAsync, usrCallback)
	local ret = false
	local function onRecv(result, msgData) 
		if result then
			ret = true
			if chatType == ChatTypeEnum.BlackName then 
				chatData[chatType] = msgData.ChatBlackList
			else 
				chatData[chatType] = msgData 
			end 
		end
		--通知用户
		if usrCallback then 
			usrCallback(result)
		end 		 
	end

	if chatType == ChatTypeEnum.World then 
		g_sgHttp.postData("Common/viewAllWorldMsg",{}, onRecv, isAsync)

	elseif chatType == ChatTypeEnum.Guild and g_AllianceMode.getSelfHaveAlliance() then 
		g_sgHttp.postData("Common/viewAllGuildMsg",{}, onRecv, isAsync)

	elseif chatType == ChatTypeEnum.BlackName then 
		g_sgHttp.postData("data/index",{name = {"ChatBlackList"}}, onRecv, isAsync) 

	elseif chatType == ChatTypeEnum.Battle or chatType == ChatTypeEnum.CityBattle then --暂时不支持向服务器拉数据
		--g_sgHttp.postData("data/index",{name = {"GuildCross"}}, onRecv, isAsync) 
	elseif chatType == ChatTypeEnum.Camp then
		g_sgHttp.postData("common/viewAllCampMsg", {}, onRecv, isAsync) 
	end 
	
	return ret 
end

function setComboData(msgData)
	if nil == msgData then return end 
	
	if msgData.World then 
		dump(msgData.World, "===msgData.World")
		chatData[ChatTypeEnum.World] = msgData.World 
	end 
	if msgData.Guild then 
		chatData[ChatTypeEnum.Guild] = msgData.Guild 
	end 
	if msgData.ChatBlackList then 
		chatData[ChatTypeEnum.BlackName] = msgData.ChatBlackList 
	end 

	if msgData.Camp then 
		chatData[ChatTypeEnum.Camp] = msgData.Camp 
	end 
end 

--登录时下发的世界聊天最新一条,用作首页下方显示
function setLastWorldChatItem(msgData)
	lastWorldChatItem = msgData and msgData[1] or nil 
end 

function getLastWorldChatItem()
	return lastWorldChatItem
end 


--更新所有数据
function RequestAllData(isAsync, usrCallback)
	local ret = true 

	local function onRecv(result, msgData) 
		print("RequestAllData:", result)
		if result then 
			setComboData(msgData)		
		end 

		--通知用户
		if usrCallback then 
			usrCallback(result)
		end 
		ret = result 
	end 
	g_sgHttp.postData("common/comboChat",{}, onRecv, isAsync) 

	return ret 
end 


function GetData(chatType, needToReq, isAsync, usrCallback) 
	if nil == chatData[chatType] or needToReq then 
		RequestChatDataByType(chatType, isAsync, usrCallback)
	end 

	--值拷贝,防止被外部修改
	local tbl = {}
	if chatData[chatType] then 
		for k, v in pairs(chatData[chatType]) do 
			table.insert(tbl, v)
		end 
	end 

	if chatType ~= ChatTypeEnum.BlackName and chatData[chatType] then 
		table.sort(tbl, function(a, b) return a.time < b.time end)
	end 
	return tbl
end 

function hasData(chatType) 
	return nil ~= chatData[chatType] 
end 

function notifyDataReady(chatType, callback) 
	if hasData(chatType) then 
		if callback then 
			callback(true) 
		end 
	else 
		GetData(chatType, true, true, callback)
	end 
end 

function SetBlackList(listData)
	chatData[ChatTypeEnum.BlackName] = listData 
end 

function isDataExist(chatType, dataItem)
	if nil == chatData[chatType] then return false end 

	for k, v in pairs(chatData[chatType]) do 
		if v.time == dataItem.time then 
			return true 
		end 
	end 

	return false 
end 

function isTypeOfChat(_type)
	for k, v in pairs(ChatTypeEnum) do 
		if v == _type then 
			return true 
		end 
	end 

	return false  
end 

function insertChatDataItem(dataItem)
	if nil == dataItem then return end 

	local chatType = dataItem.type 
	if isDataExist(chatType, dataItem) then return end 

	if nil == chatData[chatType] then 
		chatData[chatType] = {}
	end 
	table.insert(chatData[chatType], dataItem)
end 

function updateVoiceDataSendFlag(typeOfBattle, name, sendFlag)
	if not hasData(typeOfBattle) then return end 

	for k, v in pairs(chatData[typeOfBattle]) do 
		if v.paraData and v.paraData.filename == name then 
			chatData[typeOfBattle][k].send_flag = sendFlag 
			break 
		end 
	end 
end 

function getVoiceDataItem(typeOfBattle, name)
	local item 
	if hasData(typeOfBattle) then 
		for k, v in pairs(chatData[typeOfBattle]) do 
			if v.paraData and v.paraData.filename == name then 
				item = v 
				break 
			end 
		end 
	end 
	return item 	
end 

function saveVoiceDataToFile(para)
	if nil == para or nil == para.filename or nil == para.fileData then return end 

	local path = ChatMode.getRecordFilepath(para.filename)
	local file = io.open(path, "wb") 
	if file then 
		file:write(cTools_base64_decode(para.fileData))
		io.close(file)
	end 
end 


function setChatType(_type)
	chatType = _type
end 

function getChatType()
	if chatType then 
		return chatType 
	end 

	--第一次的打开聊天如果战场开的时候默认进战场
	local isFighting, ctype = ChatMode.isInBattle() 
	if isFighting then 
		return ctype 
	end 

	return ChatTypeEnum.World
end 

function onWillEnterForeground(dt) 
	print("chat:onWillEnterForeground", dt) 
	if nil == dt or dt > 5.0 then 
		GetData(getChatType(), true, true) 
	end 
end 

function setChatView(viewObj)
	chatView = viewObj 
end 

function getChatView()
	return chatView 
end 

function setNewCount(count)
	newChatCount = count 
end 

function getNewCount()
	return newChatCount or 0 
end 


--获取最新数据的时间戳
function getCurChatDataTime(chatType) 
	local data = chatData[chatType]
	if data and data[#data] and data[#data].time then 
		return data[#data].time 
	end 
end 

--备份最新数据的时间戳
function recordLastChatDataTime()
	preChatDataTime[ChatTypeEnum.World] = getCurChatDataTime(ChatTypeEnum.World) 
	preChatDataTime[ChatTypeEnum.Guild] = getCurChatDataTime(ChatTypeEnum.Guild) 
	preChatDataTime[ChatTypeEnum.Camp] = getCurChatDataTime(ChatTypeEnum.Camp) 
end 

--获取上次记录的最新数据时间戳
function getLastChatDataTime(chatType)
	return preChatDataTime[chatType] 
end 

--解析收到的聊天项(可能包含叠加的数据),并保存
function parseRecvData(chatData)
	if nil == chatData then return end 
	
	local tmp = {}

	--阵营/城战聊天数据为叠加形式
	if chatData.type == ChatTypeEnum.Camp or chatData.type == ChatTypeEnum.CityBattle then 
		tmp = chatData.data or {} 
	else 
		tmp = {chatData}
	end 

	local voicePlaying = false --如果包含多条语音, 则只播放一条
	for k, item in pairs(tmp) do 
		--战场聊天和城战聊天可能包含语音，而且城战语音几秒钟后服务器会发送回来,即使是自己发送 fuck !!!
		if item.type == ChatTypeEnum.Battle or item.type == ChatTypeEnum.CityBattle then 
			if item.paraData then 
				if getVoiceDataItem(item.type, item.paraData.filename) then ---如果本地已有语音数据则丢弃
					tmp[k] = nil 
				else 
					saveVoiceDataToFile(item.paraData)
					tmp[k].paraData.fileData = nil 

					--如果设置自动播放语音,并且处于开战状态,则自动播放其他玩家的语音
					if not voicePlaying and g_saveCache.voice_auto_play > 0 and g_PlayerMode.GetData().id ~= item.player_id then 
						if RecorderHelper.isAudioRecordSupport() and ChatMode.isInBattle() then --底层支持并且处于开战状态
							ChatMode.playVoice(item.paraData.filename, item.paraData.voiceTime, nil) 
						end 
						voicePlaying = true 
					end 
				end 
			end 
		end 

		if tmp[k] then 
			insertChatDataItem(tmp[k]) 
		end 
	end 

	return tmp 
end 

local function onRecvChatItem(obj, chatData)
	if nil == chatData then return end 
	
	-- dump(chatData, "onRecvChatItem")

	local data = parseRecvData(chatData)
	--界面更新
	for k, v in pairs(data) do 
		if chatView then 
			--如果数据为联盟聊天项且当前不在联盟聊天分页则标记新聊天数目
			if not chatView:isGuildChatType() and v.type == ChatTypeEnum.Guild then 
				setNewCount(getNewCount() + 1)
			end 

			chatView:updateChatData(v)

		elseif v.type == ChatTypeEnum.Guild then 
			setNewCount(getNewCount() + 1) 
		end 
	end 

	require("game.uilayer.mainSurface.mainSurfaceChat").updateChatComponent() 
end 

g_gameCommon.addEventHandler(g_Consts.CustomEvent.Chat, onRecvChatItem, ChatData) 


return ChatData 
