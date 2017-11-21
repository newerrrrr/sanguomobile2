local MasterEquipMode = {}
setmetatable(MasterEquipMode,{__index = _G})
setfenv(1, MasterEquipMode)

local baseData = nil
--此MAP数据只用于查询不可用于操作
local baseMapData = nil

--更新显示
function NotificationUpdateShow()
	print("MasterEquip NotificationUpdateShow")
end

function SetData(data)
	baseData = data
    baseMapData = {}
    for _ , v in ipairs(baseData) do
        baseMapData[ tonumber(v.id) ] = clone(v)
    end
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerEquipMaster)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{ name = {"PlayerEquipMaster",} }, onRecv)
	return ret
end

function RequestSycData(callback)
    local function onRecv(result, msgData)
        if(result==true)then
            SetData(msgData.PlayerEquipMaster)
        end
        
        if callback then
            callback(result,msgData)
        end
    end
    g_sgHttp.postData("data/index",{ name = {"PlayerEquipMaster",} }, onRecv,true)
end

function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

--获取主公宝物属性
function GetEquipSkillListById(id)

    if id  == nil or id <= 0 then
        return
    end
    
    if baseData == nil or baseMapData == nil then
        return
    end 

    local skill_list = {}
    local skillNum_list = {}

    local data = baseMapData[tonumber(id)]
    if data then
        
        local skill = data.equip_skill

        if skill then
            for skill_id, num in pairs(skill) do
                local std = g_data.equip_skill[ tonumber( skill_id ) ]
                local _buff_type = g_data.buff[ std.skill_buff_id[1] ].buff_type
                --dump( g_data.buff[ buff_id ] )
                --dump(std)
                local _num = tonumber( num ) 
                if _buff_type == 1 then
                    _num = _num / 10000 * 100
                end

                local numStr = tostring( _num or 0 )
                if _buff_type == 1 then
                    numStr = string.format("%.2f%%%%" , (tonumber(_num) or 0) ) 
                end

                local _min = std.min
                local _max = std.max
                local numRange = string.format( "(%d-%d)",_min , _max )
                if _buff_type == 1 then
                    _min = math.floor( _min / 100 )
                    _max = math.floor( _max / 100 )
                    numRange = string.format( "(%d%%-%d%%)",_min, _max)
                end
                --string.format( "(%d%%-%d%%)",math.floor(std.min / 100), math.floor(std.max / 100))

                local addvaluestr = g_tr( std.skill_description,{num = numStr}) .. numRange 
                table.insert(skill_list,addvaluestr)
                table.insert(skillNum_list,{ str = std.skill_description , value = _num , range = numRange , min = _min , max = _max,buff_type = _buff_type })
            end
        end
    else
        print("no found the equip data,id is :",id)
    end

    return skill_list,skillNum_list
end

return MasterEquipMode