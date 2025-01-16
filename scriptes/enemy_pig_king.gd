extends CharacterBody2D
@export var game_manager: Node  # 暴露给编辑器


const speed = 100
var is_pig_chase: bool = true

var health = 2
var health_max = 2
var health_min = 0

var dead: bool = false
var taking_damage : bool = false

var damage_to_deal  = 1

var is_dealing_damage: bool = false

var dir: Vector2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback_force = 200  # 击退力

var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area = false

var can_take_damage = true  # 添加标志位，表示敌人是否可以受伤

func _ready():
	add_to_group("monster")

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0

	player = Global.playerBody
	move(delta)
	handle_animation()
	move_and_slide()



func move(delta):
	if !dead:
		if !is_pig_chase :
			velocity += dir * speed * delta
		elif is_pig_chase and !taking_damage :
			var dir_to_player =  position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		is_roaming = true
	elif dead:
		velocity.x = 0

func _on_area_2d_body_entered(body):
	if body.name == "CharacterBody2D" and not body.invincible:
		if not can_take_damage:  # 如果当前不能受伤，则不执行伤害逻辑
			return
		
		var y_delta = position.y - body.position.y
		var x_delta = body.position.x - position.x
		var damage = 1  # 定义伤害值

		if y_delta > 30:
			health -= damage
			if health <= 0:
				dead = true
				handle_animation()  # 确保调用此函数来处理动画
				body.jump()
			else:
				#敌人受伤
				taking_damage = true  # 标记敌人正在受伤
				apply_knockback(body)  # 施加击退效果
				body.jump()
		else:
			#自己受伤
			game_manager.decrease_health()
			body.play_hurt_animation(damage)  # 使用已定义的伤害值
			if x_delta > 0:
				#玩家朝右平移
				body.position.x += 50
			else:
				#玩家朝左平移
				body.position.x -= 50

# 击退效果函数
func apply_knockback(body: Node2D):
	var dir_to_player = position.direction_to(body.position)
	# 施加击退力，反方向击退
	velocity.x = -dir_to_player.x * knockback_force  # 水平击退
	velocity.y = -dir_to_player.y * knockback_force  # 垂直击退

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		anim_sprite.play("Running")
		
		if dir.x == 1:
			anim_sprite.flip_h = true
		elif dir.x == -1:
			anim_sprite.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("hurt")
		
		can_take_damage = false  # 播放 hurt 动画时不允许受到伤害
		await get_tree().create_timer(0.5).timeout  # 等待动画播放一段时间
		taking_damage = false  # 复位标识
		can_take_damage = true  # 动画播放完后恢复可以受伤
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("Dead")
		
		await get_tree().create_timer(0.2).timeout
		handle_death()

func handle_death():
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_pig_chase:
		dir =  choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
