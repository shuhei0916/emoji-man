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


## 感情を持つ主体（NPCやプレイヤー）
class Agent:
	var name: StringName
	var goals: Array[Goal] = []
	var internal_state: Array[Emotion] = []

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
		for owner in agents:
			if owner.has_goal(goal.name):
				_evaluate_internal_emotion(utility, delta_likelihood, goal.likelihood, owner)


func _calculate_delta_likelihood(goal: Goal, congruence: float, likelihood: float, _is_incremental: bool) -> float:
	var old_likelihood := goal.likelihood
	var new_likelihood := (congruence * likelihood + 1.0) / 2.0
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
