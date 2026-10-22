class_name Player
extends EmojiCharacter

const SPEED := 300.0
const JUMP_VELOCITY := -750.0
const GRAVITY := 1600.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


## speed_multiplier: 横移動の速さの倍率, jump_height_multiplier: ジャンプの最高到達点の倍率
static func compute_velocity(current: Vector2, direction: float, jump_pressed: bool, on_floor: bool, delta: float, speed_multiplier := 1.0, jump_height_multiplier := 1.0) -> Vector2:
	var v := Vector2(direction * SPEED * speed_multiplier, current.y)
	if not on_floor:
		v.y += GRAVITY * delta
	elif jump_pressed:
		# 最高到達点は初速の2乗に比例するので、初速は平方根の倍率にする
		v.y = JUMP_VELOCITY * sqrt(jump_height_multiplier)
	return v


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var buff := MoodBuff.from_emotions(agent.get_emotional_state())
	velocity = compute_velocity(velocity, direction, Input.is_action_just_pressed("jump"), is_on_floor(), delta, buff.speed_multiplier, buff.jump_height_multiplier)
	move_and_slide()
	_update_animation(direction)


func _update_animation(direction: float) -> void:
	if direction != 0.0:
		_sprite.flip_h = direction < 0.0
	if not is_on_floor():
		_sprite.play("jump")
	elif direction != 0.0:
		_sprite.play("walk")
	else:
		_sprite.play("stand")
