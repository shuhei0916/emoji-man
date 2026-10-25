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


func test_ノードの見出しに絵文字と名前があり1行目にバフが書かれている():
	var joy: GraphNode = view.get_node("joy")
	assert_string_contains(joy.title, "😄")
	assert_string_contains(joy.title, "喜び")
	assert_eq((joy.get_child(0) as Label).text, "ジャンプ×1.5")


func test_バフのない感情にはバフなしと書かれている():
	var hope: GraphNode = view.get_node("hope")
	assert_eq((hope.get_child(0) as Label).text, "バフなし")


func test_出来事は元の感情の行として書かれ行き先へ線でつながる():
	assert_eq(view.get_connection_list().size(), chart.transitions.size())
	var neutral: GraphNode = view.get_node("neutral")
	var t: EmotionTransition = chart.transitions[0]
	assert_eq((neutral.get_child(1) as Label).text, t.event)
	var first: Dictionary = view.get_connection_list().filter(func(c): return c.from_port == 0)[0]
	assert_eq(first.from_node, &"neutral")
	assert_eq(first.to_node, t.to)


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
