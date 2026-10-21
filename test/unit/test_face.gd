extends GutTest


func test_初期状態の表情は普通():
	var face := Face.new()
	assert_eq(face.mood, Face.Mood.NEUTRAL)


func test_欲しいものを手に入れると表情が幸せになる():
	var face := Face.new()
	face.obtain_wanted_item()
	assert_eq(face.mood, Face.Mood.HAPPY)
