class_name EmotionChartOverlay
extends CanvasLayer
## ステージ中にTabで開閉する感情チャート。開いている間はゲームを止め、対象の今の感情を強調する。

const FOOTER := "点線の矢印: %s と「ふつう」に戻る　　Tab: 閉じる" % EmotionChart.DECAY_EVENT
## ノードの位置の範囲に足す余白（左上は枠の見出し、右下はノードの大きさのぶん）
const MARGIN_TOP_LEFT := Vector2(60, 80)
const MARGIN_BOTTOM_RIGHT := Vector2(320, 220)

## 今の感情を強調するキャラクター
var target: EmojiCharacter
var view: EmotionChartView

var _chart := EmotionChart.default()


func _init() -> void:
	layer = 10
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	var shade := ColorRect.new()
	shade.color = Color(0.1, 0.12, 0.18, 0.85)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		box.set("offset_" + side, 24.0 if side in ["left", "top"] else -24.0)
	add_child(box)

	var title := Label.new()
	title.text = "感情チャート"
	title.add_theme_font_size_override("font_size", 32)
	box.add_child(title)

	view = EmotionChartView.new()
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.build(_chart)
	box.add_child(view)

	var footer := Label.new()
	footer.text = FOOTER
	box.add_child(footer)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"chart"):
		toggle()
		if is_inside_tree():
			get_viewport().set_input_as_handled()


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func open() -> void:
	visible = true
	get_tree().paused = true
	if target != null:
		view.highlight(EmojiExpression.choose_def(target.agent.get_emotional_state(), _chart).id)
	_fit_view.call_deferred()


func close() -> void:
	visible = false
	get_tree().paused = false


## 図全体が画面に収まるように拡大率とスクロール位置を合わせる
func _fit_view() -> void:
	if view.size.x <= 0.0 or view.size.y <= 0.0:
		return
	var rect := Rect2(_chart.emotions[0].position, Vector2.ZERO)
	for def in _chart.emotions:
		rect = rect.expand(def.position)
	rect.position -= MARGIN_TOP_LEFT
	rect.size += MARGIN_TOP_LEFT + MARGIN_BOTTOM_RIGHT
	var zoom := minf(view.size.x / rect.size.x, view.size.y / rect.size.y)
	view.zoom = zoom
	view.scroll_offset = rect.position * zoom - (view.size - rect.size * zoom) / 2.0
