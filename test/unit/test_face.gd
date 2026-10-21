extends GutTest

var face: Face


func before_each():
	face = Face.new()


func test_初期状態の表情は普通():
	assert_eq(face.mood, Face.Mood.NEUTRAL)


func test_任意の感情になれる():
	face.feel(Face.Mood.GLOATING)
	assert_eq(face.mood, Face.Mood.GLOATING)


func test_感情は10秒未満なら続き10秒経つと普通に戻る():
	face.feel(Face.Mood.HAPPY)
	face.update(9.9)
	assert_eq(face.mood, Face.Mood.HAPPY)
	face.update(0.1)
	assert_eq(face.mood, Face.Mood.NEUTRAL)


func test_感情が続いている間にもう一度感じると10秒数え直す():
	face.feel(Face.Mood.HAPPY)
	face.update(5.0)
	face.feel(Face.Mood.HAPPY)
	face.update(9.0)
	assert_eq(face.mood, Face.Mood.HAPPY)


var mood_emojis := [
	[Face.Mood.NEUTRAL, "😐"],
	[Face.Mood.HAPPY, "😄"],
	[Face.Mood.SAD, "😢"],
	[Face.Mood.HAPPY_FOR, "🥰"],
	[Face.Mood.PITY, "🥺"],
	[Face.Mood.RESENTMENT, "😒"],
	[Face.Mood.GLOATING, "😏"],
	[Face.Mood.ANGER, "😠"],
	[Face.Mood.GRATITUDE, "🥹"],
]


func test_各感情は対応する絵文字で表される(p = use_parameters(mood_emojis)):
	face.feel(p[0])
	assert_eq(face.get_emoji(), p[1])
