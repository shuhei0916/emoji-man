class_name EmojiCharacter
extends CharacterBody2D
## 頭に絵文字の顔を持ち、出来事に応じた感情を表情に出すキャラクター。
## 感情の評価はシーン内の EmotionWorld（GAMYGDALA）が行う。

## 持っている物を置く位置（キャラクターから見て頭の上）
const HOLD_OFFSET := Vector2(0, -80)
## 投げる速さ（横は向いている方向）
const THROW_VELOCITY := Vector2(450, -450)
const GROUP := &"emoji_characters"

@export var id := &""
## 好きな人・嫌いな人のid
@export var likes: Array[StringName] = []
@export var dislikes: Array[StringName] = []
## 欲しいもの（目標）のid
@export var wants: Array[StringName] = []

var agent: Gamygdala.Agent
## 持っている物。なければ null
var held: WantedItem
## 向いている方向（右が 1、左が -1）
var facing := 1.0

var _world: EmotionWorld

@onready var _face_label: Label = $FaceLabel


func _ready() -> void:
	add_to_group(GROUP)
	_world = get_tree().get_first_node_in_group(EmotionWorld.GROUP)
	agent = _world.register(id, likes, dislikes, wants)
	# シーンで子として置かれたアイテムは、最初から持っている
	for child in get_children():
		if child is WantedItem:
			_hold(child)
	_refresh_face()


func _process(_delta: float) -> void:
	_refresh_face()


## アイテムを手に入れる。cause はそれを起こした人（省略すると自分）
func take_item(item: StringName, cause := &"") -> void:
	_world.item_taken(id, item, cause)
	_refresh_face()


## 持っていないアイテムに触れた。標準では欲しい物だけ受け取る（受け取った物は消える）
func touch_item(item: WantedItem) -> void:
	if item.item_id not in wants:
		return
	take_item(item.item_id, item.last_thrower)
	item.queue_free()


## アイテムを持ち上げて手に入れる
func pick_up(item: WantedItem) -> void:
	_hold(item)
	take_item(item.item_id, item.last_thrower)


## 持っている物を、向いている方向へ投げる
func throw() -> void:
	if held == null:
		return
	var item := held
	held = null
	item.release(self, Vector2(THROW_VELOCITY.x * facing, THROW_VELOCITY.y))


## 動いたあと、ぶつかった木箱を（壊せる気分なら）壊す
func move_and_bump() -> void:
	move_and_slide()
	for i in get_slide_collision_count():
		var collider := get_slide_collision(i).get_collider()
		if collider is BreakableBox:
			collider.hit_by(self)


func _hold(item: WantedItem) -> void:
	held = item
	item.holder = self


func _refresh_face() -> void:
	_face_label.text = EmojiExpression.choose(agent.get_emotional_state())
