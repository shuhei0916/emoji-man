extends GutTest
## 感情チャートをグラフとして描く画面のテスト

var chart: EmotionChart
var view: EmotionChartView


func before_each():
	chart = EmotionChart.default()
	view = EmotionChartView.new()
	add_child_autofree(view)
	view.build(chart)


func _nodes() -> Array:
	return view.get_children().filter(func(n): return n is GraphNode)


func test_感情ごとにノードができる():
	assert_eq(_nodes().size(), chart.emotions.size())


func test_見出しは大きな絵文字で1行目に括弧付きの名前2行目にバフが書かれている():
	var joy: GraphNode = view.get_node("joy")
	assert_eq(joy.title, "😄")
	assert_eq((joy.get_child(0) as Label).text, "（喜び）")
	assert_eq((joy.get_child(1) as Label).text, "ジャンプ×1.5")


func test_バフのない感情にはバフなしと書かれている():
	var hope: GraphNode = view.get_node("hope")
	assert_eq((hope.get_child(1) as Label).text, "バフなし")


func test_出来事はノードの中には書かれない():
	var neutral: GraphNode = view.get_node("neutral")
	assert_eq(neutral.get_child_count(), 2)


func test_遷移ごとに出来事の書かれた矢印ができる():
	assert_eq(view.arrows.size(), chart.transitions.size())
	var t: EmotionTransition = chart.transitions[0]
	assert_eq(view.arrows[0].from, t.from)
	assert_eq(view.arrows[0].to, t.to)
	assert_eq(view.arrows[0].event, t.event)


func test_矢印は元のノードの縁から先のノードの縁まで引く():
	var a := Rect2(0, 0, 100, 50)
	var b := Rect2(300, 0, 100, 50)
	var seg := EmotionChartView.arrow_between(a, b, 0.0)
	assert_almost_eq(seg[0], Vector2(100, 25), Vector2(0.01, 0.01), "元の右の縁から")
	assert_almost_eq(seg[1], Vector2(300, 25), Vector2(0.01, 0.01), "先の左の縁まで")


func test_行きと帰りの矢印は重ならないように横へずらす():
	var a := Rect2(0, 0, 100, 50)
	var b := Rect2(300, 0, 100, 50)
	var go := EmotionChartView.arrow_between(a, b, 8.0)
	var back := EmotionChartView.arrow_between(b, a, 8.0)
	assert_ne(go[0].y, back[1].y)


func test_系統ごとに枠で囲む():
	var frames := view.get_children().filter(func(n): return n is GraphFrame)
	assert_eq(frames.size(), chart.group_titles.size())
	assert_eq(view.get_element_frame(&"joy").name, &"happy")
	assert_eq(view.get_element_frame(&"anger").name, &"angry")


func test_指定した感情のノードを強調する():
	view.highlight(&"anger")
	assert_true((view.get_node("anger") as GraphNode).selected)
	view.highlight(&"joy")
	assert_true((view.get_node("joy") as GraphNode).selected)
	assert_false((view.get_node("anger") as GraphNode).selected, "前に強調していたものは戻る")


func test_ノードは動かせない():
	for n: GraphNode in _nodes():
		assert_false(n.draggable)
