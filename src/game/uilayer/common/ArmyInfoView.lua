--region NewFile_1.lua
--Author : luqingqing
--Date   : 2015/11/2
--此文件由[BabeLua]插件自动生成

local ArmyInfoView = class("ArmyInfoView", require("game.uilayer.base.BaseLayer"))


function ArmyInfoView:ctor(id,callbackfun)
    
    ArmyInfoView.super.ctor(self)
    
    self._callback = callbackfun
    if  id == nil then
        self.id = 1001
    else
        self.id = tonumber(id)
    end

    self.data = g_data.soldier[self.id]

    ArmyInfoView.super.ctor(self)

    self.layer = self:loadUI("bingying_mianban.csb")

    self.root = self.layer:getChildByName("scale_node")
    self.Button_xhao = self.root:getChildByName("Button_xhao")
    --self.Image_4 = self.root:getChildByName("Image_4")
    self.Image_15 = self.root:getChildByName("Image_15")
    self.Image_15_0 = self.root:getChildByName("Image_15_0")
    self.Image_15_1 = self.root:getChildByName("Image_15_1")
    self.Text_mingc = self.root:getChildByName("Text_mingc")

    self.name = self.root:getChildByName("text_1")
    self.Panel_nei = self.root:getChildByName("Panel_nei")

    for i=1, 3 do
        self["Panel_tiao0"..i] = self.Panel_nei:getChildByName("Panel_tiao0"..i)
        self["Panel_tiao0"..i.."_LoadingBar_2"] = self["Panel_tiao0"..i]:getChildByName("LoadingBar_2")
        self["Panel_tiao0"..i.."_Text_4"] = self["Panel_tiao0"..i]:getChildByName("Text_4")
        self["Panel_tiao0"..i.."_Text_4_0"] = self["Panel_tiao0"..i]:getChildByName("Text_4_0")
        --self["Panel_tiao0"..i.."_LoadingBar_1"] = self["Panel_tiao0"..i]:getChildByName("LoadingBar_1")
        --self["Panel_tiao0"..i.."_LoadingBar_2"] = self["Panel_tiao0"..i]:getChildByName("LoadingBar_2")
    end


    local property = {
        g_tr_original("attRange"), 
        g_tr_original("foodCost"),
        g_tr_original("moveSpeed"),
        g_tr_original("armyFightForce"), 
        g_tr_original("carry"),
        g_tr_original("haveNum")
    }
    
    for i=1, 6 do
        self["Panel_0"..i] = self.Panel_nei:getChildByName("Panel_0"..i)
        self["Panel_0"..i.."_Text_1"] = self["Panel_0"..i]:getChildByName("Text_1")
        self["Panel_0"..i.."_Text_1_0"] = self["Panel_0"..i]:getChildByName("Text_1_0")
        self["Panel_0"..i.."_Text_1"]:setString(property[i])
    end

    self.root:getChildByName("text"):setString(g_tr("armyinfotitle"))
    self.root:getChildByName("Text_14"):setString(g_tr("armyskillstr"))
    self.Panel_nei:getChildByName("Panel_tiao01"):getChildByName("Text_3"):setString(g_tr("armyattack"))
    self.Panel_nei:getChildByName("Panel_tiao02"):getChildByName("Text_3"):setString(g_tr("armydefense"))
    self.Panel_nei:getChildByName("Panel_tiao03"):getChildByName("Text_3"):setString(g_tr("armylife"))
    

    self.Button_jianhao = self.root:getChildByName("Button_jianhao")
    self.Button_jianhao:getChildByName("Text_6"):setString(g_tr("armyfired"))




    self:addEvent()
    self:setData()
end

function ArmyInfoView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_xhao then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            elseif sender == self.Button_jianhao then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self:getSoldierNum() <= 0 then
                    g_airBox.show( g_tr("SoldierFiredNotEnougt") ,3)
                    return
                end


                g_msgBox.show( g_tr("SoldierFiredStr"),nil,2,
                function ( eventtype )
                    --确定
                    if eventtype == 0 then 
                        local function callback( result , data )
                            if true == result then
                                --dump(data)
                                g_airBox.show( g_tr("SoldierFiredS") ,1)
                                self:setSoldierNum(0)
                                self["Panel_06_Text_1_0"]:setString(tostring(self:getSoldierNum()))
                                if self._callback then
                                    self._callback()
                                end
                                require("game.maplayer.homeMapArmyShow").reviewShowWithServerData()
                                self:close()
                            end
                        end
                        g_sgHttp.postData("soldier/dismissSoldier", { soldierId = self.id,num = self:getSoldierNum() }, callback )
                    end
                end , 1)
            end
        end
    end

    self.Button_xhao:addTouchEventListener(proClick)
    self.Button_jianhao:addTouchEventListener(proClick)
end

function ArmyInfoView:setData()
    --self.Image_4:loadTexture (g_resManager.getResPath(self.data.img_portrait))

    local addValue = 
    {
        self.data.attack,--攻击力
        self.data.defense,--防御力
        self.data.life,--生命值
    }


    self["Panel_tiao01_Text_4"]:setString(tostring(addValue[1]))
    self["Panel_tiao02_Text_4"]:setString(tostring(addValue[2]))
    self["Panel_tiao03_Text_4"]:setString(tostring(addValue[3]))

    --[[local max = math.max(self.data.attack, self.data.defense, self.data.life)

    local index = self.data.attack/max*100
    index = index - index%1
    self["Panel_tiao01_LoadingBar_2"]:setPercent(index)

    index = self.data.defense/max*100
    index = index - index%1
    self["Panel_tiao02_LoadingBar_2"]:setPercent(index)

    index = self.data.life/max*100
    index = index - index%1
    self["Panel_tiao03_LoadingBar_2"]:setPercent(index)]]

    --self.Text_mingc:setString(tostring(self.data.soldier_name))
    print("self.data.img_level",self.data.img_level)
    self.Text_mingc:setVisible(false)
    local lvImg = ccui.ImageView:create( g_resManager.getResPath(self.data.img_level))
    lvImg:setPosition(self.Text_mingc:getPosition())
    lvImg:setAnchorPoint(self.Text_mingc:getAnchorPoint())
    self.Text_mingc:getParent():addChild(lvImg)


    self.name:setString(g_tr(self.data.soldier_name))

    self["Panel_01_Text_1_0"]:setString(tostring(self.data.distance))
    self["Panel_02_Text_1_0"]:setString(string.format("%.2f", self.data.consumption / 10000 ))
    self["Panel_03_Text_1_0"]:setString(tostring(self.data.speed))
    self["Panel_04_Text_1_0"]:setString(string.format("%.2f", self.data.power / 10000 ))
    self["Panel_05_Text_1_0"]:setString(tostring(self.data.weight))

    local soldierData = g_SoldierMode:GetData()

    if soldierData then
        for k, v in pairs(soldierData) do 
            if self.data.id == v.soldier_id then 
                --curNum = v.num 
                self:setSoldierNum(v.num )
                break
            end 
        end
    end

    self["Panel_06_Text_1_0"]:setString( tostring(self:getSoldierNum()) )

    --技能1
    local skill_node_1 = self.root:getChildByName("Text_15")
    local skill_node_bg_1 =  self.root:getChildByName("Image_15")
    if self.data.skill_1 and self.data.skill_1~= 0 then
        local soldierSkillConfig = g_data.soldier_skills[self.data.skill_1]
        if soldierSkillConfig then
            local skill_name_1 = g_tr( soldierSkillConfig.soldier_skills_name )
            skill_node_1:setString( skill_name_1 )
            skill_node_bg_1:setTouchEnabled(true)
            g_itemTips.tipStr(skill_node_bg_1,skill_name_1,g_tr(soldierSkillConfig.soldier_skill_introduction))
        end
    else
        self.root:getChildByName("Image_15"):setVisible(false) 
        skill_node_1:setVisible(false) 
    end
    --技能2
    local skill_node_2 = self.root:getChildByName("Text_15_0")
    local skill_node_bg_2 =  self.root:getChildByName("Image_15_0")
    if self.data.skill_2 and self.data.skill_2~= 0 then
        local soldierSkillConfig = g_data.soldier_skills[self.data.skill_2]
        if soldierSkillConfig then
            local skill_name_2 = g_tr( soldierSkillConfig.soldier_skills_name )
            skill_node_2:setString( skill_name_2 )
            skill_node_bg_2:setTouchEnabled(true)
            g_itemTips.tipStr(skill_node_bg_2,skill_name_2,g_tr(soldierSkillConfig.soldier_skill_introduction))
        end
    else
        self.root:getChildByName("Image_15_0"):setVisible(false) 
        skill_node_2:setVisible(false) 
    end
    --技能3
    local skill_node_3 = self.root:getChildByName("Text_15_1")
    local skill_node_bg_3 =  self.root:getChildByName("Image_15_1")
    if self.data.skill_3 and self.data.skill_3~= 0 then
        local soldierSkillConfig = g_data.soldier_skills[self.data.skill_3]
        if soldierSkillConfig then
            local skill_name_3 = g_tr( soldierSkillConfig.soldier_skills_name )
            skill_node_3:setString( skill_name_3 )
            skill_node_bg_3:setTouchEnabled(true)
            g_itemTips.tipStr(skill_node_bg_3,skill_name_3,g_tr(soldierSkillConfig.soldier_skill_introduction))

        end
    else
        self.root:getChildByName("Image_15_1"):setVisible(false)
        skill_node_3:setVisible(false)
    end


    --dump(g_BuffMode.GetData())

    --local buff_data = g_BuffMode.GetData()

    --[[for idx, v in ipairs(self.data.add_buff) do
        local node = self[ string.format("Panel_tiao0%d_Text_4_0",idx) ]
        local bar = self[ string.format("Panel_tiao0%d_LoadingBar_2",idx) ]
        bar:setPercent(0)
        
        local buffkey = g_data.buff[v].name
        node:setVisible(false)
        if buff_data then
            local buff_num = buff_data[tostring(buffkey)].v or 0
            local buffNum = 0
            --print("buffkey",buffkey,buff_num)
            if buff_num > 0 then
                node:setVisible(true)
                buffNum = math.floor(addValue[idx] * (buff_num/10000))
                node:setString( "+" .. buffNum )
            end
            local max = addValue[idx] + buffNum
            bar:setPercent( (buffNum / max) * 100 )
        end
    end]]

    local buffAddValue = self.getSoldierBuffValue(self.id)

    for idx, var in ipairs(buffAddValue) do
        local node = self[ string.format("Panel_tiao0%d_Text_4_0",idx) ]
        local bar = self[ string.format("Panel_tiao0%d_LoadingBar_2",idx) ]
        bar:setPercent(0)
        if var > 0 then
            node:setString( "+" .. var )
        else
            node:setVisible(false)
        end

    end
end

function ArmyInfoView:setSoldierNum(num)
    self.SoldierNum = num or 0
end

function ArmyInfoView:getSoldierNum()
    return self.SoldierNum or 0
end

function ArmyInfoView.getSoldierBuffValue(sid)
    local sData = g_data.soldier[sid]

    if sData == nil then
        return
    end

    local buffData = g_BuffMode.GetData()

    if buffData == nil then
        return
    end

    local addValue = 
    {
        sData.attack,--攻击力
        sData.defense,--防御力
        sData.life,--生命值
    }
    
    local buffAddValue = {}
    local sAddBuff = sData.add_buff
    for idx, v in ipairs(sAddBuff) do
        --print("getSoldierBuffValue value",v,g_data.buff[v].name)
        if buffData then
            local buffkey = g_data.buff[v].name
            local buff_num = buffData[tostring(buffkey)].v or 0
            local buffNum = 0
            buffNum = math.floor(addValue[idx] * (buff_num/10000))
            table.insert( buffAddValue,buffNum )
        end
    end

    return buffAddValue
end

return ArmyInfoView

--endregion
