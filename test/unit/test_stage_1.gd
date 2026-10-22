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


func test_NPCはプレイヤーが星を取ると一緒に喜ぶ():
	var npc: Npc = stage.get_node("Npc")
	stage.player.take_item(&"star")
	npc._refresh_face()
	assert_eq(npc.get_node("FaceLabel").text, "🥰")


func test_NPCは星へ歩いていかない():
	var npc: Npc = stage.get_node("Npc")
	assert_eq(npc.walk_direction(), 0.0)


func test_クリアするとステージ2へ進む():
	assert_eq(stage.next_stage, "res://src/level/stage_2.tscn")
