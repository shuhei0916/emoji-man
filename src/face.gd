class_name Face
extends RefCounted

enum Mood { NEUTRAL, HAPPY, SAD, HAPPY_FOR, PITY, RESENTMENT, GLOATING, ANGER, GRATITUDE }

const EMOJIS := {
	Mood.NEUTRAL: "😐",
	Mood.HAPPY: "😄",
	Mood.SAD: "😢",
	Mood.HAPPY_FOR: "🥰",
	Mood.PITY: "🥺",
	Mood.RESENTMENT: "😒",
	Mood.GLOATING: "😏",
	Mood.ANGER: "😠",
	Mood.GRATITUDE: "🥹",
}
## 感情が続く秒数。過ぎると普通に戻る
const MOOD_DURATION := 10.0

var mood := Mood.NEUTRAL
var _mood_time_left := 0.0


func feel(new_mood: Mood) -> void:
	mood = new_mood
	_mood_time_left = MOOD_DURATION


func update(delta: float) -> void:
	if mood == Mood.NEUTRAL:
		return
	_mood_time_left -= delta
	if _mood_time_left <= 0.0:
		mood = Mood.NEUTRAL


func get_emoji() -> String:
	return EMOJIS[mood]
