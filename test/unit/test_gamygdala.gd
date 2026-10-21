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
