extends GutTest
## ステージ3〜5の設定のテスト（解き方はヘッドレスの通しプレイで確かめている）


func _load(n: int) -> Stage:
	var stage: Stage = load("res://src/level/stage_%d.tscn" % n).instantiate()
	stage.auto_reload = false
	return add_child_autofree(stage)


func test_ステージ3_星を横取りするとNPCが怒って木箱を壊せる():
	var stage := _load(3)
	var npc: Npc = stage.get_node("Npc")
	stage.get_node("EmotionWorld").item_taken(&"player", &"star")
	assert_true(MoodBuff.from_emotions(npc.agent.get_emotional_state()).can_break)
	assert_eq(stage.next_stage, "res://src/level/stage_4.tscn")


func test_ステージ4_NPCは鍵を持ち星を欲しがっていて扉がある():
	var stage := _load(4)
	var npc: Npc = stage.get_node("Npc")
	assert_eq(npc.held.item_id, &"key")
	assert_true(&"star" in npc.wants)
	assert_not_null(stage.get_node_or_null("LockedDoor"))
	assert_eq(stage.next_stage, "res://src/level/stage_5.tscn")


func test_ステージ5_NPCは星を持ち鍵を欲しがっていて最後のステージ():
	var stage := _load(5)
	var npc: Npc = stage.get_node("Npc")
	assert_eq(npc.held.item_id, &"star")
	assert_true(&"key" in npc.wants)
	assert_eq(stage.next_stage, "")


func test_ステージ5_星をもらうと喜び系になり高く跳べる():
	var stage := _load(5)
	var npc: Npc = stage.get_node("Npc")
	stage.player.pick_up(npc.held)
	assert_eq(MoodBuff.from_emotions(stage.player.agent.get_emotional_state()).jump_height_multiplier, 1.5)
