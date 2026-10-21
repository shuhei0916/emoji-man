class_name EmojiCharacter
extends CharacterBody2D
## 頭に絵文字の顔を持ち、出来事に応じた感情を表情に出すキャラクター。
## 感情の評価はシーン内の EmotionWorld（GAMYGDALA）が行う。

@export var id := &""
## 好きな人・嫌いな人のid
@export var likes: Array[StringName] = []
@export var dislikes: Array[StringName] = []
## 欲しいもの（目標）のid
@export var wants: Array[StringName] = []

var agent: Gamygdala.Agent

var _world: EmotionWorld

@onready var _face_label: Label = $FaceLabel


func _ready() -> void:
	_world = get_tree().get_first_node_in_group(EmotionWorld.GROUP)
	agent = _world.register(id, likes, dislikes, wants)
	_refresh_face()


func _process(_delta: float) -> void:
	_refresh_face()


## アイテムを手に入れる
func take_item(item: StringName) -> void:
	_world.item_taken(id, item)
	_refresh_face()


func _refresh_face() -> void:
	_face_label.text = EmojiExpression.choose(agent.get_emotional_state())
