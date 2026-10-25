class_name EmotionChart
extends Resource
## 感情の定義と、出来事による遷移をまとめた静的データ。
## バフ・絵文字はここが唯一の元になる（MoodBuff と EmojiExpression はここを読む）。

const DEFAULT_PATH := "res://src/emotion/emotion_chart.tres"
const NEUTRAL := &"neutral"
## 感情が自然に消えて「ふつう」に戻る出来事の名前（EmotionWorld の減衰で約10秒）
const DECAY_EVENT := "約10秒たつ"

@export var emotions: Array[EmotionDef] = []
@export var transitions: Array[EmotionTransition] = []
## 系統のキー → 図の枠に出す見出し
@export var group_titles: Dictionary[StringName, String] = {}


static func default() -> EmotionChart:
	return load(DEFAULT_PATH)


func get_emotion(id: StringName) -> EmotionDef:
	for e in emotions:
		if e.id == id:
			return e
	return null


## 2つの感情からなる複合絵文字の定義。なければ null
func compound_of(a: StringName, b: StringName) -> EmotionDef:
	for e in emotions:
		if e.components.size() == 2 and ((e.components[0] == a and e.components[1] == b) or (e.components[0] == b and e.components[1] == a)):
			return e
	return null
