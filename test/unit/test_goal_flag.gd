extends GutTest

const FlagScene := preload("res://src/goal/goal_flag.tscn")
const PlayerScene := preload("res://src/player/player.tscn")

var flag: GoalFlag


func before_each():
	add_child_autofree(EmotionWorld.new())
	flag = add_child_autofree(FlagScene.instantiate())
	watch_signals(flag)


func test_プレイヤーが触れるとゴールに着いたことを知らせる():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	flag._on_body_entered(player)
	assert_signal_emitted(flag, "reached")


func test_プレイヤー以外が触れてもゴールにならない():
	var other: StaticBody2D = add_child_autofree(StaticBody2D.new())
	flag._on_body_entered(other)
	assert_signal_not_emitted(flag, "reached")
