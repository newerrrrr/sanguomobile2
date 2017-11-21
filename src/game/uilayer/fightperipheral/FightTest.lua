--武斗测试配置
local isFightTest = false
if isFightTest == true then
    local pkId = -1

    local selfPlaystates = 
    {
        score = 0,
        server_id = 0,
        duel_rank_id = 1,
        nick = "红方",
        general_1 = {
            general_id = 10106,
            weapon_id = 1007000,
            armor_id = 2000700,
            horse_id = 3002200,
            zuoji_id = 0,
            lv = 1,
            skill_lv = 0,
            force_rate = 0,
            intelligence_rate = 0,
            governing_rate = 0,
            charm_rate = 0,
            political_rate = 0,
        },
        general_2 = {
            general_id = 10050,
            weapon_id = 1007000,
            armor_id = 2000700,
            horse_id = 3002200,
            zuoji_id = 0,
            lv = 1,
            skill_lv = 0,
            force_rate = 0,
            intelligence_rate = 0,
            governing_rate = 0,
            charm_rate = 0,
            political_rate = 0,
        },
        general_3 = {
            general_id = 10093,
            weapon_id = 1007000,
            armor_id = 2000700,
            horse_id = 3002200,
            zuoji_id = 0,
            lv = 1,
            skill_lv = 0,
            force_rate = 0,
            intelligence_rate = 0,
            governing_rate = 0,
            charm_rate = 0,
            political_rate = 0,
        },
        buff = {
            general_force_inc = 0,
            general_intelligence_inc = 0,
            general_governing_inc = 0,
            general_charm_inc = 0,
            general_political_inc = 0,
        }
    }
    local targetPlaystates =
    {
        score = 0,
        server_id = 0,
        duel_rank_id = 1,
        nick = "蓝方",
        general_1 = {
            general_id = 10093,
            weapon_id = 1007000,
            armor_id = 2000700,
            horse_id = 3002200,
            zuoji_id = 0,
            lv = 1,
            skill_lv = 0,
            force_rate = 0,
            intelligence_rate = 0,
            governing_rate = 0,
            charm_rate = 0,
            political_rate = 0,
        },
        general_2 = {
            general_id = 10106,
            weapon_id = 1007000,
            armor_id = 2000700,
            horse_id = 3002200,
            zuoji_id = 0,
            lv = 1,
            skill_lv = 0,
            force_rate = 0,
            intelligence_rate = 0,
            governing_rate = 0,
            charm_rate = 0,
            political_rate = 0,
        },
        general_3 = {
            general_id = 10050,
            weapon_id = 1007000,
            armor_id = 2000700,
            horse_id = 3002200,
            zuoji_id = 0,
            lv = 1,
            skill_lv = 0,
            force_rate = 0,
            intelligence_rate = 0,
            governing_rate = 0,
            charm_rate = 0,
            political_rate = 0,
        },
        buff = {
            general_force_inc = 0,
            general_intelligence_inc = 0,
            general_governing_inc = 0,
            general_charm_inc = 0,
            general_political_inc = 0,
        }
    }

    g_sceneManager.addNodeForSceneEffect(require("game.uilayer.fightperipheral.FightPreview"):create(selfPlaystates,targetPlaystates,pkId))
end