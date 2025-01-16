extends Button

func _on_pressed() -> void:
	# 重置 Global 中的所有游戏状态
	Global.reset_count = 0  # 重置重置次数
	Global.player_lives = 3  # 重置玩家生命值
	Global.playerAlive = true  # 恢复玩家生存状态
	
	# 重置其他相关状态（如果有的话）
	# 例如：
	# Global.player_score = 0  # 如果有得分系统
	# Global.some_other_state = initial_value  # 重置其他全局状态

	# 加载游戏场景
	get_tree().change_scene_to_file("res://GameSenecs/Level01.tscn")
