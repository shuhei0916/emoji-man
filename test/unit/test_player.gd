extends GutTest

const PlayerScene := preload("res://src/player/player.tscn")

var player: Player


func before_each():
	add_child_autofree(EmotionWorld.new())
	player = add_child_autofree(PlayerScene.instantiate())


func test_最初は普通の顔の絵文字を表示している():
	assert_eq(player.get_node("FaceLabel").text, "😐")


func test_インスペクタで設定した好き嫌いが関係として登録される():
	var p: Player = PlayerScene.instantiate()
	p.id = &"p2"
	p.likes = [&"alice"]
	p.dislikes = [&"bob"]
	add_child_autofree(p)
	assert_eq(p.agent.get_relation(&"alice").like, 1.0)
	assert_eq(p.agent.get_relation(&"bob").like, -1.0)
