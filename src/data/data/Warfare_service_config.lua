local Warfare_service_configConfig = {
	{
		id = 1,
		name = "open_time",
		data = "20:00:00",
	},
	{
		id = 2,
		name = "ready_time",
		data = "3",
	},
	{
		id = 3,
		name = "fight_time",
		data = "30",
	},
	{
		id = 4,
		name = "wf_gate1_hitpoint",
		data = "floor(20000+$lv*400)",
	},
	{
		id = 5,
		name = "wf_gate2_hitpoint",
		data = "floor(15000+$lv*300)",
	},
	{
		id = 6,
		name = "wf_gate3_hitpoint",
		data = "floor(10000+$lv*200)",
	},
	{
		id = 7,
		name = "wf_playercastle_hitpoint",
		data = "2000+$lv*200",
	},
	{
		id = 8,
		name = "wf_catapult_atkpower",
		data = "floor(3000+pow($power,0.5)*3)",
	},
	{
		id = 9,
		name = "wf_catapult_atkcolddown",
		data = "30",
	},
	{
		id = 10,
		name = "wf_warhammer_hitpoint",
		data = "floor(2000+$lv*40)",
	},
	{
		id = 11,
		name = "wf_warhammer_atkpower",
		data = "floor(1000+pow($power,0.7)*2)",
	},
	{
		id = 12,
		name = "wf_warhammer_atkcolddown",
		data = "30",
	},
	{
		id = 13,
		name = "wf_glaivethrower_atkpower",
		data = "floor(1500+pow($power,0.5)*2)",
	},
	{
		id = 14,
		name = "wf_glaivethrower_atkcolddown",
		data = "30",
	},
	{
		id = 15,
		name = "wf_ladder_hitpoint",
		data = "floor(1000+$lv*20)",
	},
	{
		id = 16,
		name = "wf_ladder_max_progress",
		data = "10000",
	},
	{
		id = 17,
		name = "wf_ladder_progress",
		data = "floor(10+pow($power,0.5)/100)",
	},
	{
		id = 18,
		name = "wf_ladder_progress_colddown",
		data = "30",
	},
	{
		id = 19,
		name = "wf_ladder_respawn_time",
		data = "60",
	},
	{
		id = 20,
		name = "wf_basecastle_hitpoint",
		data = "floor(10000+$lv*200)",
	},
	{
		id = 21,
		name = "wf_soldier_count_start",
		data = "5000",
	},
	{
		id = 22,
		name = "wf_soldier_count_limit",
		data = "5000",
	},
	{
		id = 23,
		name = "wf_legion_count_limit",
		data = "2",
	},
	{
		id = 24,
		name = "wf_march_speed_buff",
		data = "50000",
	},
	{
		id = 25,
		name = "wf_defender_respawn_time",
		data = "30",
	},
	{
		id = 26,
		name = "wf_playercastle_respawn_price",
		data = "10",
	},
	{
		id = 27,
		name = "wf_playercastle_respawn_soldier_count",
		data = "5000",
	},
	{
		id = 28,
		name = "wf_reinforcement_soldier_count",
		data = "1000",
	},
	{
		id = 29,
		name = "wf_reinforcement_soldier_price",
		data = "19",
	},
	{
		id = 30,
		name = "wf_castle_teleport_colddown",
		data = "120",
	},
	{
		id = 31,
		name = "wf_march_speed_burst",
		data = "100",
	},
	{
		id = 32,
		name = "wf_winner_reward",
		data = "620001",
	},
	{
		id = 33,
		name = "wf_loser_reward",
		data = "620002",
	},
	{
		id = 34,
		name = "wf_guild_winner_reward",
		data = "620003",
	},
	{
		id = 35,
		name = "team_join_num",
		data = "10",
	},
	{
		id = 36,
		name = "wf_warhammer_respawn_time",
		data = "60",
	},
	{
		id = 37,
		name = "all_soldier",
		data = "50001",
	},
	{
		id = 38,
		name = "wf_atkcastle_hitpointlost",
		data = "floor(1000+pow($power,0.7)/3)",
	},
	{
		id = 39,
		name = "wf_atkgate_hitpointlost",
		data = "floor(1000+pow($power,0.5)*4)",
	},
	{
		id = 40,
		name = "wf_atkbasecastle_hitpointlost",
		data = "floor(1000+pow($power,0.5)*4)",
	},
	{
		id = 41,
		name = "wf_reinforcement_soldier_price_gem",
		data = "20",
	},
	{
		id = 42,
		name = "wf_enroll_start",
		data = "08:00:00",
	},
	{
		id = 43,
		name = "wf_match_start",
		data = "19:00:00",
	},
	{
		id = 44,
		name = "wf_award_start",
		data = "21:10:00",
	},
	{
		id = 45,
		name = "wf_close_time",
		data = "21:10:00",
	},
	{
		id = 46,
		name = "wf_guild_loser_reward",
		data = "620004",
	},
	{
		id = 47,
		name = "wf_guild_city_level",
		data = "20",
	},
	{
		id = 48,
		name = "wf_guild_num",
		data = "10",
	},
	{
		id = 49,
		name = "wf_attacker_respawn_time",
		data = "20",
	},
	{
		id = 50,
		name = "wf_attacker_respawn_add_time",
		data = "5",
	},
	{
		id = 51,
		name = "wf_defender_respawn_add_time",
		data = "5",
	},

}
return Warfare_service_configConfig