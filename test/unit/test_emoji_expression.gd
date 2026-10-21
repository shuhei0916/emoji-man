extends GutTest
## 感情状態から表示する絵文字を1つ選ぶ表示層のテスト


func _emotions(pairs: Dictionary) -> Array[Gamygdala.Emotion]:
	var list: Array[Gamygdala.Emotion] = []
	for name in pairs:
		list.append(Gamygdala.Emotion.new(StringName(name), pairs[name]))
	return list


func test_感情がなければ普通の顔():
	assert_eq(EmojiExpression.choose(_emotions({})), "😐")


var single_emotions := [
	["joy", "😄"],
	["distress", "😢"],
	["hope", "🙂"],
	["fear", "😨"],
	["satisfaction", "😌"],
	["fear-confirmed", "😱"],
	["disappointment", "😞"],
	["relief", "😅"],
	["happy-for", "🥰"],
	["resentment", "😒"],
	["pity", "🥺"],
	["gloating", "😏"],
	["gratitude", "🥹"],
	["anger", "😠"],
	["gratification", "😎"],
	["remorse", "😣"],
]


func test_感情が1つならその絵文字(p = use_parameters(single_emotions)):
	assert_eq(EmojiExpression.choose(_emotions({p[0]: 0.5})), p[1])


func test_一番強い感情の絵文字を表示する():
	assert_eq(EmojiExpression.choose(_emotions({"hope": 0.2, "anger": 0.6, "joy": 0.4})), "😠")


func test_強さが同じなら優先順位の高い感情を表示する():
	# 怒りは苦しみより優先する（他人のせいの苦しみは怒りとして表に出る）
	assert_eq(EmojiExpression.choose(_emotions({"distress": 0.5, "anger": 0.5})), "😠")
	assert_eq(EmojiExpression.choose(_emotions({"anger": 0.5, "distress": 0.5})), "😠")


func test_弱すぎる感情は表に出ない():
	assert_eq(EmojiExpression.choose(_emotions({"anger": 0.005})), "😐")
	assert_eq(EmojiExpression.choose(_emotions({"anger": 0.005, "hope": 0.2})), "🙂")


func test_上位2つが特定の組み合わせなら複合絵文字を表示する():
	assert_eq(EmojiExpression.choose(_emotions({"joy": 0.5, "gloating": 0.5})), "😈")
	assert_eq(EmojiExpression.choose(_emotions({"gloating": 0.6, "joy": 0.4})), "😈", "順番によらない")


func test_組み合わせの2つ目が弱すぎると複合にならない():
	assert_eq(EmojiExpression.choose(_emotions({"joy": 0.5, "gloating": 0.1})), "😄")
