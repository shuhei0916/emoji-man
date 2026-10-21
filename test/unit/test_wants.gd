extends GutTest
## キャラクターの「欲しいもの」（目標）に関するテスト

const PlayerScene := preload("res://src/player/player.tscn")
const NpcScene := preload("res://src/npc/npc.tscn")


func _spawn(scene: PackedScene, wants: Array[StringName]) -> EmojiCharacter:
	var c: EmojiCharacter = scene.instantiate()
	c.wants = wants
	return add_child_autofree(c)


func _face_of(c: EmojiCharacter) -> String:
	return c.get_node("FaceLabel").text


func test_欲しいものを手に入れると幸せになる():
	var player := _spawn(PlayerScene, [&"star"])
	player.take_item(&"star")
	assert_eq(_face_of(player), "😄")


func test_欲しくないものを手に入れても何も感じない():
	var player := _spawn(PlayerScene, [&"star"])
	player.take_item(&"rock")
	assert_eq(_face_of(player), "😐")


func test_自分の欲しいものを他人に取られると怒る():
	var player := _spawn(PlayerScene, [&"star"])
	var npc := _spawn(NpcScene, [&"star"])
	player.take_item(&"star")
	assert_eq(_face_of(npc), "😠")
