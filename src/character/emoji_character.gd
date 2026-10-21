class_name EmojiCharacter
extends CharacterBody2D
## 頭に絵文字の顔を持ち、出来事を見て好き嫌いに応じた表情になるキャラクター。

const GROUP := &"emoji_characters"

@export var id := &""
## 好きな人・嫌いな人のid
@export var likes: Array[StringName] = []
@export var dislikes: Array[StringName] = []

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
func witness(subject: StringName, is_good: bool) -> void:
	var reaction := Appraisal.appraise(id, subject, is_good, prefs)
	if reaction == Appraisal.NO_REACTION:
		return
	face.feel(reaction)
	_refresh_face()


## 自分に起きた出来事を、自分を含む全員に知らせる
func announce(is_good: bool) -> void:
	for character in get_tree().get_nodes_in_group(GROUP):
		character.witness(id, is_good)


func _refresh_face() -> void:
	_face_label.text = face.get_emoji()
