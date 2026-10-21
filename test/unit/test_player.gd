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


func test_嫌いな人に悪いことが起きたのを見るとざまあみろの顔になる():
	player.prefs.dislike(&"bob")
	player.witness(&"bob", false)
	assert_eq(player.get_node("FaceLabel").text, "😏")


func test_どうでもいい人の出来事を見ても表情は変わらない():
	player.witness(&"carol", false)
	assert_eq(player.get_node("FaceLabel").text, "😐")


func test_インスペクタで設定した好き嫌いが反映される():
	var p: Player = PlayerScene.instantiate()
	p.likes = [&"alice"]
	p.dislikes = [&"bob"]
	add_child_autofree(p)
	assert_eq(p.prefs.attitude_toward(&"alice"), Preferences.Attitude.LIKE)
	assert_eq(p.prefs.attitude_toward(&"bob"), Preferences.Attitude.DISLIKE)
