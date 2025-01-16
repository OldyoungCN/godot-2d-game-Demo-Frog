extends Node

@export var monster_scene: PackedScene
@onready var spawn_timer: Timer = $Timer
@export var game_manager: Node  # 暴露给编辑器
@onready var spawn_area_visualizer: Polygon2D = $"../World/SpawnAreaVisualizer"

@export var enemies_node: Node
@export var max_monsters: int = 8
@export var spawn_interval: float = 8.0
@export var player_node_path: NodePath  # 正确使用 @export，无需传递类型参数

var spawn_counter: int = 0  # 用于确保怪物名称唯一

func _ready():
	# 检查 enemies_node 是否为空
	if enemies_node == null:
		print("错误: enemies_node 未指定！请在面板中指定 Enemys 节点。")
		return
	
	# 检查玩家节点路径是否有效
	if get_node_or_null(player_node_path) == null:
		print("错误: 玩家节点未指定！请在面板中指定玩家节点。")
		return

	# 打印 player_node_path 检查是否正确设置
	#print("玩家节点路径:", player_node_path)
	
	var player = get_node_or_null(player_node_path)
	if player == null:
		print("错误: 未能找到玩家节点！请检查 NodePath 是否正确。")
		return
	# 修改为检查 Node 类型而不是 Node2D 类型
	if not player is Node:
		print("错误: 玩家节点类型错误！玩家节点应该是 Node 类型。")
		return
	
	# 设置定时器
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	spawn_timer.start()
	
	# 可视化 spawn_area
	update_spawn_area_visualizer()

# 更新可视化区域
func update_spawn_area_visualizer():
	# 确保 spawn_area_visualizer 是有效的
	if spawn_area_visualizer == null:
		#print("错误: spawn_area_visualizer 未指定！请在面板中指定 SpawnAreaVisualizer。")
		return
	
	# 使用 spawn_area_visualizer 的多边形定义区域
	var points = spawn_area_visualizer.polygon
	print("更新 spawn_area_visualizer 多边形:", points)
	spawn_area_visualizer.visible = true
func _on_spawn_timer_timeout():
	# 每次定时器超时时检查怪物数量
	#print("定时器超时，检查怪物数量")
	check_and_spawn_monsters()

func check_and_spawn_monsters():
	# 获取当前场景中的怪物数量
	var monsters_in_scene = enemies_node.get_child_count()
	#print("当前场景中的怪物数量:", monsters_in_scene)

	# 如果怪物数量少于最大值，生成新怪物
	if monsters_in_scene < max_monsters:
		#print("怪物数量未达到最大值，准备生成新怪物")
		spawn_monster()
	else:
		# 确保场内怪物数始终保持在最大值，删除多余的怪物
		#print("达到最大怪物数量，检查并清理多余的怪物")
		maintain_monster_count()

func maintain_monster_count():
	# 获取当前怪物节点
	var monsters = enemies_node.get_children()

	# 如果怪物超过最大数量，删除多余的怪物
	while monsters.size() > max_monsters:
		var monster_to_remove = monsters.pop_back()
		#print("删除多余怪物:", monster_to_remove.name)
		monster_to_remove.queue_free()  # 删除怪物

func spawn_monster():
	# 在 spawn_area_visualizer 定义的区域内随机生成怪物位置
	var spawn_position = get_random_position_from_visualizer()
	
	var monster = monster_scene.instantiate()
	monster.position = spawn_position
	
	# 设置 GameManager 引用
	if get_node_or_null("%GameManager") != null:
		monster.game_manager = get_node("%GameManager")
	else:
		print("错误：未找到 GameManager 节点，请确保路径正确并且节点已加载。")

	# 使用 spawn_counter 来确保每个怪物名称唯一
	spawn_counter += 1
	var new_monster_name = "Radmon_" + str(spawn_counter)
	monster.name = new_monster_name
	enemies_node.call_deferred("add_child", monster)
	monster.add_to_group("monster")
	
	#print("新怪物生成完毕：位置 =", spawn_position, "名称 =", new_monster_name)



# 获取 spawn_area_visualizer 内的随机位置
func get_random_position_from_visualizer() -> Vector2:
	# 获取 spawn_area_visualizer 的多边形点
	var points = spawn_area_visualizer.polygon
	var rand_index = randi() % points.size()
	
	# 返回一个随机的点作为生成位置
	return points[rand_index]
