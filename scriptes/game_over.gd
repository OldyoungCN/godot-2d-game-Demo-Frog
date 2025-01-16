extends Node

@onready var restart_button: Button = $GameOverPanel/VBoxContainer/Restartgame  # 重启按钮
@onready var menu_button: Button = $GameOverPanel/VBoxContainer/Menu  # 菜单按钮
@onready var game_over_label: Label = $GameOverPanel/Label  # 游戏结束标签
@onready var reset_count_label: Label = $GameOverPanel/reset_count  # 显示重置次数的标签（可选）

func _ready():
	# 显示 Game Over 面板
	# 监控重置次数
	update_reset_count()
	# 根据 reset_count 判断是否显示 Game Over
	if Global.reset_count >= 3:
		game_over_label.text = "Game Over"
		reset_count_label.text = "重置次数：%d" % Global.reset_count  # 显示重置次数
		show_game_over_panel()
	else:
		# 如果重置次数不到 3，就可以选择继续游戏
		hide_game_over_panel()

# 更新重置次数的显示
func update_reset_count():
	# 通过 Global 获取 reset_count 来更新 UI
	reset_count_label.text = "重置次数: %d" % Global.reset_count

# 显示 Game Over 面板
func show_game_over_panel():
	get_tree().paused = true  # 暂停游戏逻辑
	$GameOverPanel.show()     # 显示游戏结束面板

# 隐藏 Game Over 面板
func hide_game_over_panel():
	get_tree().paused = false  # 解除暂停
	$GameOverPanel.hide()      # 隐藏游戏结束面板

# 重新开始游戏的按钮事件
func _on_restartgame_pressed():
	# 在重启游戏之前先重置状态
	Global.reset_count = 0  # 重置重置次数
	# 重载场景
	get_tree().reload_current_scene()

# 返回主菜单按钮事件
func _on_menu_pressed():
	# 返回主菜单
	get_tree().paused = false
	get_tree().change_scene_to_file("res://GameSenecs/Main.tscn")
