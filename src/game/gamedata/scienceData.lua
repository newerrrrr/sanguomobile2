
--研究所

local scienceData = {}
setmetatable(scienceData,{__index = _G})
setfenv(1, scienceData)

local sciData

--更新显示
function NotificationUpdateShow()

end

function SetData(data)
	print("scienceData SetData:", data)
	sciData = data

	require("game.uilayer.science.Science"):instance():updateModeData(sciData)
end


--请求数据
function RequestData(isAsync)
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerScience)
		end
	end
	
	g_sgHttp.postData("data/index",{name = {"PlayerScience"}}, onRecv, isAsync)
	
	return ret 
end

--玩家所有空闲装备
function GetData() 
	if nil == sciData then 
		RequestData() 
	end 

	return sciData 
end

--通过 原型（science_type_id）找到对应天赋的数据
function GetScienceByOriginID(originId)
    local data = GetData()
    if data then
        for key, var in ipairs(data) do
            local config = g_data.science[var.science_id]
            if config and config.science_type_id == originId then
                return var
            end
        end
    end
end

return scienceData
