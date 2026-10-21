class_name Gamygdala
extends RefCounted
## GAMYGDALA 感情エンジンの GDScript 移植版。
##
## 原典: https://github.com/broekens/gamygdala (js/Gamygdala.js)
## Copyright (c) 2015 broekens, MIT License（同じフォルダの LICENSE を参照）
## Popescu, Broekens, van Someren (2014) "GAMYGDALA: an Emotion Engine for Games"


## 出来事についての信念。どの目標の達成にどれだけ近づく／遠ざかるかを表す
class Belief:
	var likelihood: float
	var causal_agent_name: StringName
	var affected_goal_names: Array[StringName] = []
	var goal_congruences: Array[float] = []
	var is_incremental: bool

	func _init(p_likelihood: float, p_causal_agent_name: StringName, p_affected_goal_names: Array, p_goal_congruences: Array, p_is_incremental := false) -> void:
		likelihood = clampf(p_likelihood, -1.0, 1.0)
		causal_agent_name = p_causal_agent_name
		affected_goal_names.assign(p_affected_goal_names)
		for c in p_goal_congruences:
			goal_congruences.append(clampf(c, -1.0, 1.0))
		is_incremental = p_is_incremental


## 感情とその強さ
class Emotion:
	var name: StringName
	var intensity: float

	func _init(p_name: StringName, p_intensity: float) -> void:
		name = p_name
		intensity = p_intensity


## 目標。utility は重要度（負なら起きてほしくないこと）、likelihood は達成の見込み（0〜1、最初は0.5）
class Goal:
	var name: StringName
	var utility: float
	var likelihood := 0.5
	var is_maintenance_goal: bool

	func _init(p_name: StringName, p_utility: float, p_is_maintenance_goal := false) -> void:
		name = p_name
		utility = p_utility
		is_maintenance_goal = p_is_maintenance_goal


## ある相手への関係。like は好き嫌い（-1〜1）、emotion_list はその相手に向けた感情（怒り・同情など）
class Relation:
	var agent_name: StringName
	var like: float
	var emotion_list: Array[Emotion] = []

	func _init(p_target_name: StringName, p_like: float) -> void:
		agent_name = p_target_name
		like = p_like

	func add_emotion(emotion: Emotion) -> void:
		for e in emotion_list:
			if e.name == emotion.name:
				e.intensity += emotion.intensity
				return
		emotion_list.append(Emotion.new(emotion.name, emotion.intensity))


## 感情を持つ主体（NPCやプレイヤー）
class Agent:
	var name: StringName
	var goals: Array[Goal] = []
	var internal_state: Array[Emotion] = []
	var current_relations: Array[Relation] = []

	func _init(p_name: StringName) -> void:
		name = p_name

	func add_goal(goal: Goal) -> void:
		goals.append(goal)

	func has_goal(goal_name: StringName) -> bool:
		return get_goal_by_name(goal_name) != null

	func get_goal_by_name(goal_name: StringName) -> Goal:
		for g in goals:
			if g.name == goal_name:
				return g
		return null

	## 同じ感情が既にあれば強さを足し合わせる
	func update_emotional_state(emotion: Emotion) -> void:
		for e in internal_state:
			if e.name == emotion.name:
				e.intensity += emotion.intensity
				return
		internal_state.append(Emotion.new(emotion.name, emotion.intensity))

	func get_emotional_state(_use_gain := false) -> Array[Emotion]:
		return internal_state

	## 相手との関係を設定する（なければ作る）
	func update_relation(agent_name: StringName, like: float) -> void:
		var relation := get_relation(agent_name)
		if relation == null:
			current_relations.append(Relation.new(agent_name, like))
		else:
			relation.like = like

	func has_relation_with(agent_name: StringName) -> bool:
		return get_relation(agent_name) != null

	func get_relation(agent_name: StringName) -> Relation:
		for r in current_relations:
			if r.agent_name == agent_name:
				return r
		return null


var agents: Array[Agent] = []
var goals: Array[Goal] = []


func create_agent(agent_name: StringName) -> Agent:
	var agent := Agent.new(agent_name)
	register_agent(agent)
	return agent


func register_agent(agent: Agent) -> void:
	agents.append(agent)


func get_agent_by_name(agent_name: StringName) -> Agent:
	for a in agents:
		if a.name == agent_name:
			return a
	return null


func create_goal_for_agent(agent_name: StringName, goal_name: StringName, goal_utility: float, is_maintenance_goal := false) -> Goal:
	var agent := get_agent_by_name(agent_name)
	if agent == null:
		push_error("Gamygdala: agent %s does not exist" % agent_name)
		return null
	var goal := get_goal_by_name(goal_name)
	if goal == null:
		goal = Goal.new(goal_name, goal_utility)
		register_goal(goal)
	agent.add_goal(goal)
	if is_maintenance_goal:
		goal.is_maintenance_goal = true
	return goal


func register_goal(goal: Goal) -> void:
	if get_goal_by_name(goal.name) == null:
		goals.append(goal)


func get_goal_by_name(goal_name: StringName) -> Goal:
	for g in goals:
		if g.name == goal_name:
			return g
	return null


## source から target への関係（好き嫌い -1〜1）を作る
func create_relation(source_name: StringName, target_name: StringName, like: float) -> void:
	var source := get_agent_by_name(source_name)
	var target := get_agent_by_name(target_name)
	if source == null or target == null or like < -1.0 or like > 1.0:
		push_error("Gamygdala: cannot relate %s to %s with %s" % [source_name, target_name, like])
		return
	source.update_relation(target_name, like)


func appraise_belief(likelihood: float, causal_agent_name: StringName, affected_goal_names: Array, goal_congruences: Array, is_incremental := false) -> void:
	appraise(Belief.new(likelihood, causal_agent_name, affected_goal_names, goal_congruences, is_incremental))


## 出来事を、影響を受ける目標の持ち主全員の立場で評価する
func appraise(belief: Belief) -> void:
	for i in belief.affected_goal_names.size():
		var goal := get_goal_by_name(belief.affected_goal_names[i])
		if goal == null:
			continue
		var utility := goal.utility
		var delta_likelihood := _calculate_delta_likelihood(goal, belief.goal_congruences[i], belief.likelihood, belief.is_incremental)
		var desirability := delta_likelihood * utility
		for owner in agents:
			if owner.has_goal(goal.name):
				_evaluate_internal_emotion(utility, delta_likelihood, goal.likelihood, owner)
				_agent_actions(owner.name, belief.causal_agent_name, owner.name, desirability, utility, delta_likelihood)
				# 目標の持ち主と関係を持つ人は、他人についての感情を抱く
				for other in agents:
					var relation := other.get_relation(owner.name)
					if relation != null:
						_evaluate_social_emotion(utility, desirability, delta_likelihood, relation, other)
						_agent_actions(owner.name, belief.causal_agent_name, other.name, desirability, utility, delta_likelihood)


## 出来事による目標の見込みの変化量を求め、目標の見込みを更新する。
## 増分の出来事は見込みに加算し、そうでなければ出来事が見込みそのものを決める。
## 達成目標（維持目標でないもの）は、一度確定（1 か -1）したら変わらない
func _calculate_delta_likelihood(goal: Goal, congruence: float, likelihood: float, is_incremental: bool) -> float:
	var old_likelihood := goal.likelihood
	if not goal.is_maintenance_goal and (old_likelihood >= 1.0 or old_likelihood <= -1.0):
		return 0.0
	var new_likelihood: float
	if is_incremental:
		new_likelihood = clampf(old_likelihood + likelihood * congruence, -1.0, 1.0)
	else:
		new_likelihood = (congruence * likelihood + 1.0) / 2.0
	goal.likelihood = new_likelihood
	return new_likelihood - old_likelihood


## 目標の持ち主自身の感情（希望・恐れ・喜び・苦しみ・満足・恐れの的中・失望・安堵）を評価する
func _evaluate_internal_emotion(utility: float, delta_likelihood: float, likelihood: float, agent: Agent) -> void:
	var positive: bool
	if utility >= 0.0:
		positive = delta_likelihood >= 0.0
	else:
		positive = delta_likelihood < 0.0

	var emotions: Array[StringName] = []
	if likelihood > 0.0 and likelihood < 1.0:
		emotions.append(&"hope" if positive else &"fear")
	elif likelihood == 1.0:
		if utility >= 0.0:
			if delta_likelihood < 0.5:
				emotions.append(&"satisfaction")
			emotions.append(&"joy")
		else:
			if delta_likelihood < 0.5:
				emotions.append(&"fear-confirmed")
			emotions.append(&"distress")
	elif likelihood == 0.0:
		if utility >= 0.0:
			if delta_likelihood > 0.5:
				emotions.append(&"disappointment")
			emotions.append(&"distress")
		else:
			if delta_likelihood > 0.5:
				emotions.append(&"relief")
			emotions.append(&"joy")

	var intensity := absf(utility * delta_likelihood)
	if intensity != 0.0:
		for emotion_name in emotions:
			agent.update_emotional_state(Emotion.new(emotion_name, intensity))


## 他人の目標についての感情（喜び・妬み・同情・ざまあみろ）を評価する
func _evaluate_social_emotion(utility: float, desirability: float, delta_likelihood: float, relation: Relation, agent: Agent) -> void:
	var emotion_name: StringName
	if desirability >= 0.0:
		emotion_name = &"happy-for" if relation.like >= 0.0 else &"resentment"
	else:
		emotion_name = &"pity" if relation.like >= 0.0 else &"gloating"
	var emotion := Emotion.new(emotion_name, absf(utility * delta_likelihood * relation.like))
	if emotion.intensity != 0.0:
		relation.add_emotion(emotion)
		agent.update_emotional_state(emotion)


## 出来事を引き起こした人に関わる感情（感謝・怒り・満悦・後悔）を評価する。
## affected_name: 目標の持ち主, causal_name: 引き起こした人, self_name: 感情を持つ人
func _agent_actions(affected_name: StringName, causal_name: StringName, self_name: StringName, desirability: float, utility: float, delta_likelihood: float) -> void:
	if causal_name == &"":
		return
	if affected_name == self_name and self_name != causal_name:
		# 自分の目標が他人によって左右された
		var emotion := Emotion.new(&"gratitude" if desirability >= 0.0 else &"anger", absf(utility * delta_likelihood))
		var self_agent := get_agent_by_name(self_name)
		if not self_agent.has_relation_with(causal_name):
			self_agent.update_relation(causal_name, 0.0)
		self_agent.get_relation(causal_name).add_emotion(emotion)
		self_agent.update_emotional_state(emotion)
	if affected_name != self_name and causal_name == self_name:
		# 自分が他人の目標を左右した。好きな相手なら満悦・後悔を抱く
		# （原典は引き起こした人が未登録だと例外になるため、ここでは無視する）
		var causal_agent := get_agent_by_name(causal_name)
		if causal_agent == null or not causal_agent.has_relation_with(affected_name):
			return
		var relation := causal_agent.get_relation(affected_name)
		if relation.like < 0.0:
			return
		var emotion := Emotion.new(&"gratification" if desirability >= 0.0 else &"remorse", absf(utility * delta_likelihood * relation.like))
		relation.add_emotion(emotion)
		causal_agent.update_emotional_state(emotion)
