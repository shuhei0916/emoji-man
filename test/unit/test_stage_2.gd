extends GutTest
## ステージ2（怒って木箱を壊す）の設定のテスト

const Stage2Scene := preload("res://src/level/stage_2.tscn")

var stage: Stage


func before_each():
	stage = Stage2Scene.instantiate()
	stage.auto_reload = false
	add_child_autofree(stage)


func test_NPCは星へ歩いていく():
	var npc: Npc = stage.get_node("Npc")
	assert_ne(npc.walk_direction(), 0.0)


func test_NPCに星を取られるとプレイヤーは怒って木箱を壊せる():
	var world: EmotionWorld = stage.get_node("EmotionWorld")
	world.item_taken(&"npc", &"star")
	assert_true(MoodBuff.from_emotions(stage.player.agent.get_emotional_state()).can_break)


func test_クリアするとステージ3へ進む():
	assert_eq(stage.next_stage, "res://src/level/stage_3.tscn")
