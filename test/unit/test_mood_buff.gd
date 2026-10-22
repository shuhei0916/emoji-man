extends GutTest
## 感情によるバフ・デバフのテスト


func _emotions(pairs: Dictionary) -> Array[Gamygdala.Emotion]:
	var list: Array[Gamygdala.Emotion] = []
	for name in pairs:
		list.append(Gamygdala.Emotion.new(StringName(name), pairs[name]))
	return list


func test_感情がなければバフはかからない():
	var buff := MoodBuff.from_emotions(_emotions({}))
	assert_eq(buff.speed_multiplier, 1.0)
	assert_eq(buff.jump_height_multiplier, 1.0)


func test_一番強い感情が喜び系ならジャンプの高さが1点5倍():
	var buff := MoodBuff.from_emotions(_emotions({"joy": 0.5, "hope": 0.2}))
	assert_eq(buff.jump_height_multiplier, 1.5)
	assert_eq(buff.speed_multiplier, 1.0)


func test_喜びとざまあみろが混ざっていても喜び系として扱う():
	var buff := MoodBuff.from_emotions(_emotions({"joy": 0.5, "gloating": 0.5}))
	assert_eq(buff.jump_height_multiplier, 1.5)


func test_一番強い感情が落ち込み系なら移動が遅くなる():
	var buff := MoodBuff.from_emotions(_emotions({"distress": 0.5}))
	assert_eq(buff.speed_multiplier, 0.5)
	assert_eq(buff.jump_height_multiplier, 1.0)
