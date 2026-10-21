extends GutTest

var face: Face


func before_each():
	face = Face.new()


func test_初期状態の表情は普通():
	assert_eq(face.mood, Face.Mood.NEUTRAL)


func test_欲しいものを手に入れると表情が幸せになる():
	face.obtain_wanted_item()
	assert_eq(face.mood, Face.Mood.HAPPY)


var mood_emojis := [
	[Face.Mood.NEUTRAL, "😐"],
	[Face.Mood.HAPPY, "😄"],
	[Face.Mood.SAD, "😢"],
	[Face.Mood.HAPPY_FOR, "🥰"],
	[Face.Mood.PITY, "🥺"],
	[Face.Mood.RESENTMENT, "😒"],
	[Face.Mood.GLOATING, "😏"],
]


func test_各感情は対応する絵文字で表される(p = use_parameters(mood_emojis)):
	face.feel(p[0])
	assert_eq(face.get_emoji(), p[1])


func test_幸せになってから10秒未満は幸せなまま():
	face.obtain_wanted_item()
	face.update(9.9)
	assert_eq(face.mood, Face.Mood.HAPPY)


func test_幸せになってから10秒経つと普通に戻る():
	face.obtain_wanted_item()
	face.update(10.0)
	assert_eq(face.mood, Face.Mood.NEUTRAL)


func test_幸せな間にもう一度手に入れると10秒数え直す():
	face.obtain_wanted_item()
	face.update(5.0)
	face.obtain_wanted_item()
	face.update(9.0)
	assert_eq(face.mood, Face.Mood.HAPPY)


func test_任意の感情になれる():
	face.feel(Face.Mood.GLOATING)
	assert_eq(face.mood, Face.Mood.GLOATING)


func test_任意の感情も10秒経つと普通に戻る():
	face.feel(Face.Mood.GLOATING)
	face.update(9.9)
	assert_eq(face.mood, Face.Mood.GLOATING)
	face.update(0.1)
	assert_eq(face.mood, Face.Mood.NEUTRAL)
