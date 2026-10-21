class_name EmojiExpression
extends RefCounted
## 感情状態（GAMYGDALAの感情と強さの一覧）から、顔に表示する絵文字を1つ選ぶ。

const NEUTRAL := "😐"
## これ未満の強さの感情は表に出ない
const MIN_INTENSITY := 0.01

const EMOJIS := {
	&"joy": "😄",
	&"distress": "😢",
	&"hope": "🙂",
	&"fear": "😨",
	&"satisfaction": "😌",
	&"fear-confirmed": "😱",
	&"disappointment": "😞",
	&"relief": "😅",
	&"happy-for": "🥰",
	&"resentment": "😒",
	&"pity": "🥺",
	&"gloating": "😏",
	&"gratitude": "🥹",
	&"anger": "😠",
	&"gratification": "😎",
	&"remorse": "😣",
}


## 上位2つの感情がこの組み合わせなら、複合絵文字を表示する
const COMPOUNDS := [
	[[&"joy", &"gloating"], "😈"],
]
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


static func choose(emotions: Array[Gamygdala.Emotion]) -> String:
	var ranked := _rank(emotions)
	if ranked.is_empty():
		return NEUTRAL
	if ranked.size() >= 2 and ranked[1].intensity >= ranked[0].intensity * COMPOUND_RATIO:
		var compound := _compound_of(ranked[0].name, ranked[1].name)
		if compound != "":
			return compound
	return EMOJIS[ranked[0].name]


static func _compound_of(a: StringName, b: StringName) -> String:
	for entry in COMPOUNDS:
		var pair: Array = entry[0]
		if (pair[0] == a and pair[1] == b) or (pair[0] == b and pair[1] == a):
			return entry[1]
	return ""


## 表に出る強さの感情を、強い順に並べる。強さが同じなら優先順位の順
static func _rank(emotions: Array[Gamygdala.Emotion]) -> Array[Gamygdala.Emotion]:
	var ranked := emotions.filter(func(e: Gamygdala.Emotion) -> bool: return e.intensity >= MIN_INTENSITY)
	ranked.sort_custom(func(a: Gamygdala.Emotion, b: Gamygdala.Emotion) -> bool:
		if not is_equal_approx(a.intensity, b.intensity):
			return a.intensity > b.intensity
		return PRIORITY.find(a.name) < PRIORITY.find(b.name))
	return ranked
