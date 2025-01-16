extends Node

@export var points_label: Node
@export var hearts : Array[Node]

var points = 0

# _ready 函数初始化时无需赋值给 lives，直接从 Global 获取
func _ready():
	# 设置全局引用
	if Global != null:
		Global.set_game_manager(self)  # 设置 Global 中的 gameManager 为当前 GameManager 实例
		print("GameManager 已初始化并设置到 Global")
	
	# 初始化同步 Global 中的 player_lives 到全局变量
	_update_hearts()

# 生命减少函数
func decrease_health():
	Global.player_lives -= 1  # 直接修改 Global 中的 player_lives
	# 延迟更新生命值显示
	call_deferred("_update_hearts")  # 延迟执行更新生命的操作

# 更新生命图标
func _update_hearts():
	# 确保 hearts 数组长度与 Global.player_lives 匹配
	for h in range(len(hearts)):  # 使用数组的实际长度
		if h < Global.player_lives:
			hearts[h].show()  # 显示图标
		else:
			hearts[h].hide()  # 隐藏图标

# 增加得分函数
func add_point():
	# 如果当前玩家的生命值小于 3，则增加生命值
	if Global.player_lives < 3:
		Global.player_lives += 1  # 增加生命值
		print("增加生命值，当前生命值: ", Global.player_lives)
		
	points += 1  # 如果生命值已经为 3，则增加得分
	points_label.text = "已获得：" + str(points)  # 更新得分显示
	# 更新生命图标
	_update_hearts()

# 每帧检查 Global 中的重置标记
func _process(_delta):  # 使用 _delta 前缀来消除未使用的警告
	# 每帧监控 player_lives 的变化，并更新生命图标
	_update_hearts()

	if Global.reset_player:
		reset_player_state()
		Global.reset_player = false  # 重置标记，避免重复重置

# 重置玩家状态
func reset_player_state():
	# 直接从 Global 获取并重置生命值
	Global.player_lives = 3  # 重置 Global 中的 player_lives
	
	# 直接操作 hearts 数组，强制更新生命图标
	print("重置生命图标")
	for i in range(len(hearts)):
		if i < Global.player_lives:
			hearts[i].show()  # 显示图标
		else:
			hearts[i].hide()  # 隐藏图标

	print("玩家状态已重置，生命图标已更新。")
