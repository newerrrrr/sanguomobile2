local AllianceManorHelper = {}
setmetatable(AllianceManorHelper,{__index = _G})
setfenv(1,AllianceManorHelper)

--仓库单位转换为资源单位
function AllianceManorHelper.convertToResourceSize(type,count)
    local sizeCnt = 0
    if type == g_Consts.AllCurrencyType.Food then
        sizeCnt = count
    elseif type == g_Consts.AllCurrencyType.Gold then
        sizeCnt = count
    elseif type == g_Consts.AllCurrencyType.Wood then
        sizeCnt = count / 4
    elseif type == g_Consts.AllCurrencyType.Iron then
        sizeCnt = count / 32
    elseif type == g_Consts.AllCurrencyType.Stone then
        sizeCnt = count / 12
    end
    return math.floor(sizeCnt)
end

--资源单位转换为仓库单位
function AllianceManorHelper.convertToWarehouseSize(type,count)
    local sizeCnt = 0
    if type == g_Consts.AllCurrencyType.Food then
        sizeCnt = count
    elseif type == g_Consts.AllCurrencyType.Gold then
        sizeCnt = count
    elseif type == g_Consts.AllCurrencyType.Wood then
        sizeCnt = count * 4
    elseif type == g_Consts.AllCurrencyType.Iron then
        sizeCnt = count * 32
    elseif type == g_Consts.AllCurrencyType.Stone then
        sizeCnt = count * 12
    end
    return sizeCnt
end

return AllianceManorHelper