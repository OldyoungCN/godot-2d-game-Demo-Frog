extends CharacterBody2D

@onready var game_manager: Node = %GameManager

var player: CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("monster")

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0

	player = Global.playerBody


func _on_fire_hit_box_body_entered(body):
	if body.name == "CharacterBody2D":
		# 判断玩家是否站在物品顶部，如果是，则给玩家造成伤害
		var y_delta = position.y - body.position.y
		if y_delta > 30 and not body.invincible:  # 判断玩家是否站在物品顶部，并且玩家没有无敌状态
			# 伤害玩家
			body.jump()
			game_manager.decrease_health()
			body.play_hurt_animation(1)  # 播放玩家受伤动画
