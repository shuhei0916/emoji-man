class_name MoodBuff
extends RefCounted
## 一番強い感情によって、キャラクターの動きにかかる倍率（バフ・デバフ）と、使える能力。

## 喜び系: ジャンプが高くなる（ざまあみろも、本人にとっては喜び）
const HAPPY_EMOTIONS: Array[StringName] = [
	&"joy", &"satisfaction", &"relief", &"happy-for", &"gratitude", &"gratification", &"gloating",
]
## 落ち込み系: 移動が遅くなる
const DOWN_EMOTIONS: Array[StringName] = [
	&"distress", &"disappointment", &"fear-confirmed", &"pity", &"remorse",
]
## 怒り系: 箱を壊せる
const ANGRY_EMOTIONS: Array[StringName] = [&"anger"]
const HAPPY_JUMP_HEIGHT := 1.5
const DOWN_SPEED := 0.5

var speed_multiplier := 1.0
var jump_height_multiplier := 1.0
var can_break := false


static func from_emotions(emotions: Array[Gamygdala.Emotion]) -> MoodBuff:
	var buff := MoodBuff.new()
	var mood := EmojiExpression.dominant(emotions)
	if mood in HAPPY_EMOTIONS:
		buff.jump_height_multiplier = HAPPY_JUMP_HEIGHT
	elif mood in DOWN_EMOTIONS:
		buff.speed_multiplier = DOWN_SPEED
	elif mood in ANGRY_EMOTIONS:
		buff.can_break = true
	return buff
