extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -900.0
const MAX_JUMPS = 1
const INVINCIBILITY_DURATION = 1.5  # 无敌时间，单位秒

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_left = MAX_JUMPS
var invincible = false  # 初始无敌状态为假
var controls_disabled = false  # 用于完全禁用玩家控制
@onready var game_over_panel: Panel = %GameOverPanel

@onready var number_label: Label = %NumberLabel

@warning_ignore("unused_parameter")
func _process(delta):
	if controls_disabled:
		return  # 如果控制被禁用，不再处理任何逻辑

	# 实时读取 Global.player_lives
	var lives = Global.player_lives

	if lives > 0:
		#print("玩家存活，剩余生命值: ", lives)
		pass
	else:
		# 玩家死亡逻辑
		if Global.playerAlive:  # 确保死亡逻辑只触发一次
			disable_player_controls()
			play_death_animation()

func _ready():
	Global.playerBody = self
	Global.playerAlive = true

func jump():
	if Global.playerAlive and not controls_disabled:  # 确保只有存活状态且控制未禁用时才能跳跃
		velocity.y = JUMP_VELOCITY
	else:
		print("玩家已死亡或控制已禁用，无法跳跃。")

func disable_player_controls():
	# 禁用玩家控制
	controls_disabled = true
	velocity = Vector2.ZERO  # 停止玩家的任何移动
	print("玩家操作已被禁用，生命值为 0。")

func play_hurt_animation(damage: int):
	if not invincible and Global.playerAlive:  # 确保玩家存活且不处于无敌状态
		invincible = true
		sprite_2d.play("hurt")  # 确保调用正确的动画播放方法
		print("玩家受伤，伤害值: ", damage)
		await get_tree().create_timer(INVINCIBILITY_DURATION).timeout
		invincible = false

		# 如果生命值减至 0，直接触发死亡逻辑
		if Global.player_lives == 0 and Global.playerAlive:
			disable_player_controls()
			play_death_animation()

func reset_player_state():
	# 恢复玩家生命状态
	if Global.player_lives == 0:  # 如果生命值为 0，复活时恢复为 3
		Global.player_lives = 3
	# 增加重置次数
	Global.reset_count += 1
	# 设置 number_label 的文本从 3 开始递减
	number_label.text = " X " + str(3 - Global.reset_count)  # 每次重置时递减
	
	# 检查是否到达 3 次重置
	if Global.reset_count >= 3:
		# 到达3次重置后暂停游戏并显示 GameOverPanel
		get_tree().paused = true  # 暂停游戏
		game_over_panel.show()  # 显示 GameOverPanel

	else:
		# 重置玩家状态
		Global.playerAlive = true  # 恢复玩家生命状态
		# 重置玩家位置
		position = Vector2(100, 100)  # 假设重置为某个位置

		# 重置玩家控制状态
		invincible = false  # 恢复无敌状态
		controls_disabled = false  # 恢复玩家控制
		jumps_left = MAX_JUMPS  # 重置跳跃次数
		velocity = Vector2.ZERO  # 重置速度

		# 重置动画状态
		sprite_2d.play("default")  # 恢复默认动画
		sprite_2d.modulate = Color(1, 1, 1, 1)  # 恢复完全不透明

		# 播放角色复活动画
		play_showup_animation()

		# 直接通过 Global.player_lives 修改生命值，以触发 _update_hearts()
		Global.player_lives = 3  # 确保玩家生命值重置为 3



# 死亡动画播放
func play_death_animation():
	if not invincible and Global.playerAlive:
		invincible = true  # 设置无敌状态，避免重复触发死亡逻辑
		sprite_2d.play("death")  # 播放死亡动画
		Global.playerAlive = false  # 更新全局变量，标记玩家死亡

		# 使用计时器等待动画播放完成
		await get_tree().create_timer(7 / 12.0).timeout  # 7帧 * 1/12秒每帧

		# 动画播放完成后进行重置或其他逻辑
		reset_player_state()

# 复活动画播放
func play_showup_animation():
	# 播放 showup 动画
	sprite_2d.play("showup")
	print("播放 showup 动画")

	# 使用计时器等待 showup 动画播放完毕（假设 showup 动画有 5 帧，12 FPS）
	var timer = get_tree().create_timer(5 / 12.0)  # 5帧 * 1/12秒每帧
	await timer.timeout  # 等待定时器超时

	# 播放默认动画
	sprite_2d.play("default")


# 物理处理
func _physics_process(delta: float):
	if controls_disabled:
		return  # 如果控制被禁用，直接返回，不再处理任何移动或物理逻辑

	# 检查生命值并强制触发死亡动画
	if Global.player_lives == 0 and Global.playerAlive:
		disable_player_controls()  # 禁用控制
		play_death_animation()  # 播放死亡动画
		return  # 终止其他逻辑

	if invincible:
		sprite_2d.modulate = Color(1, 1, 1, 0.5)  # 半透明表示无敌状态
	else:
		sprite_2d.modulate = Color(1, 1, 1, 1)
	# 动画处理
	if is_on_floor():  # 当角色在地面时
		if abs(velocity.x) > 1:  # 判断是否在跑动
			sprite_2d.animation = "running"
		else:
			sprite_2d.animation = "default"
	else:  # 当角色不在地面时（跳跃阶段）
		if jumps_left == 1:  # 第二次跳跃时的动画（双跳）
			sprite_2d.animation = "double_jump"
		else:  # 第一次跳跃时的动画
			sprite_2d.animation = "jumping"
	
	# 添加重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 处理跳跃
	if Input.is_action_just_pressed("jump") and jumps_left > 0 and not controls_disabled:  # 按下跳跃键且还有剩余跳跃次数
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1  # 减少剩余跳跃次数

	# 重置跳跃次数
	if is_on_floor() and jumps_left != MAX_JUMPS:
		jumps_left = MAX_JUMPS  # 当玩家在地面时重置跳跃次数

	# 获取输入方向并处理移动/减速
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = lerp(velocity.x, 0.0, 17 * delta)  # 0 改为 0.0 (浮动值)

	# 执行移动和碰撞处理
	move_and_slide()  # 不需要传递 velocity 参数

	# 处理朝向
	sprite_2d.flip_h = velocity.x < 0
