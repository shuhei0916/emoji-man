class_name EmotionWorld
extends Node
## シーン全体で1つの感情エンジン（GAMYGDALA）を持ち、ゲーム内の出来事を感情として評価する。
## キャラクターより先にシーンツリーへ置くこと。

const GROUP := &"emotion_world"
## 線形減衰の1秒あたりの減少量。標準的な感情（強さ0.5）は10秒で消える
const DECAY_PER_SECOND := 0.05
## 好き・嫌いを関係の値にするときの大きさ
const LIKE := 1.0
const DISLIKE := -1.0

var engine := Gamygdala.new()


func _init() -> void:
	add_to_group(GROUP)
	engine.set_decay(DECAY_PER_SECOND, Gamygdala.DecayType.LINEAR)


func _process(delta: float) -> void:
	engine.decay_all(delta)


## キャラクターを感情の主体として登録する
func register(id: StringName, likes: Array[StringName], dislikes: Array[StringName], wants: Array[StringName]) -> Gamygdala.Agent:
	var agent := engine.create_agent(id)
	for other in likes:
		agent.update_relation(other, LIKE)
	for other in dislikes:
		agent.update_relation(other, DISLIKE)
	for item in wants:
		engine.create_goal_for_agent(id, _want_goal(id, item), 1.0)
	return agent


## taker が item を手に入れた。欲しがっていた本人には良いこと、他に欲しがっていた人には taker のせいの悪いこと
func item_taken(taker: StringName, item: StringName) -> void:
	var goal_names: Array[StringName] = []
	var congruences: Array[float] = []
	for agent in engine.agents:
		var goal := agent.get_goal_by_name(_want_goal(agent.name, item))
		if goal == null:
			continue
		# 欲しい気持ちは手に入れた後もなくならないので、毎回まっさらな見込みから評価する
		goal.likelihood = 0.5
		goal_names.append(goal.name)
		congruences.append(1.0 if agent.name == taker else -1.0)
	if goal_names.is_empty():
		return
	engine.appraise_belief(1.0, taker, goal_names, congruences)


static func _want_goal(id: StringName, item: StringName) -> StringName:
	return StringName("%s/wants/%s" % [id, item])
