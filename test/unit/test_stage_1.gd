extends GutTest
## ステージ1の人物設定のテスト

const Stage1Scene := preload("res://src/level/stage_1.tscn")

var stage: Stage


func before_each():
	stage = Stage1Scene.instantiate()
	stage.auto_reload = false
	add_child_autofree(stage)


func test_プレイヤーが星を取ると素直に喜ぶ():
	stage.player.take_item(&"star")
	stage.player._refresh_face()
	assert_eq(stage.player.get_node("FaceLabel").text, "😄")
