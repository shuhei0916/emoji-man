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

var cleared := false
var clear_label: Label


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
	clear_label = Label.new()
	clear_label.text = "クリア！"
	clear_label.visible = false
	hud.add_child(clear_label)
