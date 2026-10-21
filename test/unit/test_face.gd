extends GutTest

var face: Face


func before_each():
	face = Face.new()


func test_初期状態の表情は普通():
	assert_eq(face.mood, Face.Mood.NEUTRAL)


func test_欲しいものを手に入れると表情が幸せになる():
	face.obtain_wanted_item()
	assert_eq(face.mood, Face.Mood.HAPPY)


func test_普通の表情は無表情の絵文字で表される():
	assert_eq(face.get_emoji(), "😐")


func test_幸せな表情は笑顔の絵文字で表される():
	face.obtain_wanted_item()
	assert_eq(face.get_emoji(), "😄")
