class_name EmojiExpression
extends RefCounted
## 感情状態（GAMYGDALAの感情と強さの一覧）から、顔に表示する絵文字を1つ選ぶ。
## 絵文字と複合絵文字は感情チャート（emotion_chart.tres）に書かれている。

## これ未満の強さの感情は表に出ない
const MIN_INTENSITY := 0.01

## 2つ目の感情が1つ目のこの割合以上の強さなら、複合になる
const COMPOUND_RATIO := 0.5

## 強さが同じときの優先順位（先頭ほど優先）。
## 相手や状況が特定された感情ほど優先し、それに伴いがちな喜び・苦しみは最後にする
const PRIORITY: Array[StringName] = [
	&"anger", &"gratitude", &"gratification", &"remorse",
	&"gloating", &"resentment", &"pity", &"happy-for",
	&"fear-confirmed", &"satisfaction", &"disappointment", &"relief",
	&"fear", &"hope", &"distress", &"joy",
]


static func choose(emotions: Array[Gamygdala.Emotion], chart := EmotionChart.default()) -> String:
	return choose_def(emotions, chart).emoji


## 顔に出す感情の定義。感情がなければ普通の顔、上位2つが組み合わせなら複合絵文字
static func choose_def(emotions: Array[Gamygdala.Emotion], chart := EmotionChart.default()) -> EmotionDef:
	var ranked := _rank(emotions)
	if ranked.is_empty():
		return chart.get_emotion(EmotionChart.NEUTRAL)
	if ranked.size() >= 2 and ranked[1].intensity >= ranked[0].intensity * COMPOUND_RATIO:
		var compound := chart.compound_of(ranked[0].name, ranked[1].name)
		if compound != null:
			return compound
	return chart.get_emotion(ranked[0].name)


## 表に出ている一番強い感情の名前。なければ空
static func dominant(emotions: Array[Gamygdala.Emotion]) -> StringName:
	var ranked := _rank(emotions)
	return ranked[0].name if not ranked.is_empty() else &""


## 表に出る強さの感情を、強い順に並べる。強さが同じなら優先順位の順
static func _rank(emotions: Array[Gamygdala.Emotion]) -> Array[Gamygdala.Emotion]:
	var ranked := emotions.filter(func(e: Gamygdala.Emotion) -> bool: return e.intensity >= MIN_INTENSITY)
	ranked.sort_custom(func(a: Gamygdala.Emotion, b: Gamygdala.Emotion) -> bool:
		if not is_equal_approx(a.intensity, b.intensity):
			return a.intensity > b.intensity
		return PRIORITY.find(a.name) < PRIORITY.find(b.name))
	return ranked
