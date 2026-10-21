class_name EmojiCharacter
extends CharacterBody2D
## 頭に絵文字の顔を持ち、出来事を見て好き嫌いに応じた表情になるキャラクター。

const GROUP := &"emoji_characters"

@export var id := &""
## 好きな人・嫌いな人のid
@export var likes: Array[StringName] = []
@export var dislikes: Array[StringName] = []
## 欲しいもの（目標）のid
@export var wants: Array[StringName] = []

var face := Face.new()
var prefs := Preferences.new()

@onready var _face_label: Label = $FaceLabel


func _ready() -> void:
	add_to_group(GROUP)
	for other in likes:
		prefs.like(other)
	for other in dislikes:
		prefs.dislike(other)
	_refresh_face()


func _process(delta: float) -> void:
	face.update(delta)
	_refresh_face()


## subjectに起きた出来事を見て、好き嫌いに応じた表情になる
func witness(subject: StringName, is_good: bool, cause := &"") -> void:
	var reaction := Appraisal.appraise(id, subject, is_good, prefs, cause)
	if reaction == Appraisal.NO_REACTION:
		return
	face.feel(reaction)
	_refresh_face()


## 自分に起きた出来事を、自分を含む全員に知らせる
func announce(is_good: bool, cause := &"") -> void:
	for character in get_tree().get_nodes_in_group(GROUP):
		character.witness(id, is_good, cause)


## アイテムを手に入れる。
## 欲しいものなら自分にとって良いことになり、
## 同じものを欲しがっていた他の人にとっては、自分のせいで起きた悪いことになる
func take_item(item: StringName) -> void:
	if item in wants:
		announce(true, id)
	for other: EmojiCharacter in get_tree().get_nodes_in_group(GROUP):
		if other != self and item in other.wants:
			other.announce(false, id)


func _refresh_face() -> void:
	_face_label.text = face.get_emoji()
