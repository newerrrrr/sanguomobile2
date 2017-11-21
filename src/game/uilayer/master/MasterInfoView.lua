local MasterInfoView = class("MasterInfoView", require("game.uilayer.base.BaseLayer"))
local MODE = nil
local master_data = nil
local data_list = nil

local title_str = 
{
    g_tr("Power"),          --"战斗力"
    g_tr("PowerCount"),     --"战力统计"
    g_tr("Military"),       --"军事"
    g_tr("Resources"),      --"资源"
    g_tr("Development"),    --"发展"
    g_tr("Defend"),         --"城防"
} 

function MasterInfoView:createLayer( playerid  )
    --[[MODE = require("game.uilayer.master.MasterMode").new()
    master_data = MODE:getMasterInfo()
    if master_data then
        g_sceneManager.addNodeForUI( MasterInfoView:create() )
        return true
    end
    return false]]

    --player/playerInfoDetail

    local function callback(result , data)
        if true == result then
            data_list = data
            if data and table.nums(data) > 0 then
                g_sceneManager.addNodeForUI( MasterInfoView:create() )
            end
            --dump(data)
        end
    end
    
    g_sgHttp.postData("player/playerInfoDetail", { player_id = playerid }, callback)

    --g_sceneManager.addNodeForUI( MasterInfoView:create() )
end

function MasterInfoView:ctor()
    MasterInfoView.super.ctor(self)
    self:initUI()
end

function MasterInfoView:initUI()
    
    self.layer = self:loadUI("zhugong_information.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
    
    --zhcn

    self.root:getChildByName("Text_7"):setString(g_tr("MasterInfoTitle"))


    local list = self.root:getChildByName("ListView_right_content")
    list:setItemsMargin(10)

    local titlemode = cc.CSLoader:createNode("zhugong_info_item_title.csb")
    local infomode = cc.CSLoader:createNode("zhugong_info_item.csb")
    --筛选贴图
    local filter = {}
    for key, var in pairs( g_data.master_attribute ) do
        --print("var.type",var.type)
        if filter[var.type] == nil then filter[var.type] = {} end
        table.insert( filter[var.type],var)
    end
    
    --排序 
    for i, var in pairs(filter) do
        table.sort( var,function (a,b)
            return a.id < b.id
        end)
    end

    --贴图
    for i, fdata in pairs(filter) do
        local title = titlemode:clone()
        title:getChildByName("item_title"):getChildByName("text_title"):setString( title_str[i] )
        list:pushBackCustomItem(title)
        for j, data in ipairs(fdata) do
            --服务端数据
            local datanum = data_list[tostring(data.id)]
            
            --特殊处理 出征军团数

            if datanum then
                local item = infomode:clone()
                item:getChildByName("item"):getChildByName("label"):setString( g_tr( data.name ) )
                local num = item:getChildByName("item"):getChildByName("num")
                --print("data",data.id,data.type,data_list[tostring(data.id)])
                num:setString(  tostring(datanum) )
                list:pushBackCustomItem(item)
                --隐藏最后一项的 下划线
                if j == table.nums(fdata) then
                    item:getChildByName("item"):getChildByName("Image_1"):setVisible(false)
                end
            end
        end
    end
end

function MasterInfoView:onEnter( )
    print("MasterInfoView onEnter")
end

function MasterInfoView:onExit( )
	print("MasterInfoView onExit")
    MODE = nil
    master_data = nil
    data_list = nil
end

return MasterInfoView