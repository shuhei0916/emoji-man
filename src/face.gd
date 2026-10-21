class_name Face
extends RefCounted

enum Mood { NEUTRAL, HAPPY, SAD, HAPPY_FOR, PITY, RESENTMENT, GLOATING }

const EMOJIS := {
	Mood.NEUTRAL: "😐",
	Mood.HAPPY: "😄",
}
const HAPPY_DURATION := 10.0

var mood := Mood.NEUTRAL
var _happy_time_left := 0.0


func obtain_wanted_item() -> void:
	mood = Mood.HAPPY
	_happy_time_left = HAPPY_DURATION


func update(delta: float) -> void:
	if mood != Mood.HAPPY:
		return
	_happy_time_left -= delta
	if _happy_time_left <= 0.0:
		mood = Mood.NEUTRAL


func get_emoji() -> String:
	return EMOJIS[mood]
