local MasterSkillMode = {}
setmetatable(MasterSkillMode,{__index = _G})
setfenv(1, MasterSkillMode)

local baseData = nil
local skillVec = nil

--更新显示
function NotificationUpdateShow()
	--print("MasterSkillMode NotificationUpdateShow")
    --require("game.uilayer.mainSurface.mainSurfaceChat").skillUpdate()
end

--用来更新持续时间的主动技能结束更新BUFF 数据的
function SetSkillVec()
    local serverData = GetData()
    if serverData == nil then return end
    if skillVec == nil then 
        skillVec = {} 
        local configData = g_data.master_skill
        for key, var in pairs(configData) do
            if var.duration == 1 then
                skillVec[key] = 0
            end
        end
    end

    for key, var in pairs(serverData) do
        if skillVec[var.talent_id]then
            --如果时间没到则将持续结束时间记录否则将其设置成0
            if var.effect_time > g_clock.getCurServerTime() then
                skillVec[var.talent_id] = var.effect_time
            else
                skillVec[var.talent_id] = 0
            end
        end
    end
end

function GetSkillVec()
    if skillVec == nil then
        SetSkillVec()
    end
    return skillVec
end

function SetData(data)
	baseData = data
    --更新主动技能的持续时间
    SetSkillVec()
end

--设置将到期的主动技能设置为0防止重新拉BUFF数据
function SetSkillOver(id)
    if skillVec[id] then
        skillVec[id] = 0
    end
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerMasterSkill)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{ name = {"PlayerMasterSkill",} }, onRecv)
	return ret
end

--请求数据
function RequestSynData( callback )
    
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.PlayerMasterSkill)
		end

        if callback then
            callback(result, msgData)
        end

	end
	g_sgHttp.postData("data/index",{ name = {"PlayerMasterSkill",} },onRecv,true)

end


function GetData(  )
	if baseData == nil then
		RequestData()
	end
	return baseData
end

return MasterSkillMode
