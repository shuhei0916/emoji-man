class_name Stage
extends Node2D
## ステージの進行を管理する。ゴールに着いたらクリアを表示し、Rキーや穴に落ちたらやり直す。

signal restart_requested

@export var player: Player
@export var goal: GoalFlag
## false にすると、やり直しのときにシーンを読み込み直さない（テスト用）
@export var auto_reload := true
## プレイヤーがこれより下に落ちたらやり直す
@export var fall_limit_y := 1000.0
## 画面左上に出す、このステージの案内
@export_multiline var hint_text := ""

var cleared := false
var clear_label: Label
var hint_label: Label


func _ready() -> void:
	_build_hud()
	goal.reached.connect(_on_goal_reached)
	if auto_reload:
		restart_requested.connect(func() -> void: get_tree().reload_current_scene.call_deferred())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart"):
		restart_requested.emit()


func _physics_process(_delta: float) -> void:
	if player.global_position.y > fall_limit_y:
		restart_requested.emit()


func _on_goal_reached() -> void:
	cleared = true
	clear_label.visible = true
	player.set_physics_process(false)


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)

	hint_label = Label.new()
	hint_label.text = hint_text
	hint_label.position = Vector2(24, 16)
	hint_label.add_theme_font_size_override("font_size", 24)
	hint_label.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35))
	hud.add_child(hint_label)

	clear_label = Label.new()
	clear_label.text = "クリア！\nRキーでもう一度"
	clear_label.visible = false
	clear_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clear_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clear_label.add_theme_font_size_override("font_size", 64)
	clear_label.add_theme_color_override("font_color", Color.WHITE)
	clear_label.add_theme_color_override("font_outline_color", Color(0.2, 0.25, 0.35))
	clear_label.add_theme_constant_override("outline_size", 12)
	hud.add_child(clear_label)
