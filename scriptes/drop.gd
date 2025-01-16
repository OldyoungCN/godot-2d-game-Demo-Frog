extends Area2D

@onready var game_manager: Node = %GameManager  # 获取 GameManager 节点
@onready var character_body: Node = $"../../Players/CharacterBody2D"  # 获取 CharacterBody2D 节点，假设它在场景中

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		# 当玩家掉落时调用 CharacterBody2D 中的 reset_player_state() 方法
		_reset_player_state()
	elif body.is_in_group("monster"):
		# 如果碰撞的是怪物，直接摧毁怪物
		print("怪物掉落，摧毁怪物: ", body.name)
		body.queue_free()  # 直接使用 queue_free() 方法摧毁碰撞的怪物

func _reset_player_state():
	# 调用 CharacterBody2D 中的 reset_player_state 方法
	if character_body:
		character_body.reset_player_state()  # 调用复活玩家的逻辑
