extends GutTest

const PlayerScene := preload("res://src/player/player.tscn")

var player: Player


func before_each():
	player = add_child_autofree(PlayerScene.instantiate())


func test_最初は普通の顔の絵文字を表示している():
	assert_eq(player.get_node("FaceLabel").text, "😐")


func test_欲しいものを手に入れると幸せな顔の絵文字になる():
	player.obtain_wanted_item()
	assert_eq(player.get_node("FaceLabel").text, "😄")


func test_幸せな顔は10秒経つと普通の顔に戻る():
	player.obtain_wanted_item()
	player._process(10.0)
	assert_eq(player.get_node("FaceLabel").text, "😐")
