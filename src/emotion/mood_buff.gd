class_name MoodBuff
extends RefCounted
## 一番強い感情によって、キャラクターの動きにかかる倍率（バフ・デバフ）と、使える能力。
## 値は感情チャート（emotion_chart.tres）に書かれている。

var speed_multiplier := 1.0
var jump_height_multiplier := 1.0
var can_break := false


static func from_emotions(emotions: Array[Gamygdala.Emotion], chart := EmotionChart.default()) -> MoodBuff:
	var buff := MoodBuff.new()
	var def := chart.get_emotion(EmojiExpression.dominant(emotions))
	if def == null:
		return buff
	buff.jump_height_multiplier = def.jump_height_multiplier
	buff.speed_multiplier = def.speed_multiplier
	buff.can_break = def.can_break
	return buff
