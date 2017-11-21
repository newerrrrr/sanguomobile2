local GeneralComponentLayer = class("GeneralComponentLayer",function()
    return ccui.Widget:create()
end)

function GeneralComponentLayer:ctor(item,generalConfigId,type,index)
    
    self._index = index
    local uiLayer = item
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    self._generalConfigId = generalConfigId
    
    self:setAnchorPoint(cc.p(0,0))
    self:setContentSize(baseNode:getContentSize())
    
    local generalInfo = g_data.general[generalConfigId]
    assert(generalInfo,"cannot found general info with id:"..generalConfigId)
    
    baseNode:getChildByName("Image_22_1"):loadTexture(g_resManager.getResPath(1005000 + generalInfo.general_quality))--背景
    baseNode:getChildByName("Image_22"):loadTexture(g_resManager.getResPath(generalInfo.general_big_icon))--半身像
    baseNode:getChildByName("Image_22_0"):loadTexture(g_resManager.getResPath(1005100 + generalInfo.general_quality))--边框
    
    baseNode:getChildByName("Text_46")
    :setString(g_tr("preGeneral"))--将领

    baseNode:getChildByName("Text_46_0")
    :setString(g_tr(generalInfo.general_name))--武将名称
    
    baseNode:getChildByName("Text_31")
    :setString(g_tr("betterArmy"))--优势兵种
    
    local equipInfo = g_data.equipment[generalInfo.general_item_id*100]
    local str = ""
    for i=1, #equipInfo.equip_skill_id do
        local skillInfo =  g_data.equip_skill[equipInfo.equip_skill_id[i]]
        local troopType = skillInfo.equip_arm_type
        local troopStr = ""
        if troopType == 1 then
            troopStr = g_tr("infantry")
        elseif troopType == 2 then
            troopStr = g_tr("cavalry")
        elseif troopType == 3 then
            troopStr = g_tr("archer")
        elseif troopType == 4 then
            troopStr = g_tr("vehicles")
        end
        str = str..troopStr.." "
    end
    baseNode:getChildByName("Text_31_1"):setString(str)
    
    local _,iconPath = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gold)
    baseNode:getChildByName("Image_37"):loadTexture(iconPath)
--    baseNode:getChildByName("Text_37_0")
--    :setString(g_tr("buyGeneralCost"))--花费
    
    baseNode:getChildByName("Text_37")
    :setString(generalInfo.cost_gold.."")--武将招募花费
    
    baseNode:getChildByName("Text_32")
    :setString(g_tr("recruit"))--招募
    
    baseNode:getChildByName("Panel_lock"):getChildByName("Text_1")
    :setString(g_tr("locked"))--未解锁
    
    baseNode:getChildByName("Panel_lock"):setVisible(false)
    
    if type == 2 then
        self:setButtonText(g_tr("amnesty")) --招安
    end

    local recruitBtn = baseNode:getChildByName("Button_10")
    recruitBtn:setTouchEnabled(true)
    recruitBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("onRecruit")
            local goldCnt = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gold)
            local cost = generalInfo.cost_gold
            if goldCnt >= cost then
                local resultHandler = function(result, msgData)
                      if result then
                          print("buy general success")
                          --g_airBox.show(g_tr("buyGeneralSuccess"))
                          self:updateView()
                          self:getDelegate():playRecruitAnimation(generalInfo,self._index)
                      end
                end
                
                --招募/招安武将请求
                if type == 1 then
                    g_sgHttp.postData("Pub/buy",{generalId = generalConfigId,steps = g_guideManager.getToSaveStepId() },resultHandler)
                elseif type == 2 then
                    g_sgHttp.postData("Pub/buyPrisoner",{generalId = generalConfigId },resultHandler)
                end
            else 
                g_airBox.show(g_tr("currencyLimit"))
            end
        end
    end)
    
    local addAnimation = function()
        local size = self:getContentSize()
        local nameDown
        local nameUp
        if generalInfo.general_quality == 4 then
            nameDown = "Effect_ZiSeKaPaiBaoBianDown"
            nameUp = "Effect_ZiSeKaPaiBaoBianUp"
        else
            nameDown = "Effect_JinSeKaPaiBaoBianDown"
            nameUp = "Effect_JinSeKaPaiBaoBianUp"
        end
         
        local armature , animation = g_gameTools.LoadCocosAni("anime/"..nameDown.."/"..nameDown..".ExportJson", nameDown)
        baseNode:getChildByName("Image_22_1"):addChild(armature)
        armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
        animation:play("Animation1")
    
       
        local armature , animation = g_gameTools.LoadCocosAni("anime/"..nameUp.."/"..nameUp..".ExportJson", nameUp)
        self:addChild(armature)
        armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
        animation:play("Animation1")
    end
    if generalInfo.general_quality >= 4 then
        local seq = cc.Sequence:create(cc.DelayTime:create(math.random() + math.random()/2),cc.CallFunc:create(addAnimation))
        self:runAction(seq)
    end
    
    self:updateView()
end

------
--  Getter & Setter for
--      GeneralComponentLayer._Delegate
-----
function GeneralComponentLayer:setDelegate(Delegate)
    self._Delegate = Delegate
end

function GeneralComponentLayer:getDelegate()
    return self._Delegate
end

function GeneralComponentLayer:updateView()

    local ownGenerals = g_GeneralMode.GetData()
    local generalRootId = g_data.general[self._generalConfigId].general_original_id
    for key, generalInfo in pairs(ownGenerals) do
        print("generalInfo.general_id:",generalInfo.general_id)
        local configId = tonumber(string.format(generalInfo.general_id.."%02d",generalInfo.lv))
        assert(g_data.general[configId])
        if g_data.general[configId].general_original_id == generalRootId then
            self:setButtonText(g_tr("generalRecruited"))
            local recruitBtn = self._baseNode:getChildByName("Button_10")
            recruitBtn:setEnabled(false)
            break
        end
    end
    
end

function GeneralComponentLayer:setButtonText(str)
    self._baseNode:getChildByName("Text_32"):setString(str or "")
end

return GeneralComponentLayer