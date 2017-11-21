local GodGeneralBattleSkillShow = class("GodGeneralBattleSkillShow",require("game.uilayer.base.BaseLayer"))
local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()

function GodGeneralBattleSkillShow:ctor(gdata)
    
    GodGeneralBattleSkillShow.super.ctor(self)
    
    self.gData = gdata 
    local gid = gdata.cdata.general_original_id
    self.skillListData = {}
    for _, skill in pairs(g_data.battle_skill) do
        if skill.refresh_weight > 0 then
            if #skill.general_limit == 0 then
                table.insert(self.skillListData,skill)
            else
                for _, _gid in ipairs(skill.general_limit) do
                    print("_gid,gid",_gid,gid)
                    if gid == tonumber(_gid) then
                        table.insert(self.skillListData,skill)
                        break
                    end
                end
            end
        end
    end
    print("skill count",#self.skillListData)
    self:initUI()
end

function GodGeneralBattleSkillShow:initUI()
    self.layer = self:loadUI("GodGenerals_Smithrecast_Synthesis1_popup_0.csb")
    self.root = self.layer:getChildByName("scale_node")
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:close()
        end
    end)
    self.root:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("godGenXiLianDesTitle"))


    self.list = self.root:getChildByName("ListView_1")
    self:loadList()
end


function GodGeneralBattleSkillShow:loadList()
    local mode = cc.CSLoader:createNode("jitian_Panel_2.csb")

    local col = 7
    local row = math.ceil(#self.skillListData / col)
    local index = 1
    for i = 1,row do
        local node = mode:clone()
        for j = 1,col do
            local panel = node:getChildByName("scale_node"):getChildByName("Panel_"..j)
            local skill = self.skillListData[index]
            if skill then
                local skillNameTx = panel:getChildByName("Text_1")
                skillNameTx:enableOutline(cc.c4b(0, 0, 0,255),1)
                skillNameTx:setString(g_tr(skill.skill_name))
                local skillIconCon = panel:getChildByName("Image_1")
                local skillIcon = g_resManager.getRes(skill.skill_res)
                local skillLvTx = panel:getChildByName("Text_1_0")
                skillLvTx:enableOutline(cc.c4b(0, 0, 0,255),1)
                skillLvTx:setString("Lv"..skill.battle_skill_defalut_level)
                if skill.battle_skill_defalut_level >= 5 then
                    skillNameTx:setTextColor( cc.c3b(225,181,48) )
                    skillLvTx:setTextColor( cc.c3b(30,230,30) )
                end

                if skillIcon then
                    skillIcon:setTouchEnabled(true)
                    skillIcon:setScale(1.08)
                    local size = skillIconCon:getContentSize()
                    skillIconCon:addChild(skillIcon)
                    skillIcon:setPosition(cc.p(size.width/2,size.height/2))

                    local desc = self:getDesc(skill.id,skill.battle_skill_defalut_level)
                    g_itemTips.tipStr(skillIcon,g_tr(skill.skill_name),desc)
                end
            else
                panel:setVisible(false)
            end
            index = index + 1
        end
        self.list:pushBackCustomItem(node)
    end
end

function GodGeneralBattleSkillShow:getDesc(skillId,skillLevel)
    local cData = self.gData.cdata
    local nData = self.gData.ndata
    local level = tonumber(nData.lv)
    local skillLevel = skillLevel
    local skillConfig = g_data.battle_skill[skillId]
    local allSxVar = {
        ["force"] = 0,
        ["intelligence"] = 0,
        ["political"] = 0,
        ["governing"] = 0,
        ["charm"] = 0,
    }

    local sx = GodGeneralMode:initEquiptSx(cData.general_original_id)
    if sx then
        for key, var in pairs(sx) do
            allSxVar[key] = var.sv + var.av
        end
    end

    local v1 = clone(allSxVar)
    v1.lv = level
    v1.skill_lv = skillLevel
    
    g_custom_loadFunc("OperateAttackForce", "(v1)", " return " .. skillConfig.client_formula)
    local num = externFunctionOperateAttackForce(v1)

    g_custom_loadFunc("FormulaBuff", "(v1)", " return " .. skillConfig.client_formula_2)
    local bnum = externFunctionFormulaBuff(v1)
    local rddsc1 = g_tr( skillConfig.skill_description,{ num = num, numnext = "",buff = bnum,buffnext = ""} )
    return rddsc1
    --print(rddsc1)

end

return GodGeneralBattleSkillShow