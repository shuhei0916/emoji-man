class_name EmotionChartView
extends GraphEdit
## 感情チャートを、Godot標準の GraphEdit でグラフとして描く画面。
## 感情は GraphNode（見出しに大きな絵文字、その下に括弧付きの名前とバフ）、系統ごとに GraphFrame で囲む。
## 遷移は GraphEdit の線では矢印や文字を描けないため、上に重ねたレイヤーに矢印と出来事を自分で描く。読み取り専用。

const NO_BUFF := "バフなし"
const TITLE_FONT_SIZE := 36
## 行きと帰りの矢印を横へずらす幅（画面上のピクセル）
const ARROW_OFFSET := 7.0
const ARROW_COLOR := Color(0.9, 0.92, 0.98)
const DECAY_ARROW_COLOR := Color(0.6, 0.64, 0.72)
const LABEL_FONT_SIZE := 14
## 出来事の名前を置く位置（矢印の始点からの割合）。扇状に広がる先のほうに置くと重なりにくい
const LABEL_AT := 0.55

## 描く矢印の一覧。{from, to, event}
var arrows: Array[Dictionary] = []

var _highlighted: GraphNode
var _arrow_layer: ArrowLayer


func _init() -> void:
	show_menu = false
	minimap_enabled = false


func build(chart: EmotionChart) -> void:
	for def in chart.emotions:
		add_child(_make_node(def))
	for key in chart.group_titles:
		var frame := GraphFrame.new()
		frame.name = key
		frame.title = chart.group_titles[key]
		add_child(frame)
		for def in chart.emotions:
			if def.group == key:
				attach_graph_element_to_frame(def.id, key)
	for t in chart.transitions:
		arrows.append({"from": t.from, "to": t.to, "event": t.event})
	_arrow_layer = ArrowLayer.new()
	_arrow_layer.view = self
	add_child(_arrow_layer)


## 指定した感情のノードだけを強調する
func highlight(id: StringName) -> void:
	if _highlighted != null:
		_highlighted.selected = false
	_highlighted = get_node_or_null(NodePath(id)) as GraphNode
	if _highlighted != null:
		_highlighted.selected = true


## from の矩形の縁から to の矩形の縁までの線分 [始点, 終点]。
## 進む向きの右側へ offset だけずらすので、行きと帰りの矢印は重ならない
static func arrow_between(from: Rect2, to: Rect2, offset: float) -> PackedVector2Array:
	var dir := (to.get_center() - from.get_center()).normalized()
	var shift := Vector2(-dir.y, dir.x) * offset
	var a := from.get_center() + shift
	var b := to.get_center() + shift
	return PackedVector2Array([_exit_point(from, a, dir), _exit_point(to, b, -dir)])


## 矩形の中の点 p から向き dir へ進んで、矩形の縁に出る点
static func _exit_point(rect: Rect2, p: Vector2, dir: Vector2) -> Vector2:
	var t := INF
	if dir.x > 0.0:
		t = minf(t, (rect.end.x - p.x) / dir.x)
	elif dir.x < 0.0:
		t = minf(t, (rect.position.x - p.x) / dir.x)
	if dir.y > 0.0:
		t = minf(t, (rect.end.y - p.y) / dir.y)
	elif dir.y < 0.0:
		t = minf(t, (rect.position.y - p.y) / dir.y)
	return p if t == INF else p + dir * t


func _make_node(def: EmotionDef) -> GraphNode:
	var node := GraphNode.new()
	node.name = def.id
	node.title = def.emoji
	node.position_offset = def.position
	node.draggable = false
	for child in node.get_titlebar_hbox().get_children():
		if child is Label:
			child.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
			child.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label := Label.new()
	name_label.text = "（%s）" % def.label
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_child(name_label)
	var buff := Label.new()
	buff.text = def.buff_text() if def.buff_text() != "" else NO_BUFF
	buff.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	buff.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	node.add_child(buff)
	return node


## ノードの上に重ねて、矢印と出来事の名前を描くレイヤー
class ArrowLayer:
	extends Control

	var view: EmotionChartView

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _process(_delta: float) -> void:
		if is_visible_in_tree():
			queue_redraw()

	func _draw() -> void:
		var font := get_theme_default_font()
		for arrow in view.arrows:
			var from := view.get_node_or_null(NodePath(arrow.from)) as Control
			var to := view.get_node_or_null(NodePath(arrow.to)) as Control
			if from == null or to == null:
				continue
			var decay: bool = arrow.event == EmotionChart.DECAY_EVENT
			var color := DECAY_ARROW_COLOR if decay else ARROW_COLOR
			var seg := EmotionChartView.arrow_between(_local_rect(from), _local_rect(to), ARROW_OFFSET)
			_draw_arrow(seg[0], seg[1], color, decay)
			# 「約10秒たつ」は数が多いので点線だけにし、画面下の凡例で説明する
			if not decay:
				_draw_label(font, arrow.event, seg[0], seg[1], color)

	func _local_rect(c: Control) -> Rect2:
		var r := c.get_global_rect()
		return Rect2(r.position - global_position, r.size)

	func _draw_arrow(a: Vector2, b: Vector2, color: Color, dashed: bool) -> void:
		var dir := (b - a).normalized()
		var head := 12.0
		var tip_base := b - dir * head
		if dashed:
			draw_dashed_line(a, tip_base, color, 2.0, 8.0)
		else:
			draw_line(a, tip_base, color, 2.0, true)
		var side := Vector2(-dir.y, dir.x) * head * 0.5
		draw_colored_polygon(PackedVector2Array([b, tip_base + side, tip_base - side]), color)

	## 出来事の名前を、矢印の先寄りの右側（進む向きから見て）に背景付きで描く
	func _draw_label(font: Font, text: String, a: Vector2, b: Vector2, color: Color) -> void:
		var dir := (b - a).normalized()
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE)
		var center := a.lerp(b, LABEL_AT) + Vector2(-dir.y, dir.x) * (text_size.y * 0.5 + 6.0)
		var box := Rect2(center - text_size / 2.0 - Vector2(4, 2), text_size + Vector2(8, 4))
		draw_rect(box, Color(0.1, 0.12, 0.18, 0.85))
		draw_string(font, center + Vector2(-text_size.x / 2.0, text_size.y * 0.3), text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE, color)
