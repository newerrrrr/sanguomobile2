--region RankItemView.lua
--Author : luqingqing
--Date   : 2016/3/31
--此文件由[BabeLua]插件自动生成

local RankItemView = class("RankItemView", require("game.uilayer.base.BaseWidget"))

function RankItemView:ctor()
    self.layer = self:LoadUI("ranking_list.csb")
    self.root = self.layer:getChildByName("Panel_1")

    self.Image_shuz1 = self.root:getChildByName("Image_shuz1")
    self.Image_shuz2 = self.root:getChildByName("Image_shuz2")
    self.Image_shuz3 = self.root:getChildByName("Image_shuz3")

    self.Text_shuzi1 = self.root:getChildByName("Text_shuzi1")
    self.Image_2 = self.root:getChildByName("Image_2")

    self.Text_3 = self.root:getChildByName("Text_3")
    self.Text_4 = self.root:getChildByName("Text_4")

    self.imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    self.Image_2:addChild(self.imgFrame)
    self.imgFrame:setPosition(cc.p(self.Image_2:getContentSize().width/2, self.Image_2:getContentSize().height/2))

    self:addEvent()
end

function RankItemView:show(data, type, showPlayerInfo)
    self.data = data
    self.type = type
    self.showPlayerInfo = showPlayerInfo

    if self.data.rank == "1" then
        self.Image_shuz2:setVisible(false)
        self.Image_shuz3:setVisible(false)
    elseif self.data.rank == "2" then
        self.Image_shuz1:setVisible(false)
        self.Image_shuz3:setVisible(false)
    elseif self.data.rank == "3" then
        self.Image_shuz2:setVisible(false)
        self.Image_shuz1:setVisible(false)
    else
        self.Image_shuz1:setVisible(false)
        self.Image_shuz2:setVisible(false)
        self.Image_shuz3:setVisible(false)
    end

    self.Text_shuzi1:setString(self.data.rank)
    self.Text_4:setString(self.data.value)
    
    local countryName = ""
    if data.camp_id and tonumber(data.camp_id) > 0 then
			countryName = "["..g_tr(g_data.country_camp_list[tonumber(data.camp_id)].short_name).."]"
		end
		
    if tonumber(self.data.guild_id) == 0 then
        self.Text_3:setString(countryName..self.data.name)
    else
        self.Text_3:setString(countryName.."("..self.data.guild_name..")"..self.data.name)
    end
    
    
    

    if self.type == g_Consts.RankType.alliencePower or self.type == g_Consts.RankType.allienceEnemyDie then
        local currentIcon = g_AllianceMode.getAllianceIconId(tonumber(self.data.avatar))
        local iconInfo = g_data.alliance_flag[currentIcon]
        self.Image_2:loadTexture(g_resManager.getResPath(iconInfo.res_flag))
        self.imgFrame:setVisible(false)
    else
        local iconid = g_data.res_head[tonumber(self.data.avatar)].head_icon
        self.Image_2:loadTexture( g_resManager.getResPath(iconid))
        self.imgFrame:setVisible(true)
    end
end

function RankItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Image_2 then
                if self.showPlayerInfo ~= nil then
                    self.showPlayerInfo(self.data)
                end
            end
        end
    end

    self.Image_2:addTouchEventListener(proClick)
end

return RankItemView
--endregion
