extends GutTest
## ステージ中にTabで開く感情チャートのテスト

const PlayerScene := preload("res://src/player/player.tscn")
const FlagScene := preload("res://src/goal/goal_flag.tscn")

var stage: Stage
var player: Player
var world: EmotionWorld


func before_each():
	stage = Stage.new()
	stage.auto_reload = false
	world = add_child_autofree(EmotionWorld.new())
	player = PlayerScene.instantiate()
	player.wants = [&"star"]
	var goal: GoalFlag = FlagScene.instantiate()
	stage.add_child(player)
	stage.add_child(goal)
	stage.player = player
	stage.goal = goal
	add_child_autofree(stage)


func after_each():
	get_tree().paused = false


func _press_chart() -> void:
	var ev := InputEventAction.new()
	ev.action = &"chart"
	ev.pressed = true
	stage.chart_overlay._unhandled_input(ev)


func test_最初は表示されていない():
	assert_false(stage.chart_overlay.visible)


func test_Tabで開くとゲームが止まりプレイヤーの今の感情が強調される():
	player.take_item(&"star")
	_press_chart()
	assert_true(stage.chart_overlay.visible)
	assert_true(get_tree().paused)
	assert_true((stage.chart_overlay.view.get_node("joy") as GraphNode).selected)


func test_もう一度Tabで閉じるとゲームが再開する():
	_press_chart()
	_press_chart()
	assert_false(stage.chart_overlay.visible)
	assert_false(get_tree().paused)


func test_止まっている間もチャートは操作を受け付ける():
	assert_eq(stage.chart_overlay.process_mode, Node.PROCESS_MODE_ALWAYS)
