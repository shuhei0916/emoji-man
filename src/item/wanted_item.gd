class_name WantedItem
extends CharacterBody2D
## 拾ったり、投げたり、受け取ったりできるアイテム。誰も持っていなければ重力で落ちて床に止まる。

const GROUP := &"wanted_items"
const GRAVITY := 1600.0
## 床の上で横に滑る速さが落ちていく割合（1秒あたり）
const FRICTION := 1200.0
## 投げた人がすぐに拾い直さないための時間
const REPICK_DELAY := 0.4

## キャラクターの wants と照らし合わせるid
@export var item_id := &"star"

## 持っているキャラクター。誰も持っていなければ null
var holder: EmojiCharacter
## 最後に投げた人のid。受け取った人にとって、手に入れた出来事を起こした人になる
var last_thrower := &""
## これまでに手に入れたことのある人のid。拾い直しても、もう一度は出来事にならない
var owners: Array[StringName] = []

var _ignored: EmojiCharacter
var _ignore_left := 0.0


func _ready() -> void:
	add_to_group(GROUP)


func _physics_process(delta: float) -> void:
	if holder != null:
		global_position = holder.global_position + EmojiCharacter.HOLD_OFFSET
		return
	_ignore_left = maxf(0.0, _ignore_left - delta)
	velocity.y += GRAVITY * delta
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	move_and_slide()


## キャラクターの手から離れて、velocity で飛んでいく
func release(thrower: EmojiCharacter, launch_velocity: Vector2) -> void:
	holder = null
	last_thrower = thrower.id
	velocity = launch_velocity
	_ignored = thrower
	_ignore_left = REPICK_DELAY
	if get_parent() == thrower:
		reparent(thrower.get_parent())


func _on_body_entered(body: Node2D) -> void:
	if holder != null or body is not EmojiCharacter:
		return
	if body == _ignored and _ignore_left > 0.0:
		return
	body.touch_item(self)
