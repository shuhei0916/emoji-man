class_name EmojiCharacter
extends CharacterBody2D
## 頭に絵文字の顔を持ち、出来事に応じた感情を表情に出すキャラクター。
## 感情の評価はシーン内の EmotionWorld（GAMYGDALA）が行う。

## 持っている物を置く位置（キャラクターから見て頭の上）
const HOLD_OFFSET := Vector2(0, -80)
## 投げる速さ（横は向いている方向）
const THROW_VELOCITY := Vector2(450, -450)
const GROUP := &"emoji_characters"
## つぶれたときの顔（感情ではなく一瞬の反射）
const SQUASHED_FACE := "😖"
## つぶれてから元に戻るまでの秒数
const SQUASH_DURATION := 0.3
## つぶれた瞬間の見た目の倍率（縦に縮んで横に広がる）
const SQUASH_SCALE := Vector2(1.3, 0.6)

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
## つぶれた状態が残っている秒数
var _squash_left := 0.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _face_label: Label = $FaceLabel
@onready var _body: CollisionShape2D = $CollisionShape2D
@onready var _sprite_base_y := _sprite.position.y
@onready var _face_base_y := _face_label.position.y
@onready var _body_base_y := _body.position.y
@onready var _body_base_height: float = _body.shape.size.y


func _ready() -> void:
	add_to_group(GROUP)
	# つぶれると当たり判定の形を変えるので、同じシーンの他のキャラクターと共有しない
	_body.shape = _body.shape.duplicate()
	_world = get_tree().get_first_node_in_group(EmotionWorld.GROUP)
	agent = _world.register(id, likes, dislikes, wants)
	# シーンで子として置かれたアイテムは、最初から持っている
	for child in get_children():
		if child is WantedItem:
			_hold(child)
	_refresh_face()


func _process(delta: float) -> void:
	_squash_left = maxf(0.0, _squash_left - delta)
	_apply_squash()
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


## アイテムを持ち上げて手に入れる。一度手に入れた物を拾い直しても、もう一度は喜ばない
func pick_up(item: WantedItem) -> void:
	_hold(item)
	if id in item.owners:
		return
	item.owners.append(id)
	take_item(item.item_id, item.last_thrower)


## 持っている物を、向いている方向へ投げる
func throw() -> void:
	if held == null:
		return
	var item := held
	held = null
	item.release(self, Vector2(THROW_VELOCITY.x * facing, THROW_VELOCITY.y))


## 動いたあと、ぶつかった木箱を（壊せる気分なら）壊す。天井に頭をぶつけたらつぶれる
func move_and_bump() -> void:
	move_and_slide()
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is BreakableBox and collider.hit_by(self):
			continue
		# 下向きの面（天井）には頭が当たっている
		if collision.get_normal().y > 0.0:
			squash()


## つぶれる（ムギュ）
func squash() -> void:
	_squash_left = SQUASH_DURATION
	_apply_squash()


func _hold(item: WantedItem) -> void:
	held = item
	item.holder = self


## つぶれ具合に合わせて見た目と当たり判定を縦に縮める（当たり判定の横幅は変えない）。
## 天井に当たっている頭を中心に縮めるので、頭から離れた所ほど上がる
func _apply_squash() -> void:
	var scale_now := Vector2.ONE.lerp(SQUASH_SCALE, _squash_left / SQUASH_DURATION)
	var head_y := _body_base_y - _body_base_height / 2.0
	var shrink := 1.0 - scale_now.y
	var face_center_y := _face_base_y + _face_label.size.y / 2.0
	_sprite.scale = scale_now
	_sprite.position.y = _sprite_base_y + (head_y - _sprite_base_y) * shrink
	_face_label.position.y = _face_base_y + (head_y - face_center_y) * shrink
	_body.shape.size.y = _body_base_height * scale_now.y
	_body.position.y = _body_base_y + (head_y - _body_base_y) * shrink


func _refresh_face() -> void:
	if _squash_left > 0.0:
		_face_label.text = SQUASHED_FACE
		return
	_face_label.text = EmojiExpression.choose(agent.get_emotional_state())
