class_name EmotionChartView
extends GraphEdit
## 感情チャートを、Godot標準の GraphEdit でグラフとして描く画面。
## 感情は GraphNode（見出しに絵文字と名前、1行目にバフ）、出来事はその下の行で、
## 行の右のポートから行き先の感情へ線を引く。系統ごとに GraphFrame で囲む。読み取り専用。

const NO_BUFF := "バフなし"
const PORT_COLOR := Color(0.55, 0.6, 0.7)

var _highlighted: GraphNode


func _init() -> void:
	show_menu = false
	minimap_enabled = false


func build(chart: EmotionChart) -> void:
	var targets := {}
	for t in chart.transitions:
		targets[t.to] = true
	for def in chart.emotions:
		add_child(_make_node(def, chart, targets.has(def.id)))
	for key in chart.group_titles:
		var frame := GraphFrame.new()
		frame.name = key
		frame.title = chart.group_titles[key]
		add_child(frame)
		for def in chart.emotions:
			if def.group == key:
				attach_graph_element_to_frame(def.id, key)
	# 行き先は1行目（左のポート0）、元は出来事の行の順（右のポート番号）
	var port_of := {}
	for t in chart.transitions:
		var port: int = port_of.get(t.from, 0)
		port_of[t.from] = port + 1
		connect_node(t.from, port, t.to, 0)


## 指定した感情のノードだけを強調する
func highlight(id: StringName) -> void:
	if _highlighted != null:
		_highlighted.selected = false
	_highlighted = get_node_or_null(NodePath(id)) as GraphNode
	if _highlighted != null:
		_highlighted.selected = true


func _make_node(def: EmotionDef, chart: EmotionChart, is_target: bool) -> GraphNode:
	var node := GraphNode.new()
	node.name = def.id
	node.title = "%s %s" % [def.emoji, def.label]
	node.position_offset = def.position
	node.draggable = false
	var buff := Label.new()
	buff.text = def.buff_text() if def.buff_text() != "" else NO_BUFF
	node.add_child(buff)
	node.set_slot(0, is_target, 0, PORT_COLOR, false, 0, PORT_COLOR)
	for t in chart.transitions:
		if t.from != def.id:
			continue
		var row := Label.new()
		row.text = t.event
		node.add_child(row)
		node.set_slot(node.get_child_count() - 1, false, 0, PORT_COLOR, true, 0, PORT_COLOR)
	return node
