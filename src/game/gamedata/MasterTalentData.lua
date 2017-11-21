local MasterTalentMode = {}
setmetatable(MasterTalentMode,{__index = _G})
setfenv(1, MasterTalentMode)

local baseData = nil

--更新显示
function NotificationUpdateShow()
	print("MasterTalentMode NotificationUpdateShow")
end

function SetData(data)
	baseData = data
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerTalent)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{ name = {"PlayerTalent",} }, onRecv)
	return ret
end

function GetData(  )
	if baseData == nil then
		RequestData()
	end
	return baseData
end


function GetTalentByOriginID( orginId )
    local data = GetData()
    if data then
        for key, var in ipairs(data) do
            if g_data.talent[var.talent_id].talent_type_id == orginId then
                return var
            end
        end
    end

end

return MasterTalentMode
