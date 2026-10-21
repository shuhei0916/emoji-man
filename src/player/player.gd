class_name Player
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -750.0
const GRAVITY := 1600.0

var face := Face.new()

@onready var _face_label: Label = $FaceLabel
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


static func compute_velocity(current: Vector2, direction: float, jump_pressed: bool, on_floor: bool, delta: float) -> Vector2:
	var v := Vector2(direction * SPEED, current.y)
	if not on_floor:
		v.y += GRAVITY * delta
	elif jump_pressed:
		v.y = JUMP_VELOCITY
	return v


func _ready() -> void:
	_refresh_face()


func _process(delta: float) -> void:
	face.update(delta)
	_refresh_face()


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity = compute_velocity(velocity, direction, Input.is_action_just_pressed("jump"), is_on_floor(), delta)
	move_and_slide()
	_update_animation(direction)


func obtain_wanted_item() -> void:
	face.obtain_wanted_item()
	_refresh_face()


func _refresh_face() -> void:
	_face_label.text = face.get_emoji()


func _update_animation(direction: float) -> void:
	if direction != 0.0:
		_sprite.flip_h = direction < 0.0
	if not is_on_floor():
		_sprite.play("jump")
	elif direction != 0.0:
		_sprite.play("walk")
	else:
		_sprite.play("stand")
