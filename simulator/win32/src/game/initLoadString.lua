g_loadFuncName = {
	["formula"] = "formula",
  ["FormulaBuff"] = "FormulaBuff",
	["OperateMaxHP"] = "OperateMaxHP",
	["OperateAttackForce"] = "OperateAttackForce",
	["OperateSkillForce"] = "OperateSkillForce",
	["OperateBuff"] = "OperateBuff",
  ["GenTalentVal"] = "GenTalentVal",
  ["CalculateTalent"] = "CalculateTalent",
}


--屏蔽loadstring函数
if g_custom_loadstring == nil then
	g_custom_loadstring = loadstring
	loadstring = nil
end


function g_custom_loadFunc(nameKey, parameter, body)
    local funStr = "function externFunction"..g_loadFuncName[nameKey]..parameter..body.." end"
    print("externFunction str is:",funStr)
	g_custom_loadstring(funStr)()
end