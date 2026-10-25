extends GutTest
## 感情チャート（感情の定義・バフ・出来事による遷移をまとめた静的データ）のテスト

var chart: EmotionChart


func before_each():
	chart = EmotionChart.default()


func test_既定のチャートを読み込める():
	assert_not_null(chart)
	assert_gt(chart.emotions.size(), 0)


func test_感情のidから絵文字とバフを引ける():
	var joy := chart.get_emotion(&"joy")
	assert_eq(joy.emoji, "😄")
	assert_eq(joy.jump_height_multiplier, 1.5)
	var anger := chart.get_emotion(&"anger")
	assert_eq(anger.emoji, "😠")
	assert_true(anger.can_break)


func test_チャートにない感情はnull():
	assert_null(chart.get_emotion(&"no-such-emotion"))


func test_普通の顔もチャートにある():
	assert_eq(chart.get_emotion(EmotionChart.NEUTRAL).emoji, "😐")


func test_複合絵文字は構成する2つの感情から引ける():
	assert_eq(chart.compound_of(&"joy", &"gloating").emoji, "😈")
	assert_eq(chart.compound_of(&"gloating", &"joy").emoji, "😈", "順番によらない")
	assert_null(chart.compound_of(&"joy", &"anger"))


func test_遷移の元と先はすべてチャートにある感情を指す():
	assert_gt(chart.transitions.size(), 0)
	for t in chart.transitions:
		assert_not_null(chart.get_emotion(t.from), "元: %s" % t.from)
		assert_not_null(chart.get_emotion(t.to), "先: %s" % t.to)
		assert_ne(t.event, "", "出来事の名前がある")


func test_GAMYGDALAの16の感情はすべてチャートにある():
	for name in Gamygdala.PAD_MAP:
		assert_not_null(chart.get_emotion(name), "%s" % name)


func test_出来事で表に出る感情からは約10秒でふつうに戻る():
	for t in chart.transitions:
		if t.from != EmotionChart.NEUTRAL:
			continue
		var back := chart.transitions.filter(func(b): return b.from == t.to and b.to == EmotionChart.NEUTRAL)
		assert_eq(back.size(), 1, "%s からふつうへ戻る" % t.to)
		assert_eq(back[0].event, EmotionChart.DECAY_EVENT)
