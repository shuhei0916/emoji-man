extends GutTest


func test_初期状態の表情は普通():
	var face := Face.new()
	assert_eq(face.mood, Face.Mood.NEUTRAL)
