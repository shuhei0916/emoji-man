extends GutTest
## 怒っていると壊せる箱のテスト

const PlayerScene := preload("res://src/player/player.tscn")
const NpcScene := preload("res://src/npc/npc.tscn")
const BoxScene := preload("res://src/gimmick/breakable_box.tscn")

var world: EmotionWorld
var player: Player
var box: BreakableBox


func before_each():
	world = add_child_autofree(EmotionWorld.new())
	player = PlayerScene.instantiate()
	player.wants = [&"star"]
	add_child_autofree(player)
	var npc: EmojiCharacter = NpcScene.instantiate()
	add_child_autofree(npc)
	box = add_child_autofree(BoxScene.instantiate())


func test_怒っているキャラクターがぶつかると壊れる():
	world.item_taken(&"npc", &"star")
	assert_true(box.hit_by(player))
	assert_true(box.is_queued_for_deletion())


func test_怒っていないキャラクターがぶつかっても壊れない():
	assert_false(box.hit_by(player))
	assert_false(box.is_queued_for_deletion())
