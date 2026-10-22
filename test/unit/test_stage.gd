extends GutTest
## ステージの進行（クリア・やり直し）のテスト

const PlayerScene := preload("res://src/player/player.tscn")
const FlagScene := preload("res://src/goal/goal_flag.tscn")

var stage: Stage
var player: Player
var goal: GoalFlag


func before_each():
	stage = Stage.new()
	stage.auto_reload = false
	add_child_autofree(EmotionWorld.new())
	player = PlayerScene.instantiate()
	goal = FlagScene.instantiate()
	stage.add_child(player)
	stage.add_child(goal)
	stage.player = player
	stage.goal = goal
	add_child_autofree(stage)
	watch_signals(stage)


func test_ゴールに着くとクリアになりクリアと表示される():
	goal.reached.emit()
	assert_true(stage.cleared)
	assert_true(stage.clear_label.visible)
	assert_string_contains(stage.clear_label.text, "クリア")


func test_最初はクリアと表示されていない():
	assert_false(stage.cleared)
	assert_false(stage.clear_label.visible)


func test_Rキーでやり直す():
	var ev := InputEventAction.new()
	ev.action = &"restart"
	ev.pressed = true
	stage._unhandled_input(ev)
	assert_signal_emitted(stage, "restart_requested")


func test_穴に落ちたらやり直す():
	player.global_position.y = stage.fall_limit_y + 1.0
	stage._physics_process(1.0 / 60.0)
	assert_signal_emitted(stage, "restart_requested")


func test_落ちていなければやり直さない():
	player.global_position.y = stage.fall_limit_y - 1.0
	stage._physics_process(1.0 / 60.0)
	assert_signal_not_emitted(stage, "restart_requested")


func test_クリアしたらプレイヤーは動かなくなる():
	goal.reached.emit()
	assert_false(player.is_physics_processing())


func test_ステージごとの案内を表示する():
	var s := Stage.new()
	s.auto_reload = false
	s.hint_text = "⭐を取ると高く跳べる"
	var p: Player = PlayerScene.instantiate()
	p.id = &"p2"
	var g: GoalFlag = FlagScene.instantiate()
	s.add_child(p)
	s.add_child(g)
	s.player = p
	s.goal = g
	add_child_autofree(s)
	assert_eq(s.hint_label.text, "⭐を取ると高く跳べる")
	assert_true(s.hint_label.visible)
