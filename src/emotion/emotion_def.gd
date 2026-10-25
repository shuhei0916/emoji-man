class_name EmotionDef
extends Resource
## 1つの感情の定義。顔に出す絵文字と、一番強い感情になったときのバフ。

## GAMYGDALA の感情の名前（複合絵文字なら "joy+gloating" のような名前）
@export var id := &""
@export var emoji := ""
## 画面に出す日本語の名前
@export var label := ""
## 複合絵文字のとき、構成する2つの感情。普通の感情なら空
@export var components: Array[StringName] = []

@export_group("バフ")
@export var jump_height_multiplier := 1.0
@export var speed_multiplier := 1.0
@export var can_break := false

@export_group("図")
## 図でまとめて囲む系統（EmotionChart.group_titles のキー）
@export var group := &""
## 図の上での位置
@export var position := Vector2.ZERO


## バフを短い文で表す。なければ空
func buff_text() -> String:
	var parts: PackedStringArray = []
	if jump_height_multiplier != 1.0:
		parts.append("ジャンプ×%s" % jump_height_multiplier)
	if speed_multiplier != 1.0:
		parts.append("速さ×%s" % speed_multiplier)
	if can_break:
		parts.append("木箱を壊せる")
	return "、".join(parts)
