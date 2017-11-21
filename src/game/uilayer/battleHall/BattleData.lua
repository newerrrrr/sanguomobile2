local BattleData = class("BattleData")

function BattleData:ctor()

end

function BattleData:getInstance()
	if self.instance == nil then
		self.instance = require("game.uilayer.battleHall.BattleData").new()
	end

	return self.instance
end

function BattleData:getGodSkill(player)
	local result = {}
	local index = 1
	for i=1, #player.players do
		if player.godGeneralSkillArr then
			local tag = false
			for j=1, #player.godGeneralSkillArr do
				if player.godGeneralSkillArr[j].pid == player.players[i].player_id then
					if result[index] == nil then
						result[index] = {}
					end
					table.insert(result[index], player.godGeneralSkillArr[j])
					tag = true
				end
			end

			if tag == true then
				index = index + 1
			end
		end
	end

	return result
end

function BattleData:getDamage(player)
	
	local result = {}
	local max = 0

	for i=1, #player.players do
		local takeDamage = 0
		local doDamage = 0

		if result[player.players[i].player_id] == nil  then
			result[player.players[i].player_id] = {}
		end

		for key, value in pairs(player.players[i].unit) do
			if key ~= "trap" then
				takeDamage = takeDamage + value.takeDamage
				doDamage = doDamage + value.doDamage
			end
		end

		if max < takeDamage then
			max = takeDamage
		end

		if max < doDamage then
			max = doDamage
		end

		result[player.players[i].player_id].takeDamage = takeDamage
		result[player.players[i].player_id].doDamage = doDamage
	end

	return result, max
end

return BattleData