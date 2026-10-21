extends GutTest
## 欲しいもの（目標）と、それをめぐる出来事への感情のテスト

const PlayerScene := preload("res://src/player/player.tscn")
const NpcScene := preload("res://src/npc/npc.tscn")

var world: EmotionWorld


func before_each():
	world = add_child_autofree(EmotionWorld.new())


func _spawn(scene: PackedScene, id: StringName, wants: Array[StringName], likes: Array[StringName] = [], dislikes: Array[StringName] = []) -> EmojiCharacter:
	var c: EmojiCharacter = scene.instantiate()
	c.id = id
	c.wants = wants
	c.likes = likes
	c.dislikes = dislikes
	return add_child_autofree(c)


func _face_of(c: EmojiCharacter) -> String:
	c._refresh_face()
	return c.get_node("FaceLabel").text


func test_欲しいものを手に入れると幸せになる():
	var player := _spawn(PlayerScene, &"player", [&"star"])
	player.take_item(&"star")
	assert_eq(_face_of(player), "😄")


func test_欲しくないものを手に入れても何も感じない():
	var player := _spawn(PlayerScene, &"player", [&"star"])
	player.take_item(&"rock")
	assert_eq(_face_of(player), "😐")


func test_自分の欲しいものを他人に取られると怒る():
	var player := _spawn(PlayerScene, &"player", [&"star"])
	var npc := _spawn(NpcScene, &"npc", [&"star"])
	player.take_item(&"star")
	assert_eq(_face_of(npc), "😠")


func test_標準的な感情はおよそ10秒で顔から消える():
	# 強さ0.5が線形減衰(0.05/秒)で0になるのが10秒後。表示のしきい値(0.01)を下回るのは9.8秒後
	var player := _spawn(PlayerScene, &"player", [&"star"])
	player.take_item(&"star")
	world._process(9.7)
	assert_eq(_face_of(player), "😄")
	world._process(0.3)
	assert_eq(_face_of(player), "😐")


func test_好きな人が欲しいものを手に入れると一緒に喜ぶ():
	var fan := _spawn(NpcScene, &"fan", [], [&"player"])
	var player := _spawn(PlayerScene, &"player", [&"star"])
	player.take_item(&"star")
	assert_eq(_face_of(fan), "🥰")


func test_嫌いな人が欲しいものを手に入れると妬む():
	var rival := _spawn(NpcScene, &"rival", [], [], [&"player"])
	var player := _spawn(PlayerScene, &"player", [&"star"])
	player.take_item(&"star")
	assert_eq(_face_of(rival), "😒")


func test_嫌いな人が欲しいものを他人に取られるのを見るとざまあみろと思う():
	var player := _spawn(PlayerScene, &"player", [], [], [&"npc"])
	_spawn(NpcScene, &"npc", [&"star"])
	var thief := _spawn(NpcScene, &"thief", [])
	thief.take_item(&"star")
	assert_eq(_face_of(player), "😏")


func test_嫌いな人から欲しいものを奪うと喜びとざまあみろが混ざる():
	var player := _spawn(PlayerScene, &"player", [&"star"], [], [&"npc"])
	_spawn(NpcScene, &"npc", [&"star"])
	player.take_item(&"star")
	assert_eq(_face_of(player), "😈")
