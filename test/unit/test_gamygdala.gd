extends GutTest
## GAMYGDALA移植版のテスト。期待値は本家 Gamygdala.js を Node で実行して得たもの。


func test_Beliefは確からしさと目標への一致度をマイナス1から1に収める():
	var b := Gamygdala.Belief.new(2.0, &"x", [&"g"], [-3.0])
	assert_eq(b.likelihood, 1.0)
	assert_eq(b.goal_congruences, [-1.0])


var engine: Gamygdala


func before_each():
	engine = Gamygdala.new()


## エージェントの感情状態が expected（感情名→強さ）と一致するか、誤差を許して確かめる
func assert_emotions(agent: Gamygdala.Agent, expected: Dictionary, use_gain := false) -> void:
	var actual := {}
	for e in agent.get_emotional_state(use_gain):
		actual[e.name] = e.intensity
	assert_eq(actual.size(), expected.size(), "感情の数が違う: %s" % actual)
	for name in expected:
		assert_true(actual.has(StringName(name)), "%s がない: %s" % [name, actual])
		if actual.has(StringName(name)):
			assert_almost_eq(actual[StringName(name)], expected[name], 0.000001, name)


func test_良いことが確定すると喜ぶ():
	var a := engine.create_agent(&"a")
	var goal := engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.appraise_belief(1.0, &"", [&"win"], [1.0])
	assert_emotions(a, {"joy": 0.5})
	assert_eq(goal.likelihood, 1.0)


func test_良いことが起きそうだと希望を持つ():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.appraise_belief(0.5, &"", [&"win"], [1.0])
	assert_emotions(a, {"hope": 0.25})


func test_悪いことが起きそうだと恐れる():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.appraise_belief(0.5, &"", [&"win"], [-1.0])
	assert_emotions(a, {"fear": 0.25})


func test_悪いことが確定すると苦しむ():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.appraise_belief(1.0, &"", [&"win"], [-1.0])
	assert_emotions(a, {"distress": 0.5})


func test_希望を持った後に良いことが確定すると満足と喜び():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.appraise_belief(0.6, &"", [&"win"], [1.0])
	engine.appraise_belief(1.0, &"", [&"win"], [1.0])
	assert_emotions(a, {"hope": 0.3, "satisfaction": 0.2, "joy": 0.2})


func test_恐れていたことが確定すると恐れが的中し苦しむ():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"die", -1.0)
	engine.appraise_belief(0.6, &"", [&"die"], [1.0])
	engine.appraise_belief(1.0, &"", [&"die"], [1.0])
	assert_emotions(a, {"fear": 0.3, "fear-confirmed": 0.2, "distress": 0.2})


func test_達成目標は一度確定すると変わらない():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.appraise_belief(1.0, &"", [&"win"], [1.0])
	engine.appraise_belief(1.0, &"", [&"win"], [-1.0])
	assert_emotions(a, {"joy": 0.5})


func test_増分の出来事は見込みに加算される():
	var a := engine.create_agent(&"a")
	var goal := engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.appraise_belief(0.2, &"", [&"win"], [1.0], true)
	assert_almost_eq(goal.likelihood, 0.7, 0.000001)
	assert_emotions(a, {"hope": 0.2})


func test_他人のせいで目標が妨げられるとその人に怒る():
	var a := engine.create_agent(&"a")
	engine.create_agent(&"b")
	engine.create_goal_for_agent(&"a", &"star", 1.0)
	engine.appraise_belief(1.0, &"b", [&"star"], [-1.0])
	assert_emotions(a, {"distress": 0.5, "anger": 0.5})
	var relation := a.get_relation(&"b")
	assert_eq(relation.like, 0.0, "関係がなければ好き嫌い0で作られる")
	assert_eq(relation.emotion_list.size(), 1)
	assert_eq(relation.emotion_list[0].name, &"anger")


func test_他人のおかげで目標が叶うとその人に感謝する():
	var a := engine.create_agent(&"a")
	engine.create_agent(&"b")
	engine.create_goal_for_agent(&"a", &"star", 1.0)
	engine.appraise_belief(1.0, &"b", [&"star"], [1.0])
	assert_emotions(a, {"joy": 0.5, "gratitude": 0.5})


func _setup_fan_and_rival() -> Array[Gamygdala.Agent]:
	engine.create_agent(&"a")
	var fan := engine.create_agent(&"fan")
	var rival := engine.create_agent(&"rival")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.create_relation(&"fan", &"a", 1.0)
	engine.create_relation(&"rival", &"a", -0.5)
	return [fan, rival]


func test_好きな人に良いことがあると喜び_嫌いな人だと妬む():
	var pair := _setup_fan_and_rival()
	engine.appraise_belief(1.0, &"", [&"win"], [1.0])
	assert_emotions(pair[0], {"happy-for": 0.5})
	assert_emotions(pair[1], {"resentment": 0.25})


func test_好きな人に悪いことがあると同情し_嫌いな人だとざまあみろと思う():
	var pair := _setup_fan_and_rival()
	engine.appraise_belief(1.0, &"", [&"win"], [-1.0])
	assert_emotions(pair[0], {"pity": 0.5})
	assert_emotions(pair[1], {"gloating": 0.25})


func test_好きな人のために良いことをすると満悦する():
	engine.create_agent(&"a")
	var helper := engine.create_agent(&"helper")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.create_relation(&"helper", &"a", 0.8)
	engine.appraise_belief(1.0, &"helper", [&"win"], [1.0])
	assert_emotions(helper, {"happy-for": 0.4, "gratification": 0.4})


func test_好きな人に悪いことをすると後悔する():
	engine.create_agent(&"a")
	var helper := engine.create_agent(&"helper")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.create_relation(&"helper", &"a", 0.8)
	engine.appraise_belief(1.0, &"helper", [&"win"], [-1.0])
	assert_emotions(helper, {"pity": 0.4, "remorse": 0.4})


func test_同じ目標を持つ全員がそれぞれ評価する():
	var a := engine.create_agent(&"a")
	var b := engine.create_agent(&"b")
	engine.create_goal_for_agent(&"a", &"star", 1.0)
	engine.create_goal_for_agent(&"b", &"star", 1.0)
	engine.appraise_belief(1.0, &"a", [&"star"], [1.0])
	assert_emotions(a, {"joy": 0.5})
	assert_emotions(b, {"joy": 0.5, "gratitude": 0.5})


func test_ゲインを掛けると強さが0から1に収まる():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.set_gain(3.0)
	engine.appraise_belief(1.0, &"", [&"win"], [1.0])
	assert_emotions(a, {"joy": 0.6}, true)
	assert_emotions(a, {"joy": 0.5}, false)


func test_指数減衰では1秒ごとに強さが減衰係数倍になる():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.appraise_belief(1.0, &"", [&"win"], [1.0])
	engine.decay_all(1.0)
	assert_emotions(a, {"joy": 0.4})


func test_線形減衰では強さが一定の割合で減り0未満で消える():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.set_decay(0.1, Gamygdala.DecayType.LINEAR)
	engine.appraise_belief(1.0, &"", [&"win"], [1.0])
	engine.decay_all(2.0)
	assert_emotions(a, {"joy": 0.3})
	engine.decay_all(3.0)
	assert_emotions(a, {})


func test_相手に向けた感情も減衰する():
	var a := engine.create_agent(&"a")
	engine.create_agent(&"b")
	engine.create_goal_for_agent(&"a", &"star", 1.0)
	engine.appraise_belief(1.0, &"b", [&"star"], [-1.0])
	engine.decay_all(1.0)
	assert_emotions(a, {"distress": 0.4, "anger": 0.4})
	assert_almost_eq(a.get_relation(&"b").emotion_list[0].intensity, 0.4, 0.000001)


func test_感情状態をPADに変換できる():
	var a := engine.create_agent(&"a")
	engine.create_agent(&"b")
	engine.create_goal_for_agent(&"a", &"star", 1.0)
	engine.appraise_belief(1.0, &"b", [&"star"], [-1.0])
	var pad := a.get_pad_state(false)
	assert_almost_eq(pad, Vector3(-0.56, 0.435, -0.055), Vector3.ONE * 0.000001)
	a.set_gain(2.0)
	var gained := a.get_pad_state(true)
	assert_almost_eq(gained, Vector3(-0.528302, 0.465241, -0.099099), Vector3.ONE * 0.000001)


func test_減衰で感情が消えても次の感情は正しく減衰する():
	# 原典との差異: 原典は削除した直後の要素の減衰を飛ばしてしまう
	var a := engine.create_agent(&"a")
	a.update_emotional_state(Gamygdala.Emotion.new(&"hope", 0.1))
	a.update_emotional_state(Gamygdala.Emotion.new(&"joy", 0.5))
	engine.set_decay(0.2, Gamygdala.DecayType.LINEAR)
	engine.decay_all(1.0)
	assert_emotions(a, {"joy": 0.3})


func test_一人の立場だけで出来事を評価できる():
	var a := engine.create_agent(&"a")
	var b := engine.create_agent(&"b")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	engine.create_goal_for_agent(&"b", &"win", 1.0)
	a.appraise(Gamygdala.Belief.new(1.0, &"", [&"win"], [1.0]))
	assert_emotions(a, {"joy": 0.5})
	assert_emotions(b, {})


func test_目標を取り除ける():
	var a := engine.create_agent(&"a")
	engine.create_goal_for_agent(&"a", &"win", 1.0)
	assert_true(a.remove_goal(&"win"))
	assert_false(a.has_goal(&"win"))
	assert_false(a.remove_goal(&"win"))
